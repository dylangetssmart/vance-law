/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create users and contacts

replace:
'OfficeName'
'StateDescription'
'VenderCaseType'
##########################################################################################################################
*/

use [JoelBieberSA_Needles]
go
/*
alter table [sma_TRN_CriticalDeadlines] disable trigger all
delete [sma_TRN_CriticalDeadlines]
DBCC CHECKIDENT ('[sma_TRN_CriticalDeadlines]', RESEED, 0);
alter table [sma_TRN_CriticalDeadlines] enable trigger all


(select cdtnCriticalTypeID FROM [sma_MST_CriticalDeadlineTypes] where cdtbActive = 1 and cdtsDscrptn='date due') 
*/


/*
Function to strip white spaces surrounding case_dates
*/
IF OBJECT_ID (N'dbo.GMACaseDate', N'FN') IS NOT NULL
    DROP FUNCTION GMACaseDate;
GO
CREATE FUNCTION dbo.GMACaseDate(@str varchar(MAX) )
RETURNS varchar(MAX) 
AS 
BEGIN
    --set @str=replace(@str,'1.','');
    --set @str=replace(@str,'2.','');
    --set @str=replace(@str,'3.','');
    --set @str=replace(@str,'4.','');
    --set @str=replace(@str,'5.','');
    --set @str=replace(@str,'6.','');
    --set @str=replace(@str,'7.','');
    --set @str=replace(@str,'8.','');
    --set @str=replace(@str,'9.','');
    RETURN rtrim(ltrim(@str));
END;
GO

/* CRITICAL DEADLINE TYPES ##################################
Insert new Critical Deadline Types that don't yet exist
from matter.case_date_1 through case_date_10
*/

-- Disable triggers
ALTER TABLE [sma_TRN_CriticalDeadlines] DISABLE TRIGGER ALL
---

insert into [sma_MST_CriticalDeadlineTypes] (
	cdtsDscrptn
	,cdtbActive
	) (
	select distinct dbo.GMACaseDate(M.case_date_1)
	,1 from JoelBieberNeedles.[dbo].[Matter] M where isnull(dbo.GMACaseDate(M.case_date_1), '') <> ''

union
	
	select distinct dbo.GMACaseDate(M.case_date_2)
	,1 from JoelBieberNeedles.[dbo].[Matter] M where isnull(dbo.GMACaseDate(M.case_date_2), '') <> ''

union
	
	select distinct dbo.GMACaseDate(M.case_date_3)
	,1 from JoelBieberNeedles.[dbo].[Matter] M where isnull(dbo.GMACaseDate(M.case_date_3), '') <> ''

union
	
	select distinct dbo.GMACaseDate(M.case_date_4)
	,1 from JoelBieberNeedles.[dbo].[Matter] M where isnull(dbo.GMACaseDate(M.case_date_4), '') <> ''

union
	
	select distinct dbo.GMACaseDate(M.case_date_5)
	,1 from JoelBieberNeedles.[dbo].[Matter] M where isnull(dbo.GMACaseDate(M.case_date_5), '') <> ''

union
	
	select distinct dbo.GMACaseDate(M.case_date_6)
	,1 from JoelBieberNeedles.[dbo].[Matter] M where isnull(dbo.GMACaseDate(M.case_date_6), '') <> ''

union
	
	select distinct dbo.GMACaseDate(M.case_date_7)
	,1 from JoelBieberNeedles.[dbo].[Matter] M where isnull(dbo.GMACaseDate(M.case_date_7), '') <> ''

union
	
	select distinct dbo.GMACaseDate(M.case_date_8)
	,1 from JoelBieberNeedles.[dbo].[Matter] M where isnull(dbo.GMACaseDate(M.case_date_8), '') <> ''

union
	
	select distinct dbo.GMACaseDate(M.case_date_9)
	,1 from JoelBieberNeedles.[dbo].[Matter] M where isnull(dbo.GMACaseDate(M.case_date_9), '') <> ''
)

