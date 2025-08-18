use VanceLawFirm_SA
go

----------------------------
--PIVOT TABLE CONSTRUCTION
----------------------------
/*
select m.*
--distinct m.field_Title, column_name, 'convert(varchar(max), ['+ column_Name + '] ) as ['+ m.field_title +'], ', '['+m.field_title+'],'
FROM [[VanceLawFirm_Needles]].[dbo].[user_case_matter] M 
inner join [[VanceLawFirm_Needles]].[dbo].[user_case_fields] F on F.field_title=M.field_title
where m.field_Type <> 'label'
*/

-- Mediator_Name Mediator_Value_Code


if exists (select * from sys.tables where name = 'CourtUDF' and type = 'U')
begin
	drop table CourtUDF
end
----------------------
--PIVOT TABLE
----------------------

-- user_counsel_data
select
	casncaseid,
	casnorgcasetypeID,
	fieldTitle,
	FieldVal
into CourtUDF
from (
 select
	 cas.casnCaseID,
	 cas.CasnOrgCaseTypeID,
	 CONVERT(VARCHAR(MAX), [Mediator_Name])		  as [Mediator Name],
	 CONVERT(VARCHAR(MAX), [Mediator_Value_Code]) as [Mediator Value Code]
 from [VanceLawFirm_Needles]..user_counsel_data ud
 join [VanceLawFirm_Needles]..cases_Indexed c
	 on c.casenum = ud.casenum
 join sma_TRN_Cases cas
	 on cas.cassCaseNumber = CONVERT(VARCHAR, ud.casenum)
--WHERE c.matcode in ('MVA', 'PRE')
) pv
unpivot (FieldVal for FieldTitle in ([Mediator Name], [Mediator Value Code])
) as unpvt


-- user_tab_data
insert into CourtUDF
	(
		casncaseid,
		casnorgcasetypeID,
		fieldTitle,
		FieldVal
	) select
		casncaseid,
		casnorgcasetypeID,
		fieldTitle,
		FieldVal
	from (
	 select
		 cas.casnCaseID,
		 cas.CasnOrgCaseTypeID,
		 CONVERT(VARCHAR(MAX), Type_of_Witness)	   as [Type of Witness],
		 CONVERT(VARCHAR(MAX), Depo_Date)		   as [Depo Date],
		 CONVERT(VARCHAR(MAX), Depo_Time)		   as [Depo Time],
		 CONVERT(VARCHAR(MAX), Court_Reporter)	   as [Court Reporter],
		 CONVERT(VARCHAR(MAX), Type_of_Expert)	   as [Type of Expert],
		 CONVERT(VARCHAR(MAX), Statement_Context)  as [Statement Context],
		 CONVERT(VARCHAR(MAX), Expert_Value_Code)  as [Expert Value Code],
		 CONVERT(VARCHAR(MAX), Current_Medication) as [Current Medication]
	 from [VanceLawFirm_Needles]..user_tab_data ud
	 join [VanceLawFirm_Needles]..cases_Indexed c
		 on c.casenum = ud.case_id
	 join sma_TRN_Cases cas
		 on cas.cassCaseNumber = CONVERT(VARCHAR, ud.case_id)
	--WHERE c.matcode in ('MVA', 'PRE')
	) pv
	unpivot (FieldVal for FieldTitle in ([Type of Witness], [Depo Date], [Depo Time], [Court Reporter], [Type of Expert],
	[Statement Context], [Expert Value Code], [Current Medication])
	) as unpvt

select
	*
from CourtUDF cu


----------------------------
--UDF DEFINITION
----------------------------

-- user_counsel_data
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
		'Court'									   as [udfsScreenName],
		ucf.UDFType								   as [udfsType],
		ucf.field_len							   as [udfsLength],
		1										   as [udfbIsActive],
		'user_counsel_data' + ucf.column_name	   as [udfshortName],
		ucf.dropdownValues						   as [udfsNewValues],
		DENSE_RANK() over (order by M.field_title) as udfnSortOrder
	from [sma_MST_CaseType] CST
	join CaseTypeMixture mix
		on mix.[SmartAdvocate Case Type] = cst.cstsType
	join [VanceLawFirm_Needles].[dbo].user_case_counsel_matter M
		on M.mattercode = mix.matcode
			and M.field_type <> 'label'
	join (select distinct fieldTitle from CourtUDF) vd
		on vd.FieldTitle = m.field_title
	join NeedlesUserFields ucf
		on ucf.field_num = m.ref_num
	left join (
	 select distinct
		 table_Name,
		 column_name
	 from [VanceLawFirm_Needles].[dbo].[document_merge_params]
	 where table_Name = 'user_case_counsel_matter'
	) dmp
		on dmp.column_name = ucf.field_Title
	left join [sma_MST_UDFDefinition] def
		on def.[udfnRelatedPK] = cst.cstnCaseTypeID
			and def.[udfsUDFName] = m.field_title
			and def.[udfsScreenName] = 'Court'
			and udfstype = ucf.UDFType
	where
		m.Field_Title not in ('Location', 'Mediator Name', 'Court Reporter')
		and
		def.udfnUDFID is null
	order by m.field_title


