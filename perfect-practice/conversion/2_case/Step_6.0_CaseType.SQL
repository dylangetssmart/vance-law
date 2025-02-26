use [SAPerfectPracticeEmroch]

/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Cases] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Cases] 
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_Cases]', RESEED, 0); 
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Cases] enable trigger all

select * from [SAPerfectPracticeEmroch].[dbo].[sma_MST_CaseType]
select csmnCaseGroupID,count(csmnCaseGroupID) from [SAPerfectPracticeEmroch].[dbo].[sma_MST_Sitemaps]
group by csmnCaseGroupID
*/


---(0)---
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga_entitynum' AND Object_ID = Object_ID(N'sma_TRN_Cases'))
begin
    ALTER TABLE [sma_TRN_Cases] ADD [saga_entitynum] varchar(32); 
end


---(0)--- ( Schery want a special group to host all the conversion cases )
if not exists ( select * from [SAPerfectPracticeEmroch].[dbo].[sma_MST_CaseGroup] where [cgpsDscrptn]='PerfectPractice' )
begin
  insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_CaseGroup]
  (
       [cgpsCode]
      ,[cgpsDscrptn]
      ,[cgpnRecUserId]
      ,[cgpdDtCreated]
      ,[cgpnModifyUserID]
      ,[cgpdDtModified]
      ,[cgpnLevelNo]
      ,[IncidentTypeID]
      ,[LimitGroupStatuses]
  )
  select 
    'FORCONVERSION'			as [cgpsCode],
    'PerfectPractice'		as [cgpsDscrptn],
    368						as [cgpnRecUserId],
    getdate()				as [cgpdDtCreated],
    null					as [cgpnModifyUserID],
    null					as [cgpdDtModified],
    null					as [cgpnLevelNo],
    (select IncidentTypeID from [SAPerfectPracticeEmroch].[dbo].[sma_MST_IncidentTypes] where Description='General Negligence')  
							as [IncidentTypeID],
    null					as [LimitGroupStatuses]
end
GO


---(0)--- 
if not exists ( select * from [SAPerfectPracticeEmroch].[dbo].[sma_mst_offices] where office_name='Emroch & Kilduff' )   
begin
insert into [SAPerfectPracticeEmroch].[dbo].[sma_mst_offices]
(
       [office_status]
      ,[office_name]
      ,[state_id]
      ,[is_default]
      ,[date_created]
      ,[user_created]
      ,[date_modified]
      ,[user_modified]
      ,[Letterhead]
      ,[UniqueContactId]
      ,[PhoneNumber]
)
SELECT 
       1			    as [office_status]
      ,'Emroch & Kilduff' as [office_name]
      ,(select sttnStateID from sma_MST_States where sttsDescription='Virginia') as [state_id]
      ,1			    as [is_default]
      ,getdate()	    as [date_created]
      ,'rdoshi'			as [user_created]
      ,getdate()	    as [date_modified]
      ,'dbo'		    as [user_modified]
      ,'LetterheadUt.docx' as [Letterhead]
      ,NULL				as [UniqueContactId]
      ,18018452455	    as [PhoneNumber]
end
GO

---(0)---
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'VenderCaseType' AND Object_ID = Object_ID(N'sma_MST_CaseType'))
BEGIN
	ALTER TABLE sma_MST_CaseType
	ADD VenderCaseType varchar(100)
END
GO

---(1)--- sma_MST_CaseType 
insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_CaseType]
(	   		
	  [cstsCode]
	 ,[cstsType]
	 ,[cstsSubType]
	 ,[cstnWorkflowTemplateID]
      ,[cstnExpectedResolutionDays]
      ,[cstnRecUserID]
      ,[cstdDtCreated]
      ,[cstnModifyUserID]
      ,[cstdDtModified]
      ,[cstnLevelNo]
      ,[cstbTimeTracking]
      ,[cstnGroupID]
      ,[cstnGovtMunType]
      ,[cstnIsMassTort]
      ,[cstnStatusID]
      ,[cstnStatusTypeID]
	 ,[cstbActive]
	 ,[cstbUseIncident1]
	 ,[cstsIncidentLabel1]
	 ,[VenderCaseType]
)

