/* ###################################################################################
description: Create defense attorneys
steps:
	- Insert defense attorneys > [sma_TRN_LawFirms]
	- Build defense attorney list > [sma_TRN_LawFirmAttorneys]
usage_instructions:
	- 
dependencies:
	- 
notes:
	-
*/

use [Skolrood_SA]
go

alter table [sma_TRN_LawFirms] disable trigger all
go

alter table [sma_TRN_LawFirmAttorneys] disable trigger all
go

-------------------------------------------------------------------------------
-- DEFENSE ATTORNEYS
-- [counsel_Indexed]
-------------------------------------------------------------------------------
insert into [sma_TRN_LawFirms]
	(
		[lwfnLawFirmContactID],
		[lwfnLawFirmAddressID],
		[lwfnAttorneyContactID],
		[lwfnAttorneyAddressID],
		[lwfnAttorneyTypeID],
		[lwfsFileNumber],
		[lwfnRoleType],
		[lwfnContactID],
		[lwfnRecUserID],
		[lwfdDtCreated],
		[lwfnModifyUserID],
		[lwfdDtModified],
		[lwfnLevelNo],
		[lwfnAdjusterID],
		[lwfsComments]
	)
	select distinct
		case
			when ioc.CTG = 2
				then ioc.CID
			else null
		end				  as [lwfnlawfirmcontactid],
		case
			when ioc.CTG = 2
				then ioc.AID
			else null
		end				  as [lwfnlawfirmaddressid],
		case
			when ioc.CTG = 1
				then ioc.CID
			else null
		end				  as [lwfnattorneycontactid],
		case
			when ioc.CTG = 1
				then ioc.AID
			else null
		end				  as [lwfnattorneyaddressid],
		(
			select
				atnnAtorneyTypeID
			from [sma_MST_AttorneyTypes]
			where atnsAtorneyDscrptn = 'Defense Attorney'
		)				  as [lwfnattorneytypeid],
		null			  as [lwfsfilenumber],
		2				  as [lwfnroletype],
		d.defnDefendentID as [lwfncontactid],
		368				  as [lwfnrecuserid],
		GETDATE()		  as [lwfddtcreated],
		cas.casnCaseID	  as [lwfnmodifyuserid],
		GETDATE()		  as [lwfddtmodified],
		null			  as [lwfnlevelno],
		null			  as [lwfnadjusterid],
		ISNULL('comments : ' + NULLIF(CONVERT(VARCHAR(MAX), c.comments), '') + CHAR(13), '') +
		ISNULL('Attorney for party : ' + NULLIF(CONVERT(VARCHAR(MAX), iocd.name), '') + CHAR(13), '') +
		''				  as [lwfscomments]
	from Skolrood_Needles.[dbo].[counsel_Indexed] c
	left join Skolrood_Needles.[dbo].[user_counsel_data] ud
		on ud.counsel_id = c.counsel_id
			and c.case_num = ud.casenum
	join [sma_TRN_Cases] cas
		on cas.cassCaseNumber = c.case_num
	join IndvOrgContacts_Indexed ioc
		on ioc.SAGA = c.counsel_id
			and ISNULL(c.counsel_id, 0) <> 0
	join IndvOrgContacts_Indexed iocd
		on iocd.SAGA = c.party_id
			and ISNULL(c.party_id, 0) <> 0
	join [sma_TRN_Defendants] d
		on d.defnContactID = iocd.CID
			and d.defnContactCtgID = iocd.CTG
			and d.defnCaseID = cas.casnCaseID
go


