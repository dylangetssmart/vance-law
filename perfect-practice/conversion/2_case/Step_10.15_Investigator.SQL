
use [SAPerfectPracticeEmroch]
GO
/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Investigations] disable trigger all
delete [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Investigations]
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_Investigations]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Investigations] enable trigger all
*/



---(0)---
if exists (select * from sys.objects where name='Investigate_Helper' and type='U')
begin
	drop table Investigate_Helper
end
GO
create table Investigate_Helper (
	entitynum	varchar(32), 
	labelname	varchar(max), 
	answertext	varchar(max)
)

insert into Investigate_Helper ( entitynum,labelname,answertext )
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
	'Investigation To',
	'Investigator',
	'Investigation Details',
	'Investigator Assigned',
	'Investigator Assigned?',
	'Investigator?',
	'Date Investigation Assigned',
	'Date Investigation Received'
	)
) A where A.row_index=1
GO


---(0)---
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_Investigations'))
begin
    ALTER TABLE [sma_TRN_Investigations] ADD [saga] [varchar](32) NULL; 
end
GO


alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Investigations] disable trigger all

---(1)---
insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Investigations]
( [invnCaseID],[invnInvestigationTypeID],[invnInvestigatorID],[invnInvestigatorADID],[invnInvestigatorCtgID],[invsComments],[invnRecUserID],[invdDtCreated],[saga] )
select
		CAS.casnCaseID		as [invnCaseID],
		(select intnInvestigationTypeID from sma_MST_InvestigationTypes where intsDscrptn='Product Inspection')
							as [invnInvestigationTypeID],
		IOC.CID				as [invnInvestigatorID],
		IOC.AID				as [invnInvestigatorADID],
		IOC.CTG				as [invnInvestigatorCtgID],
		isnull(INV1.labelname + ' : ' + INV1.answertext + CHAR(13),'') +
		isnull(INV2.labelname + ' : ' + INV2.answertext + CHAR(13),'') +
		isnull(INV3.labelname + ' : ' + INV3.answertext + CHAR(13),'') +
		isnull(INV4.labelname + ' : ' + INV4.answertext + CHAR(13),'') +
		isnull(INV5.labelname + ' : ' + INV5.answertext + CHAR(13),'') +
		isnull(INV6.labelname + ' : ' + INV6.answertext + CHAR(13),'') +
		isnull(INV7.labelname + ' : ' + INV7.answertext + CHAR(13),'') +
		isnull(INV8.labelname + ' : ' + INV8.answertext + CHAR(13),'') +
		''					as [invsComments],
		368					as [invnRecUserID],
		getdate()			as [invdDtCreated],
		CAS.saga_entitynum	as [saga]
from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS 
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=CAS.saga_entitynum 
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=R.assocrole and CL.codeclass='EPR'
inner join [SAPerfectPracticeEmroch].[dbo].[IndvOrgContacts_Indexed] IOC on IOC.saga=ER.entitynum
left join Investigate_Helper INV1 on INV1.entitynum=R.entitynum and INV1.labelname=	'Investigation To'
left join Investigate_Helper INV2 on INV2.entitynum=R.entitynum and INV2.labelname=	'Investigator'
left join Investigate_Helper INV3 on INV3.entitynum=R.entitynum and INV3.labelname=	'Investigation Details'
left join Investigate_Helper INV4 on INV4.entitynum=R.entitynum and INV4.labelname=	'Investigator Assigned'
left join Investigate_Helper INV5 on INV5.entitynum=R.entitynum and INV5.labelname=	'Investigator Assigned?'
left join Investigate_Helper INV6 on INV6.entitynum=R.entitynum and INV6.labelname=	'Investigator?'
left join Investigate_Helper INV7 on INV7.entitynum=R.entitynum and INV7.labelname=	'Date Investigation Assigned'
left join Investigate_Helper INV8 on INV8.entitynum=R.entitynum and INV8.labelname=	'Date Investigation Received'
where CL.codelabel in ( 'Investigator')
GO

-----------
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Investigations] enable trigger all
-----------



-----------
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Investigations] disable trigger all
-----------

insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Investigations]
( [invnCaseID],[invnInvestigationTypeID],[invnInvestigatorID],[invnInvestigatorADID],[invnInvestigatorCtgID],[invsComments],[invnRecUserID],[invdDtCreated],[saga] )


select
		A.invnCaseID		as [invnCaseID],
		(select intnInvestigationTypeID from sma_MST_InvestigationTypes where intsDscrptn='Product Testing')
							as [invnInvestigationTypeID],
		NULL				as [invnInvestigatorID],
		NULL				as [invnInvestigatorADID],
		NULL				as [invnInvestigatorCtgID],
		A.invsComments		as [invsComments],
		368					as [invnRecUserID],
		getdate()			as [invdDtCreated],
		A.saga_entitynum	as [saga]
from
(
select
		CAS.casnCaseID		as [invnCaseID],
		2					as [invnInvestigationTypeID],
		isnull(INV1.labelname + ' : ' + INV1.answertext + CHAR(13),'') +
		isnull(INV2.labelname + ' : ' + INV2.answertext + CHAR(13),'') +
		isnull(INV3.labelname + ' : ' + INV3.answertext + CHAR(13),'') +
		isnull(INV4.labelname + ' : ' + INV4.answertext + CHAR(13),'') +
		isnull(INV5.labelname + ' : ' + INV5.answertext + CHAR(13),'') +
		isnull(INV6.labelname + ' : ' + INV6.answertext + CHAR(13),'') +
		isnull(INV7.labelname + ' : ' + INV7.answertext + CHAR(13),'') +
		isnull(INV8.labelname + ' : ' + INV8.answertext + CHAR(13),'') +
		''					as [invsComments],
		CAS.saga_entitynum	as saga_entitynum
from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS 
left join Investigate_Helper INV1 on INV1.entitynum=CAS.saga_entitynum and INV1.labelname=	'Investigation To'
left join Investigate_Helper INV2 on INV2.entitynum=CAS.saga_entitynum and INV2.labelname=	'Investigator'
left join Investigate_Helper INV3 on INV3.entitynum=CAS.saga_entitynum and INV3.labelname=	'Investigation Details'
left join Investigate_Helper INV4 on INV4.entitynum=CAS.saga_entitynum and INV4.labelname=	'Investigator Assigned'
left join Investigate_Helper INV5 on INV5.entitynum=CAS.saga_entitynum and INV5.labelname=	'Investigator Assigned?'
left join Investigate_Helper INV6 on INV6.entitynum=CAS.saga_entitynum and INV6.labelname=	'Investigator?'
left join Investigate_Helper INV7 on INV7.entitynum=CAS.saga_entitynum and INV7.labelname=	'Date Investigation Assigned'
left join Investigate_Helper INV8 on INV8.entitynum=CAS.saga_entitynum and INV8.labelname=	'Date Investigation Received'
where not exists ( select * from sma_TRN_Investigations where invnCaseID=CAS.casnCaseID )
) A where isnull(A.invsComments,'')<>''
-----------
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Investigations] enable trigger all
-----------

