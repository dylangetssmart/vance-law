SELECT lb.name AS EmailType, e.first_name, ea.* from email_address ea
JOIN lookup_bucket lb ON ea.email_address_type_id = lb.id
JOIN entity e ON ea.entity_id = e.id

SELECT distinct lb.name
FROM email_address ea
join lookup_bucket lb on lb.id = ea.email_address_type_id

-- Email types:
--Home
--Unknown
--Work

USE JoelBieberSA
select * from joelbiebersa..sma_MST_EmailWebsite smew
-------------------------------
-- [ 2.0] EMAIL ADDRESSES
-----------------------------------------

-- USE [TestNeedles]
-- GO
/*
alter table [sma_MST_EmailWebsite] disable trigger all
delete from [sma_MST_EmailWebsite] 
DBCC CHECKIDENT ('[sma_MST_EmailWebsite]', RESEED, 0);
alter table [sma_MST_EmailWebsite] enable trigger all
*/

---
ALTER TABLE [sma_MST_EmailWebsite] DISABLE TRIGGER ALL
GO
---------------------------------------------------------------------
----- (1/3) CONSTRUCT SMA_MST_EMAILWEBSITE FOR INDIVIDUAL -
---------------------------------------------------------------------

-- Email
INSERT INTO [sma_MST_EmailWebsite]
(
	[cewnContactCtgID]
	,[cewnContactID]
	,[cewsEmailWebsiteFlag]
	,[cewsEmailWebSite]
	,[cewbDefault]
	,[cewnRecUserID]
	,[cewdDtCreated]
	,[cewnModifyUserID]
	,[cewdDtModified]
	,[cewnLevelNo]
	,[saga]
	,[cewnComments]
)
SELECT 
	C.cinnContactCtg		as cewnContactCtgID
	,C.cinnContactID		as cewnContactID
	,'E'					as cewsEmailWebsiteFlag
	,ea.name				as cewsEmailWebSite
	,null					as cewbDefault
	,368					as cewnRecUserID
	,getdate()				as cewdDtCreated
	,368					as cewnModifyUserID
	,getdate()				as cewdDtModified
	,null					as cewnLevelNo
	,1						as saga -- indicate email
	,lb.name AS				[cewnComments]
FROM JoelBieber_GrowPath..email_address ea
JOIN JoelBieber_GrowPath..entity e
	on e.id = ea.entity_id
JOIN [sma_MST_IndvContacts] C
	on C.saga = e.id
JOIN JoelBieber_GrowPath..lookup_bucket lb
	ON ea.email_address_type_id = lb.id
--WHERE isnull(email,'') <> ''


---- Work Email
--INSERT INTO [sma_MST_EmailWebsite]
--(
--	[cewnContactCtgID]
--	,[cewnContactID]
--	,[cewsEmailWebsiteFlag]
--	,[cewsEmailWebSite]
--	,[cewbDefault]
--	,[cewnRecUserID]
--	,[cewdDtCreated]
--	,[cewnModifyUserID]
--	,[cewdDtModified]
--	,[cewnLevelNo]
--	,[saga]
--)
--SELECT 
--	C.cinnContactCtg		as cewnContactCtgID
--	,C.cinnContactID		as cewnContactID
--	,'E'					as cewsEmailWebsiteFlag
--	,N.email_work			as cewsEmailWebSite
--	,null					as cewbDefault
--	,368					as cewnRecUserID
--	,getdate()				as cewdDtCreated
--	,368					as cewnModifyUserID
--	,getdate()				as cewdDtModified
--	,null					as cewnLevelNo
--	,2						as saga -- indicate email_work
-- FROM [TestNeedles].[dbo].[names] N
-- JOIN [sma_MST_IndvContacts] C
-- 	on C.saga = N.names_id
-- WHERE isnull(email_work,'') <> ''


