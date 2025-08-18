/*---
description: Creates a stored procedure to add breadcrumb columns to a specified table.

steps: >
  - 
  - source_id
  - source_db
  - source_ref

dependencies:
  -
---*/

--SELECT * FROM ShinerSA..sma_TRN_Discovery std
--SELECT * FROM ShinerSA..sma_MST_DiscoveryType smdt
--SELECT * FROM ShinerSA..sma_TRN_DiscoveryDepositionParties stddp
--SELECT * FROM ShinerSA..sma_TRN_DiscoveryDepositionRespondents stddr


--SELECT * FROM ShinerLitify..Discovery__c dc
--SELECT * FROM ShinerSA..sma_TRN_LitigationDiscovery stld
--SELECT * FROM ShinerSA..sma_MST_ServiceTypes

--delete from  ShinerSA..sma_TRN_DiscoveryDepositionRespondents 

use [VanceLawFirm_SA]
go




---
alter table [sma_TRN_LitigationDiscovery] disable trigger all
alter table [sma_TRN_DiscoveryDepositionRespondents] disable trigger all
go

exec AddBreadcrumbsToTable 'sma_TRN_LitigationDiscovery';
exec AddBreadcrumbsToTable 'sma_TRN_DiscoveryDepositionRespondents';
go

---

--/* ------------------------------------------------------------------------------
--[sma_TRN_LitigationDiscovery] Schema
--*/ ------------------------------------------------------------------------------

---- saga
--if not exists (
--	 select
--		 *
--	 from sys.columns
--	 where Name = N'saga'
--		 and object_id = OBJECT_ID(N'sma_TRN_LitigationDiscovery')
--	)
--begin
--	alter table [sma_TRN_LitigationDiscovery] add [saga] INT null;
--end

--go

---- source_id
--if not exists (
--	 select
--		 *
--	 from sys.columns
--	 where Name = N'source_id'
--		 and object_id = OBJECT_ID(N'sma_TRN_LitigationDiscovery')
--	)
--begin
--	alter table [sma_TRN_LitigationDiscovery] add [source_id] VARCHAR(MAX) null;
--end

--go

---- source_db
--if not exists (
--	 select
--		 *
--	 from sys.columns
--	 where Name = N'source_db'
--		 and object_id = OBJECT_ID(N'sma_TRN_LitigationDiscovery')
--	)
--begin
--	alter table [sma_TRN_LitigationDiscovery] add [source_db] VARCHAR(MAX) null;
--end

--go

---- source_ref
--if not exists (
--	 select
--		 *
--	 from sys.columns
--	 where Name = N'source_ref'
--		 and object_id = OBJECT_ID(N'sma_TRN_LitigationDiscovery')
--	)
--begin
--	alter table [sma_TRN_LitigationDiscovery] add [source_ref] VARCHAR(MAX) null;
--end

--go


/* ------------------------------------------------------------------------------
Discovery Types from [Discovery_Item]
*/ ------------------------------------------------------------------------------


-- SELECT distinct utd.Discovery_Item FROM VanceLawFirm_Needles..user_tab5_data utd
-- SELECT * FROM sma_MST_DiscoveryType smdt

insert into [dbo].[sma_MST_DiscoveryType]
	(
		[dstsCode],
		[dstsDescription],
		[dstsDescriptionType],
		[dstnRecUserID],
		[dstdDtCreated],
		[dstnModifyUserID],
		[dstdDtModified],
		[dstnLevelNo],
		[dstnCheckin],
		[dstnCheckinn],
		[dstncriteria]
	) select
		null			   as dstsCode,
		utd.Discovery_Item as dstsDescription,
		utd.Discovery_Item as dstsDescriptionType,
		368				   as dstnRecUserID,
		GETDATE()		   as dstdDtCreated,
		null			   as dstnModifyUserID,
		null			   as dstdDtModified,
		null			   as dstnLevelNo,
		null			   as dstnCheckin,
		null			   as dstnCheckinn,
		null			   as dstncriteria
	from (
	 select distinct
		 Discovery_Item
	 from VanceLawFirm_Needles..user_tab5_data
	 where Discovery_Item is not null
	) utd
	where
		not exists (
		 select
			 1
		 from [dbo].[sma_MST_DiscoveryType] d
		 where d.dstsDescription = utd.Discovery_Item
		);


go

/* ------------------------------------------------------------------------------
Insert Discoveries
*/ ------------------------------------------------------------------------------

