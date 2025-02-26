
use [SAPerfectPracticeEmroch]


INSERT INTO [sma_MST_IndvContacts]
([cinbPrimary],[cinnContactTypeID],[cinnContactSubCtgID],[cinsPrefix],[cinsFirstName],[cinsMiddleName],[cinsLastName],[cinsSuffix],[cinsNickName],[cinbStatus],[cinsSSNNo],[cindBirthDate],
[cinsComments],[cinnContactCtg],[cinnRefByCtgID],[cinnReferredBy],[cindDateOfDeath],[cinsCVLink],[cinnMaritalStatusID],[cinnGender],[cinsBirthPlace],[cinnCountyID],[cinsCountyOfResidence],
[cinbFlagForPhoto],[cinsPrimaryContactNo],[cinsHomePhone],[cinsWorkPhone],[cinsMobile],[cinbPreventMailing],[cinnRecUserID],[cindDtCreated],[cinnModifyUserID],[cindDtModified],[cinnLevelNo],
[cinsPrimaryLanguage],[cinsOtherLanguage],[cinbDeathFlag],[cinsCitizenship],[cinsHeight],[cinnWeight],[cinsReligion],[cindMarriageDate],[cinsMarriageLoc],[cinsDeathPlace],[cinsMaidenName],
[cinsOccupation],[saga]) 
   
SELECT 
	1				as [cinbPrimary],
	(select octnOrigContactTypeID FROM [SAPerfectPracticeEmroch].[dbo].[sma_MST_OriginalContactTypes] where octsDscrptn='Judge' and octnContactCtgID=1) as [cinnContactTypeID], --10
	null			as [cinnContactSubCtgID],
	''				as [cinsPrefix],
	E.firstname		as [cinsFirstName],
	null			as [cinsMiddleName],
	E.lastname		as [cinsLastName],
	null			as [cinsSuffix],
	null			as [cinsNickName],
	1				as [cinbStatus],
	''				as [cinsSSNNo],
	null			as [cindBirthDate],
	'default helper contact'		
					as [cinsComments],
	1,'','',null,'','',null,'',1,1,null,'','','','',0,368,GETDATE(),'',null,0,'','','','','','','',Null,'','','','',
	'Judge'+E.entitynum	
					as [saga]
from [PerfectPracticeEmroch].[dbo].[entities] E
where E.casemarker<>1		
and E.entityrole='COURT'
and E.firstname is not null
and E.lastname is not null

