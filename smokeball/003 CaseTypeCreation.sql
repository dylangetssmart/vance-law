INSERT INTO [dbo].[sma_MST_CaseGroup]
([cgpsCode],[cgpsDscrptn],[cgpnRecUserId],[cgpdDtCreated],[cgpnModifyUserID],[cgpdDtModified],[cgpnLevelNo],[cgpsIncidentScreen],[incident_type])
Select distinct '',[Case Group],368,getdate(),null,null,'','frmIncident','General Negligence'
FROM [Case$] where  not exists (select distinct replace([cgpsDscrptn],'','') from [sma_MST_CaseGroup] where replace([cgpsDscrptn],'','')=replace([Case Group],'All ','')) and isnull([Case Group],'')<>''
union
Select distinct '',[Case Group],368,getdate(),null,null,'','frmIncident','General Negligence'
FROM  [dbo].[matters_190807031217] where  not exists (select distinct replace([cgpsDscrptn],'','') from [sma_MST_CaseGroup] where replace([cgpsDscrptn],'','')=replace([Case Group],'All ','')) and isnull([Case Group],'')<>''

go

INSERT INTO [dbo].[sma_MST_CaseType]
([cstsCode],[cstsType],[cstsSubType],[cstnWorkflowTemplateID],[cstnExpectedResolutionDays],[cstnRecUserID]
,[cstdDtCreated],[cstnModifyUserID],[cstdDtModified],[cstnLevelNo],[cstbTimeTracking],[cstnGroupID],[cstnGovtMunType],[cstnIsMassTort]
,[cstnStatusID],[cstnStatusTypeID],cstbActive,cstbUseIncident1,cstsIncidentLabel1)

Select distinct '',[MatterType],'', null,720,368,getdate(),null,null,'',0,138,null,null,1,162,1,1,'Incident'
FROM [matters_190807031217] 
where  not exists (select isnull(cststype,'') from [sma_MST_CaseType] where  isnull(cststype,'')=isnull([MatterType],'')) 
and isnull([MatterType],'')<>'' and [MatterType]<>'NULL'

go

go
INSERT INTO [dbo].[sma_MST_CaseSubType]
([cstsCode],[cstnGroupID],[cstsDscrptn],[cstnRecUserId],[cstdDtCreated],[cstnModifyUserID],[cstdDtModified],[cstnLevelNo],[cstbDefualt],[saga],[cstnTypeCode])
Select distinct '',cstncasetypeid,'',368,getdate(),null,null,'',0,'',650
From [matters_190807031217]
left join sma_mst_casetype on cststype=[MatterType]
where not exists
(select * from [sma_MST_CaseSubType] where cstnGroupID=cstnCaseTypeID and cstnTypeCode=650 )

go
INSERT INTO [dbo].[sma_MST_SubRole]
([sbrsCode],[sbrnRoleID],[sbrsDscrptn],[sbrnCaseTypeID],[sbrnPriority],[sbrnRecUserID],[sbrdDtCreated]
,[sbrnModifyUserID],[sbrdDtModified],[sbrnLevelNo],[sbrbDefualt],[saga],[sbrnTypeCode])
Select distinct '',4,'(P)-Plaintiff',cstncasetypeid,null,368,getdate(),null,null,'',0,'',20
from [matters_190807031217]
left join sma_mst_casetype on cststype=[MatterType]
where  not exists (select * from [sma_MST_SubRole] where sbrnCaseTypeID=cstnCaseTypeID and sbrnRoleID=4 and sbrnTypeCode=20)
go
INSERT INTO [dbo].[sma_MST_SubRole]
([sbrsCode],[sbrnRoleID],[sbrsDscrptn],[sbrnCaseTypeID],[sbrnPriority],[sbrnRecUserID],[sbrdDtCreated]
,[sbrnModifyUserID],[sbrdDtModified],[sbrnLevelNo],[sbrbDefualt],[saga],[sbrnTypeCode])
Select distinct '',5,'(D)-Defendant',cstncasetypeid,null,368,getdate(),null,null,'',0,'',149
from [matters_190807031217]
left join sma_mst_casetype on cststype=[MatterType]
where  not exists (select * from [sma_MST_SubRole] where sbrnCaseTypeID=cstnCaseTypeID and sbrnRoleID=5 and sbrnTypeCode=149)
go
