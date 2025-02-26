----******ScriptforCaseGenerationfromSpreadsheet******
--SET IDENTITY_INSERT sma_mst_indvcontacts ON
--INSERT INTO [sma_MST_IndvContacts]
--(cinnContactID,[cinbPrimary],[cinnContactTypeID],[cinnContactSubCtgID],[cinsPrefix],[cinsFirstName],[cinsMiddleName],[cinsLastName],[cinsSuffix],[cinsNickName],[cinbStatus],[cinsSSNNo],[cindBirthDate],[cinsComments],[cinnContactCtg],[cinnRefByCtgID],[cinnReferredBy],[cindDateOfDeath],[cinsCVLink],[cinnMaritalStatusID],[cinnGender],[cinsBirthPlace],[cinnCountyID],[cinsCountyOfResidence],[cinbFlagForPhoto],[cinsPrimaryContactNo],[cinsHomePhone],[cinsWorkPhone],[cinsMobile],[cinbPreventMailing],[cinnRecUserID],[cindDtCreated],[cinnModifyUserID],[cindDtModified],[cinnLevelNo],[cinsPrimaryLanguage],[cinsOtherLanguage],[cinbDeathFlag],[cinsCitizenship],[cinsHeight],[cinnWeight],[cinsReligion],[cindMarriageDate],[cinsMarriageLoc],[cinsDeathPlace],[cinsMaidenName],[cinsOccupation],[saga],[cinsSpouse],[cinsGrade])    
--SELECT distinct 8,1,10,null,'Mr.','Staff','','Unassigned',null,null,1,null,null,null,1,'','',null,'','',1,'',1,1,null,null,'','',null,0,368,GETDATE(),'',null,0,'','','','',null+null,null,'',Null,'','','','','','',null
--union
--SELECT distinct 9,1,10,null,'Mr.','John','','Doe',null,null,1,null,null,null,1,'','',null,'','',1,'',1,1,null,null,'','',null,0,368,GETDATE(),'',null,0,'','','','',null+null,null,'',Null,'','','','','','',null
--SET IDENTITY_INSERT sma_mst_indvcontacts OFF

--INSERT INTO [sma_MST_Address]
--([addnContactCtgID],[addnContactID],[addnAddressTypeID],[addsAddressType],[addsAddTypeCode],[addsAddress1],[addsAddress2],[addsAddress3],[addsStateCode],[addsCity],[addnZipID],[addsZip],[addsCounty],[addsCountry],[addbIsResidence],[addbPrimary],[adddFromDate],[adddToDate],[addnCompanyID],[addsDepartment],[addsTitle],[addnContactPersonID],[addsComments],[addbIsCurrent],[addbIsMailing],[addnRecUserID],[adddDtCreated],[addnModifyUserID],[adddDtModified],[addnLevelNo],[caseno],[addbDeleted],[addsZipExtn],[saga])
--Select 1,cinnContactID, 10 ,'Other', 'OTH' ,'','','','','','','','','',1,1, GETDATE() ,null,null,null,null,null,'',1,1,368,GETDATE() ,null,null,'','','','',''
--From sma_MST_IndvContacts where cinsLastName='Unassigned' and cinsFirstName='staff'
--union
--Select 1,cinnContactID, 10 ,'Other', 'OTH' ,'','','','','','','','','',1,1, GETDATE() ,null,null,null,null,null,'',1,1,368,GETDATE() ,null,null,'','','','',''
--From sma_MST_IndvContacts where cinsLastName='doe' and cinsFirstName='john'

