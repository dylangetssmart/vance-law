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

use [JoelBieberSA_Needles]
go

/*
alter table [sma_TRN_ReferredOut] disable trigger all
delete [sma_TRN_ReferredOut]
DBCC CHECKIDENT ('[sma_TRN_ReferredOut]', RESEED, 0);
alter table [sma_TRN_ReferredOut] enable trigger all

select * from [sma_TRN_ReferredOut]
*/

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
	rfonIsLawFirmUpdateToSend
	)

	select
		'G'			   as rfostype,
		cas.casnCaseID as rfoncaseid,
		-1			   as rfonplaintiffid,
		case
			when ioc.CTG = 2
				then ioc.CID
			else null
		end			   as rfonlawfrmcontactid,
		case
			when ioc.CTG = 2
				then ioc.AID
			else null
		end			   as rfonlawfrmaddressid,
		case
			when ioc.CTG = 1
				then ioc.CID
			else null
		end			   as rfonattcontactid,
		case
			when ioc.CTG = 1
				then ioc.AID
			else null
		end			   as rfonattaddressid,
		0			   as rfongfeeagreement,
		0			   as rfobmultifeestru,
		0			   as rfobcomplexfeestru,
		1			   as rfonreferred,
		0			   as rfoncocouncil,
		0			   as rfonislawfirmupdatetosend
	from JoelBieberNeedles.[dbo].[cases_indexed] c
	join [sma_TRN_cases] cas
		on cas.cassCaseNumber = c.casenum
	join [IndvOrgContacts_Indexed] ioc
		on ioc.SAGA = c.referred_to_id
			and c.referred_to_id > 0


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


