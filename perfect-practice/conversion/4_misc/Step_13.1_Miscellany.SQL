
use SAPerfectPracticeEmroch
GO


---(1)--- Case Browse does not show Attorney/Paralegal ---
TRUNCATE TABLE sma_TRN_RoleCaseStuffMainRoles
GO

IF (SELECT COUNT(*) FROM sma_TRN_RoleCaseStuffMainRoles)=0
BEGIN
                INSERT INTO sma_TRN_RoleCaseStuffMainRoles([CaseID],[AttyContactID],[ParalegalContactID],                [CaseManagerContactID])
                SELECT cssnCaseID AS CaseID,  [1], [2],[3]
                FROM
                (SELECT SS.cssnCaseID, SS.cssnStaffID, RG.RoleGroupID
                FROM sma_TRN_CaseStaff SS
                JOIN sma_MST_RolePriorityGroup RG ON RoleID = cssnRoleID and SS.cssdToDate IS NULL
                OUTER APPLY   (
                                SELECT TOP 1  cssnCaseID AS CaseID, RoleGroupID, PriorityFlag, cssnStaffID , cssnPKID
                                FROM  sma_TRN_CaseStaff sss
                                JOIN sma_MST_RolePriorityGroup RF ON RoleID = cssnRoleID
                                WHERE sss.cssdToDate IS NULL and sss.cssnCaseID  IS NOT NULL and sss.cssnCaseID = SS.cssnCaseID and RG.RoleGroupID = RF.RoleGroupID
                                ORDER BY CAseID, PriorityFlag, sss.cssdFromDate) dddd
                WHERE dddd.CaseID = SS.cssnCaseID and dddd.cssnPKID = ss.cssnPKID and  dddd.RoleGroupID is not null) AS SourceTable
                PIVOT
                (
                AVG(cssnStaffID)
                FOR RoleGroupID IN ([1], [2],[3])
                ) AS PivotTable
END

GO


---(2)--- Remove sma_MST_Religion garbage
  delete [dbo].[sma_MST_Religion]
  from
  (
  select 
    rlgnReligionID as ID,
    rlgsReligion
  FROM [dbo].[sma_MST_Religion]
  where not (rlgnReligionID<=19 or rlgnReligionID=31)
  ) A
  where rlgnReligionID=A.ID
GO


---(Appendix)--- normalize phone format
alter table sma_MST_ContactNumbers disable trigger all

update sma_MST_ContactNumbers set cnnsContactNumber=
    case
	   when len(dbo.RemoveAlphaCharactersN(cnnsContactNumber))=10 then '(' + SUBSTRING(dbo.RemoveAlphaCharactersN(cnnsContactNumber),1,3) + ') ' + SUBSTRING(dbo.RemoveAlphaCharactersN(cnnsContactNumber),4,3) + '-' + SUBSTRING(dbo.RemoveAlphaCharactersN(cnnsContactNumber),7,4) 
	   when len(dbo.RemoveAlphaCharactersN(cnnsContactNumber))=11 and left(dbo.RemoveAlphaCharactersN(cnnsContactNumber),1)='1' then '(' + SUBSTRING(dbo.RemoveAlphaCharactersN(cnnsContactNumber),2,3) + ') ' + SUBSTRING(dbo.RemoveAlphaCharactersN(cnnsContactNumber),5,3) + '-' + SUBSTRING(dbo.RemoveAlphaCharactersN(cnnsContactNumber),8,4)
	   else dbo.RemoveAlphaCharactersN(cnnsContactNumber)
    end 

alter table sma_MST_ContactNumbers enable trigger all
GO

---(Appendix)--- initialize DigitContactNumber

alter table sma_MST_ContactNumbers disable trigger all

update sma_MST_ContactNumbers set DigitContactNumber=dbo.RemoveAlphaCharactersN(cnnsContactNumber)
where len(cnnsContactNumber)=14 or len(cnnsContactNumber)=7

alter table sma_MST_ContactNumbers enable trigger all


---(Appendix)--- Synchronize sma_TRN_userPreference / sma_MST_Users
delete sma_trn_userPreference where prefUserID not in (select usrnUserID as UserID from sma_MST_users where isnull(usrnUserID,'')<>'' )  

insert into sma_trn_userPreference
(prefTopSearch,prefUserID,preDtCreated,preCreatedUserID,preAutoEmailNotification,preEmailNotificationByStaff,preWorkflowEmailNotification,preDocumentsEmailNotification,preAutoCorrect,preAttachDocumentToEmail
,preGenerateLocally,preMyClosedCaseNotification,preTheme,preNoteFontName,preNoteFontSize,preDocumentShowEmail,preDocumentPhotograph,preTaskCompleteNotify,preSMSEmailNotification,KeepMergeCodes)

select '0',A.UserID,GETDATE(),A.UserID,1,1,1,1,1,1,0,1,NULL,NULL,NULL,0,1,1,1,0
from 
(
    select usrnUserID as UserID from sma_MST_users where isnull(usrnUserID,'')<>''
			 except
    select prefUserID as UserID from sma_TRN_userpreference where isnull(prefUserID,'')<>''
) A


--(Appendix)----
--alter table sma_TRN_Cases disable trigger all
--update sma_TRN_Cases set cassCaseName= A.CaseName
--from sma_TRN_Plaintiff T
--inner join 
--(
--	SELECT 
--		CN.CaseID,
--		CASE 
--			WHEN (SELECT TOP 1 ISNULL(adpsKeyValue,'') FROM sma_MST_AdminParameters WHERE adpsKeyName = 'CaseNameFormat') <>'' 
--				THEN CN.CaseNameAdminParameter 
--			ELSE CN.DefaultCaseName 
--		END as CaseName
--	FROM getCaseName CN
--) A on A.CaseID=T.plnnCaseID
--where T.plnbIsPrimary=1
--and casnCaseID=A.CaseID
--and isnull(cassCaseName,'')='' -- set system caseName only for empty caseName
--alter table sma_TRN_Cases enable trigger all


--(Appendix)----Amran: the notes being too condensed ...
--alter table sma_trn_notes disable trigger all
--update  sma_trn_notes set notmPlainText=replace(notmPlainText,char(10),'<br>') where  notmPlainText like '%'+char(10)+'%'
--alter table sma_trn_notes enable trigger all
