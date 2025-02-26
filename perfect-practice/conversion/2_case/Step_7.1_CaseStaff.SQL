

use [SAPerfectPracticeEmroch]

/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_caseStaff] disable trigger all
delete [SAPerfectPracticeEmroch].[dbo].[sma_TRN_caseStaff]
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_caseStaff]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_caseStaff] enable trigger all
*/


----(0) staff roles ----

insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_SubRoleCode] ( srcsDscrptn, srcnRoleID )
(
select 'Assisting Attorney',10
union all
select 'Paralegal',10
union all
select 'Responsible Attorney',10
)
except
select srcsDscrptn, srcnRoleID from [SAPerfectPracticeEmroch].[dbo].[sma_MST_SubRoleCode]
GO
---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_caseStaff] disable trigger all
---
---(0)---
insert into sma_TRN_caseStaff 
( [cssnCaseID],[cssnStaffID],[cssnRoleID],[cssnRecUserID],[cssdDtCreated] )
select 
	CAS.casnCaseID			as [cssnCaseID],
	U.usrnContactID			as [cssnStaffID],
--	(select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Responsible Attorney' and sbrnRoleID=10 )	as [cssnRoleID],
	(select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Primary Attorney' and sbrnRoleID=10 )	as [cssnRoleID],
	368						as cssnRecUserID,
	getdate()				as [cssdDtCreated]
FROM [PerfectPracticeEmroch].[dbo].[entities] E
inner join [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS on CAS.cassCaseNumber = E.entityid
inner join [PerfectPracticeEmroch].[dbo].[uusers] UU on UU.entitynum=E.party0num 
inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Users] U on U.saga = UU.userid

---(1)---
insert into sma_TRN_caseStaff 
( [cssnCaseID],[cssnStaffID],[cssnRoleID],[cssnRecUserID],[cssdDtCreated] )
select 
	CAS.casnCaseID			as [cssnCaseID],
	U.usrnContactID			as [cssnStaffID],
	(select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Assisting Attorney' and sbrnRoleID=10 )	as [cssnRoleID],
	368						as cssnRecUserID,
	getdate()				as [cssdDtCreated]
FROM [PerfectPracticeEmroch].[dbo].[entities] E
inner join [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS on CAS.cassCaseNumber = E.entityid
inner join [PerfectPracticeEmroch].[dbo].[uusers] UU on UU.entitynum=E.party1num 
inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Users] U on U.saga = UU.userid

---(2)---
insert into sma_TRN_caseStaff 
( [cssnCaseID],[cssnStaffID],[cssnRoleID],[cssnRecUserID],[cssdDtCreated] )
select 
	CAS.casnCaseID			as [cssnCaseID],
	U.usrnContactID			as [cssnStaffID],
	(select sbrnSubRoleId from sma_MST_SubRole where sbrsDscrptn='Paralegal' and sbrnRoleID=10 )	as [cssnRoleID],
	368						as cssnRecUserID,
	getdate()				as [cssdDtCreated]
FROM [PerfectPracticeEmroch].[dbo].[entities] E
inner join [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS on CAS.cassCaseNumber = E.entityid
inner join [PerfectPracticeEmroch].[dbo].[uusers] UU on UU.entitynum=E.party2num 
inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Users] U on U.saga = UU.userid


---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_caseStaff] enable trigger all
---






