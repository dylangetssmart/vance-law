use [VanceLawFirm_SA]
go


---
alter table [sma_TRN_Hospitals] disable trigger all
alter table [sma_TRN_MedicalProviderRequest] disable trigger all
exec AddBreadcrumbsToTable 'sma_trn_MedicalProviderRequest'
go
---


------------------------------------
--MEDICAL PROVIDER HELPER
------------------------------------
if exists (
	 select
		 *
	 from sys.objects
	 where name = 'user_tab2_MedicalProvider_Helper'
		 and type = 'U'
	)
begin
	drop table user_tab2_MedicalProvider_Helper
end

go

---(0)---
create table user_tab2_MedicalProvider_Helper (
	TableIndex	   [INT] identity (1, 1) not null,
	case_id		   INT,
	tab_id		   INT,
	ProviderNameId INT,
	ProviderName   VARCHAR(200),
	ProviderCID	   INT,
	ProviderCTG	   INT,
	ProviderAID	   INT,
	casnCaseID	   INT,
	constraint IOC_Clustered_Index_user_tab2_MedicalProvider_Helper primary key clustered (TableIndex)
) on [PRIMARY]
go

create nonclustered index IX_NonClustered_Index_user_tab2_MedicalProvider_Helper_case_id on [user_tab2_MedicalProvider_Helper] (case_id);
create nonclustered index IX_NonClustered_Index_user_tab2_MedicalProvider_Helper_tab_id on [user_tab2_MedicalProvider_Helper] (tab_id);
create nonclustered index IX_NonClustered_Index_user_tab2_MedicalProvider_Helper_ProviderNameId on [user_tab2_MedicalProvider_Helper] (ProviderNameId);
go

---(0)---
insert into user_tab2_MedicalProvider_Helper
	(
		case_id,
		tab_id,
		ProviderNameId,
		ProviderName,
		ProviderCID,
		ProviderCTG,
		ProviderAID,
		casnCaseID
	)
	select
		D.case_id	   as case_id,
		D.tab_id	   as tab_id,		-- needles records TAB item
		N.[user_name]  as ProviderNameId,
		IOC.[Name]	   as ProviderName,
		IOC.CID		   as ProviderCID,
		IOC.CTG		   as ProviderCTG,
		IOC.AID		   as ProviderAID,
		CAS.casnCaseID as casnCaseID
	from [VanceLawFirm_Needles].[dbo].[user_tab2_data] D
	join [VanceLawFirm_Needles].[dbo].[user_tab2_name] N
		on N.tab_id = D.tab_id
			and N.user_name <> 0
			and N.ref_num = (select top 1 M.ref_num from [VanceLawFirm_Needles].[dbo].[user_tab2_matter] M where M.field_title in ('Provider Name', 'Billing Company', 'Record Provider'))
	join [VanceLawFirm_Needles].[dbo].[user_tab2_name] N2
		on N2.tab_id = D.tab_id
			and N2.user_name <> 0
			and N2.ref_num = (select top 1 M.ref_num from [VanceLawFirm_Needles].[dbo].[user_tab2_matter] M where M.field_title in ('Staff Making Request', 'Billing Company', 'Record Provider'))
	join [IndvOrgContacts_Indexed] IOC
		on IOC.SAGA = N.user_name
	join [sma_TRN_Cases] CAS
		on CAS.cassCaseNumber = D.case_id

go

---(0)---
dbcc dbreindex ('user_tab2_MedicalProvider_Helper', ' ', 90) with no_infomsgs
go




/* ------------------------------------------------------------------------------
RECORD REQUEST TYPES
*/ ------------------------------------------------------------------------------
--select * from sma_MST_Request_RecordTypes

insert into sma_MST_Request_RecordTypes
	(
		RecordType
	)
	(select distinct
		Type_of_Record
	from [VanceLawFirm_Needles].[dbo].[user_tab2_data] D
	where ISNULL(d.Type_of_Record, '') <> ''

	)
	except
	select
		RecordType
	from sma_MST_Request_RecordTypes
	

/* ------------------------------------------------------------------------------
REQUEST STATUS
*/ ------------------------------------------------------------------------------

insert into sma_MST_RequestStatus
	(
		Status,
		Description
	)
	select
		'No Records Available',
		'No Records Available'
	except
	select
		Status,
		Description
	from sma_MST_RequestStatus
go


