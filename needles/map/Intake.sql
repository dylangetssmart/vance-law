/* ######################################################################################
description: Outputs fields from [user_case_intake_matter]

steps:
	- 

usage_instructions:
	- update database reference

dependencies:
	- 

notes:
	- 
#########################################################################################
*/

USE [Needles]
GO

SELECT
	*
FROM CustomFieldUsage_intake
ORDER BY tablename, field_num

