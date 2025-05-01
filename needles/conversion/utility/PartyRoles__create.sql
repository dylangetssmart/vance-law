USE VanceLawFirm_SA
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * From sys.tables where name = 'PartyRoles' and type = 'U')
begin 
	drop table partyRoles
end

CREATE TABLE [dbo].[PartyRoles]
(
	[Needles Roles] [nvarchar](255) NULL
	,[SA Roles] [nvarchar](255) NULL
	,[SA Party] [nvarchar](255) NULL
) ON [PRIMARY]

GO

INSERT INTO [dbo].[PartyRoles]
(
	[Needles Roles]
	,[SA Roles]
	,[SA Party]
)
SELECT 'Plaintiff/Owner', '(P)-Owner', 'Plaintiff' UNION
SELECT 'Personal Representative', '(P)-Representative', 'Plaintiff' UNION
SELECT 'Guardian', '(P)-Guardian', 'Plaintiff' UNION
SELECT 'Beneficiary', '(D)-Beneficiary/Distributee', 'Defendant' UNION
SELECT 'Def-Driver', '(D)-Operator', 'Defendant' UNION
SELECT 'Potential Client', '(P)-Plaintiff', 'Plaintiff' UNION
SELECT 'Plaintiff-Driver/Owner', '(P)-Owner/Operator', 'Plaintiff' UNION
SELECT 'Def-Driver/Owner', '(D)-Owner/Operator', 'Defendant' UNION
SELECT 'Plaintiff/Driver', '(P)-Operator', 'Plaintiff' UNION
SELECT 'Defendant', '(D)-Defendant', 'Defendant' UNION
SELECT 'Driver/Owner', '(P)-Owner/Operator', 'Plaintiff' UNION
SELECT 'Def-Owner', '(D)-Owner', 'Defendant' UNION
SELECT 'Parent', '(P)-Guardian', 'Parent' UNION
SELECT 'Plaintiff', '(P)-Plaintiff', 'Plaintiff' UNION
SELECT 'Def-Owner #2', '(D)-Owner', 'Defendant' UNION
SELECT 'Administrator', '(P)-Estate Admin.', 'Plaintiff' UNION
SELECT 'Claimant', '(P)-Claimant', 'Plaintiff' UNION
SELECT 'Owner', '(P)-Owner', 'Plaintiff' UNION
SELECT 'Driver', '(P)-Operator', 'Plaintiff'




-- add non-typical roles to Other Contacts (sma_MST_OtherCasesContact)
-- Drop the sma_MST_OtherCasesContact table if it exists
--IF EXISTS (SELECT * FROM sys.tables WHERE name = 'sma_MST_OtherCasesContact' AND type = 'U')
--BEGIN 
--    DROP TABLE [dbo].[sma_MST_OtherCasesContact]
--END
--GO

---- Create the sma_MST_OtherCasesContact table
--CREATE TABLE [dbo].[sma_MST_OtherCasesContact](
--    [OtherCasesContactPKID] [int] IDENTITY(1,1) NOT NULL,
--    [OtherCasesID] [int] NULL,
--    [OtherCasesContactID] [int] NULL,
--    [OtherCasesContactCtgID] [int] NULL,
--    [OtherCaseContactAddressID] [int] NULL,
--    [OtherCasesContactRole] [varchar](500) NULL,
--    [OtherCasesCreatedUserID] [int] NULL,
--    [OtherCasesContactCreatedDt] [smalldatetime] NULL,
--    [OtherCasesModifyUserID] [int] NULL,
--    [OtherCasesContactModifieddt] [smalldatetime] NULL,
-- CONSTRAINT [PK_sma_MST_OtherCasesContact] PRIMARY KEY CLUSTERED 
--(
--    [OtherCasesContactPKID] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
--) ON [PRIMARY]

---- Create
----INSERT [VanceLawFirm_Needles].[dbo].[sma_MST_OtherCasesContact](
----	[OtherCasesContactRole]
----)
----SELECT 'Personal Representative' UNION
----SELECT 'Seller' UNION
----SELECT 'Voter' UNION
----SELECT 'Payee' UNION
----SELECT 'Family Member' UNION
----SELECT 'Buyer'