--INSERT INTO [sma_MST_IndvContacts]
--([cinbPrimary],[cinnContactTypeID],[cinnContactSubCtgID],[cinsPrefix],[cinsFirstName],[cinsMiddleName],[cinsLastName],[cinsSuffix],[cinsNickName],[cinbStatus],[cinsSSNNo],[cindBirthDate],[cinsComments],[cinnContactCtg],[cinnRefByCtgID],[cinnReferredBy],[cindDateOfDeath],[cinsCVLink],[cinnMaritalStatusID],[cinnGender],[cinsBirthPlace],[cinnCountyID],[cinsCountyOfResidence],[cinbFlagForPhoto],[cinsPrimaryContactNo],[cinsHomePhone],[cinsWorkPhone],[cinsMobile],[cinbPreventMailing],[cinnRecUserID],[cindDtCreated],[cinnModifyUserID],[cindDtModified],[cinnLevelNo],[cinsPrimaryLanguage],[cinsOtherLanguage],[cinbDeathFlag],[cinsCitizenship],[cinsHeight],[cinnWeight],[cinsReligion],[cindMarriageDate],[cinsMarriageLoc],[cinsDeathPlace],[cinsMaidenName],[cinsOccupation],[saga],[cinsSpouse],[cinsGrade])    
--SELECT distinct 1,10,null,'',case when ltrim(rtrim([Case Attorney (Login)])) like '% %' then left(ltrim(rtrim([Case Attorney (Login)])), charindex(' ', ltrim(rtrim([Case Attorney (Login)]))) )  else null end ,'',case when ltrim(rtrim([Case Attorney (Login)])) like '% %' then right(ltrim(rtrim([Case Attorney (Login)])), len(ltrim(rtrim([Case Attorney (Login)]))) - charindex(' ', ltrim(rtrim([Case Attorney (Login)])))) else ltrim(rtrim([Case Attorney (Login)])) end ,null,null,1,null,null,null,1,'','',null,'','',1,'',1,1,null,null,'','',null,0,368,GETDATE(),'',null,0,'','','','',null+null,null,'',Null,'','','','','','',null
--from ['New Case Info$'] where isnull([Case Attorney (Login)],'')<>''
--union   
--SELECT distinct 1,10,null,'',case when ltrim(rtrim([Case Paralegal (Login)])) like '% %' then left(ltrim(rtrim([Case Paralegal (Login)])), charindex(' ', ltrim(rtrim([Case Paralegal (Login)]))) )  else null end ,'',case when ltrim(rtrim([Case Paralegal (Login)])) like '% %' then right(ltrim(rtrim([Case Paralegal (Login)])), len(ltrim(rtrim([Case Paralegal (Login)]))) - charindex(' ', ltrim(rtrim([Case Paralegal (Login)])))) else ltrim(rtrim([Case Paralegal (Login)])) end ,null,null,1,null,null,null,1,'','',null,'','',1,'',1,1,null,null,'','',null,0,368,GETDATE(),'',null,0,'','','','',null+null,null,'',Null,'','','','','','',null
--from ['New Case Info$'] where isnull([Case Paralegal (Login)],'')<>''
--go

--INSERT INTO [sma_MST_Users]
--([usrnContactID],[usrsLoginID],[usrsPassword],[usrsBackColor],[usrsReadBackColor],[usrsEvenBackColor],[usrsOddBackColor],[usrnRoleID],[usrdLoginDate],[usrdLogOffDate],[usrnUserLevel],[usrsWorkstation],[usrnPortno],[usrbLoggedIn],[usrbCaseLevelRights],[usrbCaseLevelFilters],[usrnUnsuccesfulLoginCount],[usrnRecUserID],[usrdDtCreated],[usrnModifyUserID],[usrdDtModified],[usrnLevelNo],[usrsCaseCloseColor],[usrnDocAssembly],[usrnAdmin],[usrnIsLocked],usrbActiveState)     
--Select distinct (cinncontactid),SUBSTRING(min(cinsfirstname),1,1)+substring(min(cinsLastName),0,19),'#',null,null,null,null,33,null,null,null,null,null,null,null,null,null,1,GETDATE(),null,null,null,null,null,null,null,1
--From sma_MST_IndvContacts where cinnContactID not in (8,9)
--group by cinncontactid

--SET IDENTITY_INSERT sma_mst_users ON


