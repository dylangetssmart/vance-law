use [SAPerfectPracticeEmroch]

/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Cases] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Cases] 
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_Cases]', RESEED, 0); 
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Cases] enable trigger all
*/



--(0)--
insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_CaseGroup]
( [cgpsCode],[cgpsDscrptn],[cgpnRecUserId],[cgpdDtCreated],[cgpnModifyUserID],[cgpdDtModified],[cgpnLevelNo],[IncidentTypeID],[LimitGroupStatuses]  )
select 
    'FORCONVERSION'			as [cgpsCode],
    A.[SA Case Group]		as [cgpsDscrptn],
    368						as [cgpnRecUserId],
    getdate()				as [cgpdDtCreated],
    null					as [cgpnModifyUserID],
    null					as [cgpdDtModified],
    null					as [cgpnLevelNo],
    (select IncidentTypeID from [SAPerfectPracticeEmroch].[dbo].[sma_MST_IncidentTypes] where Description='General Negligence')  
							as [IncidentTypeID],
    null					as [LimitGroupStatuses]
from
(
select distinct 
	[SA Case Group]
from [PerfectPracticeEmroch].[dbo].[CaseTypeMapping]
	except 
select cgpsDscrptn
from [SAPerfectPracticeEmroch].[dbo].[sma_MST_CaseGroup]
) A


--(1)--
update sma_MST_CaseType set cstsType=A.[SA Case Type],cstnGroupID=A.cstnGroupID
from 
(
	select 
		CST.cstnCaseTypeID as ID,
		MAP.[SA Case Type],
		MAP.cstnGroupID
	from [SAPerfectPracticeEmroch].[dbo].[sma_MST_CaseType] CST
	inner join 
	(
	select 
		[PP Case Type],[SA Case Group],[SA Case Type],
		(select cgpnCaseGroupID from sma_MST_caseGroup where cgpsDscrptn=[SA Case Group]) as cstnGroupID 
	from [PerfectPracticeEmroch].[dbo].[CaseTypeMapping]
	) MAP on MAP.[PP Case Type]=CST.cstsType and CST.VenderCaseType='EmrochCaseType'
) A
where cstnCaseTypeID=A.ID




--(2)--
update sma_MST_SiteMaps set  csmnParentId=7, csmbVisible=1,csmsTitle='AUTO ACC'
where csmnCaseGroupId=0 and csmsUniqueTitle = 'UDFs #1'

update sma_MST_SiteMaps set csmnParentId=7, csmbVisible=1,csmsTitle='FIRST CALL'
where csmnCaseGroupId=0 and csmsUniqueTitle = 'UDFs #2'

update sma_MST_SiteMaps set csmnParentId=7, csmbVisible=1,csmsTitle='CLIENT PERSONAL'
where csmnCaseGroupId=0 and csmsUniqueTitle = 'UDFs #3'

update sma_MST_SiteMaps set csmnParentId=7, csmbVisible=1,csmsTitle='AUTO INSURANCE'
where csmnCaseGroupId=0 and csmsUniqueTitle = 'UDFs #4'

update sma_MST_SiteMaps set csmnParentId=7, csmbVisible=1,csmsTitle='DEFAULT AUTOINS'
where csmnCaseGroupId=0 and csmsUniqueTitle = 'UDFs #5'
