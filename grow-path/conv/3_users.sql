/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-10-09
Description: Create individual contacts and users


1. update indvcnt schema
1. create indv contacts from user
2. create users

--------------------------------------------------------------------------------------------------------------------------------------
Step				Object							Action			Source				Notes
--------------------------------------------------------------------------------------------------------------------------------------
[0] Placeholder Individual Contacts			
	[0.0]			sma_MST_IndvContacts			insert			hardcode			Unassigned Staff
	[0.1]			sma_MST_IndvContacts			insert			hardcode			Unidentified Individual
	[0.3]			sma_MST_IndvContacts			insert			hardcode			Unidentified Plaintiff
	[0.4]			sma_MST_IndvContacts			insert			hardcode			Unidentified Defendant

[1.0] Users
	[1.1]			sma_MST_Address					insert			dbo.User
	[1.2]			sma_MST_EmailWebsite			insert			dbo.User
	[1.3]			sma_MST_ContactNoType			insert			hardcode
	[1.4]			sma_MST_ContactNumbers			insert			dbo.User
	[1.5]			sma_MST_Users					insert			dbo.User							

##########################################################################################################################
*/




SELECT TOP (1000) [id]
      ,[company_id]
      ,[contact_type]
      ,[name]
      ,[address]
      ,[phone]
      ,[email]
      ,[active]
      ,[created_by_id]
      ,[updated_by_id]
      ,[created_at]
      ,[updated_at]
      ,[fax_number]
      ,[contact_role]
  FROM [JoelBieber_GrowPath].[dbo].[contact]
  where name like '%jason%'

  select DISTINCT contact_type from contact c

 select * FROM user_profile_ext upe
 where user_profile_id = 213
 order by upe.user_profile_id

--truncate table user_profile
select * FROM user_profile up --where id = 150
select * from entity e



---------------------------------------------------------------------------------------------

USE JoelBieberSA_GP
GO


/*
Add saga columns to reference source data

1. saga		> link to source record
2. saga_db	> "GP" or "ND"
3. saga_ref	> indicate data source where applicable

*/
IF NOT EXISTS (
    SELECT *
    FROM sys.columns
    WHERE Name IN (N'saga', N'saga_db', N'saga_ref')
    AND Object_ID = OBJECT_ID(N'sma_MST_IndvContacts')
)
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = OBJECT_ID(N'sma_MST_IndvContacts'))
    BEGIN
        ALTER TABLE [sma_MST_IndvContacts]
        ADD saga VARCHAR(100);
    END

    IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga_db' AND Object_ID = OBJECT_ID(N'sma_MST_IndvContacts'))
    BEGIN
        ALTER TABLE [sma_MST_IndvContacts]
        ADD saga_db VARCHAR(2);
    END

    IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga_ref' AND Object_ID = OBJECT_ID(N'sma_MST_IndvContacts'))
    BEGIN
        ALTER TABLE [sma_MST_IndvContacts]
        ADD saga_ref VARCHAR(50);
    END
END
GO

---
IF NOT EXISTS (
    SELECT *
    FROM sys.columns
    WHERE Name IN (N'saga', N'saga_db', N'saga_ref')
    AND Object_ID = OBJECT_ID(N'sma_MST_Users')
)
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = OBJECT_ID(N'sma_MST_Users'))
    BEGIN
        ALTER TABLE [sma_MST_Users]
        ADD saga VARCHAR(100);
    END

    IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga_db' AND Object_ID = OBJECT_ID(N'sma_MST_Users'))
    BEGIN
        ALTER TABLE [sma_MST_Users]
        ADD saga_db VARCHAR(2);
    END

    IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga_ref' AND Object_ID = OBJECT_ID(N'sma_MST_Users'))
    BEGIN
        ALTER TABLE [sma_MST_Users]
        ADD saga_ref VARCHAR(50);
    END
END
GO




ALTER TABLE sma_MST_IndvContacts DISABLE TRIGGER ALL
GO

