use VanceLawFirm_SA
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF COL_LENGTH('sma_trn_UserPreference', 'preFolderView') IS NULL
BEGIN
    ALTER TABLE sma_trn_UserPreference
    ADD preFolderView BIT DEFAULT 0 WITH VALUES
END
GO