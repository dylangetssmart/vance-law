
use SAPerfectPracticeEmroch
GO

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
	A.[SA Referring Source]	as [consName],
    2						as [connContactCtg],
    (select octnOrigContactTypeID FROM [dbo].[sma_MST_OriginalContactTypes] where octnContactCtgID=2 and octsDscrptn='General') as [connContactTypeID],
    368						as [connRecUserID],	
    getdate()				as [condDtCreated],
    -7						as [saga]
from
(
select distinct
	[SA Referring Source]
FROM [PerfectPracticeEmroch].[dbo].[Party7idtext_Mapping]
) A