select 
	A.[id]				as cstsCode,	-- need to remember it
	A.[codelabel]		as cstsType,
	NULL			    as cstsSubType,
	NULL			    as cstnWorkflowTemplateID,
	720					as cstnExpectedResolutionDays, -- ( hardcode 2 years )
	368					as cstnRecUserID,
	getdate()		    as cstdDtCreated,
	368					as cstnModifyUserID,
	getdate()		    as cstdDtModified,
	0					as cstnLevelNo,
	null			    as cstbTimeTracking,
     (select cgpnCaseGroupID from sma_MST_caseGroup where cgpsDscrptn='PerfectPractice') as cstnGroupID, 
     null			    as cstnGovtMunType,
     null			    as cstnIsMassTort,
	162 -->(select cssnStatusID FROM [SAPerfectPracticeEmroch].[dbo].[sma_MST_CaseStatus] where csssDescription='Presign - Not Scheduled For Sign Up') 
						as cstnStatusID,
	(select stpnStatusTypeID FROM [SAPerfectPracticeEmroch].[dbo].[sma_MST_CaseStatusType] where stpsStatusType='Status')	as cstnStatusTypeID,
	1					as cstbActive,
	1					as cstbUseIncident1,
	'Incident 1'	    as cstsIncidentLabel1,
	'EmrochCaseType'	as VenderCaseType
from
(
select distinct 
	C.id,C.codeclass,C.codelabel
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] C on C.id=E.entityrole_id
where codeclass='CT' -- inticate "Case Type"
) A

--from [PerfectPracticeEmroch].[dbo].[matter] M
--inner join [SAPerfectPracticeEmroch].[dbo].[CaseTypeMixture] MIX on MIX.matcode=M.matcode  
--where isnull(MIX.[SmartAdvocate Case Type],'')=''  -- Create only those case type that were not in CaseTypeMixture --
GO


-----(1)--- catalog all conversion case types
--update [SAPerfectPracticeEmroch].[dbo].[sma_MST_CaseType] set cstsCode=A.matcode, VenderCaseType='EmrochCaseType'
--from
--(
--    select 
--	   CST.cstnCaseTypeID	  as ID,		-- casetype specified in CaseTypeMixture    
--	   MIX.matcode			  as matcode	-- matcode of specified the casetype 
--    from [PerfectPracticeEmroch].[dbo].[matter] M
--    inner join [SAPerfectPracticeEmroch].[dbo].[CaseTypeMixture] MIX on MIX.matcode=M.matcode  
--    inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_CaseType] CST on CST.cstsType=MIX.[SmartAdvocate Case Type]  
--    where isnull([SmartAdvocate Case Type],'')<>''
--) A  where A.ID=cstnCaseTypeID

-----(1)--- check outcome.
--select convert(varchar,count(*)) as NumberOfCasetype 
--from [SAPerfectPracticeEmroch].[dbo].[sma_MST_CaseType] CST 
--inner join [PerfectPracticeEmroch].[dbo].[matter] M on M.matcode=CST.cstsCode
--where VenderCaseType='EmrochCaseType'

---(2.0)--- sma_MST_CaseSubTypeCode
--insert into [dbo].[sma_MST_CaseSubTypeCode] ( stcsDscrptn )
--select distinct MIX.[SmartAdvocate Case Sub Type]
--from [SAPerfectPracticeEmroch].[dbo].[CaseTypeMixture] MIX where isnull(MIX.[SmartAdvocate Case Sub Type],'')<>''
--    except
--select stcsDscrptn from [dbo].[sma_MST_CaseSubTypeCode]

---(2.1)--- sma_MST_CaseSubType 
insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_CaseSubType]
(
       [cstsCode]
      ,[cstnGroupID]
      ,[cstsDscrptn]
      ,[cstnRecUserId]
      ,[cstdDtCreated]
      ,[cstnModifyUserID]
      ,[cstdDtModified]
      ,[cstnLevelNo]
      ,[cstbDefualt]
      ,[saga]
      ,[cstnTypeCode]
)
select	null				as [cstsCode],
		CST.cstnCaseTypeID	as [cstnGroupID],
		'unknown'			as [cstsDscrptn], 
		368 				as [cstnRecUserId],
		getdate()			as [cstdDtCreated],
		null				as [cstnModifyUserID],
		null				as [cstdDtModified],
		null				as [cstnLevelNo],
		1					as [cstbDefualt],
		null				as [saga],
		(select stcnCodeId from [sma_MST_CaseSubTypeCode] where stcsDscrptn='Unknown')
							as [cstnTypeCode] 
from [SAPerfectPracticeEmroch].[dbo].[sma_MST_CaseType] CST 
where CST.[VenderCaseType]='EmrochCaseType'
and not exists ( select * from [dbo].[sma_MST_CaseSubType] where [cstnGroupID]=CST.cstnCaseTypeID and CST.VenderCaseType='EmrochCaseType') 

