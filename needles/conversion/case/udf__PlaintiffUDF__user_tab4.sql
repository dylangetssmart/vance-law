/*
Populates CaseUDF with all columns from [user_case_data]
*/

use [VanceLawFirm_SA]
go

if exists (
	 select
		 *
	 from sys.tables
	 where name = 'PlaintiffUDF'
		 and type = 'U'
	)
begin
	drop table PlaintiffUDF
end


if OBJECT_ID('tempdb..#ExcludedColumns') is not null
	drop table #ExcludedColumns;

create table #ExcludedColumns (
	column_name VARCHAR(128)
);
go

/* ------------------------------------------------------------------------------
Use this block if you need to exclude specific columns from being pushed to CaseUDF
*/ ------------------------------------------------------------------------------
---- Insert columns to exclude
insert into #ExcludedColumns
	(
		column_name
	)
	values
		('case_id'),
		('modified_timestamp'),
		('tab_id_location'),
		('tab_id'),
		('show_on_status_tab'),
		('case_status_attn'),
		('case_status_client')
go

-- Fetch all columns from [user_case_data] for unpivoting
declare @sql NVARCHAR(MAX) = N'';
select
	@sql = STRING_AGG(CONVERT(VARCHAR(MAX),
	N'CONVERT(VARCHAR(MAX), ' + QUOTENAME(column_name) + N') AS ' + QUOTENAME(column_name)
	), ', ')
from [VanceLawFirm_Needles].INFORMATION_SCHEMA.COLUMNS
where
	table_name = 'user_tab4_data'
	and
	TABLE_SCHEMA = 'dbo'
	and
	column_name not in (select column_name from #ExcludedColumns);
print @sql

-- Dynamically create the UNPIVOT list
declare @unpivot_list NVARCHAR(MAX) = N'';
select
	@unpivot_list = STRING_AGG(QUOTENAME(column_name), ', ')
from [VanceLawFirm_Needles].INFORMATION_SCHEMA.COLUMNS
where
	table_name = 'user_tab4_data'
	and
	TABLE_SCHEMA = 'dbo'
	and
	column_name not in (select column_name from #ExcludedColumns);
print @unpivot_list

-- Generate the dynamic SQL for creating the pivot table
set @sql = N'
SELECT casnCaseID, casnOrgCaseTypeID, FieldTitle, FieldVal
INTO PlaintiffUDF
FROM ( 
    SELECT 
        cas.casnCaseID, 
        cas.casnOrgCaseTypeID, ' + @sql + N'
    FROM [VanceLawFirm_Needles]..user_tab4_data ud
    JOIN sma_TRN_Cases cas ON cas.cassCaseNumber = CONVERT(VARCHAR, ud.case_id)
) pv
UNPIVOT (FieldVal FOR FieldTitle IN (' + @unpivot_list + N')) AS unpvt;';

exec sp_executesql @sql;
go

select
	*
from PlaintiffUDF

----------------------------
--UDF DEFINITION
----------------------------
alter table [sma_MST_UDFDefinition] disable trigger all
go

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
		) select distinct
			'C'										   as [udfsUDFCtg],
			CST.cstnCaseTypeID						   as [udfnRelatedPK],
			M.field_title							   as [udfsUDFName],
			'Plaintiff'								   as [udfsScreenName],
			ucf.UDFType								   as [udfsType],
			ucf.field_len							   as [udfsLength],
			1										   as [udfbIsActive],
			'user_tab4_data' + ucf.column_name		   as [udfshortName],
			ucf.dropdownValues						   as [udfsNewValues],
			DENSE_RANK() over (order by M.field_title) as udfnSortOrder
		from [sma_MST_CaseType] CST
		join CaseTypeMixture mix
			on mix.[SmartAdvocate Case Type] = CST.cstsType
		join [VanceLawFirm_Needles].[dbo].[user_tab4_matter] M			-- user_case_matter defines the user fields per mattercode (case type)
			on M.mattercode = mix.matcode
				and M.field_type <> 'label'
		join (select distinct fieldTitle from PlaintiffUDF) vd
			on vd.FieldTitle = M.field_title
		join [dbo].[NeedlesUserFields] ucf
			on ucf.field_num = M.ref_num
		--left join (
		--	select distinct
		--		table_Name,
		--		column_name
		--	from [VanceLawFirm_Needles].[dbo].[document_merge_params]
		--	where table_Name = 'user_case_data'
		--) dmp
		--	on dmp.column_name = ucf.field_Title
		left join [sma_MST_UDFDefinition] def
			on def.[udfnRelatedPK] = CST.cstnCaseTypeID
				and def.[udfsUDFName] = M.field_title
				and def.[udfsScreenName] = 'Plaintiff'
				and def.[udfsType] = ucf.UDFType
				and def.udfnUDFID is null
		order by M.field_title
end


alter table sma_trn_udfvalues disable trigger all
go

-- Table will not exist if it's empty or only contains ExlucedColumns
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
		) select
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
		from PlaintiffUDF udf
		join sma_TRN_Plaintiff pln
			on pln.plnnCaseID = udf.casnCaseID
				and pln.plnbIsPrimary = 1
		left join sma_MST_UDFDefinition def
			on def.udfnRelatedPK = udf.casnOrgCaseTypeID
				and def.udfsUDFName = FieldTitle
				and def.udfsScreenName = 'Plaintiff'

end



alter table sma_trn_udfvalues enable trigger all
go
