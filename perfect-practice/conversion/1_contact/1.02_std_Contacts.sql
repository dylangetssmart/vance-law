/* ###################################################################################
description: Create contact records

steps:
	-

usage_instructions:
	-

dependencies:
	- 

notes:
	-

######################################################################################
*/

USE [JohnSalazar_SA]
GO

--(0) saga field for needles names_id ---
ALTER TABLE [sma_MST_IndvContacts]
ALTER COLUMN saga INT
ALTER TABLE [sma_MST_OrgContacts]
ALTER COLUMN saga INT


---------------------------
--INSERT RACE
---------------------------
INSERT INTO sma_mst_contactRace
	(
	RaceDesc
	)
	SELECT DISTINCT
		Race_Name
	FROM [JohnSalazar_Needles]..race
	EXCEPT
	SELECT
		RaceDesc
	FROM sma_Mst_ContactRace



---------------------------------------
-- Construct [sma_MST_IndvContacts]
---------------------------------------
INSERT INTO [sma_MST_IndvContacts]
	(
	[cinsPrefix], [cinsSuffix], [cinsFirstName], [cinsMiddleName], [cinsLastName], [cinsHomePhone], [cinsWorkPhone], [cinsSSNNo], [cindBirthDate], [cindDateOfDeath], [cinnGender], [cinsMobile], [cinsComments], [cinnContactCtg], [cinnContactTypeID], [cinnContactSubCtgID], [cinnRecUserID], [cindDtCreated], [cinbStatus], [cinbPreventMailing], [cinsNickName], [cinsPrimaryLanguage], [cinsOtherLanguage], [cinnRace], [saga]
	)
	SELECT
		LEFT(N.[prefix], 20)					 AS [cinsPrefix]
	   ,LEFT(N.[suffix], 10)					 AS [cinsSuffix]
	   ,CONVERT(VARCHAR(30), N.[first_name])	 AS [cinsFirstName]
	   ,CONVERT(VARCHAR(30), N.[initial])		 AS [cinsMiddleName]
	   ,CONVERT(VARCHAR(40), N.[last_long_name]) AS [cinsLastName]
	   ,LEFT(N.[home_phone], 20)				 AS [cinsHomePhone]
	   ,LEFT(N.[work_phone], 20)				 AS [cinsWorkPhone]
	   ,LEFT(N.[ss_number], 20)					 AS [cinsSSNNo]
	   ,CASE
			WHEN (N.[date_of_birth] NOT BETWEEN '1900-01-01' AND '2079-12-31')
				THEN GETDATE()
			ELSE N.[date_of_birth]
		END										 AS [cindBirthDate]
	   ,CASE
			WHEN (N.[date_of_death] NOT BETWEEN '1900-01-01' AND '2079-12-31')
				THEN GETDATE()
			ELSE N.[date_of_death]
		END										 AS [cindDateOfDeath]
	   ,CASE
			WHEN N.[sex] = 'M'
				THEN 1
			WHEN N.[sex] = 'F'
				THEN 2
			ELSE 0
		END										 AS [cinnGender]
	   ,LEFT(N.[car_phone], 20)					 AS [cinsMobile]
	   ,CASE
			WHEN ISNULL(N.[fax_number], '') <> ''
				THEN 'FAX NUMBER: ' + N.[fax_number]
			ELSE NULL
		END										 AS [cinsComments]
	   ,1										 AS [cinnContactCtg]
	   ,(
			SELECT
				octnOrigContactTypeID
			FROM [sma_MST_OriginalContactTypes]
			WHERE octsDscrptn = 'General'
				AND octnContactCtgID = 1
		)										 
		AS [cinnContactTypeID]
	   ,CASE
			-- if names.deceased = "Y", then grab the contactSubCategoryID for "Deceased"
			WHEN N.[deceased] = 'Y'
				THEN (
						SELECT
							cscnContactSubCtgID
						FROM [sma_MST_ContactSubCategory]
						WHERE cscsDscrptn = 'Deceased'
					)
			-- if incapacitated = "Y" on the [party_Indexed] table, then grab the contactSubCategoryID for "Incompetent"
			WHEN EXISTS (
					SELECT
						*
					FROM [JohnSalazar_Needles].[dbo].[party_Indexed] P
					WHERE P.party_id = N.names_id
						AND P.incapacitated = 'Y'
				)
				THEN (
						SELECT
							cscnContactSubCtgID
						FROM [sma_MST_ContactSubCategory]
						WHERE cscsDscrptn = 'Incompetent'
					)
			-- if minor = "Y" on the [party_Indexed] table, then grab the contactSubCategoryID for "Infant"
			-- otherwise, grab the contactSubCategoryID for "Adult"
			WHEN EXISTS (
					SELECT
						*
					FROM [JohnSalazar_Needles].[dbo].[party_Indexed] P
					WHERE P.party_id = N.names_id
						AND P.minor = 'Y'
				)
				THEN (
						SELECT
							cscnContactSubCtgID
						FROM [sma_MST_ContactSubCategory]
						WHERE cscsDscrptn = 'Infant'
					)
			ELSE (
					SELECT
						cscnContactSubCtgID
					FROM [sma_MST_ContactSubCategory]
					WHERE cscsDscrptn = 'Adult'
				)
		END										 AS cinnContactSubCtgID
	   ,368										 AS cinnRecUserID
	   ,GETDATE()								 AS cindDtCreated
	   ,1										 AS [cinbStatus]
	   ,0										 AS [cinbPreventMailing]
	   ,CONVERT(VARCHAR(15), aka_full)			 AS [cinsNickName]
	   ,NULL									 AS [cinsPrimaryLanguage]
	   ,NULL									 AS [cinsOtherLanguage]
	   ,CASE
			WHEN ISNULL(n.race, '') <> ''
				THEN (
						SELECT
							RaceID
						FROM sma_mst_ContactRace
						WHERE RaceDesc = r.race_name
					)
			ELSE NULL
		END										 AS cinnrace
	   ,N.[names_id]							 AS saga
	FROM [JohnSalazar_Needles].[dbo].[names] N
	LEFT JOIN [JohnSalazar_Needles].[dbo].[Race] r
		ON r.race_id = n.race
	WHERE N.[person] = 'Y'