--INSERT INTO [sma_MST_Users]
--(usrnuserid,[usrnContactID],[usrsLoginID],[usrsPassword],[usrsBackColor],[usrsReadBackColor],[usrsEvenBackColor],[usrsOddBackColor],[usrnRoleID],[usrdLoginDate],[usrdLogOffDate],[usrnUserLevel],[usrsWorkstation],[usrnPortno],[usrbLoggedIn],
--[usrbCaseLevelRights],[usrbCaseLevelFilters],[usrnUnsuccesfulLoginCount],[usrnRecUserID],[usrdDtCreated],[usrnModifyUserID],[usrdDtModified],[usrnLevelNo],[usrsCaseCloseColor],[usrnDocAssembly],[usrnAdmin],[usrnIsLocked],usrbActiveState)     
--Select distinct 368,8,'aadmin','2/',null,null,null,null,33,null,null,null,null,null,null,null,null,null,1,GETDATE(),null,null,null,null,null,null,null,1

--SET IDENTITY_INSERT sma_mst_users OFF
--Declare @UserID int
--DECLARE staff_cursor CURSOR FAST_FORWARD FOR SELECT usrnuserid from sma_mst_users
--OPEN staff_cursor 
--FETCH NEXT FROM staff_cursor INTO @UserID
--WHILE @@FETCH_STATUS = 0
--BEGIN
--insert into sma_TRN_CaseBrowseSettings (cbsnColumnID,cbsnUserID,cbssCaption,cbsbVisible,cbsnWidth,cbsnOrder,cbsnRecUserID,cbsdDtCreated,cbsn_StyleName)
-- SELECT distinct cbcnColumnID,@UserID,cbcscolumnname,'True',200,cbcnDefaultOrder,@UserID,GETDATE(),'Office2007Blue' FROM [sma_MST_CaseBrowseColumns]
-- where cbcnColumnID not in (1,18,19,20,21,22,23,24,25,26,27,28,29,30,33)
--FETCH NEXT FROM staff_cursor INTO  @UserID
--END

--CLOSE staff_cursor 
--DEALLOCATE staff_cursor
--Migration Begins Here
Declare @Id nvarchar(max),@MatterNumber nvarchar(max),@MatterDescription nvarchar(max),@AttorneyResponsibleEmail nvarchar(max),@PersonAssistingEmail nvarchar(max),@InstructionDate nvarchar(max),@MatterType nvarchar(max),@ClientName nvarchar(max),@ClientContactIDs nvarchar(max),@OtherSideName nvarchar(max),@OtherSideContactIDs nvarchar(max),@OtherSideAttorneyName nvarchar(max),@OtherSideAttorneyContactID nvarchar(max),@UID nvarchar(max)
--Declare cursor to travesrse each row at a time
DECLARE indvCaseID_Cursor CURSOR FAST_FORWARD FOR 

Select  [Id]
      ,substring(isnull([MatterNumber],uid),0,20)
      ,[MatterDescription]
      ,[AttorneyResponsibleEmail]
      ,[PersonAssistingEmail]
      ,[InstructionDate]
      ,[MatterType]
      ,[ClientName]
      ,[ClientContactIDs]
      ,[OtherSideName]
      ,[OtherSideContactIDs]
      ,[OtherSideAttorneyName]
      ,[OtherSideAttorneyContactID]
      
	  from [matters_190807031217]

OPEN indvCaseID_Cursor 

FETCH NEXT FROM indvCaseID_Cursor INTO @Id,@MatterNumber,@MatterDescription,@AttorneyResponsibleEmail,@PersonAssistingEmail,@InstructionDate,@MatterType,@ClientName,@ClientContactIDs,@OtherSideName,@OtherSideContactIDs,@OtherSideAttorneyName,@OtherSideAttorneyContactID
WHILE @@FETCH_STATUS = 0
BEGIN
--Create Individual Contact --Address --Phone --Email

--Organization


Declare @CaseTypeiD int, @CaseSubTypeid int,@CaseID int,@PlaintiffSubRoleID1 int
Select @CaseTypeiD=min(cstnCaseTypeID) from sma_MST_CaseType where cstsType=@MatterType
Select @CaseSubTypeid=min(cstnCaseSubTypeID) from sma_MST_CaseSubType where cstnTypeCode=650 and cstnGroupID=@CaseTypeiD
Select @PlaintiffSubRoleID1=min(sbrnSubRoleId) from sma_MST_SubRole   where sbrsDscrptn='(P)-Plaintiff' and sbrnCaseTypeID=@CaseTypeiD and sbrnRoleID=4

--Case

