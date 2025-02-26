/* ###################################################################################
description: Handles common operations related to [sma_MST_IndvContacts]
steps:
	- update [sma_TRN_Cases] schema
	- Create [conversion].[office]
	- Insert [sma_mst_offices]
usage_instructions:
	- update values for [conversion].[office]
dependencies:
	- 
notes:
	-
*/


use JoelBieberSA_Needles
go


alter table sma_TRN_Cases
alter column saga INT
go

-- source_id_1
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_id'
			and Object_ID = OBJECT_ID(N'sma_TRN_Cases')
	)
begin
	alter table [sma_TRN_Cases] add [source_id] VARCHAR(max) null;
end
go

-- source_id_2
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_db'
			and Object_ID = OBJECT_ID(N'sma_TRN_Cases')
	)
begin
	alter table [sma_TRN_Cases] add [source_db] VARCHAR(max) null;
end
go

-- source_id_3
if not exists (
		select
			*
		from sys.columns
		where Name = N'source_ref'
			and Object_ID = OBJECT_ID(N'sma_TRN_Cases')
	)
begin
	alter table [sma_TRN_Cases] add [source_ref] VARCHAR(max) null;
end
go



------------------------------------------------------------------------------------------------------
-- [0.0] Temporary table to store variable values
------------------------------------------------------------------------------------------------------
begin

	if OBJECT_ID('conversion.office', 'U') is not null
	begin
		drop table conversion.office
	end

	create table conversion.office (
		OfficeName	   NVARCHAR(255),
		StateName	   NVARCHAR(100),
		PhoneNumber	   NVARCHAR(50),
		CaseGroup	   NVARCHAR(100),
		VenderCaseType NVARCHAR(25)
	);
	insert into conversion.office
		(
		OfficeName,
		StateName,
		PhoneNumber,
		CaseGroup,
		VenderCaseType
		)
values (
'Joel Bieber LLC',
'Virginia',
'8048008000',
'Needles',
'JoelBieberCaseType'
);
end

------------------------------------------------------------------------------------------------------
-- [1.0] Office
------------------------------------------------------------------------------------------------------
begin
	if not exists (
			select
				*
			from [sma_mst_offices]
			where office_name = (
					select
						OfficeName
					from conversion.office 
				)
		)
	begin
		insert into [sma_mst_offices]
			(
			[office_status],
			[office_name],
			[state_id],
			[is_default],
			[date_created],
			[user_created],
			[date_modified],
			[user_modified],
			[Letterhead],
			[UniqueContactId],
			[PhoneNumber]
			)
			select
				1					as [office_status],
				(
					select
						OfficeName
					from conversion.office
				)					as [office_name],
				(
					select
						sttnStateID
					from sma_MST_States
					where sttsDescription = (
							select
								StateName
							from conversion.office
						)
				)					as [state_id],
				1					as [is_default],
				GETDATE()			as [date_created],
				'dsmith'			as [user_created],
				GETDATE()			as [date_modified],
				'dbo'				as [user_modified],
				'LetterheadUt.docx' as [letterhead],
				null				as [uniquecontactid],
				(
					select
						phonenumber
					from conversion.office
				)					as [phonenumber]
	end
end
