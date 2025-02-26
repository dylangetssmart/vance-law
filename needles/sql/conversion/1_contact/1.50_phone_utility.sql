/* ###################################################################################
description: Update contact phone numbers
steps:
	- [sma_MST_ContactNoType]
usage_instructions:
	-
dependencies:
	- 
notes:
	-
######################################################################################
*/

use JoelBieberSA_Needles
go

-- 
insert into sma_MST_ContactNoType
	(
	ctysDscrptn,
	ctynContactCategoryID,
	ctysDefaultTexting
	)
	select
		'Work Phone',
		1,
		0
	union
	select
		'Work Fax',
		1,
		0
	union
	select
		'Cell Phone',
		1,
		0
	except
	select
		ctysDscrptn,
		ctynContactCategoryID,
		ctysDefaultTexting
	from sma_MST_ContactNoType

--
if OBJECT_ID(N'dbo.FormatPhone', N'FN') is not null
	drop function FormatPhone;
go

create function dbo.FormatPhone (@phone VARCHAR(MAX))
returns VARCHAR(MAX)
as
begin
	if LEN(@phone) = 10
		and ISNUMERIC(@phone) = 1
	begin
		return '(' + SUBSTRING(@phone, 1, 3) + ') ' + SUBSTRING(@phone, 4, 3) + '-' + SUBSTRING(@phone, 7, 4) ---> this is good for perecman
	end
	return @phone;
end;
go



---------------------------------------------------
-- [sma_MST_ContactNumbers] schema
---------------------------------------------------

--alter table sma_MST_ContactNumbers
--alter column saga int
--go

-- saga
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and Object_ID = OBJECT_ID(N'sma_MST_ContactNumbers')
	)
begin
	alter table [sma_MST_ContactNumbers] add [saga] INT null;
end
go

-- source_id
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and Object_ID = OBJECT_ID(N'sma_MST_ContactNumbers')
	)
begin
	alter table [sma_MST_ContactNumbers] add [source_id] VARCHAR(MAX) null;
end
go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and Object_ID = OBJECT_ID(N'sma_MST_ContactNumbers')
	)
begin
	alter table [sma_MST_ContactNumbers] add [source_db] VARCHAR(MAX) null;
end
go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and Object_ID = OBJECT_ID(N'sma_MST_ContactNumbers')
	)
begin
	alter table [sma_MST_ContactNumbers] add [source_ref] VARCHAR(MAX) null;
end
go
