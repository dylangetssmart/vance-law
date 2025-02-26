/* ######################################################################################
description: Outputs party roles and the number of times each is used.

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
	[role]
   ,COUNT(*) AS Count
FROM party_Indexed
WHERE ISNULL([role], '') <> ''
GROUP BY [role]