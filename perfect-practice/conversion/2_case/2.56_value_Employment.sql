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

/* ####################################
Insert Lost Wages
*/
INSERT INTO [sma_TRN_LostWages]
	(
	[ltwnEmploymentID], [ltwsType], [ltwdFrmDt], [ltwdToDt], [ltwnAmount], [ltwnAmtPaid], [ltwnLoss], [Comments], [ltwdMDConfReqDt], [ltwdMDConfDt], [ltwdEmpVerfReqDt], [ltwdEmpVerfRcvdDt], [ltwnRecUserID], [ltwdDtCreated], [ltwnModifyUserID], [ltwdDtModified], [ltwnLevelNo]
	)
	SELECT DISTINCT
		e.empnEmploymentID AS [ltwnEmploymentID]		--sma_trn_employment ID
	   ,(
			SELECT
				wgtnWagesTypeID
			FROM [sma_MST_WagesTypes]
			WHERE wgtsDscrptn = 'Salary'
		)				   
		AS [ltwsType]   			--[sma_MST_WagesTypes].wgtnWagesTypeID
		-- ,case
		-- 	when ud.Last_Date_Worked between '1/1/1900' and '6/6/2079'
		-- 		then ud.Last_Date_Worked
		-- 	else null 
		-- 	end					as [ltwdFrmDt]
		-- ,case
		-- 	when ud.Returned_to_Work between '1/1/1900' and '6/6/2079'
		-- 		then ud.Returned_to_Work 
		-- 	when isdate(ud.returntowork) = 1 and ud.returntowork between '1/1/1900' and '6/6/2079'
		-- 		then ud.returntowork 
		-- 	else null
		-- 	end					as [ltwdToDt]
	   ,NULL			   AS [ltwdFrmDt]
	   ,NULL			   AS [ltwdToDt]
	   ,NULL			   AS [ltwnAmount]
	   ,NULL			   AS [ltwnAmtPaid]
	   ,v.total_value	   AS [ltwnLoss]
		-- ,isnull('Return to work: ' + nullif(convert(Varchar,ud.returntowork),'') + char(13),'') +
		-- ''						as [comments]
	   ,NULL			   AS [comments]
	   ,NULL			   AS [ltwdMDConfReqDt]
	   ,NULL			   AS [ltwdMDConfDt]
	   ,NULL			   AS [ltwdEmpVerfReqDt]
	   ,NULL			   AS [ltwdEmpVerfRcvdDt]
	   ,368				   AS [ltwnRecUserID]
	   ,GETDATE()		   AS [ltwdDtCreated]
	   ,NULL			   AS [ltwnModifyUserID]
	   ,NULL			   AS [ltwdDtModified]
	   ,NULL			   AS [ltwnLevelNo]
	-- employment record id: case > plaintiff > employment (value has caseid)
	FROM NeedlesSLF..value_indexed v
	JOIN sma_trn_Cases cas
		ON cas.cassCaseNumber = v.case_id
	JOIN sma_trn_plaintiff p
		ON p.plnnCaseID = cas.casnCaseID
			AND p.plnbIsPrimary = 1
	INNER JOIN sma_TRN_Employment e
		ON e.empnPlaintiffID = p.plnnPlaintiffID
	WHERE v.code = 'LWG'

-- FROM NeedlesSLF..user_tab4_data ud
-- JOIN EmployerTemp et on et.employer = ud.employer and et.employer_address = ud.Employer_Address
-- JOIN IndvOrgContacts_Indexed ioc on ioc.SAGA = et.empID and ioc.[Name] = et.employer
-- JOIN [sma_TRN_Employment] e on  e.empnPlaintiffID = p.plnnPlaintiffID and empnEmployerID = ioc.CID


---------------------------------------
-- Update Special Damages
---------------------------------------
ALTER TABLE [sma_TRN_SpDamages] DISABLE TRIGGER ALL
GO

INSERT INTO [sma_TRN_SpDamages]
	(
	[spdsRefTable], [spdnRecordID], [spdnRecUserID], [spddDtCreated], [spdnLevelNo], spdnBillAmt, spddDateFrom, spddDateTo
	)
	SELECT DISTINCT
		'LostWages'		   AS spdsRefTable
	   ,lw.ltwnLostWagesID AS spdnRecordID
	   ,lw.ltwnRecUserID   AS [spdnRecUserID]
	   ,lw.ltwdDtCreated   AS spddDtCreated
	   ,NULL			   AS [spdnLevelNo]
	   ,lw.[ltwnLoss]	   AS spdnBillAmt
	   ,lw.ltwdFrmDt	   AS spddDateFrom
	   ,lw.ltwdToDt		   AS spddDateTo
	FROM sma_TRN_LostWages LW


ALTER TABLE [sma_TRN_SpDamages] ENABLE TRIGGER ALL
GO
