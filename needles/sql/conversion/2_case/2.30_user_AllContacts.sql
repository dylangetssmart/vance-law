/* ###################################################################################
description: Inserts records to Other > All Contacts
steps:
	- Insert [sma_MST_OtherCasesContact] from user_case_data
	- Insert [sma_MST_OtherCasesContact] from user_party_data.relative
	- Insert [sma_MST_OtherCasesContact] from user_party_data.relative_name
usage_instructions:
	- 
dependencies:
	- 
notes:
	-
todo
	- 
*/


use JoelBieberSA_Needles
go

alter table [sma_MST_OtherCasesContact] disable trigger all
go

-------------------------------------------------------------------
-- from user_case_data
-------------------------------------------------------------------

insert into [sma_MST_OtherCasesContact]
	(
	[OtherCasesID],
	[OtherCasesContactID],
	[OtherCasesContactCtgID],
	[OtherCaseContactAddressID],
	[OtherCasesContactRole],
	[OtherCasesCreatedUserID],
	[OtherCasesContactCreatedDt],
	[OtherCasesModifyUserID],
	[OtherCasesContactModifieddt]
	)
	select
		cas.casnCaseID as [othercasesid],
		ioc.CID		   as [othercasescontactid],
		ioc.CTG		   as [othercasescontactctgid],
		ioc.AID		   as [othercasecontactaddressid],
		'Relative'	   as [othercasescontactrole],
		368			   as [othercasescreateduserid],
		GETDATE()	   as [othercasescontactcreateddt],
		null		   as [othercasesmodifyuserid],
		null		   as [othercasescontactmodifieddt]
	--SELECT *
	from [JoelBieberNeedles].[dbo].user_case_data ucd
	join sma_TRN_Cases cas
		on CONVERT(VARCHAR, ucd.casenum) = cas.saga
	join [sma_MST_IndvContacts] indv
		on indv.source_id = ucd.Relative_Name
			and indv.source_ref = 'user_case_data.relative_name'
	join IndvOrgContacts_Indexed ioc
		on ioc.CID = indv.cinnContactID
	where ISNULL(ucd.Relative_Name, '') <> ''
go

-------------------------------------------------------------------
-- from user_party_data
-------------------------------------------------------------------

-- 'Relative_Name'
insert into [sma_MST_OtherCasesContact]
	(
	[OtherCasesID],
	[OtherCasesContactID],
	[OtherCasesContactCtgID],
	[OtherCaseContactAddressID],
	[OtherCasesContactRole],
	[OtherCasesCreatedUserID],
	[OtherCasesContactCreatedDt],
	[OtherCasesModifyUserID],
	[OtherCasesContactModifieddt]
	)
	select
		cas.casnCaseID as [othercasesid],
		ioc.CID		   as [othercasescontactid],
		ioc.CTG		   as [othercasescontactctgid],
		ioc.AID		   as [othercasecontactaddressid],
		'Relative'	   as [othercasescontactrole],
		368			   as [othercasescreateduserid],
		GETDATE()	   as [othercasescontactcreateddt],
		null		   as [othercasesmodifyuserid],
		null		   as [othercasescontactmodifieddt]
	--SELECT *
	from [JoelBieberNeedles].[dbo].user_party_data upd
	join sma_TRN_Cases cas
		on upd.case_id = cas.saga
	join [sma_MST_IndvContacts] indv
		on indv.source_id = upd.Relative_Name
			and indv.source_ref = 'conversion.user_party_relative'
	join IndvOrgContacts_Indexed ioc
		on ioc.CID = indv.cinnContactID
	where ISNULL(upd.Relative_Name, '') <> ''
go


-- 'Relative'
insert into [sma_MST_OtherCasesContact]
	(
	[OtherCasesID],
	[OtherCasesContactID],
	[OtherCasesContactCtgID],
	[OtherCaseContactAddressID],
	[OtherCasesContactRole],
	[OtherCasesCreatedUserID],
	[OtherCasesContactCreatedDt],
	[OtherCasesModifyUserID],
	[OtherCasesContactModifieddt]
	)
	select
		cas.casnCaseID as [othercasesid],
		ioc.CID		   as [othercasescontactid],
		ioc.CTG		   as [othercasescontactctgid],
		ioc.AID		   as [othercasecontactaddressid],
		'Relative'	   as [othercasescontactrole],
		368			   as [othercasescreateduserid],
		GETDATE()	   as [othercasescontactcreateddt],
		null		   as [othercasesmodifyuserid],
		null		   as [othercasescontactmodifieddt]
	--SELECT *
	from [JoelBieberNeedles].[dbo].user_party_data upd
	join sma_TRN_Cases cas
		on upd.case_id = cas.saga
	join [sma_MST_IndvContacts] indv
		on indv.source_id = upd.relative
			and indv.source_ref = 'conversion.user_party_relative'
	join IndvOrgContacts_Indexed ioc
		on ioc.CID = indv.cinnContactID
	where ISNULL(upd.relative, '') <> ''
go

---
alter table [sma_MST_OtherCasesContact] enable trigger all
go

/* ####################################
2.0 -- Add comment
*/
                
-- INSERT INTO [sma_TRN_CaseContactComment]
-- (
-- 	[CaseContactCaseID]
-- 	,[CaseRelContactID]
-- 	,[CaseRelContactCtgID]
-- 	,[CaseContactComment]
-- 	,[CaseContactCreaatedBy]
-- 	,[CaseContactCreateddt]
-- 	,[caseContactModifyBy]
-- 	,[CaseContactModifiedDt]
-- )
-- SELECT
-- 	cas.casnCaseID	as [CaseContactCaseID]
-- 	,ioc.CID		as [CaseRelContactID]
-- 	,ioc.CTG		as [CaseRelContactCtgID]
-- 	,isnull(('Spouse: '+ nullif(convert(varchar(max),ud.spouse),'')+char(13)),'') +
-- 	isnull(('Alternate Contact: '+ nullif(convert(varchar(max),ud.Alternate_Contact),'')+char(13)),'') +
-- 	isnull(('Contact Relationship: '+ nullif(convert(varchar(max),ud.Contact_Relationship),'')+char(13)),'') +
-- 	''				as [CaseContactComment]
-- 	,368			as [CaseContactCreaatedBy]
-- 	,getdate()		as [CaseContactCreateddt]
-- 	,null			as [caseContactModifyBy]
-- 	,null			as [CaseContactModifiedDt]
-- FROM NeedlesSLF.[dbo].user_party_data ud
-- join sma_TRN_Cases cas
-- 	on cas.cassCaseNumber = ud.case_id
-- join NeedlesSLF..names n
-- 	on n.names_id = ud.party_id
-- join IndvOrgContacts_Indexed ioc
-- 	on ioc.SAGA = n.names_id
-- where isnull(ud.Spouse,'') <> '' or isnull(ud.Alternate_Contact,'') <> '' or isnull(ud.Contact_Relationship,'') <> ''