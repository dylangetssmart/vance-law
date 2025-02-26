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

USE [SA]
GO
/*
alter table [sma_TRN_PoliceReports] disable trigger all
delete from [sma_TRN_PoliceReports]
DBCC CHECKIDENT ('[sma_TRN_PoliceReports]', RESEED, 0);
alter table [sma_TRN_PoliceReports] enable trigger all

*/

---
ALTER TABLE [sma_TRN_PoliceReports] DISABLE TRIGGER ALL
GO
---

---(0)---
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE [name] = 'Officer_Helper'
			AND type = 'U'
	)
BEGIN
	DROP TABLE Officer_Helper
END
GO

CREATE TABLE Officer_Helper (
	OfficerCID INT
   ,OfficerCTG INT
   ,OfficerAID INT
   ,cinsGrade VARCHAR(400)
)
GO
----
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_Officer_Helper ON [Officer_Helper] (cinsGrade);
----
GO
---(0)---
INSERT INTO Officer_Helper
	(
	OfficerCID, OfficerCTG, OfficerAID, cinsGrade
	)
	SELECT DISTINCT
		I.cinnContactID	 AS OfficerCID
	   ,I.cinnContactCtg AS OfficerCTG
	   ,A.addnAddressID	 AS OfficerAID
	   ,I.cinsGrade
	FROM TestNeedles.[dbo].[police] P
	JOIN [sma_MST_IndvContacts] I
		ON I.cinsGrade = P.officer
			AND I.cinsPrefix = 'Officer'
	JOIN [sma_MST_Address] A
		ON A.addnContactID = I.cinnContactID
			AND A.addnContactCtgID = I.cinnContactCtg
			AND A.addbPrimary = 1

GO

DBCC DBREINDEX ('Officer_Helper', ' ', 90) WITH NO_INFOMSGS


---(0)---
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE name = 'Police_Helper'
			AND type = 'U'
	)
BEGIN
	DROP TABLE Police_Helper
END
GO

CREATE TABLE Police_Helper (
	PoliceCID INT
   ,PoliceCTG INT
   ,PoliceAID INT
   ,police_id INT
   ,case_num INT
   ,casnCaseID INT
   ,officerCID INT
   ,officerAID INT
)
GO
----
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_Police_Helper ON [Police_Helper] (police_id);
----
GO

INSERT INTO Police_Helper
	(
	PoliceCID, PoliceCTG, PoliceAID, police_id, case_num, casnCaseID, officerCID, officerAID
	)
	SELECT
		IOC.CID		   AS PoliceCID
	   ,IOC.CTG		   AS PoliceCTG
	   ,IOC.AID		   AS PoliceAID
	   ,P.police_id	   AS police_id
	   ,P.case_num
	   ,CAS.casnCaseID AS casnCaseID
	   ,(
			SELECT
				H.OfficerCID
			FROM Officer_Helper H
			WHERE H.cinsGrade = P.officer
		)			   
		AS officerCID
	   ,(
			SELECT
				H.OfficerAID
			FROM Officer_Helper H
			WHERE H.cinsGrade = P.officer
		)			   
		AS officerAID
	FROM TestNeedles.[dbo].[police] P
	JOIN [sma_TRN_cases] CAS
		ON CAS.cassCaseNumber = P.case_num
	JOIN [IndvOrgContacts_Indexed] IOC
		ON IOC.SAGA = P.police_id
GO

DBCC DBREINDEX ('Police_Helper', ' ', 90) WITH NO_INFOMSGS
GO


---(2)---
INSERT INTO [sma_TRN_PoliceReports]
	(
	[pornCaseID], [pornPoliceID], [pornPoliceAdID], [porsReportNo], [porsComments], [pornPOContactID], [pornPOCtgID], [pornPOAddressID]
	)

	SELECT
		MAP.casnCaseID		   AS pornCaseID
	   ,MAP.officerCID		   AS pornPoliceID
	   ,MAP.officerAID		   AS pornPoliceAdID
	   ,LEFT(P.report_num, 30) AS porsReportNo
	   ,ISNULL('Badge:' + NULLIF(P.badge, '') + CHAR(13), '')
		AS porsComments
	   ,MAP.PoliceCID		   AS [pornPOContactID]
	   ,MAP.PoliceCTG		   AS [pornPOCtgID]
	   ,MAP.PoliceAID		   AS [pornPOAddressID]
	FROM TestNeedles.[dbo].[police] P
	JOIN Police_Helper MAP
		ON MAP.police_id = P.police_id
			AND MAP.case_num = P.case_num
GO

---
ALTER TABLE [sma_TRN_PoliceReports] ENABLE TRIGGER ALL
GO
---


