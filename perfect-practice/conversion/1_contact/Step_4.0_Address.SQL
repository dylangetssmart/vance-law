
use [SAPerfectPracticeEmroch]

/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] 
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_MST_Address]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] enable trigger all
*/

----(0)----
if not exists (select * from sma_MST_AddressTypes where addsDscrptn='BILLING_ADDR' and addnContactCategoryID=1)
begin
    insert into sma_MST_AddressTypes (addsCode,addsDscrptn,addnContactCategoryID)
	(
    select 'BILLING_ADDR','BILLING_ADDR',1
		union
    select 'HOME_ADDRESS_PH','HOME_ADDRESS_PH',1
		union
    select 'MAIN_ADDRESS_PH','MAIN_ADDRESS_PH',1
		union
    select 'WORK_ADDRESS_PH','WORK_ADDRESS_PH',1
	)
end

if not exists (select * from sma_MST_AddressTypes where addsDscrptn='BILLING_ADDR' and addnContactCategoryID=2)
begin
    insert into sma_MST_AddressTypes (addsCode,addsDscrptn,addnContactCategoryID)
	(
    select 'BILLING_ADDR','BILLING_ADDR',2
		union
    select 'HOME_ADDRESS_PH','HOME_ADDRESS_PH',2
		union
    select 'MAIN_ADDRESS_PH','MAIN_ADDRESS_PH',2
		union
    select 'WORK_ADDRESS_PH','WORK_ADDRESS_PH',2
	)end




/*** Checking 
select 'Home',1
union
select 'Business',1
union
select 'Other',1
union
select 'Home',2
union
select 'Business',2
union
select 'Other',2
except
select addsDscrptn,addnContactCategoryID from [SAPerfectPracticeEmroch].[dbo].[sma_MST_AddressTypes] 
***/
/***
 select addrtype,count(addrtype)
 from [PerfectPracticeEmroch].[dbo].[eaddress] A
 group by addrtype
 having count(addrtype) > 9000

addrtype		occurrence
BILLING_ADDR	50585
CELLULAR		9193
EMAIL_ADDRESS	9180
HOME_ADDRESS_PH	52468
MAIN_ADDRESS_PH	10938
WORK_ADDRESS_PH	57596
FAX				11300
***/


---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] disable trigger all
---

---(1)--- 
 insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address]
	(
		[addnContactCtgID],[addnContactID],[addnAddressTypeID],[addsAddressType],[addsAddTypeCode],[addsAddress1],[addsAddress2],[addsAddress3],[addsStateCode],[addsCity],[addnZipID],
		[addsZip],[addsCounty],[addsCountry],[addbIsResidence],[addbPrimary],[adddFromDate],[adddToDate],[addnCompanyID],[addsDepartment],[addsTitle],[addnContactPersonID],[addsComments],
		[addbIsCurrent],[addbIsMailing],[addnRecUserID],[adddDtCreated],[addnModifyUserID],[adddDtModified],[addnLevelNo],[caseno],[addbDeleted],[addsZipExtn],[saga]
	)
   select 
		I.cinnContactCtg	as addnContactCtgID,
		I.cinnContactID		as addnContactID,
		(select T.addnAddTypeID from [dbo].[sma_MST_AddressTypes] T where T.addnContactCategoryID = 1 and T.addsDscrptn='BILLING_ADDR')  as addnAddressTypeID, 
		(select T.addsDscrptn from [dbo].[sma_MST_AddressTypes] T where T.addnContactCategoryID = 1 and T.addsDscrptn='BILLING_ADDR')	   as addsAddressType, 
		(select T.addsCode from [dbo].[sma_MST_AddressTypes] T where T.addnContactCategoryID = 1 and T.addsDscrptn='BILLING_ADDR')	   as addsAddTypeCode,
		left(convert(varchar(MAX),A.[addrline]),75)				as addsAddress1,
		substring(convert(varchar(MAX),A.[addrline]),75+1,75)	as addsAddress2, 
		substring(convert(varchar(MAX),A.[addrline]),150+1,75)	as addsAddress3,
		left(A.[state],20)	as addsStateCode,
		left(A.[city],50)	as addsCity,
		NULL				as addnZipID,
		left(A.[zipcode],10) as addsZip,
		left(A.[county],30)	as addsCounty,
		null				as addsCountry,
		null				as addbIsResidence,
		case when A.[seqnum]=0 then 1 else 0 end as addbPrimary,
		null,null,null,null,null,null,
		null				as [addsComments],
		null,null,
		368					as addnRecUserID,
		getdate()			as adddDtCreated,
		368					as addnModifyUserID,
		getdate()			as adddDtModified,
		null,null,null,null,null
 from [PerfectPracticeEmroch].[dbo].[eaddress] A
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Indvcontacts] I on I.saga = A.entitynum
 where A.[addrtype]='BILLING_ADDR'

