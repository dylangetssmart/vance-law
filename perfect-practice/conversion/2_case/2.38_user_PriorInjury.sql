USE SANeedlesSLF
GO

/* ####################################
1.0 -- Prior/Subsequent Injuries
*/

ALTER TABLE sma_TRN_PriorInjuries DISABLE TRIGGER ALL
GO

INSERT INTO sma_TRN_PriorInjuries
	(
	[prlnInjuryID], [prldPrAccidentDt], [prldDiagnosis], [prlsDescription], [prlsComments], [prlnPlaintiffID], [prlnCaseID], [prlnInjuryType], [prlnParentInjuryID], [prlsInjuryDesc], [prlnRecUserID], [prldDtCreated], [prlnModifyUserID], [prldDtModified], [prlnLevelNo], [prlbCaseRelated], [prlbFirmCase], [prlsPrCaseNo], [prlsInjury]
	)
	SELECT
		NULL								  AS [prlnInjuryID]
	   ,NULL								  AS [prldPrAccidentDt]
	   ,NULL								  AS [prldDiagnosis]
	   ,NULL								  AS [prlsDescription]
	   ,NULL								  AS [prlsComments]
	   ,pln.plnnContactID					  AS [prlnPlaintiffID]
	   ,cas.casnCaseID						  AS [prlnCaseID]
	   ,3									  AS [prlnInjuryType]
	   ,NULL								  AS [prlnParentInjuryID]
	   ,NULL								  AS [prlsInjuryDesc]
	   ,368									  AS [prlnRecUserID]
	   ,GETDATE()							  AS [prldDtCreated]
	   ,NULL								  AS [prlnModifyUserID]
	   ,NULL								  AS [prldDtModified]
	   ,1									  AS [prlnLevelNo]
	   ,0									  AS [prlbCaseRelated]
	   ,0									  AS [prlbFirmCase]
	   ,NULL								  AS [prlsPrCaseNo]
	   ,'Prior Injuries:' + ud.prior_injuries AS [prlsInjury]
	FROM NeedlesSLF..user_case_data ud
	JOIN sma_TRN_Cases cas
		ON cas.cassCaseNumber = ud.casenum
	JOIN sma_TRN_Plaintiff pln
		ON pln.plnnCaseID = cas.casnCaseID
	WHERE ISNULL(ud.Prior_Injuries, '') <> ''

ALTER TABLE sma_TRN_PriorInjuries ENABLE TRIGGER ALL
GO