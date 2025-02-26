
use [SAPerfectPracticeEmroch]
GO

/*
exec [SAPerfectPracticeEmroch].[dbo].[sma_SP_Insert_OtherCaseRelatedContacts]
select * from [SAPerfectPracticeEmroch].[dbo].[sma_VU_AllCaseContact] V 
select distinct Label from [AmicusRutberg].[dbo].[Role2Lexicon] 

alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_CaseContactComment] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_CaseContactComment] 
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_CaseContactComment]', RESEED, 1);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_CaseContactComment] enable trigger all

alter table [SAPerfectPracticeEmroch].[dbo].[sma_MST_OtherCasesContact] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_MST_OtherCasesContact] 
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_MST_OtherCasesContact]', RESEED, 1);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_MST_OtherCasesContact] enable trigger all
*/

---(2/2)---
insert into sma_MST_OtherCasesContact (OtherCasesID,OtherCasesContactID,OtherCasesContactCtgID,OtherCaseContactAddressID,OtherCasesContactRole,OtherCasesCreatedUserID,OtherCasesContactCreatedDt)   
select A.CaseID,A.ContactID,A.ContactCtgID,A.ContactAddressID,A.ContactRoleID,A.ContactCreatedUserID,getdate()
from
(
select 
	CAS.casnCaseId	    as CaseID,
	IOC.CID				as ContactID,
	IOC.CTG				as ContactCtgID,
	IOC.AID				as ContactAddressID,
	CL.codelabel		as ContactRoleID,
	368					as ContactCreatedUserID,
	null			    as ContactComment
from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS 
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=CAS.saga_entitynum 
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=R.assocrole and CL.codeclass='EPR'
inner join [SAPerfectPracticeEmroch].[dbo].[IndvOrgContacts_Indexed] IOC on IOC.saga=ER.entitynum
where CL.codelabel in 
(
	select codelabel
		from
		(
			select codelabel 
			from [PerfectPracticeEmroch].[dbo].[entities] E
			inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=E.entitynum 
			inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=R.assocrole and CL.codeclass='EPR'
			where E.casemarker=1
		) A
	group by A.codelabel
	having count(A.codelabel) < 1000
	)
) A 

	   