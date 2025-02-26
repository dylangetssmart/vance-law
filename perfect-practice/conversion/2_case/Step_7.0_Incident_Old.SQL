
use [SAPerfectPracticeEmroch]

/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Incidents] disable trigger all
delete [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Incidents]
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_Incidents]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Incidents] enable trigger all
*/

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
--		try_convert(date,INCDATE.answertext) as IncidentDate,
		try_convert(date,E.title) as IncidentDate,
		case
		  when CAS.casnStateID is not null  
			 then CAS.casnStateID
		  else (select sttnStateID from sma_MST_States where sttsDescription='Virginia') 
		end					as [StateID],
		0					as LiabilityCodeId, 
		isnull('Fact:' + nullif(convert(varchar(max),FACT.answertext),'') + CHAR(13),'') +
		isnull('Detail:' + nullif(convert(varchar(max),DETAIL.answertext),'') + CHAR(13),'') +
		isnull('Summary:' + nullif(convert(varchar(max),SUMMARY.answertext),'') + CHAR(13),'') +
		isnull('Injuries:' + nullif(convert(varchar(max),INJ.answertext),'') + CHAR(13),'') +
		isnull('Description:' + nullif(convert(varchar(max),DSCRPTN.answertext),'') + CHAR(13),'') +
		isnull('Brief Injuries Description:' + nullif(convert(varchar(max),BRIEF.answertext),'') + CHAR(13),'') +
		''					as IncidentFacts,
		''					as [MergedFacts],
		null				as [Comments],
		try_convert(time,INCTIME.answertext) as [IncidentTime],
		368					as [RecUserID],
		getdate()			as [DtCreated],
		null				as [ModifyUserID],
		null				as [DtModified]
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS on CAS.saga_entitynum = E.entitynum
left join
(
select 
	EQANSWER.answertext,
	E.entitynum,
	ROW_NUMBER() over(partition by E.entitynum order by E.entitynum ) as row_index
from [PerfectPracticeEmroch].[dbo].[eqanswer_base] EQANSWER
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] UCODES_LABEL on UCODES_LABEL.id=EQANSWER.entityrole -- 2102
inner join [PerfectPracticeEmroch].[dbo].[uqobj_base] UQOBJ on UQOBJ.qlabel=UCODES_LABEL.id and UQOBJ.fieldnum=EQANSWER.fieldnum
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=EQANSWER.entitynum  
where UCODES_LABEL.codeclass='QC' 
and UQOBJ.labelname='Date of Accident'
) INCDATE on INCDATE.row_index=1 and INCDATE.entitynum=E.entitynum
left join
(
select 
	EQANSWER.answertext,
	E.entitynum,
	ROW_NUMBER() over(partition by E.entitynum order by E.entitynum ) as row_index
from [PerfectPracticeEmroch].[dbo].[eqanswer_base] EQANSWER
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] UCODES_LABEL on UCODES_LABEL.id=EQANSWER.entityrole -- 2102
inner join [PerfectPracticeEmroch].[dbo].[uqobj_base] UQOBJ on UQOBJ.qlabel=UCODES_LABEL.id and UQOBJ.fieldnum=EQANSWER.fieldnum
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=EQANSWER.entitynum  
where UCODES_LABEL.codeclass='QC' 
and UQOBJ.labelname='Time of Accident'
) INCTIME on INCTIME.row_index=1 and INCTIME.entitynum=E.entitynum
left join
(
select 
	EQANSWER.answertext,
	E.entitynum,
	ROW_NUMBER() over(partition by E.entitynum order by E.entitynum ) as row_index
from [PerfectPracticeEmroch].[dbo].[eqanswer_base] EQANSWER
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] UCODES_LABEL on UCODES_LABEL.id=EQANSWER.entityrole -- 2102
inner join [PerfectPracticeEmroch].[dbo].[uqobj_base] UQOBJ on UQOBJ.qlabel=UCODES_LABEL.id and UQOBJ.fieldnum=EQANSWER.fieldnum
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=EQANSWER.entitynum  
where UCODES_LABEL.codeclass='QC' 
and UQOBJ.labelname='Detailed Accident Information'
) DETAIL on DETAIL.row_index=1 and DETAIL.entitynum=E.entitynum
left join
(
select 
	EQANSWER.answertext,
	E.entitynum,
	ROW_NUMBER() over(partition by E.entitynum order by E.entitynum ) as row_index
from [PerfectPracticeEmroch].[dbo].[eqanswer_base] EQANSWER
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] UCODES_LABEL on UCODES_LABEL.id=EQANSWER.entityrole -- 2102
inner join [PerfectPracticeEmroch].[dbo].[uqobj_base] UQOBJ on UQOBJ.qlabel=UCODES_LABEL.id and UQOBJ.fieldnum=EQANSWER.fieldnum
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=EQANSWER.entitynum  
where UCODES_LABEL.codeclass='QC' 
and UQOBJ.labelname='Incident Summary (what Happened)'
) SUMMARY on SUMMARY.row_index=1 and SUMMARY.entitynum=E.entitynum
left join
(
select 
	EQANSWER.answertext,
	E.entitynum,
	ROW_NUMBER() over(partition by E.entitynum order by E.entitynum ) as row_index
from [PerfectPracticeEmroch].[dbo].[eqanswer_base] EQANSWER
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] UCODES_LABEL on UCODES_LABEL.id=EQANSWER.entityrole -- 2102
inner join [PerfectPracticeEmroch].[dbo].[uqobj_base] UQOBJ on UQOBJ.qlabel=UCODES_LABEL.id and UQOBJ.fieldnum=EQANSWER.fieldnum
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=EQANSWER.entitynum  
where UCODES_LABEL.codeclass='QC' 
and UQOBJ.labelname='Injuries'
) INJ on INJ.row_index=1 and INJ.entitynum=E.entitynum
left join
(
select 
	EQANSWER.answertext,
	E.entitynum,
	ROW_NUMBER() over(partition by E.entitynum order by E.entitynum ) as row_index
from [PerfectPracticeEmroch].[dbo].[eqanswer_base] EQANSWER
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] UCODES_LABEL on UCODES_LABEL.id=EQANSWER.entityrole -- 2102
inner join [PerfectPracticeEmroch].[dbo].[uqobj_base] UQOBJ on UQOBJ.qlabel=UCODES_LABEL.id and UQOBJ.fieldnum=EQANSWER.fieldnum
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=EQANSWER.entitynum  
where UCODES_LABEL.codeclass='QC' 
and UQOBJ.labelname='Description of Incident'
) DSCRPTN on DSCRPTN.row_index=1 and DSCRPTN.entitynum=E.entitynum
left join
(
select 
	EQANSWER.answertext,
	E.entitynum,
	ROW_NUMBER() over(partition by E.entitynum order by E.entitynum ) as row_index
from [PerfectPracticeEmroch].[dbo].[eqanswer_base] EQANSWER
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] UCODES_LABEL on UCODES_LABEL.id=EQANSWER.entityrole -- 2102
inner join [PerfectPracticeEmroch].[dbo].[uqobj_base] UQOBJ on UQOBJ.qlabel=UCODES_LABEL.id and UQOBJ.fieldnum=EQANSWER.fieldnum
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=EQANSWER.entitynum  
where UCODES_LABEL.codeclass='QC' 
and UQOBJ.labelname='Facts of Incident'
) FACT on FACT.row_index=1 and FACT.entitynum=E.entitynum
left join
(
select 
	EQANSWER.answertext,
	E.entitynum,
	ROW_NUMBER() over(partition by E.entitynum order by E.entitynum ) as row_index
from [PerfectPracticeEmroch].[dbo].[eqanswer_base] EQANSWER
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] UCODES_LABEL on UCODES_LABEL.id=EQANSWER.entityrole -- 2102
inner join [PerfectPracticeEmroch].[dbo].[uqobj_base] UQOBJ on UQOBJ.qlabel=UCODES_LABEL.id and UQOBJ.fieldnum=EQANSWER.fieldnum
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=EQANSWER.entitynum  
where UCODES_LABEL.codeclass='QC' 
and UQOBJ.labelname='Brief description of injuries'
) BRIEF on BRIEF.row_index=1 and BRIEF.entitynum=E.entitynum



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

