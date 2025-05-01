use VanceLawFirm_SA
go

IF EXISTS (select * from sys.objects where name='CaseTypeMixture')
BEGIN
    DROP TABLE [dbo].[CaseTypeMixture]
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CaseTypeMixture]
(
	[matcode] [nvarchar](255) NULL
	,[header] [nvarchar](255) NULL
	,[description] [nvarchar](255) NULL
	,[SmartAdvocate Case Type] [nvarchar](255) NULL
	,[SmartAdvocate Case Sub Type] [nvarchar](255) NULL
) ON [PRIMARY]


-- Seed CaseTypeMixture with values directly from matter for initial converison
INSERT INTO [dbo].[CaseTypeMixture]
(
	[matcode]
	,[header]
	,[description]
	,[SmartAdvocate Case Type]
	,[SmartAdvocate Case Sub Type]
)
	SELECT 
		matcode, 
		header, 
		description, 
		description AS [SmartAdvocate Case Type], 
		'' AS [SmartAdvocate Case Sub Type]
	FROM VanceLawFirm_Needles..matter;
GO


-- Add missing MVA case type
insert into [dbo].[CaseTypeMixture]
	(
		[matcode],
		[header],
		[description],
		[SmartAdvocate Case Type],
		[SmartAdvocate Case Sub Type]
	)
	values
	('MVA', 'MVA', 'Motor Vehicle Accident', 'Motor Vehicle Accident', '')



--select * from casetypemixture


--INSERT INTO [dbo].[CaseTypeMixture]
--(
--	[matcode]
--	,[header]
--	,[description]
--	,[SmartAdvocate Case Type]
--	,[SmartAdvocate Case Sub Type]
--)
--SELECT 'AGA', 'AUTOGA', 'Car Accident - General', 'Car Accident - General', '' UNION
--SELECT 'AN3', 'NC WC', 'Workplace Injury - General', 'Workplace Injury - General', '' UNION
--SELECT 'ANA', 'ANASTOMM', 'Medical Malpractice - General', 'Medical Malpractice - General', '' UNION
--SELECT 'ANC', 'NC PI', 'Personal Injury - General', 'Personal Injury - General', '' UNION
--SELECT 'ASC', 'AUTO SC', 'Car Accident - General', 'Car Accident - General', '' UNION
--SELECT 'AVA', 'AUTO VA', 'Car Accident - General', 'Car Accident - General', '' UNION
--SELECT 'AVB', 'AUTO VB', 'Car Accident - General', 'Car Accident - General', '' UNION
--SELECT 'BRE', 'BOC', 'Breach of Contract', 'Breach of Contract', '' UNION
--SELECT 'DC', 'DC PI', 'Car Accident - General', 'Car Accident - General', '' UNION
--SELECT 'DOG', 'DOG BITE', 'Dog Bite', 'Dog Bite', '' UNION
--SELECT 'DSC', 'SC DOG', 'Dog Bite', 'Dog Bite', '' UNION
--SELECT 'GEN', 'GEN TORT', 'Personal Injury - General', 'Personal Injury - General', '' UNION
--SELECT 'MM', 'MED-MAL', 'Medical Malpractice - General', 'Medical Malpractice - General', '' UNION
--SELECT 'MPI', 'MDPI', 'Car Accident - General', 'Car Accident - General', '' UNION
--SELECT 'NVA', 'NOT VA', 'Car Accident - General', 'Car Accident - General', '' UNION
--SELECT 'PED', 'PED/BIKE', 'Personal Injury - General', 'Personal Injury - General', '' UNION
--SELECT 'PER', 'PER INJ', 'Personal Injury - General', 'Personal Injury - General', '' UNION
--SELECT 'PSC', 'PSC', 'Pedestrian', 'Pedestrian', '' UNION
--SELECT 'RUP', 'ROUNDUP', 'Product Liability - General', 'Product Liability - General', '' UNION
--SELECT 'SAS', 'SAS', 'Sexual Harassment', 'Sexual Harassment', '' UNION
--SELECT 'SCP', 'SC PI', 'Personal Injury - General', 'Personal Injury - General', '' UNION
--SELECT 'SNC', 'NC S&F', 'Slip/Trip and Fall', 'Slip/Trip and Fall', '' UNION
--SELECT 'SSC', 'S&F SC', 'Slip/Trip and Fall', 'Slip/Trip and Fall', '' UNION
--SELECT 'SVA', 'S&F VA', 'Slip/Trip and Fall', 'Slip/Trip and Fall', '' UNION
--SELECT 'VWC', 'VA WC', 'Workplace Injury - General', 'Workplace Injury - General', '' UNION
--SELECT 'WC', 'WORKCOMP', 'Workplace Injury - General', 'Workplace Injury - General', '' UNION
--SELECT 'WV', 'WVPI', 'Personal Injury - General', 'Personal Injury - General', ''