GO

---------------------------------------
-- Construct [sma_MST_OrgContacts]
---------------------------------------
INSERT INTO [sma_MST_OrgContacts]
	(
	[consName], [consWorkPhone], [consComments], [connContactCtg], [connContactTypeID], [connRecUserID], [condDtCreated], [conbStatus], [saga]
	)
	SELECT
		N.[last_long_name] AS [consName]
	   ,N.[work_phone]	   AS [consWorkPhone]
	   ,CASE
			WHEN ISNULL(N.[aka_full], '') <> '' AND
				ISNULL(N.[email], '') = ''
				THEN (
					'AKA: ' + N.[aka_full]
					)
			WHEN ISNULL(N.[aka_full], '') = '' AND
				ISNULL(N.[email], '') <> ''
				THEN (
					'EMAIL: ' + N.[email]
					)
			WHEN ISNULL(N.[aka_full], '') <> '' AND
				ISNULL(N.[email], '') <> ''
				THEN (
					'AKA: ' + N.[aka_full] + ' EMAIL: ' + N.[email]
					)
		END				   AS [consComments]
	   ,2				   AS [connContactCtg]
	   ,(
			SELECT
				octnOrigContactTypeID
			FROM.[sma_MST_OriginalContactTypes]
			WHERE octsDscrptn = 'General'
				AND octnContactCtgID = 2
		)				   
		AS [connContactTypeID]
	   ,368				   AS [connRecUserID]
	   ,GETDATE()		   AS [condDtCreated]
	   ,1				   AS [conbStatus]
	   ,	-- Hardcode Status as ACTIVE
		N.[names_id]	   AS [saga]			-- remember the [names].[names_id] number
	FROM [JohnSalazar_Needles].[dbo].[names] N
	WHERE N.[person] <> 'Y'
GO

