-- Author: Dylan Smith
-- Date: 2024-09-09
-- Description: Brief description of the script's purpose

/*
This script performs the following tasks:
  - [Task 1]
  - [Task 2]
  - ...

Notes:
	- Because batch separators (GO) are required due to schema changes (adding columns),
	we use a temporary table instead of variables, which are locally scoped
	see: https://learn.microsoft.com/en-us/sql/t-sql/language-elements/variables-transact-sql?view=sql-server-ver16#variable-scope
	see also: https://stackoverflow.com/a/56370223
	- After making schema changes (e.g. adding a new column to an existing table) statements using the new schema must be compiled separately in a different batch.
	- For example, you cannot ALTER a table to add a column, then select that column in the same batch - because while compiling the execution plan, that column does not exist for selecting.



*/

use [SA]
GO

-- Create a temporary table to store variable values
DROP TABLE IF EXISTS #TempVariables;

CREATE TABLE #TempVariables (
	OfficeName NVARCHAR(255)
   ,StateName NVARCHAR(100)
   ,PhoneNumber NVARCHAR(50)
   ,CaseGroup NVARCHAR(100)
   ,VenderCaseType NVARCHAR(25)
);

-- Insert values into the temporary table
INSERT INTO #TempVariables
	(
	OfficeName, StateName, PhoneNumber, CaseGroup, VenderCaseType
	)
VALUES (
'Joel Bieber LLC', 'Virginia', '8048008000', 'Needles', 'JoelBieberCaseType'
);


-- (0.1) sma_MST_CaseGroup -----------------------------------------------------
-- Create a default case group for data that does not neatly fit elsewhere
IF NOT EXISTS (
		SELECT
			*
		FROM [sma_MST_CaseGroup]
		WHERE [cgpsDscrptn] = (
				SELECT
					CaseGroup
				FROM #TempVariables
			)
	)
BEGIN
	INSERT INTO [sma_MST_CaseGroup]
		(
		[cgpsCode], [cgpsDscrptn], [cgpnRecUserId], [cgpdDtCreated], [cgpnModifyUserID], [cgpdDtModified], [cgpnLevelNo], [IncidentTypeID], [LimitGroupStatuses]
		)
		SELECT
			'FORCONVERSION' AS [cgpsCode]
		   ,(
				SELECT
					CaseGroup
				FROM #TempVariables
			)				
			AS [cgpsDscrptn]
		   ,368				AS [cgpnRecUserId]
		   ,GETDATE()		AS [cgpdDtCreated]
		   ,NULL			AS [cgpnModifyUserID]
		   ,NULL			AS [cgpdDtModified]
		   ,NULL			AS [cgpnLevelNo]
		   ,(
				SELECT
					IncidentTypeID
				FROM [sma_MST_IncidentTypes]
				WHERE Description = 'General Negligence'
			)				
			AS [IncidentTypeID]
		   ,NULL			AS [LimitGroupStatuses]
END
GO


-- (0.2) sma_MST_Offices -----------------------------------------------------
-- Create an office for conversion client
IF NOT EXISTS (
		SELECT
			*
		FROM [sma_mst_offices]
		WHERE office_name = (
				SELECT
					OfficeName
				FROM #TempVariables
			)
	)
BEGIN
	INSERT INTO [sma_mst_offices]
		(
		[office_status], [office_name], [state_id], [is_default], [date_created], [user_created], [date_modified], [user_modified], [Letterhead], [UniqueContactId], [PhoneNumber]
		)
		SELECT
			1					AS [office_status]
		   ,(
				SELECT
					OfficeName
				FROM #TempVariables
			)					
			AS [office_name]
		   ,(
				SELECT
					sttnStateID
				FROM sma_MST_States
				WHERE sttsDescription = (
						SELECT
							StateName
						FROM #TempVariables
					)
			)					
			AS [state_id]
		   ,1					AS [is_default]
		   ,GETDATE()			AS [date_created]
		   ,'rdoshi'			AS [user_created]
		   ,GETDATE()			AS [date_modified]
		   ,'dbo'				AS [user_modified]
		   ,'LetterheadUt.docx' AS [Letterhead]
		   ,NULL				AS [UniqueContactId]
		   ,(
				SELECT
					PhoneNumber
				FROM #TempVariables
			)					
			AS [PhoneNumber]
