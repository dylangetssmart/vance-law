use Skolrood_SA
go

/* ------------------------------------------------------------------------------
Create missing Settlement Types from value_code.description
*/

--SELECT * FROM Skolrood_SA..sma_MST_SettlementType smst
--SELECT * FROM Skolrood_Needles..value_code vc

insert into [sma_MST_SettlementType]
	(
		SettlTypeName
	)
	select
		vc.description
	from Skolrood_Needles..value_code vc
	--select
	--	'Settlement Recovery'
	--union
	--select
	--	'MedPay'
	--union
	--select
	--	'Paid To Client'
	where
		vc.code in (
			select
				code
			from conversion.value_settlements
		)
	except
	select
		SettlTypeName
	from [sma_MST_SettlementType]
go

/* ------------------------------------------------------------------------------
Insert Settlement records
*/
alter table [sma_TRN_Settlements] disable trigger all
go

insert into [sma_TRN_Settlements]
	(
		stlnCaseID,
		stlnSetAmt,				-- Gross Settlement
		stlnNet,
		stlnNetToClientAmt,
		stlnPlaintiffID,
		stlnStaffID,
		stlnLessDisbursement,
		stlnGrossAttorneyFee,
		stlnForwarder,			-- Referrer
		stlnOther,
		InterestOnDisbursement,
		stlsComments,
		stlTypeID,
		stldSettlementDate,
		stlbTakeMedPay,			-- "Take Fee"
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		map.casnCaseID  as stlnCaseID,
		v.total_value   as stlnSetAmt,					-- Gross Settlement
		null			as stlnNet,
		null			as stlnNetToClientAmt,
		map.PlaintiffID as stlnPlaintiffID,
		null			as stlnStaffID,					-- Settled By
		null			as stlnLessDisbursement,
		--case
		--	when v.code in ('VER')
		--		then v.total_value
		--end				as stlngrossattorneyfee,	-- Gross Fee
		null			as stlnGrossAttorneyFee,		-- Gross Fee
		null			as stlnForwarder,				-- Referrer
		null			as stlnOther,
		null			as InterestOnDisbursement,
		ISNULL('memo:' + NULLIF(v.memo, '') + CHAR(13), '')
		+ ISNULL('code:' + NULLIF(v.code, '') + CHAR(13), '')
		+ ''			as stlsComments,
		/*
		Settlement Type:
		Fetch sma_MST_SettlementType.ID where SettleTypeName matches value_code.description
		*/
		(
			select
				ID
			from sma_MST_SettlementType
			where SettlTypeName = (
					select
						vc.description
					from Skolrood_Needles..value_code vc
					where vc.code = v.code
				)
		)				as stlTypeID,
		case
			when v.[start_date] between '1900-01-01' and '2079-06-06'
				then v.[start_date]
			else null
		end				as stldSettlementDate,
		--case
		--	when v.code = 'MPP'
		--		then 1
		--	else 0
		--end				as stlbtakemedpay,
		null			as stlbTakeMedPay,
		v.value_id		as saga,
		null			as [source_id],
		'needles'		as [source_db],
		'value_Indexed' as [source_ref]
	from Skolrood_Needles.[dbo].[value_Indexed] v
	join value_tab_Settlement_Helper map
		on map.case_id = v.case_id
			and map.value_id = v.value_id
	where
		v.code in (
			select
				code
			from conversion.value_settlements
		)
go

alter table [sma_TRN_Settlements] enable trigger all
go