/* ######################################################################################
description:

steps:
	-

usage_instructions:
	-

dependencies:
	- 

notes:
	-

######################################################################################
*/

use [SA]
go
/*
update sma_MST_IndvContacts set cinsComments = NULL

*/
---
ALTER TABLE sma_MST_IndvContacts DISABLE TRIGGER ALL
GO
---

----(1)----
UPDATE sma_MST_IndvContacts SET cinsComments = isnull(cinsComments,'') + CHAR(13) + 'Age : ' + convert(varchar,A.Age)
FROM
(
SELECT 
    P.case_id											   as CaseID, 
    P.party_id											   as PartyID,
    DATEPART(yyyy,getdate()) - DATEPART(yyyy,N.date_of_birth) - 1   as Age

FROM TestNeedles.[dbo].[party_Indexed] P 
JOIN TestNeedles.[dbo].[names] N on N.names_id=P.party_id
WHERE N.date_of_birth is not null
) A
WHERE A.PartyID=saga 


----(2)----
UPDATE sma_MST_IndvContacts SET cinsComments = isnull(cinsComments,'') + CHAR(13) + 'Age at DOI : ' + convert(varchar,A.DOI)
FROM
(
SELECT 
    P.case_id											   as CaseID, 
    P.party_id											   as PartyID,
    DATEPART(yyyy,C.date_of_incident) - DATEPART(yyyy,N.date_of_birth) - 1   as DOI
FROM TestNeedles.[dbo].[party_Indexed] P 
JOIN TestNeedles.[dbo].[names] N on N.names_id=P.party_id
JOIN TestNeedles.[dbo].[cases] C on C.casenum=P.case_id
WHERE C.date_of_incident is not null 
and N.date_of_birth is not null
) A
WHERE A.PartyID=saga 


----(3)----
UPDATE sma_MST_IndvContacts SET cinsComments = isnull(cinsComments,'') + CHAR(13) + 'Deceased : ' + convert(varchar,A.Deceased)
FROM
(
SELECT 
    P.case_id											   as CaseID, 
    P.party_id											   as PartyID,
    N.Deceased											   as Deceased
FROM TestNeedles.[dbo].[party_Indexed] P 
JOIN TestNeedles.[dbo].[names] N on N.names_id=P.party_id
WHERE N.Deceased is not null
) A
WHERE A.PartyID=saga 


----(4)----
UPDATE sma_MST_IndvContacts SET cinsComments = isnull(cinsComments,'') + CHAR(13) + 'Date of Death : ' + convert(varchar,A.DOD)
FROM
(
SELECT 
    P.case_id											   as CaseID, 
    P.party_id											   as PartyID,
    DATEPART(yyyy,N.date_of_death)							   as DOD
FROM TestNeedles.[dbo].[party_Indexed] P 
JOIN TestNeedles.[dbo].[names] N on N.names_id=P.party_id
WHERE N.date_of_death is not null
) A
WHERE A.PartyID=saga 



----(5)----
UPDATE sma_MST_IndvContacts SET cinsComments = isnull(cinsComments,'') + CHAR(13) + 'Incapacitated : ' + convert(varchar,A.incapacitated)
FROM
(
SELECT 
    P.case_id											   as CaseID, 
    P.party_id											   as PartyID,
    P.incapacitated										   as incapacitated
FROM TestNeedles.[dbo].[party_Indexed] P 
JOIN TestNeedles.[dbo].[names] N on N.names_id=P.party_id
WHERE isnull(incapacitated,'')<>''
) A
WHERE A.PartyID=saga 


----(5)----
UPDATE sma_MST_IndvContacts SET cinsComments = isnull(cinsComments,'') + CHAR(13) + 'Incapacity : ' + convert(varchar,A.Incapacity)
FROM
(
SELECT 
    P.case_id											   as CaseID, 
    P.party_id											   as PartyID,
    P.incapacity										   as Incapacity
FROM TestNeedles.[dbo].[party_Indexed] P 
JOIN TestNeedles.[dbo].[names] N on N.names_id=P.party_id
WHERE isnull(incapacity,'')<>''
) A
WHERE A.PartyID=saga 



----(6)----
UPDATE sma_MST_IndvContacts SET cinsComments = isnull(cinsComments,'') + CHAR(13) + 'Responsible for another party : ' + convert(varchar,A.Responsibility)
FROM
(
SELECT 
    P.case_id											   as CaseID, 
    P.party_id											   as PartyID,
    P.responsibility									   as Responsibility
FROM TestNeedles.[dbo].[party_Indexed] P 
JOIN TestNeedles.[dbo].[names] N on N.names_id=P.party_id
WHERE isnull(P.responsibility,'')<>''
) A
WHERE A.PartyID=saga 


---
ALTER TABLE sma_MST_IndvContacts ENABLE TRIGGER ALL
GO
---