-----------------------------------------
---- INDIVIDUAL CONTACT CARD FOR STAFF
-----------------------------------------
--INSERT INTO [sma_MST_IndvContacts]
--	(
--	[cinsPrefix], [cinsSuffix], [cinsFirstName], [cinsMiddleName], [cinsLastName], [cinsHomePhone], [cinsWorkPhone], [cinsSSNNo], [cindBirthDate], [cindDateOfDeath], [cinnGender], [cinsMobile], [cinsComments], [cinnContactCtg], [cinnContactTypeID], [cinnRecUserID], [cindDtCreated], [cinbStatus], [cinbPreventMailing], [cinsNickName], [saga], [cinsGrade]				-- remember the [staff_code]
--	)
--	SELECT
--		iu.prefix						  AS [cinsPrefix]
--	   ,iu.suffix						  AS [cinsSuffix]
--	   ,
--		--left(isnull(first_name,dbo.get_firstword(full_name)),30)	as [cinsFirstName],
--		SAFirst							  AS [cinsFirstName]
--	   ,SAMiddle						  AS [cinsmiddleName]
--	   ,
--		--left(isnull(last_name,dbo.get_lastword(full_name)),40)	    as [cinsLastName],
--		SALast							  AS [cinsLastName]
--	   ,NULL							  AS [cinsHomePhone]
--	   ,LEFT(s.phone_number, 20)		  AS [cinsWorkPhone]
--	   ,NULL							  AS [cinsSSNNo]
--	   ,NULL							  AS [cindBirthDate]
--	   ,NULL							  AS [cindDateOfDeath]
--	   ,CASE s.[sex]
--			WHEN 'M'
--				THEN 1
--			WHEN 'F'
--				THEN 2
--			ELSE 0
--		END								  AS [cinnGender]
--	   ,LEFT(s.mobil_phone, 20)			  AS [cinsMobile]
--	   ,NULL							  AS [cinsComments]
--	   ,1								  AS [cinnContactCtg]
--	   ,(
--			SELECT
--				octnOrigContactTypeID
--			FROM sma_MST_OriginalContactTypes
--			WHERE octsDscrptn = 'General'
--				AND octnContactCtgID = 1
--		)								  
--		AS [cinnContactTypeID]
--	   ,368
--	   ,GETDATE()
--	   ,1								  AS [cinbStatus]
--	   ,0
--	   ,CONVERT(VARCHAR(15), s.full_name) AS [cinsNickName]
--	   ,NULL							  AS [saga]
--	   ,staff_code						  AS [cinsGrade] -- Remember it to go to sma_MST_Users
--	--Select *
--	FROM [implementation_users] iu
--	LEFT JOIN [sma_MST_IndvContacts] ind
--		ON iu.StaffCode = ind.cinsGrade
--	LEFT JOIN [JohnSalazar_Needles]..[staff] s
--		ON s.staff_code = iu.StaffCode
--	WHERE cinnContactID IS NULL
--		AND SALoginID <> 'aadmin'

-----------------------------------------
---- EMAILS FOR STAFF
-----------------------------------------
--INSERT INTO [sma_MST_EmailWebsite]
--	(
--	[cewnContactCtgID], [cewnContactID], [cewsEmailWebsiteFlag], [cewsEmailWebSite], [cewbDefault], [cewnRecUserID], [cewdDtCreated], [cewnModifyUserID], [cewdDtModified], [cewnLevelNo], [saga]
--	)
--	SELECT
--		C.cinnContactCtg AS cewnContactCtgID
--	   ,C.cinnContactID	 AS cewnContactID
--	   ,'E'				 AS cewsEmailWebsiteFlag
--	   ,s.email			 AS cewsEmailWebSite
--	   ,NULL			 AS cewbDefault
--	   ,368				 AS cewnRecUserID
--	   ,GETDATE()		 AS cewdDtCreated
--	   ,368				 AS cewnModifyUserID
--	   ,GETDATE()		 AS cewdDtModified
--	   ,NULL
--	   ,1				 AS saga -- indicate email
--	FROM implementation_users iu
--	JOIN [JohnSalazar_Needles]..staff s
--		ON s.staff_code = iu.StaffCode
--	JOIN [sma_MST_IndvContacts] C
--		ON C.cinsGrade = iu.StaffCode
--	WHERE ISNULL(email, '') <> ''

