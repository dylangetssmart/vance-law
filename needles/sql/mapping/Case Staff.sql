/* ######################################################################################
description: Outputs distinct case staff

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

SELECT DISTINCT
	c.staff_1
   ,c.staff_2
   ,c.staff_3
   ,c.staff_4
   ,c.staff_5
   ,c.staff_6
   ,c.staff_7
   ,c.staff_8
   ,c.staff_9
   ,c.staff_10
FROM NeedlesSLF..cases c