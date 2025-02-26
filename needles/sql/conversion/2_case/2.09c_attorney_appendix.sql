/* ###################################################################################
description: Update contact types for attorneys
steps:
	- Update individual contact type > [sma_MST_IndvContacts]
	
usage_instructions:
	- 
dependencies:
	- 
notes:
	-
*/

USE [JoelBieberSA_Needles]
GO


---(Appendix)---
UPDATE sma_MST_IndvContacts
SET cinnContactTypeID = (
	SELECT
		octnOrigContactTypeID
	FROM [sma_MST_OriginalContactTypes]
	WHERE octsDscrptn = 'Attorney'
		AND octnContactCtgID = 1
)
FROM (
	SELECT
		I.cinnContactID AS ID
	FROM JoelBieberNeedles.[dbo].[counsel] C
	JOIN JoelBieberNeedles.[dbo].[names] L
		ON C.counsel_id = L.names_id
	JOIN [dbo].[sma_MST_IndvContacts] I
		ON saga = L.names_id
	WHERE L.person = 'Y'
) A
WHERE cinnContactID = A.ID
GO
