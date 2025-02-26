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
alter table [sma_TRN_ReferredOut] disable trigger all
delete [sma_TRN_ReferredOut]
DBCC CHECKIDENT ('[sma_TRN_ReferredOut]', RESEED, 0);
alter table [sma_TRN_ReferredOut] enable trigger all

select * from [sma_TRN_ReferredOut]
*/

--(1)--
INSERT INTO [sma_TRN_ReferredOut]
	(
	rfosType, rfonCaseID, rfonPlaintiffID, rfonLawFrmContactID, rfonLawFrmAddressID, rfonAttContactID, rfonAttAddressID, rfonGfeeAgreement, rfobMultiFeeStru, rfobComplexFeeStru, rfonReferred, rfonCoCouncil, rfonIsLawFirmUpdateToSend
	)

	SELECT
		'G'			   AS rfosType
	   ,CAS.casnCaseID AS rfonCaseID
	   ,-1			   AS rfonPlaintiffID
	   ,CASE
			WHEN IOC.CTG = 2
				THEN IOC.CID
			ELSE NULL
		END			   AS rfonLawFrmContactID
	   ,CASE
			WHEN IOC.CTG = 2
				THEN IOC.AID
			ELSE NULL
		END			   AS rfonLawFrmAddressID
	   ,CASE
			WHEN IOC.CTG = 1
				THEN IOC.CID
			ELSE NULL
		END			   AS rfonAttContactID
	   ,CASE
			WHEN IOC.CTG = 1
				THEN IOC.AID
			ELSE NULL
		END			   AS rfonAttAddressID
	   ,0			   AS rfonGfeeAgreement
	   ,0			   AS rfobMultiFeeStru
	   ,0			   AS rfobComplexFeeStru
	   ,1			   AS rfonReferred
	   ,0			   AS rfonCoCouncil
	   ,0			   AS rfonIsLawFirmUpdateToSend
	FROM TestNeedles.[dbo].[cases_indexed] C
	JOIN [sma_TRN_cases] CAS
		ON CAS.cassCaseNumber = C.casenum
	JOIN [IndvOrgContacts_Indexed] IOC
		ON IOC.SAGA = C.referred_to_id
			AND C.referred_to_id > 0


--(2)--
UPDATE sma_MST_IndvContacts
SET cinnContactTypeID = (
	SELECT
		octnOrigContactTypeID
	FROM [dbo].[sma_MST_OriginalContactTypes]
	WHERE octsDscrptn = 'Attorney'
)
WHERE cinnContactID IN (
	SELECT
		rfonAttContactID
	FROM sma_TRN_ReferredOut
	WHERE ISNULL(rfonAttContactID, '') <> ''
)


