
use PerfectPracticeEmroch

--(1)--
ALTER TABLE [entities] alter column [entitynum] varchar(10); 

--(2)--
CREATE CLUSTERED INDEX IX_entities_entitynum ON dbo.entities (entitynum);

--(3)--
DBCC DBREINDEX('entities',' ',80)  WITH NO_INFOMSGS 


