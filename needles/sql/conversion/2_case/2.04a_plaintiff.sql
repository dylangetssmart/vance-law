/* ###################################################################################
description: Insert plaintiffs
steps:
	- update schema > [sma_TRN_Plaintiff]
	- Insert case staff from staff_1 through staff_4 > [sma_TRN_CaseStaff]	
usage_instructions:
	- update values for [conversion].[office]
dependencies:
	- 
notes:
	-
*/

use [JoelBieberSA_Needles]
go

if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_party'
			and object_id = OBJECT_ID(N'sma_TRN_Plaintiff')
	)
begin
	alter table [sma_TRN_Plaintiff] add [saga_party] INT null;
end

-- source_id
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and Object_ID = OBJECT_ID(N'sma_TRN_Plaintiff')
	)
begin
	alter table [sma_TRN_Plaintiff] add [source_id] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and Object_ID = OBJECT_ID(N'sma_TRN_Plaintiff')
	)
begin
	alter table [sma_TRN_Plaintiff] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and Object_ID = OBJECT_ID(N'sma_TRN_Plaintiff')
	)
begin
	alter table [sma_TRN_Plaintiff] add [source_ref] VARCHAR(MAX) null;
end
go


alter table [sma_TRN_Plaintiff] disable trigger all
go

-------------------------------------------------------------------------------
-- Insert plaintiffs
-------------------------------------------------------------------------------

insert into [sma_TRN_Plaintiff]
	(
	[plnnCaseID],
	[plnnContactCtg],
	[plnnContactID],
	[plnnAddressID],
	[plnnRole],
	[plnbIsPrimary],
	[plnbWCOut],
	[plnnPartiallySettled],
	[plnbSettled],
	[plnbOut],
	[plnbSubOut],
	[plnnSeatBeltUsed],
	[plnnCaseValueID],
	[plnnCaseValueFrom],
	[plnnCaseValueTo],
	[plnnPriority],
	[plnnDisbursmentWt],
	[plnbDocAttached],
	[plndFromDt],
	[plndToDt],
	[plnnRecUserID],
	[plndDtCreated],
	[plnnModifyUserID],
	[plndDtModified],
	[plnnLevelNo],
	[plnsMarked],
	[saga],
	[plnnNoInj],
	[plnnMissing],
	[plnnLIPBatchNo],
	[plnnPlaintiffRole],
	[plnnPlaintiffGroup],
	[plnnPrimaryContact],
	[saga_party]
	)
	select
		cas.casnCaseID  as [plnncaseid],
		cio.CTG			as [plnncontactctg],
		cio.CID			as [plnncontactid],
		cio.AID			as [plnnaddressid],
		s.sbrnSubRoleId as [plnnrole],
		1				as [plnbisprimary],
		0,
		0,
		0,
		0,
		0,
		0,
		null,
		null,
		null,
		null,
		null,
		null,
		GETDATE(),
		null,
		368				as [plnnrecuserid],
		GETDATE()		as [plnddtcreated],
		null,
		null,
		null			as [plnnlevelno],
		null,
		'',
		null,
		null,
		null,
		null,
		null,
		1				as [plnnprimarycontact],
		p.TableIndex	as [saga_party]
	--SELECT  * -- cas.casncaseid, p.role, p.party_ID, pr.[needles roles], pr.[sa roles], pr.[sa party], s.*
	from JoelBieberNeedles.[dbo].[party_indexed] p
	join [sma_TRN_Cases] cas
		on cas.cassCaseNumber = p.case_id
	join IndvOrgContacts_Indexed cio
		on cio.SAGA = p.party_id
	join [PartyRoles] pr
		on pr.[Needles Roles] = p.[role]
	join [sma_MST_SubRole] s
		on cas.casnOrgCaseTypeID = s.sbrnCaseTypeID
			and s.sbrsDscrptn = [sa roles]
			and s.sbrnRoleID = 4
	where pr.[sa party] = 'Plaintiff'
	--and cas.casnCaseID = 22985
go


