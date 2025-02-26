USE SANeedlesSLF
go

ALTER TABLE [SANeedlesSLF].[dbo].[sma_TRN_CaseWitness] DISABLE TRIGGER ALL
go

----(1)----
INSERT INTO [SANeedlesSLF].[dbo].[sma_TRN_CaseWitness]
	(
	[witnCaseID], [witnWitnesContactID], [witnWitnesAdID], [witnRoleID], [witnFavorable], [witnTestify], [witdStmtReqDate], [witdStmtDate], [witbHasRec], [witsDoc], [witsComment], [witnRecUserID], [witdDtCreated], [witnModifyUserID], [witdDtModified], [witnLevelNo]
	)

	SELECT DISTINCT
		c.casnCaseID AS [witnCaseID]
	   ,ioc.CID		 AS [witnWitnesContactID]
	   ,ioc.AID		 AS [witnWitnesAdID]
	   ,NULL		 AS [witnRoleID]
	   ,NULL		 AS [witnFavorable]
	   ,NULL		 AS [witnTestify]
	   ,NULL		 AS [witdStmtReqDate]
	   ,NULL		 AS [witdStmtDate]
	   ,NULL		 AS [witbHasRec]
	   ,NULL		 AS [witsDoc]
	   ,NULL		 AS [witsComment]
	   ,368			 AS [witnRecUserID]
	   ,GETDATE()	 AS [witdDtCreated]
	   ,NULL		 AS [witnModifyUserID]
	   ,NULL		 AS [witdDtModified]
	   ,NULL		 AS [witnLevelNo]
	FROM NeedlesSLF..user_party_data upd
	JOIN SANeedlesSLF..IndvOrgContacts_Indexed ioc
		ON ioc.saga = upd.case_id
	INNER JOIN SANeedlesSLF..sma_MST_IndvContacts ic
		ON ic.cinnContactID = ioc.CID
			AND ic.saga_ref = 'witness'
	JOIN SANeedlesSLF..sma_TRN_Cases c
		ON c.cassCaseNumber = CONVERT(VARCHAR, upd.case_id)
	WHERE ISNULL(upd.Witness_1, '') <> ''
		OR ISNULL(upd.Witness_2, '') <> ''
		OR ISNULL(upd.Witness_3, '') <> ''
GO

ALTER TABLE [SANeedlesSLF].[dbo].[sma_TRN_CaseWitness] ENABLE TRIGGER ALL
go
