/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create users and contacts

replace:
'OfficeName'
'StateDescription'
'VenderCaseType'
##########################################################################################################################
*/

USE [SA]
GO

/*
alter table [sma_TRN_InsuranceCoverage] disable trigger all
delete from [sma_TRN_InsuranceCoverage]
DBCC CHECKIDENT ('[sma_TRN_InsuranceCoverage]', RESEED, 0);
alter table [sma_TRN_InsuranceCoverage] disable trigger all
*/

IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga'
			AND object_id = OBJECT_ID(N'sma_TRN_InsuranceCoverage')
	)
BEGIN
	ALTER TABLE [sma_TRN_InsuranceCoverage]
	ADD [saga] INT NULL;
END

/*
-------------------------------------------------------------------------------
##############################################################################
-------------------------------------------------------------------------------
Build support table with anchors and values
*/
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE name = 'Insurance_Contacts_Helper'
			AND type = 'U'
	)
BEGIN
	DROP TABLE Insurance_Contacts_Helper
END
GO

CREATE TABLE Insurance_Contacts_Helper (
	tableIndex INT IDENTITY (1, 1) NOT NULL
   ,insurance_id INT			-- table id
   ,insurer_id INT				-- insurance company
   ,adjuster_id INT				-- adjuster
   ,insured VARCHAR(100)		-- a person or organization covered by insurance
   ,incnInsContactID INT
   ,incnInsAddressID INT
   ,incnAdjContactId INT
   ,incnAdjAddressID INT
   ,incnInsured INT
   ,pord VARCHAR(1)
   ,caseID INT
   ,PlaintiffDefendantID INT
	CONSTRAINT IX_Insurance_Contacts_Helper PRIMARY KEY CLUSTERED
	(
	tableIndex
	) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_insurance_id ON Insurance_Contacts_Helper (insurance_id);
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_insurer_id ON Insurance_Contacts_Helper (insurer_id);
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_adjuster_id ON Insurance_Contacts_Helper (adjuster_id);
GO

---(0)---
INSERT INTO Insurance_Contacts_Helper
	(
	insurance_id, insurer_id, adjuster_id, insured, incnInsContactID, incnInsAddressID, incnAdjContactId, incnAdjAddressID, incnInsured, pord, caseID, PlaintiffDefendantID
	)
	SELECT
		INS.insurance_id
	   ,INS.insurer_id
	   ,INS.adjuster_id
	   ,INS.insured
	   ,IOC1.CID			 AS incnInsContactID
	   ,IOC1.AID			 AS incnInsAddressID
	   ,IOC2.CID			 AS incnAdjContactId
	   ,IOC2.AID			 AS incnAdjAddressID
	   ,INFO.UniqueContactId AS incnInsured
	   ,NULL				 AS pord
	   ,CAS.casnCaseID		 AS caseID
	   ,NULL				 AS PlaintiffDefendantID
	--select *
	FROM NeedlesSLF.[dbo].[insurance_Indexed] INS
	JOIN [sma_TRN_Cases] CAS
		ON CAS.cassCaseNumber = INS.case_num
	JOIN IndvOrgContacts_Indexed IOC1
		ON IOC1.saga = INS.insurer_id
			AND ISNULL(INS.insurer_id, 0) <> 0
			AND ioc1.CTG = 2
	LEFT JOIN IndvOrgContacts_Indexed IOC2
		ON IOC2.saga = INS.adjuster_id
			AND ISNULL(INS.adjuster_id, 0) <> 0
	JOIN [sma_MST_IndvContacts] I
		ON I.cinsLastName = INS.insured
			AND I.cinsGrade = INS.insured
			AND I.saga = -1
	JOIN [sma_MST_AllContactInfo] INFO
		ON INFO.ContactId = I.cinnContactID
			AND INFO.ContactCtg = I.cinnContactCtg
GO

DBCC DBREINDEX ('Insurance_Contacts_Helper', ' ', 90) WITH NO_INFOMSGS
GO

---(0)--- (prepare for multiple party)
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE Name = 'multi_party_helper_temp'
	)
BEGIN
	DROP TABLE [multi_party_helper_temp]
