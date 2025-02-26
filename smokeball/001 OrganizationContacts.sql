set ansi_warnings off

alter table [sma_MST_OrgContacts] alter column saga varchar(500)
Declare @OrgName varchar(5000),@Address1 varchar(5000),@Address2 varchar(5000),@City varchar(5000),@State varchar(5000),@Zip varchar(5000),@Email varchar(5000),@ContactType varchar(5000),@OfficePhone varchar(5000),@Cell varchar(5000),@Fax varchar(5000),@ID varchar(5000)
DECLARE org_cursor CURSOR FAST_FORWARD FOR
Select [Other Name]
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
      ,[Id] from [SAConversion].[dbo].[IndividualContact$] where isnull([Other Name],'')<>''

OPEN org_cursor 

FETCH NEXT FROM org_cursor INTO @OrgName,@Address1,@Address2,@City,@State,@Zip,@Email,@ContactType,@OfficePhone,@Cell,@Fax,@ID
WHILE @@FETCH_STATUS = 0
BEGIN

INSERT INTO [sma_MST_OrgContacts]
([conbPrimary],[connContactTypeID],[connContactSubCtgID],[consName],[conbStatus],[consEINNO],[consComments],[connContactCtg],[connRefByCtgID],[connReferredBy],[connContactPerson],[consWorkPhone],[conbPreventMailing],[connRecUserID],[condDtCreated],[connModifyUserID],[condDtModified],[connLevelNo],[consOtherName],[saga])
Select 1, 11,'',@OrgName,1,'','',2,null,null,'','',0,368,GETDATE(),null,null,'',null,@id


Declare @ContactID int,@County varchar(5000),@addressid int
Select @ContactID=scope_identity();

Select @County=MIN(zpcsCounty) from sma_mst_zipcodes where zpcsZip=@zip and zpcsCity=@city


INSERT INTO [sma_MST_Address]
([addnContactCtgID],[addnContactID],[addnAddressTypeID],[addsAddressType],[addsAddTypeCode],[addsAddress1],[addsAddress2],[addsAddress3],[addsStateCode],[addsCity],[addnZipID],[addsZip],[addsCounty],[addsCountry],[addbIsResidence],[addbPrimary],[adddFromDate],[adddToDate],[addnCompanyID],[addsDepartment],[addsTitle],[addnContactPersonID],[addsComments],[addbIsCurrent],[addbIsMailing],[addnRecUserID],[adddDtCreated],[addnModifyUserID],[adddDtModified],[addnLevelNo],[caseno],[addbDeleted],[addsZipExtn],[saga])
Select 2,@ContactID, 12,'Office','WRK',substring(@Address1,0,75),substring(isnull(@Address2,''),0,75),'',substring(@State,0,20),substring(@City,0,50),'',substring(@Zip,0,6),substring(@County,0,30),'USA',1,1,GETDATE(),null,null,null,null,null,'',1,1,368,GETDATE(),null,null,'','',null,case when @Zip like '%-%' then SUBSTRING(@Zip, CHARINDEX('-', @zip) + 1, LEN(@zip)) else '' end,''

Select @addressid=scope_identity();

INSERT INTO [sma_MST_ContactNumbers]
([cnnnContactCtgID],[cnnnContactID],[cnnnPhoneTypeID],[cnnsContactNumber],[cnnsExtension],[cnnbPrimary],[cnnbVisible],[cnnnAddressID],[cnnsLabelCaption],[cnnnRecUserID],[cnndDtCreated],[cnnnModifyUserID],[cnndDtModified],[cnnnLevelNo],[caseNo],[saga])	
Select 2, @ContactID,24,@OfficePhone,'',0,1,@addressid,'Office Phone',368,GETDATE(),null,null,null,null,null
where ISNULL(@OfficePhone,'(   )   -')<>'(   )   -'

INSERT INTO [sma_MST_ContactNumbers]
([cnnnContactCtgID],[cnnnContactID],[cnnnPhoneTypeID],[cnnsContactNumber],[cnnsExtension],[cnnbPrimary],[cnnbVisible],[cnnnAddressID],[cnnsLabelCaption],[cnnnRecUserID],[cnndDtCreated],[cnnnModifyUserID],[cnndDtModified],[cnnnLevelNo],[caseNo],[saga])	
Select 2, @ContactID,28,@Cell,'',0,1,@addressid,'Cell',368,GETDATE(),null,null,null,null,null
where ISNULL(@Cell,'(   )   -')<>'(   )   -'


INSERT INTO [sma_MST_ContactNumbers]
([cnnnContactCtgID],[cnnnContactID],[cnnnPhoneTypeID],[cnnsContactNumber],[cnnsExtension],[cnnbPrimary],[cnnbVisible],[cnnnAddressID],[cnnsLabelCaption],[cnnnRecUserID],[cnndDtCreated],[cnnnModifyUserID],[cnndDtModified],[cnnnLevelNo],[caseNo],[saga])	
Select 2, @ContactID,28,@fax,'',0,1,@addressid,'Fax',368,GETDATE(),null,null,null,null,null
where ISNULL(@Fax,'(   )   -')<>'(   )   -'

update sma_MST_ContactNumbers set cnnbPrimary=1 where cnnnContactCtgID=2 and cnnnContactID=@ContactID and cnnnContactNumberID =(select MIN(cnnnContactNumberID) from sma_MST_ContactNumbers where cnnnContactCtgID=2 and cnnnContactID=@ContactID)

INSERT INTO [sma_MST_EmailWebsite]
([cewnContactCtgID],[cewnContactID],[cewsEmailWebsiteFlag],[cewsEmailWebSite],[cewbDefault],[cewnRecUserID],[cewdDtCreated],[cewnModifyUserID],[cewdDtModified],[cewnLevelNo],[saga])
Select 2,@ContactID,'E',@Email,1,368,GETDATE(),null,null,null,null where ISNULL(@Email,'')<>''
FETCH NEXT FROM org_cursor INTO @OrgName,@Address1,@Address2,@City,@State,@Zip,@Email,@ContactType,@OfficePhone,@Cell,@Fax,@ID
END

CLOSE org_cursor
DEALLOCATE org_cursor
go
insert into sma_MST_RelContacts
select distinct 1,cinnContactID,a1.AddressId,2,connContactID,a2.AddressId,2,368,getdate(),null,null,0,'Business',null
FROM sma_MST_IndvContacts i 
JOIN sma_MST_OrgContacts o on i.saga=o.saga
JOIN sma_MST_AllContactInfo a1 on a1.ContactCtg=1 and a1.ContactId=cinnContactID
JOIN sma_MST_AllContactInfo a2 on a2.ContactCtg=2 and a2.ContactId=connContactID