---- Other Email
-- INSERT INTO [sma_MST_EmailWebsite]
--(
--	[cewnContactCtgID]
--	,[cewnContactID]
--	,[cewsEmailWebsiteFlag]
--	,[cewsEmailWebSite]
--	,[cewbDefault]
--	,[cewnRecUserID]
--	,[cewdDtCreated]
--	,[cewnModifyUserID]
--	,[cewdDtModified]
--	,[cewnLevelNo]
--	,[saga]
--)
-- SELECT 
--	C.cinnContactCtg		as cewnContactCtgID
--	,C.cinnContactID		as cewnContactID
--	,'E'					as cewsEmailWebsiteFlag
--	,N.other_email			as cewsEmailWebSite
--	,null					as cewbDefault
--	,368					as cewnRecUserID
--	,getdate()				as cewdDtCreated
--	,368					as cewnModifyUserID
--	,getdate()				as cewdDtModified
--	,null					as cewnLevelNo
--	,3						as saga -- indicate other_email
--FROM [TestNeedles].[dbo].[names] N
--JOIN [sma_MST_IndvContacts] C
--	on C.saga = N.names_id
--WHERE isnull(other_email,'') <> ''




--------------------------------------------------------------------
----- (2/3) CONSTRUCT SMA_MST_EMAILWEBSITE FOR ORGANIZATION ------
--------------------------------------------------------------------

-- Email
INSERT INTO [sma_MST_EmailWebsite]
(
	[cewnContactCtgID]
	,[cewnContactID]
	,[cewsEmailWebsiteFlag]
	,[cewsEmailWebSite]
	,[cewbDefault]
	,[cewnRecUserID]
	,[cewdDtCreated]
	,[cewnModifyUserID]
	,[cewdDtModified]
	,[cewnLevelNo]
	,[saga]
)
SELECT 
	C.connContactCtg		as cewnContactCtgID
	,C.connContactID		as cewnContactID
	,'E'					as cewsEmailWebsiteFlag
	,ea.name				as cewsEmailWebSite
	,null					as cewbDefault
	,368					as cewnRecUserID
	,getdate()				as cewdDtCreated
	,368					as cewnModifyUserID
	,getdate()				as cewdDtModified
	,null					as cewnLevelNo
	,1						as saga -- indicate email
	,lb.name AS				[cewnComments]
FROM JoelBieber_GrowPath..email_address ea
JOIN JoelBieber_GrowPath..entity e
	on e.id = ea.entity_id
JOIN [sma_MST_OrgContacts] C
	on C.saga = e.id
JOIN JoelBieber_GrowPath..lookup_bucket lb
	ON ea.email_address_type_id = lb.id


--	C.connContactCtg		as cewnContactCtgID
--	,C.connContactID		as cewnContactID
--	,'E'					as cewsEmailWebsiteFlag
--	,N.email				as cewsEmailWebSite
--	,null					as cewbDefault
--	,368					as cewnRecUserID
--	,getdate()				as cewdDtCreated
--	,368					as cewnModifyUserID
--	,getdate()				as cewdDtModified
--	,null					as cewnLevelNo
--	,1						as saga -- indicate email
--FROM [TestNeedles].[dbo].[names] N
--JOIN [sma_MST_OrgContacts] C
--	on C.saga = N.names_id
--WHERE isnull(email,'') <> ''

---- Work Email
--INSERT INTO [sma_MST_EmailWebsite]
--(
--	[cewnContactCtgID]
--	,[cewnContactID]
--	,[cewsEmailWebsiteFlag]
--	,[cewsEmailWebSite]
--	,[cewbDefault]
--	,[cewnRecUserID]
--	,[cewdDtCreated]
--	,[cewnModifyUserID]
--	,[cewdDtModified]
--	,[cewnLevelNo]
--	,[saga]
--)
--SELECT 
--	C.connContactCtg		as cewnContactCtgID
--	,C.connContactID		as cewnContactID
--	,'E'					as cewsEmailWebsiteFlag
--	,N.email_work			as cewsEmailWebSite
--	,null					as cewbDefault
--	,368					as cewnRecUserID
--	,getdate()				as cewdDtCreated
--	,368					as cewnModifyUserID
--	,getdate()				as cewdDtModified
--	,null					as cewnLevelNo
--	,2						as saga -- indicate email_work
--FROM [TestNeedles].[dbo].[names] N
--JOIN [sma_MST_OrgContacts] C
--	on C.saga = N.names_id
--WHERE isnull(email_work,'') <> ''

