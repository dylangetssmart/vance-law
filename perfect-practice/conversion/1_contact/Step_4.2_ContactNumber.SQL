
use [SAPerfectPracticeEmroch]

/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_MST_ContactNumbers] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_MST_ContactNumbers] 
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_MST_ContactNumbers]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_MST_ContactNumbers] enable trigger all
*/

/* 
Needles phone columns:
home_phone,home_ext
work_phone,work_extension
fax_number,fax_ext
car_phone,car_ext
beeper_number,beeper_ext
other_phone1,other1_ext
other_phone2,other2_ext
other_phone3,other3_ext
other_phone4,other4_ext
other_phone5,other5_ext
*/

---(0)---
insert into sma_MST_ContactNoType ( ctysDscrptn,ctynContactCategoryID, ctysDefaultTexting )
select 'CELLULAR',1,0
union
select 'FAX',1,0
union
select 'WORK_ADDRESS_PH',1,0
union
select 'MAIN_ADDRESS_PH',1,0	
union
select 'HOME_ADDRESS_PH',1,0	
union
select 'CELLULAR',2,0
union
select 'FAX',2,0
union
select 'WORK_ADDRESS_PH',2,0	
union
select 'MAIN_ADDRESS_PH',2,0	
union
select 'HOME_ADDRESS_PH',2,0	

except
select ctysDscrptn,ctynContactCategoryID,ctysDefaultTexting from sma_MST_ContactNoType 

---(0)----

IF OBJECT_ID (N'dbo.FormatPhone', N'FN') IS NOT NULL
    DROP FUNCTION FormatPhone;
GO
CREATE FUNCTION dbo.FormatPhone(@phone varchar(MAX) )
RETURNS varchar(MAX) 
AS 
BEGIN
    if len(@phone)=10 and ISNUMERIC(@phone)=1 
    begin
	   return '(' + Substring(@phone,1,3) + ') ' + Substring(@phone,4,3) + '-' + Substring(@phone,7,4) ---> this is good for perecman
    end
    return @phone;
END;
GO



---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_MST_ContactNumbers] disable trigger all
---

--(1)--
insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_ContactNumbers]
(     
       [cnnnContactCtgID],[cnnnContactID],[cnnnPhoneTypeID],[cnnsContactNumber],[cnnsExtension],[cnnbPrimary],[cnnbVisible],[cnnnAddressID],[cnnsLabelCaption]
	   ,[cnnnRecUserID],[cnndDtCreated],[cnnnModifyUserID],[cnndDtModified],[cnnnLevelNo],[caseNo]
)
 select 
		I.cinnContactCtg		as cnnnContactCtgID,
		I.cinnContactID			as cnnnContactID,
		(select ctynContactNoTypeID from sma_MST_ContactNoType where ctysDscrptn='WORK_ADDRESS_PH' and ctynContactCategoryID=1) as cnnnPhoneTypeID, 
--		dbo.FormatPhone(E.phnum)	as cnnsContactNumber,
		left(E.phnum,20)		as cnnsContactNumber,
		null					as cnnsExtension,
		1						as cnnbPrimary,
		null					as cnnbVisible,
		A.addnAddressID			as cnnnAddressID,
		'work'					as cnnsLabelCaption,
		368						as cnnnRecUserID,
		getdate()				as cnndDtCreated,
		null					as cnnnModifyUserID,
		null					as cnndDtModified,
		null,null
 from [PerfectPracticeEmroch].[dbo].[eaddress] E
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts] I on I.saga = E.entitynum
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] A on A.addnContactID=I.cinnContactID and A.addnContactCtgID=I.cinnContactCtg and A.addbPrimary=1
 where E.addrtype='WORK_ADDRESS_PH'
 and E.phnum is not null


