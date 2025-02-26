
use [SAPerfectPracticeEmroch]
GO

/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Lienors] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Lienors] 
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_Lienors]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Lienors] enable trigger all

alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_LienDetails] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_LienDetails] 
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_LienDetails]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_LienDetails] enable trigger all
*/



---(0)---
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_Lienors'))
begin
    ALTER TABLE [sma_TRN_Lienors] ADD [saga] varchar(32) null; 
end
GO


---(0)---
insert into [dbo].[sma_MST_LienType] ( lntsDscrptn)
select distinct
	ER.entityrole
from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS 
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=CAS.saga_entitynum 
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=R.assocrole and CL.codeclass='EPR'
inner join [SAPerfectPracticeEmroch].[dbo].[IndvOrgContacts_Indexed] IOC on IOC.saga=ER.entitynum
where CL.codelabel in ( 'INS_HEALTH' )
	except
select lntsDscrptn from [dbo].[sma_MST_LienType]
GO



---------------------------------------------------------------------------------------
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Lienors] disable trigger all
GO
---(1)---
insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Lienors]
(
    [lnrnCaseID],
    [lnrnLienorTypeID],
    [lnrnLienorContactCtgID],
    [lnrnLienorContactID],
    [lnrnLienorAddressID],
    [lnrnLienorRelaContactID],
    [lnrnPlaintiffID],
    [lnrnCnfrmdLienAmount],
    [lnrnNegLienAmount],
    [lnrsComments],
    [lnrnRecUserID],
    [lnrdDtCreated],
    [lnrnFinal],
    [saga]
)
  select 
    CAS.casnCaseID			as [lnrnCaseID],
    ( select lntnLienTypeID FROM [dbo].[sma_MST_LienType] where lntsDscrptn=ER.entityrole )
							as [lnrnLienorTypeID],				   
    IOC.CTG					as [lnrnLienorContactCtgID],
    IOC.CID					as [lnrnLienorContactID],
    IOC.AID					as [lnrnLienorAddressID],
    0						as [lnrnLienorRelaContactID],
    (select plnnPlaintiffID from sma_TRN_Plaintiff where plnnCaseID=CAS.casnCaseID and plnbIsPrimary=1)
							as [lnrnPlaintiffID],
    null					as [lnrnCnfrmdLienAmount],
    null					as [lnrnNegLienAmount],
	''						as [lnrsComments],
    368						as [lnrnRecUserID],
    getdate()				as [lnrdDtCreated],
    0						as [lnrnFinal],
    R.assocnum				as [saga]
from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS 
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=CAS.saga_entitynum 
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=R.assocrole and CL.codeclass='EPR'
inner join [SAPerfectPracticeEmroch].[dbo].[IndvOrgContacts_Indexed] IOC on IOC.saga=ER.entitynum
where CL.codelabel in ( 'INS_HEALTH' )

----
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Lienors] enable trigger all
GO





