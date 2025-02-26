
use [SAPerfectPracticeEmroch]

/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts] 
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts] enable trigger all

alter table [SAPerfectPracticeEmroch].[dbo].[sma_MST_users] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_MST_users] 
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_MST_users]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_MST_users] enable trigger all

alter table [SAPerfectPracticeEmroch].[dbo].[sma_MST_OrgContacts] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_MST_OrgContacts] 
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_MST_OrgContacts]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_MST_OrgContacts] enable trigger all
*/


---(0)--- saga field for needles names_id:
--ALTER TABLE [sma_MST_IndvContacts] ALTER COLUMN saga int;
--ALTER TABLE [sma_MST_OrgContacts] ALTER COLUMN saga int;
 
---(0)--- construct special contacts:
SET IDENTITY_INSERT [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts] ON 

if (select count(*) from Implementation_Users) = 0
begin

INSERT INTO [sma_MST_IndvContacts]
(cinncontactid,[cinbPrimary],[cinnContactTypeID],[cinnContactSubCtgID],[cinsPrefix],[cinsFirstName],[cinsMiddleName],[cinsLastName],[cinsSuffix],[cinsNickName],[cinbStatus],[cinsSSNNo],[cindBirthDate],
[cinsComments],[cinnContactCtg],[cinnRefByCtgID],[cinnReferredBy],[cindDateOfDeath],[cinsCVLink],[cinnMaritalStatusID],[cinnGender],[cinsBirthPlace],[cinnCountyID],[cinsCountyOfResidence],
[cinbFlagForPhoto],[cinsPrimaryContactNo],[cinsHomePhone],[cinsWorkPhone],[cinsMobile],[cinbPreventMailing],[cinnRecUserID],[cindDtCreated],[cinnModifyUserID],[cindDtModified],[cinnLevelNo],
[cinsPrimaryLanguage],[cinsOtherLanguage],[cinbDeathFlag],[cinsCitizenship],[cinsHeight],[cinnWeight],[cinsReligion],[cindMarriageDate],[cinsMarriageLoc],[cinsDeathPlace],[cinsMaidenName],
[cinsOccupation],[saga],[cinsSpouse],[cinsGrade]) 
   
SELECT distinct 8,1,10,null,'Mr.','Staff','','Unassigned',null,null,1,null,
null,null,1,'','',null,'','',1,'',1,1,null,null,'','',null,0,368,GETDATE(),'',null,0,'','','','',null+null,null,'',Null,'','','','',-1,'',null
union
SELECT distinct 9,1,10,null,'Mr.','Individual','','Unidentified',null,null,1,null,
null,null,1,'','',null,'','',1,'',1,1,null,null,'','',null,0,368,GETDATE(),'',null,0,'','','','',null+null,null,'',Null,'','','','',0,'',null
union
SELECT distinct 10,1,10,null,null,'Plaintiff','','Unidentified',null,null,1,null,
null,null,1,'','',null,'','',1,'',1,1,null,null,'','',null,0,368,GETDATE(),'',null,0,'','','','',null+null,null,'',Null,'','','','','','',null
union
SELECT distinct 11,1,10,null,null,'Defendant','','Unidentified',null,null,1,null,
null,null,1,'','',null,'','',1,'',1,1,null,null,'','',null,0,368,GETDATE(),'',null,0,'','','','',null+null,null,'',Null,'','','','','','',null
end

SET IDENTITY_INSERT [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts] OFF
 



---(1)--- Required Organization:

 insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_OrgContacts]
	(
		[consName],
		[consWorkPhone],
		[consComments],
		[connContactCtg],
		[connContactTypeID],	
		[connRecUserID],		
		[condDtCreated],
		[conbStatus],			
		[saga]					
	)
