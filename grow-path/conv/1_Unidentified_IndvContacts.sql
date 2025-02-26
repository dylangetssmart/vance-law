/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create placeholder individual contacts used as fallback when contact records do not exist

1 - Unassigned Staff
2 - Unidentified Individual
3 - Unidentified Plaintiff
4 - Unidentified Defendant

##########################################################################################################################
*/

USE JoelBieberSA
GO

ALTER TABLE sma_MST_IndvContacts DISABLE TRIGGER ALL
GO

---------------------------------------------------
-- [1] Unassigned Staff
---------------------------------------------------
IF NOT EXISTS (
		SELECT
			*
		FROM sma_MST_IndvContacts
		WHERE [cinsFirstName] = 'Staff'
			AND [cinsLastName] = 'Unassigned'
	)
BEGIN
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
	   ,[saga]
	   ,[cinsSpouse]
	   ,[cinsGrade]
		)

		SELECT
			1
		   ,10
		   ,NULL
		   ,'Mr.'
		   ,'Staff'
		   ,''
		   ,'Unassigned'
		   ,NULL
		   ,NULL
		   ,1
		   ,NULL
		   ,NULL
		   ,NULL
		   ,1
		   ,''
		   ,''
		   ,NULL
		   ,''
		   ,''
		   ,1
		   ,''
		   ,1
		   ,1
		   ,NULL
		   ,NULL
		   ,''
		   ,''
		   ,NULL
		   ,0
		   ,368
		   ,GETDATE()
		   ,''
		   ,NULL
		   ,0
		   ,''
		   ,''
		   ,''
		   ,''
		   ,NULL + NULL
		   ,NULL
		   ,''
		   ,NULL
		   ,''
		   ,''
		   ,''
		   ,''
		   ,''
		   ,''
		   ,NULL
END

---------------------------------------------------
-- [2] Unidentified Individual
---------------------------------------------------
IF NOT EXISTS (
		SELECT
			*
		FROM sma_MST_IndvContacts
		WHERE [cinsFirstName] = 'Individual'
			AND [cinsLastName] = 'Unidentified'
	)
BEGIN
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
	   ,[saga]
	   ,[cinsSpouse]
	   ,[cinsGrade]
		)

		SELECT
			1
		   ,10
		   ,NULL
		   ,'Mr.'
		   ,'Individual'
		   ,''
		   ,'Unidentified'
		   ,NULL
		   ,NULL
		   ,1
		   ,NULL
		   ,NULL
		   ,NULL
		   ,1
		   ,''
		   ,''
		   ,NULL
		   ,''
		   ,''
		   ,1
		   ,''
		   ,1
		   ,1
		   ,NULL
		   ,NULL
		   ,''
		   ,''
		   ,NULL
		   ,0
		   ,368
		   ,GETDATE()
		   ,''
		   ,NULL
		   ,0
		   ,''
		   ,''
		   ,''
		   ,''
		   ,NULL + NULL
		   ,NULL
		   ,''
		   ,NULL
		   ,''
		   ,''
		   ,''
		   ,'Unknown'
		   ,''
		   ,'Doe'
		   ,NULL
END

---------------------------------------------------
-- [3] Unidentified Plaintiff
---------------------------------------------------
IF NOT EXISTS (
		SELECT
			*
		FROM sma_MST_IndvContacts
		WHERE [cinsFirstName] = 'Plaintiff'
			AND [cinsLastName] = 'Unidentified'
	)
BEGIN
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
	   ,[saga]
	   ,[cinsSpouse]
	   ,[cinsGrade]
		)

		SELECT
			1
		   ,10
		   ,NULL
		   ,''
		   ,'Plaintiff'
		   ,''
		   ,'Unidentified'
		   ,NULL
		   ,NULL
		   ,1
		   ,NULL
		   ,NULL
		   ,NULL
		   ,1
		   ,''
		   ,''
		   ,NULL
		   ,''
		   ,''
		   ,1
		   ,''
		   ,1
		   ,1
		   ,NULL
		   ,NULL
		   ,''
		   ,''
		   ,NULL
		   ,0
		   ,368
		   ,GETDATE()
		   ,''
		   ,NULL
		   ,0
		   ,''
		   ,''
		   ,''
		   ,''
		   ,NULL + NULL
		   ,NULL
		   ,''
		   ,NULL
		   ,''
		   ,''
		   ,''
		   ,''
		   ,''
		   ,''
		   ,NULL
END

---------------------------------------------------
-- [4] Unidentified Defendant
---------------------------------------------------
IF NOT EXISTS (
		SELECT
			*
		FROM sma_MST_IndvContacts
		WHERE [cinsFirstName] = 'Defendant'
			AND [cinsLastName] = 'Unidentified'
	)
BEGIN
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
	   ,[saga]
	   ,[cinsSpouse]
	   ,[cinsGrade]
		)

		SELECT DISTINCT
			1
		   ,10
		   ,NULL
		   ,''
		   ,'Defendant'
		   ,''
		   ,'Unidentified'
		   ,NULL
		   ,NULL
		   ,1
		   ,NULL
		   ,NULL
		   ,NULL
		   ,1
		   ,''
		   ,''
		   ,NULL
		   ,''
		   ,''
		   ,1
		   ,''
		   ,1
		   ,1
		   ,NULL
		   ,NULL
		   ,''
		   ,''
		   ,NULL
		   ,0
		   ,368
		   ,GETDATE()
		   ,''
		   ,NULL
		   ,0
		   ,''
		   ,''
		   ,''
		   ,''
		   ,NULL + NULL
		   ,NULL
		   ,''
		   ,NULL
		   ,''
		   ,''
		   ,''
		   ,''
		   ,''
		   ,''
		   ,NULL
END
GO