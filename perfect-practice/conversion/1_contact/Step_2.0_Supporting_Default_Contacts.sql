
use [SAPerfectPracticeEmroch]


--(1.1)-- ( Note: userid-->IndvContacts )
INSERT INTO [sma_MST_IndvContacts]
([cinbPrimary],[cinnContactTypeID],[cinnContactSubCtgID],[cinsPrefix],[cinsFirstName],[cinsMiddleName],[cinsLastName],[cinsSuffix],[cinsNickName],[cinbStatus],[cinsSSNNo],[cindBirthDate],
[cinsComments],[cinnContactCtg],[cinnRefByCtgID],[cinnReferredBy],[cindDateOfDeath],[cinsCVLink],[cinnMaritalStatusID],[cinnGender],[cinsBirthPlace],[cinnCountyID],[cinsCountyOfResidence],
[cinbFlagForPhoto],[cinsPrimaryContactNo],[cinsHomePhone],[cinsWorkPhone],[cinsMobile],[cinbPreventMailing],[cinnRecUserID],[cindDtCreated],[cinnModifyUserID],[cindDtModified],[cinnLevelNo],
[cinsPrimaryLanguage],[cinsOtherLanguage],[cinbDeathFlag],[cinsCitizenship],[cinsHeight],[cinnWeight],[cinsReligion],[cindMarriageDate],[cinsMarriageLoc],[cinsDeathPlace],[cinsMaidenName],
[cinsOccupation],[saga]) 
   
SELECT distinct 
	1			as [cinbPrimary],
	(select octnOrigContactTypeID FROM [SAPerfectPracticeEmroch].[dbo].[sma_MST_OriginalContactTypes] where octsDscrptn='General' and octnContactCtgID=1) as [cinnContactTypeID], --10
	null			as [cinnContactSubCtgID],
	''			as [cinsPrefix],
	e.first_name	as [cinsFirstName],
	null			as [cinsMiddleName],
	e.last_name	as [cinsLastName],
	null			as [cinsSuffix],
	null			as [cinsNickName],
	1			as [cinbStatus],
	''			as [cinsSSNNo],
	null			as [cindBirthDate],
	'default helper contact'		
				as [cinsComments],
	1,'','',null,'','',null,'',1,1,null,'','','','',0,368,GETDATE(),'',null,0,'','','','','','','',Null,'','','','',
	-1			as [saga]
from
(
select 'unidentified' as first_name, 'plaintiff'  as last_name
    union
select 'unidentified' as first_name, 'defendant'  as last_name
) e


--(1.2)-- ( Note: userid-->address )
INSERT INTO [sma_MST_Address]
([addnContactCtgID],[addnContactID],[addnAddressTypeID],[addsAddressType],[addsAddTypeCode],[addsAddress1],[addsAddress2],[addsAddress3],
[addsStateCode],[addsCity],[addnZipID]
,[addsZip],[addsCounty],[addsCountry],
[addbIsResidence],[addbPrimary],[adddFromDate],[adddToDate],[addnCompanyID],[addsDepartment],[addsTitle],[addnContactPersonID],[addsComments]
,[addbIsCurrent],[addbIsMailing],[addnRecUserID],[adddDtCreated],[addnModifyUserID],[adddDtModified],[addnLevelNo],[caseno],[addbDeleted],[addsZipExtn],[saga])

select  
	   I.cinnContactCtg		  as [addnContactCtgID],
	   I.cinnContactID		  as [addnContactID], 
	   (select addnAddTypeID from sma_MST_AddressTypes where addsDscrptn='Home - Physical' and addnContactCategoryID=1) as [addnAddressTypeID], 
	   ''				  as [addsAddressType],
	   ''				  as [addsAddTypeCode],
	   ''				  as [addsAddress1],
	   ''				  as [addsAddress2],
	   ''				  as [addsAddress3],
	   ''				  as [addsStateCode],
	   ''				  as [addsCity],
	   ''				  as [addnZipID],
	   ''				  as [addsZip],
	   null,null,
	   1,1, GETDATE(),null,null,null,null,null,'',
	   1,1,
	   368				  as [addnRecUserID], 
	   GETDATE()			  as [adddDtCreated],
	   null,null,'','',null,null,''
from sma_MST_IndvContacts I 
inner join
(
select 'unidentified' as first_name, 'plaintiff'  as last_name
    union
select 'unidentified' as first_name, 'defendant'  as last_name
) e on e.first_name=I.cinsFirstName and e.last_name=I.cinsLastName and saga='-1'

