
use SAPerfectPracticeEmroch
GO

/*
alter table SAPerfectPracticeEmroch.[dbo].[sma_TRN_Employment] disable trigger all
delete SAPerfectPracticeEmroch.[dbo].[sma_TRN_Employment]
DBCC CHECKIDENT ('SAPerfectPracticeEmroch.[dbo].[sma_TRN_Employment]', RESEED, 0);
alter table SAPerfectPracticeEmroch.[dbo].[sma_TRN_Employment] enable trigger all
*/


---(0)---
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_Employment'))
begin
    ALTER TABLE [sma_TRN_Employment] ADD [saga] varchar(32) NULL; 
end
GO

---(1)---
insert into [dbo].[sma_TRN_Employment]
(
    empnPlaintiffID,
    empnEmprAddressID,
    empnEmployerID,
    empnEmpUnion,
    empsJobTitle,
    empsCompensationComments,
    empnAverageWeeklyWage,
    empnSalaryAmt,
    empbOnTheJob,
    empbWCClaim,
    empdDateHired,
    empsComments,
    saga
)

select 
    (select plnnPlaintiffID from sma_TRN_Plaintiff where plnnCaseID=CAS.casnCaseID and plnbIsPrimary=1)		
						as empnPlaintiffID,
    IOC.AID				as empnEmprAddressID,
    IOC.CID				as empnEmployerID,
    null				as empnEmpUnion,
    null				as empsJobTitle,
    null				as empsCompensationComments,
    null				as empnAverageWeeklyWage,
    null				as empnSalaryAmt,
    null				as empbOnTheJob,
    null				as empbWCClaim,
    null				as empdDateHired,
    isnull('entityrole:' + nullif(convert(varchar,ER.entityrole),'') + CHAR(13),'') +
    isnull('notes:' + nullif(convert(varchar,ER.notes),'') + CHAR(13),'') +
    ''					as empsComments,
    R.assocnum			as saga
from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS 
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=CAS.saga_entitynum 
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=R.assocrole and CL.codeclass='EPR'
inner join [SAPerfectPracticeEmroch].[dbo].[IndvOrgContacts_Indexed] IOC on IOC.saga=ER.entitynum
where CL.codelabel in ( 'EMPLOYER')