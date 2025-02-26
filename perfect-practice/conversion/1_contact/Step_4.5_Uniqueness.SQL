
use [SAPerfectPracticeEmroch]




DBCC DBREINDEX('sma_MST_Address',' ',90) WITH NO_INFOMSGS 
GO
DBCC DBREINDEX('sma_MST_ContactNumbers',' ',90) WITH NO_INFOMSGS 
GO
DBCC DBREINDEX('sma_MST_EmailWebsite',' ',90) WITH NO_INFOMSGS 
GO


----
alter table sma_MST_Address disable trigger all
alter table sma_MST_ContactNumbers disable trigger all
alter table sma_MST_EmailWebsite disable trigger all
----

GO
---(1)--- Phone number uniqueness
update [dbo].[sma_MST_ContactNumbers] set cnnbPrimary= 
    case 
	   when A.RowNumber = 1 then 1 
	   else 0 
    end
from
(
select 
    CN.cnnnContactID	   as ContactID,
    ROW_NUMBER() OVER (Partition BY CN.cnnnContactID order by 
    case
	   when cnnnPhoneTypeID=(select ctynContactNoTypeID from sma_MST_ContactNoType where ctysDscrptn='CELLULAR' and ctynContactCategoryID=CN.cnnnContactCtgID)			then 1
	   when cnnnPhoneTypeID=(select ctynContactNoTypeID from sma_MST_ContactNoType where ctysDscrptn='FAX' and ctynContactCategoryID=CN.cnnnContactCtgID)				then 2
	   when cnnnPhoneTypeID=(select ctynContactNoTypeID from sma_MST_ContactNoType where ctysDscrptn='WORK_ADDRESS_PH' and ctynContactCategoryID=CN.cnnnContactCtgID)	then 3
	   when cnnnPhoneTypeID=(select ctynContactNoTypeID from sma_MST_ContactNoType where ctysDscrptn='MAIN_ADDRESS_PH' and ctynContactCategoryID=CN.cnnnContactCtgID)	then 4
	   when cnnnPhoneTypeID=(select ctynContactNoTypeID from sma_MST_ContactNoType where ctysDscrptn='HOME_ADDRESS_PH' and ctynContactCategoryID=CN.cnnnContactCtgID)	then 5
	   else 0
    end
    )				   as RowNumber,
    CN.cnnnContactNumberID  as ContactNumberID,
    CN.cnnnPhoneTypeID	   as PhoneTypeID
from [dbo].[sma_MST_ContactNumbers] CN where CN.cnnnContactCtgID=1
) A where A.ContactNumberID=cnnnContactNumberID


update [dbo].[sma_MST_ContactNumbers] set cnnbPrimary= 
    case 
	   when A.RowNumber = 1 then 1 
	   else 0 
    end
from
(
select 
    CN.cnnnContactID	   as ContactID,
    ROW_NUMBER() OVER (Partition BY CN.cnnnContactID order by 
    case
	   when cnnnPhoneTypeID=(select ctynContactNoTypeID from sma_MST_ContactNoType where ctysDscrptn='CELLULAR' and ctynContactCategoryID=CN.cnnnContactCtgID)			then 1
	   when cnnnPhoneTypeID=(select ctynContactNoTypeID from sma_MST_ContactNoType where ctysDscrptn='FAX' and ctynContactCategoryID=CN.cnnnContactCtgID)				then 2
	   when cnnnPhoneTypeID=(select ctynContactNoTypeID from sma_MST_ContactNoType where ctysDscrptn='WORK_ADDRESS_PH' and ctynContactCategoryID=CN.cnnnContactCtgID)	then 3
	   when cnnnPhoneTypeID=(select ctynContactNoTypeID from sma_MST_ContactNoType where ctysDscrptn='MAIN_ADDRESS_PH' and ctynContactCategoryID=CN.cnnnContactCtgID)	then 4
	   when cnnnPhoneTypeID=(select ctynContactNoTypeID from sma_MST_ContactNoType where ctysDscrptn='HOME_ADDRESS_PH' and ctynContactCategoryID=CN.cnnnContactCtgID)	then 5
	   else 0
    end
    )				   as RowNumber,
    CN.cnnnContactNumberID  as ContactNumberID,
    CN.cnnnPhoneTypeID	   as PhoneTypeID
from [dbo].[sma_MST_ContactNumbers] CN where CN.cnnnContactCtgID=2
) A where A.ContactNumberID=cnnnContactNumberID


