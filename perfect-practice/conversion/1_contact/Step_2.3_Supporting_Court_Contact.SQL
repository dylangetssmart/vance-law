

use SAPerfectPracticeEmroch
GO

---
---
--- saga=-1: consName="Unidentified Court"
---


if not exists (select * from [SAPerfectPracticeEmroch].[dbo].[sma_MST_OrgContacts] where consName='Unidentified Court' and saga=-1)
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
    'Unidentified Court'			as [consName],
    2							as [connContactCtg],
    (select octnOrigContactTypeID FROM [dbo].[sma_MST_OriginalContactTypes] where octnContactCtgID=2 and octsDscrptn='Court') as [connContactTypeID],
    368						as [connRecUserID],	
    getdate()					as [condDtCreated],
    -1						as [saga]

end