SELECT 
		case
			when E.[refname] is not null then E.[refname]
			when E.[refname] is null and E.[firstname] is not null then E.[firstname]
			else E.[entityid]
		end								as [consName],
		null							as [consWorkPhone],
		isnull('entityid:' + nullif(convert(varchar(MAX),E.entityid),'') + CHAR(13),'') +
		isnull('firstname:' + nullif(convert(varchar(MAX),E.firstname),'') + CHAR(13),'') +
		isnull('lastname:' + nullif(convert(varchar(MAX),E.lastname),'') + CHAR(13),'') +
		isnull('notes:' + nullif(convert(varchar(MAX),E.notes),'') + CHAR(13),'') +
		isnull('salutation:' + nullif(convert(varchar(MAX),E.salutation),'') + CHAR(13),'') +
		''								as [consComments],
		2								as [connContactCtg],
		(select octnOrigContactTypeID FROM [SAPerfectPracticeEmroch].[dbo].[sma_MST_OriginalContactTypes] where octsDscrptn='General' and octnContactCtgID=2) 
										as [connContactTypeID],
		368								as [connRecUserID],
		getdate()						as [condDtCreated],
		1								as [conbStatus],	-- Hardcode Status as ACTIVE
		E.[entitynum]					as [saga]			-- remember the [names].[names_id] number
from [PerfectPracticeEmroch].[dbo].[entities] E
where E.casemarker<>1			-->(0:general 1:case  2:users)
and E.entityrole in 
(
'COURT',
'INS_AUTO',			--1 %INS%
'INS_HEALTH',		--2 %INS%
'INS_LIABILITY',	--3 %INS%
-->'INS_LIMITS',	--4 %INS%
'INS_MALPRACTICE',	--5 %INS%
'INS_SUBRO',		--6 %INS%
'INS_WORKCOMP',		--7 %INS%
'INSURANCE'			--8 %INS%
)


---(1)--- construct sma_MST_IndvContacts:

insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts]
(
	[cinsPrefix],
	[cinsSuffix],
	[cinsFirstName],
	[cinsMiddleName],
	[cinsLastName],
	[cinsHomePhone],
	[cinsWorkPhone],
	[cinsSSNNo],
	[cindBirthDate],
	[cindDateOfDeath],
	[cinnGender],
	[cinsMobile],
	[cinsComments],
	[cinnContactCtg],
	[cinnContactTypeID],	
	[cinnContactSubCtgID],
	[cinnRecUserID],		
	[cindDtCreated],
	[cinbStatus],			
	[cinbPreventMailing],
	[cinsNickName],
	[cinsPrimaryLanguage],
     [cinsOtherLanguage],
	[saga]					
)
SELECT										 
		left(E.[salutation],20)					as [cinsPrefix],
		null									as [cinsSuffix],
		convert(varchar(30),E.[firstname])		as [cinsFirstName],
		convert(varchar(30),E.[middlename])		as [cinsMiddleName],
		convert(varchar(40),E.[lastname])		as [cinsLastName],
		null									as [cinsHomePhone],
		null									as [cinsWorkPhone],
		left(E.[ssn],20)						as [cinsSSNNo],
		null									as [cindBirthDate],
		null									as [cindDateOfDeath],
		case 
			when E.[gender]='M' then 1
			when E.[gender]='F' then 2
			else 0
		end										as [cinnGender],
		null									as [cinsMobile],
		isnull('entityid:' + nullif(convert(varchar(MAX),E.entityid),'') + CHAR(13),'') +
		isnull('notes:' + nullif(convert(varchar(MAX),E.notes),'') + CHAR(13),'') +
		''										as [cinsComments],
		1										as [cinnContactCtg],
		(select octnOrigContactTypeID FROM [SAPerfectPracticeEmroch].[dbo].[sma_MST_OriginalContactTypes] where octsDscrptn='General' and octnContactCtgID=1) 
												as [cinnContactTypeID],
		null									as cinnContactSubCtgID,
		368										as cinnRecUserID,
		getdate()								as cindDtCreated,
		1										as [cinbStatus],			-- Hardcode Status as ACTIVE 
		0		 								as [cinbPreventMailing], 
		convert(varchar(15),E.refname)			as [cinsNickName],
		null									as [cinsPrimaryLanguage],
		null									as [cinsOtherLanguage],
		E.entitynum								as saga  