/*
select A.*
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS on CAS.cassCaseNumber = E.entityid
left join
(
select 
	EQANSWER.answertext,
	E.entitynum,
	ROW_NUMBER() over(partition by E.entitynum order by E.entitynum ) as row_index
from [PerfectPracticeEmroch].[dbo].[eqanswer_base] EQANSWER
inner join [dbo].[ucodes_label] UCODES_LABEL on UCODES_LABEL.id=EQANSWER.entityrole -- 2102
inner join [dbo].[uqobj_base] UQOBJ on UQOBJ.qlabel=UCODES_LABEL.id and UQOBJ.fieldnum=EQANSWER.fieldnum
inner join [dbo].[entities] E on E.casemarker=1 and E.entitynum=EQANSWER.entitynum  
where UCODES_LABEL.codeclass='QC' 
and UQOBJ.labelname='Date of Accident'
) A on A.row_index=1 and A.entitynum=E.entitynum
where E.entitynum=21523

select A.*
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS on CAS.cassCaseNumber = E.entityid
left join
(
select 
	EQANSWER.answertext,
	E.entitynum,
	ROW_NUMBER() over(partition by E.entitynum order by E.entitynum ) as row_index
from [PerfectPracticeEmroch].[dbo].[eqanswer_base] EQANSWER
inner join [dbo].[ucodes_label] UCODES_LABEL on UCODES_LABEL.id=EQANSWER.entityrole -- 2102
inner join [dbo].[uqobj_base] UQOBJ on UQOBJ.qlabel=UCODES_LABEL.id and UQOBJ.fieldnum=EQANSWER.fieldnum
inner join [dbo].[entities] E on E.casemarker=1 and E.entitynum=EQANSWER.entitynum  
where UCODES_LABEL.codeclass='QC' 
and UQOBJ.labelname='Detailed Accident Information'
) DETAIL on DETAIL.row_index=1 and DETAIL.entitynum=E.entitynum
*/