------------------------------------------------------
---- INSERT AADMIN USER IF DOES NOT ALREADY EXIST
------------------------------------------------------
--IF (
--		SELECT
--			COUNT(*)
--		FROM sma_mst_users
--		WHERE usrsLoginID = 'aadmin'
--	)
--	= 0
--BEGIN
--	SET IDENTITY_INSERT sma_mst_users ON

--	INSERT INTO [sma_MST_Users]
--		(
--		usrnUserID, [usrnContactID], [usrsLoginID], [usrsPassword], [usrsBackColor], [usrsReadBackColor], [usrsEvenBackColor], [usrsOddBackColor], [usrnRoleID], [usrdLoginDate], [usrdLogOffDate], [usrnUserLevel], [usrsWorkstation], [usrnPortno], [usrbLoggedIn], [usrbCaseLevelRights], [usrbCaseLevelFilters], [usrnUnsuccesfulLoginCount], [usrnRecUserID], [usrdDtCreated], [usrnModifyUserID], [usrdDtModified], [usrnLevelNo], [usrsCaseCloseColor], [usrnDocAssembly], [usrnAdmin], [usrnIsLocked], [usrbActiveState]
--		)
--		SELECT DISTINCT
--			368		  AS usrnuserid
--		   ,(
--				SELECT
--				TOP 1
--					cinnContactID
--				FROM dbo.sma_MST_IndvContacts
--				WHERE cinsLastName = 'Unassigned'
--					AND cinsFirstName = 'Staff'
--			)		  
--			AS usrnContactID
--		   ,'aadmin'  AS usrsLoginID
--		   ,'2/'	  AS usrsPassword
--		   ,NULL	  AS [usrsBackColor]
--		   ,NULL	  AS [usrsReadBackColor]
--		   ,NULL	  AS [usrsEvenBackColor]
--		   ,NULL	  AS [usrsOddBackColor]
--		   ,33		  AS [usrnRoleID]
--		   ,NULL	  AS [usrdLoginDate]
--		   ,NULL	  AS [usrdLogOffDate]
--		   ,NULL	  AS [usrnUserLevel]
--		   ,NULL	  AS [usrsWorkstation]
--		   ,NULL	  AS [usrnPortno]
--		   ,NULL	  AS [usrbLoggedIn]
--		   ,NULL	  AS [usrbCaseLevelRights]
--		   ,NULL	  AS [usrbCaseLevelFilters]
--		   ,NULL	  AS [usrnUnsuccesfulLoginCount]
--		   ,1		  AS [usrnRecUserID]
--		   ,GETDATE() AS [usrdDtCreated]
--		   ,NULL	  AS [usrnModifyUserID]
--		   ,NULL	  AS [usrdDtModified]
--		   ,NULL	  AS [usrnLevelNo]
--		   ,NULL	  AS [usrsCaseCloseColor]
--		   ,NULL	  AS [usrnDocAssembly]
--		   ,NULL	  AS [usrnAdmin]
--		   ,NULL	  AS [usrnIsLocked]
--		   ,1		  AS [usrbActiveState]
--	SET IDENTITY_INSERT sma_mst_users OFF
--END

