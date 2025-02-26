/* ######################################################################################
description: Creates implementatio_users
steps:
	-
usage_instructions:
	- 
dependencies:
	- 
notes:
	- 
#########################################################################################
*/


/*
This script manages the population of the `implementation_users` table for the JoelBieberSA_Needles project.
It consists of two main phases, controlled by the `@Phase` variable:

    - Phase 1: Initial Conversion
      - Seeds the `implementation_users` table from the `JoelBieberNeedles..staff` table.
      - Used in the initial data conversion phase when only `staff` data is available.

    - Phase 2: Implementation Database Seeding
      - Drops and repopulates `implementation_users` based on the implementation database.
      - Joins `sma_mst_users` and `sma_MST_IndvContacts` from the implementation database.
      - Adds `staff_code` from `JoelBieberNeedles..staff` if available.
      - Used in later project phases when the implementation database is the primary source.

Usage:
- Set the `@Phase` variable to `1` for Phase 1 or `2` for Phase 2, then run the script.

Requirements:
- Phase 1 assumes `staff` records exist in `JoelBieberNeedles..staff`.
- Phase 2 assumes that both `sma_mst_users` and `sma_MST_IndvContacts` are populated in the implementation database.

*/

USE [SA];

IF OBJECT_ID('implementation_users', 'U') IS NOT NULL
BEGIN
	DROP TABLE implementation_users;
END;

-- Create the implementation_users table
CREATE TABLE implementation_users (
	SAContactID NVARCHAR(25)
   ,SAUserID NVARCHAR(25)
   ,StaffCode NVARCHAR(50)
   ,full_name NVARCHAR(100)
   ,SALoginID NVARCHAR(50)
   ,Prefix NVARCHAR(10)
   ,SAFirst NVARCHAR(50)
   ,SAMiddle VARCHAR(5)
   ,SALast NVARCHAR(50)
   ,Suffix NVARCHAR(10)
   ,Active BIT
   ,Visible BIT
);
GO

-- Declare a variable to control the execution phase
DECLARE @Phase INT = 1;  -- Set to 1 for Phase 1, 2 for Phase 2

IF @Phase = 1
BEGIN
	-- Phase 1: Initial Conversion - Seed from JoelBieberNeedles..staff

	INSERT INTO implementation_users
		(
		SAContactID
	   ,SAUserID
	   ,StaffCode
	   ,full_name
	   ,SALoginID
	   ,Prefix
	   ,SAFirst
	   ,SAMiddle
	   ,SALast
	   ,Suffix
		)
		SELECT
			NULL						   AS SAContactID
		   ,NULL						   AS SAUserID
		   ,staff_code					   AS StaffCode
		   ,s.full_name					   AS full_name
		   ,staff_code					   AS SAloginID
		   ,prefix						   AS Prefix
		   ,dbo.get_firstword(s.full_name) AS SAFirst
		   ,''							   AS SAMiddle
		   ,dbo.get_lastword(s.full_name)  AS SALast
		   ,suffix						   AS Suffix
		FROM [Needles].[dbo].[staff] s;
END
ELSE
IF @Phase = 2
BEGIN
	-- Phase 2: Use implementation database as starting point and add staff_code from JoelBieberNeedles..staff

	INSERT INTO implementation_users
		(
		SAContactID
	   ,SAUserID
	   ,StaffCode
	   ,full_name
	   ,SALoginID
	   ,Prefix
	   ,SAFirst
	   ,SAMiddle
	   ,SALast
	   ,Suffix
	   ,Active
	   ,Visible
		)
		SELECT
			smic.cinnContactID
		   ,u.usrnUserID
		   ,COALESCE(s.staff_code, '') AS StaffCode
		   ,s.full_name
		   ,u.usrsLoginID			   AS SALoginID
		   ,smic.cinsPrefix			   AS Prefix
		   ,smic.cinsFirstName		   AS SAFirst
		   ,smic.cinsMiddleName		   AS SAMddle
		   ,smic.cinsLastName		   AS SALast
		   ,smic.cinsSuffix			   AS Suffix
		   ,u.usrbActiveState		   AS Active
		   ,u.usrbIsShowInSystem	   AS Visible
		--select * 
		FROM [SA]..sma_mst_users u
		JOIN [SA]..sma_MST_IndvContacts smic
			ON smic.cinnContactID = u.usrnContactID
		LEFT JOIN [Needles]..staff s
			ON s.full_name = smic.cinsFirstName + ' ' + smic.cinsLastName
END;
