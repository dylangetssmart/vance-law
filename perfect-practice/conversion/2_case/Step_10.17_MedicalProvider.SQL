
use [SAPerfectPracticeEmroch]
GO
/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Hospitals] disable trigger all
delete [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Hospitals]
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_Hospitals]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Hospitals] enable trigger all
*/

-----------

alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Hospitals] disable trigger all
GO

---(0)---
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_Hospitals'))
begin
    ALTER TABLE [sma_TRN_Hospitals] ADD [saga] [varchar](32) NULL; 
end
GO


---(1)---
insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Hospitals]
 (	[hosnCaseID], 
	[hosnContactID], 
	[hosnContactCtg],
	[hosnAddressID], 
	[hossMedProType], 
	[hosdStartDt],
	[hosdEndDt],
	[hosnPlaintiffID],
	[hosnComments], 
	[hosnHospitalChart], 
	[hosnRecUserID],
	[hosdDtCreated], 
	[hosnModifyUserID],
	[hosdDtModified],
	[saga]
)

select 
    CAS.casnCaseID		as [hosnCaseID], 
    IOC.CID				as [hosnContactID],
    IOC.CTG				as [hosnContactCtg],
    IOC.AID				as [hosnAddressID], 
    'M'					as [hossMedProType],
    null				as [hosdStartDt],
    null				as [hosdEndDt],
    (select plnnPlaintiffId from sma_TRN_Plaintiff where plnnCaseID=CAS.casnCaseID and plnbIsPrimary=1 )
						as hosnPlaintiffID,
    isnull('entityrole:' + nullif(convert(varchar,ER.entityrole),'') + CHAR(13),'') +
    isnull('notes:' + nullif(convert(varchar,ER.notes),'') + CHAR(13),'') +
	''					as [hosnComments],
    null				as [hosnHospitalChart],
    368					as [hosnRecUserID],
    getdate()			as [hosdDtCreated],
    null				as [hosnModifyUserID],
    null				as [hosdDtModified],
    R.assocnum			as [saga]
--select IOC.Name,IOC.CTG,ER.entityrole,CAS.saga_entitynum
--select ER.*
from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS 
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=CAS.saga_entitynum 
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=R.assocrole and CL.codeclass='EPR'
inner join [SAPerfectPracticeEmroch].[dbo].[IndvOrgContacts_Indexed] IOC on IOC.saga=ER.entitynum
where CL.codelabel in ( 'DOCTOR','HOSPITAL','RADIOLOGIST','AMBULANCE','PHARMACY','PHYSICAL_THERAPY')
--and CAS.cassCaseNumber='10752721523'
GO

-----------
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Hospitals] enable trigger all
-----------





