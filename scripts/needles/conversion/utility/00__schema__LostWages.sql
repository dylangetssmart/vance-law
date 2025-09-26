/*
- create employer records from value.provider > names.names_id
- create special damage records for lost wages
*/

use [VanceLawFirm_SA]
go


/* ------------------------------------------------------------------------------
[sma_TRN_LostWages] Schema
*/

-- saga
if not exists (
		select
			*
		from sys.columns
		where Name = N'saga'
			and object_id = OBJECT_ID(N'sma_TRN_LostWages')
	)
begin
	alter table [sma_TRN_LostWages] add [saga] INT null;
end

go

-- source_id
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and object_id = OBJECT_ID(N'sma_TRN_LostWages')
	)
begin
	alter table [sma_TRN_LostWages] add [source_id] VARCHAR(MAX) null;
end

go

-- source_db
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and object_id = OBJECT_ID(N'sma_TRN_LostWages')
	)
begin
	alter table [sma_TRN_LostWages] add [source_db] VARCHAR(MAX) null;
end

go

-- source_ref
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and object_id = OBJECT_ID(N'sma_TRN_LostWages')
	)
begin
	alter table [sma_TRN_LostWages] add [source_ref] VARCHAR(MAX) null;
end

go