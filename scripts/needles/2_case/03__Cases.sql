use [VanceLawFirm_SA]
go

alter table [sma_TRN_Cases] disable trigger all
go

insert into [sma_TRN_Cases]
	(
		[cassCaseNumber],
		[casbAppName],
		[cassCaseName],
		[casnCaseTypeID],
		[casnState],
		[casdStatusFromDt],
		[casnStatusValueID],
		[casdsubstatusfromdt],
		[casnSubStatusValueID],
		[casdOpeningDate],
		[casdClosingDate],
		[casnCaseValueID],
		[casnCaseValueFrom],
		[casnCaseValueTo],
		[casnCurrentCourt],
		[casnCurrentJudge],
		[casnCurrentMagistrate],
		[casnCaptionID],
		[cassCaptionText],
		[casbMainCase],
		[casbCaseOut],
		[casbSubOut],
		[casbWCOut],
		[casbPartialOut],
		[casbPartialSubOut],
		[casbPartiallySettled],
		[casbInHouse],
		[casbAutoTimer],
		[casdExpResolutionDate],
		[casdIncidentDate],
		[casnTotalLiability],
		[cassSharingCodeID],
		[casnStateID],
		[casnLastModifiedBy],
		[casdLastModifiedDate],
		[casnRecUserID],
		[casdDtCreated],
		[casnModifyUserID],
		[casdDtModified],
		[casnLevelNo],
		[cassCaseValueComments],
		[casbRefIn],
		[casbDelete],
		[casbIntaken],
		[casnOrgCaseTypeID],
		[CassCaption],
		[cassMdl],
		[office_id],
		[LIP],
		[casnSeriousInj],
		[casnCorpDefn],
		[casnWebImporter],
		[casnRecoveryClient],
		[cas],
		[ngage],
		[casnClientRecoveredDt],
		[CloseReason],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		c.casenum	   as casscasenumber,
		''			   as casbappname,
		case_title	   as casscasename,
		(
			select
				cstnCaseSubTypeID
			from [sma_MST_CaseSubType] st
			where st.cstnGroupID = cst.cstnCaseTypeID
				and st.cstsDscrptn = mix.[SmartAdvocate Case Sub Type]
		)			   as casncasetypeid,
		(
			select
				[sttnStateID]
			from [sma_MST_States]
			where [sttsDescription] = (
					select
						StateName
					from conversion.office
				)
		)			   as casnstate,
		GETDATE()	   as casdstatusfromdt,
		(
			select
				cssnStatusID
			from [sma_MST_CaseStatus]
			where csssDescription = 'Presign - Not Scheduled For Sign Up'
		)			   as casnstatusvalueid,
		GETDATE()	   as casdsubstatusfromdt,
		(
			select
				cssnStatusID
			from [sma_MST_CaseStatus]
			where csssDescription = 'Presign - Not Scheduled For Sign Up'
		)			   as casnsubstatusvalueid,
		case
			when (c.date_opened not between '1900-01-01' and '2079-12-31')
				then GETDATE()
			else c.date_opened
		end			   as casdopeningdate,
		case
			when (c.close_date not between '1900-01-01' and '2079-12-31')
				then GETDATE()
			else c.close_date
		end			   as casdclosingdate,
		null		   as [casncasevalueid],
		null		   as [casncasevaluefrom],
		null		   as [casncasevalueto],
		null		   as [casncurrentcourt],
		null		   as [casncurrentjudge],
		null		   as [casncurrentmagistrate],
		0			   as [casncaptionid],
		case_title	   as casscaptiontext,
		1			   as [casbmaincase],
		0			   as [casbcaseout],
		0			   as [casbsubout],
		0			   as [casbwcout],
		0			   as [casbpartialout],
		0			   as [casbpartialsubout],
		0			   as [casbpartiallysettled],
		1			   as [casbinhouse],
		null		   as [casbautotimer],
		null		   as [casdexpresolutiondate],
		null		   as [casdincidentdate],
		0			   as [casntotalliability],
		0			   as [casssharingcodeid],
		(
			select
				[sttnStateID]
			from [sma_MST_States]
			where [sttsDescription] = (
					select
						StateName
					from conversion.office
				)
		)			   as [casnstateid],
		null		   as [casnlastmodifiedby],
		null		   as [casdlastmodifieddate],
		(
			select
				usrnUserID
			from sma_MST_Users
			where source_id = c.intake_staff
		)			   as casnrecuserid,
		case
			when c.intake_date between '1900-01-01' and '2079-06-06' and
				c.intake_time between '1900-01-01' and '2079-06-06'
				then (
						select
							CAST(CONVERT(DATE, c.intake_date) as DATETIME) + CAST(CONVERT(TIME, c.intake_time) as DATETIME)
					)
			else null
		end			   as casddtcreated,
		null		   as casnmodifyuserid,
		null		   as casddtmodified,
		''			   as casnlevelno,
		''			   as casscasevaluecomments,
		null		   as casbrefin,
		null		   as casbdelete,
		null		   as casbintaken,
		cstnCaseTypeID as casnorgcasetypeid -- actual case type
		,
		''			   as casscaption,
		0			   as cassmdl,
		(
			select
				office_id
			from sma_MST_Offices
			where office_name = (
					select
						OfficeName
					from conversion.office
				)
		)			   as office_id,
		null		   as [lip],
		null		   as [casnseriousinj],
		null		   as [casncorpdefn],
		null		   as [casnwebimporter],
		null		   as [casnrecoveryclient],
		null		   as [cas],
		null		   as [ngage],
		null		   as [casnclientrecovereddt],
		null		   as [closereason],
		c.casenum	   as [saga],
		null		   as [source_id],
		'needles'	   as [source_db],
		null		   as [source_ref]
	--select *
	from [VanceLawFirm_Needles].[dbo].[cases_Indexed] c
	--left join [VanceLawFirm_Needles].[dbo].[user_case_data] u
	--	on u.casenum = c.casenum
	join caseTypeMixture mix
		on mix.matcode = c.matcode
	left join sma_MST_CaseType cst
		on cst.cststype = mix.[SmartAdvocate Case Type]
			and VenderCaseType = (
				select
					VenderCaseType
				from conversion.office
			)
	order by c.casenum
go



select * from VanceLawFirm_Needles..cases where casenum = 214848
select * from VanceLawFirm_Needles..cases where matcode = 'mv2'
select *, Contract_Signed_Date from VanceLawFirm_Needles..user_tab6_data
select * from VanceLawFirm_Needles..matter

/* ------------------------------------------------------------------------------
Retained Date

for matcode 'MVA':		retained date = [user_tab6_data].[Contract_Signed_Date]
for all other cases:	retained date = case open date
*/ ------------------------------------------------------------------------------
alter table sma_TRN_Retainer disable trigger all
go

insert into [dbo].[sma_TRN_Retainer]
	(
		[rtnnCaseID],
		[rtnnPlaintiffID],
		[rtndSentDt],
		[rtndRcvdDt],
		[rtndRetainerDt],
		[rtnbCopyRefAttFee],
		[rtnnFeeStru],
		[rtnbMultiFeeStru],
		[rtnnBeforeTrial],
		[rtnnAfterTrial],
		[rtnnAtAppeal],
		[rtnnUDF1],
		[rtnnUDF2],
		[rtnnUDF3],
		[rtnbComplexStru],
		[rtnbWrittenAgree],
		[rtnnStaffID],
		[rtnsComments],
		[rtnnUserID],
		[rtndDtCreated],
		[rtnnModifyUserID],
		[rtndDtModified],
		[rtnnLevelNo],
		[rtnnPlntfAdv],
		[rtnnFeeAmt],
		[rtnsRetNo],
		[rtndRetStmtSent],
		[rtndRetStmtRcvd],
		[rtndClosingStmtRcvd],
		[rtndClosingStmtSent],
		[rtnsClosingRetNo],
		[rtndSignDt],
		[rtnsDocuments],
		[rtndExecDt],
		[rtnsGrossNet],
		[rtnnFeeStruAlter],
		[rtnsGrossNetAlter],
		[rtnnFeeAlterAmt],
		[rtnbFeeConditionMet],
		[rtnsFeeCondition]
	)
	select
		cas.casnCaseID		as rtnnCaseID,
		null			as rtnnPlaintiffID,
		null			as rtndSentDt,
		CASE
			WHEN c.matcode = 'MVA' THEN
				-- If Contract Date exists, validate it. Fall back to Opening Date if invalid.
				COALESCE(
					dbo.ValidDate(ut6.Contract_Signed_Date),	-- returns null if invalid
					cas.casdOpeningDate							
				)
			ELSE
				-- Use Opening Date for all other scenarios
				cas.casdOpeningDate 
		END AS rtndRcvdDt,
		--casdOpeningDate as rtndRcvdDt,
		null			as rtndRetainerDt,
		0				as rtnbCopyRefAttFee,
		null			as rtnnFeeStru,
		0				as rtnbMultiFeeStru,
		null			as rtnnBeforeTrial,
		null			as rtnnAfterTrial,
		null			as rtnnAtAppeal,
		null			as rtnnUDF1,
		null			as rtnnUDF2,
		null			as rtnnUDF3,
		0				as rtnbComplexStru,
		0				as rtnbWrittenAgree,
		null			as rtnnStaffID,
		null			as rtnsComments,
		368				as rtnnUserID,
		GETDATE()		as rtndDtCreated,
		null			as rtnnModifyUserID,
		null			as rtndDtModified,
		1				as rtnnLevelNo,
		null			as rtnnPlntfAdv,
		null			as rtnnFeeAmt,
		null			as rtnsRetNo,
		null			as rtndRetStmtSent,
		null			as rtndRetStmtRcvd,
		null			as rtndClosingStmtRcvd,
		null			as rtndClosingStmtSent,
		null			as rtnsClosingRetNo,
		null			as rtndSignDt,
		null			as rtnsDocuments,
		null			as rtndExecDt,
		null			as rtnsGrossNet,
		null			as rtnnFeeStruAlter,
		null			as rtnsGrossNetAlter,
		null			as rtnnFeeAlterAmt,
		null			as rtnbFeeConditionMet,
		null			as rtnsFeeCondition
	--from cte
	from VanceLawFirm_Needles..cases_Indexed c
	join sma_TRN_Cases cas on cas.saga = c.casenum
	left join VanceLawFirm_Needles..user_tab6_data ut6 on ut6.case_id = c.casenum
go



---
alter table sma_TRN_Retainer enable trigger all
go

---
alter table [sma_TRN_Cases] enable trigger all
go
---
