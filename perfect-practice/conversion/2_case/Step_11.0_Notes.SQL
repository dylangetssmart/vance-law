

use [SAPerfectPracticeEmroch]

/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Notes] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Notes] 
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_Notes]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Notes] enable trigger all

--SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_TYPE='FOREIGN KEY' AND CONSTRAINT_NAME LIKE '%sma_TRN_Notes%'
--ALTER TABLE sma_TRN_TaskNew DROP CONSTRAINT FK_sma_TRN_TaskNew_sma_TRN_Notes;
--truncate table sma_TRN_Notes

select * from sma_TRN_Notes
*/


---(0)---
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_Notes'))
begin
    ALTER TABLE [sma_TRN_Notes] ADD [saga] varchar(32) NULL; 
end
GO

----(0)----
insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_NoteTypes] ( nttsDscrptn, nttsNoteText )
select A.nttsDscrptn,A.nttsDscrptn
from
(
select distinct 
	CL.codelabel as nttsDscrptn
FROM [PerfectPracticeEmroch].[dbo].[transactions] T
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=T.actcode
--where CL.codelabel like '%_NOTES'
where T.trantype=0 -- Notes
    except
select nttsDscrptn from [SAPerfectPracticeEmroch].[dbo].[sma_MST_NoteTypes] where isnull(nttsDscrptn,'')<>''
) A
GO

---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Notes] disable trigger all
---
----(1)----
insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Notes]
(
      [notnCaseID],[notnNoteTypeID],[notmDescription],[notmPlainText],[notnContactCtgID],[notnContactId],[notsPriority],[notnFormID],[notnRecUserID],
      [notdDtCreated],[notnModifyUserID],[notdDtModified],[notnLevelNo],[notdDtInserted],[WorkPlanItemId],[notnSubject],[saga]
)
select 
    CAS.casnCaseID	 as [notnCaseID],
	(select nttnNoteTypeID from [SAPerfectPracticeEmroch].[dbo].[sma_MST_NoteTypes] where nttsDscrptn=CL.codelabel) as [notnNoteTypeID],

    T.trantext		as [notmDescription],
    T.trantext		as [notmPlainText],
    0				as [notnContactCtgID],
    null			as [notnContactId],
    null			as [notsPriority],
    null			as [notnFormID],
	(
		select U.usrnUserID
		from [PerfectPracticeEmroch].[dbo].[uusers] UU 
		inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Users] U on U.saga = UU.userid
		where UU.entitynum=T.accompby
	)
					as [notnRecUserID],
    try_convert(datetime,T.startdtact)			 as notdDtCreated,
    null			as [notnModifyUserID],
    null			as notdDtModified,
    null			as [notnLevelNo],
    null			as [notdDtInserted],
    null			as [WorkPlanItemId],
    null			as [notnSubject],
	T.id			as [saga]
FROM [PerfectPracticeEmroch].[dbo].[transactions] T
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=T.actcode
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=T.entitynum  
inner join [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS on CAS.cassCaseNumber = E.entityid
--where CL.[codeclass] in ( '0','3','4','5','7','8' )
where T.trantype=0 -- Notes
GO
---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Notes] enable trigger all
---