---(2)--- 
 insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address]
	(
		[addnContactCtgID],[addnContactID],[addnAddressTypeID],[addsAddressType],[addsAddTypeCode],[addsAddress1],[addsAddress2],[addsAddress3],[addsStateCode],[addsCity],[addnZipID],
		[addsZip],[addsCounty],[addsCountry],[addbIsResidence],[addbPrimary],[adddFromDate],[adddToDate],[addnCompanyID],[addsDepartment],[addsTitle],[addnContactPersonID],[addsComments],
		[addbIsCurrent],[addbIsMailing],[addnRecUserID],[adddDtCreated],[addnModifyUserID],[adddDtModified],[addnLevelNo],[caseno],[addbDeleted],[addsZipExtn],[saga]
	)
   select 
		I.cinnContactCtg	as addnContactCtgID,
		I.cinnContactID		as addnContactID,
		(select T.addnAddTypeID from [dbo].[sma_MST_AddressTypes] T where T.addnContactCategoryID = 1 and T.addsDscrptn='HOME_ADDRESS_PH')  as addnAddressTypeID, 
		(select T.addsDscrptn from [dbo].[sma_MST_AddressTypes] T where T.addnContactCategoryID = 1 and T.addsDscrptn='HOME_ADDRESS_PH')	   as addsAddressType, 
		(select T.addsCode from [dbo].[sma_MST_AddressTypes] T where T.addnContactCategoryID = 1 and T.addsDscrptn='HOME_ADDRESS_PH')	   as addsAddTypeCode,
		left(convert(varchar(MAX),A.[addrline]),75)				as addsAddress1,
		substring(convert(varchar(MAX),A.[addrline]),75+1,75)	as addsAddress2, 
		substring(convert(varchar(MAX),A.[addrline]),150+1,75)	as addsAddress3,
		left(A.[state],20)	as addsStateCode,
		left(A.[city],50)	as addsCity,
		NULL				as addnZipID,
		left(A.[zipcode],10) as addsZip,
		left(A.[county],30)	as addsCounty,
		null				as addsCountry,
		null				as addbIsResidence,
		case when A.[seqnum]=0 then 1 else 0 end as addbPrimary,
		null,null,null,null,null,null,
		null				as [addsComments],
		null,null,
		368					as addnRecUserID,
		getdate()			as adddDtCreated,
		368					as addnModifyUserID,
		getdate()			as adddDtModified,
		null,null,null,null,null
 from [PerfectPracticeEmroch].[dbo].[eaddress] A
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Indvcontacts] I on I.saga = A.entitynum
 where A.[addrtype]='HOME_ADDRESS_PH'

  ---(3)--- 
 insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address]
	(
		[addnContactCtgID],[addnContactID],[addnAddressTypeID],[addsAddressType],[addsAddTypeCode],[addsAddress1],[addsAddress2],[addsAddress3],[addsStateCode],[addsCity],[addnZipID],
		[addsZip],[addsCounty],[addsCountry],[addbIsResidence],[addbPrimary],[adddFromDate],[adddToDate],[addnCompanyID],[addsDepartment],[addsTitle],[addnContactPersonID],[addsComments],
		[addbIsCurrent],[addbIsMailing],[addnRecUserID],[adddDtCreated],[addnModifyUserID],[adddDtModified],[addnLevelNo],[caseno],[addbDeleted],[addsZipExtn],[saga]
	)
   select 
		I.cinnContactCtg	as addnContactCtgID,
		I.cinnContactID		as addnContactID,
		(select T.addnAddTypeID from [dbo].[sma_MST_AddressTypes] T where T.addnContactCategoryID = 1 and T.addsDscrptn='MAIN_ADDRESS_PH')  as addnAddressTypeID, 
		(select T.addsDscrptn from [dbo].[sma_MST_AddressTypes] T where T.addnContactCategoryID = 1 and T.addsDscrptn='MAIN_ADDRESS_PH')	   as addsAddressType, 
		(select T.addsCode from [dbo].[sma_MST_AddressTypes] T where T.addnContactCategoryID = 1 and T.addsDscrptn='MAIN_ADDRESS_PH')	   as addsAddTypeCode,
		left(convert(varchar(MAX),A.[addrline]),75)				as addsAddress1,
		substring(convert(varchar(MAX),A.[addrline]),75+1,75)	as addsAddress2, 
		substring(convert(varchar(MAX),A.[addrline]),150+1,75)	as addsAddress3,
		left(A.[state],20)	as addsStateCode,
		left(A.[city],50)	as addsCity,
		NULL				as addnZipID,
		left(A.[zipcode],10) as addsZip,
		left(A.[county],30)	as addsCounty,
		null				as addsCountry,
		null				as addbIsResidence,
		case when A.[seqnum]=0 then 1 else 0 end as addbPrimary,
		null,null,null,null,null,null,
		null				as [addsComments],
		null,null,
		368					as addnRecUserID,
		getdate()			as adddDtCreated,
		368					as addnModifyUserID,
		getdate()			as adddDtModified,
		null,null,null,null,null
 from [PerfectPracticeEmroch].[dbo].[eaddress] A
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Indvcontacts] I on I.saga = A.entitynum
 where A.[addrtype]='MAIN_ADDRESS_PH'

  ---(4)--- 
 insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address]
	(
		[addnContactCtgID],[addnContactID],[addnAddressTypeID],[addsAddressType],[addsAddTypeCode],[addsAddress1],[addsAddress2],[addsAddress3],[addsStateCode],[addsCity],[addnZipID],
		[addsZip],[addsCounty],[addsCountry],[addbIsResidence],[addbPrimary],[adddFromDate],[adddToDate],[addnCompanyID],[addsDepartment],[addsTitle],[addnContactPersonID],[addsComments],
		[addbIsCurrent],[addbIsMailing],[addnRecUserID],[adddDtCreated],[addnModifyUserID],[adddDtModified],[addnLevelNo],[caseno],[addbDeleted],[addsZipExtn],[saga]
	)
   select 
		I.cinnContactCtg	as addnContactCtgID,
		I.cinnContactID		as addnContactID,
		(select T.addnAddTypeID from [dbo].[sma_MST_AddressTypes] T where T.addnContactCategoryID = 1 and T.addsDscrptn='WORK_ADDRESS_PH')  as addnAddressTypeID, 
		(select T.addsDscrptn from [dbo].[sma_MST_AddressTypes] T where T.addnContactCategoryID = 1 and T.addsDscrptn='WORK_ADDRESS_PH')	   as addsAddressType, 
		(select T.addsCode from [dbo].[sma_MST_AddressTypes] T where T.addnContactCategoryID = 1 and T.addsDscrptn='WORK_ADDRESS_PH')	   as addsAddTypeCode,
		left(convert(varchar(MAX),A.[addrline]),75)				as addsAddress1,
		substring(convert(varchar(MAX),A.[addrline]),75+1,75)	as addsAddress2, 
		substring(convert(varchar(MAX),A.[addrline]),150+1,75)	as addsAddress3,
		left(A.[state],20)	as addsStateCode,
		left(A.[city],50)	as addsCity,
		NULL				as addnZipID,
		left(A.[zipcode],10) as addsZip,
		left(A.[county],30)	as addsCounty,
		null				as addsCountry,
		null				as addbIsResidence,
		case when A.[seqnum]=0 then 1 else 0 end as addbPrimary,
		null,null,null,null,null,null,
		null				as [addsComments],
		null,null,
		368					as addnRecUserID,
		getdate()			as adddDtCreated,
		368					as addnModifyUserID,
		getdate()			as adddDtModified,
		null,null,null,null,null
 from [PerfectPracticeEmroch].[dbo].[eaddress] A
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Indvcontacts] I on I.saga = A.entitynum
 where A.[addrtype]='WORK_ADDRESS_PH'


 -- select addrtype,count(addrtype)