-- user_tab_data
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
		'Court'									   as [udfsScreenName],
		ucf.UDFType								   as [udfsType],
		ucf.field_len							   as [udfsLength],
		1										   as [udfbIsActive],
		'user_tab_data' + ucf.column_name		   as [udfshortName],
		ucf.dropdownValues						   as [udfsNewValues],
		DENSE_RANK() over (order by M.field_title) as udfnSortOrder
	from [sma_MST_CaseType] CST
	join CaseTypeMixture mix
		on mix.[SmartAdvocate Case Type] = cst.cstsType
	join [VanceLawFirm_Needles].[dbo].user_tab_matter M
		on M.mattercode = mix.matcode
			and M.field_type <> 'label'
	join (select distinct fieldTitle from CourtUDF) vd
		on vd.FieldTitle = m.field_title
	join NeedlesUserFields ucf
		on ucf.field_num = m.ref_num
	--left join (
	-- select distinct
	--	 table_Name,
	--	 column_name
	-- from [VanceLawFirm_Needles].[dbo].[document_merge_params]
	-- where table_Name = 'user_case_counsel_matter'
	--) dmp
	--on dmp.column_name = ucf.field_Title
	left join [sma_MST_UDFDefinition] def
		on def.[udfnRelatedPK] = cst.cstnCaseTypeID
			and def.[udfsUDFName] = m.field_title
			and def.[udfsScreenName] = 'Court'
			and udfstype = ucf.UDFType
	where
		m.Field_Title not in ('Location', 'Mediator Name', 'Court Reporter')
		and
		def.udfnUDFID is null
	order by m.field_title

-- Contact UDF for Court Reporter
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
		'R'										   as [udfsUDFCtg],
		CST.cstnCaseTypeID						   as [udfnRelatedPK], -- contact id
		M.field_title							   as [udfsUDFName],
		'Court'									   as [udfsScreenName],
		ucf.UDFType								   as [udfsType],
		ucf.field_len							   as [udfsLength],
		1										   as [udfbIsActive],
		'user_tab_data' + ucf.column_name		   as [udfshortName],
		ucf.dropdownValues						   as [udfsNewValues],
		DENSE_RANK() over (order by M.field_title) as udfnSortOrder
	from [sma_MST_CaseType] CST
	join CaseTypeMixture mix
		on mix.[SmartAdvocate Case Type] = cst.cstsType
	join [VanceLawFirm_Needles].[dbo].user_tab_matter M
		on M.mattercode = mix.matcode
			and M.field_type <> 'label'
	join (select distinct fieldTitle from CourtUDF) vd
		on vd.FieldTitle = m.field_title
	join NeedlesUserFields ucf
		on ucf.field_num = m.ref_num
	--left join (
	-- select distinct
	--	 table_Name,
	--	 column_name
	-- from [VanceLawFirm_Needles].[dbo].[document_merge_params]
	-- where table_Name = 'user_case_counsel_matter'
	--) dmp
	--on dmp.column_name = ucf.field_Title
	left join [sma_MST_UDFDefinition] def
		on def.[udfnRelatedPK] = cst.cstnCaseTypeID
			and def.[udfsUDFName] = m.field_title
			and def.[udfsScreenName] = 'Court'
			and udfstype = ucf.UDFType
	where
		m.Field_Title in ('Court Reporter')
		and
		def.udfnUDFID is null
	order by m.field_title


--------------------------------------
--UDF VALUES
--------------------------------------
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
	) select --fieldtitle, udf.casnOrgCaseTypeID,
		def.udfnUDFID as [udvnUDFID],
		'Court'		  as [udvsScreenName],
		'C'			  as [udvsUDFCtg],
		casnCaseID	  as [udvnRelatedID],
		0			  as [udvnSubRelatedID],
		udf.FieldVal  as [udvsUDFValue],
		368			  as [udvnRecUserID],
		GETDATE()	  as [udvdDtCreated],
		null		  as [udvnModifyUserID],
		null		  as [udvdDtModified],
		null		  as [udvnLevelNo]
	--select *
	from CourtUDF udf
	left join sma_MST_UDFDefinition def
		on def.udfnRelatedPK = udf.casnOrgCaseTypeID
			and def.udfsUDFName = FieldTitle
			and def.udfsScreenName = 'Court'

alter table sma_trn_udfvalues enable trigger all
go