--------------------------------------------------------------------------
---------------------------- MEDICAL PROVIDERS ---------------------------
--------------------------------------------------------------------------
insert into [sma_TRN_Hospitals]
	(
		[hosnCaseID],
		[hosnContactID],
		[hosnContactCtg],
		[hosnAddressID],
		[hossMedProType],
		[hosdStartDt],
		[hosdEndDt],
		[hosnPlaintiffID],
		[hosnComments],
		[hosnHospitalChart],
		[hosnRecUserID],
		[hosdDtCreated],
		[hosnModifyUserID],
		[hosdDtModified],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select distinct
		casnCaseID												as [hosnCaseID],
		ProviderCID												as [hosnContactID],
		ProviderCTG												as [hosnContactCtg],
		ProviderAID												as [hosnAddressID],
		'M'														as [hossMedProType],			--M or P (P for Prior Medical Provider)
		null													as [hosdStartDt],
		null													as [hosdEndDt],
		(select plnnPlaintiffID from [sma_TRN_Plaintiff] where plnnCaseID = casnCaseID and plnbIsPrimary = 1) as hosnPlaintiffID,
		''														as [hosnComments],
		null													as [hosnHospitalChart],
		368														as [hosnRecUserID],
		GETDATE()												as [hosdDtCreated],
		null													as [hosnModifyUserID],
		null													as [hosdDtModified],
		null													as [saga],
		'user_tab2_data.tab_id = ' + CONVERT(VARCHAR, D.tab_id) as [source_id],
		'needles'												as [source_db],
		'user_tab2_data'										as [source_ref]
	from [VanceLawFirm_Needles].[dbo].[user_tab2_data] D
	join user_tab2_MedicalProvider_Helper MAP
		on MAP.case_id = D.case_id
			and MAP.tab_id = D.tab_id
	left join [sma_TRN_Hospitals] H
		on H.hosnCaseID = MAP.casnCaseID
			and H.hosnContactID = MAP.ProviderCID
			and H.hosnContactCtg = MAP.ProviderCTG
			and H.hosnAddressID = MAP.ProviderAID
	where
		H.hosnHospitalID is null	--only add the hospital if it does not already exist
		and
		(   ISNULL(d.Provider_Name, '') <> ''
			or
			ISNULL(d.Billing_Company, '') <> ''
			or
			ISNULL(d.Record_Provider, '') <> ''
		)



/* ------------------------------------------------------------------------------
Medical Requests

  - [Staff_Making_Request] and [Ordered_By] do not link to name records,
  - so a custom map is used to find the associated [staff] records

*/ ------------------------------------------------------------------------------

IF OBJECT_ID('MedicalRequest_staff_map', 'U') IS NOT NULL
    DROP TABLE MedicalRequest_staff_map;
GO

create table MedicalRequest_staff_map (
    input_string varchar(100),
    staff_code varchar(50),
    full_name varchar(200)
);

insert into MedicalRequest_staff_map (input_string, staff_code, full_name)
values
('mglarrow', 'MATTHEW', 'Matthew Glarrow'),
('qgamble',  'QUEENIE', 'Queenie Gamble'),
('chowe',    'CARSON',  'Carson Howe'),
('DORIS',    'DORIS',   'Doris Billups'),
('lwesson',  'LAUREN',  'Lauren Wesson'),
('bpierce',  'BILLIE',  'Billie Pierce'),
('Michele',  'MICHELE', 'Michele Webb'),
('Stewart',  'STEWART', 'Stewart E. Vance'),
('Kyle',     'KYLE',    'Kyle D. Weidman'),
('Jabeka',   'JABEKA',  'Jabeka Macklin');
go


insert into [sma_trn_MedicalProviderRequest]
	(
		MedPrvCaseID,
		MedPrvPlaintiffID,
		MedPrvhosnHospitalID,
		MedPrvRecordType,
		MedPrvRequestdate,
		MedPrvAssignee,
		MedPrvAssignedBy,
		MedPrvHighPriority,
		MedPrvFromDate,
		MedPrvToDate,
		MedPrvComments,
		MedPrvNotes,
		MedPrvCompleteDate,
		MedPrvStatusId,
		MedPrvFollowUpDate,
		MedPrvStatusDate,
		OrderAffidavit,
		FollowUpNotes,		--Retrieval Provider Notes
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		hosnCaseID							   as MedPrvCaseID,
		hosnPlaintiffID						   as MedPrvPlaintiffID,
		H.hosnHospitalID					   as MedPrvhosnHospitalID,
		(select uId from sma_MST_Request_RecordTypes where RecordType = UD.Type_of_Record) as MedPrvRecordType,
		dbo.ValidDate(ud.Date_Requested)	   as MedPrvRequestdate,
		null								   as MedPrvAssignee,
		COALESCE(
            (
                select u.usrnUserID
                from MedicalRequest_staff_map m
                join sma_mst_users u
                  on u.source_id = m.staff_code
                where m.input_string = UD.Ordered_By
            ),
            (
                select u.usrnUserID
                from MedicalRequest_staff_map m
                join sma_mst_users u
                  on u.source_id = m.staff_code
                where m.input_string = UD.Staff_Making_Request
            )
        ) as MedPrvAssignedBy,												-- Requested By
		0									   as MedPrvHighPriority,		-- 1=high priority; 0=Normal
		dbo.ValidDate(ud.For_Records)		   as MedPrvFromDate,
		dbo.ValidDate(ud.Through)			   as MedPrvToDate,
		CONCAT_WS(CHAR(13),
			NULLIF('Please Order: ' + UD.Please_Order, ''),
			NULLIF('Medicaid: ' + UD.Medicaid, ''),
			NULLIF('No Records Date: ' + CONVERT(VARCHAR, UD.No_Records_Date), ''),
			NULLIF('Method of Request: ' + CONVERT(VARCHAR, UD.Method_of_Request), ''),
			NULLIF('Notes: ' + CONVERT(VARCHAR, UD.Notes), ''),
			NULLIF('Method: ' + CONVERT(VARCHAR, UD.Method), ''),
			NULLIF('No Records Available: ' + CONVERT(VARCHAR, UD.No_Records_Available), '')
		)									   as MedPrvComments,
		CONCAT_WS(CHAR(13),
			NULLIF('Provider Value Code: ' + UD.Provider_Value_Code, ''),
			NULLIF('Billing Co Value Code: ' + UD.Billing_Co_Value_Code, ''),
			NULLIF('Add Provider Value Code: ' + UD.Add_Provider_Value_Code, '')
		)									   as MedPrvNotes,
		dbo.ValidDate(ud.Date_Received)		   as MedPrvCompleteDate,
		case
			when (UD.PrePayment_Required = 'Y')
				then (select uId from [sma_MST_RequestStatus] where [Status] = 'Received')
			when (UD.No_Records_Available = 'Y')
				then (select uId from [sma_MST_RequestStatus] where [Status] = 'No Records Available ')
			else null
		end									   as MedPrvStatusId,
		case
			when dbo.ValidDate(ud.Second_Request) is not null
				then ud.Second_Request
			when dbo.ValidDate(ud.Third_Request) is not null
				then UD.Third_Request
			else null
		end									   as MedPrvFollowUpDate,
		case
			when dbo.ValidDate(UD.Date_Received) is not null
				then (select uId from [sma_MST_RequestStatus] where [Status] = 'Received')
			else null
		end									   as MedPrvStatusDate,
		0									   as OrderAffidavit,
		null								   as FollowUpNotes,	--Retreival Provider Notes
		null								   as [saga],
		'tab2: ' + CONVERT(VARCHAR, UD.tab_id) as [source_id],
		'needles'							   as [source_db],
		'user_tab2_data'					   as [source_ref]
	from [VanceLawFirm_Needles].[dbo].[user_tab2_data] UD
	join VanceLawFirm_Needles.[dbo].[cases] C
		on C.casenum = ud.case_id
	join user_tab2_MedicalProvider_Helper MAP
		on MAP.case_id = UD.case_id
			and MAP.tab_id = UD.tab_id
	join [sma_TRN_Hospitals] H
		on H.hosnContactID = MAP.ProviderCID
			and H.hosnContactCtg = MAP.ProviderCTG
			and H.hosnCaseID = MAP.casnCaseID
			and h.source_id = 'user_tab2_data.tab_id = ' + CONVERT(VARCHAR, UD.tab_id)



	--join VanceLawFirm_Needles..user_tab2_name utn
	--	on utn.tab_id = ud.tab_id
	--		and utn.case_id = ud.case_id
	--		and utn.[user_name] <> 0
	--join VanceLawFirm_Needles..user_tab2_matter utm
	--	on utn.ref_num = utm.ref_num
	--		and utm.mattercode = c.matcode
	--		and utm.field_title = 'Staff Making Request'
	-- join IndvOrgContacts_Indexed ioc
	--	 on ioc.saga = utn.[user_name]



	--join VanceLawFirm_Needles..user_tab2_name utn2
	--	on utn.tab_id = ud.tab_id
	--		and utn.case_id = ud.case_id
	--		and utn.[user_name] <> 0
	--join VanceLawFirm_Needles..user_tab2_matter utm2
	--	on utn.ref_num = utm.ref_num
	--		and utm.mattercode = c.matcode
	--		and utm.field_title = 'Ordered By'
	--join IndvOrgContacts_Indexed ioc2
	--	 on ioc.saga = utn2.[user_name]

go



---
alter table [sma_TRN_Hospitals] enable trigger all
go

alter table [sma_trn_MedicalProviderRequest] enable trigger all
go
---