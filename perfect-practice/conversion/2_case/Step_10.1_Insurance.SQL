
use [SAPerfectPracticeEmroch]
GO
/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_InsuranceCoverage] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_InsuranceCoverage]
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_InsuranceCoverage]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_InsuranceCoverage] disable trigger all


alter table [SAPerfectPracticeEmroch].[dbo].[sma_MST_RelContacts] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_MST_RelContacts]
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_MST_RelContacts]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_MST_RelContacts] disable trigger all

alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_InsuranceCoverageAdjusters] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_InsuranceCoverageAdjusters]
--DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_InsuranceCoverageAdjusters]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_InsuranceCoverageAdjusters] disable trigger all
*/


---(0)---
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_InsuranceCoverage'))
begin
    ALTER TABLE [sma_TRN_InsuranceCoverage] ADD [saga] varchar(32) NULL; 
end

---(0)--- Needles type
insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_InsuranceType] (intsDscrptn ) 
(
select 'ADJUSTOR'
	union
select 'INS_AUTO'
	union
select 'INS_HEALTH'
	union
select 'INS_LIABILITY'
	union
select 'INS_MALPRACTICE'
	union
select 'INS_SUBRO'
	union
select 'INS_WORKCOMP'
	union
select 'INSURANCE'
)
except
select intsDscrptn FROM [SAPerfectPracticeEmroch].[dbo].[sma_MST_InsuranceType]
GO

---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_InsuranceCoverage] disable trigger all
---
GO

---(1)--- Insurance of plaintiffs
insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_InsuranceCoverage] 
(
	[incnCaseID],[incnInsContactID],[incnInsAddressID],[incbCarrierHasLienYN],[incnInsType],[incnAdjContactId],[incnAdjAddressID],[incsPolicyNo],[incsClaimNo],[incnStackedTimes],
	[incsComments],[incnInsured],[incnCovgAmt],[incnDeductible],[incnUnInsPolicyLimit],[incnUnderPolicyLimit],[incbPolicyTerm],[incbTotCovg],[incsPlaintiffOrDef],[incnPlaintiffIDOrDefendantID],
	[incnTPAdminOrgID],[incnTPAdminAddID],[incnTPAdjContactID],[incnTPAdjAddID],[incsTPAClaimNo],[incnRecUserID],[incdDtCreated],[incnModifyUserID],[incdDtModified],[incnLevelNo],
	[incnUnInsPolicyLimitAcc],[incnUnderPolicyLimitAcc],[incb100Per],[incnMVLeased],[incnPriority],[incbDelete],[incnauthtodefcoun],[incnauthtodefcounDt],[incbPrimary],[saga]
)
select 
	CAS.casnCaseID			as [incnCaseID],
    IOC.CID					as [incnInsContactID],
	IOC.AID					as [incnInsAddressID],
	null					as [incbCarrierHasLienYN],
	(select intnInsuranceTypeID from sma_MST_InsuranceType where intsDscrptn = CL.codelabel )
							as [incnInsType], 
	null					as [incnAdjContactId],
	null					as [incnAdjAddressID],
	null					as [incsPolicyNo],
	null					as [incsClaimNo],
	null							as [incnStackedTimes],
    isnull('entity firstname:' + nullif(convert(varchar(max),ER.firstname),'') + CHAR(13),'') +
    isnull('entity lastname:' + nullif(convert(varchar(max),ER.lastname),'') + CHAR(13),'') +
    isnull('entityrole:' + nullif(convert(varchar,ER.entityrole),'') + CHAR(13),'') +
    isnull('notes:' + nullif(convert(varchar,ER.notes),'') + CHAR(13),'') +
	''						as [incsComments],
	null					as [incnInsured],
	null					as [incnCovgAmt], 
	null					as [incnDeductible],
	null					as [incnUnInsPolicyLimit],
	null					as [incnUnderPolicyLimit],
	0						as [incbPolicyTerm],
	0						as [incbTotCovg],
	'P'						as [incsPlaintiffOrDef],
	( select plnnPlaintiffID from sma_TRN_Plaintiff where plnnCaseID=CAS.casnCaseID and plnbIsPrimary=1 )  
							as [incnPlaintiffIDOrDefendantID],
	null					as [incnTPAdminOrgID], 
	null					as [incnTPAdminAddID],
	null					as [incnTPAdjContactID],
	null					as [incnTPAdjAddID],
	null					as [incsTPAClaimNo],
	368						as [incnRecUserID],
    getdate()				as [incdDtCreated],
    null					as [incnModifyUserID],
    null					as [incdDtModified],
	null					as [incnLevelNo],
	null					as [incnUnInsPolicyLimitAcc],
	null					as [incnUnderPolicyLimitAcc],
	0						as [incb100Per],
	null					as [incnMVLeased],
	null					as [incnPriority],
	0						as [incbDelete],
	0						as [incnauthtodefcoun],
	null					as [incnauthtodefcounDt],
	0						as [incbPrimary],
	R.assocnum				as [saga]
