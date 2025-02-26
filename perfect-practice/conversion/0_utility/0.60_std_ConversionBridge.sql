



CREATE TABLE ConversionBridge ( 
		SARefTableID	int,				--SA Table Reference- ConversionBridgeTables.ID
		SARecordID		int,				--SA Identifier/PK
		SourceDB		varchar(100),		--source databasename, if client is coming from multiple databases
		SourceTable		varchar(255),		--source table
		SourceID_int	int,				--source identifier int
		SourceID_bigint	bigint,				--source identifier bigint
		SourceID_char	varchar(255),		--sourceIdentifier varchar
		SourceID_nchar	nvarchar(255),		--sourceIdentifier nvarchar
		Source_Ref		varchar(255),		--if additional reference needed
		Comment			nvarchar(max),
		DateCreated		datetime,
		DateModified	datetime
)
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_ConversionBridge_SARefTable ON ConversionBridge (SARefTableID);   
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_ConversionBridge_SARecordID ON ConversionBridge (SARecordID);   
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_ConversionBridge_SourceDB ON ConversionBridge (SourceDB); 
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_ConversionBridge_SourceTable ON ConversionBridge (SourceTable); 
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_ConversionBridge_SourceIDint ON ConversionBridge (SourceID_int); 
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_ConversionBridge_SourceIDbigint ON ConversionBridge (SourceID_bigint); 
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_ConversionBridge_SourceIDChar ON ConversionBridge (SourceID_char); 
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_ConversionBridge_SourceIDnChar ON ConversionBridge (SourceID_nchar); 
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_ConversionBridge_Source_Ref ON ConversionBridge (Source_Ref); 
GO




CREATE TABLE ConversionBridgeTables (
		[Id] [int] IDENTITY(1,1) NOT NULL,
		RefTable varchar(100) 
)

INSERT INTO ConversionBridgeTables (RefTable)
SELECT 'IndvContacts' 
UNION SELECT 'OrgContacts' 
UNION SELECT 'Users' 
UNION SELECT 'Cases' 
UNION SELECT 'Plaintiff' 
UNION SELECT 'Defendants' 
UNION SELECT 'Documents' 
UNION SELECT 'Notes' 
UNION SELECT 'InsuranceCoverage' 
UNION SELECT 'LawFirms' 
UNION SELECT 'PlaintiffAttorney' 
UNION SELECT 'Hospitals' 
UNION SELECT 'Visits' 
UNION SELECT 'spDamages' 
UNION SELECT 'MedicalProviderRequest' 
UNION SELECT 'Courts' 
UNION SELECT 'CourtDocket' 
UNION SELECT 'PoliceReports' 
UNION SELECT 'Investigations' 
UNION SELECT 'Disbursement' 
UNION SELECT 'Negotiations' 
UNION SELECT 'Settlements' 
UNION SELECT 'Lienors' 
UNION SELECT 'LienDetails' 
UNION SELECT 'LitigationDiscovery' 
UNION SELECT 'Injury' 
UNION SELECT 'TaskNew' 
UNION SELECT 'Employment' 
UNION SELECT 'CalendarAppointments' 
UNION SELECT 'CriticalDeadlines' 
UNION SELECT 'SOLs' 
UNION SELECT 'Emails' 
UNION SELECT 'Vehicles' 
UNION SELECT 'CaseWitness' 
UNION SELECT 'ExpertContacts' 
