USE SANeedlesSLF
GO
/*
alter table [dbo].[sma_TRN_Employment] disable trigger all
delete from [dbo].[sma_TRN_Employment] 
DBCC CHECKIDENT ('[dbo].[sma_TRN_Employment]', RESEED, 0);
alter table [dbo].[sma_TRN_Employment] enable trigger all
*/

--sp_help [sma_TRN_Employment]

ALTER TABLE sma_TRN_Employment
ALTER COLUMN [empsJobTitle] VARCHAR(500)
GO


/* ####################################
1.0 -- From user_tab_data
*/

INSERT INTO [dbo].[sma_TRN_Employment]
	(
	[empnPlaintiffID], [empnEmprAddressID], [empnEmployerID], [empnContactPersonID], [empnCPAddressId], [empsJobTitle], [empnSalaryFreqID], [empnSalaryAmt], [empnCommissionFreqID], [empnCommissionAmt], [empnBonusFreqID], [empnBonusAmt], [empnOverTimeFreqID], [empnOverTimeAmt], [empnOtherFreqID], [empnOtherCompensationAmt], [empsComments], [empbWorksOffBooks], [empsCompensationComments], [empbWorksPartiallyOffBooks], [empbOnTheJob], [empbWCClaim], [empbContinuing], [empdDateHired], [empnUDF1], [empnUDF2], [empnRecUserID], [empdDtCreated], [empnModifyUserID], [empdDtModified], [empnLevelNo], [empnauthtodefcoun], [empnauthtodefcounDt], [empnTotalDisability], [empnAverageWeeklyWage], [empnEmpUnion], [NotEmploymentReasonID], [empdDateTo], [empsDepartment], [empdSent], [empdReceived], [empnStatusId], [empnWorkSiteId]
	)
	SELECT
		(
			SELECT
				plnnPlaintiffID
			FROM sma_trn_plaintiff
			WHERE plnnCaseID = cas.casncaseid
				AND plnbIsPrimary = 1
		)						   
		AS [empnPlaintiffID]		--Plaintiff ID
	   ,A.addnAddressID			   AS [empnEmprAddressID]		--employer org AID
	   ,org.connContactID		   AS [empnEmployerID]			--employer org CID
	   ,NULL					   AS [empnContactPersonID]	--indv CID
	   ,NULL					   AS [empnCPAddressId]		--indv AID
	   ,NULL					   AS [empsJobTitle]			--ds 6/6/2024 - Job Title
	   ,(
			SELECT
				fqmnFrequencyID
			FROM sma_MST_Frequencies
			WHERE fqmsCode = 'AN'
		)						   
		AS [empnSalaryFreqID]		--ds 6/6/2024 - Salary Frequency -> sma_mst_frequencies.fqmnFrequencyID
	   ,ud.Annual_Income_Plaintiff AS [empnSalaryAmt]			--ds 6/6/2024 - Salary Amount
	   ,NULL					   AS [empnCommissionFreqID]	--Commission: (frequency)  sma_mst_frequencies.fqmnFrequencyID
	   ,NULL					   AS [empnCommissionAmt]		--Commission Amount
	   ,NULL					   AS [empnBonusFreqID]		--Bonus: (frequency)  sma_mst_frequencies.fqmnFrequencyID
	   ,NULL					   AS [empnBonusAmt]			--Bonus Amount
	   ,NULL					   AS [empnOverTimeFreqID]	--Overtime (frequency)  sma_mst_frequencies.fqmnFrequencyID
	   ,NULL					   AS [empnOverTimeAmt]		--Overtime Amoun
	   ,NULL					   AS [empnOtherFreqID]		--Other Compensation (frequency)  sma_mst_frequencies.fqmnFrequencyID
	   ,NULL					   AS [empnOtherCompensationAmt]	--Other Compensation Amount
	   ,NULL					   AS [empsComments]
	   ,NULL					   AS [empbWorksOffBooks]
	   ,NULL					   AS empsCompensationComments			-- Compensation Comments
	   ,NULL					   AS [empbWorksPartiallyOffBooks]	--bit
	   ,NULL					   AS [empbOnTheJob]				--On the job injury? bit
	   ,NULL					   AS [empbWCClaim]				--W/C Claim?  bit
	   ,NULL					   AS [empbContinuing]			--continuing?  bit
	   ,NULL					   AS [empdDateHired]				-- ds 6/6/2024 - Date From
	   ,NULL					   AS [empnUDF1]
	   ,NULL					   AS [empnUDF2]
	   ,368						   AS [empnRecUserID]
	   ,GETDATE()				   AS [empdDtCreated]
	   ,NULL					   AS [empnModifyUserID]
	   ,NULL					   AS [empdDtModified]
	   ,NULL					   AS [empnLevelNo]
	   ,NULL					   AS [empnauthtodefcoun]		--Auth. to defense cousel:  bit
	   ,NULL					   AS [empnauthtodefcounDt]	--Auth. to defense cousel:  date
	   ,NULL					   AS [empnTotalDisability]	--Temporary Total Disability (TTD)
	   ,NULL					   AS [empnAverageWeeklyWage]		--Average weekly wage (AWW)
	   ,NULL					   AS [empnEmpUnion]			--Unique Contact ID of Union
	   ,NULL					   AS [NotEmploymentReasonID]		--1=Minor; 2=Retired; 3=Unemployed; (MST?)
	   ,NULL					   AS [empdDateTo]			--ds 6/6/2024 - Date To
	   ,NULL					   AS [empsDepartment]		--Department
	   ,NULL					   AS [empdSent]			--emp verification request sent
	   ,NULL					   AS [empdReceived]		--emp verification request received
	   ,NULL					   AS [empnStatusId]		--status  sma_MST_EmploymentStatuses.ID
	   ,NULL					   AS [empnWorkSiteId]

	FROM NeedlesSLF..user_party_data ud

	INNER JOIN SANeedlesSLF..Employer_Address_Helper help
		ON help.case_id = ud.case_id
			AND help.party_id = ud.party_id

	JOIN sma_MST_OrgContacts org
		ON org.saga = ud.case_id
			AND org.saga_ref = 'upd_employer'

	-- join Employer_Address_Helper help
	-- 	on help.case_id = upd.case_id
	-- 	and help.party_id = upd.party_id

	JOIN sma_trn_Cases cas
		ON cas.cassCaseNumber = CONVERT(VARCHAR, ud.case_id)

	-- Link to SA Contact Card via:
	-- user_tab_data -> user_tab_name -> names -> IndvOrgContacts_Indexed
	-- join NeedlesSLF.dbo.user_tab_name utn
	-- 	on ud.tab_id = utn.tab_id
	-- join NeedlesSLF.dbo.names n
	-- 	on utn.user_name = n.names_id


	JOIN SANeedlesSLF..sma_MST_Address A
		ON A.addnContactID = org.connContactID
			AND a.addnContactCtgID = org.connContactCtg


