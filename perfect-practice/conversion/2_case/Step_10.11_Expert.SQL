
use [SAPerfectPracticeEmroch]
GO

/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_ExpertContacts] disable trigger all
delete [SAPerfectPracticeEmroch].[dbo].[sma_TRN_ExpertContacts]
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_ExpertContacts]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_ExpertContacts] enable trigger all
*/



---(0)---
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_ExpertContacts'))
begin
    ALTER TABLE [sma_TRN_ExpertContacts] ADD [saga] varchar(32) NULL; 
end
GO

alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_ExpertContacts] disable trigger all
GO
insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_ExpertContacts]
(
       [ectnCaseID]
      ,[ectnExpContactID]
      ,[ectnExpContactCtgId]
      ,[ectnExpAddressID]
      ,[ectnExpertFor]
      ,[ectnExpertTypeID]
      ,[ectnWillTestifyYN]
      ,[ectsComment]
      ,[ectnRecUserID]
      ,[ectdDtCreated]
      ,[ectnModifyUserID]
      ,[ectdDtModified]
      ,[ectnLevelNo]
	  ,[saga]
)
select 
    CAS.casnCaseID		as [ectnCaseID],
    IOC.CID				as [ectnExpContactID],
    IOC.CTG 			as [ectnExpContactCtgId],
    IOC.AID 			as [ectnExpAddressID],
    2					as [ectnExpertFor], --2:Neutral
    null				as [ectnExpertTypeID],
    null				as [ectnWillTestifyYN],
    isnull('entityrole:' + nullif(convert(varchar,ER.entityrole),'') + CHAR(13),'') +
    isnull('notes:' + nullif(convert(varchar,ER.notes),'') + CHAR(13),'') +
    ''					as [ectsComment],
    368					as [ectnRecUserID],
    getdate()			as [ectdDtCreated],
    null				as [ectnModifyUserID],
    null				as [ectdDtModified],
    null				as [ectnLevelNo],
	R.assocnum			as [saga]
from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS 
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=CAS.saga_entitynum 
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=R.assocrole and CL.codeclass='EPR'
inner join [SAPerfectPracticeEmroch].[dbo].[IndvOrgContacts_Indexed] IOC on IOC.saga=ER.entitynum
where CL.codelabel in ( 'EXPERT')
GO
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_ExpertContacts] enable trigger all
GO