END
GO


-- (1) sma_MST_CaseType -----------------------------------------------------
-- (1.1) - Add a case type field that acts as conversion flag
-- for future reference: "VenderCaseType"
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'VenderCaseType'
			AND object_id = OBJECT_ID(N'sma_MST_CaseType')
	)
BEGIN
	ALTER TABLE sma_MST_CaseType
	ADD VenderCaseType VARCHAR(100)
END
GO

-- (1.2) - Create case types from CaseTypeMixtures
INSERT INTO [sma_MST_CaseType]
	(
	[cstsCode], [cstsType], [cstsSubType], [cstnWorkflowTemplateID], [cstnExpectedResolutionDays], [cstnRecUserID], [cstdDtCreated], [cstnModifyUserID], [cstdDtModified], [cstnLevelNo], [cstbTimeTracking], [cstnGroupID], [cstnGovtMunType], [cstnIsMassTort], [cstnStatusID], [cstnStatusTypeID], [cstbActive], [cstbUseIncident1], [cstsIncidentLabel1], [VenderCaseType]
	)
	SELECT
		NULL					  AS cstsCode
	   ,[SmartAdvocate Case Type] AS cstsType
	   ,NULL					  AS cstsSubType
	   ,NULL					  AS cstnWorkflowTemplateID
	   ,720						  AS cstnExpectedResolutionDays 		-- ( Hardcode 2 years )
	   ,368						  AS cstnRecUserID
	   ,GETDATE()				  AS cstdDtCreated
	   ,368						  AS cstnModifyUserID
	   ,GETDATE()				  AS cstdDtModified
	   ,0						  AS cstnLevelNo
	   ,NULL					  AS cstbTimeTracking
	   ,(
			SELECT
				cgpnCaseGroupID
			FROM sma_MST_caseGroup
			WHERE cgpsDscrptn = (
					SELECT
						CaseGroup
					FROM #TempVariables
				)
		)						  
		AS cstnGroupID
	   ,NULL					  AS cstnGovtMunType
	   ,NULL					  AS cstnIsMassTort
	   ,(
			SELECT
				cssnStatusID
			FROM [sma_MST_CaseStatus]
			WHERE csssDescription = 'Presign - Not Scheduled For Sign Up'
		)						  
		AS cstnStatusID
	   ,(
			SELECT
				stpnStatusTypeID
			FROM [sma_MST_CaseStatusType]
			WHERE stpsStatusType = 'Status'
		)						  
		AS cstnStatusTypeID
	   ,1						  AS cstbActive
	   ,1						  AS cstbUseIncident1
	   ,'Incident 1'			  AS cstsIncidentLabel1
	   ,(
			SELECT
				VenderCaseType
			FROM #TempVariables
		)						  
		AS VenderCaseType
	FROM [CaseTypeMixture] MIX
	LEFT JOIN [sma_MST_CaseType] ct
		ON ct.cststype = mix.[SmartAdvocate Case Type]
	WHERE ct.cstncasetypeid IS NULL
GO

-- (1.3) - Add conversion flag to case types created above
UPDATE [sma_MST_CaseType]
SET VenderCaseType = (
	SELECT
		VenderCaseType
	FROM #TempVariables
)
FROM [CaseTypeMixture] MIX
JOIN [sma_MST_CaseType] ct
	ON ct.cststype = mix.[SmartAdvocate Case Type]
WHERE ISNULL(VenderCaseType, '') = ''
GO

