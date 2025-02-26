use [SAPerfectPracticeEmroch]

/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_MST_EmailWebsite] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_MST_EmailWebsite] 
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_MST_EmailWebsite]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_MST_EmailWebsite] enable trigger all
*/

---
alter table [sma_MST_EmailWebsite] disable trigger all
GO
---
----- (1/3) construct sma_MST_EmailWebsite for Individual ------

  insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_EmailWebsite]
  ( [cewnContactCtgID],[cewnContactID],[cewsEmailWebsiteFlag],[cewsEmailWebSite],[cewbDefault],[cewnRecUserID],[cewdDtCreated],[cewnModifyUserID],[cewdDtModified],[cewnLevelNo],[saga] )
  select 
		I.cinnContactCtg	as cewnContactCtgID,
		I.cinnContactID		as cewnContactID,
		'E'					as cewsEmailWebsiteFlag,
		A.[phnum]			as cewsEmailWebSite,
		null				as cewbDefault,
		368					as cewnRecUserID,
		getdate()			as cewdDtCreated,
		368					as cewnModifyUserID,
		getdate()			as cewdDtModified,
		null,
		1					as saga -- indicate email
 from [PerfectPracticeEmroch].[dbo].[eaddress] A
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts] I on I.saga = A.entitynum
 where isnull(A.addrtype,'') = 'EMAIL_ADDRESS'
 and A.[phnum] is not null


----- (2/3) construct sma_MST_EmailWebsite for Organization ------

  insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_EmailWebsite]
  ( [cewnContactCtgID],[cewnContactID],[cewsEmailWebsiteFlag],[cewsEmailWebSite],[cewbDefault],[cewnRecUserID],[cewdDtCreated],[cewnModifyUserID],[cewdDtModified],[cewnLevelNo],[saga] )
  select 
		O.connContactCtg	as cewnContactCtgID,
		O.connContactID		as cewnContactID,
		'E'					as cewsEmailWebsiteFlag,
		A.[phnum]			as cewsEmailWebSite,
		null				as cewbDefault,
		368					as cewnRecUserID,
		getdate()			as cewdDtCreated,
		368					as cewnModifyUserID,
		getdate()			as cewdDtModified,
		null,
		1					as saga -- indicate email
 from [PerfectPracticeEmroch].[dbo].[eaddress] A
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_OrgContacts] O on O.saga = A.entitynum
 where isnull(A.addrtype,'') = 'EMAIL_ADDRESS'
 and A.[phnum] is not null

 ---
 alter table [sma_MST_EmailWebsite] enable trigger all
 ---

 /* colombo no default */

 /*
---- (3/3 set default)

 update [SAPerfectPracticeEmroch].[dbo].[sma_MST_EmailWebsite] set cewbDefault=0  
 update [SAPerfectPracticeEmroch].[dbo].[sma_MST_EmailWebsite] set cewbDefault=1 where cewsEmailWebsiteFlag='W'

declare @cewnContactID int;
declare @email_Count int;
declare @email_work_Count int;
declare @other_email_Count int;

declare @email_cewnEmlWSID int;
declare @email_work_cewnEmlWSID int;
declare @other_email_cewnEmlWSID int;
 
DECLARE EmailWebsite_cursor CURSOR FOR 
select distinct cewnContactID from [SAPerfectPracticeEmroch].[dbo].[sma_MST_EmailWebsite]

OPEN EmailWebsite_cursor 

FETCH NEXT FROM EmailWebsite_cursor
INTO @cewnContactID

WHILE @@FETCH_STATUS = 0
BEGIN

select @email_Count=count(*),@email_cewnEmlWSID=min(cewnEmlWSID) from [SAPerfectPracticeEmroch].[dbo].[sma_MST_EmailWebsite] where cewnContactID=@cewnContactID and saga=1 
select @email_work_Count=count(*),@email_work_cewnEmlWSID=min(cewnEmlWSID) from [SAPerfectPracticeEmroch].[dbo].[sma_MST_EmailWebsite] where cewnContactID=@cewnContactID and saga=2
select @other_email_Count=count(*),@other_email_cewnEmlWSID=min(cewnEmlWSID) from [SAPerfectPracticeEmroch].[dbo].[sma_MST_EmailWebsite] where cewnContactID=@cewnContactID and saga=3

if ( @email_Count != 0 )
begin
update [SAPerfectPracticeEmroch].[dbo].[sma_MST_EmailWebsite] set cewbDefault=1 where cewnEmlWSID=@email_cewnEmlWSID
end

if ( @email_Count = 0 and @email_work_Count != 0)
begin
update [SAPerfectPracticeEmroch].[dbo].[sma_MST_EmailWebsite] set cewbDefault=1 where cewnEmlWSID=@email_work_cewnEmlWSID
end

if ( @email_Count = 0 and @email_work_Count = 0 and @other_email_Count <> 0)
begin
update [SAPerfectPracticeEmroch].[dbo].[sma_MST_EmailWebsite] set cewbDefault=1 where cewnEmlWSID=@other_email_cewnEmlWSID
end


FETCH NEXT FROM EmailWebsite_cursor
INTO @cewnContactID

END 

CLOSE EmailWebsite_cursor;
DEALLOCATE EmailWebsite_cursor;
*/