--(2)--
insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_ContactNumbers]
(     
       [cnnnContactCtgID],[cnnnContactID],[cnnnPhoneTypeID],[cnnsContactNumber],[cnnsExtension],[cnnbPrimary],[cnnbVisible],[cnnnAddressID],[cnnsLabelCaption]
	   ,[cnnnRecUserID],[cnndDtCreated],[cnnnModifyUserID],[cnndDtModified],[cnnnLevelNo],[caseNo]
)
 select 
		I.cinnContactCtg		as cnnnContactCtgID,
		I.cinnContactID			as cnnnContactID,
		(select ctynContactNoTypeID from sma_MST_ContactNoType where ctysDscrptn='MAIN_ADDRESS_PH' and ctynContactCategoryID=1) as cnnnPhoneTypeID, 
--		dbo.FormatPhone(E.phnum)	as cnnsContactNumber,
		left(E.phnum,20)		as cnnsContactNumber,
		null					as cnnsExtension,
		1						as cnnbPrimary,
		null						as cnnbVisible,
		A.addnAddressID			as cnnnAddressID,
		'main'					as cnnsLabelCaption,
		368						as cnnnRecUserID,
		getdate()				as cnndDtCreated,
		null					as cnnnModifyUserID,
		null					as cnndDtModified,
		null,null
 from [PerfectPracticeEmroch].[dbo].[eaddress] E
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts] I on I.saga = E.entitynum
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] A on A.addnContactID=I.cinnContactID and A.addnContactCtgID=I.cinnContactCtg and A.addbPrimary=1
 where E.addrtype='MAIN_ADDRESS_PH'
 and E.phnum is not null

--(3)--
insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_ContactNumbers]
(     
       [cnnnContactCtgID],[cnnnContactID],[cnnnPhoneTypeID],[cnnsContactNumber],[cnnsExtension],[cnnbPrimary],[cnnbVisible],[cnnnAddressID],[cnnsLabelCaption]
	   ,[cnnnRecUserID],[cnndDtCreated],[cnnnModifyUserID],[cnndDtModified],[cnnnLevelNo],[caseNo]
)
 select 
		I.cinnContactCtg		as cnnnContactCtgID,
		I.cinnContactID			as cnnnContactID,
		(select ctynContactNoTypeID from sma_MST_ContactNoType where ctysDscrptn='HOME_ADDRESS_PH' and ctynContactCategoryID=1) as cnnnPhoneTypeID, 
--		dbo.FormatPhone(E.phnum)	as cnnsContactNumber,
		left(E.phnum,20)		as cnnsContactNumber,
		null					as cnnsExtension,
		1						as cnnbPrimary,
		null						as cnnbVisible,
		A.addnAddressID			as cnnnAddressID,
		'home'					as cnnsLabelCaption,
		368						as cnnnRecUserID,
		getdate()				as cnndDtCreated,
		null					as cnnnModifyUserID,
		null					as cnndDtModified,
		null,null
 from [PerfectPracticeEmroch].[dbo].[eaddress] E
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts] I on I.saga = E.entitynum
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] A on A.addnContactID=I.cinnContactID and A.addnContactCtgID=I.cinnContactCtg and A.addbPrimary=1
 where E.addrtype='HOME_ADDRESS_PH'
 and E.phnum is not null

--(4)--
insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_ContactNumbers]
(     
       [cnnnContactCtgID],[cnnnContactID],[cnnnPhoneTypeID],[cnnsContactNumber],[cnnsExtension],[cnnbPrimary],[cnnbVisible],[cnnnAddressID],[cnnsLabelCaption]
	   ,[cnnnRecUserID],[cnndDtCreated],[cnnnModifyUserID],[cnndDtModified],[cnnnLevelNo],[caseNo]
)
 select 
		I.cinnContactCtg		as cnnnContactCtgID,
		I.cinnContactID			as cnnnContactID,
		(select ctynContactNoTypeID from sma_MST_ContactNoType where ctysDscrptn='CELLULAR' and ctynContactCategoryID=1) as cnnnPhoneTypeID, 
