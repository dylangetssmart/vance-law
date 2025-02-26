
use SAPerfectPracticeEmroch
GO

/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_PlaintiffInjury] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_PlaintiffInjury] 
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_PlaintiffInjury]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_PlaintiffInjury] enable trigger all
*/



---(0)---
if exists (select * from sys.objects where name='Injury_Helper' and type='U')
begin
	drop table Injury_Helper
end
GO
create table Injury_Helper (
	entitynum	varchar(32), 
	labelname	varchar(max), 
	answertext	varchar(max)
)

insert into Injury_Helper ( entitynum,labelname,answertext )
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
	'Injuries',
	'Injuries/Scars?',
	'Injuries:  List'
	)
) A where A.row_index=1
GO



---(0)---
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_PlaintiffInjury'))
begin
    ALTER TABLE [sma_TRN_PlaintiffInjury] ADD [saga] [varchar](20) NULL; 
end
GO
--(1)--
insert into [dbo].[sma_TRN_PlaintiffInjury]
(
       [plinPlaintiffID]
      ,[plinCaseID]
      ,[plisInjuriesSummary]
      ,[plisPleadingsSummary]
      ,[plisComment]
      ,[plinRecUserID]
      ,[plidDtCreated]
      ,[plinModifyUserID]
      ,[plidDtModified]
	  ,[saga]
)
select
		(select plnnPlaintiffID from sma_TRN_Plaintiff where plnnCaseID=CAS.casnCaseID and plnbIsPrimary=1 )		
							as [plinPlaintiffID],
		CAS.casnCaseID		as [plinCaseID],
		isnull(INJ.labelname + ' : ' + INJ.answertext + CHAR(13),'') +
		isnull(INS.labelname + ' : ' + INS.answertext + CHAR(13),'') +
		isnull(INL.labelname + ' : ' + INL.answertext + CHAR(13),'') +
		
		''					as [plisInjuriesSummary],
		null				as [plisPleadingsSummary],
		null				as [plisComment],
		368					as [plinRecUserID],
		getdate()			as [plidDtCreated],
		null				as [plinModifyUserID],
		null				as [plidDtModified],
		null				as [saga]
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS on CAS.saga_entitynum = E.entitynum	  
left join Injury_Helper INJ on INJ.entitynum=E.entitynum and INJ.labelname='Injuries'
left join Injury_Helper INS on INS.entitynum=E.entitynum and INS.labelname='Injuries/Scars?'
left join Injury_Helper INL on INL.entitynum=E.entitynum and INL.labelname='Injuries:  List'



-----------------------------