from [PerfectPracticeEmroch].[dbo].[entities] E
where E.casemarker<>1		--> (0:general 1:case  2:users)
and E.lastname is not null	--> Indvidual
and E.entitynum not in ( select saga from [SAPerfectPracticeEmroch].[dbo].[sma_MST_OrgContacts] where saga is not null)

---(2)--- construct sma_MST_OrgContacts:

insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_OrgContacts]
	(
		[consName],
		[consWorkPhone],
		[consComments],
		[connContactCtg],
		[connContactTypeID],	
		[connRecUserID],		
		[condDtCreated],
		[conbStatus],			
		[saga]					
	)
SELECT 
		case
			when E.[refname] is not null then E.[refname]
			when E.[refname] is null and E.[firstname] is not null then E.[firstname]
			else E.[entityid]
		end								as [consName],
		null							as [consWorkPhone],
		isnull('entityid:' + nullif(convert(varchar(MAX),E.entityid),'') + CHAR(13),'') +
		isnull('firstname:' + nullif(convert(varchar(MAX),E.firstname),'') + CHAR(13),'') +
		isnull('lastname:' + nullif(convert(varchar(MAX),E.lastname),'') + CHAR(13),'') +
		isnull('notes:' + nullif(convert(varchar(MAX),E.notes),'') + CHAR(13),'') +
		isnull('salutation:' + nullif(convert(varchar(MAX),E.salutation),'') + CHAR(13),'') +
		''								as [consComments],
		2								as [connContactCtg],
		(select octnOrigContactTypeID FROM [SAPerfectPracticeEmroch].[dbo].[sma_MST_OriginalContactTypes] where octsDscrptn='General' and octnContactCtgID=2) 
										as [connContactTypeID],
		368								as [connRecUserID],
		getdate()						as [condDtCreated],
		1								as [conbStatus],	-- Hardcode Status as ACTIVE
		E.[entitynum]					as [saga]			-- remember the [names].[names_id] number
from [PerfectPracticeEmroch].[dbo].[entities] E
where E.casemarker<>1		--> (0:general 1:case  2:users)
and E.lastname is null		--> Indvidual
and E.entitynum not in ( select saga from [SAPerfectPracticeEmroch].[dbo].[sma_MST_OrgContacts] where saga is not null)


---(3.2)--- construct sma_MST_Users:

SET IDENTITY_INSERT sma_mst_users ON

if (select count(*) from Implementation_Users) = 0
begin

INSERT INTO [SAPerfectPracticeEmroch].[dbo].[sma_MST_Users]
(usrnuserid,[usrnContactID],[usrsLoginID],[usrsPassword],[usrsBackColor],[usrsReadBackColor],[usrsEvenBackColor],[usrsOddBackColor],[usrnRoleID],[usrdLoginDate],[usrdLogOffDate],[usrnUserLevel],[usrsWorkstation],[usrnPortno],[usrbLoggedIn],
[usrbCaseLevelRights],[usrbCaseLevelFilters],[usrnUnsuccesfulLoginCount],[usrnRecUserID],[usrdDtCreated],[usrnModifyUserID],[usrdDtModified],[usrnLevelNo],[usrsCaseCloseColor],[usrnDocAssembly],[usrnAdmin],[usrnIsLocked])     
Select distinct 368,8,'aadmin','2/',null,null,null,null,33,null,null,null,null,null,null,null,null,null,1,GETDATE(),null,null,null,null,null,null,null
end

SET IDENTITY_INSERT sma_mst_users OFF


if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_MST_Users'))
begin
    ALTER TABLE [sma_MST_Users] ADD [saga] [varchar](32) NULL; 
end
GO

INSERT INTO [SAPerfectPracticeEmroch].[dbo].[sma_MST_Users]
([usrnContactID],[usrsLoginID],[usrsPassword],[usrsBackColor],[usrsReadBackColor],[usrsEvenBackColor],[usrsOddBackColor],[usrnRoleID],[usrdLoginDate],[usrdLogOffDate],[usrnUserLevel],[usrsWorkstation],[usrnPortno],[usrbLoggedIn],
[usrbCaseLevelRights],[usrbCaseLevelFilters],[usrnUnsuccesfulLoginCount],[usrnRecUserID],[usrdDtCreated],[usrnModifyUserID],[usrdDtModified],[usrnLevelNo],[usrsCaseCloseColor],[usrnDocAssembly],[usrnAdmin],[usrnIsLocked],[saga])     

