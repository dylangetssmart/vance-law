use [BrachEichler_SA]
go

if exists (select * from sys.objects where name = 'CaseTypeMap')
begin
	drop table [dbo].[CaseTypeMap]
end

go

set ansi_nulls on
go

set quoted_identifier on
go

create table [dbo].[CaseTypeMap] (
	[matcode]					  [NVARCHAR](255) null,
	[header]					  [NVARCHAR](255) null,
	[description]				  [NVARCHAR](255) null,
	[SmartAdvocate Case Type]	  [NVARCHAR](255) null,
	[SmartAdvocate Case Sub Type] [NVARCHAR](255) null
) on [PRIMARY]
go


insert into [dbo].[CaseTypeMap]
	(
		[matcode],
		[header],
		[description],
		[SmartAdvocate Case Type],
		[SmartAdvocate Case Sub Type]
	)
	select distinct
		c.matcode,
		m.header						   as header,
		m.description					   as description,
		COALESCE(m.description, c.matcode) as [SmartAdvocate Case Type],
		''								   as [SmartAdvocate Case Sub Type]
	from [BrachEichler_Needles]..cases c
	left join BrachEichler_Needles..matter m
		on m.matcode = c.matcode
	where
		not exists (
		 select
			 1
		 from [dbo].[CaseTypeMap] map
		 where c.matcode = map.matcode
		);
go

---------------------------------------------------------------------------------
-- PLACEHOLDER FOR DATA INSERTION
--
-- To insert your data, uncomment the section below and paste your Excel rows
-- into the VALUES list. Each row must be enclosed in parentheses and comma-separated.
---------------------------------------------------------------------------------

--insert into [dbo].[CaseTypeMap]
--	(
--		[matcode],
--		[header],
--		[description],
--		[SmartAdvocate Case Type],
--		[SmartAdvocate Case Sub Type]
--	)
--	values
--		-- START PASTE HERE: Replace the example row below with your data
--		-- ('CA', 'CA', 'Class Action', 'CA', '')