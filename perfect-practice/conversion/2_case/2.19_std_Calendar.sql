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

SET QUOTED_IDENTIFIER ON;

/*
alter table [sma_TRN_CalendarAppointments] disable trigger all
delete from [sma_TRN_CalendarAppointments]
DBCC CHECKIDENT ('[sma_TRN_CalendarAppointments]', RESEED, 0);
alter table [sma_TRN_CalendarAppointments] disable trigger all

alter table [sma_trn_AppointmentStaff] disable trigger all
delete from [sma_trn_AppointmentStaff]
DBCC CHECKIDENT ('[sma_trn_AppointmentStaff]', RESEED, 0);
alter table [sma_trn_AppointmentStaff] disable trigger all
*/

---(0)---
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga'
			AND object_id = OBJECT_ID(N'sma_TRN_CalendarAppointments')
	)
BEGIN
	ALTER TABLE [sma_TRN_CalendarAppointments] ADD [saga] [VARCHAR](100) NULL;
END
GO

----(0)----
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE name = 'CalendarJudgeStaffCourt'
			AND type = 'U'
	)
BEGIN
	DROP TABLE CalendarJudgeStaffCourt
END
GO

-- Construct table
SELECT
	CAL.calendar_id AS CalendarId
   ,CAS.casnCaseID  AS CaseID
   ,0				AS Judge_Contact
   ,0				AS Staff_Contact
   ,0				AS Court_Contact
   ,0				AS Court_Address
   ,0				AS Party_Contact INTO CalendarJudgeStaffCourt
FROM TestNeedles.[dbo].[calendar] CAL
JOIN [sma_TRN_Cases] CAS
	ON CAS.cassCaseNumber = CAL.casenum
WHERE ISNULL(CAL.casenum, 0) <> 0

-- Update Judge_Contact with cinnContactID from [sma_MST_IndvContacts]
-- calendar.judge_link = on [sma_MST_IndvContacts].saga
UPDATE CalendarJudgeStaffCourt
SET Judge_Contact = I.cinnContactID
FROM TestNeedles.[dbo].[calendar] CAL
JOIN [sma_TRN_Cases] CAS
	ON CAS.cassCaseNumber = CAL.casenum
JOIN [sma_MST_IndvContacts] I
	ON I.saga = CAL.judge_link
	AND CAL.judge_link <> 0
WHERE CAL.calendar_id = CalendarId

-- Set Staff_Contact [sma_MST_IndvContacts].cinnContactID
-- calendar.staff_id = [sma_MST_IndvContacts].cinsGrade
UPDATE CalendarJudgeStaffCourt
SET Staff_Contact = J.cinnContactID
FROM TestNeedles.[dbo].[calendar] CAL
JOIN [sma_TRN_Cases] CAS
	ON CAS.cassCaseNumber = CAL.casenum
JOIN [sma_MST_IndvContacts] J
	ON J.cinsGrade = CAL.staff_id
	AND ISNULL(CAL.staff_id, '') <> ''
WHERE CAL.calendar_id = CalendarId

-- Set Court_Contact to [sma_MST_OrgContacts].connContactID 
-- Set Court_Address to [sma_MST_Address].addnAddressID
UPDATE CalendarJudgeStaffCourt
SET Court_Contact = O.connContactID
   ,Court_Address = A.addnAddressID
FROM TestNeedles.[dbo].[calendar] CAL
JOIN [sma_TRN_Cases] CAS
	ON CAS.cassCaseNumber = CAL.casenum
JOIN [sma_MST_OrgContacts] O
	ON O.saga = CAL.court_link
JOIN [sma_MST_Address] A
	ON A.addnContactID = O.connContactID
	AND A.addnContactCtgID = O.connContactCtg
	AND A.addbPrimary = 1
WHERE CAL.calendar_id = CalendarId

-- Set Party_Contact to [sma_MST_IndvContacts].cinnContactID
UPDATE CalendarJudgeStaffCourt
SET Party_Contact = J.cinnContactID
FROM TestNeedles.[dbo].[calendar] CAL
JOIN [sma_TRN_Cases] CAS
	ON CAS.cassCaseNumber = CAL.casenum
JOIN [sma_MST_IndvContacts] J
	ON J.saga = CAL.party_id
WHERE CAL.calendar_id = CalendarId


