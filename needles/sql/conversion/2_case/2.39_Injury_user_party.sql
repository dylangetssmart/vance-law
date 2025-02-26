use JoelBieberSA_Needles
go
	
alter table [sma_TRN_PlaintiffInjury] disable trigger all
go

-------------------------------------------------------------------------------
-- Insert Injuries Summary
-------------------------------------------------------------------------------

insert into [sma_TRN_PlaintiffInjury]
	(
	[plinPlaintiffID],
	[plinCaseID],
	[plisInjuriesSummary],
	[plisPleadingsSummary],
	[plisConfinementHospital],
	[plisConfinementBed],
	[plisConfinementHome],
	[plisConfinementIncapacitated],
	[plisComment],
	[plinRecUserID],
	[plidDtCreated],
	[plinModifyUserID],
	[plidDtModified]
	)
	select
		pln.plnnPlaintiffID as [plinplaintiffid],
		cas.casnCaseID		as [plincaseid],
		ISNULL('Injuries: ' + NULLIF(CONVERT(VARCHAR(MAX), upd.Injuries), '') + CHAR(13), '') +
		ISNULL('Current Injuries: ' + NULLIF(CONVERT(VARCHAR(MAX), upd.current_Injuries), '') + CHAR(13), '') +
		ISNULL('Current Inj: ' + NULLIF(CONVERT(VARCHAR(MAX), upd.CURRENT_INJ), '') + CHAR(13), '') +
		''					as [plisinjuriessummary],
		null				as [plispleadingssummary],
		null				as [plisconfinementhospital],
		null				as [plisconfinementbed],
		null				as [plisconfinementhome],
		null				as [plisconfinementincapacitated],
		null				as [pliscomment],
		368					as [plinrecuserid],
		GETDATE()			as [pliddtcreated],
		null				as [plinmodifyuserid],
		null				as [pliddtmodified]
	--select *
	from JoelBieberNeedles..user_party_data upd
	join sma_trn_Cases cas
		on cas.cassCaseNumber = CONVERT(VARCHAR, upd.case_id)
	join [sma_TRN_Plaintiff] pln
		on pln.plnnCaseID = cas.casnCaseID
	where ISNULL(upd.Injuries, '') <> ''
		or ISNULL(upd.Current_Injuries, '') <> ''
		or ISNULL(upd.CURRENT_INJ, '') <> ''
go

alter table [sma_TRN_PlaintiffInjury] enable trigger all
go


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