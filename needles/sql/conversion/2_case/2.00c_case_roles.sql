/* ###################################################################################
description: Handles common operations related to [sma_MST_IndvContacts]
steps:
	- Create a general purpose case group > [[sma_MST_SubRole]]
	- Create case types from CaseTypeMixture > [[sma_MST_SubRoleCode]]
	- Create case subtype codes > [sma_MST_CaseSubTypeCode]
	- Create case subtypes > [sma_MST_CaseSubType]
usage_instructions:
	- update values for [conversion].[office]
dependencies:
	- 
notes:
	-
*/


use JoelBieberSA_Needles
go


-- (3.0) sma_MST_SubRole -----------------------------------------------------
insert into [sma_MST_SubRole]
	(
	[sbrsCode],
	[sbrnRoleID],
	[sbrsDscrptn],
	[sbrnCaseTypeID],
	[sbrnPriority],
	[sbrnRecUserID],
	[sbrdDtCreated],
	[sbrnModifyUserID],
	[sbrdDtModified],
	[sbrnLevelNo],
	[sbrbDefualt],
	[saga]
	)
	select
		[sbrscode]		   as [sbrscode],
		[sbrnroleid]	   as [sbrnroleid],
		[sbrsdscrptn]	   as [sbrsdscrptn],
		cst.cstnCaseTypeID as [sbrncasetypeid],
		[sbrnpriority]	   as [sbrnpriority],
		[sbrnrecuserid]	   as [sbrnrecuserid],
		[sbrddtcreated]	   as [sbrddtcreated],
		[sbrnmodifyuserid] as [sbrnmodifyuserid],
		[sbrddtmodified]   as [sbrddtmodified],
		[sbrnlevelno]	   as [sbrnlevelno],
		[sbrbdefualt]	   as [sbrbdefualt],
		[saga]			   as [saga]
	from sma_MST_CaseType cst
	left join sma_mst_subrole s
		on cst.cstnCaseTypeID = s.sbrncasetypeid
			or s.sbrncasetypeid = 1
	join [CaseTypeMixture] mix
		on mix.matcode = cst.cstsCode
	where VenderCaseType = (
			select
				VenderCaseType
			from conversion.office
		)
		and ISNULL(mix.[SmartAdvocate Case Type], '') = ''

-- (3.1) sma_MST_SubRole : use the sma_MST_SubRole.sbrsDscrptn value to set the sma_MST_SubRole.sbrnTypeCode field ---
update sma_MST_SubRole
set sbrnTypeCode = A.CodeId
from (
	select
		s.sbrsdscrptn as sbrsdscrptn,
		s.sbrnSubRoleId as subroleid,
		(
			select
				MAX(srcnCodeId)
			from sma_MST_SubRoleCode
			where srcsDscrptn = s.sbrsdscrptn
		) as codeid
	from sma_MST_SubRole s
	join sma_MST_CaseType cst
		on cst.cstnCaseTypeID = s.sbrnCaseTypeID
		and cst.VenderCaseType = (
			select
				VenderCaseType
			from conversion.office
		)
) a
where a.subroleid = sbrnSubRoleId


-- (4) specific plaintiff and defendant party roles ----------------------------------------------------
-- roleId 4 -> plaintiff
-- roleId 5 -> defendant
--INSERT INTO [sma_MST_SubRoleCode]
--	(
--	srcsDscrptn
--   ,srcnRoleID
--	)
--	(
--	SELECT
--		'(P)-Default Role'
--	   ,4

--	UNION ALL

--	SELECT
--		'(D)-Default Role'
--	   ,5

--	UNION ALL

--	SELECT
--		[SA Roles]
--	   ,4
--	FROM [PartyRoles]
--	WHERE [SA Party] = 'Plaintiff'

--	UNION ALL

--	SELECT
--		[SA Roles]
--	   ,5
--	FROM [PartyRoles]
--	WHERE [SA Party] = 'Defendant'

--	-- co-counsel
--	UNION ALL
--	SELECT
--		'(P)-CO-COUNSEL'
--	   ,4
--	UNION ALL
--	SELECT
--		'(D)-CO-COUNSEL'


--	   ,5
--	-- driver
--	UNION ALL
--	SELECT
--		'(P)-Driver'
--	   ,4
--	UNION ALL
--	SELECT
--		'(D)-Driver'
--	   ,5
--	-- Ins Adjuster
--	UNION ALL
--	SELECT
--		'(P)-Adjuster'
--	   ,4
--	UNION ALL
--	SELECT
--		'(D)-Adjuster'
--	   ,5
--	-- Owner
--	UNION ALL
--	SELECT
--		'(P)-Owner'
--	   ,4
--	UNION ALL
--	SELECT
--		'(D)-Owner'
--	   ,5
--	-- PROPERTY OWNER
--	UNION ALL
--	SELECT
--		'(P)-PROPERTY OWNER'
--	   ,4
--	UNION ALL
--	SELECT
--		'(D)-PROPERTY OWNER'
--	   ,5




--	)
--	EXCEPT
--	SELECT
--		srcsDscrptn
--	   ,srcnRoleID
--	FROM [sma_MST_SubRoleCode]