END
GO

SELECT
	INS.insurance_id AS ins_id
   ,T.plnnPlaintiffID INTO [multi_party_helper_temp]
--select *
FROM NeedlesSLF.[dbo].[insurance_Indexed] INS
JOIN [sma_TRN_cases] CAS
	ON CAS.cassCaseNumber = INS.case_num
JOIN [IndvOrgContacts_Indexed] IOC
	ON IOC.SAGA = INS.party_id
JOIN [sma_TRN_Plaintiff] T
	ON T.plnnContactID = IOC.CID
		AND T.plnnContactCtg = IOC.CTG
		AND T.plnnCaseID = CAS.casnCaseID
GO

UPDATE [Insurance_Contacts_Helper]
SET pord = 'P'
   ,PlaintiffDefendantID = A.plnnPlaintiffID
FROM [multi_party_helper_temp] A
WHERE A.ins_id = insurance_id
GO

IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE Name = 'multi_party_helper_temp'
	)
BEGIN
	DROP TABLE [multi_party_helper_temp]
END
GO

SELECT
	INS.insurance_id AS ins_id
   ,D.defnDefendentID INTO [multi_party_helper_temp]
FROM NeedlesSLF.[dbo].[insurance_Indexed] INS
JOIN [sma_TRN_cases] CAS
	ON CAS.cassCaseNumber = INS.case_num
JOIN [IndvOrgContacts_Indexed] IOC
	ON IOC.SAGA = INS.party_id
JOIN [sma_TRN_Defendants] D
	ON D.defnContactID = IOC.CID
		AND D.defnContactCtgID = IOC.CTG
		AND D.defnCaseID = CAS.casnCaseID
GO

UPDATE [Insurance_Contacts_Helper]
SET pord = 'D'
   ,PlaintiffDefendantID = A.defnDefendentID
FROM [multi_party_helper_temp] A
WHERE A.ins_id = insurance_id
GO

-------------------------------------------------------------------------------
-- Insurance Types ############################################################
-------------------------------------------------------------------------------
INSERT INTO [sma_MST_InsuranceType]
	(
	intsDscrptn
	)
	SELECT
		'Unspecified'
	UNION
	SELECT DISTINCT
		policy_type
	FROM NeedlesSLF.[dbo].[insurance] INS
	WHERE ISNULL(policy_type, '') <> ''
	EXCEPT
	SELECT
		intsDscrptn
	FROM [sma_MST_InsuranceType]
GO

---
ALTER TABLE [sma_TRN_InsuranceCoverage] DISABLE TRIGGER ALL
---
GO