from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS 
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=CAS.saga_entitynum 
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=R.assocrole and CL.codeclass='EPR'
inner join [SAPerfectPracticeEmroch].[dbo].[IndvOrgContacts_Indexed] IOC on IOC.saga=ER.entitynum
where CL.codelabel in 
( 
'INS_AUTO',			--1 %INS%
'INS_HEALTH',		--2 %INS%
'INS_LIABILITY',	--3 %INS%
'INS_MALPRACTICE',	--5 %INS%
'INS_SUBRO',		--6 %INS%
'INS_WORKCOMP',		--7 %INS%
'INSURANCE'			--8 %INS%
)
GO


---(2)---
insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_InsuranceCoverage] 
(
	[incnCaseID],[incnInsContactID],[incnInsAddressID],[incbCarrierHasLienYN],[incnInsType],[incnAdjContactId],[incnAdjAddressID],[incsPolicyNo],[incsClaimNo],[incnStackedTimes],
	[incsComments],[incnInsured],[incnCovgAmt],[incnDeductible],[incnUnInsPolicyLimit],[incnUnderPolicyLimit],[incbPolicyTerm],[incbTotCovg],[incsPlaintiffOrDef],[incnPlaintiffIDOrDefendantID],
	[incnTPAdminOrgID],[incnTPAdminAddID],[incnTPAdjContactID],[incnTPAdjAddID],[incsTPAClaimNo],[incnRecUserID],[incdDtCreated],[incnModifyUserID],[incdDtModified],[incnLevelNo],
	[incnUnInsPolicyLimitAcc],[incnUnderPolicyLimitAcc],[incb100Per],[incnMVLeased],[incnPriority],[incbDelete],[incnauthtodefcoun],[incnauthtodefcounDt],[incbPrimary],[saga]
)
select 
	CAS.casnCaseID			as [incnCaseID],
--	(select CID from IndvOrgContacts_Indexed where Name='Unidentified Insurance Company' and saga=-4)
    IOC_INS.CID				as [incnInsContactID],
--	(select AID from IndvOrgContacts_Indexed where Name='Unidentified Insurance Company' and saga=-4)
	IOC_INS.AID				as [incnInsAddressID],
	null					as [incbCarrierHasLienYN],
	(select intnInsuranceTypeID from sma_MST_InsuranceType where intsDscrptn = CL.codelabel )
							as [incnInsType], 
	IOC.CID					as [incnAdjContactId],
	IOC.AID					as [incnAdjAddressID],
	null					as [incsPolicyNo],
	null					as [incsClaimNo],
	null					as [incnStackedTimes],
    isnull('entity refname:' + nullif(convert(varchar(max),ER.refname),'') + CHAR(13),'') +
    isnull('entityrole:' + nullif(convert(varchar,ER.entityrole),'') + CHAR(13),'') +
    isnull('notes:' + nullif(convert(varchar,ER.notes),'') + CHAR(13),'') +
	''						as [incsComments],
	null					as [incnInsured],
	null					as [incnCovgAmt], 
	null					as [incnDeductible],
	null					as [incnUnInsPolicyLimit],
	null					as [incnUnderPolicyLimit],
	0						as [incbPolicyTerm],
	0						as [incbTotCovg],
	'P'						as [incsPlaintiffOrDef],
	( select plnnPlaintiffID from sma_TRN_Plaintiff where plnnCaseID=CAS.casnCaseID and plnbIsPrimary=1 )  
							as [incnPlaintiffIDOrDefendantID],
	null					as [incnTPAdminOrgID], 
	null					as [incnTPAdminAddID],
	null					as [incnTPAdjContactID],
	null					as [incnTPAdjAddID],
	null					as [incsTPAClaimNo],
	368						as [incnRecUserID],
    getdate()				as [incdDtCreated],
    null					as [incnModifyUserID],
    null					as [incdDtModified],
	null					as [incnLevelNo],
	null					as [incnUnInsPolicyLimitAcc],
	null					as [incnUnderPolicyLimitAcc],
	0						as [incb100Per],
	null					as [incnMVLeased],
	null					as [incnPriority],
	0						as [incbDelete],
	0						as [incnauthtodefcoun],
	null					as [incnauthtodefcounDt],
	0						as [incbPrimary],
	R.assocnum				as [saga]
