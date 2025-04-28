/* ######################################################################################
description: Outputs entire value_code table

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

USE VanceLawFirm_Needles

SELECT
	code,
	description,
	c_d,
	dtf
FROM value_code