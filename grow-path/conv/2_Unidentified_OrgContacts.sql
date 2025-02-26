/* #######################################################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create placeholder organization contacts used as fallback when contact records do not exist

1.0 - Unidentified Medical Provider
1.1 - Unidentified Insurance
1.2 - Unidentified Court
1.3 - Unid Lienor

#########################################################################################################################
*/

USE JoelBieberSA
GO

---------------------------------------------------
-- [1.0] - Unidentified Medical Provider
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
		[consName]
	   ,[connContactCtg]
	   ,[connContactTypeID]
	   ,[connRecUserID]
	   ,[condDtCreated]
	   ,[saga]
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
		   ,'unidentifiedHospital'			AS [saga]
END

---------------------------------------------------
-- [1.1] - Unidentified Insurance
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
		[consName]
	   ,[connContactCtg]
	   ,[connContactTypeID]
	   ,[connRecUserID]
	   ,[condDtCreated]
	   ,[saga]
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
		   ,'unidentifiedInsurance'	 AS [saga]
END

---------------------------------------------------
-- [1.2] - Unidentified Court
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
		[consName]
	   ,[connContactCtg]
	   ,[connContactTypeID]
	   ,[connRecUserID]
	   ,[condDtCreated]
	   ,[saga]
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
		   ,'unidentifiedCourt'	 AS [saga]
END

-- ds 2024-09-25
---------------------------------------------------
-- [1.3] - Unidentified Lienor
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
		[consName]
	   ,[connContactCtg]
	   ,[connContactTypeID]
	   ,[connRecUserID]
	   ,[condDtCreated]
	   ,[saga]
		)
		SELECT
			'Unidentified Lienor' AS [consName]
		   ,2					 AS [connContactCtg]
		   ,(
				SELECT
					octnOrigContactTypeID
			FROM [sma_MST_OriginalContactTypes]
				WHERE octnContactCtgID = 2
					AND octsDscrptn = 'General'
			)					 
			AS [connContactTypeID]
		   ,368					 AS [connRecUserID]
		   ,GETDATE()			 AS [condDtCreated]
		   ,'unidentifiedLienor'	 AS [saga]
END
