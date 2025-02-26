

use [JoelBieberSA_Needles]
go


--select
--	*
--from [sma_TRN_ReferredOut]


--(1)--
insert into [sma_TRN_ReferredOut]
	(
	rfosType,
	rfonCaseID,
	rfonPlaintiffID,
	rfonLawFrmContactID,
	rfonLawFrmAddressID,
	rfonAttContactID,
	rfonAttAddressID,
	rfonGfeeAgreement,
	rfobMultiFeeStru,
	rfobComplexFeeStru,
	rfonReferred,
	rfonCoCouncil,
	rfonIsLawFirmUpdateToSend,
	rfosComments
	)
	select
		'G'							 as rfostype,
		cas.casnCaseID				 as rfoncaseid,
		-1							 as rfonplaintiffid,
		case
			when ioc.CTG = 2
				then ioc.CID
			else null
		end							 as rfonlawfrmcontactid,
		case
			when ioc.CTG = 2
				then ioc.AID
			else null
		end							 as rfonlawfrmaddressid,
		case
			when ioc.CTG = 1
				then ioc.CID
			else null
		end							 as rfonattcontactid,
		case
			when ioc.CTG = 1
				then ioc.AID
			else null
		end							 as rfonattaddressid,
		0							 as rfongfeeagreement,
		0							 as rfobmultifeestru,
		0							 as rfobcomplexfeestru,
		1							 as rfonreferred,
		0							 as rfoncocouncil,
		0							 as rfonislawfirmupdatetosend,
		'user_case_data.referred_to' as rfoscomments
	from JoelBieberNeedles.dbo.user_case_data ucd
	join sma_TRN_Cases cas
		on CONVERT(VARCHAR, ucd.casenum) = cas.cassCaseNumber
	join sma_MST_IndvContacts indv
		on indv.source_id = ucd.Referred_to
			and indv.source_ref = 'Referred_to'
	join [IndvOrgContacts_Indexed] ioc
		on ioc.cid = indv.cinncontactid
			and ioc.ctg = 1
	where ISNULL(ucd.Referred_to, '') <> ''

--(2)--
update sma_MST_IndvContacts
set cinnContactTypeID = (
	select
		octnOrigContactTypeID
	from [dbo].[sma_MST_OriginalContactTypes]
	where octsDscrptn = 'Attorney'
)
where cinnContactID in (
	select
		rfonAttContactID
	from sma_TRN_ReferredOut
	where ISNULL(rfonAttContactID, '') <> ''
)