-- from NeedlesSLF..user_party_data upd
-- join sma_MST_OrgContacts org
-- 	on org.saga = upd.case_id
-- 	and org.saga_ref = 'upd_employer'

-- -- Indv
-- left join SANeedlesSLF.dbo.IndvOrgContacts_Indexed ioci
-- 	on n.names_id = ioci.saga
-- 	and ioci.CTG = 1

-- -- Org
-- left join SANeedlesSLF.dbo.IndvOrgContacts_Indexed ioco
-- 	on n.names_id = ioco.saga
-- 	and ioco.CTG = 2

--WHERE isnull(ud.Annual_Income_Plaintiff,'')<>''
GO



-- /* ####################################
-- Insert Lost Wages
-- */
-- INSERT INTO [sma_TRN_LostWages]
-- 	(
-- 	[ltwnEmploymentID], [ltwsType], [ltwdFrmDt], [ltwdToDt], [ltwnAmount], [ltwnAmtPaid], [ltwnLoss], [Comments], [ltwdMDConfReqDt], [ltwdMDConfDt], [ltwdEmpVerfReqDt], [ltwdEmpVerfRcvdDt], [ltwnRecUserID], [ltwdDtCreated], [ltwnModifyUserID], [ltwdDtModified], [ltwnLevelNo]
-- 	)
-- 	SELECT DISTINCT
-- 		e.empnEmploymentID AS [ltwnEmploymentID]		--sma_trn_employment ID
-- 	   ,(
-- 			SELECT
-- 				wgtnWagesTypeID
-- 			FROM [sma_MST_WagesTypes]
-- 			WHERE wgtsDscrptn = 'Salary'
-- 		)				   
-- 		AS [ltwsType]   			--[sma_MST_WagesTypes].wgtnWagesTypeID
-- 		-- ,case
-- 		-- 	when ud.Last_Date_Worked between '1/1/1900' and '6/6/2079'
-- 		-- 		then ud.Last_Date_Worked
-- 		-- 	else null 
-- 		-- 	end					as [ltwdFrmDt]
-- 		-- ,case
-- 		-- 	when ud.Returned_to_Work between '1/1/1900' and '6/6/2079'
-- 		-- 		then ud.Returned_to_Work 
-- 		-- 	when isdate(ud.returntowork) = 1 and ud.returntowork between '1/1/1900' and '6/6/2079'
-- 		-- 		then ud.returntowork 
-- 		-- 	else null
-- 		-- 	end					as [ltwdToDt]
-- 	   ,NULL			   AS [ltwdFrmDt]
-- 	   ,NULL			   AS [ltwdToDt]
-- 	   ,NULL			   AS [ltwnAmount]
-- 	   ,NULL			   AS [ltwnAmtPaid]
-- 	   ,v.total_value	   AS [ltwnLoss]
-- 		-- ,isnull('Return to work: ' + nullif(convert(Varchar,ud.returntowork),'') + char(13),'') +
-- 		-- ''						as [comments]
-- 	   ,NULL			   AS [comments]
-- 	   ,NULL			   AS [ltwdMDConfReqDt]
-- 	   ,NULL			   AS [ltwdMDConfDt]
-- 	   ,NULL			   AS [ltwdEmpVerfReqDt]
-- 	   ,NULL			   AS [ltwdEmpVerfRcvdDt]
-- 	   ,368				   AS [ltwnRecUserID]
-- 	   ,GETDATE()		   AS [ltwdDtCreated]
-- 	   ,NULL			   AS [ltwnModifyUserID]
-- 	   ,NULL			   AS [ltwdDtModified]
-- 	   ,NULL			   AS [ltwnLevelNo]
-- 	-- employment record id: case > plaintiff > employment (value has caseid)
-- 	FROM NeedlesSLF..value_indexed v
-- 	JOIN sma_trn_Cases cas
-- 		ON cas.cassCaseNumber = v.case_id
-- 	JOIN sma_trn_plaintiff p
-- 		ON p.plnnCaseID = cas.casnCaseID
-- 			AND p.plnbIsPrimary = 1
-- 	INNER JOIN sma_TRN_Employment e
-- 		ON e.empnPlaintiffID = p.plnnPlaintiffID
-- 	WHERE v.code = 'LWG'