---------------------------------------------------
-- [1.0] Individual contacts for users
---------------------------------------------------
INSERT INTO [sma_MST_IndvContacts]
	(
	[cinbPrimary]
   ,[cinnContactTypeID]
   ,[cinnContactSubCtgID]
   ,[cinsPrefix]
   ,[cinsFirstName]
   ,[cinsMiddleName]
   ,[cinsLastName]
   ,[cinsSuffix]
   ,[cinsNickName]
   ,[cinbStatus]
   ,[cinsSSNNo]
   ,[cindBirthDate]
   ,[cinsComments]
   ,[cinnContactCtg]
   ,[cinnRefByCtgID]
   ,[cinnReferredBy]
   ,[cindDateOfDeath]
   ,[cinsCVLink]
   ,[cinnMaritalStatusID]
   ,[cinnGender]
   ,[cinsBirthPlace]
   ,[cinnCountyID]
   ,[cinsCountyOfResidence]
   ,[cinbFlagForPhoto]
   ,[cinsPrimaryContactNo]
   ,[cinsHomePhone]
   ,[cinsWorkPhone]
   ,[cinsMobile]
   ,[cinbPreventMailing]
   ,[cinnRecUserID]
   ,[cindDtCreated]
   ,[cinnModifyUserID]
   ,[cindDtModified]
   ,[cinnLevelNo]
   ,[cinsPrimaryLanguage]
   ,[cinsOtherLanguage]
   ,[cinbDeathFlag]
   ,[cinsCitizenship]
   ,[cinsHeight]
   ,[cinnWeight]
   ,[cinsReligion]
   ,[cindMarriageDate]
   ,[cinsMarriageLoc]
   ,[cinsDeathPlace]
   ,[cinsMaidenName]
   ,[cinsOccupation]
   ,[cinsSpouse]
   ,[cinsGrade]
   ,[saga]
   ,[saga_db]
   ,[saga_ref]
	)
	SELECT DISTINCT
		1		  AS [cinbPrimary]
	   ,10		  AS [cinnContactTypeID]
	   ,NULL
	   ,e.prefix AS [cinsPrefix]
	   ,e.first_name AS [cinsFirstName]
	   ,e.middle_name		  AS [cinsMiddleName]
	   ,e.last_name_or_company_name  AS [cinsLastName]
	   ,e.suffix	  AS [cinsSuffix]
	   ,NULL	  AS [cinsNickName]
	   ,1		  AS [cinbStatus]
	   ,NULL	  AS [cinsSSNNo]
	   ,e.date_of_birth	  AS [cindBirthDate]
	   ,NULL	  AS [cinsComments]
	   ,1		  AS [cinnContactCtg]
	   ,''
	   ,''
	   ,NULL
	   ,''
	   ,''
	   ,lbg.name		  AS [cinnGender]
	   ,''
	   ,1
	   ,1
	   ,NULL
	   ,NULL
	   ,''
	   ,''
	   ,NULL
	   ,0
	   ,368		  AS [cinnRecUserID]
	   ,GETDATE() AS [cindDtCreated]
	   ,''
	   ,NULL
	   ,0
	   ,''
	   ,''
	   ,''
	   ,''
	   ,NULL
	   ,NULL
	   ,''
	   ,NULL
	   ,''
	   ,''
	   ,''
	   ,lbo.name	  AS [cinsOccupation]
	   ,''		  AS [cinsSpouse]
	   ,NULL	  AS [cinsGrade]
	   ,u.id	  AS [saga]
	   ,'GP' as [saga_db]
	   ,'user_profile' as [saga_ref]
	FROM JoelBieber_GrowPath..user_profile u
	join JoelBieber_GrowPath..entity e
		ON e.user_profile_id = u.id
	-- Occupation
	LEFT JOIN JoelBieber_GrowPath..lookup_bucket lbo
		on lbo.id = u.job_title_id
	-- Gender
	LEFT JOIN JoelBieber_GrowPath..lookup_bucket lbg
		on lbg.id = e.gender_id
	--LEFT JOIN [sma_MST_IndvContacts] ind
	--	ON ind.saga = u.id
	--WHERE ind.cinnContactID IS NULL
GO







ALTER TABLE sma_MST_IndvContacts ENABLE TRIGGER ALL
GO

-----------------------------------------------------
---- [1.1] Users > Address
-----------------------------------------------------
--ALTER TABLE sma_MST_Address DISABLE TRIGGER ALL
--GO

