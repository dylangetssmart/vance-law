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

ALTER TABLE [sma_TRN_Cases] DISABLE TRIGGER ALL
GO

DECLARE @State as NVARCHAR(50)
DECLARE @OfficeName as NVARCHAR(255)
DECLARE @VenderCaseType as NVARCHAR(25)

SET @State = 'state'
SET @OfficeName = 'office_name'
SET @VenderCaseType = 'vender_case_type'

INSERT INTO [sma_TRN_Cases]
	(
	[cassCaseNumber], [casbAppName], [cassCaseName], [casnCaseTypeID], [casnState], [casdStatusFromDt], [casnStatusValueID], [casdsubstatusfromdt], [casnSubStatusValueID], [casdOpeningDate], [casdClosingDate], [casnCaseValueID], [casnCaseValueFrom], [casnCaseValueTo], [casnCurrentCourt], [casnCurrentJudge], [casnCurrentMagistrate], [casnCaptionID], [cassCaptionText], [casbMainCase], [casbCaseOut], [casbSubOut], [casbWCOut], [casbPartialOut], [casbPartialSubOut], [casbPartiallySettled], [casbInHouse], [casbAutoTimer], [casdExpResolutionDate], [casdIncidentDate], [casnTotalLiability], [cassSharingCodeID], [casnStateID], [casnLastModifiedBy], [casdLastModifiedDate], [casnRecUserID], [casdDtCreated], [casnModifyUserID], [casdDtModified], [casnLevelNo], [cassCaseValueComments], [casbRefIn], [casbDelete], [casbIntaken], [casnOrgCaseTypeID], [CassCaption], [cassMdl], [office_id], [saga], [LIP], [casnSeriousInj], [casnCorpDefn], [casnWebImporter], [casnRecoveryClient], [cas], [ngage], [casnClientRecoveredDt], [CloseReason]
	)
	SELECT
		C.casenum	   AS cassCaseNumber
	   ,''			   AS casbAppName
	   ,case_title	   AS cassCaseName
	   ,(
			SELECT
				cstnCaseSubTypeID
			FROM [sma_MST_CaseSubType] ST
			WHERE ST.cstnGroupID = CST.cstnCaseTypeID
				AND ST.cstsDscrptn = MIX.[SmartAdvocate Case Sub Type]
		)			   
		AS casnCaseTypeID
	   ,(
			SELECT
				[sttnStateID]
			FROM [sma_MST_States]
			WHERE [sttsDescription] = @State
		)			   
		AS casnState
	   ,GETDATE()	   AS casdStatusFromDt
	   ,(
			SELECT
				cssnStatusID
			FROM [sma_MST_CaseStatus]
			WHERE csssDescription = 'Presign - Not Scheduled For Sign Up'
		)			   
		AS casnStatusValueID
	   ,GETDATE()	   AS casdsubstatusfromdt
	   ,(
			SELECT
				cssnStatusID
			FROM [sma_MST_CaseStatus]
			WHERE csssDescription = 'Presign - Not Scheduled For Sign Up'
		)			   
		AS casnSubStatusValueID
	   ,CASE
			WHEN (C.date_opened NOT BETWEEN '1900-01-01' AND '2079-12-31')
				THEN GETDATE()
			ELSE C.date_opened
		END			   AS casdOpeningDate
	   ,CASE
			WHEN (C.close_date NOT BETWEEN '1900-01-01' AND '2079-12-31')
				THEN GETDATE()
			ELSE C.close_date
		END			   AS casdClosingDate
	   ,NULL		   AS [casnCaseValueID]
	   ,NULL		   AS [casnCaseValueFrom]
	   ,NULL		   AS [casnCaseValueTo]
	   ,NULL		   AS [casnCurrentCourt]
	   ,NULL		   AS [casnCurrentJudge]
	   ,NULL		   AS [casnCurrentMagistrate]
	   ,0			   AS [casnCaptionID]
	   ,case_title	   AS cassCaptionText
	   ,1			   AS [casbMainCase]
	   ,0			   AS [casbCaseOut]
	   ,0			   AS [casbSubOut]
	   ,0			   AS [casbWCOut]
	   ,0			   AS [casbPartialOut]
	   ,0			   AS [casbPartialSubOut]
	   ,0			   AS [casbPartiallySettled]
	   ,1			   AS [casbInHouse]
	   ,NULL		   AS [casbAutoTimer]
	   ,NULL		   AS [casdExpResolutionDate]
	   ,NULL		   AS [casdIncidentDate]
	   ,0			   AS [casnTotalLiability]
	   ,0			   AS [cassSharingCodeID]
	   ,(
			SELECT
				[sttnStateID]
			FROM [sma_MST_States]
			WHERE [sttsDescription] = @State
		)			   
		AS [casnStateID]
	   ,NULL		   AS [casnLastModifiedBy]
	   ,NULL		   AS [casdLastModifiedDate]
	   ,(
			SELECT
				usrnUserID
			FROM sma_MST_Users
			WHERE saga = C.intake_staff
		)			   
		AS casnRecUserID
	   ,CASE
			WHEN C.intake_date BETWEEN '1900-01-01' AND '2079-06-06' AND
				C.intake_time BETWEEN '1900-01-01' AND '2079-06-06'
				THEN (
						SELECT
							CAST(CONVERT(DATE, C.intake_date) AS DATETIME) + CAST(CONVERT(TIME, C.intake_time) AS DATETIME)
					)
			ELSE NULL
		END			   AS casdDtCreated
	   ,NULL		   AS casnModifyUserID
	   ,NULL		   AS casdDtModified
	   ,''			   AS casnLevelNo
	   ,''			   AS cassCaseValueComments
	   ,NULL		   AS casbRefIn
	   ,NULL		   AS casbDelete
	   ,NULL		   AS casbIntaken
	   ,cstnCaseTypeID AS casnOrgCaseTypeID -- actual case type
	   ,''			   AS CassCaption
	   ,0			   AS cassMdl
	   ,(
			SELECT
				office_id
			FROM sma_MST_Offices
			WHERE office_name = @OfficeName
		)			   
		AS office_id
	   ,''			   AS [saga]
	   ,NULL		   AS [LIP]
	   ,NULL		   AS [casnSeriousInj]
	   ,NULL		   AS [casnCorpDefn]
	   ,NULL		   AS [casnWebImporter]
	   ,NULL		   AS [casnRecoveryClient]
	   ,NULL		   AS [cas]
	   ,NULL		   AS [ngage]
	   ,NULL		   AS [casnClientRecoveredDt]
	   ,0			   AS CloseReason
	FROM [JoelBieberNeedles].[dbo].[cases_Indexed] C
	LEFT JOIN [JoelBieberNeedles].[dbo].[user_case_data] U
		ON U.casenum = C.casenum
	JOIN caseTypeMixture mix
		ON mix.matcode = c.matcode
	LEFT JOIN sma_MST_CaseType CST
		ON CST.cststype = mix.[smartadvocate Case Type]
			AND VenderCaseType = @VenderCaseType
	ORDER BY C.casenum
GO

---
ALTER TABLE [sma_TRN_Cases] ENABLE TRIGGER ALL
GO
---