--(1)--- Insurance of plaintiffs
INSERT INTO [sma_TRN_InsuranceCoverage]
	(
	[incnCaseID], [incnInsContactID], [incnInsAddressID], [incbCarrierHasLienYN], [incnInsType], [incnAdjContactId], [incnAdjAddressID], [incsPolicyNo], [incsClaimNo], [incnStackedTimes], [incsComments], [incnInsured], [incnCovgAmt], [incnDeductible], [incnUnInsPolicyLimit], [incnUnderPolicyLimit], [incbPolicyTerm], [incbTotCovg], [incsPlaintiffOrDef], [incnPlaintiffIDOrDefendantID], [incnTPAdminOrgID], [incnTPAdminAddID], [incnTPAdjContactID], [incnTPAdjAddID], [incsTPAClaimNo], [incnRecUserID], [incdDtCreated], [incnModifyUserID], [incdDtModified], [incnLevelNo], [incnUnInsPolicyLimitAcc], [incnUnderPolicyLimitAcc], [incb100Per], [incnMVLeased], [incnPriority], [incbDelete], [incnauthtodefcoun], [incnauthtodefcounDt], [incbPrimary], [saga]
	)
	SELECT
		MAP.caseID				 AS [incnCaseID]
	   ,MAP.incnInsContactID	 AS [incnInsContactID]
	   ,MAP.incnInsAddressID	 AS [incnInsAddressID]
	   ,NULL					 AS [incbCarrierHasLienYN]
	   ,(
			SELECT
				intnInsuranceTypeID
			FROM [sma_MST_InsuranceType]
			WHERE intsDscrptn = CASE
					WHEN ISNULL(INS.policy_type, '') <> ''
						THEN INS.policy_type
					ELSE 'Unspecified'
				END
		)						 
		AS [incnInsType]
	   ,MAP.incnAdjContactId	 AS [incnAdjContactId]
	   ,MAP.incnAdjAddressID	 AS [incnAdjAddressID]
	   ,INS.policy				 AS [incsPolicyNo]
	   ,INS.claim				 AS [incsClaimNo]
	   ,NULL					 AS [incnStackedTimes]
		--  ,ISNULL('accept: ' + NULLIF(CONVERT(VARCHAR, INS.accept), '') + CHAR(13), '') +
		--ISNULL('actual: ' + NULLIF(CONVERT(VARCHAR, INS.actual), '') + CHAR(13), '') +
		--ISNULL('agent: ' + NULLIF(CONVERT(VARCHAR, INS.agent), '') + CHAR(13), '') +
		--ISNULL('date_settled: ' + NULLIF(CONVERT(VARCHAR, INS.date_settled), '') + CHAR(13), '') +
		--ISNULL('how_settled: ' + NULLIF(CONVERT(VARCHAR, INS.how_settled), '') + CHAR(13), '') +
		--ISNULL('maximum_amount: ' + NULLIF(CONVERT(VARCHAR, INS.maximum_amount), '') + CHAR(13), '') +
		--ISNULL('minimum_amount: ' + NULLIF(CONVERT(VARCHAR, INS.minimum_amount), '') + CHAR(13), '') +
		--ISNULL('policy: ' + NULLIF(CONVERT(VARCHAR, INS.policy), '') + CHAR(13), '') +
		--ISNULL('claim: ' + NULLIF(CONVERT(VARCHAR, INS.claim), '') + CHAR(13), '') +
		--ISNULL('insured: ' + NULLIF(CONVERT(VARCHAR, INS.insured), '') + CHAR(13), '') +
		--ISNULL('limits: ' + NULLIF(CONVERT(VARCHAR, INS.limits), '') + CHAR(13), '') +
		--ISNULL('comments : ' + NULLIF(CONVERT(VARCHAR, INS.comments), '') + CHAR(13), '') +
		--ISNULL('Value Date: ' + NULLIF(CONVERT(VARCHAR, Ud.Value_date, 101), '') + CHAR(13), '') +
		--ISNULL('Requested Limits: ' + NULLIF(CONVERT(VARCHAR, Ud.Requested_Limits), '') + CHAR(13), '') +
		--ISNULL('Projected Settlement Date: ' + NULLIF(CONVERT(VARCHAR, Ud.Projected_Settlement_Date, 101), '') + CHAR(13), '') +
		--ISNULL('Medpay: ' + NULLIF(CONVERT(VARCHAR, ud.Medpay), '') + CHAR(13), '') +
		--ISNULL('About Limits: ' + NULLIF(CONVERT(VARCHAR, Ud.About_Limits), '') + CHAR(13), '') +
		--ISNULL('ERISA Lien: ' + NULLIF(CONVERT(VARCHAR, Ud.ERISA_Lien), '') + CHAR(13), '') +
		--ISNULL('Subro Provider: ' + NULLIF(CONVERT(VARCHAR, Ud.Subro_Provider), '') + CHAR(13), '') +
		--ISNULL('Nurse Case Manager: ' + NULLIF(CONVERT(VARCHAR, Ud.Nurse_Case_Manager), '') + CHAR(13), '') +
		--ISNULL('NCM: ' + NULLIF(CONVERT(VARCHAR, Ud.NCM), '') + CHAR(13), '') +
		--ISNULL('Credit Attorney: ' + NULLIF(CONVERT(VARCHAR, Ud.Credit_Date, 101), '') + CHAR(13), '') +
		--ISNULL('Credit Date: ' + NULLIF(CONVERT(VARCHAR, Ud.NCM), '') + CHAR(13), '') +
		--ISNULL('Red Folder Research: ' + NULLIF(CONVERT(VARCHAR, Ud.Red_Folder_Research), '') + CHAR(13), '') +
		--ISNULL('Is_there_a_John_Doe: ' + NULLIF(CONVERT(VARCHAR, Ud.Is_there_a_John_Doe), '') + CHAR(13), '') +
	   ,''						 AS [incsComments]
	   ,MAP.incnInsured			 AS [incnInsured]
	   ,INS.actual				 AS [incnCovgAmt]
	   ,NULL					 AS [incnDeductible]
	   ,
		--lim.[high]						as [incnUnInsPolicyLimit],
		--lim.[low]						as [incnUnderPolicyLimit],
		0						 AS [incnUnInsPolicyLimit]
	   ,0						 AS [incnUnderPolicyLimit]
	   ,0						 AS [incbPolicyTerm]
	   ,0						 AS [incbTotCovg]
	   ,'P'						 AS [incsPlaintiffOrDef]
	   ,
		--    ( select plnnPlaintiffID from sma_TRN_Plaintiff where plnnCaseID=MAP.caseID and plnbIsPrimary=1 )  
		MAP.PlaintiffDefendantID AS [incnPlaintiffIDOrDefendantID]
	   ,NULL					 AS [incnTPAdminOrgID]
	   ,NULL					 AS [incnTPAdminAddID]
	   ,NULL					 AS [incnTPAdjContactID]
	   ,NULL					 AS [incnTPAdjAddID]
	   ,NULL					 AS [incsTPAClaimNo]
	   ,368						 AS [incnRecUserID]
	   ,GETDATE()				 AS [incdDtCreated]
	   ,NULL					 AS [incnModifyUserID]
	   ,NULL					 AS [incdDtModified]
	   ,NULL					 AS [incnLevelNo]
	   ,NULL					 AS [incnUnInsPolicyLimitAcc]
	   ,NULL					 AS [incnUnderPolicyLimitAcc]
	   ,0						 AS [incb100Per]
	   ,NULL					 AS [incnMVLeased]
	   ,NULL					 AS [incnPriority]
	   ,0						 AS [incbDelete]
	   ,0						 AS [incnauthtodefcoun]
	   ,NULL					 AS [incnauthtodefcounDt]
	   ,0						 AS [incbPrimary]
	   ,INS.insurance_id		 AS [saga]
	--select *
	FROM NeedlesSLF.[dbo].[insurance_Indexed] INS
	LEFT JOIN NeedlesSLF.[dbo].[user_insurance_data] UD
		ON INS.insurance_id = UD.insurance_id
	--LEFT JOIN InsuranceLimMap LIM on LIM.case_num = ins.case_num and LIM.insurer_ID = ins.insurer_id
	JOIN [Insurance_Contacts_Helper] MAP
		ON INS.insurance_id = MAP.insurance_id
			AND MAP.pord = 'P'
