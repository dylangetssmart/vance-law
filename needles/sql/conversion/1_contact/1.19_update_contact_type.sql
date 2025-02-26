/*

update contact types for contacts created by inserting from names

i.e. "clerks" are created by insert from names
- clerk Law Clerk
- court Court
- other special contact types




*/

--select
--	*
--from sma_MST_ContactTypes smct
--select
--	*
--from [sma_MST_OriginalContactTypes]


-----------------------------------------------------------------------------------------------
-- update indv


-- cinnContactId

--n.[names_id]							 as saga,
--null									 as source_id_1,
--'needles'								 as source_id_2,
--'names'									 as source_id_3

use JoelBieberSA_Needles
go

;with cte_indv_contacts
as
(
	select
		names_id as names_id,
		'Clerk' as contact_type
	from JoelBieberNeedles..user_case_data ucd
	join JoelBieberNeedles..user_case_fields ucf
		on ucf.field_title = 'Clerk'
	join JoelBieberNeedles..user_case_name ucn
		on ucn.ref_num = ucf.field_num
		and ucd.casenum = ucn.casenum
	join JoelBieberNeedles..names n
		on n.names_id = ucn.user_name
	where ISNULL(ucd.CLERK, '') <> ''

)

update sma_MST_IndvContacts
set cinnContactTypeID =
case
	when cte.contact_type = 'Clerk'
		then (
				select
					octnOrigContactTypeID
				from [dbo].[sma_MST_OriginalContactTypes]
				where octsDscrptn = 'Law Clerk'
					and octnContactCtgID = 1
			)
end
from sma_MST_IndvContacts indv
join cte_indv_contacts cte
	on indv.saga = cte.names_id

-----------------------------------------------------------------------------------------------
-- update org

;with cte_org_contacts
as
(
	select
		names_id as names_id,
		'Court' as contact_type
	from JoelBieberNeedles..user_case_data ucd
	join JoelBieberNeedles..user_case_fields ucf
		on ucf.field_title = 'Court'
	join JoelBieberNeedles..user_case_name ucn
		on ucn.ref_num = ucf.field_num
		and ucd.casenum = ucn.casenum
	join JoelBieberNeedles..names n
		on n.names_id = ucn.user_name
	where ISNULL(ucd.COURT, '') <> ''

)

update sma_MST_OrgContacts
set connContactTypeID =
case
	when cte.contact_type = 'Court'
		then (
				select
					octnOrigContactTypeID
				from [dbo].[sma_MST_OriginalContactTypes]
				where octsDscrptn = 'Court'
					and octnContactCtgID = 1
			)
end
from sma_MST_OrgContacts org
join cte_org_contacts cte
	on org.saga = cte.names_id
