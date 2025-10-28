use [BrachEichler_SA]
go

if exists (select * from sys.objects where name = 'ValueCodeMap')
begin
	drop table [conv].[ValueCodeMap]
end

go

set ansi_nulls on
go

set quoted_identifier on
go

create table [conv].[ValueCodeMap] (
	[Code]				  [NVARCHAR](50)  not null,
	[Description]		  [NVARCHAR](255) null,
	[Credit_Debit]		  [NVARCHAR](10)  null,
	[DueToFirm]			  [NVARCHAR](1)	  null,
	[SA_Section]		  [NVARCHAR](255) null,
	[SA_Screen]			  [NVARCHAR](255) null,
	[SA_Field]			  [NVARCHAR](255) null,
	[Disbursement_Status] [NVARCHAR](50)  null,
	[Comment]			  [NVARCHAR](MAX) null,

	constraint [PK_ValueCodeMap] primary key clustered ([Code] asc)
) on [PRIMARY]
go

---------------------------------------------------------------------------------
-- PLACEHOLDER FOR DATA INSERTION
--
-- To insert your data, uncomment the section below and paste your Excel rows
-- into the VALUES list. Each row must be enclosed in parentheses and comma-separated.
---------------------------------------------------------------------------------

--insert into [conv].[ValueCodeMap]
--	(
--		[Code],
--		[Description],
--		[Credit_Debit],
--		[DueToFirm],
--		[SA_Section],
--		[SA_Screen],
--		[SA_Field],
--		[Disbursement_Status],
--		[Comment]
--	)
--	values
--		-- START PASTE HERE: Replace the example row below with all your (data, 'from', 'Excel', 'formatted', 'as', 'SQL', 'rows', NULL, NULL),
--		--('EXAMPLE', 'Example Placeholder Entry', 'X', 'Y', NULL, NULL, NULL, 'Pending', 'Replace this with your data')