-------------------------------------------------------------------------------
-- Insert plaintiffs from conversion.user_case_plaintiff_defendant
-- see: 1.06_contact_indv_user_plaintiff_defendant.sql
-------------------------------------------------------------------------------
insert into [sma_TRN_Plaintiff]
	(
	[plnnCaseID],
	[plnnContactCtg],
	[plnnContactID],
	[plnnAddressID],
	[plnnRole],
	[plnbIsPrimary],
	[plnbWCOut],
	[plnnPartiallySettled],
	[plnbSettled],
	[plnbOut],
	[plnbSubOut],
	[plnnSeatBeltUsed],
	[plnnCaseValueID],
	[plnnCaseValueFrom],
	[plnnCaseValueTo],
	[plnnPriority],
	[plnnDisbursmentWt],
	[plnbDocAttached],
	[plndFromDt],
	[plndToDt],
	[plnnRecUserID],
	[plndDtCreated],
	[plnnModifyUserID],
	[plndDtModified],
	[plnnLevelNo],
	[plnsMarked],
	[saga],
	[plnnNoInj],
	[plnnMissing],
	[plnnLIPBatchNo],
	[plnnPlaintiffRole],
	[plnnPlaintiffGroup],
	[plnnPrimaryContact],
	[saga_party]
	)
	select
		cas.casnCaseID  as [plnncaseid],
		cio.CTG			as [plnncontactctg],
		cio.CID			as [plnncontactid],
		cio.AID			as [plnnaddressid],
		s.sbrnSubRoleId as [plnnrole],
		1				as [plnbisprimary],
		0,
		0,
		0,
		0,
		0,
		0,
		null,
		null,
		null,
		null,
		null,
		null,
		GETDATE(),
		null,
		368				as [plnnrecuserid],
		GETDATE()		as [plnddtcreated],
		null,
		null,
		null			as [plnnlevelno],
		null,
		'',
		null,
		null,
		null,
		null,
		null,
		1				as [plnnprimarycontact],
		null as [saga_party]
	--SELECT  * cas.casnOrgCaseTypeID -- cas.casncaseid, p.role, p.party_ID, pr.[needles roles], pr.[sa roles], pr.[sa party], s.*
	from JoelBieberNeedles..user_case_data ucd
	-- case
	join sma_TRN_Cases cas
		on cas.cassCaseNumber = convert(varchar,ucd.casenum)
	-- contact: conversion.user_case_plaintiff_defendant > sma_mst_indvcontacts > indvorgcontacts_indexed
	join conversion.user_case_plaintiff_defendant conv_ucpd
		on conv_ucpd.contact_name = ucd.PLAINTIFF
		and conv_ucpd.plaintiff_or_defendant = 'P'
	join sma_mst_indvcontacts indv
		on indv.source_id = conv_ucpd.contact_name
		and indv.source_ref = 'cte_user_case_plaintiff_defendant:plaintiff'
	join IndvOrgContacts_Indexed cio
		on cio.cid = indv.cinncontactid
		and cio.ctg = 1
	-- role
	join [sma_MST_SubRole] s
		on cas.casnOrgCaseTypeID = s.sbrnCaseTypeID
			and s.sbrsDscrptn = '(P)-Plaintiff'
			and s.sbrnRoleID = 4
			
	/*
	subrole records added by implementation
		select * from sma_MST_SubRole where sbrnCaseTypeID in (1780,1685) order by sbrsDscrptn
		SELECT * FROM sma_MST_Users smu
		select * from JoelBieberSA_Needles.conversion.user_case_plaintiff_defendant ucpd
	--	select * from sma_MST_IndvContacts smic where smic.source_ref = 'cte_user_case_plaintiff_defendant:plaintiff'
	*/
go

/*
-------------------------------------------------------------------------------
##############################################################################
-------------------------------------------------------------------------------
---(Appendix A)-- every case need at least one plaintiff
*/

insert into [sma_TRN_Plaintiff]
	(
	[plnnCaseID],
	[plnnContactCtg],
	[plnnContactID],
	[plnnAddressID],
	[plnnRole],
	[plnbIsPrimary],
	[plnbWCOut],
	[plnnPartiallySettled],
	[plnbSettled],
	[plnbOut],
	[plnbSubOut],
	[plnnSeatBeltUsed],
	[plnnCaseValueID],
	[plnnCaseValueFrom],
	[plnnCaseValueTo],
	[plnnPriority],
	[plnnDisbursmentWt],
	[plnbDocAttached],
	[plndFromDt],
	[plndToDt],
	[plnnRecUserID],
	[plndDtCreated],
	[plnnModifyUserID],
	[plndDtModified],
	[plnnLevelNo],
	[plnsMarked],
	[saga],
	[plnnNoInj],
	[plnnMissing],
	[plnnLIPBatchNo],
	[plnnPlaintiffRole],
	[plnnPlaintiffGroup],
	[plnnPrimaryContact]
	)
	select
		casnCaseID as [plnncaseid],
		1		   as [plnncontactctg],
		(
			select
				cinncontactid
			from sma_MST_IndvContacts
			where cinsFirstName = 'Plaintiff'
				and cinsLastName = 'Unidentified'
		)		   as [plnncontactid],
		null	   as [plnnaddressid],
		(
			select
				sbrnSubRoleId
			from sma_MST_SubRole s
			inner join sma_MST_SubRoleCode c
				on c.srcnCodeId = s.sbrnTypeCode
				and c.srcsDscrptn = '(P)-Default Role'
			where s.sbrnCaseTypeID = cas.casnOrgCaseTypeID
		)		   as plnnrole,
		1		   as [plnbisprimary],
		0,
		0,
		0,
		0,
		0,
		0,
		null,
		null,
		null,
		null,
		null,
		null,
		GETDATE(),
		null,
		368		   as [plnnrecuserid],
		GETDATE()  as [plnddtcreated],
		null,
		null,
		'',
		null,
		'',
		null,
		null,
		null,
		null,
		null,
		1		   as [plnnprimarycontact]
	from sma_trn_cases cas
	left join [sma_TRN_Plaintiff] t
		on t.plnncaseid = cas.casnCaseID
	where plnncaseid is null
go



update sma_TRN_Plaintiff
set plnbIsPrimary = 0

update sma_TRN_Plaintiff
set plnbIsPrimary = 1
from (
	select distinct
		t.plnnCaseID,
		ROW_NUMBER() over (partition by t.plnnCaseID order by p.record_num) as rownumber,
		t.plnnPlaintiffID as id
	from sma_TRN_Plaintiff t
	left join JoelBieberNeedles.[dbo].[party_indexed] p
		on p.TableIndex = t.saga_party
) a
where a.rownumber = 1
and plnnPlaintiffID = a.id



alter table [sma_TRN_Plaintiff] enable trigger all
go
