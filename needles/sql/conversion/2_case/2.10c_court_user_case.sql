/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create users and contacts

replace:
'OfficeName'
'StateDescription'
'VenderCaseType'
##########################################################################################################################
*/

use [JoelBieberSA_Needles]
go


---
alter table [sma_trn_caseJudgeorClerk] disable trigger all
go

alter table [sma_TRN_CourtDocket] disable trigger all
go

alter table [sma_TRN_Courts] disable trigger all
go



/* -------------------------------------------------------------------------------------------------
Insert Courts from user_case_data.COURT

COURT is a `name` field, so a contact exists

*/

insert into [sma_TRN_Courts]
	(
	crtnCaseID,
	crtnCourtID,
	crtnCourtAddId,
	crtnIsActive,
	crtnLevelNo,
	source_id,
	source_db,
	source_ref
	)
	select
		cas.casnCaseID		   as crtncaseid,
		ioci.CID			   as crtncourtid,
		ioci.AID			   as crtncourtaddid,
		1					   as crtnisactive,
		null				   as crtnlevelno,
		null				   as source_id,
		null				   as source_db,
		'user_case_data.COURT' as source_ref
	--select *
	from JoelBieberNeedles..user_case_data ucd
	join sma_TRN_Cases cas
		on CONVERT(VARCHAR, casenum) = cas.cassCaseNumber
	join JoelBieberNeedles..user_case_name ucn
		on ucn.casenum = ucd.casenum
			and ucn.ref_num = (
				select top 1
					m.ref_num
				from JoelBieberNeedles.[dbo].[user_case_matter] m
				where m.field_title = 'Court'
			)
			and ucn.user_name <> 0
	join JoelBieberNeedles..names n
		on n.names_id = ucn.user_name
	join IndvOrgContacts_Indexed ioci
		on ioci.SAGA = n.names_id
	-- only insert new courts
	where ISNULL(ucd.COURT, '') <> ''
		and not exists (
			select
				1
			from [sma_TRN_Courts] existing
			where existing.crtncaseid = cas.casnCaseID
				and existing.crtncourtid = ioci.CID
		);
go

--select * from sma_TRN_Courts stc where stc.crtnCaseID = 18430

/*  -------------------------------------------------------------------------------------------------
Insert Clerks from user_case_data.CLERK

1. create unidentified court records for clerks without a court
2. create blank dockets for all clerks
3. insert clerks

*/

--SELECT casenum, clerk, court
--FROM JoelBieberNeedles..user_case_data ucd 
--where ISNULL(ucd.CLERK, '') <> ''
--	and ISNULL(ucd.COURT,'') = ''

-------------------------------------------------------------------
-- 1. For clerks that DO NOT have an associated court record (user_case_data.COURT), create courts using unidentified court
-------------------------------------------------------------------
insert into [sma_TRN_Courts]
	(
	crtnCaseID,
	crtnCourtID,
	crtnCourtAddId,
	crtnIsActive,
	crtnLevelNo,
	source_id,
	source_db,
	source_ref
	)
	select
		cas.casnCaseID		 as crtncaseid,
		ioci.CID			 as crtncourtid,
		ioci.AID			 as crtncourtaddid,
		1					 as crtnisactive,
		null				 as crtnlevelno,
		null				 as source_id,
		null				 as source_db,
		'Unidentified Court' as source_ref
	--select *
	from JoelBieberNeedles..user_case_data ucd
	join sma_TRN_Cases cas
		on CONVERT(VARCHAR, casenum) = cas.cassCaseNumber
	join IndvOrgContacts_Indexed ioci
		on ioci.[Name] = 'Unidentified Court'
	where ISNULL(ucd.CLERK, '') <> ''
		and ISNULL(ucd.COURT, '') = ''
go

-------------------------------------------------------------------
-- 2. Create blank docket records for Clerks
-------------------------------------------------------------------

