
use SAPerfectPracticeEmroch
GO

------
alter table sma_MST_OrgContacts disable trigger all
alter table sma_MST_IndvContacts disable trigger all
GO
-----

----(0)----

update [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts] set cinnContactTypeID=(select octnOrigContactTypeID FROM [SAPerfectPracticeEmroch].[dbo].[sma_MST_OriginalContactTypes] where octsDscrptn='Adjuster' and octnContactCtgID=1)
where cinnContactID in
(
select distinct incnAdjContactId 
from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_InsuranceCoverage] INS
where incnAdjContactId is not null
) 

GO

update [SAPerfectPracticeEmroch].[dbo].[sma_MST_OrgContacts] set connContactTypeID=(select octnOrigContactTypeID FROM [SAPerfectPracticeEmroch].[dbo].[sma_MST_OriginalContactTypes] where octsDscrptn='Insurance Company' and octnContactCtgID=2)
where connContactID in
(
select distinct incnInsContactID
from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_InsuranceCoverage] INS
where incnInsContactID is not null
)
GO


----(1)----

update [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts] set cinnContactTypeID=(select octnOrigContactTypeID FROM [SAPerfectPracticeEmroch].[dbo].[sma_MST_OriginalContactTypes] where octsDscrptn='Doctor' and octnContactCtgID=1)
where cinnContactID in
(
select distinct hosnContactID 
from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Hospitals] HOS
where hosnContactID is not null
and hosnContactCtg=1
) 
GO

update [SAPerfectPracticeEmroch].[dbo].[sma_MST_OrgContacts] set connContactTypeID=(select octnOrigContactTypeID FROM [SAPerfectPracticeEmroch].[dbo].[sma_MST_OriginalContactTypes] where octsDscrptn='Medical Office' and octnContactCtgID=2)
where connContactID in
(
select distinct hosnContactID 
from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Hospitals] HOS
where hosnContactID is not null
and hosnContactCtg=2
)
GO



----(2)----

update [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts] set cinnContactTypeID=(select octnOrigContactTypeID FROM [SAPerfectPracticeEmroch].[dbo].[sma_MST_OriginalContactTypes] where octsDscrptn='Attorney' and octnContactCtgID=1)
where cinnContactID in
(
select distinct planAtorneyContactID from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_PlaintiffAttorney]
where planAtorneyContactID is not null
) 

update [SAPerfectPracticeEmroch].[dbo].[sma_MST_OrgContacts] set connContactTypeID=(select octnOrigContactTypeID FROM [SAPerfectPracticeEmroch].[dbo].[sma_MST_OriginalContactTypes] where octsDscrptn='Law Firm' and octnContactCtgID=2)
where connContactID in
(
select distinct planLawfrmContactID from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_PlaintiffAttorney]
where planLawfrmContactID is not null
)


----(3)----

update [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts] set cinnContactTypeID=(select octnOrigContactTypeID FROM [SAPerfectPracticeEmroch].[dbo].[sma_MST_OriginalContactTypes] where octsDscrptn='Attorney' and octnContactCtgID=1)
where cinnContactID in
(
select distinct lwfnAttorneyContactID from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_LawFirms]
where lwfnAttorneyContactID is not null
)

update [SAPerfectPracticeEmroch].[dbo].[sma_MST_OrgContacts] set connContactTypeID=(select octnOrigContactTypeID FROM [SAPerfectPracticeEmroch].[dbo].[sma_MST_OriginalContactTypes] where octsDscrptn='Law Firm' and octnContactCtgID=2)
where connContactID in
(
select distinct lwfnLawFirmContactID from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_LawFirms]
where lwfnLawFirmContactID is not null
)


----(4)----
update [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts] set cinnContactTypeID=(select octnOrigContactTypeID from [SAPerfectPracticeEmroch].[dbo].[sma_MST_OriginalContactTypes] where octsDscrptn='Judge')
where cinnContactID in
(
select 
crtJudgeorClerkContactID as ID
from [SAPerfectPracticeEmroch].[dbo].[sma_trn_caseJudgeorClerk]
where crtJudgeorClerkContactCtgID = 1
) 


----(5)----
update [dbo].[sma_MST_OrgContacts] set connContactTypeID=(select octnOrigContactTypeID FROM [dbo].[sma_MST_OriginalContactTypes] where octsDscrptn='Court' and octnContactCtgID=2)
where connContactID in
(
select distinct crtnCourtID from [dbo].[sma_TRN_Courts] where crtnCourtID is not null
)

------
alter table sma_MST_OrgContacts enable trigger all
alter table sma_MST_IndvContacts enable trigger all
GO

