/* ######################################################################################
description: Create placeholder organization contacts used as fallback when contact records do not exist
steps:
	- Unidentified Medical Provider
	- Unidentified Insurance
	- Unidentified Court
	- Unidentified Lienor
	- Unidentified School
usage_instructions:
	-
dependencies:
	- 
notes:
	-
#########################################################################################
*/

USE [SA]
GO

-- ALTER TABLE [sma_MST_OrgContacts]
-- ALTER COLUMN saga VARCHAR(100);

---------------------------------------------------
-- [1] - Unidentified Medical Provider
---------------------------------------------------
IF NOT EXISTS (
		SELECT
			*
		FROM [sma_MST_OrgContacts]
		WHERE consName = 'Unidentified Medical Provider'
	)
BEGIN
	INSERT INTO [sma_MST_OrgContacts]
		(
		[consName], [connContactCtg], [connContactTypeID], [connRecUserID], [condDtCreated]
		)
		SELECT
			'Unidentified Medical Provider' AS [consName]
		   ,2								AS [connContactCtg]
		   ,(
				SELECT
					octnOrigContactTypeID
				FROM [sma_MST_OriginalContactTypes]
				WHERE octnContactCtgID = 2
					AND octsDscrptn = 'Hospital'
			)								
			AS [connContactTypeID]
		   ,368								AS [connRecUserID]
		   ,GETDATE()						AS [condDtCreated]
END
GO

---------------------------------------------------
-- [2] - Unidentified Insurance
---------------------------------------------------
IF NOT EXISTS (
		SELECT
			*
		FROM [sma_MST_OrgContacts]
		WHERE consName = 'Unidentified Insurance'
	)
BEGIN
	INSERT INTO [sma_MST_OrgContacts]
		(
		[consName], [connContactCtg], [connContactTypeID], [connRecUserID], [condDtCreated]
		)
		SELECT
			'Unidentified Insurance' AS [consName]
		   ,2						 AS [connContactCtg]
		   ,(
				SELECT
					octnOrigContactTypeID
				FROM [sma_MST_OriginalContactTypes]
				WHERE octnContactCtgID = 2
					AND octsDscrptn = 'Insurance Company'
			)						 
			AS [connContactTypeID]
		   ,368						 AS [connRecUserID]
		   ,GETDATE()				 AS [condDtCreated]
END
GO

---------------------------------------------------
-- [3] - Unidentified Court
---------------------------------------------------
IF NOT EXISTS (
		SELECT
			*
		FROM [sma_MST_OrgContacts]
		WHERE consName = 'Unidentified Court'
	)
BEGIN
	INSERT INTO [sma_MST_OrgContacts]
		(
		[consName], [connContactCtg], [connContactTypeID], [connRecUserID], [condDtCreated]
		)
		SELECT
			'Unidentified Court' AS [consName]
		   ,2					 AS [connContactCtg]
		   ,(
				SELECT
					octnOrigContactTypeID
				FROM [sma_MST_OriginalContactTypes]
				WHERE octnContactCtgID = 2
					AND octsDscrptn = 'Court'
			)					 
			AS [connContactTypeID]
		   ,368					 AS [connRecUserID]
		   ,GETDATE()			 AS [condDtCreated]
END
GO

---------------------------------------------------
-- [4] - Unidentified Lienor
---------------------------------------------------
IF NOT EXISTS (
		SELECT
			*
		FROM [sma_MST_OrgContacts]
		WHERE consName = 'Unidentified Lienor'
	)
BEGIN
	INSERT INTO [sma_MST_OrgContacts]
		(
		[consName], [connContactCtg], [connContactTypeID], [connRecUserID], [condDtCreated]
		)
		SELECT
			'Unidentified Lienor' AS [consName]
		   ,2					  AS [connContactCtg]
		   ,(
				SELECT
					octnOrigContactTypeID
				FROM [sma_MST_OriginalContactTypes]
				WHERE octnContactCtgID = 2
					AND octsDscrptn = 'General'
			)					  
			AS [connContactTypeID]
		   ,368					  AS [connRecUserID]
		   ,GETDATE()			  AS [condDtCreated]
END
GO

---------------------------------------------------
-- [5] - Unidentified School
---------------------------------------------------
IF NOT EXISTS (
		SELECT
			*
		FROM [sma_MST_OrgContacts]
		WHERE consName = 'Unidentified School'
	)
BEGIN
	INSERT INTO [sma_MST_OrgContacts]
		(
		[consName], [connContactCtg], [connContactTypeID], [connRecUserID], [condDtCreated]
		)
		SELECT
			'Unidentified School' AS [consName]
		   ,2					  AS [connContactCtg]
		   ,(
				SELECT
					octnOrigContactTypeID
				FROM [sma_MST_OriginalContactTypes]
				WHERE octnContactCtgID = 2
					AND octsDscrptn = 'General'
			)					  
			AS [connContactTypeID]
		   ,368					  AS [connRecUserID]
		   ,GETDATE()			  AS [condDtCreated]
END
GO