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
alter table [sma_TRN_Incidents] disable trigger all
delete [sma_TRN_Incidents]
DBCC CHECKIDENT ('[sma_TRN_Incidents]', RESEED, 0);
alter table [sma_TRN_Incidents] enable trigger all
*/


---
ALTER TABLE [sma_TRN_Incidents] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Cases] DISABLE TRIGGER ALL
GO

DECLARE @StateCode NVARCHAR(2) = 'VA'

---
INSERT INTO [sma_TRN_Incidents]
	(
	[CaseId], [IncidentDate], [StateID], [LiabilityCodeId], [IncidentFacts], [MergedFacts], [Comments], [IncidentTime], [RecUserID], [DtCreated], [ModifyUserID], [DtModified]
	)
	SELECT
		CAS.casnCaseID	   AS CaseId
	   ,CASE
			WHEN (C.[date_of_incident] BETWEEN '1900-01-01' AND '2079-06-06')
				THEN CONVERT(DATE, C.[date_of_incident])
			ELSE NULL
		END				   AS IncidentDate
	   ,CASE
			WHEN EXISTS (
					SELECT
						*
					FROM sma_MST_States
					WHERE sttsCode = U.[State]
				)
				THEN (
						SELECT
							sttnStateID
						FROM sma_MST_States
						WHERE sttsCode = U.[State]
					)
			ELSE (
					SELECT
						sttnStateID
					FROM sma_MST_States
					WHERE sttsCode = @StateCode
				)
		END				   AS [StateID]
		-- ,(
		-- 	select sttnStateID
		-- 	from sma_MST_States
		-- 	where sttsCode='VA'
		-- )							as [StateID]
	   ,0				   AS LiabilityCodeId
	   ,C.synopsis + CHAR(13) +
		--isnull('Description of Accident:' + nullif(u.Description_of_Accident,'') + CHAR(13),'') + 
		''				   AS IncidentFacts
	   ,''				   AS [MergedFacts]
	   ,NULL			   AS [Comments]
	   ,u.Time_of_Accident AS [IncidentTime]
	   ,368				   AS [RecUserID]
	   ,GETDATE()		   AS [DtCreated]
	   ,NULL			   AS [ModifyUserID]
	   ,NULL			   AS [DtModified]
	FROM TestNeedles.[dbo].[cases_Indexed] C
	JOIN TestNeedles.[dbo].[user_case_data] U
		ON U.casenum = C.casenum
	JOIN [sma_TRN_cases] CAS
		ON CAS.cassCaseNumber = CONVERT(VARCHAR, C.casenum)

UPDATE CAS
SET CAS.casdIncidentDate = INC.IncidentDate
   ,CAS.casnStateID = INC.StateID
   ,CAS.casnState = INC.StateID
FROM sma_trn_cases AS CAS
LEFT JOIN sma_TRN_Incidents AS INC
	ON casnCaseID = caseid
WHERE INC.CaseId = CAS.casncaseid

---
ALTER TABLE [sma_TRN_Incidents] ENABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Cases] ENABLE TRIGGER ALL
GO