--		dbo.FormatPhone(E.phnum)	as cnnsContactNumber,
		left(E.phnum,20)		as cnnsContactNumber,
		null					as cnnsExtension,
		1						as cnnbPrimary,
		null					as cnnbVisible,
		A.addnAddressID			as cnnnAddressID,
		'cellular'				as cnnsLabelCaption,
		368						as cnnnRecUserID,
		getdate()				as cnndDtCreated,
		null					as cnnnModifyUserID,
		null					as cnndDtModified,
		null,null
 from [PerfectPracticeEmroch].[dbo].[eaddress] E
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts] I on I.saga = E.entitynum
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] A on A.addnContactID=I.cinnContactID and A.addnContactCtgID=I.cinnContactCtg and A.addbPrimary=1
 where E.addrtype='CELLULAR'
 and E.phnum is not null

 --(5)--
insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_ContactNumbers]
(     
       [cnnnContactCtgID],[cnnnContactID],[cnnnPhoneTypeID],[cnnsContactNumber],[cnnsExtension],[cnnbPrimary],[cnnbVisible],[cnnnAddressID],[cnnsLabelCaption]
	   ,[cnnnRecUserID],[cnndDtCreated],[cnnnModifyUserID],[cnndDtModified],[cnnnLevelNo],[caseNo]
)
 select 
		I.cinnContactCtg		as cnnnContactCtgID,
		I.cinnContactID			as cnnnContactID,
		(select ctynContactNoTypeID from sma_MST_ContactNoType where ctysDscrptn='FAX' and ctynContactCategoryID=1) as cnnnPhoneTypeID, 
--		dbo.FormatPhone(E.phnum)	as cnnsContactNumber,
		left(E.phnum,20)		as cnnsContactNumber,
		null					as cnnsExtension,
		1						as cnnbPrimary,
		null						as cnnbVisible,
		A.addnAddressID			as cnnnAddressID,
		'fax'					as cnnsLabelCaption,
		368						as cnnnRecUserID,
		getdate()				as cnndDtCreated,
		null					as cnnnModifyUserID,
		null					as cnndDtModified,
		null,null
 from [PerfectPracticeEmroch].[dbo].[eaddress] E
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts] I on I.saga = E.entitynum
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] A on A.addnContactID=I.cinnContactID and A.addnContactCtgID=I.cinnContactCtg and A.addbPrimary=1
 where E.addrtype='FAX'
 and E.phnum is not null

 ---For organization---
 
--(1)--
insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_ContactNumbers]
(     
       [cnnnContactCtgID],[cnnnContactID],[cnnnPhoneTypeID],[cnnsContactNumber],[cnnsExtension],[cnnbPrimary],[cnnbVisible],[cnnnAddressID],[cnnsLabelCaption]
	   ,[cnnnRecUserID],[cnndDtCreated],[cnnnModifyUserID],[cnndDtModified],[cnnnLevelNo],[caseNo]
)
 select 
		O.connContactCtg		as cnnnContactCtgID,
		O.connContactID			as cnnnContactID,
		(select ctynContactNoTypeID from sma_MST_ContactNoType where ctysDscrptn='WORK_ADDRESS_PH' and ctynContactCategoryID=2) as cnnnPhoneTypeID, 
--		dbo.FormatPhone(E.phnum)	as cnnsContactNumber,
		left(E.phnum,20)		as cnnsContactNumber,
		null					as cnnsExtension,
		1						as cnnbPrimary,
		null					as cnnbVisible,
		A.addnAddressID			as cnnnAddressID,
		'work'					as cnnsLabelCaption,
		368						as cnnnRecUserID,
		getdate()				as cnndDtCreated,
		null					as cnnnModifyUserID,
		null					as cnndDtModified,
		null,null
 from [PerfectPracticeEmroch].[dbo].[eaddress] E
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_OrgContacts] O on O.saga = E.entitynum
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] A on A.addnContactID=O.connContactID and A.addnContactCtgID=O.connContactCtg and A.addbPrimary=1
 where E.addrtype='WORK_ADDRESS_PH'
 and E.phnum is not null


