
use SAPerfectPracticeEmroch
GO

---(0)---
select
	EMROCH.entitynum,
	EMROCH.firstname,
	EMROCH.lastname,
	SA.usrnUserID
	into usermap_helper
from
(
select I.cinsFirstName,I.cinsLastName,U.usrnUserID
from [dbo].[sma_MST_Users] U	
inner join [dbo].[sma_MST_IndvContacts] I on I.cinnContactID=U.usrnContactID
) SA
inner join
(
select E.firstname,E.lastname,E.entitynum
From [PerfectPracticeEmroch].[dbo].[uusers] STF
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.entitynum=STF.entitynum
where E.firstname is not null
) EMROCH on EMROCH.firstname=SA.cinsFirstName and EMROCH.lastname=SA.cinsLastName
GO



---(1)---
alter table sma_TRN_TaskNew disable trigger all

update sma_TRN_TaskNew set tskAssigneeId=A.AssigneeId
from
(
select 
	TS.tskID	as ID,
	(select M.usrnUserID from usermap_helper M where M.entitynum=T.accompby)	
				as AssigneeId
FROM [PerfectPracticeEmroch].[dbo].[transactions] T
inner join [dbo].[sma_TRN_TaskNew] TS on TS.saga=T.id
where T.trantype=1 -- To Do
and try_convert(smalldatetime,T.startdtact)>try_convert(smalldatetime,'2024-03-11')
) A
where tskID=A.ID

alter table sma_TRN_TaskNew enable trigger all
