-- Case Types
SELECT
	ct.name AS CaseType
	,count(*) as count
FROM case_type ct
LEFT JOIN matter m ON ct.id = m.case_type_id
group BY ct.name
order BY ct.name ASC

-- Party Roles
SELECT
    it.name as InvolvementType
	,it.meaning AS Meaning
	,it.valid_involvee_kind AS ValidInvolveeKind
	,CASE it.active
		when 'f' then 'False'
		when 't' then 'True'
	end AS Active
	,CASE mi.adversarial
		when 'f' then 'False'
		when 't' then 'True'
	end AS Adversarial
    ,COUNT(*) AS count
FROM matter_involvement mi
JOIN matter_involvement_involvement_type mit
    ON mit.matter_involvement_id = mi.id
JOIN involvement_type it
    ON it.id = mit.involvement_type_id
JOIN entity e
    ON e.id = mi.involvee_id
GROUP BY it.name, it.meaning, mi.adversarial, it.valid_involvee_kind, it.active
ORDER BY InvolvementType;

-- Users
SELECT
	up.id			   AS [up.id]
   ,up.username AS [up.username]
   ,up.display_name as [up.display_name]
   ,up.email AS [up.email]
   ,up.active as [up.active]
   ,up.hidden as [up.hidden]
   ,up.type as [up.type]
   ,e.id			   AS [e.id]
   ,e.prefix			AS [e.prefix]
   ,e.first_name AS [e.first_name]
   ,e.middle_name as [e.middle_name]
   ,e.last_name_or_company_name AS [e.last_name_or_company_name]
   ,e.suffix AS [e.suffix]
   ,lb_job.id		   AS [job.id]
   ,lb_job.name		   AS [job.title]
   ,lb_job.meaning	   AS [job.meaning]
   ,lb_job.description AS [job.description]
FROM JoelBieber_GrowPath..entity e
JOIN joelBieber_GrowPath..user_profile up
	ON e.user_profile_id = up.id
LEFT JOIN lookup_bucket lb_job
	ON up.job_title_id = lb_job.id
order BY [up.username]