--INSERT INTO [sma_MST_Address]
--	(
--	[addnContactCtgID]
--   ,[addnContactID]
--   ,[addnAddressTypeID]
--   ,[addsAddressType]
--   ,[addsAddTypeCode]
--   ,[addsAddress1]
--   ,[addsAddress2]
--   ,[addsAddress3]
--   ,[addsStateCode]
--   ,[addsCity]
--   ,[addnZipID]
--   ,[addsZip]
--   ,[addsCounty]
--   ,[addsCountry]
--   ,[addbIsResidence]
--   ,[addbPrimary]
--   ,[adddFromDate]
--   ,[adddToDate]
--   ,[addnCompanyID]
--   ,[addsDepartment]
--   ,[addsTitle]
--   ,[addnContactPersonID]
--   ,[addsComments]
--   ,[addbIsCurrent]
--   ,[addbIsMailing]
--   ,[addnRecUserID]
--   ,[adddDtCreated]
--   ,[addnModifyUserID]
--   ,[adddDtModified]
--   ,[addnLevelNo]
--   ,[caseno]
--   ,[addbDeleted]
--   ,[addsZipExtn]
--   ,[saga]
--	)
--	SELECT
--		ind.cinnContactCtg AS addnContactCtgID
--	   ,ind.cinnContactID  AS addnContactID
--	   ,T.addnAddTypeID	   AS addnAddressTypeID
--	   ,T.addsDscrptn	   AS addsAddressType
--	   ,T.addsCode		   AS addsAddTypeCode
--	   ,u.[street]		   AS addsAddress1
--	   ,''				   AS addsAddress2
--	   ,NULL			   AS addsAddress3
--	   ,u.[state]		   AS addsStateCode
--	   ,u.[city]		   AS addsCity
--	   ,NULL			   AS addnZipID
--	   ,u.[postalcode]	   AS addsZip
--	   ,''				   AS addsCounty
--	   ,u.[country]		   AS addsCountry
--	   ,NULL			   AS addbIsResidence
--	   ,1				   AS addbPrimary
--	   ,NULL
--	   ,NULL
--	   ,NULL
--	   ,NULL
--	   ,NULL
--	   ,NULL
--	   ,CASE
--			WHEN ISNULL(u.companyName, '') <> ''
--				THEN 'Company : ' + CHAR(13) + u.companyName
--			ELSE ''
--		END				   AS [addsComments]
--	   ,NULL
--	   ,NULL
--	   ,368				   AS addnRecUserID
--	   ,GETDATE()		   AS adddDtCreated
--	   ,368				   AS addnModifyUserID
--	   ,GETDATE()		   AS adddDtModified
--	   ,NULL
--	   ,NULL
--	   ,NULL
--	   ,NULL
--	   ,NULL
--	FROM ShinerLitify..[User] u
--	JOIN [sma_MST_IndvContacts] ind
--		ON ind.saga = u.[Id]
--	JOIN [sma_MST_AddressTypes] T
--		ON T.addnContactCategoryID = ind.cinnContactCtg
--			AND T.addsCode = 'WORK'

--ALTER TABLE sma_MST_Address ENABLE TRIGGER ALL
--GO

-----------------------------------------------------
---- [1.2] Users > Email Address
-----------------------------------------------------
--INSERT INTO [sma_MST_EmailWebsite]
--	(
--	[cewnContactCtgID]
--   ,[cewnContactID]
--   ,[cewsEmailWebsiteFlag]
--   ,[cewsEmailWebSite]
--   ,[cewbDefault]
--   ,[cewnRecUserID]
--   ,[cewdDtCreated]
--   ,[cewnModifyUserID]
--   ,[cewdDtModified]
--   ,[cewnLevelNo]
--   ,[saga]
--	)
--	SELECT
--		ind.cinnContactCtg AS cewnContactCtgID
--	   ,ind.cinnContactID  AS cewnContactID
--	   ,'E'				   AS cewsEmailWebsiteFlag
--	   ,u.Email			   AS cewsEmailWebSite
--	   ,NULL			   AS cewbDefault
--	   ,368				   AS cewnRecUserID
--	   ,GETDATE()		   AS cewdDtCreated
--	   ,368				   AS cewnModifyUserID
--	   ,GETDATE()		   AS cewdDtModified
--	   ,NULL
--	   ,NULL			   AS saga -- indicate email
--	FROM ShinerLitify..[User] u
--	JOIN [sma_MST_IndvContacts] ind
--		ON ind.saga = u.[Id]
--GO

