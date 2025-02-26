
use SAPerfectPracticeEmroch
GO
/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_trn_caseJudgeorClerk] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_trn_caseJudgeorClerk]
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_trn_caseJudgeorClerk]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_trn_caseJudgeorClerk] enable trigger all

alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_CourtDocket] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_CourtDocket]
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_CourtDocket]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_CourtDocket] enable trigger all

alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Courts] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Courts]
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_Courts]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Courts] enable trigger all
*/

---(0)---
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_Courts'))
begin
    ALTER TABLE [sma_TRN_Courts] ADD [saga] varchar(32) NULL; 
end
GO

---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_trn_caseJudgeorClerk] disable trigger all
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_CourtDocket] disable trigger all
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Courts] disable trigger all
GO
---

---(1)---
insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Courts] 
( 
	crtnCaseID,
	crtnCourtID,
	crtnCourtAddId,
	crtsComment,
	crtnIsActive,
	crtnLevelNo,
	saga
)
select 
	CAS.casnCaseID	    as crtnCaseID, 
	IOC.CID				as crtnCourtID, 
	IOC.AID				as crtnCourtAddId,
	''					as crtsComment,
	1					as crtnIsActive,
	null				as crtnLevelNo, -- remembering judge_link
	R.assocnum			as saga
--select IOC.Name --12263
from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS 
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.entitynum=CAS.saga_entitynum
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=E.entitynum and (select codelabel from [PerfectPracticeEmroch].[dbo].[ucodes_label] where codeclass='EPR' and id=R.assocrole) = 'COURT'
inner join [SAPerfectPracticeEmroch].[dbo].[IndvOrgContacts_Indexed] IOC on IOC.saga=R.assocnum

--select count(*) -- 4092
--from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS 
--inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.entitynum=CAS.saga_entitynum
--inner join [PerfectPracticeEmroch].[dbo].[entities] E_CT on E_CT.entitynum=E.party5num
--inner join [SAPerfectPracticeEmroch].[dbo].[IndvOrgContacts_Indexed] IOC on IOC.saga=E_CT.entitynum

GO

---(2)---
insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_CourtDocket]
( 
	crdnCourtsID,
	crdnIndexTypeID,
	crdnDocketNo,
	crdsComments,
	crdnPrice,
	crdbActiveInActive,
	crdsEfile
)
select 
	CRT.crtnPKCourtsID		as crdnCourtsID,
    (select idtnIndexTypeID from sma_MST_IndexType where idtsDscrptn='Docket Number') 
							as crdnIndexTypeID,  
	left(E.party5pct,30)	as crdnDocketNo,
	''						as crdsComments,
	0						as crdnPrice,
	1						as crdbActiveInActive,
	0						as crdsEfile
from [dbo].[sma_TRN_Courts] CRT 
inner join [dbo].[sma_TRN_Cases] CAS on CAS.casnCaseID=CRT.crtnCaseID 
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.entitynum=CAS.saga_entitynum
where E.party5pct is not null

--(3)---
insert into [SAPerfectPracticeEmroch].[dbo].[sma_trn_caseJudgeorClerk]
( 
	crtDocketID,
	crtJudgeorClerkContactID,
	crtJudgeorClerkContactCtgID,
	crtJudgeorClerkRoleID
) 
select 
	CRD.crdnCourtDocketID	as crtDocketID,
	IOC.CID					as crtJudgeorClerkContactID,
	IOC.CTG					as crtJudgeorClerkContactCtgID,
	(select octnOrigContactTypeID from sma_MST_OriginalContactTypes where octsDscrptn='Judge')			
							as crtJudgeorClerkRoleID
from [dbo].[sma_TRN_Courts] CRT 
left join [SAPerfectPracticeEmroch].[dbo].[sma_TRN_CourtDocket] CRD on CRD.crdnCourtsID=CRT.crtnPKCourtsID
inner join [PerfectPracticeEmroch].[dbo].[entities] RE on RE.entitynum=CRT.saga
inner join [SAPerfectPracticeEmroch].[dbo].[IndvOrgContacts_Indexed] IOC on IOC.saga='Judge'+RE.entitynum	
GO

---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_trn_caseJudgeorClerk] enable trigger all
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_CourtDocket] enable trigger all
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Courts] enable trigger all
---