--- (3.0) sma_MST_SubRole ----
--INSERT INTO [sma_MST_SubRole]
--([sbrsCode],[sbrnRoleID],[sbrsDscrptn],[sbrnCaseTypeID],[sbrnPriority],[sbrnRecUserID],[sbrdDtCreated],[sbrnModifyUserID],[sbrdDtModified],[sbrnLevelNo],[sbrbDefualt],[saga])
--Select 
--	[sbrsCode]			as [sbrsCode],
--	[sbrnRoleID]		as [sbrnRoleID],
--	[sbrsDscrptn]		as [sbrsDscrptn],
--	CST.cstnCaseTypeID	as [sbrnCaseTypeID],
--	[sbrnPriority]		as [sbrnPriority],
--	[sbrnRecUserID]		as [sbrnRecUserID],
--	[sbrdDtCreated]		as [sbrdDtCreated],
--	[sbrnModifyUserID]	as [sbrnModifyUserID],
--	[sbrdDtModified]	as [sbrdDtModified],
--	[sbrnLevelNo]		as [sbrnLevelNo],
--	[sbrbDefualt]		as [sbrbDefualt],
--	[saga]				as [saga] 
--from sma_MST_CaseType CST
--left join sma_MST_SubRole S on CST.cstnCaseTypeID=S.sbrnCaseTypeID or S.sbrnCaseTypeID=1
--inner join [SAPerfectPracticeEmroch].[dbo].[CaseTypeMixture] MIX on MIX.matcode=CST.cstsCode  
--where VenderCaseType='EmrochCaseType'
--and isnull(MIX.[SmartAdvocate Case Type],'')=''

---- (3.1) sma_MST_SubRole : use the sma_MST_SubRole.sbrsDscrptn value to set the sma_MST_SubRole.sbrnTypeCode field ---
--update sma_MST_SubRole set sbrnTypeCode=A.CodeId
--from
--(
--	select
--	S.sbrsDscrptn		as sbrsDscrptn,
--	S.sbrnSubRoleId	as SubRoleId, 
--	(select max(srcnCodeId) from sma_MST_SubRoleCode where srcsDscrptn=S.sbrsDscrptn) as CodeId
--from sma_MST_SubRole S
--inner join sma_MST_CaseType CST on CST.cstnCaseTypeID=S.sbrnCaseTypeID and CST.VenderCaseType='EmrochCaseType'
--) A
--where A.SubRoleId = sbrnSubRoleId

---(4.0)--- specific party roles --- sizeof(R)
insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_SubRoleCode] ( srcsDscrptn, srcnRoleID )
(
	select '(P)-Default Role', 4 
		union all
	select '(D)-Default Role', 5
	--	union all
	--select [SA Roles],4 from [PerfectPracticeEmroch].[dbo].[PartyRoles] where [SA Party]='Plaintiff'
	--	union all
	--select [SA Roles],5 from [PerfectPracticeEmroch].[dbo].[PartyRoles] where [SA Party]='Defendant'
)
    except
select srcsDscrptn, srcnRoleID from [SAPerfectPracticeEmroch].[dbo].[sma_MST_SubRoleCode]


---(4.1)--- sma_MST_SubRole --- sizeof( CST x R )
insert into [SAPerfectPracticeEmroch].[dbo].sma_MST_SubRole ( sbrnRoleID,sbrsDscrptn,sbrnCaseTypeID,sbrnTypeCode)

select 
	T.sbrnRoleID,
	T.sbrsDscrptn,
	T.sbrnCaseTypeID,
	T.sbrnTypeCode
from 
(
    select 
		R.PorD					as sbrnRoleID,
		R.role					as sbrsDscrptn,
		CST.cstnCaseTypeID	    as sbrnCaseTypeID,
		(select SRC.srcnCodeId from sma_MST_SubRoleCode SRC where SRC.srcsDscrptn = R.role and SRC.srcnRoleID = R.PorD) 
								as sbrnTypeCode
		from sma_MST_CaseType CST
		cross join 
		(
			select '(P)-Default Role' as role, 4 as PorD
				union all
			select '(D)-Default Role' as role, 5 as PorD
			--	union all
			--select [SA Roles]  as role, 4 as PorD from [PerfectPracticeEmroch].[dbo].[PartyRoles] where [SA Party]='Plaintiff'
			--	union all
			--select [SA Roles]  as role, 5 as PorD from [PerfectPracticeEmroch].[dbo].[PartyRoles] where [SA Party]='Defendant'
		) R
		where CST.VenderCaseType='EmrochCaseType'
) T
	except 
select sbrnRoleID,sbrsDscrptn,sbrnCaseTypeID,sbrnTypeCode from sma_MST_SubRole

