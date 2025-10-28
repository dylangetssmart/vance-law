use [VanceLawFirm_SA]
go

if exists (select * from sys.objects where name = 'PartyRoleMap')
begin
	drop table [dbo].[PartyRoleMap]
end

go

set ansi_nulls on
go

set quoted_identifier on
go

create table [dbo].[PartyRoleMap] (
	[Needles Role] [NVARCHAR](255) null,
	[SA Role]	   [NVARCHAR](255) null,
	[SA Party]	   [NVARCHAR](255) null
) on [PRIMARY]


---------------------------------------------------------------------------------
-- FOR MAPPING SPREADSHEET
--
-- To insert your data, uncomment the section below and paste your Excel rows
-- into the VALUES list. Each row must be enclosed in parentheses and comma-separated.
---------------------------------------------------------------------------------

--insert into [dbo].[PartyRoleMap]
--	(
--		[Needles Role],
--		[SA Role],
--		[SA Party]
--	)
--	select distinct
--		[role] as [Needles Role],
--		''	   as [Sa role],
--		''	   as [SA Party]
--	from [VanceLawFirm_Needles]..party_Indexed
--	where
--		ISNULL([role], '') <> ''
--	group by [role]
--	order by [role]
--go


---------------------------------------------------------------------------------
-- PLACEHOLDER FOR DATA INSERTION
--
-- To insert your data, uncomment the section below and paste your Excel rows
-- into the VALUES list. Each row must be enclosed in parentheses and comma-separated.
---------------------------------------------------------------------------------

insert into [dbo].[PartyRoleMap]
	(
		[Needles Role],
		[SA Role],
		[SA Party]
	)
	values
		-- START PASTE HERE: Replace the example row below with your data
		-- ('Example', 'SA Role', 'SA Party')
		('Plaintiff/Owner', '(P)-Owner', 'Plaintiff'),
		('Personal Representative', '(P)-Representative', 'Plaintiff'),
		('Guardian', '(P)-Guardian', 'Plaintiff'),
		('Beneficiary', '(D)-Beneficiary/Distributee', 'Defendant'),
		('Def-Driver', '(D)-Operator', 'Defendant'),
		('Potential Client', '(P)-Plaintiff', 'Plaintiff' ),
		('Plaintiff-Driver/Owner', '(P)-Owner/Operator', 'Plaintiff' ),
		('Def-Driver/Owner', '(D)-Owner/Operator', 'Defendant' ),
		('Plaintiff/Driver', '(P)-Operator', 'Plaintiff' ),
		('Defendant', '(D)-Defendant', 'Defendant' ),
		('Driver/Owner', '(P)-Owner/Operator', 'Plaintiff' ),
		('Def-Owner', '(D)-Owner', 'Defendant' ),
		('Parent', '(P)-Guardian', 'Parent' ),
		('Plaintiff', '(P)-Plaintiff', 'Plaintiff' ),
		('Def-Owner #2', '(D)-Owner', 'Defendant'),
		('Administrator', '(P)-Estate Admin.', 'Plaintiff'),
		('Claimant', '(P)-Claimant', 'Plaintiff'),
		('Owner', '(P)-Owner', 'Plaintiff'),
		('Driver', '(P)-Operator', 'Plaintiff')