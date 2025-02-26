
use [SAPerfectPracticeEmroch]

/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_PoliceReports] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_PoliceReports]
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_PoliceReports]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_PoliceReports] enable trigger all
*/


---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_PoliceReports] disable trigger all
---
GO

---(0)---
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_PoliceReports'))
begin
    ALTER TABLE [sma_TRN_PoliceReports] ADD [saga] varchar(32) NULL; 
end
GO



---(2)---
insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_PoliceReports]
(
       [pornCaseID]
      ,[pornPoliceID]
      ,[pornPoliceAdID]
      ,[porsReportNo]
      ,[porsComments]
      ,[pornPOContactID]
      ,[pornPOCtgID]
      ,[pornPOAddressID]
	 ,[saga]
)

select 
    CAS.casnCaseID			as pornCaseID,
	case when IOC.CTG=2 then IOC.CID else null end as pornPoliceID,
	case when IOC.CTG=2 then IOC.AID else null end as pornPoliceAdID,
    null					as porsReportNo,
    isnull('entityrole:' + nullif(convert(varchar,ER.entityrole),'') + CHAR(13),'') +
    isnull('notes:' + nullif(convert(varchar,ER.notes),'') + CHAR(13),'') +
	''						as porsComments,
	case when IOC.CTG=1 then IOC.CID else null end as [pornPOContactID],
	case when IOC.CTG=1 then IOC.CTG else null end as [pornPOCtgID],
	case when IOC.CTG=1 then IOC.AID else null end as [pornPOAddressID],
    R.assocnum				as [saga]
from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS 
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=CAS.saga_entitynum 
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=R.assocrole and CL.codeclass='EPR'
inner join [SAPerfectPracticeEmroch].[dbo].[IndvOrgContacts_Indexed] IOC on IOC.saga=ER.entitynum
where CL.codelabel in ( 'POLICE_DEPART','OFFICER','TROOPER')
--and CAS.cassCaseNumber='10752721523'


---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_PoliceReports] enable trigger all
---

--(Appendix)--
update sma_MST_IndvContacts set cinnContactTypeID=(select octnOrigContactTypeID from [dbo].[sma_MST_OriginalContactTypes] where octsDscrptn='Police Officer' and octnContactCtgID=1)
where cinnContactID in 
(
select pornPoliceID 
from sma_TRN_PoliceReports PR
inner join sma_MST_Address A on A.addnContactID=PR.pornPoliceID and A.addnContactCtgID=1
)

update sma_MST_OrgContacts set connContactTypeID=(select octnOrigContactTypeID FROM [dbo].[sma_MST_OriginalContactTypes] where octsDscrptn='Police' and octnContactCtgID=2)
where connContactID in 
(
select pornPOContactID
from sma_TRN_PoliceReports PR
inner join sma_MST_Address A on A.addnContactID=PR.pornPOContactID and A.addnContactCtgID=2
where pornPOCtgID=2
)