-- from [PerfectPracticeEmroch].[dbo].[eaddress] A
-- group by addrtype
-- having count(addrtype) > 9000

--addrtype		occurrence
--BILLING_ADDR	50585
--CELLULAR		9193
--EMAIL_ADDRESS	9180
--HOME_ADDRESS_PH	52468
--MAIN_ADDRESS_PH	10938
--WORK_ADDRESS_PH	57596
--FAX				11300


 ---(1)---
  insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address]
	(
		[addnContactCtgID],[addnContactID],[addnAddressTypeID],[addsAddressType],[addsAddTypeCode],[addsAddress1],[addsAddress2],[addsAddress3],[addsStateCode],[addsCity],[addnZipID],
		[addsZip],[addsCounty],[addsCountry],[addbIsResidence],[addbPrimary],[adddFromDate],[adddToDate],[addnCompanyID],[addsDepartment],[addsTitle],[addnContactPersonID],[addsComments],
		[addbIsCurrent],[addbIsMailing],[addnRecUserID],[adddDtCreated],[addnModifyUserID],[adddDtModified],[addnLevelNo],[caseno],[addbDeleted],[addsZipExtn],[saga]
	)

  select 
		O.connContactCtg	as addnContactCtgID,
		O.connContactID		as addnContactID,
		(select T.addnAddTypeID from [SAPerfectPracticeEmroch].[dbo].[sma_MST_AddressTypes] T where T.addnContactCategoryID = 2 and T.addsDscrptn='BILLING_ADDR') as addnAddressTypeID, 
		(select T.addsDscrptn from [SAPerfectPracticeEmroch].[dbo].[sma_MST_AddressTypes] T where T.addnContactCategoryID = 2 and T.addsDscrptn='BILLING_ADDR')   as addsAddressType,
		(select T.addsCode from [SAPerfectPracticeEmroch].[dbo].[sma_MST_AddressTypes] T where T.addnContactCategoryID = 2 and T.addsDscrptn='BILLING_ADDR')	    as addsAddTypeCode,
		left(convert(varchar(MAX),A.[addrline]),75)				as addsAddress1,
		substring(convert(varchar(MAX),A.[addrline]),75+1,75)	as addsAddress2, 
		substring(convert(varchar(MAX),A.[addrline]),150+1,75)	as addsAddress3,
		left(A.[state],20)	as addsStateCode,
		left(A.[city],50)	as addsCity,
		NULL				as addnZipID,
		left(A.[zipcode],10) as addsZip,
		left(A.[county],30)	as addsCounty,
		null				as addsCountry,
		null				as addbIsResidence,
		case when A.[seqnum]=0 then 1 else 0 end as addbPrimary,
		null,null,null,null,null,null,
		null				as [addsComments],
		null,null,
		368					as addnRecUserID,
		getdate()			as adddDtCreated,
		368					as addnModifyUserID,
		getdate()			as adddDtModified,
		null,null,null,null,null
 from [PerfectPracticeEmroch].[dbo].[eaddress] A
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Orgcontacts] O on O.saga = A.entitynum
 where A.[addrtype]='BILLING_ADDR'

 
 ---(2)---
  insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address]
	(
		[addnContactCtgID],[addnContactID],[addnAddressTypeID],[addsAddressType],[addsAddTypeCode],[addsAddress1],[addsAddress2],[addsAddress3],[addsStateCode],[addsCity],[addnZipID],
		[addsZip],[addsCounty],[addsCountry],[addbIsResidence],[addbPrimary],[adddFromDate],[adddToDate],[addnCompanyID],[addsDepartment],[addsTitle],[addnContactPersonID],[addsComments],
		[addbIsCurrent],[addbIsMailing],[addnRecUserID],[adddDtCreated],[addnModifyUserID],[adddDtModified],[addnLevelNo],[caseno],[addbDeleted],[addsZipExtn],[saga]
	)

  select 
		O.connContactCtg	as addnContactCtgID,
		O.connContactID		as addnContactID,
		(select T.addnAddTypeID from [SAPerfectPracticeEmroch].[dbo].[sma_MST_AddressTypes] T where T.addnContactCategoryID = 2 and T.addsDscrptn='HOME_ADDRESS_PH') as addnAddressTypeID, 
		(select T.addsDscrptn from [SAPerfectPracticeEmroch].[dbo].[sma_MST_AddressTypes] T where T.addnContactCategoryID = 2 and T.addsDscrptn='HOME_ADDRESS_PH')   as addsAddressType,
		(select T.addsCode from [SAPerfectPracticeEmroch].[dbo].[sma_MST_AddressTypes] T where T.addnContactCategoryID = 2 and T.addsDscrptn='HOME_ADDRESS_PH')	    as addsAddTypeCode,
		left(convert(varchar(MAX),A.[addrline]),75)				as addsAddress1,
		substring(convert(varchar(MAX),A.[addrline]),75+1,75)	as addsAddress2, 
		substring(convert(varchar(MAX),A.[addrline]),150+1,75)	as addsAddress3,
		left(A.[state],20)	as addsStateCode,
		left(A.[city],50)	as addsCity,
		NULL				as addnZipID,
		left(A.[zipcode],10) as addsZip,
		left(A.[county],30)	as addsCounty,
		null				as addsCountry,
		null				as addbIsResidence,
		case when A.[seqnum]=0 then 1 else 0 end as addbPrimary,
		null,null,null,null,null,null,
		null				as [addsComments],
		null,null,
		368					as addnRecUserID,
		getdate()			as adddDtCreated,
		368					as addnModifyUserID,
		getdate()			as adddDtModified,
		null,null,null,null,null
 from [PerfectPracticeEmroch].[dbo].[eaddress] A
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Orgcontacts] O on O.saga = A.entitynum
 where A.[addrtype]='HOME_ADDRESS_PH'


  ---(3)---
  insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address]
	(
		[addnContactCtgID],[addnContactID],[addnAddressTypeID],[addsAddressType],[addsAddTypeCode],[addsAddress1],[addsAddress2],[addsAddress3],[addsStateCode],[addsCity],[addnZipID],
		[addsZip],[addsCounty],[addsCountry],[addbIsResidence],[addbPrimary],[adddFromDate],[adddToDate],[addnCompanyID],[addsDepartment],[addsTitle],[addnContactPersonID],[addsComments],
		[addbIsCurrent],[addbIsMailing],[addnRecUserID],[adddDtCreated],[addnModifyUserID],[adddDtModified],[addnLevelNo],[caseno],[addbDeleted],[addsZipExtn],[saga]
	)

  select 
		O.connContactCtg	as addnContactCtgID,
		O.connContactID		as addnContactID,
		(select T.addnAddTypeID from [SAPerfectPracticeEmroch].[dbo].[sma_MST_AddressTypes] T where T.addnContactCategoryID = 2 and T.addsDscrptn='MAIN_ADDRESS_PH') as addnAddressTypeID, 
		(select T.addsDscrptn from [SAPerfectPracticeEmroch].[dbo].[sma_MST_AddressTypes] T where T.addnContactCategoryID = 2 and T.addsDscrptn='MAIN_ADDRESS_PH')   as addsAddressType,
		(select T.addsCode from [SAPerfectPracticeEmroch].[dbo].[sma_MST_AddressTypes] T where T.addnContactCategoryID = 2 and T.addsDscrptn='MAIN_ADDRESS_PH')	    as addsAddTypeCode,
		left(convert(varchar(MAX),A.[addrline]),75)				as addsAddress1,
		substring(convert(varchar(MAX),A.[addrline]),75+1,75)	as addsAddress2, 
		substring(convert(varchar(MAX),A.[addrline]),150+1,75)	as addsAddress3,
		left(A.[state],20)	as addsStateCode,
		left(A.[city],50)	as addsCity,
		NULL				as addnZipID,
		left(A.[zipcode],10) as addsZip,
		left(A.[county],30)	as addsCounty,
		null				as addsCountry,
		null				as addbIsResidence,
		case when A.[seqnum]=0 then 1 else 0 end as addbPrimary,
		null,null,null,null,null,null,
		null				as [addsComments],
		null,null,
		368					as addnRecUserID,
		getdate()			as adddDtCreated,
		368					as addnModifyUserID,
		getdate()			as adddDtModified,
		null,null,null,null,null
 from [PerfectPracticeEmroch].[dbo].[eaddress] A
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Orgcontacts] O on O.saga = A.entitynum
 where A.[addrtype]='MAIN_ADDRESS_PH'

  
 ---(4)---
  insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address]
	(
		[addnContactCtgID],[addnContactID],[addnAddressTypeID],[addsAddressType],[addsAddTypeCode],[addsAddress1],[addsAddress2],[addsAddress3],[addsStateCode],[addsCity],[addnZipID],
		[addsZip],[addsCounty],[addsCountry],[addbIsResidence],[addbPrimary],[adddFromDate],[adddToDate],[addnCompanyID],[addsDepartment],[addsTitle],[addnContactPersonID],[addsComments],
		[addbIsCurrent],[addbIsMailing],[addnRecUserID],[adddDtCreated],[addnModifyUserID],[adddDtModified],[addnLevelNo],[caseno],[addbDeleted],[addsZipExtn],[saga]
	)

  select 
		O.connContactCtg	as addnContactCtgID,
		O.connContactID		as addnContactID,
		(select T.addnAddTypeID from [SAPerfectPracticeEmroch].[dbo].[sma_MST_AddressTypes] T where T.addnContactCategoryID = 2 and T.addsDscrptn='WORK_ADDRESS_PH') as addnAddressTypeID, 
		(select T.addsDscrptn from [SAPerfectPracticeEmroch].[dbo].[sma_MST_AddressTypes] T where T.addnContactCategoryID = 2 and T.addsDscrptn='WORK_ADDRESS_PH')   as addsAddressType,
		(select T.addsCode from [SAPerfectPracticeEmroch].[dbo].[sma_MST_AddressTypes] T where T.addnContactCategoryID = 2 and T.addsDscrptn='WORK_ADDRESS_PH')	    as addsAddTypeCode,
		left(convert(varchar(MAX),A.[addrline]),75)				as addsAddress1,
		substring(convert(varchar(MAX),A.[addrline]),75+1,75)	as addsAddress2, 
		substring(convert(varchar(MAX),A.[addrline]),150+1,75)	as addsAddress3,
		left(A.[state],20)	as addsStateCode,
		left(A.[city],50)	as addsCity,
		NULL				as addnZipID,
		left(A.[zipcode],10) as addsZip,
		left(A.[county],30)	as addsCounty,
		null				as addsCountry,
		null				as addbIsResidence,
		case when A.[seqnum]=0 then 1 else 0 end as addbPrimary,
		null,null,null,null,null,null,
		null				as [addsComments],
		null,null,
		368					as addnRecUserID,
		getdate()			as adddDtCreated,
		368					as addnModifyUserID,
		getdate()			as adddDtModified,
		null,null,null,null,null
 from [PerfectPracticeEmroch].[dbo].[eaddress] A
 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Orgcontacts] O on O.saga = A.entitynum
 where A.[addrtype]='WORK_ADDRESS_PH'


 
