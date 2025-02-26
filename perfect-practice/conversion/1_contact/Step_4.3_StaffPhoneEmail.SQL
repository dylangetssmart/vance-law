
use [SAPerfectPracticeEmroch]

/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_MST_EmailWebsite] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_MST_EmailWebsite] 
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_MST_EmailWebsite]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_MST_EmailWebsite] enable trigger all
*/

---(0)---
insert into sma_MST_ContactNoType ( ctysDscrptn,ctynContactCategoryID,ctysDefaultTexting )
select 'Work Phone',1,0
union
select 'Work Fax',1,0
except
select ctysDscrptn,ctynContactCategoryID,ctysDefaultTexting from sma_MST_ContactNoType 


---(1)---
insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_EmailWebsite]
  ( [cewnContactCtgID],[cewnContactID],[cewsEmailWebsiteFlag],[cewsEmailWebSite],[cewbDefault],[cewnRecUserID],[cewdDtCreated],[cewnModifyUserID],[cewdDtModified],[cewnLevelNo] )
select 
		I.cinnContactCtg  as cewnContactCtgID,
		I.cinnContactID   as cewnContactID,
		'E'			   as cewsEmailWebsiteFlag,
		email		   as cewsEmailWebSite,
		null			   as cewbDefault,
		368			   as cewnRecUserID,
		getdate()		   as cewdDtCreated,
		null			   as cewnModifyUserID,
		null			   as cewdDtModified,
		null			   as cewnLevelNo
from [PerfectPracticeEmroch].[dbo].[staff] STF
inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Indvcontacts] I on I.cinsGrade = STF.staff_code
where isnull(STF.email,'')<>''



---(2)---  (303) 551-7701 ext. 1071
insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_ContactNumbers]
(     
       [cnnnContactCtgID],[cnnnContactID],[cnnnPhoneTypeID],[cnnsContactNumber],[cnnsExtension],[cnnbPrimary],[cnnbVisible],[cnnnAddressID],[cnnsLabelCaption]
	 ,[cnnnRecUserID],[cnndDtCreated],[cnnnModifyUserID],[cnndDtModified],[cnnnLevelNo],[caseNo]
)
 select 
		I.cinnContactCtg	  as cnnnContactCtgID,
		I.cinnContactID	  as cnnnContactID,
		(select ctynContactNoTypeID from sma_MST_ContactNoType where ctysDscrptn='Work Phone' and ctynContactCategoryID=1) 
						  as cnnnPhoneTypeID,
		left(STF.phone_number,20)	  as cnnsContactNumber,

		null				  as cnnsExtension,
		1				  as cnnbPrimary,
		null				  as cnnbVisible,
		A.addnAddressID	  as cnnnAddressID,
		'Work Phone'  as cnnsLabelCaption,
		368				  as cnnnRecUserID,
		getdate()			  as cnndDtCreated,
		null				  as cnnnModifyUserID,
		null				  as cnndDtModified,
		null,null
from [PerfectPracticeEmroch].[dbo].[staff] STF
inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Indvcontacts] I on I.cinsGrade = STF.staff_code
inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] A on A.addnContactID=I.cinnContactID and A.addnContactCtgID=I.cinnContactCtg and A.addbPrimary=1 
where isnull(STF.phone_number,'')<>''


---(3)---
insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_ContactNumbers]
(     
       [cnnnContactCtgID],[cnnnContactID],[cnnnPhoneTypeID],[cnnsContactNumber],[cnnsExtension],[cnnbPrimary],[cnnbVisible],[cnnnAddressID],[cnnsLabelCaption]
	 ,[cnnnRecUserID],[cnndDtCreated],[cnnnModifyUserID],[cnndDtModified],[cnnnLevelNo],[caseNo]
)
 select 
		I.cinnContactCtg	  as cnnnContactCtgID,
		I.cinnContactID	  as cnnnContactID,
		(select ctynContactNoTypeID from sma_MST_ContactNoType where ctysDscrptn='Work Fax' and ctynContactCategoryID=1) 
						  as cnnnPhoneTypeID,
		left(STF.fax_number,20)	  as cnnsContactNumber,
		null				  as cnnsExtension,
		0				  as cnnbPrimary,
		null				  as cnnbVisible,
		A.addnAddressID	  as cnnnAddressID,
		'Work Fax'	  as cnnsLabelCaption,
		368				  as cnnnRecUserID,
		getdate()			  as cnndDtCreated,
		null				  as cnnnModifyUserID,
		null				  as cnndDtModified,
		null,null
from [PerfectPracticeEmroch].[dbo].[staff] STF
inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Indvcontacts] I on I.cinsGrade = STF.staff_code
inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] A on A.addnContactID=I.cinnContactID and A.addnContactCtgID=I.cinnContactCtg and A.addbPrimary=1 
where isnull(STF.fax_number,'')<>'' 