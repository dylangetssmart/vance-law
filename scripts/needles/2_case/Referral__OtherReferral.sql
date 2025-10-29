use [VanceLawFirm_SA]
go

insert into [sma_TRN_OtherReferral]
	(
		[otrnCaseID],
		[otrnRefContactCtg],
		[otrnRefContactID],
		[otrnRefAddressID],
		[otrnPlaintiffID],
		[otrsComments],
		[otrnUserID],
		[otrdDtCreated]
	)
	select
		cas.casnCaseID as [otrncaseid],
		ioc.CTG		   as [otrnrefcontactctg],
		ioc.CID		   as [otrnrefcontactid],
		ioc.AID		   as [otrnrefaddressid],
		-1			   as [otrnplaintiffid],
		null		   as [otrscomments],
		368			   as [otrnuserid],
		GETDATE()	   as [otrddtcreated]
	--select *
	from [VanceLawFirm_Needles].[dbo].[cases_indexed] c
	join [sma_TRN_cases] cas
		on cas.cassCaseNumber = CONVERT(VARCHAR, c.casenum)
	join [IndvOrgContacts_Indexed] ioc
		on ioc.SAGA = CONVERT(VARCHAR, c.referred_link)
			and c.referred_link > 0
			--where ioc.saga = 50137
			--where c.casenum=214848 