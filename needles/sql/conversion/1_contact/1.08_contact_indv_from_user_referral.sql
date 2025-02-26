use JoelBieberSA_Needles
go


alter table [sma_MST_IndvContacts] disable trigger all
go


;
with cte_referrals
as
(
	-- user_case_data.Dr_Referral
	select distinct
		ucd.Dr_Referral as contact_name,
		'user_case_data.Dr_Referral' as source_ref
	from JoelBieberNeedles..user_case_data ucd
	where ISNULL(ucd.Dr_Referral, '') <> ''

	union all

	-- user_case_data.Referred_to
	select distinct
		ucd.Referred_to as contact_name,
		'user_case_data.Referred_to' as source_ref
	from JoelBieberNeedles..user_case_data ucd
	where ISNULL(ucd.Referred_to, '') <> ''
)
insert into [sma_MST_IndvContacts]
	(
	[cinbPrimary],
	[cinnContactTypeID],
	[cinnContactSubCtgID],
	[cinsPrefix],
	[cinsFirstName],
	[cinsMiddleName],
	[cinsLastName],
	[cinsSuffix],
	[cinsNickName],
	[cinbStatus],
	[cinsSSNNo],
	[cindBirthDate],
	[cinsComments],
	[cinnContactCtg],
	[cinnRefByCtgID],
	[cinnReferredBy],
	[cindDateOfDeath],
	[cinsCVLink],
	[cinnMaritalStatusID],
	[cinnGender],
	[cinsBirthPlace],
	[cinnCountyID],
	[cinsCountyOfResidence],
	[cinbFlagForPhoto],
	[cinsPrimaryContactNo],
	[cinsHomePhone],
	[cinsWorkPhone],
	[cinsMobile],
	[cinbPreventMailing],
	[cinnRecUserID],
	[cindDtCreated],
	[cinnModifyUserID],
	[cindDtModified],
	[cinnLevelNo],
	[cinsPrimaryLanguage],
	[cinsOtherLanguage],
	[cinbDeathFlag],
	[cinsCitizenship],
	[cinsHeight],
	[cinnWeight],
	[cinsReligion],
	[cindMarriageDate],
	[cinsMarriageLoc],
	[cinsDeathPlace],
	[cinsMaidenName],
	[cinsOccupation],
	[cinsSpouse],
	[cinsGrade],
	[saga],
	[source_id],
	[source_db],
	[source_ref]
	)
	select
		1									as [cinbprimary],
		case
			when cte.source_ref = 'Dr_Referral'
				then (
						select
							octnOrigContactTypeID
						from [dbo].[sma_MST_OriginalContactTypes]
						where octsDscrptn = 'Referral'
							and octnContactCtgID = 1
					)
			when cte.source_ref = 'Referred_to'
				then (
						select
							octnOrigContactTypeID
						from [dbo].[sma_MST_OriginalContactTypes]
						where octsDscrptn = 'Attorney'
							and octnContactCtgID = 1
					)
		end									as [cinncontacttypeid],
		null								as [cinncontactsubctgid],
		''									as [cinsprefix],
		dbo.get_firstword(cte.contact_name) as [cinsfirstname],
		''									as [cinsmiddlename],
		dbo.get_lastword(cte.contact_name)  as [cinslastname],
		null								as [cinssuffix],
		null								as [cinsnickname],
		1									as [cinbstatus],
		null								as [cinsssnno],
		null								as [cindbirthdate],
		null								as [cinscomments],
		1									as [cinncontactctg],
		''									as [cinnrefbyctgid],
		''									as [cinnreferredby],
		null								as [cinddateofdeath],
		''									as [cinscvlink],
		''									as [cinnmaritalstatusid],
		1									as [cinngender],
		''									as [cinsbirthplace],
		1									as [cinncountyid],
		1									as [cinscountyofresidence],
		null								as [cinbflagforphoto],
		null								as [cinsprimarycontactno],
		null								as [cinshomephone],
		''									as [cinsworkphone],
		null								as [cinsmobile],
		0									as [cinbpreventmailing],
		368									as [cinnrecuserid],
		GETDATE()							as [cinddtcreated],
		''									as [cinnmodifyuserid],
		null								as [cinddtmodified],
		0									as [cinnlevelno],
		''									as [cinsprimarylanguage],
		''									as [cinsotherlanguage],
		''									as [cinbdeathflag],
		''									as [cinscitizenship],
		null								as [cinsheight],
		null								as [cinnweight],
		''									as [cinsreligion],
		null								as [cindmarriagedate],
		null								as [cinsmarriageloc],
		null								as [cinsdeathplace],
		''									as [cinsmaidenname],
		null								as [cinsoccupation],
		''									as [cinsspouse],
		''									as [cinsgrade],
		null								as [saga],
		cte.contact_name					as [source_id],
		'needles'							as [source_db],
		cte.source_ref						as [source_ref]
	from cte_referrals cte
go


alter table [sma_MST_IndvContacts] enable trigger all
go