/*---
description: Base script to pivot and enrich EAV data from [user_party_data]
steps:
	1. Pivot the EAV table
	2. Enrich the pivoted data with context and UDF definitions
usage_instructions:
	1. Adjust variables and excluded columns
	2. Review field selections for the final output table
dependencies:
    - [NeedlesUserFields]
    - [PartyRoles]
notes: >
	- EAV (Entity - Attribute - Value) is pivoted using CROSS APPLY and STRING_AGG.
	- https://en.wikipedia.org/wiki/Entity%E2%80%93attribute%E2%80%93value_model
---*/


use [VanceLawFirm_SA]
go


-------------------------------------------------------------------------------
-- Setup variables
-------------------------------------------------------------------------------
declare @DatabaseName SYSNAME = 'VanceLawFirm_Needles';
declare @SchemaName SYSNAME = 'dbo';
declare @TableName SYSNAME = 'user_party_data';  -- source EAV table
declare @UnpivotValueList NVARCHAR(MAX);
declare @SQL NVARCHAR(MAX);

-- Define excluded columns for the pivot (columns NOT to be treated as EAV attributes)
if OBJECT_ID('tempdb..#ExcludedColumns') is not null
	drop table #ExcludedColumns;

create table #ExcludedColumns (
	column_name SYSNAME
);

insert into #ExcludedColumns
	(
		column_name
	)
	values
		('party_id'),
		('case_id'),
		('party_id_location'),
		('modified_timestamp');

-------------------------------------------------------------------------------
-- 2. Build the Dynamic SQL for Pivoting the EAV Table
-------------------------------------------------------------------------------

-- 2a. Build the list of columns to unpivot into (Attribute, Value) pairs
select
	@UnpivotValueList = STRING_AGG(
	CAST('(''' + column_name + ''', CONVERT(VARCHAR(MAX), ' + QUOTENAME(column_name) + '))' as NVARCHAR(MAX)),
	', '
	)
from [VanceLawFirm_Needles].INFORMATION_SCHEMA.COLUMNS
where
	table_schema = @SchemaName
	and
	table_name = @TableName
	and
	column_name not in (select column_name from #ExcludedColumns);


-- 2b. Build the final SQL statement to pivot the data into a temporary table
set @SQL = '
SELECT 
    t.party_id, 
    t.case_id, 
    v.Attribute, 
    v.Value
INTO ##Pivoted_Data
FROM ' + QUOTENAME(@DatabaseName) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' AS t
CROSS APPLY (VALUES ' + @UnpivotValueList + ') AS v(Attribute, Value)
WHERE isnull(v.Value, '''') <> ''''
ORDER BY 
    t.case_id, 
	t.party_id,
    v.Attribute;
';

print @SQL; -- uncomment to debug
exec sp_executesql @SQL;


-------------------------------------------------------------------------------
-- 3. Enrich the Pivoted Data and Create Final Output
-------------------------------------------------------------------------------
if OBJECT_ID('user_party_data_pivoted') is not null
	drop table user_party_data_pivoted;

select distinct
	pv.case_id,
	pv.Attribute,
	pv.Value,
	upm.party_role,
	upn.user_name,
	nuf.field_title,
	nuf.field_num,
	nuf.UDFType,
	nuf.field_type,
	nuf.field_len,
	nuf.table_name,
	nuf.column_name,
	nuf.DropDownValues
into user_party_data_pivoted
from ##Pivoted_Data pv
join [VanceLawFirm_Needles].[dbo].NeedlesUserFields nuf
	on nuf.column_name = pv.Attribute
		and nuf.table_name = 'user_party_data'
join [VanceLawFirm_Needles].[dbo].user_party_matter upm
	on upm.ref_num = nuf.field_num
join [PartyRoleMap] pr
	on pr.[Needles Role] = upm.party_role
left join [VanceLawFirm_Needles].[dbo].user_party_name upn
	on upn.case_id = pv.case_id
		and upn.party_id = pv.party_id
		and upn.ref_num = nuf.field_num
		and upn.user_name <> 0
go

-------------------------------------------------------------------------------
-- 4. Clean Up
-------------------------------------------------------------------------------

-- Drop temp tables
if OBJECT_ID('tempdb..##Pivoted_Data') is not null
	drop table ##Pivoted_Data;

if OBJECT_ID('tempdb..#ExcludedColumns') is not null
	drop table #ExcludedColumns;

-- Final output
select * from dbo.user_party_data_pivoted; -- verify results


/* ------------------------------------------------------------------------------
2. Create UDF Definitions
------------------------------------------------------------------------------- */
alter table [sma_MST_UDFDefinition] disable trigger all
go

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
		'C'											as [udfsUDFCtg],
		cas.casnOrgCaseTypeID						as [udfnRelatedPK],
		pe.field_title								as [udfsUDFName],
		'Defendant'									as [udfsScreenName],
		pe.UDFType									as [udfsType],
		pe.field_len								as [udfsLength],
		1											as [udfbIsActive],
		pe.table_name + '.' + pe.column_name		as [udfshortName],
		pe.DropDownValues							as [udfsNewValues],
		DENSE_RANK() over (order by pe.field_title) as udfnSortOrder
	--select *
	from user_party_data_pivoted pe
	join sma_TRN_Cases cas
		on cas.saga = pe.case_id
	left join [sma_MST_UDFDefinition] def
		on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID
			and def.[udfsUDFName] = pe.field_title
			and def.[udfsScreenName] = 'Defendant'
			and def.[udfsType] = pe.field_type
			and def.udfnUDFID is null
	where
		pe.party_role = 'Defendant'
	order by pe.field_title
go

alter table [sma_MST_UDFDefinition] enable trigger all
go

/* ------------------------------------------------------------------------------
3. Insert UDF Values
------------------------------------------------------------------------------- */
alter table sma_trn_udfvalues disable trigger all
go

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
		def.udfnUDFID	  as [udvnUDFID],
		'Defendant'		  as [udvsScreenName],
		'C'				  as [udvsUDFCtg],
		cas.casnCaseID	  as [udvnRelatedID],
		d.defnDefendentID as [udvnSubRelatedID],
		case
			when pe.field_type = 'name' then CONVERT(VARCHAR(MAX), ioci.UNQCID)
			else pe.Value
		end				  as [udvsUDFValue],
		368				  as [udvnRecUserID],
		GETDATE()		  as [udvdDtCreated],
		null			  as [udvnModifyUserID],
		null			  as [udvdDtModified],
		null			  as [udvnLevelNo]
	--select *
	from user_party_data_pivoted pe
	join sma_TRN_Cases cas
		on cas.saga = pe.case_id
	join sma_TRN_Defendants d
		on d.defnCaseID = cas.casnCaseID
	join IndvOrgContacts_Indexed ioci
		on ioci.SAGA = pe.user_name -- Joins on the populated user_name column in pivoted_data
	left join sma_MST_UDFDefinition def
		on def.udfnRelatedPK = cas.casnOrgCaseTypeID
			and def.udfsUDFName = pe.field_title
			and def.udfsScreenName = 'Defendant'
	where
		pe.party_role = 'Defendant'
go

alter table sma_trn_udfvalues enable trigger all
go