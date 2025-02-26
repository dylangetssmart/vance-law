USE SANeedlesSLF
GO

/* ####################################
1.0 -- Create PlaintiffInjury records
*/
ALTER TABLE [sma_TRN_PlaintiffInjury] DISABLE TRIGGER ALL
GO

INSERT INTO [sma_TRN_PlaintiffInjury]
	(
	[plinPlaintiffID], [plinCaseID], [plisInjuriesSummary], [plisPleadingsSummary], [plisConfinementHospital], [plisConfinementBed], [plisConfinementHome], [plisConfinementIncapacitated], [plisComment], [plinRecUserID], [plidDtCreated], [plinModifyUserID], [plidDtModified]
	)
	SELECT
		pln.plnnPlaintiffID AS [plinPlaintiffID]
	   ,cas.casnCaseID		AS [plinCaseID]
	   ,ISNULL('Injuries: ' + NULLIF(CONVERT(VARCHAR(MAX), ucd.Injuries), '') + CHAR(13), '') +
		ISNULL('Passenger''s Injuries: ' + NULLIF(CONVERT(VARCHAR(MAX), ucd.Passengers_Injuries), '') + CHAR(13), '') +
		''					AS [plisInjuriesSummary]
	   ,NULL				AS [plisPleadingsSummary]
	   ,NULL				AS [plisConfinementHospital]
	   ,NULL				AS [plisConfinementBed]
	   ,NULL				AS [plisConfinementHome]
	   ,NULL				AS [plisConfinementIncapacitated]
	   ,NULL				AS [plisComment]
	   ,368					AS [plinRecUserID]
	   ,GETDATE()			AS [plidDtCreated]
	   ,NULL				AS [plinModifyUserID]
	   ,NULL				AS [plidDtModified]
	FROM NeedlesSLF..user_case_data ucd
	JOIN sma_trn_Cases cas
		ON cas.cassCaseNumber = CONVERT(VARCHAR, ucd.casenum)
	-- Link to SA Contact Card via:
	-- user_tab_data -> user_tab_name -> names -> IndvOrgContacts_Indexed
	--join NeedlesSLF.dbo.user_case_name ucn
	--	on ucd.casenum = ucn.casenum
	--join NeedlesSLF.dbo.names n
	--	on ucn.user_name = n.names_id
	--left join IndvOrgContacts_Indexed ioci
	--	on n.names_id = ioci.saga
	--	and ioci.CTG = 1
	JOIN [sma_TRN_Plaintiff] pln
		ON pln.plnnCaseID = cas.casnCaseID
	WHERE ISNULL(ucd.Injuries, '') <> ''
		OR ISNULL(ucd.Passengers_Injuries, '') <> ''
GO

ALTER TABLE [sma_TRN_PlaintiffInjury] ENABLE TRIGGER ALL
GO
-- SET IDENTITY_INSERT [sma_TRN_PlaintiffInjury] OFF;
GO


/* ####################################
2.0 -- Populate InjuryDetails.Comments
*/

-- ALTER TABLE [sma_TRN_Injury] DISABLE TRIGGER ALL
-- GO
-- SET IDENTITY_INSERT [sma_TRN_Injury] ON;
-- GO


-- insert into [sma_TRN_Injury]
-- (	
-- 	[injnCaseId]
--     ,[injnPlaintiffId]
--     ,[injnInjuryType]
--     ,[injnBodyPartSide]
--     ,[injnBodyPartID]
--     ,[injnInjuryNameID]
--     ,[injsTreatmentIDS]
--     ,[injsSequaleadIDS]
--     ,[injsDescription]
--     ,[injnDuration]
--     ,[injdInjuryDt]
--     ,[injnBOPInterrogation]
--     ,[injbDocAttached]
--     ,[injnPriority]
--     ,[injsComments]
--     ,[injnRecUserID]
--     ,[injdDtCreated]
--     ,[injnModifyUserID]
--     ,[injdDtModified]
--     ,[injnLevelNo]
--     ,[injnOtherInj]
--     ,[injdDateEstablished]
--     ,[injbConsequential]
--     ,[injsOrigICDs]
--     ,[injnMergeableDescription]
--     ,[injsInjuryNameIDS]
-- )
-- select
--     cas.casnCaseID					as [injnCaseId]
--     ,pln.plnnPlaintiffID			as [injnPlaintiffId]
--     ,1								as [injnInjuryType]
--     ,4								as [injnBodyPartSide]
--     ,null							as [injnBodyPartID]
--     ,null							as [injnInjuryNameID]
--     ,null							as [injsTreatmentIDS]
--     ,null							as [injsSequaleadIDS]
--     ,null							as [injsDescription]
--     ,null							as [injnDuration]
--     ,null							as [injdInjuryDt]
--     ,0								as [injnBOPInterrogation]
--     ,null							as [injbDocAttached]
--     ,null							as [injnPriority]
--     ,ucd.Treatment_Since_Injury		as [injsComments]
--     ,368							as [injnRecUserID]
--     ,GETDATE()						as [injdDtCreated]
--     ,null							as [injnModifyUserID]
--     ,null							as [injdDtModified]
--     ,1								as [injnLevelNo]
--     ,null							as [injnOtherInj]
--     ,null							as [injdDateEstablished]
--     ,0								as [injbConsequential]
--     ,null							as [injsOrigICDs]
--     ,null							as [injnMergeableDescription]
--     ,null							as [injsInjuryNameIDS]
-- FROM NeedlesSLF..user_case_data ucd
-- 	JOIN sma_trn_Cases cas
-- 		on cas.cassCaseNumber = convert(varchar,ucd.casenum)
-- 	-- Link to SA Contact Card via:
-- 	-- user_tab_data -> user_tab_name -> names -> IndvOrgContacts_Indexed
-- 	--join NeedlesSLF.dbo.user_case_name ucn
-- 	--	on ucd.casenum = ucn.casenum
-- 	--join NeedlesSLF.dbo.names n
-- 	--	on ucn.user_name = n.names_id
-- 	--left join IndvOrgContacts_Indexed ioci
-- 	--	on n.names_id = ioci.saga
-- 	--	and ioci.CTG = 1
-- 	join [sma_TRN_Plaintiff] pln
-- 		on pln.plnnCaseID = cas.casnCaseID
-- WHERE isnull(ucd.Treatment_Since_Injury,'')<>''
-- GO

-- ALTER TABLE [sma_TRN_Injury] ENABLE TRIGGER ALL
-- GO
-- SET IDENTITY_INSERT [sma_TRN_Injury] OFF;
-- GO