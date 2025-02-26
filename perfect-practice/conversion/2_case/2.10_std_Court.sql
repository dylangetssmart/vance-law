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

use SA
GO
---
ALTER TABLE [sma_trn_caseJudgeorClerk] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_CourtDocket] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Courts] DISABLE TRIGGER ALL
GO
---

---(1)---
insert into [sma_TRN_Courts] (
	crtnCaseID
	,crtnCourtID
	,crtnCourtAddId
	,crtnIsActive
	,crtnLevelNo
	)
select A.casnCaseID as crtnCaseID
	,A.CID as crtnCourtID
	,A.AID as crtnCourtAddId
	,1 as crtnIsActive
	,A.judge_link as crtnLevelNo -- remembering judge_link
from (
	select CAS.casnCaseID
		,IOC.CID
		,IOC.AID
		,C.judge_link
	from [TestNeedles].[dbo].[cases] C
	join [sma_TRN_cases] CAS
		on CAS.cassCaseNumber = C.casenum
	join IndvOrgContacts_Indexed IOC
		on IOC.SAGA = C.court_link
	where isnull(court_link, 0) <> 0
	
	union
	
	select CAS.casnCaseID
		,IOC.CID
		,IOC.AID
		,C.judge_link
	from [TestNeedles].[dbo].[cases] C
	join [sma_TRN_cases] CAS
		on CAS.cassCaseNumber = C.casenum
	join IndvOrgContacts_Indexed IOC
		on IOC.SAGA = - 1
			and IOC.[Name] = 'Unidentified Court'
	where isnull(court_link, 0) = 0
		and (
			isnull(judge_link, 0) <> 0
			or docket <> ''
			)
	) A
go

---(2)---
INSERT INTO [sma_TRN_CourtDocket] 
( 
	crdnCourtsID,
	crdnIndexTypeID,
	crdnDocketNo,
	crdnPrice,
	crdbActiveInActive,
	crdsEfile,
	crdsComments
) 
SELECT 
    crtnPKCourtsID	    as crdnCourtsID,
    (
		select idtnIndexTypeID
		from sma_MST_IndexType 
		where idtsDscrptn='Index Number'
	)					as crdnIndexTypeID,
    case
		when isnull(C.docket,'')<>''
			then left(C.docket,30)   
		else 'Case-' + CAS.cassCaseNumber
		end				as crdnDocketNo, 
	0  					as crdnPrice,
	1					as crdbActiveInActive,
	0					as crdsEfile,
    'Docket Number:' + left(C.docket,30) 
						as crdsComments
FROM [sma_TRN_Courts] CRT
	JOIN [sma_TRN_cases] CAS
		on CAS.casnCaseID=CRT.crtnCaseID 
	JOIN [TestNeedles].[dbo].[cases] C
		on C.casenum=CAS.cassCaseNumber
GO

---(3)---
INSERT INTO [sma_trn_caseJudgeorClerk] 
( 
	crtDocketID,
	crtJudgeorClerkContactID,
	crtJudgeorClerkContactCtgID,
	crtJudgeorClerkRoleID
) 
SELECT DISTINCT
	CRD.crdnCourtDocketID	as crtDocketID,
	IOC.CID				as crtJudgeorClerkContactID,
	IOC.CTG				as crtJudgeorClerkContactCtgID,
	(
		select octnOrigContactTypeID
		from sma_MST_OriginalContactTypes
		where octsDscrptn='Judge'
	) as crtJudgeorClerkRoleID 
FROM [sma_TRN_CourtDocket] CRD
JOIN [sma_TRN_Courts] CRT
	on CRT.crtnPKCourtsID=CRD.crdnCourtsID  
JOIN IndvOrgContacts_Indexed IOC
	on IOC.SAGA = CRT.crtnLevelNo  -- ( crtnLevelNo --> C.judge_link )
WHERE isnull(crtnLevelNo,0)<> 0


