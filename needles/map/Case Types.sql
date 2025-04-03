/* ######################################################################################
description: Outputs matter codes and the number of times each is used.

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
	m.*
   ,[count]
FROM matter m
JOIN (
	SELECT
		m.matcode
	   ,m.header
	   ,m.[description]
	   ,COUNT(*) AS [Count]
	FROM matter m
	JOIN cases_Indexed ci
		ON m.matcode = ci.matcode
	GROUP BY m.matcode
			,m.header
			,m.[description]
) c
	ON m.matcode = c.matcode