---(Appendix)---

---(A.0)
insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address]
	(
	addnContactCtgID,
	addnContactID,
	addnAddressTypeID, 
	addsAddressType,
	addsAddTypeCode,
	addbPrimary,
	addnRecUserID,
	adddDtCreated
	)
select 
		I.cinnContactCtg	as addnContactCtgID,
		I.cinnContactID		as addnContactID,
		(select addnAddTypeID from [SAPerfectPracticeEmroch].[dbo].[sma_MST_AddressTypes] where addsDscrptn='Other' and addnContactCategoryID=1)	as addnAddressTypeID, 
		(select addsDscrptn from [SAPerfectPracticeEmroch].[dbo].[sma_MST_AddressTypes] where addsDscrptn='Other' and addnContactCategoryID=1)	as addsAddressType,
		(select addsCode from [SAPerfectPracticeEmroch].[dbo].[sma_MST_AddressTypes] where addsDscrptn='Other' and addnContactCategoryID=1)		as addsAddTypeCode,
		1					as addbPrimary,
		368					as addnRecUserID,
		getdate()			as adddDtCreated
from [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts] I
left join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] A on A.addnContactID=I.cinnContactID and A.addnContactCtgID=I.cinnContactCtg
where A.addnAddressID is NULL

---(A.1)
insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address]
	(
	addnContactCtgID,
	addnContactID,
	addnAddressTypeID, 
	addsAddressType,
	addsAddTypeCode,
	addbPrimary,
	addnRecUserID,
	adddDtCreated
	)
