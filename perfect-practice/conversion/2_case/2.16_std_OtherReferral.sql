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
alter table [sma_TRN_OtherReferral] disable trigger all
delete [sma_TRN_OtherReferral]
DBCC CHECKIDENT ('[sma_TRN_OtherReferral]', RESEED, 0);
alter table [sma_TRN_OtherReferral] enable trigger all
*/

--(1)--

INSERT INTO [sma_TRN_OtherReferral]
	(
	[otrnCaseID], [otrnRefContactCtg], [otrnRefContactID], [otrnRefAddressID], [otrnPlaintiffID], [otrsComments], [otrnUserID], [otrdDtCreated]
	)
	SELECT
		CAS.casnCaseID AS [otrnCaseID]
	   ,IOC.CTG		   AS [otrnRefContactCtg]
	   ,IOC.CID		   AS [otrnRefContactID]
	   ,IOC.AID		   AS [otrnRefAddressID]
	   ,-1			   AS [otrnPlaintiffID]
	   ,NULL		   AS [otrsComments]
	   ,368			   AS [otrnUserID]
	   ,GETDATE()	   AS [otrdDtCreated]
	FROM TestNeedles.[dbo].[cases_indexed] C
	JOIN [sma_TRN_cases] CAS
		ON CAS.cassCaseNumber = C.casenum
	JOIN [IndvOrgContacts_Indexed] IOC
		ON IOC.SAGA = C.referred_link
			AND C.referred_link > 0
