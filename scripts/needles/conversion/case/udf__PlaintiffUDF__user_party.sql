/*
description: >
  Populates PlaintiffUDF with fields from user_party_data for Plaintiff roles.

steps: |
  1. Disable triggers
  2. Create #ExcludedColumns (temp table to exclude specific columns)
  3. Create [VanceLawFirm_SA].[conversion].[FieldTitleMap] (field_title mapping table)
  4. Create [VanceLawFirm_SA].[PlaintiffUDF] (unpivoted pivot table for UDF values)
  5. Insert into [sma_MST_UDFDefinition]
  6. Insert into [sma_TRN_UDFValues]
  7. Enable triggers

dependencies:
  - [VanceLawFirm_SA].[NeedlesUserFields] from `needles/conversion/utility/create__NeedlesUserFields.sql`
  - [VanceLawFirm_SA].[PartyRoles] from `needles/conversion/utility/create__PartyRoles.sql`
  - [VanceLawFirm_SA].[CaseTypeMixture] from `needles/conversion/utility/create__CaseTypeMixture.sql`

notes: >
  - For each field in [user_party_matter] with [party_role] = 'Plaintiff',
    this process creates a UDF definition and populates UDF values from [user_party_data].
  - The script uses a persistent mapping table (conversion.FieldTitleMap) to
    map original field titles (e.g., 'D/B/A') to SQL-safe aliases (e.g., 'D_B_A').
  - A pivot/unpivot approach is used because the Needles user table structure stores UDF data in columns rather than rows.
  - #ExcludedColumns is a session-scoped temp table automatically created in tempdb (not schema-qualified).
*/


use [VanceLawFirm_SA]
go


---
alter table [sma_MST_UDFDefinition] disable trigger all
go

alter table sma_TRN_UDFValues disable trigger all
go
---

/* ------------------------------------------------------------------------------
[#ExcludedColumns] -- Temp table to exclude specific columns
	- Use this to define any columns that should be excluded from the Plaintiff UDF insert
*/ ------------------------------------------------------------------------------

if OBJECT_ID('tempdb..#ExcludedColumns') is not null
	drop table #ExcludedColumns;

create table #ExcludedColumns (
	column_name VARCHAR(128)
);
go

insert into #ExcludedColumns
	(
		column_name
	)
	values
		('casenum'),
		('modified_timestamp')
go


/* ---------------------------------------------------------------------------
[SA].[conversion].[FieldTitleMap] -- Field Title Mapping Table
	- This table is the driver for the rest of the UDF insert.
	- Filters out non-plaintiff user fields 
	- Maps original field titles (e.g., 'D/B/A') to SQL-safe aliases (e.g., 'D_B_A')
--------------------------------------------------------------------------- */

if exists (
    select *
    from sys.tables
    where name = 'FieldTitleMap'
      and type = 'U'
      and schema_id = schema_id('conversion')
)
begin
    drop table conversion.FieldTitleMap;
end;

create table conversion.FieldTitleMap (
    field_title        NVARCHAR(255) not null,
    alias_field_title  NVARCHAR(255) not null,
    column_name        NVARCHAR(255) not null,
    field_type         NVARCHAR(50)  not null,
    source_table       NVARCHAR(128) not null,
    constraint PK_FieldTitleMap primary key (alias_field_title, source_table)
);