-----------------------------------------------------
---- [1.3] Users > Phone Numbers
-----------------------------------------------------
--INSERT INTO sma_MST_ContactNoType
--	(
--	ctysDscrptn
--   ,ctynContactCategoryID
--   ,ctysDefaultTexting
--	)
--	SELECT
--		'Work Phone'
--	   ,1
--	   ,0
--	UNION
--	SELECT
--		'Work Fax'
--	   ,1
--	   ,0
--	UNION
--	SELECT
--		'Cell'
--	   ,1
--	   ,0
--	EXCEPT
--	SELECT
--		ctysDscrptn
--	   ,ctynContactCategoryID
--	   ,ctysDefaultTexting
--	FROM sma_MST_ContactNoType
--GO

---- HQ/Main Office Phone
--INSERT INTO [sma_MST_ContactNumbers]
--	(
--	[cnnnContactCtgID]
--   ,[cnnnContactID]
--   ,[cnnnPhoneTypeID]
--   ,[cnnsContactNumber]
--   ,[cnnsExtension]
--   ,[cnnbPrimary]
--   ,[cnnbVisible]
--   ,[cnnnAddressID]
--   ,[cnnsLabelCaption]
--   ,[cnnnRecUserID]
--   ,[cnndDtCreated]
--   ,[cnnnModifyUserID]
--   ,[cnndDtModified]
--   ,[cnnnLevelNo]
--   ,[caseNo]
--	)
--	SELECT
--		ind.cinnContactCtg		 AS cnnnContactCtgID
--	   ,ind.cinnContactID		 AS cnnnContactID
--	   ,(
--			SELECT
--				ctynContactNoTypeID
--			FROM sma_MST_ContactNoType
--			WHERE ctysDscrptn = 'HQ/Main Office Phone'
--				AND ctynContactCategoryID = 1
--		)						 
--		AS cnnnPhoneTypeID
--	   ,   -- Home Phone 
--		dbo.FormatPhone(u.Phone) AS cnnsContactNumber
--	   ,NULL					 AS cnnsExtension
--	   ,1						 AS cnnbPrimary
--	   ,NULL					 AS cnnbVisible
--	   ,a.addnAddressID			 AS cnnnAddressID
--	   ,'HQ/Main Office Phone'	 AS cnnsLabelCaption
--	   ,368						 AS cnnnRecUserID
--	   ,GETDATE()				 AS cnndDtCreated
--	   ,368						 AS cnnnModifyUserID
--	   ,GETDATE()				 AS cnndDtModified
--	   ,NULL
--	   ,NULL
--	FROM ShinerLitify..[User] u
--	JOIN [sma_MST_IndvContacts] ind
--		ON ind.saga = u.[Id]
--	JOIN sma_MST_Address a
--		ON a.addnContactID = ind.cinnContactID
--			AND a.addnContactCtgID = ind.cinnContactCtg
--	WHERE ISNULL(u.Phone, '') <> ''
--GO

---- Work Fax
--INSERT INTO [sma_MST_ContactNumbers]
--	(
--	[cnnnContactCtgID]
--   ,[cnnnContactID]
--   ,[cnnnPhoneTypeID]
--   ,[cnnsContactNumber]
--   ,[cnnsExtension]
--   ,[cnnbPrimary]
--   ,[cnnbVisible]
--   ,[cnnnAddressID]
--   ,[cnnsLabelCaption]
--   ,[cnnnRecUserID]
--   ,[cnndDtCreated]
--   ,[cnnnModifyUserID]
--   ,[cnndDtModified]
--   ,[cnnnLevelNo]
--   ,[caseNo]
--	)
--	SELECT
--		ind.cinnContactCtg	   AS cnnnContactCtgID
--	   ,ind.cinnContactID	   AS cnnnContactID
--	   ,(
--			SELECT
--				ctynContactNoTypeID
--			FROM sma_MST_ContactNoType
--			WHERE ctysDscrptn = 'Work Fax'
--				AND ctynContactCategoryID = 1
--		)					   
--		AS cnnnPhoneTypeID
--	   ,   -- Home Phone 
--		dbo.FormatPhone(u.Fax) AS cnnsContactNumber
--	   ,NULL				   AS cnnsExtension
--	   ,1					   AS cnnbPrimary
--	   ,NULL				   AS cnnbVisible
--	   ,a.addnAddressID		   AS cnnnAddressID
--	   ,'Work Fax'			   AS cnnsLabelCaption
--	   ,368					   AS cnnnRecUserID
--	   ,GETDATE()			   AS cnndDtCreated
--	   ,368					   AS cnnnModifyUserID
--	   ,GETDATE()			   AS cnndDtModified
--	   ,NULL
--	   ,NULL
--	FROM ShinerLitify..[User] u
--	JOIN [sma_MST_IndvContacts] ind
--		ON ind.saga = u.[Id]
--	JOIN sma_MST_Address a
--		ON a.addnContactID = ind.cinnContactID
--			AND a.addnContactCtgID = ind.cinnContactCtg
--	WHERE ISNULL(u.Fax, '') <> ''
--GO