GO


---(2)--- Insurance of defendants
--INSERT INTO [sma_TRN_InsuranceCoverage] 
--(
--	[incnCaseID],[incnInsContactID],[incnInsAddressID],[incbCarrierHasLienYN],[incnInsType],[incnAdjContactId],[incnAdjAddressID],[incsPolicyNo],[incsClaimNo],[incnStackedTimes],
--	[incsComments],[incnInsured],[incnCovgAmt],[incnDeductible],[incnUnInsPolicyLimit],[incnUnderPolicyLimit],[incbPolicyTerm],[incbTotCovg],[incsPlaintiffOrDef],[incnPlaintiffIDOrDefendantID],
--	[incnTPAdminOrgID],[incnTPAdminAddID],[incnTPAdjContactID],[incnTPAdjAddID],[incsTPAClaimNo],[incnRecUserID],[incdDtCreated],[incnModifyUserID],[incdDtModified],[incnLevelNo],
--	[incnUnInsPolicyLimitAcc],[incnUnderPolicyLimitAcc],[incb100Per],[incnMVLeased],[incnPriority],[incbDelete],[incnauthtodefcoun],[incnauthtodefcounDt],[incbPrimary],[saga]
--)
--SELECT DISTINCT 
--	MAP.caseID					    as [incnCaseID],
--	MAP.incnInsContactID			as [incnInsContactID],
--	MAP.incnInsAddressID			as [incnInsAddressID],
--	null							as [incbCarrierHasLienYN],
--	(select intnInsuranceTypeID from [sma_MST_InsuranceType] where intsDscrptn = case when isnull(INS.policy_type,'')<>'' then INS.policy_type else 'Unspecified' end ) as [incnInsType], 
--	MAP.incnAdjContactId			as [incnAdjContactId],
--	MAP.incnAdjAddressID			as [incnAdjAddressID],
--	INS.policy					    as [incsPolicyNo],
--	INS.claim						as [incsClaimNo],
--	null							as [incnStackedTimes],
--    isnull('accept : ' + nullif(convert(varchar,INS.accept),'') + CHAR(13),'') +
--    isnull('actual : ' + nullif(convert(varchar,INS.actual),'') + CHAR(13),'') +
--    isnull('agent : ' + nullif(convert(varchar,INS.agent),'') + CHAR(13),'') +
--    isnull('date_settled : ' + nullif(convert(varchar,INS.date_settled),'') + CHAR(13),'') +
--    isnull('how_settled : ' + nullif(convert(varchar,INS.how_settled),'') + CHAR(13),'') +
--    isnull('maximum_amount : ' + nullif(convert(varchar,INS.maximum_amount),'') + CHAR(13),'') +
--    isnull('minimum_amount : ' + nullif(convert(varchar,INS.minimum_amount),'') + CHAR(13),'') +
--    isnull('policy : ' + nullif(convert(varchar,INS.policy),'') + CHAR(13),'') +
--    isnull('claim : ' + nullif(convert(varchar,INS.claim),'') + CHAR(13),'') +
--    isnull('insured : ' + nullif(convert(varchar,INS.insured),'') + CHAR(13),'') +
--    isnull('limits : ' + nullif(convert(varchar,INS.limits),'') + CHAR(13),'') +
--    isnull('comments : ' + nullif(convert(varchar,INS.comments),'') + CHAR(13),'') +
--	isnull('Value Date: ' + nullif(convert(varchar,Ud.Value_date,101),'') + CHAR(13),'') +
--	isnull('Requested Limits: ' + nullif(convert(varchar,Ud.Requested_Limits),'') + CHAR(13),'') +
--	isnull('Projected Settlement Date: ' + nullif(convert(varchar,Ud.Projected_Settlement_Date,101),'') + CHAR(13),'') +
--	isnull('Medpay: ' + nullif(convert(varchar,ud.Medpay),'') + CHAR(13),'') +
--	isnull('About Limits: ' + nullif(convert(varchar,Ud.About_Limits),'') + CHAR(13),'') +
--	isnull('ERISA Lien: ' + nullif(convert(varchar,Ud.ERISA_Lien),'') + CHAR(13),'') +
--	isnull('Subro Provider: ' + nullif(convert(varchar,Ud.Subro_Provider),'') + CHAR(13),'') +
--	isnull('Nurse Cas Manager: ' + nullif(convert(varchar,Ud.Nurse_Case_Manager),'') + CHAR(13),'') +
--	isnull('NCM: ' + nullif(convert(varchar,Ud.NCM),'') + CHAR(13),'') +
--	isnull('Credit Attorney: ' + nullif(convert(varchar,Ud.Credit_Date,101),'') + CHAR(13),'') +
--	isnull('Credit Date: ' + nullif(convert(varchar,Ud.NCM),'') + CHAR(13),'') +
--	isnull('Red Folder Research: ' + nullif(convert(varchar,Ud.Red_Folder_Research),'') + CHAR(13),'') +
--	isnull('Is_there_a_John_Doe: ' + nullif(convert(varchar,Ud.Is_there_a_John_Doe),'') + CHAR(13),'') +
--	''							    as [incsComments],
--    MAP.incnInsured					as [incnInsured],
--    INS.actual					    as [incnCovgAmt], 
--    null							as [incnDeductible],
--	lim.[high]						as [incnUnInsPolicyLimit],
--	lim.[low]						as [incnUnderPolicyLimit],
--    0							    as [incbPolicyTerm],
--    0							    as [incbTotCovg],
--    'D'							    as [incsPlaintiffOrDef],
--	MAP.PlaintiffDefendantID	    as [incnPlaintiffIDOrDefendantID],
--    null							as [incnTPAdminOrgID], 
--    null			    as [incnTPAdminAddID],
--    null			    as [incnTPAdjContactID],
--    null			    as [incnTPAdjAddID],
--    null			    as [incsTPAClaimNo],
--    368					as [incnRecUserID],
--    getdate()		    as [incdDtCreated],
--    null			    as [incnModifyUserID],
--    null			    as [incdDtModified],
--    null			    as [incnLevelNo],
--	null			    as [incnUnInsPolicyLimitAcc],
--    null			    as [incnUnderPolicyLimitAcc],
--    0					as [incb100Per],
--    null			    as [incnMVLeased],
--    null			    as [incnPriority],
--    0					as [incbDelete],
--    0					as [incnauthtodefcoun],
--    null			    as [incnauthtodefcounDt],
--    0					as [incbPrimary],
--	INS.insurance_id	as [saga]
--FROM NeedlesSLF.[dbo].[insurance_Indexed] INS
--LEFT JOIN NeedlesSLF.[dbo].[user_insurance_data] UD on INS.insurance_id=UD.insurance_id
--LEFT JOIN InsuranceLimMap LIM on LIM.case_num = ins.case_num and LIM.insurer_ID = ins.insurer_id
--JOIN [Insurance_Contacts_Helper] MAP on INS.insurance_id=MAP.insurance_id and MAP.pord='D'
GO
---
ALTER TABLE [sma_TRN_InsuranceCoverage] ENABLE TRIGGER ALL
GO
---