--(2)--
insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_ContactNumbers]
(     
       [cnnnContactCtgID],[cnnnContactID],[cnnnPhoneTypeID],[cnnsContactNumber],[cnnsExtension],[cnnbPrimary],[cnnbVisible],[cnnnAddressID],[cnnsLabelCaption]
	   ,[cnnnRecUserID],[cnndDtCreated],[cnnnModifyUserID],[cnndDtModified],[cnnnLevelNo],[caseNo]
)
 select 
		O.connContactCtg		as cnnnContactCtgID,
		O.connContactID			as cnnnContactID,
		(select ctynContactNoTypeID from sma_MST_ContactNoType where ctysDscrptn='MAIN_ADDRESS_PH' and ctynContactCategoryID=2) as cnnnPhoneTypeID, 
--		dbo.FormatPhone(E.phnum)	as cnnsContactNumber,
		left(E.phnum,20)		as cnnsContactNumber,
		null					as cnnsExtension,
		1						as cnnbPrimary,
		null					as cnnbVisible,
		A.addnAddressID			as cnnnAddressID,
		'main'					as cnnsLabelCaption,
		368						as cnnnRecUserID,
		getdate()				as cnndDtCreated,
		null					as cnnnModifyUserID,
		null					as cnndDtModified,
		null,null
 from [PerfectPracticeEmroch].[dbo].[eaddress] E
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_OrgContacts] O on O.saga = E.entitynum
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] A on A.addnContactID=O.connContactID and A.addnContactCtgID=O.connContactCtg and A.addbPrimary=1
 where E.addrtype='MAIN_ADDRESS_PH'
 and E.phnum is not null

--(3)--
insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_ContactNumbers]
(     
       [cnnnContactCtgID],[cnnnContactID],[cnnnPhoneTypeID],[cnnsContactNumber],[cnnsExtension],[cnnbPrimary],[cnnbVisible],[cnnnAddressID],[cnnsLabelCaption]
	   ,[cnnnRecUserID],[cnndDtCreated],[cnnnModifyUserID],[cnndDtModified],[cnnnLevelNo],[caseNo]
)
 select 
		O.connContactCtg		as cnnnContactCtgID,
		O.connContactID			as cnnnContactID,
		(select ctynContactNoTypeID from sma_MST_ContactNoType where ctysDscrptn='HOME_ADDRESS_PH' and ctynContactCategoryID=2) as cnnnPhoneTypeID, 
--		dbo.FormatPhone(E.phnum)	as cnnsContactNumber,
		left(E.phnum,20)		as cnnsContactNumber,
		null					as cnnsExtension,
		1						as cnnbPrimary,
		null					as cnnbVisible,
		A.addnAddressID			as cnnnAddressID,
		'home'					as cnnsLabelCaption,
		368						as cnnnRecUserID,
		getdate()				as cnndDtCreated,
		null					as cnnnModifyUserID,
		null					as cnndDtModified,
		null,null
 from [PerfectPracticeEmroch].[dbo].[eaddress] E
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_OrgContacts] O on O.saga = E.entitynum
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] A on A.addnContactID=O.connContactID and A.addnContactCtgID=O.connContactCtg and A.addbPrimary=1
 where E.addrtype='HOME_ADDRESS_PH'
 and E.phnum is not null

--(4)--
insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_ContactNumbers]
(     
       [cnnnContactCtgID],[cnnnContactID],[cnnnPhoneTypeID],[cnnsContactNumber],[cnnsExtension],[cnnbPrimary],[cnnbVisible],[cnnnAddressID],[cnnsLabelCaption]
	   ,[cnnnRecUserID],[cnndDtCreated],[cnnnModifyUserID],[cnndDtModified],[cnnnLevelNo],[caseNo]
)
 select 
		O.connContactCtg		as cnnnContactCtgID,
		O.connContactID			as cnnnContactID,
		(select ctynContactNoTypeID from sma_MST_ContactNoType where ctysDscrptn='CELLULAR' and ctynContactCategoryID=2) as cnnnPhoneTypeID, 
