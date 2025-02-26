
use [SAPerfectPracticeEmroch]

/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Notes] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Notes] 
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_Notes]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Notes] enable trigger all
*/

---(0)---
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_Notes'))
begin
    ALTER TABLE [sma_TRN_Notes] ADD [saga] varchar(32) NULL; 
end
GO

---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Notes] disable trigger all
---

---(1)--- 
insert into sma_TRN_Notes 
( 
    notnCaseID,
    notnNoteTypeID,
    notmDescription,
    notmPlainText,
    notnContactCtgID,
    notnContactId,
    notsPriority,
    notnFormID,
    notnRecUserID,
    notdDtCreated,
    notnModifyUserID,
    notdDtModified,
    saga
) 
 select 
    0			    as notnCaseID,
    (select nttnNoteTypeID FROM sma_MST_NoteTypes where nttsCode='CONTACT') as notnNoteTypeID,
    PN.note		    as notmDescription,
    PN.note		    as notmPlainText,
    IOC.CTG		    as notnContactCtgID,
    IOC.CID		    as notnContactId,
    'Normal'		    as notsPriority,
    0			    as notnFormID,
    368			    as notnRecUserID,
    getdate()		    as notdDtCreated,
    NULL			    as notnModifyUserID,
    NULL			    as notdDtModified,
    'provider_notes:' + convert(varchar,PN.note_key)	 as saga
from [PerfectPracticeEmroch].[dbo].[provider_notes] PN
inner join IndvOrgContacts_Indexed IOC on IOC.SAGA=PN.name_id

---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Notes] enable trigger all
---