-- 2.1 - insert blank docket for Clerks with no associated user_case_data.Court using Unidentified Court
insert into [sma_TRN_CourtDocket]
	(
	crdnCourtsID,
	crdnIndexTypeID,
	crdnDocketNo,
	crdnPrice,
	crdbActiveInActive,
	crdsEfile,
	crdsComments,
	source_id,
	source_db,
	source_ref
	)
	select
		court.crtnPKCourtsID		   as crdncourtsid,
		(
			select
				idtnIndexTypeID
			from sma_MST_IndexType
			where idtsDscrptn = 'Index Number'
		)			   as crdnindextypeid,
		'blank'		   as crdndocketno,
		0			   as crdnprice,
		1			   as crdbactiveinactive,
		0			   as crdsefile,
		'blank docket' as crdscomments,
		null		   as source_id,
		null		   as source_db,
		'blank'		   as source_ref
	from joelbieberNeedles..user_case_data ucd
	join sma_TRN_Cases cas
		on CONVERT(VARCHAR, ucd.casenum) = cas.cassCaseNumber
	join [sma_TRN_Courts] court
		on court.crtnCaseID = cas.casnCaseID
			and court.source_ref = 'Unidentified Court'
	where ISNULL(ucd.CLERK, '') <> ''
		and ISNULL(ucd.court, '') = ''
go

-- 2.2 - insert blank docket for Clerks with associated user_case_data.Court
-- join to court using source_ref
insert into [sma_TRN_CourtDocket]
	(
	crdnCourtsID,
	crdnIndexTypeID,
	crdnDocketNo,
	crdnPrice,
	crdbActiveInActive,
	crdsEfile,
	crdsComments,
	source_id,
	source_db,
	source_ref
	)
	select
		court.crtnPKCourtsID as crdncourtsid,
		(
			select
				idtnIndexTypeID
			from sma_MST_IndexType
			where idtsDscrptn = 'Index Number'
		)					 as crdnindextypeid,
		'blank'				 as crdndocketno,
		0					 as crdnprice,
		1					 as crdbactiveinactive,
		0					 as crdsefile,
		'blank docket'		 as crdscomments,
		null				 as source_id,
		null				 as source_db,
		'blank'				 as source_ref
	from joelbieberNeedles..user_case_data ucd
	join sma_TRN_Cases cas
		on CONVERT(VARCHAR, ucd.casenum) = cas.cassCaseNumber
	join [sma_TRN_Courts] court
		on court.crtnCaseID = cas.casnCaseID
	--and court.source_ref = 'user_case_data.COURT'
	where ISNULL(ucd.CLERK, '') <> ''
		and ISNULL(ucd.court, '') <> ''
go


--select
--	*
--from sma_TRN_Courts stc
--where stc.crtnCaseID = 18430
--select
--	*
--from [sma_TRN_CourtDocket]
--where crdnCourtsID = 7514
--select
--	*
--from IndvOrgContacts_Indexed ioci
--where ioci.CID = 31455


---------------------------------------------------------------------
---- 3. Insert Clerks using blank dockets
---------------------------------------------------------------------
insert into [sma_trn_caseJudgeorClerk]
	(
	crtDocketID,
	crtJudgeorClerkContactID,
	crtJudgeorClerkContactCtgID,
	crtJudgeorClerkRoleID
	)
	select distinct
		docket.crdnCourtDocketID as crtdocketid,
		ioc.CID					 as crtjudgeorclerkcontactid,
		ioc.CTG					 as crtjudgeorclerkcontactctgid,
		(
			select
				octnOrigContactTypeID
			from sma_MST_OriginalContactTypes
			where octsDscrptn = 'Law Clerk'
		)						 as crtjudgeorclerkroleid

	from [sma_TRN_CourtDocket] docket
	join [sma_TRN_Courts] court
		on court.crtnPKCourtsID = docket.crdnCourtsID
	join sma_TRN_Cases cas
		on cas.casnCaseID = court.crtnCaseId
	join JoelBieberNeedles..user_case_data ucd
		on CONVERT(VARCHAR, ucd.casenum) = cas.cassCaseNumber
	join JoelBieberNeedles..user_case_name ucn
		on ucn.casenum = ucd.casenum
			and ucn.ref_num = (
				select top 1
					m.ref_num
				from JoelBieberNeedles.[dbo].[user_case_matter] m
				where m.field_title = 'Clerk'
			)
			and ucn.user_name <> 0
	join JoelBieberNeedles..names n
		on n.names_id = ucn.user_name
	join IndvOrgContacts_Indexed ioc
		on ioc.SAGA = n.names_id
	where ISNULL(ucd.CLERK, '') <> ''
		and docket.source_ref = 'blank'
		--and cas.casnCaseID = 18430