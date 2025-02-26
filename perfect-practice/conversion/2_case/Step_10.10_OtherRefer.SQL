
use SAPerfectPracticeEmroch

/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_OtherReferral] disable trigger all
delete [SAPerfectPracticeEmroch].[dbo].[sma_TRN_OtherReferral]
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_OtherReferral]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_OtherReferral] enable trigger all
*/

--(1)--

insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_OtherReferral]
(
       [otrnCaseID]
      ,[otrnRefContactCtg]
      ,[otrnRefContactID]
      ,[otrnRefAddressID]
      ,[otrnPlaintiffID]
      ,[otrsComments]
      ,[otrnUserID]
      ,[otrdDtCreated]
)
select
    CAS.casnCaseID	    as [otrnCaseID],
    IOC.CTG				as [otrnRefContactCtg],
    IOC.CID				as [otrnRefContactID],
    IOC.AID				as [otrnRefAddressID],
    -1					as [otrnPlaintiffID],
    'PP REFERRING_SOURCE' as [otrsComments],
    368					as [otrnUserID], 
    getdate()		    as [otrdDtCreated] 
from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS 
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.entitynum=CAS.saga_entitynum
inner join [PerfectPracticeEmroch].[dbo].[Party7idtext_Mapping] M on M.[My PP Referring Source]=E.party7idtext
inner join [SAPerfectPracticeEmroch].[dbo].[IndvOrgContacts_Indexed] IOC on IOC.saga=-7 and IOC.CTG=2 and IOC.[Name]=M.[SA Referring Source]


--(2)--
insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_OtherReferral]
(
       [otrnCaseID]
      ,[otrnRefContactCtg]
      ,[otrnRefContactID]
      ,[otrnRefAddressID]
      ,[otrnPlaintiffID]
      ,[otrsComments]
      ,[otrnUserID]
      ,[otrdDtCreated]
)
select
    CAS.casnCaseID	    as [otrnCaseID],
    IOC.CTG				as [otrnRefContactCtg],
    IOC.CID				as [otrnRefContactID],
    IOC.AID				as [otrnRefAddressID],
    -1					as [otrnPlaintiffID],
    'Relationships ' + CL.codelabel as [otrsComments],
    368					as [otrnUserID], 
    getdate()		    as [otrdDtCreated] 
from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS 
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=CAS.saga_entitynum 
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=R.assocrole and CL.codeclass='EPR'
inner join [SAPerfectPracticeEmroch].[dbo].[IndvOrgContacts_Indexed] IOC on IOC.saga=ER.entitynum
where CL.codelabel in ( 'REFERRING_SOURCE', 'ATTY_LIEN' )