------------------------------------------------------
---- INSERT CONVERSION USER IF DOES NOT ALREADY EXIST
------------------------------------------------------
--IF (
--		SELECT
--			COUNT(*)
--		FROM sma_mst_users
--		WHERE usrsLoginID = 'conversion'
--	)
--	= 0
--BEGIN
--	INSERT INTO [sma_MST_Users]
--		(
--		[usrnContactID], [usrsLoginID], [usrsPassword], [usrsBackColor], [usrsReadBackColor], [usrsEvenBackColor], [usrsOddBackColor], [usrnRoleID], [usrdLoginDate], [usrdLogOffDate], [usrnUserLevel], [usrsWorkstation], [usrnPortno], [usrbLoggedIn], [usrbCaseLevelRights], [usrbCaseLevelFilters], [usrnUnsuccesfulLoginCount], [usrnRecUserID], [usrdDtCreated], [usrnModifyUserID], [usrdDtModified], [usrnLevelNo], [usrsCaseCloseColor], [usrnDocAssembly], [usrnAdmin], [usrnIsLocked], [usrbActiveState]
--		)
--		SELECT DISTINCT
--			(
--				SELECT
--				TOP 1
--					cinnContactID
--				FROM dbo.sma_MST_IndvContacts
--				WHERE cinsLastName = 'Unassigned'
--					AND cinsFirstName = 'Staff'
--			)			 
--			AS usrnContactID
--		   ,'conversion' AS usrsLoginID
--		   ,'pass'		 AS usrsPassword
--		   ,NULL		 AS [usrsBackColor]
--		   ,NULL		 AS [usrsReadBackColor]
--		   ,NULL		 AS [usrsEvenBackColor]
--		   ,NULL		 AS [usrsOddBackColor]
--		   ,33			 AS [usrnRoleID]
--		   ,NULL		 AS [usrdLoginDate]
--		   ,NULL		 AS [usrdLogOffDate]
--		   ,NULL		 AS [usrnUserLevel]
--		   ,NULL		 AS [usrsWorkstation]
--		   ,NULL		 AS [usrnPortno]
--		   ,NULL		 AS [usrbLoggedIn]
--		   ,NULL		 AS [usrbCaseLevelRights]
--		   ,NULL		 AS [usrbCaseLevelFilters]
--		   ,NULL		 AS [usrnUnsuccesfulLoginCount]
--		   ,1			 AS [usrnRecUserID]
--		   ,GETDATE()	 AS [usrdDtCreated]
--		   ,NULL		 AS [usrnModifyUserID]
--		   ,NULL		 AS [usrdDtModified]
--		   ,NULL		 AS [usrnLevelNo]
--		   ,NULL		 AS [usrsCaseCloseColor]
--		   ,NULL		 AS [usrnDocAssembly]
--		   ,NULL		 AS [usrnAdmin]
--		   ,NULL		 AS [usrnIsLocked]
--		   ,1			 AS [usrbActiveState]
--END

------------------------------------------------------
---- Add [saga] to [sma_MST_Users] if it does not exist
------------------------------------------------------
--IF NOT EXISTS (
--		SELECT
--			*
--		FROM sys.columns
--		WHERE Name = N'saga'
--			AND Object_ID = OBJECT_ID(N'sma_MST_Users')
--	)
--BEGIN
--	ALTER TABLE [sma_MST_Users] ADD [saga] [VARCHAR](20) NULL;
--END
--GO

-----------------------
---- INSERT USERS
-----------------------