---Check result
select count(*) from [dbo].[sma_MST_ContactNumbers] 
where cnnnContactCtgID=2 and cnnbPrimary= 1

select count(distinct cnnnContactID) from [dbo].[sma_MST_ContactNumbers] 
where cnnnContactCtgID=2


GO
---(2)--- Email uniqueness
update [SAPerfectPracticeEmroch].[dbo].[sma_MST_EmailWebsite] set cewbDefault=
    case
	   when A.RowNumber = 1 then 1
	   else 0
    end
from
(
select 
    ROW_NUMBER() OVER (Partition BY cewnContactID order by cewnEmlWSID ASC )  as RowNumber,
    cewnEmlWSID as EmlWSID
from [SAPerfectPracticeEmroch].[dbo].[sma_MST_EmailWebsite] 
where cewnContactCtgID = (select ctgnCategoryID FROM sma_MST_ContactCtg where ctgsDesc='Individual')
) A
where A.EmlWSID=cewnEmlWSID

---
update [SAPerfectPracticeEmroch].[dbo].[sma_MST_EmailWebsite] set cewbDefault=
    case
	   when A.RowNumber = 1 then 1
	   else 0
    end
from
(
select 
    ROW_NUMBER() OVER (Partition BY cewnContactID order by cewnEmlWSID ASC )  as RowNumber,
    cewnEmlWSID as EmlWSID
from [SAPerfectPracticeEmroch].[dbo].[sma_MST_EmailWebsite] 
where cewnContactCtgID = (select ctgnCategoryID FROM sma_MST_ContactCtg where ctgsDesc='Organization')
) A
where A.EmlWSID=cewnEmlWSID

GO

---(3)--- Address uniqueness
update [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] set addbPrimary=
    case
	   when IV.RowNumber = 1 then 1
	   else 0
    end
from
(
select 
    A.addnAddressID		   as AddressID,
    A.addnContactID		   as ContactID,
    A.addbPrimary,
    ROW_NUMBER() OVER (Partition BY A.addnContactID order by 
    case
	   when A.addbPrimary=1	    then 1  --> case when [dbo].[multi_addresses].[default_addr]='Y' then 1 else 0 end as addbPrimary
	   else 99
    end
    )				   as RowNumber
from [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] A
where addnContactCtgID=(select ctgnCategoryID FROM sma_MST_ContactCtg where ctgsDesc='Individual')
) IV 
where IV.AddressID=addnAddressID


update [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] set addbPrimary=
    case
	   when IV.RowNumber = 1 then 1
	   else 0
    end
from
(
select 
    A.addnAddressID		   as AddressID,
    A.addnContactID		   as ContactID,
    A.addbPrimary,
    ROW_NUMBER() OVER (Partition BY A.addnContactID order by 
    case
	   when A.addbPrimary=1	    then 1  --> case when [dbo].[multi_addresses].[default_addr]='Y' then 1 else 0 end as addbPrimary
	   else 99
    end
    )				   as RowNumber
from [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] A
where addnContactCtgID=(select ctgnCategoryID FROM sma_MST_ContactCtg where ctgsDesc='Organization')
) IV 
where IV.AddressID=addnAddressID



---(Appendix)--- normalize phone format
update sma_MST_ContactNumbers set cnnsContactNumber=
    case
	   when len(dbo.RemoveAlphaCharactersN(cnnsContactNumber))=10 then '(' + SUBSTRING(dbo.RemoveAlphaCharactersN(cnnsContactNumber),1,3) + ') ' + SUBSTRING(dbo.RemoveAlphaCharactersN(cnnsContactNumber),4,3) + '-' + SUBSTRING(dbo.RemoveAlphaCharactersN(cnnsContactNumber),7,4) 
	   when len(dbo.RemoveAlphaCharactersN(cnnsContactNumber))=11 and left(dbo.RemoveAlphaCharactersN(cnnsContactNumber),1)='1' then '(' + SUBSTRING(dbo.RemoveAlphaCharactersN(cnnsContactNumber),2,3) + ') ' + SUBSTRING(dbo.RemoveAlphaCharactersN(cnnsContactNumber),5,3) + '-' + SUBSTRING(dbo.RemoveAlphaCharactersN(cnnsContactNumber),8,4)
	   else dbo.RemoveAlphaCharactersN(cnnsContactNumber)
    end 
GO
----
alter table sma_MST_Address enable trigger all
alter table sma_MST_ContactNumbers enable trigger all
alter table sma_MST_EmailWebsite enable trigger all
----

