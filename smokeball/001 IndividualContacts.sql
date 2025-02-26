set ansi_warnings off
alter table [sma_MST_IndvContacts] alter column saga varchar(500)
Declare @Prefix varchar(5000),@FirstName varchar(5000),@Middle varchar(5000),@LastName varchar(5000),@Suffix varchar(5000),@Address1 varchar(5000),@Address2 varchar(5000),@City varchar(5000),@State varchar(5000),@Zip varchar(5000),@Email varchar(5000),@ContactType varchar(5000),@Home varchar(5000),@Cell varchar(5000),@Work varchar(5000),@ID varchar(5000)
DECLARE indv_Cursor CURSOR FAST_FORWARD FOR
Select [Title]
      ,[FirstName]
      ,[MiddleName]
      ,[Surname]
      ,[Suffix]
      ,[AddressLine1]
      ,[AddressLine2]
      ,[CitySuburb]
      ,[State]
      ,isnull([ZipCode],zip2)
      ,[Email]
      ,[ContactType]
      ,[Phone]
      ,[CellPhone]
      ,[Fax]
      ,[Id] from [IndividualContact$]

OPEN indv_Cursor 

FETCH NEXT FROM indv_Cursor INTO @Prefix,@FirstName,@Middle,@LastName,@Suffix,@Address1,@Address2,@City,@State,@Zip,@Email,@ContactType,@Home,@Cell,@Work,@ID
WHILE @@FETCH_STATUS = 0
BEGIN
INSERT INTO [sma_MST_IndvContacts]
([cinbPrimary],[cinnContactTypeID],[cinnContactSubCtgID],[cinsPrefix],[cinsFirstName],[cinsMiddleName],[cinsLastName],[cinsSuffix],[cinsNickName],[cinbStatus],[cinsSSNNo],[cindBirthDate],[cinsComments],[cinnContactCtg],[cinnRefByCtgID],[cinnReferredBy],[cindDateOfDeath],[cinsCVLink],[cinnMaritalStatusID],[cinnGender],[cinsBirthPlace],[cinnCountyID],[cinsCountyOfResidence],[cinbFlagForPhoto],[cinsPrimaryContactNo],[cinsHomePhone],[cinsWorkPhone],[cinsMobile],[cinbPreventMailing],[cinnRecUserID],[cindDtCreated],[cinnModifyUserID],[cindDtModified],[cinnLevelNo],[cinsPrimaryLanguage],[cinsOtherLanguage],[cinbDeathFlag],[cinsCitizenship],[cinsHeight],[cinnWeight],[cinsReligion],[cindMarriageDate],[cinsMarriageLoc],[cinsDeathPlace],[cinsMaidenName],[cinsOccupation],[saga],[cinsSpouse],[cinsGrade])   
SELECT distinct 1, 10 ,null,ltrim(rtrim(@Prefix)),substring(@FirstName,0,30),substring(@Middle,0,30),substring(@LastName,0,40),substring(@Suffix,0,10),'', 1,null,null,'',1,'','',null,'','',null,'',1,1,null,substring(@Home,0,19),'','','',0,368,Getdate(),null,null,0,'','','','','','','',Null,'','','','',@id,'',null


Declare @ContactID int,@County varchar(5000),@addressid int
Select @ContactID=scope_identity();

Select @County=MIN(zpcsCounty) from sma_mst_zipcodes where zpcsZip=@zip and zpcsCity=@city


