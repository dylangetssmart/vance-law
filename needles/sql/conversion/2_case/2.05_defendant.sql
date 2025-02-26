/* ###################################################################################
description: Insert defendants
steps:
	- Insert plantiff death from individual contact records > [sma_TRN_PlaintiffDeath]
	
usage_instructions:
	- 
dependencies:
	- 
notes:
	-
*/


use [JoelBieberSA_Needles]
go

-------------------------------------------------------------------------------
-- Update schema
-------------------------------------------------------------------------------

if not exists (
		select
			*
		from sys.columns
		where Name = N'saga_party'
			and object_id = OBJECT_ID(N'sma_TRN_Defendants')
	)
begin
	alter table [sma_TRN_Defendants] add [saga_party] INT null;
end


-- source_id
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and Object_ID = OBJECT_ID(N'sma_TRN_Defendants')
	)
begin
	alter table [sma_TRN_Defendants] add [source_id] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and Object_ID = OBJECT_ID(N'sma_TRN_Defendants')
	)
begin
	alter table [sma_TRN_Defendants] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and Object_ID = OBJECT_ID(N'sma_TRN_Defendants')
	)
begin
	alter table [sma_TRN_Defendants] add [source_ref] VARCHAR(MAX) null;
end
go


alter table [sma_TRN_Defendants] disable trigger all
go

-------------------------------------------------------------------------------
-- Insert defendants
-------------------------------------------------------------------------------
insert into [sma_TRN_Defendants]
	(
	[defnCaseID],
	[defnContactCtgID],
	[defnContactID],
	[defnAddressID],
	[defnSubRole],
	[defbIsPrimary],
	[defbCounterClaim],
	[defbThirdParty],
	[defsThirdPartyRole],
	[defnPriority],
	[defdFrmDt],
	[defdToDt],
	[defnRecUserID],
	[defdDtCreated],
	[defnModifyUserID],
	[defdDtModified],
	[defnLevelNo],
	[defsMarked],
	[saga],
	[saga_party]
	)
	select
		casnCaseID	  as [defncaseid],
		acio.CTG	  as [defncontactctgid],
		acio.CID	  as [defncontactid],
		acio.AID	  as [defnaddressid],
		sbrnSubRoleId as [defnsubrole],
		1			  as [defbisprimary],
		null,
		null,
		null,
		null,
		null,
		null,
		368			  as [defnrecuserid],
		GETDATE()	  as [defddtcreated],
		null		  as [defnmodifyuserid],
		null		  as [defddtmodified],
		null		  as [defnlevelno],
		null,
		null,
		p.TableIndex  as [saga_party]
	from JoelBieberNeedles.[dbo].[party_indexed] p
	join [sma_TRN_Cases] cas
		on cas.cassCaseNumber = p.case_id
	join IndvOrgContacts_Indexed acio
		on acio.SAGA = p.party_id
	join [PartyRoles] pr
		on pr.[Needles Roles] = p.[role]
	join [sma_MST_SubRole] s
		on cas.casnOrgCaseTypeID = s.sbrnCaseTypeID
			and s.sbrsDscrptn = [sa roles]
			and s.sbrnRoleID = 5
	where pr.[sa party] = 'Defendant'
go


