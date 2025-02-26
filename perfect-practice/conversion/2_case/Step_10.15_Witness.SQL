
use [SAPerfectPracticeEmroch]

/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_CaseWitness] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_CaseWitness] 
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_CaseWitness]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_CaseWitness] enable trigger all
*/


---(0)---
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_CaseWitness'))
begin
    ALTER TABLE [sma_TRN_CaseWitness] ADD [saga] varchar(32) NULL; 
end
GO

---(0)---
insert into sma_MST_WitnessType ( WitnessType )
select distinct
	CL.codelabel
from [PerfectPracticeEmroch].[dbo].[entities] E 
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=E.entitynum and E.casemarker=1
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=R.assocrole and CL.codeclass='EPR'
where CL.codelabel like '%WITNESS%'

	except
select WitnessType from sma_MST_WitnessType
GO

alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_CaseWitness] disable trigger all
---
----(1)----
insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_CaseWitness]
(
	   [witnCaseID]
      ,[witnWitnesContactID]
      ,[witnWitnesAdID]
      ,[witnRoleID]
      ,[witnFavorable]
      ,[witnTestify]
      ,[witdStmtReqDate]
      ,[witdStmtDate]
      ,[witbHasRec]
      ,[witsDoc]
      ,[witsComment]
      ,[witnRecUserID]
      ,[witdDtCreated]
      ,[witnModifyUserID]
      ,[witdDtModified]
      ,[witnLevelNo]
	  ,[saga]
)

select distinct 
	CAS.casnCaseID		as [witnCaseID],
	IOC.UNQCID			as [witnWitnesContactID],
	IOC.AID				as [witnWitnesAdID],
	(select ID from sma_MST_WitnessType where WitnessType = CL.codelabel)  
						as [witnRoleID],
	null				as [witnFavorable],
	null				as [witnTestify],
	null				as [witdStmtReqDate],
	null				as [witdStmtDate],
	null				as [witbHasRec],
	null				as [witsDoc],
    isnull('entityrole:' + nullif(convert(varchar,ER.entityrole),'') + CHAR(13),'') +
    isnull('notes:' + nullif(convert(varchar,ER.notes),'') + CHAR(13),'') +
	''					as [witsComment],
	368					as [witnRecUserID],
	getdate()			as [witdDtCreated],
	null				as [witnModifyUserID],
	null				as [witdDtModified],
	null				as [witnLevelNo],
	R.assocnum			as [saga]
from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS 
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=CAS.saga_entitynum 
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=R.assocrole and CL.codeclass='EPR'
inner join [SAPerfectPracticeEmroch].[dbo].[IndvOrgContacts_Indexed] IOC on IOC.saga=ER.entitynum
where CL.codelabel like '%WITNESS%'
GO

---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_CaseWitness] enable trigger all
---

insert into sma_MST_WitnessType ( WitnessType )
select distinct
	CL.codelabel
from [PerfectPracticeEmroch].[dbo].[entities] E 
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=E.entitynum and E.casemarker=1
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=R.assocrole and CL.codeclass='EPR'
where CL.codelabel like '%WITNESS%'

except
select WitnessType from sma_MST_WitnessType
