/* ###################################################################################
description: Handle all operations related to [sma_MST_IndvContacts]
steps:
	- insert from names
usage_instructions:
	-
dependencies:
	- 
notes:
	-
######################################################################################
*/

use VanceLawFirm_SA
go


/* --------------------------------------------------------------------------------------------------------------
- Insert from [names]
- Normal contacts
*/


--select top 1
--	ucd.COURT,
--	ucd.casenum
--from VanceLawFirm_Needles..user_case_data ucd
--where ISNULL(ucd.COURT, '') <> ''

--select
--	*
--from VanceLawFirm_Needles..user_case_fields ucf
--where ucf.field_title = 'court'
--select
--	*
--from VanceLawFirm_Needles..user_case_name ucn
--where ucn.casenum = 207706
--select
--	*
--from VanceLawFirm_Needles..names
--where names_id = 24740

--with cte_courts
--as
--(
--	select distinct
--		names_id
--	from VanceLawFirm_Needles..user_case_data ucd
--	join VanceLawFirm_Needles..user_case_fields ucf
--		on ucf.field_title = 'Court'
--	join VanceLawFirm_Needles..user_case_name ucn
--		on ucn.ref_num = ucf.field_num
--		and ucd.casenum = ucn.casenum
--	join VanceLawFirm_Needles..names n
--		on n.names_id = ucn.user_name
--	where ISNULL(ucd.COURT, '') <> ''

--)

insert into [sma_MST_OrgContacts]
	(
	[consName],
	[consWorkPhone],
	[consComments],
	[connContactCtg],
	[connContactTypeID],
	[connRecUserID],
	[condDtCreated],
	[conbStatus],
	[saga],
	[source_id],
	[source_db],
	[source_ref]
	)
	select
		n.[last_long_name] as [consname],
		n.[work_phone]	   as [consworkphone],
		case
			when ISNULL(n.[aka_full], '') <> '' and
				ISNULL(n.[email], '') = ''
				then (
					'AKA: ' + n.[aka_full]
					)
			when ISNULL(n.[aka_full], '') = '' and
				ISNULL(n.[email], '') <> ''
				then (
					'EMAIL: ' + n.[email]
					)
			when ISNULL(n.[aka_full], '') <> '' and
				ISNULL(n.[email], '') <> ''
				then (
					'AKA: ' + n.[aka_full] + ' EMAIL: ' + n.[email]
					)
		end				   as [conscomments],
		2				   as [conncontactctg],
		--case
		--	when cte_courts.names_id is not null
		--		then (
		--				select
		--					octnOrigContactTypeID
		--				from.[sma_MST_OriginalContactTypes]
		--				where octsDscrptn = 'Court'
		--					and octnContactCtgID = 2
		--			)
		--	else (
		--			select
		--				octnOrigContactTypeID
		--			from.[sma_MST_OriginalContactTypes]
		--			where octsDscrptn = 'General'
		--				and octnContactCtgID = 2
		--		)
		--end				   as [conncontacttypeid],
		(
			select
				octnOrigContactTypeID
			from.[sma_MST_OriginalContactTypes]
			where octsDscrptn = 'General'
				and octnContactCtgID = 2
		)				   as [conncontacttypeid],

		368				   as [connrecuserid],
		GETDATE()		   as [conddtcreated],
		1				   as [conbstatus],
		n.[names_id]	   as [saga],
		null			   as [source_id],
		'needles'		   as [source_db],
		'names'			   as [source_ref]
	from VanceLawFirm_Needles.[dbo].[names] n
	--join cte_courts
	--	on n.names_id = cte_courts.names_id
	where n.[person] <> 'Y'
go