insert into conversion.FieldTitleMap
	(
		field_title,
		alias_field_title,
		column_name,
		field_type,
		source_table
	)
	select distinct
		F.field_title,
		REPLACE(REPLACE(F.field_title, '/', '_'), ' ', '_') as alias_field_title,
		F.column_name,
		M.field_type,
		'user_party_data'									as source_table
	from [VanceLawFirm_Needles].[dbo].[user_party_matter] M
	join NeedlesUserFields F
		on F.field_num = M.ref_num
	join PartyRoles R
		on R.[Needles Roles] = M.party_role
	where
		R.[SA Party] = 'Plaintiff'
		and
		F.column_name in (
		 select
			 COLUMN_NAME
		 from [VanceLawFirm_Needles].INFORMATION_SCHEMA.COLUMNS
		 where TABLE_NAME = 'user_party_data'
		)
		and
		column_name not in (select column_name from #ExcludedColumns)
		and
		M.field_type <> 'label';


/* ---------------------------------------------------------------------------
[PlaintiffUDF] -- Pivot Table
	- build select
	- build unpviot
--------------------------------------------------------------------------- */
if OBJECT_ID('PlaintiffUDF', 'U') is not null
	drop table PlaintiffUDF;

declare @cols NVARCHAR(MAX);
declare @sql NVARCHAR(MAX);
declare @select_expr NVARCHAR(MAX);
declare @unpivot_expr NVARCHAR(MAX);

-- Build SELECT and UNPIVOT expressions from the mapping table
--select
--	@select_expr  = STRING_AGG(
--	'CONVERT(VARCHAR(MAX), [' + column_name + ']) AS [' + alias_field_title + ']',
--	', '),
--	@unpivot_expr = STRING_AGG('[' + alias_field_title + ']', ', ')
--from conversion.FieldTitleMap
--where
--	source_table = 'user_party_data';

select
	@select_expr  = STRING_AGG(
	CAST(
	case
		when field_type = 'name'
			then 'CONVERT(VARCHAR(MAX), ioci.UNQCID) AS [' + alias_field_title + ']'
		else 'CONVERT(VARCHAR(MAX), ud.[' + column_name + ']) AS [' + alias_field_title + ']'
	end
	as NVARCHAR(MAX)),
	', '
	),
	@unpivot_expr = STRING_AGG(
	CAST('[' + alias_field_title + ']' as NVARCHAR(MAX)),
	', '
	)
from conversion.FieldTitleMap
where
	source_table = 'user_party_data';


print @select_expr
print @unpivot_expr


-- Dynamic SQL to generate pivot table
set @sql = '
SELECT casnCaseID, casnOrgCaseTypeID, FieldTitle, FieldVal
INTO PlaintiffUDF
FROM ( 
    SELECT 
        cas.casnCaseID, 
        cas.casnOrgCaseTypeID, 
        ' + @select_expr + '
    FROM [VanceLawFirm_Needles]..user_party_data ud
	JOIN [VanceLawFirm_Needles]..cases_Indexed c
		 on c.casenum = ud.case_id
    JOIN [VanceLawFirm_Needles]..user_party_name un
		on un.party_id = ud.party_id
		AND un.[user_name] <> 0
    LEFT JOIN [VanceLawFirm_Needles]..user_party_matter upm
        ON upm.ref_num = un.ref_num
		AND upm.mattercode = c.matcode
    LEFT JOIN IndvOrgContacts_Indexed ioci
        ON ioci.SAGA = un.[user_name]
	JOIN sma_TRN_Cases cas 
        ON cas.cassCaseNumber = CONVERT(VARCHAR, ud.case_id)
) pv
UNPIVOT (FieldVal FOR FieldTitle IN (' + @unpivot_expr + ')) AS unpvt;';

exec sp_executesql @sql;

select * from PlaintiffUDF


/* ---------------------------------------------------------------------------
[sma_MST_UDFDefinition]
--------------------------------------------------------------------------- */

if exists (
	 select
		 *
	 from sys.tables
	 where name = 'PlaintiffUDF'
		 and type = 'U'
	)
begin
	insert into [sma_MST_UDFDefinition]
		(
			[udfsUDFCtg],
			[udfnRelatedPK],
			[udfsUDFName],
			[udfsScreenName],
			[udfsType],
			[udfsLength],
			[udfbIsActive],
			[udfshortName],
			[udfsNewValues],
			[udfnSortOrder]
		)
		select distinct
			'C'										   as [udfsUDFCtg],
			CST.cstnCaseTypeID						   as [udfnRelatedPK],
			M.field_title							   as [udfsUDFName],
			'Plaintiff'								   as [udfsScreenName],
			ucf.UDFType								   as [udfsType],
			ucf.field_len							   as [udfsLength],
			1										   as [udfbIsActive],
			'user_party_data' + ucf.column_name		   as [udfshortName],
			ucf.dropdownValues						   as [udfsNewValues],
			DENSE_RANK() over (order by M.field_title) as udfnSortOrder
		from [sma_MST_CaseType] CST
		join CaseTypeMixture mix
			on mix.[SmartAdvocate Case Type] = CST.cstsType
		join [VanceLawFirm_Needles].[dbo].[user_party_matter] M
			on M.mattercode = mix.matcode
				and M.field_type <> 'label'
		join conversion.FieldTitleMap map
			on map.field_title = M.field_title
				and map.source_table = 'user_party_data'
		join (select distinct FieldTitle from PlaintiffUDF) vd
			on vd.FieldTitle = map.alias_field_title
		join [dbo].[NeedlesUserFields] ucf
			on ucf.field_num = M.ref_num
		left join (
		 select distinct
			 table_Name,
			 column_name
		 from [VanceLawFirm_Needles].[dbo].[document_merge_params]
		 where table_Name = 'user_party_data'
		) dmp
			on dmp.column_name = ucf.field_Title
		left join [sma_MST_UDFDefinition] def
			on def.[udfnRelatedPK] = CST.cstnCaseTypeID
				and def.[udfsUDFName] = M.field_title
				and def.[udfsScreenName] = 'Plaintiff'
				and def.[udfsType] = ucf.UDFType
				and def.udfnUDFID is null
		order by M.field_title;
end

alter table [sma_MST_UDFDefinition] enable trigger all
go

/* ------------------------------------------------------------------------------
[sma_TRN_UDFValues]
*/ ------------------------------------------------------------------------------

if exists (
	 select
		 *
	 from sys.tables
	 where name = 'PlaintiffUDF'
		 and type = 'U'
	)
begin
	insert into [sma_TRN_UDFValues]
		(
			[udvnUDFID],
			[udvsScreenName],
			[udvsUDFCtg],
			[udvnRelatedID],
			[udvnSubRelatedID],
			[udvsUDFValue],
			[udvnRecUserID],
			[udvdDtCreated],
			[udvnModifyUserID],
			[udvdDtModified],
			[udvnLevelNo]
		)
		select
			def.udfnUDFID		as [udvnUDFID],
			'Plaintiff'			as [udvsScreenName],
			'C'					as [udvsUDFCtg],
			casnCaseID			as [udvnRelatedID],
			pln.plnnPlaintiffID as [udvnSubRelatedID],
			udf.FieldVal		as [udvsUDFValue],
			368					as [udvnRecUserID],
			GETDATE()			as [udvdDtCreated],
			null				as [udvnModifyUserID],
			null				as [udvdDtModified],
			null				as [udvnLevelNo]
		--select *
		from PlaintiffUDF udf
		join conversion.FieldTitleMap map
			on udf.FieldTitle = map.alias_field_title
				and map.source_table = 'user_party_data'
		join sma_TRN_Plaintiff pln
			on pln.plnnCaseID = udf.casnCaseID
				and pln.plnbIsPrimary = 1
		join sma_MST_UDFDefinition def
			on def.udfnRelatedPK = udf.casnOrgCaseTypeID
				and def.udfsUDFName = map.field_title
end


---
alter table [sma_MST_UDFDefinition] enable trigger all
go

alter table sma_TRN_UDFValues enable trigger all
go
---