---- Cell
--INSERT INTO [sma_MST_ContactNumbers]
--	(
--	[cnnnContactCtgID]
--   ,[cnnnContactID]
--   ,[cnnnPhoneTypeID]
--   ,[cnnsContactNumber]
--   ,[cnnsExtension]
--   ,[cnnbPrimary]
--   ,[cnnbVisible]
--   ,[cnnnAddressID]
--   ,[cnnsLabelCaption]
--   ,[cnnnRecUserID]
--   ,[cnndDtCreated]
--   ,[cnnnModifyUserID]
--   ,[cnndDtModified]
--   ,[cnnnLevelNo]
--   ,[caseNo]
--	)
--	SELECT
--		ind.cinnContactCtg			   AS cnnnContactCtgID
--	   ,ind.cinnContactID			   AS cnnnContactID
--	   ,(
--			SELECT
--				ctynContactNoTypeID
--			FROM sma_MST_ContactNoType
--			WHERE ctysDscrptn = 'Cell'
--				AND ctynContactCategoryID = 1
--		)							   
--		AS cnnnPhoneTypeID
--	   ,   -- Home Phone 
--		dbo.FormatPhone(u.MobilePhone) AS cnnsContactNumber
--	   ,NULL						   AS cnnsExtension
--	   ,1							   AS cnnbPrimary
--	   ,NULL						   AS cnnbVisible
--	   ,a.addnAddressID				   AS cnnnAddressID
--	   ,'Cell'						   AS cnnsLabelCaption
--	   ,368							   AS cnnnRecUserID
--	   ,GETDATE()					   AS cnndDtCreated
--	   ,368							   AS cnnnModifyUserID
--	   ,GETDATE()					   AS cnndDtModified
--	   ,NULL
--	   ,NULL
--	FROM ShinerLitify..[User] u
--	JOIN [sma_MST_IndvContacts] ind
--		ON ind.saga = u.[Id]
--	JOIN sma_MST_Address a
--		ON a.addnContactID = ind.cinnContactID
--			AND a.addnContactCtgID = ind.cinnContactCtg
--	WHERE ISNULL(u.MobilePhone, '') <> ''
--GO

---------------------------------------------------
-- [1.4] Users
---------------------------------------------------
ALTER TABLE sma_MST_Users DISABLE TRIGGER ALL
GO

----------------------------------------------------
-- Create aadmin user using Unassigned Staff contact
----------------------------------------------------
IF (
		SELECT
			COUNT(*)
		FROM sma_MST_Users
		WHERE usrsLoginID = 'aadmin'
	)
	= 0