--/* ####################################
--ds 6/20/2024
--Create Defense Attorneys from user_party_data 
--*/
--insert into [sma_TRN_LawFirms]
--	(
--		[lwfnLawFirmContactID],
--		[lwfnLawFirmAddressID],
--		[lwfnAttorneyContactID],
--		[lwfnAttorneyAddressID],
--		[lwfnAttorneyTypeID],
--		[lwfsFileNumber],
--		[lwfnRoleType],
--		[lwfnContactID],
--		[lwfnRecUserID],
--		[lwfdDtCreated],
--		[lwfnModifyUserID],
--		[lwfdDtModified],
--		[lwfnLevelNo],
--		[lwfnAdjusterID],
--		[lwfsComments]
--	)
--	select distinct
--		case
--			when IOC.CTG = 2
--				then IOC.CID
--			else null
--		end				  as [lwfnLawFirmContactID],
--		case
--			when IOC.CTG = 2
--				then IOC.AID
--			else null
--		end				  as [lwfnLawFirmAddressID],
--		case
--			when IOC.CTG = 1
--				then IOC.CID
--			else null
--		end				  as [lwfnAttorneyContactID],
--		case
--			when IOC.CTG = 1
--				then IOC.AID
--			else null
--		end				  as [lwfnAttorneyAddressID],
--		(
--			select
--				atnnAtorneyTypeID
--			from [sma_MST_AttorneyTypes]
--			where atnsAtorneyDscrptn = 'Defense Attorney'
--		)				  as [lwfnAttorneyTypeID],
--		null			  as [lwfsFileNumber],
--		2				  as [lwfnRoleType],
--		D.defnDefendentID as [lwfnContactID],
--		368				  as [lwfnRecUserID],
--		GETDATE()		  as [lwfdDtCreated],
--		null			  as [lwfnModifyUserID],
--		null			  as [lwfdDtModified],
--		null			  as [lwfnLevelNo],
--		null			  as [lwfnAdjusterID],
--		null			  as [lwfsComments]
--	from Skolrood_Needles.[dbo].[user_party_data] ud
--	-- case data
--	join Skolrood_Needles.[dbo].[cases] C
--		on C.casenum = CONVERT(VARCHAR, ud.case_id)
--	join sma_TRN_Cases cas
--		on cas.NeedlesCasenum = c.casenum
--	-- on cas.cassCaseNumber = c.casenum
--	-- field link
--	join Skolrood_Needles.[dbo].[user_party_name] N
--		on N.case_id = ud.case_id
--			and N.party_id = ud.party_id
--			and N.[user_name] <> 0
--	join Skolrood_Needles.[dbo].[user_party_matter] M
--		on M.ref_num = N.ref_num
--			and M.mattercode = C.matcode
--			and M.field_title = 'Defense Atty'
--	-- contact card for the law firm
--	join Skolrood_Needles.[dbo].names
--		on names.names_id = N.user_name
--	join IndvOrgContacts_Indexed ioc
--		on ioc.SAGA = names.names_id
--	-- contact card for the defendant
--	join sma_TRN_Defendants d
--		on d.defnCaseID = cas.casnCaseID
--			and d.defbIsPrimary = 1
--	where
--		ISNULL(ud.Defense_Atty, '') <> ''
--go

-------------------------------------------------------------------------------
-- Defense Attorney list
-------------------------------------------------------------------------------
insert into sma_TRN_LawFirmAttorneys
	(
		SourceTableRowID,
		UniqueContactID,
		IsDefendant,
		IsPrimary
	)
	select
		a.lawfirmid			as sourcetablerowid,
		a.attorneycontactid as uniqueaontactid,
		1					as isdefendant,
		case
			when a.sequencenumber = 1
				then 1
			else 0
		end					as isprimary
	from (
		select
			f.lwfnLawFirmID																 as lawfirmid,
			ac.UniqueContactID															 as attorneycontactid,
			ROW_NUMBER() over (partition by f.lwfnModifyUserID order by f.lwfnLawFirmID) as sequencenumber
		from [sma_TRN_LawFirms] f
		left join sma_MST_AllContactInfo ac
			on ac.ContactCtg = 1
			and ac.ContactId = f.lwfnAttorneyContactID
	) a
	where
		a.attorneycontactid is not null
go


alter table [sma_TRN_LawFirms] enable trigger all
go

alter table [sma_TRN_LawFirmAttorneys] enable trigger all
go
---