---- Insert data into sma_MST_Users table from implementation_users table
--INSERT INTO [sma_MST_Users]
--	(
--	[usrnContactID],         -- Contact ID
--	[usrsLoginID],           -- Login ID
--	[usrsPassword],          -- Password
--	[usrsBackColor],         -- Background Color
--	[usrsReadBackColor],     -- Read Background Color
--	[usrsEvenBackColor],     -- Even Background Color
--	[usrsOddBackColor],      -- Odd Background Color
--	[usrnRoleID],            -- Role ID
--	[usrdLoginDate],         -- Login Date
--	[usrdLogOffDate],        -- Log Off Date
--	[usrnUserLevel],         -- User Level
--	[usrsWorkstation],       -- Workstation
--	[usrnPortno],            -- Port Number
--	[usrbLoggedIn],          -- Logged In
--	[usrbCaseLevelRights],   -- Case Level Rights
--	[usrbCaseLevelFilters],  -- Case Level Filters
--	[usrnUnsuccesfulLoginCount], -- Unsuccessful Login Count
--	[usrnRecUserID],         -- Record User ID
--	[usrdDtCreated],         -- Date Created
--	[usrnModifyUserID],      -- Modify User ID
--	[usrdDtModified],        -- Date Modified
--	[usrnLevelNo],           -- Level Number
--	[usrsCaseCloseColor],    -- Case Close Color
--	[usrnDocAssembly],       -- Document Assembly
--	[usrnAdmin],             -- Admin
--	[usrnIsLocked],          -- Is Locked
--	[saga],                  -- Staff Code
--	[usrbActiveState],       -- Active State
--	[usrbIsShowInSystem]     -- Show In System
--	)
--	SELECT
--		INDV.cinnContactID					 -- [usrnContactID]
--	   ,STF.SALoginID                      -- [usrsLoginID]
--	   ,'#'								 -- [usrsPassword]
--	   ,NULL                               -- [usrsBackColor]
--	   ,NULL                               -- [usrsReadBackColor]
--	   ,NULL                               -- [usrsEvenBackColor]
--	   ,NULL                               -- [usrsOddBackColor]
--	   ,33                                 -- [usrnRoleID]
--	   ,NULL                               -- [usrdLoginDate]
--	   ,NULL                               -- [usrdLogOffDate]
--	   ,NULL                               -- [usrnUserLevel]
--	   ,NULL                               -- [usrsWorkstation]
--	   ,NULL                               -- [usrnPortno]
--	   ,NULL                               -- [usrbLoggedIn]
--	   ,NULL                               -- [usrbCaseLevelRights]
--	   ,NULL                               -- [usrbCaseLevelFilters]
--	   ,NULL                               -- [usrnUnsuccesfulLoginCount]
--	   ,1                                  -- [usrnRecUserID]
--	   ,GETDATE()                          -- [usrdDtCreated]
--	   ,NULL                               -- [usrnModifyUserID]
--	   ,NULL                               -- [usrdDtModified]
--	   ,NULL                               -- [usrnLevelNo]
--	   ,NULL                               -- [usrsCaseCloseColor]
--	   ,NULL                               -- [usrnDocAssembly]
--	   ,NULL                               -- [usrnAdmin]
--	   ,NULL                               -- [usrnIsLocked]
--	   ,CONVERT(VARCHAR(20), STF.StaffCode) -- [saga]
--	   ,0 AS [usrbActiveState]
--	   ,1 AS [usrbIsShowInSystem]
--	FROM implementation_users STF
--	JOIN sma_MST_IndvContacts INDV
--		ON INDV.cinsGrade = STF.StaffCode
--	LEFT JOIN [sma_MST_Users] u
--		ON u.saga = CONVERT(VARCHAR(20), STF.StaffCode)
--	WHERE u.usrsLoginID IS NULL
--GO

-----------------------------------------------END ADD USERS-----------------------------------------------

--DECLARE @UserID INT

--DECLARE staff_cursor CURSOR FAST_FORWARD FOR SELECT
--	usrnUserID
--FROM sma_mst_users

--OPEN staff_cursor

--FETCH NEXT FROM staff_cursor INTO @UserID

--SET NOCOUNT ON;
--WHILE @@FETCH_STATUS = 0
--BEGIN
---- Print the fetched UserID for debugging
--PRINT 'Fetched UserID: ' + CAST(@UserID AS VARCHAR);

---- Check if @UserID is NULL
--IF @UserID IS NOT NULL
--BEGIN
--	PRINT 'Inserting for UserID: ' + CAST(@UserID AS VARCHAR);

--	INSERT INTO sma_TRN_CaseBrowseSettings
--		(
--		cbsnColumnID, cbsnUserID, cbssCaption, cbsbVisible, cbsnWidth, cbsnOrder, cbsnRecUserID, cbsdDtCreated, cbsn_StyleName
--		)
--		SELECT DISTINCT
--			cbcnColumnID
--		   ,@UserID
--		   ,cbcscolumnname
--		   ,'True'
--		   ,200
--		   ,cbcnDefaultOrder
--		   ,@UserID
--		   ,GETDATE()
--		   ,'Office2007Blue'
--		FROM [sma_MST_CaseBrowseColumns]
--		WHERE cbcnColumnID NOT IN (1, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 33);
--END
--ELSE
--BEGIN
--	-- Log the NULL @UserID occurrence
--	PRINT 'NULL UserID encountered. Skipping insert.';
--END

--FETCH NEXT FROM staff_cursor INTO @UserID;
--END

--CLOSE staff_cursor
--DEALLOCATE staff_cursor



------ Appendix ----
--INSERT INTO Account_UsersInRoles
--	(
--	user_id, role_id
--	)
--	SELECT
--		usrnUserID AS user_id
--	   ,2		   AS role_id
--	FROM sma_MST_Users

--UPDATE sma_MST_Users
--SET usrbActiveState = 1
--WHERE usrsLoginID = 'aadmin'

--UPDATE Account_UsersInRoles
--SET role_id = 1
--WHERE user_id = 368 