BEGIN
	SET IDENTITY_INSERT sma_MST_Users ON

	INSERT INTO [sma_MST_Users]
		(
		usrnUserID
	   ,[usrnContactID]
	   ,[usrsLoginID]
	   ,[usrsPassword]
	   ,[usrsBackColor]
	   ,[usrsReadBackColor]
	   ,[usrsEvenBackColor]
	   ,[usrsOddBackColor]
	   ,[usrnRoleID]
	   ,[usrdLoginDate]
	   ,[usrdLogOffDate]
	   ,[usrnUserLevel]
	   ,[usrsWorkstation]
	   ,[usrnPortno]
	   ,[usrbLoggedIn]
	   ,[usrbCaseLevelRights]
	   ,[usrbCaseLevelFilters]
	   ,[usrnUnsuccesfulLoginCount]
	   ,[usrnRecUserID]
	   ,[usrdDtCreated]
	   ,[usrnModifyUserID]
	   ,[usrdDtModified]
	   ,[usrnLevelNo]
	   ,[usrsCaseCloseColor]
	   ,[usrnDocAssembly]
	   ,[usrnAdmin]
	   ,[usrnIsLocked]
	   ,[usrbActiveState]
		)
		SELECT DISTINCT
			368		  AS usrnuserid
		   ,(
				SELECT
				TOP 1
					cinnContactID
				FROM dbo.sma_MST_IndvContacts
				WHERE cinsLastName = 'Unassigned'
					AND cinsFirstName = 'Staff'
			)		  
			AS usrnContactID
		   ,'aadmin'  AS usrsLoginID
		   ,'2/'	  AS usrsPassword
		   ,NULL	  AS [usrsBackColor]
		   ,NULL	  AS [usrsReadBackColor]
		   ,NULL	  AS [usrsEvenBackColor]
		   ,NULL	  AS [usrsOddBackColor]
		   ,33		  AS [usrnRoleID]
		   ,NULL	  AS [usrdLoginDate]
		   ,NULL	  AS [usrdLogOffDate]
		   ,NULL	  AS [usrnUserLevel]
		   ,NULL	  AS [usrsWorkstation]
		   ,NULL	  AS [usrnPortno]
		   ,NULL	  AS [usrbLoggedIn]
		   ,NULL	  AS [usrbCaseLevelRights]
		   ,NULL	  AS [usrbCaseLevelFilters]
		   ,NULL	  AS [usrnUnsuccesfulLoginCount]
		   ,1		  AS [usrnRecUserID]
		   ,GETDATE() AS [usrdDtCreated]
		   ,NULL	  AS [usrnModifyUserID]
		   ,NULL	  AS [usrdDtModified]
		   ,NULL	  AS [usrnLevelNo]
		   ,NULL	  AS [usrsCaseCloseColor]
		   ,NULL	  AS [usrnDocAssembly]
		   ,NULL	  AS [usrnAdmin]
		   ,NULL	  AS [usrnIsLocked]
		   ,1		  AS [usrbActiveState]
	SET IDENTITY_INSERT sma_MST_Users OFF
END
GO

----------------------------------------------------
-- Create converison user using Unassigned Staff contact
----------------------------------------------------
IF (
	select count(*)
	from sma_mst_users
	where usrsloginid = 'conversion'
	) = 0
BEGIN
	INSERT INTO [sma_MST_Users]
	(
		[usrnContactID]
		,[usrsLoginID]
		,[usrsPassword]
		,[usrsBackColor]
		,[usrsReadBackColor]
		,[usrsEvenBackColor]
		,[usrsOddBackColor]
		,[usrnRoleID]
		,[usrdLoginDate]
		,[usrdLogOffDate]
		,[usrnUserLevel]
		,[usrsWorkstation]
		,[usrnPortno]
		,[usrbLoggedIn]
		,[usrbCaseLevelRights]
		,[usrbCaseLevelFilters]
		,[usrnUnsuccesfulLoginCount]
		,[usrnRecUserID]
		,[usrdDtCreated]
		,[usrnModifyUserID]
		,[usrdDtModified]
		,[usrnLevelNo]
		,[usrsCaseCloseColor]
		,[usrnDocAssembly]
		,[usrnAdmin]
		,[usrnIsLocked]
		,[usrbActiveState]
	)
	SELECT DISTINCT
		(
			SELECT
				TOP 1
				cinnContactID
			FROM
				dbo.sma_MST_IndvContacts
			WHERE
				cinslastname = 'Unassigned'
				AND cinsfirstname = 'Staff'
		)							as usrnContactID
		,'conversion'				as usrsLoginID
		,'pass'				 		as usrsPassword
		,null						as [usrsBackColor]
		,null						as [usrsReadBackColor]
		,null						as [usrsEvenBackColor]
		,null						as [usrsOddBackColor]
		,33							as [usrnRoleID]
		,null						as [usrdLoginDate]
		,null						as [usrdLogOffDate]
		,null						as [usrnUserLevel]
		,null						as [usrsWorkstation]
		,null						as [usrnPortno]
		,null						as [usrbLoggedIn]
		,null						as [usrbCaseLevelRights]
		,null						as [usrbCaseLevelFilters]
		,null						as [usrnUnsuccesfulLoginCount]
		,1							as [usrnRecUserID]
		,GETDATE()					as [usrdDtCreated]
		,null						as [usrnModifyUserID]
		,null						as [usrdDtModified]
		,null						as [usrnLevelNo]
		,null						as [usrsCaseCloseColor]
		,null						as [usrnDocAssembly]
		,null						as [usrnAdmin]
		,null						as [usrnIsLocked]
		,1							as [usrbActiveState]
