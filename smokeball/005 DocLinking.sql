
INSERT INTO [sma_TRN_Documents]
([docnCaseID],[docsDocumentName],[docsDocumentPath],[docsDocumentData],[docnCategoryID],[docnSubCategoryID],[docnFromContactCtgID]
,[docnFromContactID],[docsToContact],[docsDocType],[docnTemplateID],[docbAttachFlag],[docsDescrptn],[docnAuthor],[docsDocsrflag]
,[docnRecUserID],[docdDtCreated],[docnModifyUserID],[docdDtModified],[docnLevelNo],[ctgnCategoryID],[sctnSubCategoryID],[sctssSubSubCategoryID]
,[sctsssSubSubSubCategoryID],[docnMedProvContactctgID],[docnMedProvContactID],[docnComments],[docnReasonReject],[docsReviewerContactId]
,[docsReviewDate],[docsDocumentAnalysisResultId],[docsIsReviewed],[docsToContactID],[docsToContactCtgID],[docdLastUpdated],[docnPriority])
Select distinct casncaseid,null,
substring(replace(f1,'F:','\\SA'),0,1000),'',52,371,
null
,null,'','Doc',null,null,substring(ISNULL(f5,'')+isnull(char(13)+f6,'')+isnull(char(13)+f7,''),0,200),0,'',368,GETDATE(),
null,null,'',52,371,'','','','','','',null,null,null,null,null,null,null,3
from [print$]
JOIN sma_trn_cases on cassCaseNumber=case when f5 like '% %' then left(f5, charindex(' ', f5) - 1)  end

 where casncaseid is not null and f1 like '%.%'
 order by casncaseid
 go
 INSERT INTO [sma_TRN_Documents]
([docnCaseID],[docsDocumentName],[docsDocumentPath],[docsDocumentData],[docnCategoryID],[docnSubCategoryID],[docnFromContactCtgID]
,[docnFromContactID],[docsToContact],[docsDocType],[docnTemplateID],[docbAttachFlag],[docsDescrptn],[docnAuthor],[docsDocsrflag]
,[docnRecUserID],[docdDtCreated],[docnModifyUserID],[docdDtModified],[docnLevelNo],[ctgnCategoryID],[sctnSubCategoryID],[sctssSubSubCategoryID]
,[sctsssSubSubSubCategoryID],[docnMedProvContactctgID],[docnMedProvContactID],[docnComments],[docnReasonReject],[docsReviewerContactId]
,[docsReviewDate],[docsDocumentAnalysisResultId],[docsIsReviewed],[docsToContactID],[docsToContactCtgID],[docdLastUpdated],[docnPriority])
Select distinct casncaseid,null,
substring(replace(f1,'F:','\\SA'),0,1000),'',52,371,
null
,null,'','Doc',null,null,substring(ISNULL(f5,'')+isnull(char(13)+f6,'')+isnull(char(13)+f7,''),0,200),0,'',368,GETDATE(),
null,null,'',52,371,'','','','','','',null,null,null,null,null,null,null,3
from sma_trn_cases
JOIN sma_TRN_Plaintiff on plnnCaseID=casnCaseID
JOIN sma_MST_AllContactInfo on plnnContactCtg=ContactCtg and plnnContactID=ContactId
JOIN sma_MST_CaseType on cstnCaseTypeID=casnOrgCaseTypeID
JOIN [print$] on f5 like  NameForLetters+' - '+cstsType+'%'
 where casncaseid is not null and f1 like '%.%' and not exists(select * from sma_TRN_Documents where docsDocumentPath=f1)
 order by casncaseid
 go
 

 update sma_TRN_Documents
set docsDocumentName=RIGHT( docsDocumentPath, CHARINDEX( '\', REVERSE( docsDocumentPath ) + '\' ) - 1 ),
docsDocumentPath=REPLACE(docsDocumentPath,RIGHT( docsDocumentPath, CHARINDEX( '\', REVERSE( docsDocumentPath ) + '\' ) - 1 ),'')
where docsDocumentName is null
 
 go
 update sma_TRN_Documents set docsDocumentPath=replace(docsDocumentPath,'e:','\\LLGSQL1')
 go
 select *,replace(directoryname+'\'+name,'e:','\\LLGSQL1') as FulPath into Export1 from [export]
go
update d set docdDtCreated=lastwritetime from Export1
JOIN sma_trn_documents d on FullPath=FulPath
where FulPath is not null
go
drop table Export1
go
-- select RIGHT( docsDocumentPath, CHARINDEX( '\', REVERSE( docsDocumentPath ) + '\' ) - 1 ),* from sma_TRN_Documents
--where docsDocumentName is null 