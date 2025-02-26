USE SANeedlesSLF
GO

/* ####################################
1.0 -- School/OtherActivities
*/

-- 1.2 Create Grades that don't currently exist
ALTER TABLE [sma_MST_Grades] DISABLE TRIGGER ALL
GO

INSERT INTO [sma_MST_Grades]
	(
	[grdsCode], [grdsDescription], [grdnRecUserID], [grddDtCreated], [grdnModifyUserID], [grddDtModified], [grdnLevelNo]
	)
	SELECT DISTINCT
		NULL		 AS [grdsCode]
	   ,ud.Education AS [grdsDescription]
	   ,368			 AS [grdnRecUserID]
	   ,GETDATE()	 AS [grddDtCreated]
	   ,NULL		 AS [grdnModifyUserID]
	   ,NULL		 AS [grddDtModified]
	   ,NULL		 AS [grdnLevelNo]
	FROM [NeedlesSLF].[dbo].[user_party_data] ud
	WHERE ISNULL(ud.Education, '') <> ''
		AND NOT EXISTS (
			SELECT
				1
			FROM [SANeedlesSLF].[dbo].[sma_MST_Grades] g
			WHERE g.grdsDescription = ud.Education
		);
ALTER TABLE [sma_MST_Grades] ENABLE TRIGGER ALL
GO

GO

-- 1.3 Add school records
ALTER TABLE [sma_TRN_SchoolOthAct] DISABLE TRIGGER ALL
GO

INSERT INTO [sma_TRN_SchoolOthAct]
	(
	[schnCaseID], [schnPlaintiffID], [schsType], [schdFromDate], [schdToDate], [schnDays], [schnActivityID], [schnOrgContactID], [schnOrgAddressID], [schnContactPersonID], [schnContactPersonAddID], [schnGradeID], [schbLimitedYN], [schdMDConfReqDt], [schdMDConfRcvdDt], [schdOrgConfReqDt], [schdOrgConfRcvdDt], [schbDocAttached], [schsComments], [schnLossAmount], [schnRecUserID], [schdDtCreated], [schnModifyUserID], [schdDtModified], [schnLevelNo], [schnauthtodefcoun], [schnauthtodefcounDt]
	)
	SELECT
		cas.casnCaseID	  AS [schnCaseID]
	   ,pln.plnnContactID AS [schnPlaintiffID]
	   ,'S'				  AS [schsType]
	   ,NULL			  AS [schdFromDate]
	   ,NULL			  AS [schdToDate]
	   ,NULL			  AS [schnDays]
	   ,0				  AS [schnActivityID]
	   ,(
			SELECT
				connContactID
			FROM [sma_MST_OrgContacts]
			WHERE consName = 'Unidentified School'
				AND saga = -1
		)				  
		AS [schnOrgContactID]
	   ,(
			SELECT
				addnAddressID
			FROM [sma_MST_Address]
			WHERE addnContactCtgID = 2
				AND addnContactID = (
					SELECT
						connContactID
					FROM [sma_MST_OrgContacts]
					WHERE consName = 'Unidentified School'
						AND saga = -1
				)
		)				  
		AS [schnOrgAddressID]
	   ,NULL			  AS [schnContactPersonID]
	   ,NULL			  AS [schnContactPersonAddID]
	   ,(
			SELECT
				grdnGradeID
			FROM sma_MST_Grades
			WHERE grdsDescription = ud.Education
		)				  
		AS [schnGradeID]
	   ,0				  AS [schbLimitedYN]
	   ,NULL			  AS [schdMDConfReqDt]
	   ,NULL			  AS [schdMDConfRcvdDt]
	   ,NULL			  AS [schdOrgConfReqDt]
	   ,NULL			  AS [schdOrgConfRcvdDt]
	   ,0				  AS [schbDocAttached]
	   ,NULL			  AS [schsComments]
	   ,NULL			  AS [schnLossAmount]
	   ,368				  AS [schnRecUserID]
	   ,GETDATE()		  AS [schdDtCreated]
	   ,NULL			  AS [schdDtModified]
	   ,NULL			  AS [schnModifyUserID]
	   ,1				  AS [schnLevelNo]
	   ,0				  AS [schnauthtodefcoun]
	   ,NULL			  AS [schnauthtodefcounDt]
	FROM NeedlesSLF..user_party_data ud
	JOIN sma_TRN_Cases cas
		ON cas.cassCaseNumber = ud.case_id
	LEFT JOIN sma_TRN_Plaintiff pln
		ON pln.plnnCaseID = cas.casnCaseID
	WHERE ISNULL(ud.Education, '') <> ''

ALTER TABLE [sma_TRN_SchoolOthAct] ENABLE TRIGGER ALL
GO