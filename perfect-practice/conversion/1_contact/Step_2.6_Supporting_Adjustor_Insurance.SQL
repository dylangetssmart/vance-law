

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
	A.refname				as [consName],
    2						as [connContactCtg],
    (select octnOrigContactTypeID FROM [dbo].[sma_MST_OriginalContactTypes] where octnContactCtgID=2 and octsDscrptn='Insurance Company') as [connContactTypeID],
    368						as [connRecUserID],	
    getdate()				as [condDtCreated],
    -6						as [saga]
from
(
	select distinct 
		ER.refname
	from [PerfectPracticeEmroch].[dbo].[entities] E
	inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=E.entitynum and E.casemarker=1
	inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum
	inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=R.assocrole and CL.codeclass='EPR'
	where CL.codelabel = 'ADJUSTOR'
) A

