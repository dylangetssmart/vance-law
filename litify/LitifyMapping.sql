-- Party Roles
SELECT
	lprc.litify_pm__Role__c
   ,COUNT(*) AS RoleCount
FROM ShinerLitify..litify_pm__Role__c lprc
GROUP BY lprc.litify_pm__Role__c
ORDER BY RoleCount DESC;


-- Insurance Types
SELECT
	lpic.litify_pm__Insurance_Type__c
   ,COUNT(*) AS RoleCount
FROM ShinerLitify..litify_pm__Insurance__c lpic
GROUP BY lpic.litify_pm__Insurance_Type__c
ORDER BY RoleCount DESC;


-- Referral Sources
SELECT
	lpsc.litify_tso_Source_Type_Name__c
   ,COUNT(*) AS RoleCount
FROM ShinerLitify..litify_pm__Source__c lpsc
GROUP BY lpsc.litify_tso_Source_Type_Name__c
ORDER BY RoleCount DESC;


-- Damage Types
SELECT
	lpdc.litify_pm__Type__c
   ,COUNT(*) AS RoleCount
FROM ShinerLitify..litify_pm__Damage__c lpdc
GROUP BY lpdc.litify_pm__Type__c
ORDER BY RoleCount DESC;


-- Damage Types
SELECT
	lprc.litify_pm__Request_Type__c
   ,COUNT(*) AS RoleCount
FROM ShinerLitify..litify_pm__Request__c lprc
GROUP BY lprc.litify_pm__Request_Type__c
ORDER BY RoleCount DESC;