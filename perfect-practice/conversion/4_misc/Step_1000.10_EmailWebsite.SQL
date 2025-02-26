use [SAPerfectPracticeEmroch]

/*
alter table [dbo].[sma_MST_EmailWebsite] disable trigger all
delete from [dbo].[sma_MST_EmailWebsite] 
DBCC CHECKIDENT ('[dbo].[sma_MST_EmailWebsite]', RESEED, 0);
alter table [dbo].[sma_MST_EmailWebsite] enable trigger all
*/

---
alter table [sma_MST_EmailWebsite] disable trigger all
GO
---

---(1)---
  insert into [dbo].[sma_MST_EmailWebsite]
  ( [cewnContactCtgID],[cewnContactID],[cewsEmailWebsiteFlag],[cewsEmailWebSite],[cewbDefault],[cewnRecUserID],[cewdDtCreated],[cewnModifyUserID],[cewdDtModified],[cewnLevelNo],[saga] )
  select 
		I.cinnContactCtg	as cewnContactCtgID,
		I.cinnContactID		as cewnContactID,
		'E'					as cewsEmailWebsiteFlag,
		left(A.[phnum],255)	as cewsEmailWebSite,
		null				as cewbDefault,
		368					as cewnRecUserID,
		getdate()			as cewdDtCreated,
		368					as cewnModifyUserID,
		getdate()			as cewdDtModified,
		null,
		1					as saga -- indicate email
 from [PerfectPracticeEmroch].[dbo].[eaddress] A
 inner join [dbo].[sma_MST_IndvContacts] I on I.saga = A.entitynum
 where isnull(A.addrtype,'') like '%EMAIL%'
 and isnull(A.addrtype,'') <> 'EMAIL_ADDRESS'
 and A.[phnum] is not null

 --select count(*)  -- 6385: like '%EMAIL%' 859: like '%EMAIL%' and <> 'EMAIL_ADDRESS'  5526: = 'EMAIL_ADDRESS' ( 6385 = 5526+859 )
-- from [PerfectPracticeEmroch].[dbo].[eaddress] A
-- inner join [dbo].[sma_MST_IndvContacts] I on I.saga = A.entitynum
-- where isnull(A.addrtype,'') like '%EMAIL%'

 
---(2)---
  insert into [dbo].[sma_MST_EmailWebsite]
  ( [cewnContactCtgID],[cewnContactID],[cewsEmailWebsiteFlag],[cewsEmailWebSite],[cewbDefault],[cewnRecUserID],[cewdDtCreated],[cewnModifyUserID],[cewdDtModified],[cewnLevelNo],[saga] )
  select 
		O.connContactCtg	as cewnContactCtgID,
		O.connContactID		as cewnContactID,
		'E'					as cewsEmailWebsiteFlag,
		left(A.[phnum],255)	as cewsEmailWebSite,
		null				as cewbDefault,
		368					as cewnRecUserID,
		getdate()			as cewdDtCreated,
		368					as cewnModifyUserID,
		getdate()			as cewdDtModified,
		null,
		1					as saga -- indicate email
 from [PerfectPracticeEmroch].[dbo].[eaddress] A
 inner join [dbo].[sma_MST_OrgContacts] O on O.saga = A.entitynum
 where isnull(A.addrtype,'') like '%EMAIL%'
 and isnull(A.addrtype,'') <> 'EMAIL_ADDRESS'
 and A.[phnum] is not null


 ---(3)---
  insert into [dbo].[sma_MST_EmailWebsite]
  ( [cewnContactCtgID],[cewnContactID],[cewsEmailWebsiteFlag],[cewsEmailWebSite],[cewbDefault],[cewnRecUserID],[cewdDtCreated],[cewnModifyUserID],[cewdDtModified],[cewnLevelNo],[saga] )
  select 
		I.cinnContactCtg	as cewnContactCtgID,
		I.cinnContactID		as cewnContactID,
		'E'					as cewsEmailWebsiteFlag,
		left(A.[addrline],255)	as cewsEmailWebSite,
		null				as cewbDefault,
		368					as cewnRecUserID,
		getdate()			as cewdDtCreated,
		368					as cewnModifyUserID,
		getdate()			as cewdDtModified,
		null,
		1					as saga -- indicate email
 from [PerfectPracticeEmroch].[dbo].[eaddress] A
 inner join [dbo].[sma_MST_IndvContacts] I on I.saga = A.entitynum
 where isnull(A.addrtype,'') like '%EMAIL%'
 and A.[addrline] is not null

---(4)---
  insert into [dbo].[sma_MST_EmailWebsite]
  ( [cewnContactCtgID],[cewnContactID],[cewsEmailWebsiteFlag],[cewsEmailWebSite],[cewbDefault],[cewnRecUserID],[cewdDtCreated],[cewnModifyUserID],[cewdDtModified],[cewnLevelNo],[saga] )
  select 
		O.connContactCtg	as cewnContactCtgID,
		O.connContactID		as cewnContactID,
		'E'					as cewsEmailWebsiteFlag,
		left(A.[addrline],255)	as cewsEmailWebSite,
		null				as cewbDefault,
		368					as cewnRecUserID,
		getdate()			as cewdDtCreated,
		368					as cewnModifyUserID,
		getdate()			as cewdDtModified,
		null,
		1					as saga -- indicate email
 from [PerfectPracticeEmroch].[dbo].[eaddress] A
 inner join [dbo].[sma_MST_OrgContacts] O on O.saga = A.entitynum
 where isnull(A.addrtype,'') like '%EMAIL%'
 and A.[addrline] is not null


 ---
 alter table [sma_MST_EmailWebsite] enable trigger all
 ---