--		dbo.FormatPhone(E.phnum)	as cnnsContactNumber,
		left(E.phnum,20)		as cnnsContactNumber,
		null					as cnnsExtension,
		1						as cnnbPrimary,
		null					as cnnbVisible,
		A.addnAddressID			as cnnnAddressID,
		'cellular'					as cnnsLabelCaption,
		368						as cnnnRecUserID,
		getdate()				as cnndDtCreated,
		null					as cnnnModifyUserID,
		null					as cnndDtModified,
		null,null
 from [PerfectPracticeEmroch].[dbo].[eaddress] E
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_OrgContacts] O on O.saga = E.entitynum
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] A on A.addnContactID=O.connContactID and A.addnContactCtgID=O.connContactCtg and A.addbPrimary=1
 where E.addrtype='CELLULAR'
 and E.phnum is not null

--(5)--
insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_ContactNumbers]
(     
       [cnnnContactCtgID],[cnnnContactID],[cnnnPhoneTypeID],[cnnsContactNumber],[cnnsExtension],[cnnbPrimary],[cnnbVisible],[cnnnAddressID],[cnnsLabelCaption]
	   ,[cnnnRecUserID],[cnndDtCreated],[cnnnModifyUserID],[cnndDtModified],[cnnnLevelNo],[caseNo]
)
 select 
		O.connContactCtg		as cnnnContactCtgID,
		O.connContactID			as cnnnContactID,
		(select ctynContactNoTypeID from sma_MST_ContactNoType where ctysDscrptn='FAX' and ctynContactCategoryID=2) as cnnnPhoneTypeID, 
--		dbo.FormatPhone(E.phnum)	as cnnsContactNumber,
		left(E.phnum,20)		as cnnsContactNumber,
		null					as cnnsExtension,
		1						as cnnbPrimary,
		null					as cnnbVisible,
		A.addnAddressID			as cnnnAddressID,
		'fax'					as cnnsLabelCaption,
		368						as cnnnRecUserID,
		getdate()				as cnndDtCreated,
		null					as cnnnModifyUserID,
		null					as cnndDtModified,
		null,null
 from [PerfectPracticeEmroch].[dbo].[eaddress] E
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_OrgContacts] O on O.saga = E.entitynum
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] A on A.addnContactID=O.connContactID and A.addnContactCtgID=O.connContactCtg and A.addbPrimary=1
 where E.addrtype='FAX'
 and E.phnum is not null
  
 ---(Appendix) Finally, only one phone number as primary---
update [SAPerfectPracticeEmroch].[dbo].[sma_MST_ContactNumbers] set cnnbPrimary=0
from
(
select 
    ROW_NUMBER() OVER (Partition BY cnnnContactID order by cnnnContactNumberID )  as RowNumber,
    cnnnContactNumberID as ContactNumberID  
from [SAPerfectPracticeEmroch].[dbo].[sma_MST_ContactNumbers] 
where cnnnContactCtgID = (select ctgnCategoryID FROM [SAPerfectPracticeEmroch].[dbo].[sma_MST_ContactCtg] where ctgsDesc='Individual')
) A
where A.RowNumber <> 1
and A.ContactNumberID=cnnnContactNumberID


update [SAPerfectPracticeEmroch].[dbo].[sma_MST_ContactNumbers] set cnnbPrimary=0
from
(
select 
    ROW_NUMBER() OVER (Partition BY cnnnContactID order by cnnnContactNumberID )  as RowNumber,
    cnnnContactNumberID as ContactNumberID  
from [SAPerfectPracticeEmroch].[dbo].[sma_MST_ContactNumbers] 
where cnnnContactCtgID = (select ctgnCategoryID FROM [SAPerfectPracticeEmroch].[dbo].[sma_MST_ContactCtg] where ctgsDesc='Organization')
) A
where A.RowNumber <> 1
and A.ContactNumberID=cnnnContactNumberID


---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_MST_ContactNumbers] enable trigger all
--- 