---- Other Email
--INSERT INTO [sma_MST_EmailWebsite]
--(
--	[cewnContactCtgID]
--	,[cewnContactID]
--	,[cewsEmailWebsiteFlag]
--	,[cewsEmailWebSite]
--	,[cewbDefault]
--	,[cewnRecUserID]
--	,[cewdDtCreated]
--	,[cewnModifyUserID]
--	,[cewdDtModified]
--	,[cewnLevelNo]
--	,[saga]
--)
--SELECT 
--	C.connContactCtg		as cewnContactCtgID
--	,C.connContactID		as cewnContactID
--	,'E'					as cewsEmailWebsiteFlag
--	,N.other_email			as cewsEmailWebSite
--	,null					as cewbDefault
--	,368					as cewnRecUserID
--	,getdate()				as cewdDtCreated
--	,368					as cewnModifyUserID
--	,getdate()				as cewdDtModified
--	,null					as cewnLevelNo
--	,3						as saga -- indicate other_email
--FROM [TestNeedles].[dbo].[names] N
--JOIN [sma_MST_OrgContacts] C
--	on C.saga = N.names_id
--WHERE isnull(other_email,'') <> ''

---- Website
--INSERT INTO [sma_MST_EmailWebsite]
--(
--	[cewnContactCtgID]
--	,[cewnContactID]
--	,[cewsEmailWebsiteFlag]
--	,[cewsEmailWebSite]
--	,[cewbDefault]
--	,[cewnRecUserID]
--	,[cewdDtCreated]
--	,[cewnModifyUserID]
--	,[cewdDtModified]
--	,[cewnLevelNo]
--	,[saga]
--)
--SELECT 
--	C.connContactCtg		as cewnContactCtgID
--	,C.connContactID		as cewnContactID
--	,'W'					as cewsEmailWebsiteFlag
--	,N.website				as cewsEmailWebSite
--	,null					as cewbDefault
--	,368					as cewnRecUserID
--	,getdate()				as cewdDtCreated
--	,368					as cewnModifyUserID
--	,getdate()				as cewdDtModified
--	,null					as cewnLevelNo
--	,4						as saga -- indicate website
--FROM [TestNeedles].[dbo].[names] N
--JOIN [sma_MST_OrgContacts] C
--	on C.saga = N.names_id
--WHERE isnull(website,'') <> ''

 ---
 ALTER TABLE [sma_MST_EmailWebsite] ENABLE TRIGGER ALL
 GO
 ---


 /*
---- (3/3 set default)

update [sma_MST_EmailWebsite] set cewbDefault=0  
update [sma_MST_EmailWebsite] set cewbDefault=1 where cewsEmailWebsiteFlag='W'

declare @cewnContactID int;
declare @email_Count int;
declare @email_work_Count int;
declare @other_email_Count int;

declare @email_cewnEmlWSID int;
declare @email_work_cewnEmlWSID int;
declare @other_email_cewnEmlWSID int;
 
DECLARE EmailWebsite_cursor CURSOR FOR 
select distinct cewnContactID from [sma_MST_EmailWebsite]

OPEN EmailWebsite_cursor 

FETCH NEXT FROM EmailWebsite_cursor
INTO @cewnContactID

WHILE @@FETCH_STATUS = 0
BEGIN

select @email_Count=count(*),@email_cewnEmlWSID=min(cewnEmlWSID) from [sma_MST_EmailWebsite] where cewnContactID=@cewnContactID and saga=1 
select @email_work_Count=count(*),@email_work_cewnEmlWSID=min(cewnEmlWSID) from [sma_MST_EmailWebsite] where cewnContactID=@cewnContactID and saga=2
select @other_email_Count=count(*),@other_email_cewnEmlWSID=min(cewnEmlWSID) from [sma_MST_EmailWebsite] where cewnContactID=@cewnContactID and saga=3

if ( @email_Count != 0 )
begin
update [sma_MST_EmailWebsite] set cewbDefault=1 where cewnEmlWSID=@email_cewnEmlWSID
end

if ( @email_Count = 0 and @email_work_Count != 0)
begin
update [sma_MST_EmailWebsite] set cewbDefault=1 where cewnEmlWSID=@email_work_cewnEmlWSID
end

if ( @email_Count = 0 and @email_work_Count = 0 and @other_email_Count <> 0)
begin
update [sma_MST_EmailWebsite] set cewbDefault=1 where cewnEmlWSID=@other_email_cewnEmlWSID
end


FETCH NEXT FROM EmailWebsite_cursor
INTO @cewnContactID

END 

CLOSE EmailWebsite_cursor;
DEALLOCATE EmailWebsite_cursor;

*/


