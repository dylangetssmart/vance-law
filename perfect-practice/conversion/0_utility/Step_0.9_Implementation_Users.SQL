

use [SAPerfectPracticeEmroch]

---(0)---
if exists (select * from sys.objects where name='implementation_users' and type='U')
begin
    drop table implementation_users
end
GO
    create table implementation_users ( first_name varchar(100), last_name varchar(100) )    -- don't create these staffs again after running SQLDeleteRowsExecptUsersnFirmInfo.sql 
GO

insert into implementation_users ( first_name,last_name ) 
(
select I.cinsFirstName,I.cinsLastName
from [SAPerfectPracticeEmroch].[dbo].[sma_MST_Users] U	
inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts] I on I.cinnContactID=U.usrnContactID

	intersect

select E.firstname,E.lastname
From [PerfectPracticeEmroch].[dbo].[uusers] STF
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.entitynum=STF.entitynum
where E.firstname is not null
)




-----(1/2)---
--insert into implementation_users ( loginid, staff_code )
--select 
--	A.LoginID		as usrsLoginID, 
--	A.staff_code	as staff_code 
--from
--(
--	select 
--		F.staff_code, 
--		U.usrsLoginID	as LoginID, 
--		I.cinnContactID as ContactID
--	from sma_MST_Users U	
--	inner join sma_MST_IndvContacts I on I.cinnContactID=U.usrnContactID
--	inner join PerfectPracticeEmroch.dbo.staff F on F.first_name=I.cinsFirstName and F.last_name=I.cinsLastName
--) A

-----(2/2)---
--update sma_MST_IndvContacts set cinsGrade=A.staff_code
--from
--(
--	select 
--		F.staff_code, 
--		U.usrsLoginID	as LoginID, 
--		I.cinnContactID as ContactID
--	from sma_MST_Users U
--	inner join sma_MST_IndvContacts I on I.cinnContactID=U.usrnContactID
--	inner join PerfectPracticeEmroch.dbo.staff F on F.first_name=I.cinsFirstName and F.last_name=I.cinsLastName
--) A 
--where A.ContactID=cinnContactID


--if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_MST_Users'))
--begin
--    ALTER TABLE [sma_MST_Users] ADD [saga] [varchar](32) NULL; 
--end
--GO

--update sma_MST_Users set saga=A.staff_code
--from
--(
--	select 
--		F.staff_code, 
--		U.usrsLoginID	as LoginID, 
--		I.cinnContactID as ContactID
--	from sma_MST_Users U
--	inner join sma_MST_IndvContacts I on I.cinnContactID=U.usrnContactID
--	inner join PerfectPracticeEmroch.dbo.staff F on F.first_name=I.cinsFirstName and F.last_name=I.cinsLastName
--) A 
--where A.LoginID=usrsLoginID