END


-- Create users from individual contacts
INSERT INTO [sma_MST_Users]
	(
	[usrnContactID]
   ,[usrsLoginID]
   ,[usrsPassword]
   ,[usrsBackColor]
   ,[usrsReadBackColor]
   ,[usrsEvenBackColor]
   ,[usrsOddBackColor]
   ,[usrnRoleID]
   ,[usrdLoginDate]
   ,[usrdLogOffDate]
   ,[usrnUserLevel]
   ,[usrsWorkstation]
   ,[usrnPortno]
   ,[usrbLoggedIn]
   ,[usrbCaseLevelRights]
   ,[usrbCaseLevelFilters]
   ,[usrnUnsuccesfulLoginCount]
   ,[usrnRecUserID]
   ,[usrdDtCreated]
   ,[usrnModifyUserID]
   ,[usrdDtModified]
   ,[usrnLevelNo]
   ,[usrsCaseCloseColor]
   ,[usrnDocAssembly]
   ,[usrnAdmin]
   ,[usrnIsLocked]
   ,usrbActiveState
   ,usrnFirmRoleID
   ,usrnFirmTitleID
   ,usrbIsShowInSystem
   ,[saga]
   ,[saga_ref]
	)
	--select * FROM JoelBieber_GrowPath..user_profile up
	SELECT DISTINCT
		cinnContactID
	   ,up.username	AS [usrsLoginID]
	   ,'#'		 AS [usrsPassword]
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,33
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,1
	   ,GETDATE()
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,0
	   ,NULL
	   ,0
	   ,21862
	   ,21866
	   ,0
	   ,up.id as saga
	   ,'GP' as saga_ref
	FROM sma_MST_IndvContacts IND
	JOIN JoelBieber_GrowPath..user_profile up
		ON IND.saga = up.id
	LEFT JOIN [sma_MST_Users] u
		ON u.saga = IND.saga
	WHERE u.usrsLoginID IS NULL
GO


-----------------------------------------------------------
-- Add default set of case browse columns for every user.
-----------------------------------------------------------

DECLARE @UserID INT

DECLARE staff_cursor CURSOR FAST_FORWARD FOR SELECT
	usrnUserID
FROM sma_MST_Users

OPEN staff_cursor

FETCH NEXT FROM staff_cursor INTO @UserID

SET NOCOUNT ON;
WHILE @@FETCH_STATUS = 0
BEGIN
-- Print the fetched UserID for debugging
PRINT 'Fetched UserID: ' + CAST(@UserID AS VARCHAR);

-- Check if @UserID is NULL
IF @UserID IS NOT NULL
BEGIN
	PRINT 'Inserting for UserID: ' + CAST(@UserID AS VARCHAR);

	INSERT INTO sma_TRN_CaseBrowseSettings
		(
		cbsnColumnID
	   ,cbsnUserID
	   ,cbssCaption
	   ,cbsbVisible
	   ,cbsnWidth
	   ,cbsnOrder
	   ,cbsnRecUserID
	   ,cbsdDtCreated
	   ,cbsn_StyleName
		)
		SELECT DISTINCT
			cbcnColumnID
		   ,@UserID
		   ,cbcscolumnname
		   ,'True'
		   ,200
		   ,cbcnDefaultOrder
		   ,@UserID
		   ,GETDATE()
		   ,'Office2007Blue'
		FROM [sma_MST_CaseBrowseColumns]
		WHERE cbcnColumnID NOT IN (1, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 33);
END
ELSE
BEGIN
	-- Log the NULL @UserID occurrence
	PRINT 'NULL UserID encountered. Skipping insert.';
END

FETCH NEXT FROM staff_cursor INTO @UserID;
END

CLOSE staff_cursor
DEALLOCATE staff_cursor
GO

---- Appendix ----
INSERT INTO Account_UsersInRoles
	(
	user_id
   ,role_id
	)
	SELECT
		usrnUserID AS user_id
	   ,2		   AS role_id
	FROM sma_MST_Users

UPDATE Account_UsersInRoles
SET role_id = 1
WHERE user_id = 368