select
	cinncontactid, convert(varchar(20),STF.userid),'#',null,null,null,null,
	case
		when E.title like '%Attorney%' then (select sbrnSubRoleId from sma_MST_SubRole where sbrnRoleID=10 and sbrsDscrptn='Attorney')
		when E.title like 'Paralegal' then (select sbrnSubRoleId from sma_MST_SubRole where sbrnRoleID=10 and sbrsDscrptn='Paralegal')
		else (select sbrnSubRoleId from sma_MST_SubRole where sbrnRoleID=10 and sbrsDscrptn='Staff')
	end as usrnRoleID,
null,null,null,null,null,null,null,null,null,1,GETDATE(),null,null,null,null,null,null,null,convert(varchar(20),STF.userid)
From [PerfectPracticeEmroch].[dbo].[uusers] STF
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.entitynum=STF.entitynum
inner join [SAPerfectPracticeEmroch].[dbo].sma_MST_IndvContacts I on I.saga = STF.entitynum
where not exists ( select * from implementation_users where first_name=E.firstname and last_name=E.lastname )
and STF.userid not in ( 'cseverin' ,'cunger','emcnelis','pfones','whanson','wmarstiller')


---(3.3)---

Declare @UserID int

DECLARE staff_cursor CURSOR FAST_FORWARD FOR SELECT usrnuserid from sma_mst_users

OPEN staff_cursor 

FETCH NEXT FROM staff_cursor INTO @UserID

SET NOCOUNT ON;
WHILE @@FETCH_STATUS = 0
BEGIN

insert into sma_TRN_CaseBrowseSettings (cbsnColumnID,cbsnUserID,cbssCaption,cbsbVisible,cbsnWidth,cbsnOrder,cbsnRecUserID,cbsdDtCreated,cbsn_StyleName)
 SELECT distinct cbcnColumnID,@UserID,cbcscolumnname,'True',200,cbcnDefaultOrder,@UserID,GETDATE(),'Office2007Blue' FROM [sma_MST_CaseBrowseColumns]
 where cbcnColumnID not in (1,18,19,20,21,22,23,24,25,26,27,28,29,30,33)

FETCH NEXT FROM staff_cursor INTO  @UserID
END

CLOSE staff_cursor 
DEALLOCATE staff_cursor



---- Appendix ----
insert into Account_UsersInRoles ( user_id,role_id)
select usrnUserID as user_id,2 as role_id from sma_MST_Users 
update Account_UsersInRoles set role_id=1 where user_id=368 

update sma_MST_Users set usrbActiveState=1
where usrsLoginID='aadmin'


---- Appendix ----
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_MST_Users'))
begin
    ALTER TABLE [sma_MST_Users] ADD [saga] [varchar](32) NULL; 
end
GO
update sma_MST_Users set saga=A.staff_code
from 
(
select 
	STF.userid		as staff_code,
	U.usrsLoginID	as LoginID
From [PerfectPracticeEmroch].[dbo].[uusers] STF
inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts] I on I.saga = STF.entitynum
inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Users] U on U.usrnContactID=I.cinnContactID
) A where A.LoginID=usrsLoginID


---- Appendix (live )----
--(1)--
update sma_MST_users set saga=usrsLoginID
where saga is null


--(2)--
update sma_MST_IndvContacts set saga=A.entitynum
from
(
select 
	I.cinnContactID as ID,
	STF.entitynum
from [SAPerfectPracticeEmroch].[dbo].[sma_MST_Users] U 
inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts] I on I.cinnContactID = U.usrnContactID
inner join [PerfectPracticeEmroch].[dbo].[uusers] STF on STF.userid = U.usrsLoginID
where I.saga is null
) A
where cinnContactID=A.ID




