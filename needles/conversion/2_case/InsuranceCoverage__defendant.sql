/*---
priority: 1
sequence: 1
description: Create office record
data-source:
---*/

/* ###################################################################################
description: Insert defendants
steps:
	- Insert defendant insurance > [sma_TRN_InsuranceCoverage]
	
usage_instructions:
	- 
dependencies:
	- [conversion].[insurance_contacts_helper]
notes:
	-
*/

use [VanceLawFirm_SA]
go

alter table [sma_TRN_InsuranceCoverage] disable trigger all
go

insert into [sma_TRN_InsuranceCoverage]
	(
		[incnCaseID],
		[incnInsContactID],
		[incnInsAddressID],
		[incbCarrierHasLienYN],
		[incnInsType],
		[incnAdjContactId],
		[incnAdjAddressID],
		[incsPolicyNo],
		[incsClaimNo],
		[incnStackedTimes],
		[incsComments],
		[incnInsured],
		[incnCovgAmt],
		[incnDeductible],
		[incnUnInsPolicyLimit],
		[incnUnderPolicyLimit],
		[incbPolicyTerm],
		[incbTotCovg],
		[incsPlaintiffOrDef],
		[incnPlaintiffIDOrDefendantID],
		[incnTPAdminOrgID],
		[incnTPAdminAddID],
		[incnTPAdjContactID],
		[incnTPAdjAddID],
		[incsTPAClaimNo],
		[incnRecUserID],
		[incdDtCreated],
		[incnModifyUserID],
		[incdDtModified],
		[incnLevelNo],
		[incnUnInsPolicyLimitAcc],
		[incnUnderPolicyLimitAcc],
		[incb100Per],
		[incnMVLeased],
		[incnPriority],
		[incbDelete],
		[incnauthtodefcoun],
		[incnauthtodefcounDt],
		[incbPrimary],
		[saga]
	)
	select distinct
		map.caseID				 as [incncaseid],
		map.incninscontactid	 as [incninscontactid],
		map.incninsaddressid	 as [incninsaddressid],
		null					 as [incbcarrierhaslienyn],
		(
			select
				intnInsuranceTypeID
			from [sma_MST_InsuranceType]
			where intsDscrptn = case
					when ISNULL(ins.policy_type, '') <> ''
						then ins.policy_type
					else 'Unspecified'
				end
		)						 as [incninstype],
		map.incnadjcontactid	 as [incnadjcontactid],
		map.incnadjaddressid	 as [incnadjaddressid],
		ins.policy				 as [incspolicyno],
		ins.claim				 as [incsclaimno],
		null					 as [incnstackedtimes],
		''						 as [incscomments],
		map.incninsured			 as [incninsured],
		ins.actual				 as [incncovgamt],
		null					 as [incndeductible],
		0						 as [incnuninspolicylimit],
		0						 as [incnunderpolicylimit],
		0						 as [incbpolicyterm],
		0						 as [incbtotcovg],
		'D'						 as [incsplaintiffordef],
		map.PlaintiffDefendantID as [incnplaintiffidordefendantid],
		null					 as [incntpadminorgid],
		null					 as [incntpadminaddid],
		null					 as [incntpadjcontactid],
		null					 as [incntpadjaddid],
		null					 as [incstpaclaimno],
		368						 as [incnrecuserid],
		GETDATE()				 as [incddtcreated],
		null					 as [incnmodifyuserid],
		null					 as [incddtmodified],
		null					 as [incnlevelno],
		null					 as [incnuninspolicylimitacc],
		null					 as [incnunderpolicylimitacc],
		0						 as [incb100per],
		null					 as [incnmvleased],
		null					 as [incnpriority],
		0						 as [incbdelete],
		0						 as [incnauthtodefcoun],
		null					 as [incnauthtodefcoundt],
		0						 as [incbprimary],
		ins.insurance_id		 as [saga]
	from [VanceLawFirm_Needles].[dbo].[insurance_Indexed] ins
	left join [VanceLawFirm_Needles].[dbo].[user_insurance_data] ud
		on ins.insurance_id = ud.insurance_id
	--LEFT JOIN InsuranceLimMap LIM on LIM.case_num = ins.case_num and LIM.insurer_ID = ins.insurer_id
	join conversion.insurance_contacts_helper map
		on ins.insurance_id = map.insurance_id
			and map.pord = 'D'
go

---
alter table [sma_TRN_InsuranceCoverage] enable trigger all
go