insert into [dbo].[sma_TRN_LitigationDiscovery]
	(
		[CaseID],
		[EnteredDt],
		[TypeID],
		[MethodOfService],
		[ServedByID],
		[ResDescription],
		[DemandOrder],
		[OrderDt],
		[OnDate],
		[OnBeforeDt],
		[WithinDays],
		[FromDt],
		[DtToComply],
		[AppointmentID],
		[RecUserID],
		[ModifyUserID],
		[DtModified],
		[Deleted],
		[DeletedOn],
		[DeletedBy],
		[DissDocuments],
		[lidnRespondentType],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	) select
		cas.casnCaseID											  as CaseID,
		case
			when (utd.Date_Received not between '1900-01-01' and '2079-12-31')
				then null
			else utd.Date_Received
		end														  as EnteredDt,
		(
		 select
			 dstnDiscoveryTypeID
		 from sma_MST_DiscoveryType
		 where dstsDescription = utd.Discovery_Item
		)														  as TypeID,
		(
		 select
			 sctnSrvcTypeID
		 from sma_MST_ServiceTypes
		 where sctsDscrptn = 'Unspecified'
		)														  as MethodOfService,
		d.UNQCID												  as ServedByID,
		ISNULL('Discovery Name: ' + utd.Note + CHAR(13), '') +
		ISNULL('Document Description: ' + utd.All_Counsel_Copied + CHAR(13), '') +
		''														  as ResDescription,
		1														  as DemandOrder,
		null													  as OrderDt,
		null													  as OnDate,
		null													  as OnBeforeDt,
		null													  as WithinDays,
		null													  as FromDt,
		null													  as DtToComply,
		null													  as AppointmentID,
		368														  as RecUserID,
		null													  as ModifyUserID,
		null													  as DtModified,
		null													  as Deleted,
		null													  as DeletedOn,
		null													  as DeletedBy,
		null													  as DissDocuments,
		2														  as lidnRespondentType,
		null													  as [saga],
		'user_tab5_data.tab_id = ' + CONVERT(VARCHAR, utd.tab_id) as [source_id],
		'needles'												  as [source_db],
		'user_tab5_data'										  as [source_ref]
	--select * 
	from VanceLawFirm_Needles..user_tab5_data utd
	join sma_TRN_Cases cas
		on cas.saga = utd.case_id
	left join (
	 select
		 n.case_ID,
		 ioc.unqcid
	 from VanceLawFirm_Needles..user_tab5_name n
	 join VanceLawFirm_Needles..user_tab5_matter m
		 on n.ref_num = m.ref_num
	 join IndvOrgContacts_Indexed ioc
		 on ioc.saga = n.[user_name]
	 where m.field_Title like 'Received from Defendant'
		 and [user_name] <> 0
	) d
		on d.case_id = utd.case_id

go

/* ------------------------------------------------------------------------------
Respondents
*/ ------------------------------------------------------------------------------

--sma_TRN_DiscoveryDepositionRespondents

/*
-- check uniqueness
SELECT tab_id, COUNT(*) AS occurrences
FROM VanceLawFirm_Needles..user_tab5_data
GROUP BY tab_id
HAVING COUNT(*) > 1;
*/


-- Sent to Defendant
insert into [dbo].[sma_TRN_DiscoveryDepositionRespondents]
	(
		[DiscoveryID],
		[OldDiscoveryID],
		[RespondentID],
		[AppointmentID],
		[ConfAppointmentID],
		[TaskID],
		[CSWDt],
		[Comments],
		[ToClientDt],
		[ClientConfDt],
		[ClientRcvdDt],
		[RecUserID],
		[DtCreated],
		[ModifyUserID],
		[DtModified],
		[CSW],
		[CriticalDeadlinesID],
		[Deleted],
		[DeletedOn],
		[DeletedBy],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	) select
		ld.DiscoveryID as DiscoveryID,
		null		   as OldDiscoveryID,
		ioc.UNQCID	   as RespondentID,
		null		   as AppointmentID,
		null		   as ConfAppointmentID,
		null		   as TaskID,
		null		   as CSWDt,
		null		   as Comments,
		null		   as ToClientDt,
		null		   as ClientConfDt,
		null		   as ClientRcvdDt,
		368			   as RecUserID,
		GETDATE()	   as DtCreated,
		null		   as ModifyUserID,
		null		   as DtModified,
		null		   as CSW,
		null		   as CriticalDeadlinesID,
		null		   as Deleted,
		null		   as DeletedOn,
		null		   as DeletedBy,
		null		   as [saga],
		null		   as [source_id],
		'needles'	   as [source_db],
		null		   as [source_ref]
	--select m.field_title, n.case_id, n.[user_name], tab_id, ioc.*
	from VanceLawFirm_Needles..user_tab5_data utd
	join VanceLawFirm_Needles..user_tab5_name n
		on n.tab_id = utd.tab_id
			and n.user_name <> 0
	join VanceLawFirm_Needles.[dbo].[cases] C
		on C.casenum = utd.case_id
	join VanceLawFirm_Needles..user_tab5_matter m
		on n.ref_num = m.ref_num
			and m.mattercode = C.matcode
			and m.field_Title like 'Sent to Defendant'
	join IndvOrgContacts_Indexed ioc
		on ioc.saga = n.[user_name]
	join sma_TRN_LitigationDiscovery ld
		on ld.source_id = 'user_tab5_data.tab_id = ' + CONVERT(VARCHAR, n.tab_id)
