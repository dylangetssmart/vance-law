

use SAPerfectPracticeEmroch
GO

---
---
--- saga=-1: consName="Unidentified Court"
---


if not exists (select * from [SAPerfectPracticeEmroch].[dbo].[sma_MST_OrgContacts] where consName='Unidentified Insurance Company' and saga=-4)
begin

insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_OrgContacts] 
(
    [consName],
    [connContactCtg],
    [connContactTypeID],
    [connRecUserID],
    [condDtCreated],
    [saga]
)

select  
    'Unidentified Insurance Company'	
							as [consName],
    2						as [connContactCtg],
    (select octnOrigContactTypeID FROM [dbo].[sma_MST_OriginalContactTypes] where octnContactCtgID=2 and octsDscrptn='Insurance Company') as [connContactTypeID],
    368						as [connRecUserID],	
    getdate()				as [condDtCreated],
    -4						as [saga]
end



