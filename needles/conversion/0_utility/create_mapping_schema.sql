use VanceLawFirm_SA
go

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'mapping')
EXEC sys.sp_executesql N'CREATE SCHEMA [mapping]'
GO