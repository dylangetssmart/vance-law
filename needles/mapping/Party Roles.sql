SELECT
	[role]
   ,COUNT(*) AS Count
FROM party_Indexed
WHERE ISNULL([role], '') <> ''
GROUP BY [role]