-------------------------------------------------------------------------------
-- Insert defendants from conversion.user_case_plaintiff_defendant
-- see: 1.06_contact_indv_user_plaintiff_defendant.sql
-------------------------------------------------------------------------------
insert into [sma_TRN_Defendants]
	(
	[defnCaseID],
	[defnContactCtgID],
	[defnContactID],
	[defnAddressID],
	[defnSubRole],
	[defbIsPrimary],
	[defbCounterClaim],
	[defbThirdParty],
	[defsThirdPartyRole],
	[defnPriority],
	[defdFrmDt],
	[defdToDt],
	[defnRecUserID],
	[defdDtCreated],
	[defnModifyUserID],
	[defdDtModified],
	[defnLevelNo],
	[defsMarked],
	[saga]
	--[saga_party]
	)
	select
		casnCaseID	  as [defncaseid],
		cio.CTG	  as [defncontactctgid],
		cio.CID	  as [defncontactid],
		cio.AID	  as [defnaddressid],
		sbrnSubRoleId as [defnsubrole],
		1			  as [defbisprimary],
		null,
		null,
		null,
		null,
		null,
		null,
		368			  as [defnrecuserid],
		GETDATE()	  as [defddtcreated],
		null		  as [defnmodifyuserid],
		null		  as [defddtmodified],
		null		  as [defnlevelno],
		null,
		null as [saga]
		--p.TableIndex  as [saga_party]
	select *
	from JoelBieberNeedles..user_case_data ucd
	-- case
	join sma_TRN_Cases cas
		on cas.cassCaseNumber = convert(varchar,ucd.casenum)
	-- contact: conversion.user_case_plaintiff_defendant > sma_mst_indvcontacts > indvorgcontacts_indexed
	join conversion.user_case_plaintiff_defendant conv_ucpd
		on conv_ucpd.contact_name = ucd.DEFENDANT
		and conv_ucpd.plaintiff_or_defendant = 'D'
	join sma_mst_indvcontacts indv
		on indv.source_id = conv_ucpd.contact_name
		and indv.source_ref = 'cte_user_case_plaintiff_defendant:defendant'
	join IndvOrgContacts_Indexed cio
		on cio.cid = indv.cinncontactid
		and cio.ctg = 1
	-- role
	join [sma_MST_SubRole] s
		on cas.casnOrgCaseTypeID = s.sbrnCaseTypeID
			and s.sbrsDscrptn = '(D)-DEFENDANT'
			and s.sbrnRoleID = 5
go


-------------------------------------------------------------------------------
-- Every case need at least one defendant
-------------------------------------------------------------------------------
insert into [sma_TRN_Defendants]
	(
	[defnCaseID],
	[defnContactCtgID],
	[defnContactID],
	[defnAddressID],
	[defnSubRole],
	[defbIsPrimary],
	[defbCounterClaim],
	[defbThirdParty],
	[defsThirdPartyRole],
	[defnPriority],
	[defdFrmDt],
	[defdToDt],
	[defnRecUserID],
	[defdDtCreated],
	[defnModifyUserID],
	[defdDtModified],
	[defnLevelNo],
	[defsMarked],
	[saga]
	)
	select
		casnCaseID as [defncaseid],
		1		   as [defncontactctgid],
		(
			select
				cinncontactid
			from sma_MST_IndvContacts
			where cinsFirstName = 'Defendant'
				and cinsLastName = 'Unidentified'
		)		   as [defncontactid],
		null	   as [defnaddressid],
		(
			select
				sbrnSubRoleId
			from sma_MST_SubRole s
			inner join sma_MST_SubRoleCode c
				on c.srcnCodeId = s.sbrnTypeCode
				and c.srcsDscrptn = '(D)-Default Role'
			where s.sbrnCaseTypeID = cas.casnOrgCaseTypeID
		)		   as [defnsubrole],
		1		   as [defbisprimary],-- reexamine??
		null,
		null,
		null,
		null,
		null,
		null,
		368		   as [defnrecuserid],
		GETDATE()  as [defddtcreated],
		368		   as [defnmodifyuserid],
		GETDATE()  as [defddtmodified],
		null,
		null,
		null
	from sma_trn_cases cas
	left join [sma_TRN_Defendants] d
		on d.defncaseid = cas.casnCaseID
	where d.defncaseid is null

-------------------------------------------------------------------------------
-- Update primary defendant
-------------------------------------------------------------------------------
update sma_TRN_Defendants
set defbIsPrimary = 0

update sma_TRN_Defendants
set defbIsPrimary = 1
from (
	select distinct
		d.defnCaseID,
		ROW_NUMBER() over (partition by d.defnCaseID order by p.record_num) as rownumber,
		d.defnDefendentID as id
	from sma_TRN_Defendants d
	left join JoelBieberNeedles.[dbo].[party_indexed] p
		on p.TableIndex = d.saga_party
) a
where a.rownumber = 1
and defnDefendentID = a.id

go


---
alter table [sma_TRN_Defendants] enable trigger all
go