
use SAPerfectPracticeEmroch

/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_PlaintiffAttorney] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_PlaintiffAttorney] 
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_PlaintiffAttorney]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_PlaintiffAttorney] enable trigger all

alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_LawFirms] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_LawFirms] 
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_LawFirms]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_LawFirms] enable trigger all

alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_LawFirmAttorneys] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_LawFirmAttorneys] 
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_LawFirmAttorneys]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_LawFirmAttorneys] enable trigger all
*/


---(0)---
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_PlaintiffAttorney'))
begin
    ALTER TABLE [sma_TRN_PlaintiffAttorney] ADD [saga] int NULL; 
end
GO

---(0)---
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_LawFirms'))
begin
    ALTER TABLE [sma_TRN_LawFirms] ADD [saga] int NULL; 
end
GO

---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_PlaintiffAttorney] disable trigger all
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_LawFirms] disable trigger all
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_LawFirmAttorneys] disable trigger all
GO
---

---(2)--- Defense Attorneys
insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_LawFirms]
(
       [lwfnLawFirmContactID]
      ,[lwfnLawFirmAddressID]
      ,[lwfnAttorneyContactID]
      ,[lwfnAttorneyAddressID]
      ,[lwfnAttorneyTypeID]
      ,[lwfsFileNumber]
      ,[lwfnRoleType]
      ,[lwfnContactID]
      ,[lwfnRecUserID]
      ,[lwfdDtCreated]
      ,[lwfnModifyUserID]
      ,[lwfdDtModified]
      ,[lwfnLevelNo]
      ,[lwfnAdjusterID]
	 ,[lwfsComments]
	 ,[saga]
)
select distinct
    case
	   when IOC.CTG = 2 then IOC.CID
	   else null
    end			    as [lwfnLawFirmContactID],
    case
	   when IOC.CTG = 2 then IOC.AID
	   else null
    end			    as [lwfnLawFirmAddressID],
    case
	   when IOC.CTG = 1 then IOC.CID
	   else null
    end			    as [lwfnAttorneyContactID],
    case
	   when IOC.CTG = 1 then IOC.AID
	   else null
    end			    as [lwfnAttorneyAddressID] ,
    (select atnnAtorneyTypeID FROM sma_MST_AttorneyTypes where atnsAtorneyDscrptn='Defense Attorney')   as [lwfnAttorneyTypeID],
    null			    as [lwfsFileNumber],
    2			    as [lwfnRoleType], -- ?
    (select defnDefendentID from sma_TRN_Defendants where defnCaseID=CAS.casnCaseID and defbIsPrimary=1)   
					as [lwfnContactID],
    368			    as [lwfnRecUserID],
    getdate()		as [lwfdDtCreated],
    null			as [lwfnModifyUserID],
    getdate()		as[lwfdDtModified],
    null			as [lwfnLevelNo],
    null			as [lwfnAdjusterID],
    isnull('entityrole:' + nullif(convert(varchar,ER.entityrole),'') + CHAR(13),'') +
    isnull('notes:' + nullif(convert(varchar,ER.notes),'') + CHAR(13),'') +
    ''			    as [lwfsComments],
    R.assocnum	    as [saga]
from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS 
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=CAS.saga_entitynum 
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=R.assocrole and CL.codeclass='EPR'
inner join [SAPerfectPracticeEmroch].[dbo].[IndvOrgContacts_Indexed] IOC on IOC.saga=ER.entitynum
where CL.codelabel in ( 'ATTY_DEF','ATTY_OTHER')
GO

----(4)---- Defense Attorney list
insert into sma_TRN_LawFirmAttorneys (SourceTableRowID,UniqueContactID,IsDefendant,IsPrimary)
select 
    A.LawFirmID			  as SourceTableRowID,
    A.AttorneyContactID		  as UniqueAontactID,
    1					  as IsDefendant,
    case 
	   when A.SequenceNumber=1 then 1
	   else 0
    end					  as IsPrimary
from
(
select 
    F.lwfnLawFirmID			  as LawFirmID,
    AC.UniqueContactId		  as AttorneyContactID,
    ROW_NUMBER() OVER (Partition BY F.lwfnModifyUserID order by F.lwfnLawFirmID) as SequenceNumber     
from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_LawFirms] F
left join sma_MST_AllContactInfo AC on AC.ContactCtg=1 and AC.ContactId=F.lwfnAttorneyContactID
) A
where A.AttorneyContactID is not null

  

---(Appendix)----
update sma_MST_IndvContacts set cinnContactTypeID=(select octnOrigContactTypeID FROM [SAPerfectPracticeEmroch].[dbo].[sma_MST_OriginalContactTypes] where octsDscrptn='Attorney' and octnContactCtgID=1)
from
  (
	select AC.ContactId as ID
	from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_LawFirms] F
	inner join sma_MST_AllContactInfo AC on AC.ContactCtg=1 and AC.ContactId=F.lwfnAttorneyContactID
  ) A
where cinnContactID=A.ID

---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_PlaintiffAttorney] enable trigger all
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_LawFirms] enable trigger all
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_LawFirmAttorneys] enable trigger all
---
GO
