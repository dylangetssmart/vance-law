

/*
select distinct 
	AST.StaffContactId
	FROM sma_trn_AppointmentStaff AS AST
		 LEFT JOIN sma_MST_AllContactInfo AS ACI ON ACI.UniqueContactId = AST.UniqueContactID
		 LEFT JOIN sma_MST_EmailWebsite AS EWS ON EWS.cewnContactID = ACI.ContactId
												  AND EWS.cewnContactCtgID = ACI.ContactCtg
												  AND EWS.cewbDefault = 1
												  AND EWS.cewsEmailWebsiteFlag = 'E'
		 LEFT JOIN sma_MST_Users AS USR ON USR.usrnContactID = ACI.ContactId AND ACI.ContactCtg = 1
where isnull(EWS.cewsEmailWebSite,'')=''


select 69833 as new, 23 as old -- Christopher	Spinelli
	union
select 88882 as new, 56 as old -- Harrison	Long
	union
select 53511 as new, 16 as old -- Julie	Bickhart


select * FROM sma_trn_AppointmentStaff AS AST
where StaffContactId>10000

*/

---(1)---
update sma_trn_AppointmentStaff set StaffContactId=56
where StaffContactId=88882

update sma_trn_AppointmentStaff set StaffContactId=23
where StaffContactId=69833





---(0)---
insert into [dbo].[sma_MST_ActivityType] ( attsDscrptn, attnActivityCtg )  
select A.ActivityType, (select atcnPKId FROM sma_MST_ActivityCategory where atcsDscrptn='Case-Related Appointment')
from
(

select 'Appointment' as ActivityType

except
select 
    attsDscrptn as ActivityType
from sma_MST_ActivityType 
where attnActivityCtg = (select atcnPKId FROM sma_MST_ActivityCategory where atcsDscrptn='Case-Related Appointment')
and isnull(attsDscrptn,'') <> '' 
) A
GO


---(0)---
insert into [dbo].[sma_MST_ActivityType] ( attsDscrptn, attnActivityCtg )  
select A.ActivityType, (select atcnPKId FROM sma_MST_ActivityCategory where atcsDscrptn='Non-Case Related Appointment')
from
(

select 'Appointment' as ActivityType

except
select 
    attsDscrptn as ActivityType
from sma_MST_ActivityType 
where attnActivityCtg = (select atcnPKId FROM sma_MST_ActivityCategory where atcsDscrptn='Non-Case Related Appointment')
and isnull(attsDscrptn,'') <> '' 
) A
GO





alter table sma_TRN_CalendarAppointments disable trigger all
---(2)---
update sma_TRN_CalendarAppointments set ActivityTypeID=A.ActivityTypeID
from
(
select 
		CAL.AppointmentID	as ID,
		(select attnActivityTypeID from sma_MST_ActivityType 
			where attnActivityCtg=(select atcnPKId FROM sma_MST_ActivityCategory where atcsDscrptn='Case-Related Appointment') 
			and attsDscrptn = 'Appointment' )
							as [ActivityTypeID]
from [dbo].[sma_TRN_CalendarAppointments] CAL
inner join [PerfectPracticeEmroch].[dbo].[transactions] T on 'Case-related:'+convert(varchar,T.id)=CAL.[saga]
where CAL.ActivityTypeID is null
) A 
where AppointmentID=A.ID



update sma_TRN_CalendarAppointments set ActivityTypeID=A.ActivityTypeID
from
(
select 
		CAL.AppointmentID	as ID,
		(select attnActivityTypeID from sma_MST_ActivityType 
			where attnActivityCtg=(select atcnPKId FROM sma_MST_ActivityCategory where atcsDscrptn='Non-Case Related Appointment') 
			and attsDscrptn = 'Appointment' )
							as [ActivityTypeID]
from [dbo].[sma_TRN_CalendarAppointments] CAL
inner join [PerfectPracticeEmroch].[dbo].[transactions] T on 'Non-Case:'+convert(varchar,T.id)=CAL.[saga]
where CAL.ActivityTypeID is null
) A
where AppointmentID=A.ID

alter table sma_TRN_CalendarAppointments enable trigger all


------------------

/*
select 
	count(*)
from [dbo].[sma_TRN_CalendarAppointments] CAL
inner join [PerfectPracticeEmroch].[dbo].[transactions] T on 'Case-related:'+convert(varchar,T.id)=CAL.[saga]
where CAL.ActivityTypeID is null


select 
	count(*)
from [dbo].[sma_TRN_CalendarAppointments] CAL
inner join [PerfectPracticeEmroch].[dbo].[transactions] T on 'Non-Case:'+convert(varchar,T.id)=CAL.[saga]
where CAL.ActivityTypeID is null


select distinct 
	(select attsDscrptn from sma_MST_ActivityType where attnActivityTypeID=CAL.ActivityTypeID )
from [dbo].[sma_TRN_CalendarAppointments] CAL
inner join [PerfectPracticeEmroch].[dbo].[transactions] T on 'Case-related:'+convert(varchar,T.id)=CAL.[saga]


select CAL.* 
--	(select attsDscrptn from sma_MST_ActivityType where attnActivityTypeID=CAL.ActivityTypeID )
from [dbo].[sma_TRN_CalendarAppointments] CAL
inner join [PerfectPracticeEmroch].[dbo].[transactions] T on 'Non-Case:'+convert(varchar,T.id)=CAL.[saga]
where T.trantype=2 -- Appointment
and try_convert(datetime,T.startdtact) > try_convert(datetime,'03/11/2024')
and T.id in
(
1612425,
1496217,
1496218
)
*/



select try_convert(datetime,T.startdtact),*
from [PerfectPracticeEmroch].[dbo].[transactions] T 
where T.trantype=2 -- Appointment
and try_convert(datetime,T.startdtact) > try_convert(datetime,'03/11/2024')
and T.trantext like '%OBJECTIONS TO WITNESS & EXHIBIT LISTS DUE%' and T.trantext like  '%OBJECTIONS & OTHER UNRESOVED ISSUES HEARD BY TODAY%'