INSERT INTO [sma_MST_Address]
([addnContactCtgID],[addnContactID],[addnAddressTypeID],[addsAddressType],[addsAddTypeCode],[addsAddress1],[addsAddress2],[addsAddress3],[addsStateCode],[addsCity],[addnZipID],[addsZip],[addsCounty],[addsCountry],[addbIsResidence],[addbPrimary],[adddFromDate],[adddToDate],[addnCompanyID],[addsDepartment],[addsTitle],[addnContactPersonID],[addsComments],[addbIsCurrent],[addbIsMailing],[addnRecUserID],[adddDtCreated],[addnModifyUserID],[adddDtModified],[addnLevelNo],[caseno],[addbDeleted],[addsZipExtn],[saga])
Select 1,@ContactID, 1 , 'Home - Primary','HM',substring(@address1,0,75),substring(isnull(@Address2,''),0,75),'',substring(@State,0,20),substring(@City,0,50),'',substring(@Zip,0,6),substring(@County,0,30),'USA',1,1,GETDATE(),null,null,null,null,null,'',1,1,368,GETDATE(),null,null,'','',null,case when @Zip like '%-%' then SUBSTRING(@Zip, CHARINDEX('-', @zip) + 1, LEN(@zip)) else '' end,''

Select @addressid=scope_identity();

INSERT INTO [sma_MST_ContactNumbers]
([cnnnContactCtgID],[cnnnContactID],[cnnnPhoneTypeID],[cnnsContactNumber],[cnnsExtension],[cnnbPrimary],[cnnbVisible],[cnnnAddressID],[cnnsLabelCaption],[cnnnRecUserID],[cnndDtCreated],[cnnnModifyUserID],[cnndDtModified],[cnnnLevelNo],[caseNo],[saga])	
Select 1, @ContactID,1,@Home,'',0,1,@addressid,'Home',368,GETDATE(),null,null,null,null,null
where ISNULL(@Home,'(   )   -')<>'(   )   -'

INSERT INTO [sma_MST_ContactNumbers]
([cnnnContactCtgID],[cnnnContactID],[cnnnPhoneTypeID],[cnnsContactNumber],[cnnsExtension],[cnnbPrimary],[cnnbVisible],[cnnnAddressID],[cnnsLabelCaption],[cnnnRecUserID],[cnndDtCreated],[cnnnModifyUserID],[cnndDtModified],[cnnnLevelNo],[caseNo],[saga])	
Select 1, @ContactID,29,@Cell,'',0,1,@addressid,'Cell',368,GETDATE(),null,null,null,null,null
where ISNULL(@Cell,'(   )   -')<>'(   )   -'

INSERT INTO [sma_MST_ContactNumbers]
([cnnnContactCtgID],[cnnnContactID],[cnnnPhoneTypeID],[cnnsContactNumber],[cnnsExtension],[cnnbPrimary],[cnnbVisible],[cnnnAddressID],[cnnsLabelCaption],[cnnnRecUserID],[cnndDtCreated],[cnnnModifyUserID],[cnndDtModified],[cnnnLevelNo],[caseNo],[saga])	
Select 1, @ContactID,31,@Work,'',0,1,@addressid,'Cell',368,GETDATE(),null,null,null,null,null
where ISNULL(@Work,'(   )   -')<>'(   )   -'

update sma_MST_ContactNumbers set cnnbPrimary=1 where cnnnContactCtgID=1 and cnnnContactID=@ContactID and cnnnContactNumberID =(select MIN(cnnnContactNumberID) from sma_MST_ContactNumbers where cnnnContactCtgID=1 and cnnnContactID=@ContactID)

INSERT INTO [sma_MST_EmailWebsite]
([cewnContactCtgID],[cewnContactID],[cewsEmailWebsiteFlag],[cewsEmailWebSite],[cewbDefault],[cewnRecUserID],[cewdDtCreated],[cewnModifyUserID],[cewdDtModified],[cewnLevelNo],[saga])
Select 1,@ContactID,'E',@Email,1,368,GETDATE(),null,null,null,null where ISNULL(@Email,'')<>''
FETCH NEXT FROM indv_Cursor INTO @Prefix,@FirstName,@Middle,@LastName,@Suffix,@Address1,@Address2,@City,@State,@Zip,@Email,@ContactType,@Home,@Cell,@Work,@ID
END

CLOSE indv_Cursor
DEALLOCATE indv_Cursor