-- (2) sma_MST_CaseSubType -----------------------------------------------------
-- (2.1) - sma_MST_CaseSubTypeCode
-- For non-null values of SA Case Sub Type from CaseTypeMixture,
-- add distinct values to CaseSubTypeCode and populate stcsDscrptn
INSERT INTO [dbo].[sma_MST_CaseSubTypeCode]
	(
	stcsDscrptn
	)
	SELECT DISTINCT
		MIX.[SmartAdvocate Case Sub Type]
	FROM [CaseTypeMixture] MIX
	WHERE ISNULL(MIX.[SmartAdvocate Case Sub Type], '') <> ''
	EXCEPT
	SELECT
		stcsDscrptn
	FROM [dbo].[sma_MST_CaseSubTypeCode]
GO

-- (2.2) - sma_MST_CaseSubType
-- Construct CaseSubType using CaseTypes
INSERT INTO [sma_MST_CaseSubType]
	(
	[cstsCode], [cstnGroupID], [cstsDscrptn], [cstnRecUserId], [cstdDtCreated], [cstnModifyUserID], [cstdDtModified], [cstnLevelNo], [cstbDefualt], [saga], [cstnTypeCode]
	)
	SELECT
		NULL						  AS [cstsCode]
	   ,cstncasetypeid				  AS [cstnGroupID]
	   ,[SmartAdvocate Case Sub Type] AS [cstsDscrptn]
	   ,368							  AS [cstnRecUserId]
	   ,GETDATE()					  AS [cstdDtCreated]
	   ,NULL						  AS [cstnModifyUserID]
	   ,NULL						  AS [cstdDtModified]
	   ,NULL						  AS [cstnLevelNo]
	   ,1							  AS [cstbDefualt]
	   ,NULL						  AS [saga]
	   ,(
			SELECT
				stcnCodeId
			FROM [sma_MST_CaseSubTypeCode]
			WHERE stcsDscrptn = [SmartAdvocate Case Sub Type]
		)							  
		AS [cstnTypeCode]
	FROM [sma_MST_CaseType] CST
	JOIN [CaseTypeMixture] MIX
		ON MIX.[SmartAdvocate Case Type] = CST.cststype
	LEFT JOIN [sma_MST_CaseSubType] sub
		ON sub.[cstnGroupID] = cstncasetypeid
			AND sub.[cstsDscrptn] = [SmartAdvocate Case Sub Type]
	WHERE sub.cstncasesubtypeID IS NULL
		AND ISNULL([SmartAdvocate Case Sub Type], '') <> ''


/*
---(2.2) sma_MST_CaseSubType
insert into [sma_MST_CaseSubType]
(
       [cstsCode]
      ,[cstnGroupID]
      ,[cstsDscrptn]
      ,[cstnRecUserId]
      ,[cstdDtCreated]
      ,[cstnModifyUserID]
      ,[cstdDtModified]
      ,[cstnLevelNo]
      ,[cstbDefualt]
      ,[saga]
      ,[cstnTypeCode]
)
select  	null				as [cstsCode],
		cstncasetypeid		as [cstnGroupID],
		MIX.[SmartAdvocate Case Sub Type] as [cstsDscrptn], 
		368 				as [cstnRecUserId],
		getdate()			as [cstdDtCreated],
		null				as [cstnModifyUserID],
		null				as [cstdDtModified],
		null				as [cstnLevelNo],
		1				as [cstbDefualt],
		null				as [saga],
		(select stcnCodeId from [sma_MST_CaseSubTypeCode] where stcsDscrptn=MIX.[SmartAdvocate Case Sub Type]) as [cstnTypeCode] 
FROM [sma_MST_CaseType] CST 
JOIN [CaseTypeMixture] MIX on MIX.matcode=CST.cstsCode  
LEFT JOIN [sma_MST_CaseSubType] sub on sub.[cstnGroupID] = cstncasetypeid and sub.[cstsDscrptn] = MIX.[SmartAdvocate Case Sub Type]
WHERE isnull(MIX.[SmartAdvocate Case Type],'')<>''
and sub.cstncasesubtypeID is null
*/