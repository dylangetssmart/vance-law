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

IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga_party'
			AND object_id = OBJECT_ID(N'sma_TRN_Defendants')
	)
BEGIN
	ALTER TABLE [sma_TRN_Defendants] ADD [saga_party] INT NULL;
END

ALTER TABLE [sma_TRN_Defendants] DISABLE TRIGGER ALL
GO


/*
-------------------------------------------------------------------------------
-- Construct sma_TRN_Defendants ###############################################
-------------------------------------------------------------------------------
*/

INSERT INTO [sma_TRN_Defendants]
	(
	[defnCaseID], [defnContactCtgID], [defnContactID], [defnAddressID], [defnSubRole], [defbIsPrimary], [defbCounterClaim], [defbThirdParty], [defsThirdPartyRole], [defnPriority], [defdFrmDt], [defdToDt], [defnRecUserID], [defdDtCreated], [defnModifyUserID], [defdDtModified], [defnLevelNo], [defsMarked], [saga], [saga_party]
	)
	SELECT
		casnCaseID	  AS [defnCaseID]
	   ,ACIO.CTG	  AS [defnContactCtgID]
	   ,ACIO.CID	  AS [defnContactID]
	   ,ACIO.AID	  AS [defnAddressID]
	   ,sbrnSubRoleId AS [defnSubRole]
	   ,1			  AS [defbIsPrimary]
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,368			  AS [defnRecUserID]
	   ,GETDATE()	  AS [defdDtCreated]
	   ,NULL		  AS [defnModifyUserID]
	   ,NULL		  AS [defdDtModified]
	   ,NULL		  AS [defnLevelNo]
	   ,NULL
	   ,NULL
	   ,P.TableIndex  AS [saga_party]
	FROM TestNeedles.[dbo].[party_indexed] P
	JOIN [sma_TRN_Cases] CAS
		ON CAS.cassCaseNumber = P.case_id
	JOIN IndvOrgContacts_Indexed ACIO
		ON ACIO.SAGA = P.party_id
	JOIN [PartyRoles] pr
		ON pr.[Needles Roles] = p.[role]
	JOIN [sma_MST_SubRole] S
		ON CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID
			AND s.sbrsDscrptn = [sa roles]
			AND S.sbrnRoleID = 5
	WHERE pr.[sa party] = 'Defendant'
GO

/*
-------------------------------------------------------------------------------
##############################################################################
-------------------------------------------------------------------------------
---(Appendix B)-- every case need at least one defendant
*/

INSERT INTO [sma_TRN_Defendants]
	(
	[defnCaseID], [defnContactCtgID], [defnContactID], [defnAddressID], [defnSubRole], [defbIsPrimary], [defbCounterClaim], [defbThirdParty], [defsThirdPartyRole], [defnPriority], [defdFrmDt], [defdToDt], [defnRecUserID], [defdDtCreated], [defnModifyUserID], [defdDtModified], [defnLevelNo], [defsMarked], [saga]
	)
	SELECT
		casnCaseID AS [defnCaseID]
	   ,1		   AS [defnContactCtgID]
	   ,(
			SELECT
				cinncontactid
			FROM sma_MST_IndvContacts
			WHERE cinsFirstName = 'Defendant'
				AND cinsLastName = 'Unidentified'
		)		   
		AS [defnContactID]
	   ,NULL	   AS [defnAddressID]
	   ,(
			SELECT
				sbrnSubRoleId
			FROM sma_MST_SubRole S
			INNER JOIN sma_MST_SubRoleCode C
				ON C.srcnCodeId = S.sbrnTypeCode
				AND C.srcsDscrptn = '(D)-Default Role'
			WHERE S.sbrnCaseTypeID = CAS.casnOrgCaseTypeID
		)		   
		AS [defnSubRole]
	   ,1		   AS [defbIsPrimary]
	   ,-- reexamine??
		NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,368		   AS [defnRecUserID]
	   ,GETDATE()  AS [defdDtCreated]
	   ,368		   AS [defnModifyUserID]
	   ,GETDATE()  AS [defdDtModified]
	   ,NULL
	   ,NULL
	   ,NULL
	FROM sma_trn_cases CAS
	LEFT JOIN [sma_TRN_Defendants] D
		ON D.defnCaseID = CAS.casnCaseID
	WHERE D.defnCaseID IS NULL

----
UPDATE sma_TRN_Defendants
SET defbIsPrimary = 0

UPDATE sma_TRN_Defendants
SET defbIsPrimary = 1
FROM (
	SELECT DISTINCT
		D.defnCaseID
	   ,ROW_NUMBER() OVER (PARTITION BY D.defnCaseID ORDER BY P.record_num) AS RowNumber
	   ,D.defnDefendentID AS ID
	FROM sma_TRN_Defendants D
	LEFT JOIN TestNeedles.[dbo].[party_indexed] P
		ON P.TableIndex = D.saga_party
) A
WHERE A.RowNumber = 1
AND defnDefendentID = A.ID

GO


---
ALTER TABLE [sma_TRN_Defendants] ENABLE TRIGGER ALL
GO