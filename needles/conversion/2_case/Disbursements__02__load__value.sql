use Skolrood_SA
go


-- Use this to create custom CheckRequestStatuses
-- INSERT INTO [sma_MST_CheckRequestStatus] ([description])
-- select 'Unrecouped'
-- EXCEPT SELECT [description] FROM [sma_MST_CheckRequestStatus]


/* --------------------------------------------------------------------------------------------------------------
Create missing disbursement types for applicable value codes
*/

insert into [sma_MST_DisbursmentType]
	(
		disnTypeCode,
		dissTypeName
	)
	(
	select distinct
		'CONVERSION',
		vc.[description]
	from [Skolrood_Needles].[dbo].[value] v
	join [Skolrood_Needles].[dbo].[value_code] vc
		on vc.code = v.code
	where ISNULL(v.code, '') in (
			select
				code
			from conversion.value_disbursements
		))
	except
	select
		'CONVERSION',
		dissTypeName
	from [sma_MST_DisbursmentType]


/* --------------------------------------------------------------------------------------------------------------
Create Disbursements
*/

alter table [sma_TRN_Disbursement] disable trigger all
go

insert into [sma_TRN_Disbursement]
	(
		disnCaseID,
		disdCheckDt,
		disnPayeeContactCtgID,
		disnPayeeContactID,
		disnAmount,
		disnPlaintiffID,
		dissDisbursementType,
		UniquePayeeID,
		dissDescription,
		dissComments,
		disnCheckRequestStatus,
		disdBillDate,
		disdDueDate,
		disnRecUserID,
		disdDtCreated,
		disnRecoverable,
		saga,
		source_id,
		source_db,
		source_ref
	)
	select
		map.casnCaseID  as disncaseid,
		null			as disdcheckdt,
		map.ProviderCTG as disnpayeecontactctgid,
		map.ProviderCID as disnpayeecontactid,
		v.total_value   as disnamount,
		map.PlaintiffID as disnplaintiffid,
		(
			select
				disnTypeID
			from [sma_MST_DisbursmentType]
			where dissTypeName = (
					select
						[description]
					from [Skolrood_Needles].[dbo].[value_code]
					where [code] = v.code
				)
		)				as dissdisbursementtype,
		map.ProviderUID as uniquepayeeid,
		v.[memo]		as dissdescription,
		null			as dissComments,
		(
			select
				Id
			from [sma_MST_CheckRequestStatus]
			where [Description] = 'Paid'
		)				as disncheckrequeststatus,
		case
			when v.start_date between '1900-01-01' and '2079-06-06'
				then v.start_date
			else null
		end				as disdbilldate,
		case
			when v.stop_date between '1900-01-01' and '2079-06-06'
				then v.stop_date
			else null
		end				as disdduedate,
		(
			select
				usrnUserID
			from sma_MST_Users
			where source_id = v.staff_created
		)				as disnrecuserid,
		case
			when date_created between '1900-01-01' and '2079-06-06'
				then date_created
			else null
		end				as disddtcreated,
		case
			when v.code = 'DTF'
				then 1
			else 0
		end				as disnrecoverable,
		v.value_id		as saga,
		null			as source_id,
		'needles'		as source_db,
		'value_indexed' as source_ref
	from [Skolrood_Needles].[dbo].[value_Indexed] v
	join value_tab_Disbursement_Helper map
		on map.case_id = v.case_id
			and map.value_id = v.value_id
go

---
alter table [sma_TRN_Disbursement] enable trigger all
go
---