from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS 
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=CAS.saga_entitynum 
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=R.assocrole and CL.codeclass='EPR'
inner join [SAPerfectPracticeEmroch].[dbo].[IndvOrgContacts_Indexed] IOC on IOC.saga=ER.entitynum
left join [SAPerfectPracticeEmroch].[dbo].[IndvOrgContacts_Indexed] IOC_INS on IOC_INS.saga=-6 and IOC_INS.CTG=2 and IOC_INS.Name=ER.refname
where CL.codelabel in 
( 
'ADJUSTOR'
)

---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_InsuranceCoverage] enable trigger all
---

--select CID from IndvOrgContacts_Indexed where Name='Unidentified Insurance Company' and saga=-4


---(Adjuster/Insurer association)---
insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_RelContacts]
(
       [rlcnPrimaryCtgID]
      ,[rlcnPrimaryContactID]
      ,[rlcnPrimaryAddressID]
      ,[rlcnRelCtgID]
      ,[rlcnRelContactID]
      ,[rlcnRelAddressID]
      ,[rlcnRelTypeID]
      ,[rlcnRecUserID]
      ,[rlcdDtCreated]
      ,[rlcnModifyUserID]
      ,[rlcdDtModified]
      ,[rlcnLevelNo]
      ,[rlcsBizFam]
      ,[rlcnOrgTypeID]
)
select distinct
	1							as [rlcnPrimaryCtgID],
	IC.[incnAdjContactId]		as [rlcnPrimaryContactID],
	IC.[incnAdjAddressID]		as [rlcnPrimaryAddressID],
	2							as [rlcnRelCtgID],
	IC.[incnInsContactID]		as [rlcnRelContactID],
	IC.[incnAdjAddressID]		as [rlcnRelAddressID],
	2							as [rlcnRelTypeID],
	368							as [rlcnRecUserID],
	getdate()					as [rlcdDtCreated],
	null						as [rlcnModifyUserID],
	null						as [rlcdDtModified],
	null						as [rlcnLevelNo],
	'Business'					as [rlcsBizFam],
	null						as [rlcnOrgTypeID]
from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_InsuranceCoverage] IC
where isnull(IC.[incnAdjContactId],0)<>0 and isnull(IC.[incnInsContactID],0)<>0  
GO

---(Appendix)---
insert into sma_TRN_InsuranceCoverageAdjusters 
(
    InsuranceCoverageId,
    AdjusterContactUID,
    IsPrimary
)

select 
    IC.incnInsCovgID			as InsuranceCoverageId,
    AC.UniqueContactId			as AdjusterContactUID,
    1							as IsPrimary		  
from sma_TRN_InsuranceCoverage AS IC 
inner join sma_MST_AllContactInfo AS AC ON AC.ContactId=IC.incnAdjContactId and AC.ContactCtg=1
 except
select 
    InsuranceCoverageId,
    AdjusterContactUID,
    IsPrimary
from sma_TRN_InsuranceCoverageAdjusters