go

-- Party_Receiving
insert into [dbo].[sma_TRN_DiscoveryDepositionRespondents]
	(
		[DiscoveryID],
		[OldDiscoveryID],
		[RespondentID],
		[AppointmentID],
		[ConfAppointmentID],
		[TaskID],
		[CSWDt],
		[Comments],
		[ToClientDt],
		[ClientConfDt],
		[ClientRcvdDt],
		[RecUserID],
		[DtCreated],
		[ModifyUserID],
		[DtModified],
		[CSW],
		[CriticalDeadlinesID],
		[Deleted],
		[DeletedOn],
		[DeletedBy],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	) select
		ld.DiscoveryID as DiscoveryID,
		null		   as OldDiscoveryID,
		ioc.UNQCID	   as RespondentID,
		null		   as AppointmentID,
		null		   as ConfAppointmentID,
		null		   as TaskID,
		null		   as CSWDt,
		null		   as Comments,
		null		   as ToClientDt,
		null		   as ClientConfDt,
		null		   as ClientRcvdDt,
		368			   as RecUserID,
		GETDATE()	   as DtCreated,
		null		   as ModifyUserID,
		null		   as DtModified,
		null		   as CSW,
		null		   as CriticalDeadlinesID,
		null		   as Deleted,
		null		   as DeletedOn,
		null		   as DeletedBy,
		null		   as [saga],
		null		   as [source_id],
		null		   as [source_db],
		null		   as [source_ref]
	from VanceLawFirm_Needles..user_tab5_data utd
	join VanceLawFirm_Needles..user_tab5_name n
		on n.tab_id = utd.tab_id
			and n.user_name <> 0
	join VanceLawFirm_Needles.[dbo].[cases] C
		on C.casenum = utd.case_id
	join VanceLawFirm_Needles..user_tab5_matter m
		on n.ref_num = m.ref_num
			and m.mattercode = C.matcode
			and m.field_Title like 'Party Receiving'
	join IndvOrgContacts_Indexed ioc
		on ioc.saga = n.[user_name]
	join sma_TRN_LitigationDiscovery ld
		on ld.source_id = 'user_tab5_data.tab_id = ' + CONVERT(VARCHAR, n.tab_id)
--from VanceLawFirm_Needles..user_tab5_name n
--join VanceLawFirm_Needles..user_tab5_matter m
--	on n.ref_num = m.ref_num
--join IndvOrgContacts_Indexed ioc
--	on ioc.saga = n.[user_name]
--join sma_TRN_LitigationDiscovery ld
--	on ld.source_id = 'user_tab5_data.tab_id = ' + CONVERT(VARCHAR, n.tab_id)
--where
--	m.field_Title like 'Party Receiving'
--	and
--	[user_name] <> 0
go


/*
-----------------------------------------------------
--INSERT REPSONDENT COMPLIED DATES
-----------------------------------------------------
INSERT INTO sma_TRN_DiscoveryDepositionRespondents (DiscoveryID, RespondentID, CSW, CSWDt, RecUserID, DtCreated )
SELECT ld.DiscoveryID, NULL, 1, e.ReceiveDate, ld.RecUserID, e.Created
FROM PrevailCarlieYoung..[evidence] e
JOIN sma_TRN_LitigationDiscovery ld on ld.saga = e.Ident
WHERE isnull(ReceiveDate,'')<>''

----------------------------------------------------------------
--INSERT RELATED DOCUMENTS
----------------------------------------------------------------
--ADD DOCUMENTS TO LITIGATION DISCOVERY RECORD
INSERT INTO sma_TRN_DocumentAttachments (FormId, RecordId, DocumentId, CaseId)
SELECT DISTINCT
	(select [ID] From sma_MST_DocumentAttachmentForms where [Name] = 'LitigationDiscovery') as FormID,
	r.DiscoveryID			as RecordID, 
	doc.docnDocumentId		as DocumentID,  --documentid
	r.CaseID				as CaseID
FROM sma_TRN_LitigationDiscovery r
JOIN sma_TRN_Documents doc on r.CaseID = doc.docnCaseID and r.saga = doc.saga

*/



---
alter table [sma_TRN_LitigationDiscovery] enable trigger all
alter table [sma_TRN_DiscoveryDepositionRespondents] enable trigger all
go
---