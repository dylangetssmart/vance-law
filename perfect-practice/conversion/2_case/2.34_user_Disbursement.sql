USE SANeedlesSLF
GO

/* ########################################################
8/2/2024 - Create disbursements from user_tab_data.Firm_Expenses
*/

-- 1) Create disbursement type
INSERT INTO [sma_MST_DisbursmentType]
	(
	disnTypeCode, dissTypeName
	)
VALUES (
NULL
, 'Firm Expenses'
)

-- 2) Create Disbursements
ALTER TABLE [sma_TRN_Disbursement] DISABLE TRIGGER ALL

INSERT INTO [sma_TRN_Disbursement]
	(
	disnCaseID, disdCheckDt, disnPayeeContactCtgID, disnPayeeContactID, disnAmount, disnPlaintiffID, dissDisbursementType, UniquePayeeID, dissDescription, dissComments, disnCheckRequestStatus, disdBillDate, disdDueDate, disnRecUserID, disdDtCreated, disnRecoverable, saga
	)
	SELECT
		cas.casnCaseID					AS disnCaseID
	   ,NULL							AS disdCheckDt
	   ,NULL							AS disnPayeeContactCtgID
	   ,NULL							AS disnPayeeContactID
	   ,d.Firm_Expenses					AS disnAmount
	   ,pln.plnnPlaintiffID				AS disnPlaintiffID
	   ,(
			SELECT
				disnTypeID
			FROM [sma_MST_DisbursmentType]
			WHERE dissTypeName = 'Firm Expenses'
		)								
		AS dissDisbursementType
	   ,NULL							AS UniquePayeeID
	   ,NULL							AS dissDescription
	   ,'user_tab_data > Firm Expenses' AS dissComments
	   ,(
			SELECT
				Id
			FROM [sma_MST_CheckRequestStatus]
			WHERE [Description] = 'Review'
		)								
		AS disnCheckRequestStatus
	   ,NULL							AS disdBillDate
	   ,NULL							AS disdDueDate
	   ,368								AS disnRecUserID
	   ,GETDATE()						AS disdDtCreated
	   ,0								AS disnRecoverable
	   ,d.case_id						AS saga
	FROM [NeedlesSLF].[dbo].[user_tab_data] d
	JOIN sma_trn_cases cas
		ON cas.cassCaseNumber = d.case_id
	JOIN sma_TRN_Plaintiff pln
		ON cas.casnCaseID = pln.plnnCaseID
	WHERE ISNULL(d.Firm_Expenses, 0) <> 0
GO

ALTER TABLE [sma_TRN_Disbursement] ENABLE TRIGGER ALL


--SELECT
--	stlnGrossAttorneyFee
--   ,stlnCBAFee
--   ,stlnOther
--   ,stlnForwarder
--FROM sma_TRN_Settlements