/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create users and contacts

replace: @VenderCaseType
##########################################################################################################################
*/

USE [SA]
GO

DECLARE @VenderCaseType as NVARCHAR(25)
SET @VenderCaseType = 'vender_case_type'

-- (3.0) sma_MST_SubRole -----------------------------------------------------
INSERT INTO [sma_MST_SubRole]
	(
	[sbrsCode], [sbrnRoleID], [sbrsDscrptn], [sbrnCaseTypeID], [sbrnPriority], [sbrnRecUserID], [sbrdDtCreated], [sbrnModifyUserID], [sbrdDtModified], [sbrnLevelNo], [sbrbDefualt], [saga]
	)
	SELECT
		[sbrsCode]		   AS [sbrsCode]
	   ,[sbrnRoleID]	   AS [sbrnRoleID]
	   ,[sbrsDscrptn]	   AS [sbrsDscrptn]
	   ,CST.cstnCaseTypeID AS [sbrnCaseTypeID]
	   ,[sbrnPriority]	   AS [sbrnPriority]
	   ,[sbrnRecUserID]	   AS [sbrnRecUserID]
	   ,[sbrdDtCreated]	   AS [sbrdDtCreated]
	   ,[sbrnModifyUserID] AS [sbrnModifyUserID]
	   ,[sbrdDtModified]   AS [sbrdDtModified]
	   ,[sbrnLevelNo]	   AS [sbrnLevelNo]
	   ,[sbrbDefualt]	   AS [sbrbDefualt]
	   ,[saga]			   AS [saga]
	FROM sma_MST_CaseType CST
	LEFT JOIN sma_mst_subrole S
		ON CST.cstnCaseTypeID = S.sbrnCaseTypeID
			OR S.sbrnCaseTypeID = 1
	JOIN [CaseTypeMixture] MIX
		ON MIX.matcode = CST.cstsCode
	WHERE VenderCaseType = @VenderCaseType
		AND ISNULL(MIX.[SmartAdvocate Case Type], '') = ''

-- (3.1) sma_MST_SubRole : use the sma_MST_SubRole.sbrsDscrptn value to set the sma_MST_SubRole.sbrnTypeCode field ---
UPDATE sma_MST_SubRole
SET sbrnTypeCode = A.CodeId
FROM (
	SELECT
		S.sbrsDscrptn AS sbrsDscrptn
	   ,S.sbrnSubRoleId AS SubRoleId
	   ,(
			SELECT
				MAX(srcnCodeId)
			FROM sma_MST_SubRoleCode
			WHERE srcsDscrptn = S.sbrsDscrptn
		)
		AS CodeId
	FROM sma_MST_SubRole S
	JOIN sma_MST_CaseType CST
		ON CST.cstnCaseTypeID = S.sbrnCaseTypeID
		AND CST.VenderCaseType = @VenderCaseType
) A
WHERE A.SubRoleId = sbrnSubRoleId


-- (4) specific plaintiff and defendant party roles ----------------------------------------------------
INSERT INTO [sma_MST_SubRoleCode]
	(
	srcsDscrptn, srcnRoleID
	)
	(
	SELECT
		'(P)-Default Role'
	   ,4

	UNION ALL

	SELECT
		'(D)-Default Role'
	   ,5

	UNION ALL

	SELECT
		[SA Roles]
	   ,4
	FROM [PartyRoles]
	WHERE [SA Party] = 'Plaintiff'

	UNION ALL

	SELECT
		[SA Roles]
	   ,5
	FROM [PartyRoles]
	WHERE [SA Party] = 'Defendant'
	)
	EXCEPT
	SELECT
		srcsDscrptn
	   ,srcnRoleID
	FROM [sma_MST_SubRoleCode]


-- (4.1) Not already in sma_MST_SubRole-----
INSERT INTO sma_MST_SubRole
	(
	sbrnRoleID, sbrsDscrptn, sbrnCaseTypeID, sbrnTypeCode
	)
	SELECT
		T.sbrnRoleID
	   ,T.sbrsDscrptn
	   ,T.sbrnCaseTypeID
	   ,T.sbrnTypeCode
	FROM (
		SELECT
			R.PorD AS sbrnRoleID
		   ,R.[role] AS sbrsDscrptn
		   ,CST.cstnCaseTypeID AS sbrnCaseTypeID
		   ,(
				SELECT
					srcnCodeId
				FROM sma_MST_SubRoleCode
				WHERE srcsDscrptn = R.role
					AND srcnRoleID = R.PorD
			)
			AS sbrnTypeCode
		FROM sma_MST_CaseType CST
		CROSS JOIN (
			SELECT
				'(P)-Default Role' AS role
			   ,4 AS PorD
			UNION ALL
			SELECT
				'(D)-Default Role' AS role
			   ,5 AS PorD
			UNION ALL
			SELECT
				[SA Roles] AS role
			   ,4 AS PorD
			FROM [PartyRoles]
			WHERE [SA Party] = 'Plaintiff'
			UNION ALL
			SELECT
				[SA Roles] AS role
			   ,5 AS PorD
			FROM [PartyRoles]
			WHERE [SA Party] = 'Defendant'
		) R
		WHERE CST.VenderCaseType = @VenderCaseType
	) T
	EXCEPT
	SELECT
		sbrnRoleID
	   ,sbrsDscrptn
	   ,sbrnCaseTypeID
	   ,sbrnTypeCode
	FROM sma_MST_SubRole