except

select cdtsDscrptn
	,cdtbActive
from [sma_MST_CriticalDeadlineTypes]
where cdtbActive = 1


/*
Create a helper table
*/
IF EXISTS (select * from sys.objects where name='criticalDeadline_Helper' and type='U')
BEGIN
	DROP TABLE criticalDeadline_Helper
END 
GO

CREATE TABLE criticalDeadline_Helper (
    TableIndex	int IDENTITY(1,1) NOT NULL,
    casnCaseID	int,
    UniqueContactId bigint
CONSTRAINT IOC_Clustered_Index_criticalDeadline_Helper PRIMARY KEY CLUSTERED ( TableIndex )
) ON [PRIMARY] 
GO

INSERT INTO criticalDeadline_Helper (
	casnCaseID
	,UniqueContactId
	)
SELECT plnnCaseID, UniqueContactId
from sma_TRN_Plaintiff 
JOIN sma_MST_AllContactInfo
	on ContactCtg=plnnContactCtg
		and ContactId=plnnContactID
WHERE plnbIsPrimary=1
GO

DBCC DBREINDEX('criticalDeadline_Helper',' ',90)  WITH NO_INFOMSGS 
GO

/*
Create Critical Deadline records
Loop through case_date_1 to case_date_10
*/

DECLARE @i INT = 1
DECLARE @sql NVARCHAR(MAX)
DECLARE @caseDate NVARCHAR(20)

WHILE @i <= 9
BEGIN
    SET @caseDate = 'case_date_' + CAST(@i AS NVARCHAR(2))
    
    SET @sql = '
    INSERT INTO [sma_TRN_CriticalDeadlines] (
        [crdnCaseID]
        ,[crdnCriticalDeadlineTypeID]
        ,[crddDueDate]
        ,[crdsRequestFrom]
        ,[ResponderUID]
    )
    SELECT 
        CAS.casnCaseID as [crdnCaseID]
        ,(
            SELECT cdtnCriticalTypeID
            FROM [sma_MST_CriticalDeadlineTypes]
            WHERE cdtbActive = 1
                AND cdtsDscrptn = dbo.GMACaseDate(M.' + @caseDate + ')
        ) as [crdnCriticalDeadlineTypeID]
        ,CASE 
            WHEN C.' + @caseDate + ' BETWEEN ''1900-01-01'' AND ''2079-06-01''
                THEN C.' + @caseDate + '
            ELSE NULL
        END as [crddDueDate]
        ,(
            SELECT CONVERT(VARCHAR, MAP.UniqueContactId) + '';''
            FROM criticalDeadline_Helper MAP
            WHERE MAP.casnCaseID = CAS.casnCaseID
        ) as [crdsRequestFrom]
        ,(
            SELECT CONVERT(VARCHAR, MAP.UniqueContactId)
            FROM criticalDeadline_Helper MAP
            WHERE MAP.casnCaseID = CAS.casnCaseID
        ) as [ResponderUID]
    FROM JoelBieberNeedles.[dbo].[cases] C
    JOIN JoelBieberNeedles.[dbo].[matter] M
        ON M.matcode = C.matcode
    JOIN [sma_TRN_cases] CAS
        ON CAS.cassCaseNumber = casenum
    WHERE ISNULL(C.' + @caseDate + ', '''') <> ''''
    '
    
    EXEC sp_executesql @sql
    
    SET @i = @i + 1
END

-----
ALTER TABLE [sma_TRN_CriticalDeadlines] ENABLE TRIGGER ALL
GO
-----

---(Appendix)---
ALTER TABLE sma_TRN_CriticalDeadlines DISABLE TRIGGER ALL
GO

UPDATE [sma_TRN_CriticalDeadlines] 
SET crddCompliedDate=getdate()
WHERE crddDueDate < getdate()
GO

ALTER TABLE sma_TRN_CriticalDeadlines ENABLE TRIGGER ALL
GO