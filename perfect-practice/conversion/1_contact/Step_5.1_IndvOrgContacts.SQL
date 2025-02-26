

use SAPerfectPracticeEmroch
GO

if exists (select * from sys.objects where name='IndvOrgContacts_Indexed' and type='U')
begin
    drop table IndvOrgContacts_Indexed
end
GO

create table IndvOrgContacts_Indexed
(
    TableIndex [int] IDENTITY(1,1) NOT NULL,
    CID int,
    CTG int,
    AID int,
    UNQCID bigint,
    Name varchar(100),
    SAGA varchar(100),
    CONSTRAINT IOC_Clustered_Index PRIMARY KEY CLUSTERED ( TableIndex )
) 
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_IndvOrgContacts_Indexed_CID ON IndvOrgContacts_Indexed (CID);   
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_IndvOrgContacts_Indexed_CTG ON IndvOrgContacts_Indexed (CTG);   
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_IndvOrgContacts_Indexed_AID ON IndvOrgContacts_Indexed (AID); 
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_IndvOrgContacts_Indexed_UNID ON IndvOrgContacts_Indexed (UNQCID); 
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_IndvOrgContacts_Indexed_SAGA ON IndvOrgContacts_Indexed (SAGA); 
GO

insert into IndvOrgContacts_Indexed 
(   CID,CTG,AID,UNQCID,Name,SAGA )
select 
    IOC.CID		    as CID,
    IOC.CTG		    as CTG,	
    A.addnAddressID	    as AID,
    ACF.UniqueContactId as UNQCID,
    IOC.Name		    as Name,
    IOC.SAGA		    as SAGA 
from
(
	select cinnContactID as CID, cinnContactCtg as CTG, cinsFirstName + ' ' + cinsLastName as Name, saga as SAGA from [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts]  
	union
	select connContactID as CID, connContactCtg as CTG, consName as Name, saga as SAGA from [SAPerfectPracticeEmroch].[dbo].[sma_MST_OrgContacts]  
) IOC
inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Address] A on A.addnContactID=IOC.CID and A.addnContactCtgID=IOC.CTG and A.addbPrimary=1
inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_AllContactInfo] ACF on ACF.ContactId=IOC.CID and ACF.ContactCtg=IOC.CTG
GO

DBCC DBREINDEX('IndvOrgContacts_Indexed',' ',90) WITH NO_INFOMSGS 
GO
DBCC DBREINDEX('sma_MST_IndvContacts',' ',90) WITH NO_INFOMSGS 
GO
DBCC DBREINDEX('sma_MST_OrgContacts',' ',90) WITH NO_INFOMSGS 
GO