INSERT INTO [sma_TRN_Cases]
([cassCaseNumber],[casbAppName],[cassCaseName],[casnCaseTypeID],[casnState],[casdStatusFromDt],[casnStatusValueID],[casdsubstatusfromdt],[casnSubStatusValueID],[casdOpeningDate],[casdClosingDate],[casnCaseValueID],[casnCaseValueFrom],[casnCaseValueTo],[casnCurrentCourt],[casnCurrentJudge],[casnCurrentMagistrate],[casnCaptionID],[cassCaptionText],[casbMainCase],[casbCaseOut],[casbSubOut],[casbWCOut],[casbPartialOut],[casbPartialSubOut],[casbPartiallySettled],[casbInHouse],[casbAutoTimer],[casdExpResolutionDate],[casdIncidentDate],[casnTotalLiability],[cassSharingCodeID],[casnStateID],[casnLastModifiedBy],[casdLastModifiedDate],[casnRecUserID],[casdDtCreated],[casnModifyUserID],[casdDtModified],[casnLevelNo],[cassCaseValueComments],[casbRefIn],[casbDelete],[casbIntaken],[casnOrgCaseTypeID],[CassCaption],[cassMdl],[office_id],[saga],[LIP],[casnSeriousInj],[casnCorpDefn],[casnWebImporter],[casnRecoveryClient],[cas],[ngage],[casnClientRecoveredDt],[CloseReason])
select distinct cast(@MatterNumber as varchar(20)),null,@MatterDescription,@CaseSubTypeid,26,getdate() ,162,null ,'' ,getdate(),null,null,0,0,null,null,null,null,null,1,0,0,0,0,0,0,1 ,0 ,null ,null,0 ,null ,'' ,null,null,368 , GETDATE(),null,null,'' ,'' ,0 ,0 ,1 ,@CaseTypeiD,'' ,'' ,2 ,'' ,'','' ,'' ,'' ,'' ,'' ,'' ,null ,'' 

Select @CaseID=SCOPE_IDENTITY();
--Plaintiff
INSERT INTO   [sma_TRN_Plaintiff]
([plnnCaseID],[plnnContactCtg],[plnnContactID],[plnnAddressID],[plnnRole],[plnbIsPrimary],[plnbWCOut],[plnnPartiallySettled],[plnbSettled],[plnbOut],[plnbSubOut],[plnnSeatBeltUsed],[plnnCaseValueID],[plnnCaseValueFrom],[plnnCaseValueTo],[plnnPriority],[plnnDisbursmentWt],[plnbDocAttached],[plndFromDt],[plndToDt],[plnnRecUserID],[plndDtCreated],[plnnModifyUserID],[plndDtModified],[plnnLevelNo],[plnsMarked],[saga],[plnnNoInj],[plnnMissing],[plnnLIPBatchNo],[plnnPlaintiffRole])
select  distinct @CaseID,1,cinncontactid,addnaddressid,(@PlaintiffSubRoleID1),1,0,0,0,0,0,0,0,0,0,0,0,0,getdate(),null,368,getdate(),null,null,null,null,null,null,null,null,null
from sma_MST_IndvContacts i join sma_mst_address on addnContactID=cinnContactID and addnContactCtgID=1 and addbPrimary=1 where i.saga=@ClientContactIDs

--Defendant
Declare @DefendantSubRoleID1 int, @DefendantSubRoleID2 int,@DefendantSubRoleID3 int
Select @DefendantSubRoleID1=min(sbrnSubRoleId) from sma_MST_SubRole   where sbrnTypeCode=149 and sbrnCaseTypeID=@CaseTypeiD and sbrnRoleID=5

alter table [sma_TRN_Defendants] disable trigger all
INSERT INTO [sma_TRN_Defendants]
([defnCaseID],[defnContactCtgID],[defnContactID],[defnAddressID],[defnSubRole],[defbIsPrimary],[defbCounterClaim],[defbThirdParty],[defsThirdPartyRole],[defnPriority],[defdFrmDt],[defdToDt],[defnRecUserID],[defdDtCreated],[defnModifyUserID],[defdDtModified],[defnLevelNo],[defsMarked],[saga])  
Select @CaseID,1 ,cinnContactID,addnAddressID,(@DefendantSubRoleID1),1,0,0,'',0,getdate(),null,368,getdate(),null,null,null,null,null
from sma_MST_IndvContacts i join sma_mst_address on addnContactID=cinnContactID and addnContactCtgID=1 and addbPrimary=1 where i.saga=@OtherSideContactIDs

