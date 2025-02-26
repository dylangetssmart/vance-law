
use [SAPerfectPracticeEmroch]

/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Incidents] disable trigger all
delete [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Incidents]
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_Incidents]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Incidents] enable trigger all
*/



---(0)---
if exists (select * from sys.objects where name='Incident_Helper' and type='U')
begin
	drop table Incident_Helper
end
GO
create table Incident_Helper (
	entitynum	varchar(32), 
	labelname	varchar(max), 
	answertext	varchar(max)
)

insert into Incident_Helper ( entitynum,labelname,answertext )
select A.entitynum,A.labelname,A.answertext
from
(
select
	UQOBJ.labelname,
	EQANSWER.answertext,
	E.entitynum,
	ROW_NUMBER() over(partition by UQOBJ.labelname,E.entitynum order by E.entitynum ) as row_index
from [PerfectPracticeEmroch].[dbo].[eqanswer_base] EQANSWER
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] UCODES_LABEL on UCODES_LABEL.id=EQANSWER.entityrole -- 2102
inner join [PerfectPracticeEmroch].[dbo].[uqobj_base] UQOBJ on UQOBJ.qlabel=UCODES_LABEL.id and UQOBJ.fieldnum=EQANSWER.fieldnum
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=EQANSWER.entitynum  
where UCODES_LABEL.codeclass='QC' 
and EQANSWER.answertext is not null
and UQOBJ.labelname in 
	(
	'Date of Accident',
	'Time of Accident',
	'Detailed Accident Information',
	'Incident Summary (what Happened)',
	'Injuries',
	'Description of Incident',
	'Facts of Incident',
	'Brief description of injuries',
	'Location of Incident',
	'Intersection Of',
	'Accident Location',
	'Location of Incident / Accident'
	)
) A where A.row_index=1
GO


---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Incidents] disable trigger all
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Cases] disable trigger all
---
insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Incidents]
(
       [CaseId]
      ,[IncidentDate]
      ,[StateID]
      ,[LiabilityCodeId]
      ,[IncidentFacts]
      ,[MergedFacts]
      ,[Comments]
      ,[IncidentTime]
      ,[RecUserID]
      ,[DtCreated]
      ,[ModifyUserID]
      ,[DtModified]
)
select 
		CAS.casnCaseID		as CaseId,
		try_convert(date,E.title) as IncidentDate,
		case
		  when CAS.casnStateID is not null  
			 then CAS.casnStateID
		  else (select sttnStateID from sma_MST_States where sttsDescription='Virginia') 
		end					as [StateID],
		0					as LiabilityCodeId, 
		isnull(DOI.labelname + ' : ' + DOI.answertext + CHAR(13),'') + 
		isnull(TOI.labelname + ' : ' + TOI.answertext + CHAR(13),'') + 
		isnull(DAI.labelname + ' : ' + DAI.answertext + CHAR(13),'') + 
		isnull(ISW.labelname + ' : ' + ISW.answertext + CHAR(13),'') + 
		isnull(INJ.labelname + ' : ' + INJ.answertext + CHAR(13),'') + 
		isnull(DSI.labelname + ' : ' + DSI.answertext + CHAR(13),'') + 
		isnull(FOI.labelname + ' : ' + FOI.answertext + CHAR(13),'') + 
		isnull(BDI.labelname + ' : ' + BDI.answertext + CHAR(13),'') + 
		isnull(LOI.labelname + ' : ' + LOI.answertext + CHAR(13),'') +
		isnull(I_O.labelname + ' : ' + I_O.answertext + CHAR(13),'') +
		isnull(A_L.labelname + ' : ' + A_L.answertext + CHAR(13),'') +
		isnull(LOA.labelname + ' : ' + LOA.answertext + CHAR(13),'') +
		''					as IncidentFacts,
		''					as [MergedFacts],
		null				as [Comments],
		try_convert(time,TOI.answertext) as [IncidentTime],
		368					as [RecUserID],
		getdate()			as [DtCreated],
		null				as [ModifyUserID],
		null				as [DtModified]
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS on CAS.saga_entitynum = E.entitynum
left join Incident_Helper DOI on DOI.entitynum=E.entitynum and DOI.labelname='Date of Accident'
left join Incident_Helper TOI on TOI.entitynum=E.entitynum and TOI.labelname='Time of Accident'
left join Incident_Helper DAI on DAI.entitynum=E.entitynum and DAI.labelname='Detailed Accident Information'
left join Incident_Helper ISW on ISW.entitynum=E.entitynum and ISW.labelname='Incident Summary (what Happened)'
left join Incident_Helper INJ on INJ.entitynum=E.entitynum and INJ.labelname='Injuries'
left join Incident_Helper DSI on DSI.entitynum=E.entitynum and DSI.labelname='Description of Incident'
left join Incident_Helper FOI on FOI.entitynum=E.entitynum and FOI.labelname='Facts of Incident'
left join Incident_Helper BDI on BDI.entitynum=E.entitynum and BDI.labelname='Brief description of injuries'
left join Incident_Helper LOI on LOI.entitynum=E.entitynum and LOI.labelname='Location of Incident'
left join Incident_Helper I_O on I_O.entitynum=E.entitynum and I_O.labelname='Intersection Of'
left join Incident_Helper A_L on A_L.entitynum=E.entitynum and A_L.labelname='Accident Location'
left join Incident_Helper LOA on LOA.entitynum=E.entitynum and LOA.labelname='Location of Incident / Accident'


update CAS
set CAS.casdIncidentDate= try_convert(datetime,INC.IncidentDate),
    CAS.casnStateID=INC.StateID,
    CAS.casnState=INC.StateID
from [SAPerfectPracticeEmroch].[dbo].sma_trn_cases as CAS
left join [SAPerfectPracticeEmroch].[dbo].sma_TRN_Incidents as INC on casnCaseID=caseid
where INC.CaseId=CAS.casncaseid 

---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Incidents] enable trigger all
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Cases] enable trigger all