/* 
---Check it out: Should have as many rows as CaseType---
select CST.cstnCaseTypeID,CST.cstsType,sbrsDscrptn
from sma_MST_SubRole S
inner join [SAPerfectPracticeEmroch].[dbo].sma_MST_CaseType CST on CST.cstnCaseTypeID=S.sbrnCaseTypeID
where CST.VenderCaseType='EmrochCaseType'
and sbrsDscrptn='(D)-Default Role'
order by CST.cstnCaseTypeID
*/

---(5)--- sma_TRN_cases 
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Cases] disable trigger all

insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Cases]
( 
  [cassCaseNumber],[casbAppName],[cassCaseName],[casnCaseTypeID],[casnState],[casdStatusFromDt],[casnStatusValueID],[casdsubstatusfromdt],[casnSubStatusValueID],[casdOpeningDate],
  [casdClosingDate],[casnCaseValueID],[casnCaseValueFrom],[casnCaseValueTo],[casnCurrentCourt],[casnCurrentJudge],[casnCurrentMagistrate],[casnCaptionID],[cassCaptionText],
  [casbMainCase],[casbCaseOut],[casbSubOut],[casbWCOut],[casbPartialOut],[casbPartialSubOut],[casbPartiallySettled],[casbInHouse],[casbAutoTimer],[casdExpResolutionDate],
  [casdIncidentDate],[casnTotalLiability],[cassSharingCodeID],[casnStateID],[casnLastModifiedBy],[casdLastModifiedDate],[casnRecUserID],[casdDtCreated],[casnModifyUserID],
  [casdDtModified],[casnLevelNo],[cassCaseValueComments],[casbRefIn],[casbDelete],[casbIntaken],[casnOrgCaseTypeID],[CassCaption],[cassMdl],[office_id],[saga],
  [LIP],[casnSeriousInj],[casnCorpDefn],[casnWebImporter],[casnRecoveryClient],[cas],[ngage],[casnClientRecoveredDt],[CloseReason],[AutoUpdateName],[saga_entitynum]
)

SELECT 
	E.entityid			as cassCaseNumber,
    '' 					as casbAppName,
    E.refname			as cassCaseName,
	( select cstnCaseSubTypeID from [dbo].[sma_MST_CaseSubType] ST where ST.cstnGroupID = CST.cstnCaseTypeID and ST.cstsDscrptn='Unknown' ) 
						as casnCaseTypeID,
	(select [sttnStateID] from [SAPerfectPracticeEmroch].[dbo].[sma_MST_States] where [sttsDescription]='Virginia') 
						as casnState,
    GETDATE()			as casdStatusFromDt,
    162	-->(select cssnStatusID FROM [SAPerfectPracticeEmroch].[dbo].[sma_MST_CaseStatus] where csssDescription='Presign - Not Scheduled For Sign Up')
						as casnStatusValueID,
    GETDATE()			as casdsubstatusfromdt,
    162	-->(select cssnStatusID FROM [SAPerfectPracticeEmroch].[dbo].[sma_MST_CaseStatus] where csssDescription='Presign - Not Scheduled For Sign Up')
						as casnSubStatusValueID,
	try_convert(date,E.dateopen)	as casdOpeningDate,
	case
		when try_convert(date,E.dateopen) < try_convert(date,'12/31/2014') then try_convert(date,'12/31/2014') --> Susan
		else try_convert(date,E.dateclosed)	
	end					as casdClosingDate, 
	null,null,null,null,null,null,0,
	E.refname			as cassCaptionText,
	1,0,0,0,0,0,0,1,null,null,null,0,0,
	(select [sttnStateID] from [SAPerfectPracticeEmroch].[dbo].[sma_MST_States] where [sttsDescription]='Virginia') 
    					as casnStateID,
    null,null,
	null					as casnRecUserID,
	try_convert(date,E.dateentered)	as casdDtCreated,
    null,null,'','',null,null,null,
    CST.cstnCaseTypeID	as casnOrgCaseTypeID,
    ''					as CassCaption,
    0					as cassMdl,
    (select office_id from sma_MST_Offices where office_name='Emroch & Kilduff') 
						as office_id,
    '',null,null,null,null,null,null,null,null,
    0					as CloseReason,
	0					as AutoUpdateName,
	E.entitynum			as saga_entitynum
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_CaseType] CST on CST.cstsType=E.entityrole and CST.VenderCaseType='EmrochCaseType'
where E.casemarker=1	--> got to be 1 here!

---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Cases] enable trigger all
---

---Appendix---
DBCC DBREINDEX('sma_TRN_Cases',' ',90) WITH NO_INFOMSGS 