INSERT INTO [sma_TRN_Defendants]
([defnCaseID],[defnContactCtgID],[defnContactID],[defnAddressID],[defnSubRole],[defbIsPrimary],[defbCounterClaim],[defbThirdParty],[defsThirdPartyRole],[defnPriority],[defdFrmDt],[defdToDt],[defnRecUserID],[defdDtCreated],[defnModifyUserID],[defdDtModified],[defnLevelNo],[defsMarked],[saga])  
Select @CaseID,1 ,9,2,(@DefendantSubRoleID1),0,0,0,'',0,getdate(),null,368,getdate(),null,null,null,null,null where not exists(select * from sma_TRN_Defendants where defnCaseID=@CaseID and defbIsPrimary=1)

Declare @DefID int=scope_identity();
alter table [sma_TRN_Defendants] enable trigger all

insert into sma_TRN_LawFirms
select distinct NULL,NULL,cinnContactID,addnAddressID,7,NULL,2,@DefID,368,getdate(),NULL,NULL,1,NULL,NULL,NULL,0,NULL,0
from sma_MST_IndvContacts i join sma_mst_address on addnContactID=cinnContactID and addnContactCtgID=1 and addbPrimary=1 where i.saga=@OtherSideContactIDs
--Incident

Insert into sma_TRN_Incidents([CaseId],[IncidentDate],[StateID],[LiabilityCodeId],[IncidentFacts],[MergedFacts],[Comments],[IncidentTime],[RecUserID],[DtCreated],[ModifyUserID],[DtModified])
select @CaseID,NULL,67,'','','','',null,368,getdate(),null,null


--Staff
--Status
INSERT INTO [sma_TRN_CaseStatus]
([cssnCaseID],[cssnStatusTypeID],[cssnStatusID],[cssnExpDays],[cssdFromDate],[cssdToDt],[csssComments],[cssnRecUserID],[cssdDtCreated],[cssnModifyUserID],[cssdDtModified],[cssnLevelNo],[cssnDelFlag])
select @CaseID,1,162,'',getdate(),null,'',368,getdate(),null,null,null,null
exec sma_SP_Create_SOLs @CaseID, @@IDENTITY, 368  	
exec sma_SP_Create_SOLs_MultipleIncidents @CaseID ,'0,1,2,3,4,5',@@IDENTITY 
exec sma_SP_Create_plnSOLs_MultipleIncidents @CaseID ,'0,1,2,3,4,5',@@IDENTITY
FETCH NEXT FROM indvCaseID_Cursor INTO @Id,@MatterNumber,@MatterDescription,@AttorneyResponsibleEmail,@PersonAssistingEmail,@InstructionDate,@MatterType,@ClientName,@ClientContactIDs,@OtherSideName,@OtherSideContactIDs,@OtherSideAttorneyName,@OtherSideAttorneyContactID

end

CLOSE indvCaseID_Cursor
DEALLOCATE indvCaseID_Cursor

