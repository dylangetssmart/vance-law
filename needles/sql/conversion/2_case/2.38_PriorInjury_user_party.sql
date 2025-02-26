use JoelBieberSA_Needles
go

/* ####################################
1.0 -- Prior/Subsequent Injuries
*/

alter table sma_TRN_PriorInjuries disable trigger all
go

insert into sma_TRN_PriorInjuries
	(
	[prlnInjuryID],
	[prldPrAccidentDt],
	[prldDiagnosis],
	[prlsDescription],
	[prlsComments],
	[prlnPlaintiffID],
	[prlnCaseID],
	[prlnInjuryType],
	[prlnParentInjuryID],
	[prlsInjuryDesc],
	[prlnRecUserID],
	[prldDtCreated],
	[prlnModifyUserID],
	[prldDtModified],
	[prlnLevelNo],
	[prlbCaseRelated],
	[prlbFirmCase],
	[prlsPrCaseNo],
	[prlsInjury]
	)
	select
		null			  as [prlninjuryid],
		null			  as [prldpraccidentdt],
		null			  as [prlddiagnosis],
		null			  as [prlsdescription],
		null			  as [prlscomments],
		pln.plnnContactID as [prlnplaintiffid],
		cas.casnCaseID	  as [prlncaseid],
		3				  as [prlninjurytype],
		null			  as [prlnparentinjuryid],
		null			  as [prlsinjurydesc],
		368				  as [prlnrecuserid],
		GETDATE()		  as [prlddtcreated],
		null			  as [prlnmodifyuserid],
		null			  as [prlddtmodified],
		1				  as [prlnlevelno],
		0				  as [prlbcaserelated],
		0				  as [prlbfirmcase],
		null			  as [prlsprcaseno],
		ISNULL('Prior Injury: ' + NULLIF(upd.PRIOR_INJURY, '') + CHAR(13), '') +
		ISNULL('Prior_INJ: ' + NULLIF(upd.PRIOR_INJ, '') + CHAR(13), '') +
		ISNULL('Prior Injuries: ' + NULLIF(upd.Prior_Injuries, '') + CHAR(13), '') +
		''				  as [prlsinjury]
	from JoelBieberNeedles..user_party_data upd
	join sma_TRN_Cases cas
		on cas.cassCaseNumber = convert(varchar,upd.case_id)
	join sma_TRN_Plaintiff pln
		on pln.plnnCaseID = cas.casnCaseID
	where ISNULL(upd.PRIOR_INJURY, '') <> ''
		or ISNULL(upd.PRIOR_INJ, '') <> ''
		or ISNULL(upd.Prior_Injuries, '') <> ''

--FROM JoelBieberNeedles..user_case_data ud
--JOIN sma_TRN_Cases cas
--	ON cas.cassCaseNumber = ud.casenum
--JOIN sma_TRN_Plaintiff pln
--	ON pln.plnnCaseID = cas.casnCaseID

alter table sma_TRN_PriorInjuries enable trigger all
go

--select
--	upd.PRIOR_INJURY,
--	upd.PRIOR_INJ,
--	upd.Prior_Injuries
--from JoelBieberNeedles..user_party_data upd