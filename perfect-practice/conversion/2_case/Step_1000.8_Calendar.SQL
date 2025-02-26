
use [SAPerfectPracticeEmroch]

/*
select E.party0num,
	APP.AppointmentID, 
	ACI.ContactId,
	ACI.ContactEmail,
	ACI.ContactCtg
from [dbo].[sma_TRN_CalendarAppointments] APP
inner join [PerfectPracticeEmroch].[dbo].[transactions] T on 'Case-related:'+convert(varchar,T.id)=APP.[saga]
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=T.entitynum  
inner join [dbo].[IndvOrgContacts_Indexed] IOC on IOC.saga=E.party0num
inner join [dbo].[sma_MST_AllContactInfo] ACI on ACI.ContactId=IOC.CID and ACI.ContactCtg=IOC.CTG
where E.entityid='22-15082'
and try_convert(Date,APP.FromDate)=try_convert(Date,'04/01/2024')
and APP.Comments like '%trantext : DEP PREP OF GONSMAN VIA ZOOM%'


select IOC.saga,count(IOC.saga)
from [dbo].[IndvOrgContacts_Indexed] IOC
group by IOC.saga
having count(IOC.saga)>1
*/

---(1)---
if exists (select * from sys.objects where name='AppointmentStaff_Helper' and type='U')
begin
	drop table AppointmentStaff_Helper
end
GO

select A.ID into AppointmentStaff_Helper
--select count(*) -- 161
from
(
select 
	AST.RecordId as ID,
	APP.AppointmentId,
	E.party0num,
	ACI.ContactEmail,
	ROW_NUMBER() over( partition by APP.AppointmentId,E.party0num order by ACI.ContactEmail ) as row_index
from [dbo].[sma_TRN_CalendarAppointments] APP
inner join [PerfectPracticeEmroch].[dbo].[transactions] T on 'Case-related:'+convert(varchar,T.id)=APP.[saga]
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=T.entitynum  
inner join [dbo].[IndvOrgContacts_Indexed] IOC on IOC.saga=E.party0num
inner join [dbo].[sma_MST_AllContactInfo] ACI on ACI.ContactId=IOC.CID and ACI.ContactCtg=IOC.CTG
inner join [dbo].[sma_trn_AppointmentStaff] AST on 
AST.AppointmentId=APP.AppointmentId and 
AST.StaffContactId=ACI.ContactId and
AST.StaffContactCtg=ACI.ContactCtg 
where IOC.saga in
	(
	'146257',
	'164118',
	'175009',
	'197988',
	'198382',
	'199859',
	'201362',
	'20201',
	'202913',
	'202914',
	'3018',
	'74839',
	'77705',
	'83821',
	'863'
	)
) A 
where A.row_index=1
GO

---(2)---
alter table sma_trn_AppointmentStaff disable trigger all
GO
delete sma_trn_AppointmentStaff
where RecordId in ( select ID from AppointmentStaff_Helper )

alter table sma_trn_AppointmentStaff enable trigger all


----(3)-----
insert into [dbo].[sma_trn_AppointmentStaff] ( AppointmentId,StaffContactId,ContactEmailID,StaffContactCtg )
select 
	APP.AppointmentID, 
	ACI.ContactId,
	ACI.ContactEmail,
	ACI.ContactCtg
from [dbo].[sma_TRN_CalendarAppointments] APP
inner join [PerfectPracticeEmroch].[dbo].[transactions] T on 'Case-related:'+convert(varchar,T.id)=APP.[saga]
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=T.entitynum  
left join [PerfectPracticeEmroch].[dbo].[entities] P on P.entitynum=T.operatornum and P.entityrole='PRODUCER'  
left join [dbo].[IndvOrgContacts_Indexed] IOC on IOC.saga=P.entitynum
inner join [dbo].[sma_MST_AllContactInfo] ACI on ACI.ContactId=IOC.CID and ACI.ContactCtg=IOC.CTG




---(0)---
if exists (select * from sys.objects where name='AppointmentStaff_Helper2' and type='U')
begin
	drop table AppointmentStaff_Helper2
end
GO

select A.ID into AppointmentStaff_Helper2
from
(
select 
	AST.RecordId as ID,
	APP.AppointmentId,
	T.operatornum,
	ACI.ContactEmail,
	ROW_NUMBER() over( partition by APP.AppointmentId,T.operatornum order by ACI.ContactEmail ) as row_index
from [dbo].[sma_TRN_CalendarAppointments] APP
inner join [PerfectPracticeEmroch].[dbo].[transactions] T on 'Case-related:'+convert(varchar,T.id)=APP.[saga]
left join [PerfectPracticeEmroch].[dbo].[entities] P on P.entitynum=T.operatornum and P.entityrole='PRODUCER'  
left join [dbo].[IndvOrgContacts_Indexed] IOC on IOC.saga=P.entitynum
inner join [dbo].[sma_MST_AllContactInfo] ACI on ACI.ContactId=IOC.CID and ACI.ContactCtg=IOC.CTG
inner join [dbo].[sma_trn_AppointmentStaff] AST on 
AST.AppointmentId=APP.AppointmentId and 
AST.StaffContactId=ACI.ContactId and
AST.StaffContactCtg=ACI.ContactCtg 
where IOC.saga in
	(
	'146257',
	'164118',
	'175009',
	'197988',
	'198382',
	'199859',
	'201362',
	'20201',
	'202913',
	'202914',
	'3018',
	'74839',
	'77705',
	'83821',
	'863'
	)
) A 
where A.row_index=1
GO

---(2)---
alter table sma_trn_AppointmentStaff disable trigger all
GO
delete sma_trn_AppointmentStaff
where RecordId in ( select ID from AppointmentStaff_Helper2 )

alter table sma_trn_AppointmentStaff enable trigger all