---(0)---
INSERT INTO [sma_MST_ActivityType]
	(
	attsDscrptn, attnActivityCtg
	)
	SELECT
		A.ActivityType
	   ,(
			SELECT
				atcnPKId
			FROM sma_MST_ActivityCategory
			WHERE atcsDscrptn = 'Case-Related Appointment'
		)
	FROM (
		SELECT DISTINCT
			appointment_type AS ActivityType
		FROM TestNeedles.[dbo].[calendar] CAL
		WHERE ISNULL(appointment_type, '') <> ''
		EXCEPT
		SELECT
			attsDscrptn AS ActivityType
		FROM sma_MST_ActivityType
		WHERE attnActivityCtg = (
				SELECT
					atcnPKId
				FROM sma_MST_ActivityCategory
				WHERE atcsDscrptn = 'Case-Related Appointment'
			)
			AND ISNULL(attsDscrptn, '') <> ''
	) A
GO


ALTER TABLE [sma_TRN_CalendarAppointments] DISABLE TRIGGER ALL

----(1)-----
INSERT INTO [sma_TRN_CalendarAppointments]
	(
	[FromDate], [ToDate], [AppointmentTypeID], [ActivityTypeID], [CaseID], [LocationContactID], [LocationContactGtgID], [JudgeID], [Comments], [StatusID], [Address], [subject], [RecurranceParentID], [AdjournedID], [RecUserID], [DtCreated], [ModifyUserID], [DtModified], [DepositionType], [Deponants], [OriginalAppointmentID], [OriginalAdjournedID], [RecurrenceId], [WorkPlanItemId], [AutoUpdateAppId], [AutoUpdated], [AutoUpdateProviderId], [saga]
	)
	SELECT
		CASE
			WHEN CAL.[start_date] BETWEEN '1900-01-01' AND '2079-06-06' AND
				CONVERT(TIME, ISNULL(CAL.[start_time], '00:00:00')) <> CONVERT(TIME, '00:00:00')
				THEN CAST(CAST(CAL.[start_date] AS DATETIME) + CAST(CAL.[start_time] AS DATETIME) AS DATETIME)
			--then cast(cal.[start_date] as datetime)
			WHEN CAL.[start_date] BETWEEN '1900-01-01' AND '2079-06-06' AND
				CONVERT(TIME, ISNULL(CAL.[start_time], '00:00:00')) = CONVERT(TIME, '00:00:00')
				THEN CAST(CAST(CAL.[start_date] AS DATETIME) + CAST('00:00:00' AS DATETIME) AS DATETIME)
			ELSE '1900-01-01'
		END													AS [FromDate]
	   ,CASE
			WHEN CAL.[stop_date] BETWEEN '1900-01-01' AND '2079-06-06' AND
				CONVERT(TIME, ISNULL(CAL.[stop_time], '00:00:00')) <> CONVERT(TIME, '00:00:00')
				THEN CAST(CAST(CAL.[stop_date] AS DATETIME) + CAST(CAL.[stop_time] AS DATETIME) AS DATETIME)
			--then cast(cal.[stop_date] as datetime)
			WHEN CAL.[stop_date] BETWEEN '1900-01-01' AND '2079-06-06' AND
				CONVERT(TIME, ISNULL(CAL.[stop_time], '00:00:00')) = CONVERT(TIME, '00:00:00')
				THEN CAST(CAST(CAL.[stop_date] AS DATETIME) + CAST('00:00:00' AS DATETIME) AS DATETIME)
			ELSE '1900-01-01'
		END													AS [ToDate]
	   ,(
			SELECT
				ID
			FROM [sma_MST_CalendarAppointmentType]
			WHERE AppointmentType = 'Case-related'
		)													
		AS [AppointmentTypeID]
	   ,CASE
			WHEN ISNULL(CAL.appointment_type, '') <> ''
				THEN (
						SELECT
							attnActivityTypeID
						FROM sma_MST_ActivityType
						WHERE attnActivityCtg = (
								SELECT
									atcnPKId
								FROM sma_MST_ActivityCategory
								WHERE atcsDscrptn = 'Case-Related Appointment'
							)
							AND attsDscrptn = CAL.appointment_type
					)
			ELSE (
					SELECT
						attnActivityTypeID
					FROM [sma_MST_ActivityType]
					WHERE attnActivityCtg = (
							SELECT
								atcnPKId
							FROM sma_MST_ActivityCategory
							WHERE atcsDscrptn = 'Case-Related Appointment'
						)
						AND attsDscrptn = 'Appointment'
				)
		END													AS [ActivityTypeID]
	   ,CAS.casnCaseID										AS [CaseID]
	   ,MAP.Court_Contact									AS [LocationContactID]
	   ,2													AS [LocationContactGtgID]
	   ,MAP.Judge_Contact									AS [JudgeID]
	   ,ISNULL('party name : ' + NULLIF(CAL.[party_name], '') + CHAR(13), '') +
		ISNULL('short notes : ' + NULLIF(CAL.[short_notes], '') + CHAR(13), '') +
		''													AS [Comments]
	   ,CASE
			WHEN CAL.status = 'Canceled'
				THEN (
						SELECT
							[StatusId]
						FROM [sma_MST_AppointmentStatus]
						WHERE [StatusName] = 'Canceled'
					)
			WHEN CAL.status = 'Done'
				THEN (
						SELECT
							[StatusId]
						FROM [sma_MST_AppointmentStatus]
						WHERE [StatusName] = 'Completed'
					)
			WHEN CAL.status = 'No Show'
				THEN (
						SELECT
							[StatusId]
						FROM [sma_MST_AppointmentStatus]
						WHERE [StatusName] = 'Open'
					)
			WHEN CAL.status = 'Open'
				THEN (
						SELECT
							[StatusId]
						FROM [sma_MST_AppointmentStatus]
						WHERE [StatusName] = 'Open'
					)
			WHEN CAL.status = 'Postponed'
				THEN (
						SELECT
							[StatusId]
						FROM [sma_MST_AppointmentStatus]
						WHERE [StatusName] = 'Adjourned'
					)
			WHEN CAL.status = 'Rescheduled'
				THEN (
						SELECT
							[StatusId]
						FROM [sma_MST_AppointmentStatus]
						WHERE [StatusName] = 'Adjourned'
					)
			ELSE (
					SELECT
						[StatusId]
					FROM [sma_MST_AppointmentStatus]
					WHERE [StatusName] = 'Open'
				)
		END													AS [StatusID]
	   ,NULL												AS [Address]
	   ,LEFT(CAL.[subject], 120)							AS [Subject]
	   ,NULL
	   ,NULL
	   ,368													AS [RecUserID]
	   ,CAL.[date_created]									AS [DtCreated]
	   ,NULL												AS [ModifyUserID]
	   ,NULL												AS [DtModified]
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,'Case-related:' + CONVERT(VARCHAR, CAL.calendar_id) AS [saga]
	FROM TestNeedles.[dbo].[calendar] CAL
	JOIN [sma_TRN_Cases] CAS
		ON CAS.cassCaseNumber = CAL.casenum
	JOIN CalendarJudgeStaffCourt MAP
		ON MAP.CalendarId = CAL.calendar_id
	WHERE ISNULL(CAL.casenum, 0) <> 0
GO

ALTER TABLE [sma_TRN_CalendarAppointments] ENABLE TRIGGER ALL

----(2)-----
INSERT INTO [sma_trn_AppointmentStaff]
	(
	[AppointmentId], [StaffContactId]
	)
	SELECT
		APP.AppointmentID
	   ,MAP.Staff_Contact
	FROM [sma_TRN_CalendarAppointments] APP
	JOIN TestNeedles.[dbo].[calendar] CAL
		ON APP.saga = 'Case-related:' + CONVERT(VARCHAR, CAL.calendar_id)
	JOIN CalendarJudgeStaffCourt MAP
		ON MAP.CalendarId = CAL.calendar_id


/*
----(3)-----
insert into [SA].[dbo].[sma_trn_AppointmentStaff] ( [AppointmentId] ,[StaffContactId] ) 
select APP.AppointmentID, MAP.Party_Contact
from [SA].[dbo].[sma_TRN_CalendarAppointments] APP
inner join TestNeedles.[dbo].[calendar] CAL on APP.saga='Case-related:'+convert(varchar,CAL.calendar_id)
inner join CalendarJudgeStaffCourt MAP on MAP.CalendarId=CAL.calendar_id
*/
