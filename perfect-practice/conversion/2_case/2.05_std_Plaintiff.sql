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

IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga_party'
			AND object_id = OBJECT_ID(N'sma_TRN_Plaintiff')
	)
BEGIN
	ALTER TABLE [sma_TRN_Plaintiff] ADD [saga_party] INT NULL;
END


ALTER TABLE [sma_TRN_Plaintiff] DISABLE TRIGGER ALL
GO


-------------------------------------------------------------------------------
-- Construct sma_TRN_Plaintiff ################################################
-- 
-------------------------------------------------------------------------------

INSERT INTO [sma_TRN_Plaintiff]
	(
	[plnnCaseID], [plnnContactCtg], [plnnContactID], [plnnAddressID], [plnnRole], [plnbIsPrimary], [plnbWCOut], [plnnPartiallySettled], [plnbSettled], [plnbOut], [plnbSubOut], [plnnSeatBeltUsed], [plnnCaseValueID], [plnnCaseValueFrom], [plnnCaseValueTo], [plnnPriority], [plnnDisbursmentWt], [plnbDocAttached], [plndFromDt], [plndToDt], [plnnRecUserID], [plndDtCreated], [plnnModifyUserID], [plndDtModified], [plnnLevelNo], [plnsMarked], [saga], [plnnNoInj], [plnnMissing], [plnnLIPBatchNo], [plnnPlaintiffRole], [plnnPlaintiffGroup], [plnnPrimaryContact], [saga_party]
	)
	SELECT
		CAS.casnCaseID  AS [plnnCaseID]
	   ,CIO.CTG			AS [plnnContactCtg]
	   ,CIO.CID			AS [plnnContactID]
	   ,CIO.AID			AS [plnnAddressID]
	   ,S.sbrnSubRoleId AS [plnnRole]
	   ,1				AS [plnbIsPrimary]
	   ,0
	   ,0
	   ,0
	   ,0
	   ,0
	   ,0
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,GETDATE()
	   ,NULL
	   ,368				AS [plnnRecUserID]
	   ,GETDATE()		AS [plndDtCreated]
	   ,NULL
	   ,NULL
	   ,NULL			AS [plnnLevelNo]
	   ,NULL
	   ,''
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,1				AS [plnnPrimaryContact]
	   ,P.TableIndex	AS [saga_party]
	--SELECT cas.casncaseid, p.role, p.party_ID, pr.[needles roles], pr.[sa roles], pr.[sa party], s.*
	FROM Needles.[dbo].[party_indexed] P
	JOIN [sma_TRN_Cases] CAS
		ON CAS.cassCaseNumber = P.case_id
	JOIN IndvOrgContacts_Indexed CIO
		ON CIO.SAGA = P.party_id
	JOIN [PartyRoles] pr
		ON pr.[Needles Roles] = p.[role]
	JOIN [sma_MST_SubRole] S
		ON CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID
			AND s.sbrsDscrptn = [sa roles]
			AND S.sbrnRoleID = 4
	WHERE pr.[sa party] = 'Plaintiff'
GO


/*
select * from [sma_MST_SubRole]
---( Now. do special role assignment )
DECLARE @needles_role varchar(100);
DECLARE @sa_role varchar(100);
DECLARE role_cursor CURSOR FOR 
SELECT [Needles Roles],[SA Roles] FROM [SA].[dbo].[PartyRoles] where [SA Party]='Plaintiff'
 
OPEN role_cursor 
FETCH NEXT FROM role_cursor INTO @needles_role,@sa_role
WHILE @@FETCH_STATUS = 0
BEGIN

    update [SA].[dbo].[sma_TRN_Plaintiff] set plnnRole=S.sbrnSubRoleId
    from TestNeedles.[dbo].[party_indexed] P 
    inner join [SA].[dbo].[sma_TRN_Cases] CAS on CAS.cassCaseNumber = P.case_id  
    inner join [SA].[dbo].[sma_MST_SubRole] S on CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID and S.sbrnRoleID=4 and S.sbrsDscrptn=@sa_role
    inner join IndvOrgContacts_Indexed CIO on CIO.SAGA = P.party_id
    where P.role=@needles_role
    and P.TableIndex=saga_party 

FETCH NEXT FROM role_cursor INTO @needles_role,@sa_role
END 
CLOSE role_cursor;
DEALLOCATE role_cursor;


GO
*/