-- -- FROM NeedlesSLF..user_tab4_data ud
-- -- JOIN EmployerTemp et on et.employer = ud.employer and et.employer_address = ud.Employer_Address
-- -- JOIN IndvOrgContacts_Indexed ioc on ioc.SAGA = et.empID and ioc.[Name] = et.employer
-- -- JOIN [sma_TRN_Employment] e on  e.empnPlaintiffID = p.plnnPlaintiffID and empnEmployerID = ioc.CID


-- ---------------------------------------
-- -- Update Special Damages
-- ---------------------------------------
-- ALTER TABLE [sma_TRN_SpDamages] DISABLE TRIGGER ALL
-- GO

-- INSERT INTO [sma_TRN_SpDamages]
-- 	(
-- 	[spdsRefTable], [spdnRecordID], [spdnRecUserID], [spddDtCreated], [spdnLevelNo], spdnBillAmt, spddDateFrom, spddDateTo
-- 	)
-- 	SELECT DISTINCT
-- 		'LostWages'		   AS spdsRefTable
-- 	   ,lw.ltwnLostWagesID AS spdnRecordID
-- 	   ,lw.ltwnRecUserID   AS [spdnRecUserID]
-- 	   ,lw.ltwdDtCreated   AS spddDtCreated
-- 	   ,NULL			   AS [spdnLevelNo]
-- 	   ,lw.[ltwnLoss]	   AS spdnBillAmt
-- 	   ,lw.ltwdFrmDt	   AS spddDateFrom
-- 	   ,lw.ltwdToDt		   AS spddDateTo
-- 	FROM sma_TRN_LostWages LW


-- ALTER TABLE [sma_TRN_SpDamages] ENABLE TRIGGER ALL
-- GO
