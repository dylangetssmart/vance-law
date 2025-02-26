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
alter table [sma_TRN_Notes] disable trigger all
delete from [sma_TRN_Notes] 
DBCC CHECKIDENT ('[sma_TRN_Notes]', RESEED, 0);
alter table [sma_TRN_Notes] enable trigger all
*/
IF NOT EXISTS (
		SELECT
			*
		FROM sys.tables t
		JOIN sys.columns c
			ON t.object_id = c.object_id
		WHERE t.name = 'Sma_trn_notes'
			AND c.name = 'saga'
	)
BEGIN
	ALTER TABLE sma_trn_notes
	ADD SAGA INT
END
GO

----(0)----
INSERT INTO [sma_MST_NoteTypes]
	(
	nttsDscrptn, nttsNoteText
	)
	SELECT DISTINCT
		topic AS nttsDscrptn
	   ,topic AS nttsNoteText
	FROM TestNeedles.[dbo].[case_notes_Indexed]
	EXCEPT
	SELECT
		nttsDscrptn
	   ,nttsNoteText
	FROM [sma_MST_NoteTypes]
GO

---
ALTER TABLE [sma_TRN_Notes] DISABLE TRIGGER ALL
GO
---

----(1)----
INSERT INTO [sma_TRN_Notes]
	(
	[notnCaseID], [notnNoteTypeID], [notmDescription], [notmPlainText], [notnContactCtgID], [notnContactId], [notsPriority], [notnFormID], [notnRecUserID], [notdDtCreated], [notnModifyUserID], [notdDtModified], [notnLevelNo], [notdDtInserted], [WorkPlanItemId], [notnSubject], SAGA
	)
	SELECT
		casnCaseID						AS [notnCaseID]
	   ,(
			SELECT
				MIN(nttnNoteTypeID)
			FROM [sma_MST_NoteTypes]
			WHERE nttsDscrptn = N.topic
		)								
		AS [notnNoteTypeID]
	   ,note							AS [notmDescription]
	   ,REPLACE(note, CHAR(10), '<br>') AS [notmPlainText]
	   ,0								AS [notnContactCtgID]
	   ,NULL							AS [notnContactId]
	   ,NULL							AS [notsPriority]
	   ,NULL							AS [notnFormID]
	   ,U.usrnUserID					AS [notnRecUserID]
	   ,CASE
			WHEN N.note_date BETWEEN '1900-01-01' AND '2079-06-06' AND
				CONVERT(TIME, ISNULL(N.note_time, '00:00:00')) <> CONVERT(TIME, '00:00:00')
				THEN CAST(CAST(N.note_date AS DATETIME) + CAST(N.note_time AS DATETIME) AS DATETIME)
			WHEN N.note_date BETWEEN '1900-01-01' AND '2079-06-06' AND
				CONVERT(TIME, ISNULL(N.note_time, '00:00:00')) = CONVERT(TIME, '00:00:00')
				THEN CAST(CAST(N.note_date AS DATETIME) + CAST('00:00:00' AS DATETIME) AS DATETIME)
			ELSE '1900-01-01'
		END								AS notdDtCreated
	   ,NULL							AS [notnModifyUserID]
	   ,NULL							AS notdDtModified
	   ,NULL							AS [notnLevelNo]
	   ,NULL							AS [notdDtInserted]
	   ,NULL							AS [WorkPlanItemId]
	   ,NULL							AS [notnSubject]
	   ,note_key						AS SAGA
	FROM TestNeedles.[dbo].[case_notes_Indexed] N
	JOIN [sma_TRN_Cases] C
		ON C.cassCaseNumber = N.case_num
	LEFT JOIN [sma_MST_Users] U
		ON U.saga = N.staff_id
	LEFT JOIN [sma_TRN_Notes] ns
		ON ns.saga = note_key
	WHERE ns.notnNoteID IS NULL
GO


--alter table sma_trn_notes disable trigger all
--update  sma_trn_notes set notmPlainText=replace(notmPlainText,char(10),'<br>') where  notmPlainText like '%'+char(10)+'%'
--alter table sma_trn_notes enable trigger all

---
ALTER TABLE [sma_TRN_Notes] ENABLE TRIGGER ALL
GO
---

