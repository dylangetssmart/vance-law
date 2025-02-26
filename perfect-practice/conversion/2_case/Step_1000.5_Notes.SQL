

use [SAPerfectPracticeEmroch]

---(0)---
alter table [dbo].[sma_TRN_Notes] disable trigger all
delete [dbo].[sma_TRN_Notes] 
from
(
select N.notnNoteID as ID
from [dbo].[sma_TRN_Notes] N
inner join [PerfectPracticeEmroch].[dbo].[transactions] T on T.id=N.[saga]
where T.trantype=0 -- Notes
) A where notnNoteID=A.ID
alter table [dbo].[sma_TRN_Notes] enable trigger all
GO

---
alter table [dbo].[sma_TRN_Notes] disable trigger all
---
----(1)----
insert into [dbo].[sma_TRN_Notes]
(
      [notnCaseID],[notnNoteTypeID],[notmDescription],[notmPlainText],[notnContactCtgID],[notnContactId],[notsPriority],[notnFormID],[notnRecUserID],
      [notdDtCreated],[notnModifyUserID],[notdDtModified],[notnLevelNo],[notdDtInserted],[WorkPlanItemId],[notnSubject],[saga]
)
select 
    CAS.casnCaseID	 as [notnCaseID],
	(select nttnNoteTypeID from [dbo].[sma_MST_NoteTypes] where nttsDscrptn=CL.codelabel) as [notnNoteTypeID],

    T.trantext		as [notmDescription],
    T.trantext		as [notmPlainText],
    0				as [notnContactCtgID],
    null			as [notnContactId],
    null			as [notsPriority],
    null			as [notnFormID],
	(select M.usrnUserID from usermap_helper M where M.entitynum=T.accompby)
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
left join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=T.actcode
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=T.entitynum  
inner join [dbo].[sma_TRN_cases] CAS on CAS.cassCaseNumber = E.entityid
where T.trantype=0 -- Notes
GO
---
alter table [dbo].[sma_TRN_Notes] enable trigger all
---


select count(*) from [dbo].[sma_TRN_Notes]
