
use [SAPerfectPracticeEmroch]

/*
alter table sma_TRN_CalendarAppointments disable trigger all
delete [dbo].[sma_TRN_CalendarAppointments] -- 166
where saga like 'Case-related:%'
alter table sma_TRN_CalendarAppointments enable trigger all

alter table [dbo].[sma_trn_AppointmentStaff] disable trigger all
delete from [dbo].[sma_trn_AppointmentStaff]
DBCC CHECKIDENT ('[dbo].[sma_trn_AppointmentStaff]', RESEED, 0);
alter table [dbo].[sma_trn_AppointmentStaff] disable trigger all
*/

---(0)---
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_CalendarAppointments'))
begin
    ALTER TABLE [sma_TRN_CalendarAppointments] ADD [saga] [varchar](32) NULL; 
end
GO


---(0)---
insert into [dbo].[sma_MST_ActivityType] ( attsDscrptn, attnActivityCtg )  
select A.ActivityType, (select atcnPKId FROM sma_MST_ActivityCategory where atcsDscrptn='Non-Case Related Appointment')
from
(

select distinct 
	CL.codelabel as ActivityType
FROM [PerfectPracticeEmroch].[dbo].[transactions] T
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=T.actcode
where T.trantype=2 -- Appointment


except
select 
    attsDscrptn as ActivityType
from sma_MST_ActivityType 
where attnActivityCtg = (select atcnPKId FROM sma_MST_ActivityCategory where atcsDscrptn='Non-Case Related Appointment')
and isnull(attsDscrptn,'') <> '' 
) A
GO


alter table [dbo].[sma_TRN_CalendarAppointments] disable trigger all

----(1)-----
insert into [dbo].[sma_TRN_CalendarAppointments]
(
	[FromDate],
	[ToDate],
	[AppointmentTypeID],
	[ActivityTypeID],
	[CaseID],
	[LocationContactID],
	[LocationContactGtgID],
	[JudgeID],
	[Comments],
	[StatusID],
	[Address],
	[Subject],
	[RecurranceParentID],[AdjournedID],[RecUserID],[DtCreated],[ModifyUserID],[DtModified],[DepositionType],[Deponants],
	[OriginalAppointmentID],[OriginalAdjournedID],[RecurrenceId],[WorkPlanItemId],[AutoUpdateAppId],[AutoUpdated],[AutoUpdateProviderId],[saga]
)

select 
	try_convert(datetime,T.startdtact) + try_convert(datetime,T.starttmact)
							as [FromDate],
	try_convert(datetime,T.startdtact) + try_convert(datetime,T.stoptmplan)
							as [ToDate],
	(select ID FROM [dbo].[sma_MST_CalendarAppointmentType] where AppointmentType='Non-Case related Office') 
						  as [AppointmentTypeID],
	case
		when CL.codelabel is not null then
		(select attnActivityTypeID from sma_MST_ActivityType 
			where attnActivityCtg=(select atcnPKId FROM sma_MST_ActivityCategory where atcsDscrptn='Non-Case Related Appointment') 
			and attsDscrptn = CL.codelabel )
		else
		(select attnActivityTypeID from sma_MST_ActivityType 
			where attnActivityCtg=(select atcnPKId FROM sma_MST_ActivityCategory where atcsDscrptn='Non-Case Related Appointment') 
			and attsDscrptn = 'Imported' )
	end						as [ActivityTypeID], 
	null					as [CaseID],
	null					as [LocationContactID],
	null					as [LocationContactGtgID],
	null					as [JudgeID],
	isnull('trantext : ' + nullif(T.[trantext],'') + CHAR(13),'') +
	''						as [Comments],
	case 
		when T.transtatus = 'CANCEL'	then (select [StatusId] from [dbo].[sma_MST_AppointmentStatus] where [StatusName]='Canceled')
		when T.transtatus = 'FINISH'		then (select [StatusId] from [dbo].[sma_MST_AppointmentStatus] where [StatusName]='Completed')
		when T.transtatus = 'OPEN'		then (select [StatusId] from [dbo].[sma_MST_AppointmentStatus] where [StatusName]='Open')
		else (select [StatusId] from [dbo].[sma_MST_AppointmentStatus] where [StatusName]='Open')
	end						as [StatusID],
	null					as [Address],
	left(T.transum,120)		as [Subject],
	null,null,
	368						as [RecUserID],
	getdate()				as [DtCreated],
	null					as [ModifyUserID],
	null					as [DtModified],
	null,null,null,null,null,null,null,null,null,
	'Non-Case:'+convert(varchar,T.id)	as [saga]
FROM [PerfectPracticeEmroch].[dbo].[transactions] T
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker<>1 and E.entitynum=T.entitynum  
--inner join [dbo].[sma_TRN_cases] CAS on CAS.cassCaseNumber = E.entityid
left join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=T.actcode
where T.trantype=2 -- Appointment
and try_convert(datetime,T.startdtact) > try_convert(datetime,'03/11/2024')
GO
alter table [dbo].[sma_TRN_CalendarAppointments] enable trigger all



GO
SET QUOTED_IDENTIFIER  OFF 

----(2)-----
insert into [dbo].[sma_trn_AppointmentStaff] ( AppointmentId,StaffContactId,ContactEmailID,StaffContactCtg )
select 
	APP.AppointmentID, 
	ACI.ContactId,
	ACI.ContactEmail,
	ACI.ContactCtg
from [dbo].[sma_TRN_CalendarAppointments] APP
inner join [PerfectPracticeEmroch].[dbo].[transactions] T on 'Non-Case:'+convert(varchar,T.id)=APP.[saga]
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker<>1 and E.entitynum=T.entitynum  
inner join [dbo].[IndvOrgContacts_Indexed] IOC on IOC.saga=E.party0num
inner join [dbo].[sma_MST_AllContactInfo] ACI on ACI.ContactId=IOC.CID and ACI.ContactCtg=IOC.CTG
--where not exists ( select * from sma_trn_AppointmentStaff 
--					where AppointmentId=APP.AppointmentID 
--					and StaffContactId=ACI.ContactId 
--					and ContactEmailID=ACI.ContactEmail 
--					and StaffContactCtg=ACI.ContactCtg)
SET QUOTED_IDENTIFIER  ON 




--select count(*) from [dbo].[sma_TRN_CalendarAppointments] -- 166
--where saga like 'Case-related:%'


--alter table sma_TRN_CalendarAppointments disable trigger all
--delete [dbo].[sma_TRN_CalendarAppointments] -- 166
--where saga like 'Case-related:%'
--alter table sma_TRN_CalendarAppointments enable trigger all
