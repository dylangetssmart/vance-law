/*---
description: creates conversion schema if it does not exist
steps:
	-
usage_instructions:
	-
dependencies:
	- 
notes:
	-
---*/

use [BrachEichler_SA]
go

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'conv')
EXEC sys.sp_executesql N'CREATE SCHEMA [conv]'
GO