select 
		O.connContactCtg	as addnContactCtgID,
		O.connContactID		as addnContactID,
		(select addnAddTypeID from [SAPerfectPracticeEmroch].[dbo].[sma_MST_AddressTypes] where addsDscrptn='Other' and addnContactCategoryID=2)	as addnAddressTypeID, 
		(select addsDscrptn from [SAPerfectPracticeEmroch].[dbo].[sma_MST_AddressTypes] where addsDscrptn='Other' and addnContactCategoryID=2)	as addsAddressType,
		(select addsCode from [SAPerfectPracticeEmroch].[dbo].[sma_MST_AddressTypes] where addsDscrptn='Other' and addnContactCategoryID=2)		as addsAddTypeCode,
		1					as addbPrimary,
		368					as addnRecUserID,
		getdate()			as adddDtCreated
from [SAPerfectPracticeEmroch].[dbo].[sma_MST_OrgContacts] O
left join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] A on A.addnContactID=O.connContactID and A.addnContactCtgID=O.connContactCtg
where A.addnAddressID is NULL

----(Appendix)----
update [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] set addbPrimary=1
from
( 
	select 
		I.cinnContactID		as CID,
		A.addnAddressID		as AID,
		ROW_NUMBER() OVER(PARTITION BY I.cinnContactID ORDER BY A.addnAddressID ASC) as RowNumber
	from [SAPerfectPracticeEmroch].[dbo].[sma_MST_Indvcontacts] I 
	inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] A on A.addnContactID=I.cinnContactID and A.addnContactCtgID=I.cinnContactCtg and A.addbPrimary<>1 
	where I.cinnContactID not in 
	( 
	select I.cinnContactID
	from [SAPerfectPracticeEmroch].[dbo].[sma_MST_Indvcontacts] I 
	inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] A on A.addnContactID=I.cinnContactID and A.addnContactCtgID=I.cinnContactCtg and A.addbPrimary=1 
	)
) A 
where A.RowNumber=1
and A.AID=addnAddressID