go
INSERT INTO [sma_MST_IndvContacts]
([cinbPrimary],[cinnContactTypeID],[cinnContactSubCtgID],[cinsPrefix],[cinsFirstName],[cinsMiddleName],[cinsLastName],[cinsSuffix],[cinsNickName],[cinbStatus],[cinsSSNNo],[cindBirthDate],[cinsComments],[cinnContactCtg],[cinnRefByCtgID],[cinnReferredBy],[cindDateOfDeath],[cinsCVLink],[cinnMaritalStatusID],[cinnGender],[cinsBirthPlace],[cinnCountyID],[cinsCountyOfResidence],[cinbFlagForPhoto],[cinsPrimaryContactNo],[cinsHomePhone],[cinsWorkPhone],[cinsMobile],[cinbPreventMailing],[cinnRecUserID],[cindDtCreated],[cinnModifyUserID],[cindDtModified],[cinnLevelNo],[cinsPrimaryLanguage],[cinsOtherLanguage],[cinbDeathFlag],[cinsCitizenship],[cinsHeight],[cinnWeight],[cinsReligion],[cindMarriageDate],[cinsMarriageLoc],[cinsDeathPlace],[cinsMaidenName],[cinsOccupation],[saga],[cinsSpouse],[cinsGrade])   
SELECT distinct 1, 10 ,null,ltrim(rtrim('')),substring('Unknown',0,30),substring('',0,30),substring('Unknown',0,40),substring('',0,10),'', 1,null,null,'',1,'','',null,'','',null,'',1,1,null,substring('',0,19),'','','',0,368,Getdate(),null,null,0,'','','','','','','',Null,'','','','',0,'',null
where not exists(select * from [sma_MST_IndvContacts] where cinsFirstName='Unknown' and cinsLastName='Unknown')
go
INSERT INTO [sma_MST_Address]
([addnContactCtgID],[addnContactID],[addnAddressTypeID],[addsAddressType],[addsAddTypeCode],[addsAddress1],[addsAddress2],[addsAddress3],[addsStateCode],[addsCity],[addnZipID],[addsZip],[addsCounty],[addsCountry],[addbIsResidence],[addbPrimary],[adddFromDate],[adddToDate],[addnCompanyID],[addsDepartment],[addsTitle],[addnContactPersonID],[addsComments],[addbIsCurrent],[addbIsMailing],[addnRecUserID],[adddDtCreated],[addnModifyUserID],[adddDtModified],[addnLevelNo],[caseno],[addbDeleted],[addsZipExtn],[saga])
Select 1,cinnContactID, 1 , 'Home - Primary','HM',substring('',0,75),substring(isnull('',''),0,75),'',substring('',0,20),substring('',0,50),'',substring('',0,6),substring('',0,30),'USA',1,1,GETDATE(),null,null,null,null,null,'',1,1,368,GETDATE(),null,null,'','',null,'',''
From [sma_MST_IndvContacts] where not exists(select * from sma_mst_address where addnContactCtgID=1 and addnContactID=cinnContactID)
go
alter table [sma_TRN_Plaintiff] disable trigger all
INSERT INTO   [sma_TRN_Plaintiff]
([plnnCaseID],[plnnContactCtg],[plnnContactID],[plnnAddressID],[plnnRole],[plnbIsPrimary],[plnbWCOut],[plnnPartiallySettled],[plnbSettled],[plnbOut],[plnbSubOut],[plnnSeatBeltUsed],[plnnCaseValueID],[plnnCaseValueFrom],[plnnCaseValueTo],[plnnPriority],[plnnDisbursmentWt],[plnbDocAttached],[plndFromDt],[plndToDt],[plnnRecUserID],[plndDtCreated],[plnnModifyUserID],[plndDtModified],[plnnLevelNo],[plnsMarked],[saga],[plnnNoInj],[plnnMissing],[plnnLIPBatchNo],[plnnPlaintiffRole])
select  distinct casnCaseID,1,cinncontactid,addnaddressid,(sbrnSubRoleId),1,0,0,0,0,0,0,0,0,0,0,0,0,getdate(),null,368,getdate(),null,null,null,null,null,null,null,null,null
from sma_trn_cases Left join sma_MST_SubRole on sbrnCaseTypeID=casnOrgCaseTypeID and sbrnTypeCode=20 cross join sma_MST_IndvContacts i JOIN sma_mst_address on addnContactID=cinnContactID and addnContactCtgID=1 and addbPrimary=1
where cinsFirstName='Unknown' and cinsLastName='Unknown' and not exists(select * from sma_TRN_Plaintiff where plnnCaseID=casnCaseID)
alter table [sma_TRN_Plaintiff] enable trigger all
go
update c set casscasename=isnull(clientname,mattertype) from sma_trn_cases  c
JOIN [matters_190807031217] on cassCaseNumber=substring(isnull([MatterNumber],uid),0,20)
JOIN sma_TRN_Plaintiff on plnnCaseID=casnCaseID
JOIN sma_MST_AllContactInfo on ContactId=plnnContactID and plnnContactCtg=ContactCtg
where cassCaseName is null