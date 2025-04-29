/*
- create employer records from value.provider > names.names_id
- create special damage records for lost wages
*/

use Skolrood_SA
go


/* ------------------------------------------------------------------------------
[sma_TRN_LostWages] Schema
*/

-- saga
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and object_id = OBJECT_ID(N'sma_TRN_LostWages')
	)
begin
	alter table [sma_TRN_LostWages] add [saga] INT null;
end

go

-- source_id
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and object_id = OBJECT_ID(N'sma_TRN_LostWages')
	)
begin
	alter table [sma_TRN_LostWages] add [source_id] VARCHAR(MAX) null;
end

go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and object_id = OBJECT_ID(N'sma_TRN_LostWages')
	)
begin
	alter table [sma_TRN_LostWages] add [source_db] VARCHAR(MAX) null;
end

go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and object_id = OBJECT_ID(N'sma_TRN_LostWages')
	)
begin
	alter table [sma_TRN_LostWages] add [source_ref] VARCHAR(MAX) null;
end

go

/* ------------------------------------------------------------------------------
Insert Lost Wages
*/

insert into [sma_TRN_LostWages]
	(
		[ltwnEmploymentID],
		[ltwsType],
		[ltwdFrmDt],
		[ltwdToDt],
		[ltwnAmount],
		[ltwnAmtPaid],
		[ltwnLoss],
		[Comments],
		[ltwdMDConfReqDt],
		[ltwdMDConfDt],
		[ltwdEmpVerfReqDt],
		[ltwdEmpVerfRcvdDt],
		[ltwnRecUserID],
		[ltwdDtCreated],
		[ltwnModifyUserID],
		[ltwdDtModified],
		[ltwnLevelNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select distinct
		e.empnEmploymentID as [ltwnEmploymentID]		--sma_trn_employment ID
		,
		(
			select
				wgtnWagesTypeID
			from [sma_MST_WagesTypes]
			where wgtsDscrptn = 'Lost Wages'
		)				   as [ltwsType]   			--[sma_MST_WagesTypes].wgtnWagesTypeID
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
		,
		case
			when v.start_date between '1900-01-01' and '2079-06-06'
				then v.start_date
			else null
		end				   as [ltwdFrmDt],
		case
			when v.stop_date between '1900-01-01' and '2079-06-06'
				then v.stop_date
			else null
		end				   as [ltwdToDt],
		null			   as [ltwnAmount],
		null			   as [ltwnAmtPaid],
		v.total_value	   as [ltwnLoss],
		ISNULL('Memo: ' + NULLIF(CONVERT(VARCHAR, v.memo), '') + CHAR(13), '') +
		''				   as [comments],
		null			   as [ltwdMDConfReqDt],
		null			   as [ltwdMDConfDt],
		null			   as [ltwdEmpVerfReqDt],
		null			   as [ltwdEmpVerfRcvdDt],
		368				   as [ltwnRecUserID],
		GETDATE()		   as [ltwdDtCreated],
		null			   as [ltwnModifyUserID],
		null			   as [ltwdDtModified],
		null			   as [ltwnLevelNo],
		v.value_id		   as [saga],
		null			   as [source_id],
		'needles'		   as [source_db],
		'value_indexed'	   as [source_ref]
	-- employment record id: case > plaintiff > employment (value has caseid)
	from Skolrood_Needles..value_indexed v
	join sma_trn_Cases cas
		on cas.cassCaseNumber = CONVERT(VARCHAR, v.case_id)
	join sma_trn_plaintiff p
		on p.plnnCaseID = cas.casnCaseID
			and p.plnbIsPrimary = 1
	inner join sma_TRN_Employment e
		on e.empnPlaintiffID = p.plnnPlaintiffID
	where
		v.code = 'LWG'

-- FROM Skolrood_Needles..user_tab4_data ud
-- JOIN EmployerTemp et on et.employer = ud.employer and et.employer_address = ud.Employer_Address
-- JOIN IndvOrgContacts_Indexed ioc on ioc.SAGA = et.empID and ioc.[Name] = et.employer
-- JOIN [sma_TRN_Employment] e on  e.empnPlaintiffID = p.plnnPlaintiffID and empnEmployerID = ioc.CID


---------------------------------------
-- Update Special Damages
---------------------------------------
alter table [sma_TRN_SpDamages] disable trigger all
go

insert into [sma_TRN_SpDamages]
	(
		[spdsRefTable],
		[spdnRecordID],
		[spdnRecUserID],
		[spddDtCreated],
		[spdnLevelNo],
		spdnBillAmt,
		spddDateFrom,
		spddDateTo
	)
	select distinct
		'LostWages'		   as spdsRefTable,
		lw.ltwnLostWagesID as spdnRecordID,
		lw.ltwnRecUserID   as [spdnRecUserID],
		lw.ltwdDtCreated   as spddDtCreated,
		null			   as [spdnLevelNo],
		lw.[ltwnLoss]	   as spdnBillAmt,
		lw.ltwdFrmDt	   as spddDateFrom,
		lw.ltwdToDt		   as spddDateTo
	from sma_TRN_LostWages LW


alter table [sma_TRN_SpDamages] enable trigger all
go