---(Adjuster/Insurer association)---
INSERT INTO [sma_MST_RelContacts]
	(
	[rlcnPrimaryCtgID], [rlcnPrimaryContactID], [rlcnPrimaryAddressID], [rlcnRelCtgID], [rlcnRelContactID], [rlcnRelAddressID], [rlcnRelTypeID], [rlcnRecUserID], [rlcdDtCreated], [rlcnModifyUserID], [rlcdDtModified], [rlcnLevelNo], [rlcsBizFam], [rlcnOrgTypeID]
	)
	SELECT DISTINCT
		1					  AS [rlcnPrimaryCtgID]
	   ,IC.[incnAdjContactId] AS [rlcnPrimaryContactID]
	   ,IC.[incnAdjAddressID] AS [rlcnPrimaryAddressID]
	   ,2					  AS [rlcnRelCtgID]
	   ,IC.[incnInsContactID] AS [rlcnRelContactID]
	   ,IC.[incnAdjAddressID] AS [rlcnRelAddressID]
	   ,2					  AS [rlcnRelTypeID]
	   ,368					  AS [rlcnRecUserID]
	   ,GETDATE()			  AS [rlcdDtCreated]
	   ,NULL				  AS [rlcnModifyUserID]
	   ,NULL				  AS [rlcdDtModified]
	   ,NULL				  AS [rlcnLevelNo]
	   ,'Business'			  AS [rlcsBizFam]
	   ,NULL				  AS [rlcnOrgTypeID]
	FROM [sma_TRN_InsuranceCoverage] IC
	WHERE ISNULL(IC.[incnAdjContactId], 0) <> 0
		AND ISNULL(IC.[incnInsContactID], 0) <> 0


------------------------------
--INSURANCE ADJUSTERS
------------------------------
INSERT INTO [sma_TRN_InsuranceCoverageAdjusters]
	(
	InsuranceCoverageId, AdjusterContactUID
	)
	SELECT
		incnInsCovgID
	   ,ioc2.UNQCID
	FROM sma_TRN_InsuranceCoverage ic
	JOIN IndvOrgContacts_Indexed IOC2
		ON IOC2.CID = ic.incnAdjContactId
			AND ioc2.AID = ic.[incnAdjAddressID]
	LEFT JOIN sma_TRN_InsuranceCoverageAdjusters ca
		ON ca.InsuranceCoverageId = incnInsCovgID
			AND ca.AdjusterContactUID = ioc2.UNQCID
	WHERE ca.InsuranceCoverageId IS NULL