update [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] set addbPrimary=1
from
( 
	 select 
		O.connContactID		as CID,
		A.addnAddressID		as AID,
		ROW_NUMBER() OVER(PARTITION BY O.connContactID ORDER BY A.addnAddressID ASC) as RowNumber
	 from [SAPerfectPracticeEmroch].[dbo].[sma_MST_OrgContacts] O 
	 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] A on A.addnContactID=O.connContactID and A.addnContactCtgID=O.connContactCtg and A.addbPrimary<>1 
	 where O.connContactID not in 
	 ( 
	 select O.connContactID
	 from [SAPerfectPracticeEmroch].[dbo].[sma_MST_OrgContacts] O 
	 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] A on A.addnContactID=O.connContactID and A.addnContactCtgID=O.connContactCtg and A.addbPrimary=1 
	 )
) A 
where A.RowNumber=1
and A.AID=addnAddressID

 
---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] enable trigger all
---


------------- Check Uniqueness------------
-- select I.cinnContactID
-- 	 from [SAPerfectPracticeEmroch].[dbo].[sma_MST_Indvcontacts] I 
--	 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] A on A.addnContactID=I.cinnContactID and A.addnContactCtgID=I.cinnContactCtg and A.addbPrimary=1 
--	 group by cinnContactID
--	 having count(cinnContactID)>1

-- select O.connContactID
-- 	 from [SAPerfectPracticeEmroch].[dbo].[sma_MST_OrgContacts] O 
--	 inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] A on A.addnContactID=O.connContactID and A.addnContactCtgID=O.connContactCtg and A.addbPrimary=1 
--	 group by connContactID
--	 having count(connContactID)>1