---- (4) specific plaintiff and defendant party roles ----
-- roleId 4 -> plaintiff
-- roleId 5 -> defendant
insert into [sma_MST_SubRoleCode]
	(
	srcsDscrptn,
	srcnRoleID
	)
	(
	-- Default Roles
	select
		'(P)-Default Role',
		4
	union all
	select
		'(D)-Default Role',
		5
	
	-- Roles from PartyRoles table
	union all
	select
		[SA Roles],
		4
	from [PartyRoles]
	where [SA Party] = 'Plaintiff'
	union all
	select
		[SA Roles],
		5
	from [PartyRoles]
	where [SA Party] = 'Defendant'

	-- party.role = "CO-COUNSEL"
	union all
	select
		'(P)-CO-COUNSEL',
		4
	union all
	select
		'(D)-CO-COUNSEL',
		5

	-- party.role = "DRIVER"
	union all
	select
		'(P)-DRIVER',
		4
	union all
	select
		'(D)-DRIVER',
		5

	-- party.role = "INS ADJUSTER"
	union all
	select
		'(P)-ADJUSTER',
		4
	union all
	select
		'(D)-ADJUSTER',
		5

	-- party.role = "OWNER"
	union all
	select
		'(P)-OWNER',
		4
	union all
	select
		'(D)-OWNER',
		5

	-- party.role = "PROPERTY OWNER"
	union all
	select
		'(P)-PROPERTY OWNER',
		4
	union all
	select
		'(D)-PROPERTY OWNER',
		5
	)
	except
	select
		srcsDscrptn,
		srcnRoleID
	from [sma_MST_SubRoleCode];


-- (4.1) Not already in sma_MST_SubRole-----
insert into sma_MST_SubRole
	(
	sbrnRoleID,
	sbrsDscrptn,
	sbrnCaseTypeID,
	sbrnTypeCode
	)
	select
		newroles.sbrnroleid,
		newroles.sbrsdscrptn,
		newroles.sbrncasetypeid,
		subrolecodes.srcnCodeId as sbrntypecode
	from (
		select
			r.pord as sbrnroleid,
			r.[role] as sbrsdscrptn,
			cst.cstnCaseTypeID as sbrncasetypeid
		from sma_MST_CaseType cst
		cross join (
			-- Default Roles
			select
				'(P)-Default Role' as role,
				4 as pord
			union all
			select
				'(D)-Default Role' as role,
				5 as pord

			-- Roles from PartyRoles table
			union all
			select
				[SA Roles] as role,
				4 as pord
			from [PartyRoles]
			where [SA Party] = 'Plaintiff'
			union all
			select
				[SA Roles] as role,
				5 as pord
			from [PartyRoles]
			where [SA Party] = 'Defendant'

			-- Specific Roles
			union all
			select
				'(P)-CO-COUNSEL',
				4
			union all
			select
				'(D)-CO-COUNSEL',
				5
			union all
			select
				'(P)-DRIVER',
				4
			union all
			select
				'(D)-DRIVER',
				5
			union all
			select
				'(P)-ADJUSTER',
				4
			union all
			select
				'(D)-ADJUSTER',
				5
			union all
			select
				'(P)-OWNER',
				4
			union all
			select
				'(D)-OWNER',
				5
			union all
			select
				'(P)-PROPERTY OWNER',
				4
			union all
			select
				'(D)-PROPERTY OWNER',
				5
		) r
		where cst.VenderCaseType = (
				select
					VenderCaseType
				from conversion.office
			)
	) as newroles
	join sma_MST_SubRoleCode subrolecodes
		on subrolecodes.srcsDscrptn = newroles.sbrsdscrptn
			and subrolecodes.srcnRoleID = newroles.sbrnroleid
	except
	select
		sbrnroleid,
		sbrsdscrptn,
		sbrncasetypeid,
		sbrntypecode
	from sma_MST_SubRole;