/*
from TestNeedles.[dbo].[party_indexed] P 
inner join [SA].[dbo].[sma_TRN_Cases] C on C.cassCaseNumber = P.case_id  
inner join [SA].[dbo].[sma_MST_SubRole] S on C.casnOrgCaseTypeID = S.sbrnCaseTypeID
inner join IndvOrgContacts_Indexed ACIO on ACIO.SAGA = P.party_id
where S.sbrnRoleID=5 and S.sbrsDscrptn='(D)-Default Role'
and P.role in (SELECT [Needles Roles] FROM [SA].[dbo].[PartyRoles] where [SA Party]='Defendant')
GO

---( Now. do special role assignment )
DECLARE @needles_role varchar(100);
DECLARE @sa_role varchar(100);
DECLARE role_cursor CURSOR FOR 
SELECT [Needles Roles],[SA Roles] FROM [SA].[dbo].[PartyRoles] where [SA Party]='Defendant'
 
OPEN role_cursor 
FETCH NEXT FROM role_cursor INTO @needles_role,@sa_role
WHILE @@FETCH_STATUS = 0
BEGIN


    update [SA].[dbo].[sma_TRN_Defendants] set defnSubRole=S.sbrnSubRoleId
    from TestNeedles.[dbo].[party_indexed] P 
    inner join [SA].[dbo].[sma_TRN_Cases] C on C.cassCaseNumber = P.case_id  
    inner join [SA].[dbo].[sma_MST_SubRole] S on C.casnOrgCaseTypeID = S.sbrnCaseTypeID and S.sbrnRoleID=5 and S.sbrsDscrptn=@sa_role
    inner join IndvOrgContacts_Indexed ACIO on ACIO.SAGA = P.party_id
    where P.role=@needles_role
    and P.TableIndex=saga_party 

FETCH NEXT FROM role_cursor INTO @needles_role,@sa_role
END 
CLOSE role_cursor;
DEALLOCATE role_cursor;
GO
*/


/*
-------------------------------------------------------------------------------
##############################################################################
-------------------------------------------------------------------------------
---(Appendix A)-- every case need at least one plaintiff
*/

INSERT INTO [sma_TRN_Plaintiff]
	(
	[plnnCaseID], [plnnContactCtg], [plnnContactID], [plnnAddressID], [plnnRole], [plnbIsPrimary], [plnbWCOut], [plnnPartiallySettled], [plnbSettled], [plnbOut], [plnbSubOut], [plnnSeatBeltUsed], [plnnCaseValueID], [plnnCaseValueFrom], [plnnCaseValueTo], [plnnPriority], [plnnDisbursmentWt], [plnbDocAttached], [plndFromDt], [plndToDt], [plnnRecUserID], [plndDtCreated], [plnnModifyUserID], [plndDtModified], [plnnLevelNo], [plnsMarked], [saga], [plnnNoInj], [plnnMissing], [plnnLIPBatchNo], [plnnPlaintiffRole], [plnnPlaintiffGroup], [plnnPrimaryContact]
	)
	SELECT
		casnCaseID AS [plnnCaseID]
	   ,1		   AS [plnnContactCtg]
	   ,(
			SELECT
				cinncontactid
			FROM sma_MST_IndvContacts
			WHERE cinsFirstName = 'Plaintiff'
				AND cinsLastName = 'Unidentified'
		)		   
		AS [plnnContactID]
	   ,-- Unidentified Plaintiff
		NULL	   AS [plnnAddressID]
	   ,(
			SELECT
				sbrnSubRoleId
			FROM sma_MST_SubRole S
			INNER JOIN sma_MST_SubRoleCode C
				ON C.srcnCodeId = S.sbrnTypeCode
				AND C.srcsDscrptn = '(P)-Default Role'
			WHERE S.sbrnCaseTypeID = CAS.casnOrgCaseTypeID
		)		   
		AS plnnRole
	   ,1		   AS [plnbIsPrimary]
	   ,0
	   ,0
	   ,0
	   ,0
	   ,0
	   ,0
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,GETDATE()
	   ,NULL
	   ,368		   AS [plnnRecUserID]
	   ,GETDATE()  AS [plndDtCreated]
	   ,NULL
	   ,NULL
	   ,''
	   ,NULL
	   ,''
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,1		   AS [plnnPrimaryContact]
	FROM sma_trn_cases CAS
	LEFT JOIN [sma_TRN_Plaintiff] T
		ON T.plnnCaseID = CAS.casnCaseID
	WHERE plnnCaseID IS NULL
GO



UPDATE sma_TRN_Plaintiff
SET plnbIsPrimary = 0

UPDATE sma_TRN_Plaintiff
SET plnbIsPrimary = 1
FROM (
	SELECT DISTINCT
		T.plnnCaseID
	   ,ROW_NUMBER() OVER (PARTITION BY T.plnnCaseID ORDER BY P.record_num) AS RowNumber
	   ,T.plnnPlaintiffID AS ID
	FROM sma_TRN_Plaintiff T
	LEFT JOIN TestNeedles.[dbo].[party_indexed] P
		ON P.TableIndex = T.saga_party
) A
WHERE A.RowNumber = 1
AND plnnPlaintiffID = A.ID



ALTER TABLE [sma_TRN_Plaintiff] ENABLE TRIGGER ALL
GO
