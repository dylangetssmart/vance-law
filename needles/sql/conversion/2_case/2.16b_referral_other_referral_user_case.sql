/* ###################################################################################
Author: Dylan Smith | dylans@smartadvocate.com
Date: 2024-09-12
Description: Create users and contacts

replace:
'OfficeName'
'StateDescription'
'VenderCaseType'
##########################################################################################################################
*/

use [JoelBieberSA_Needles]
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
		cas.casnCaseID				 as [otrncaseid],
		ioc.CTG						 as [otrnrefcontactctg],
		ioc.CID						 as [otrnrefcontactid],
		ioc.AID						 as [otrnrefaddressid],
		-1							 as [otrnplaintiffid],
		'user_case_data.dr_referral' as [otrscomments],
		368							 as [otrnuserid],
		GETDATE()					 as [otrddtcreated]
	from JoelBieberNeedles.dbo.user_case_data ucd
	join sma_TRN_Cases cas
		on CONVERT(VARCHAR, ucd.casenum) = cas.cassCaseNumber
	join sma_MST_IndvContacts indv
		on indv.source_id = ucd.Dr_Referral
			and indv.source_ref = 'Dr_referral'
	join [IndvOrgContacts_Indexed] ioc
		on ioc.cid = indv.cinncontactid
			and ioc.ctg = 1
	where ISNULL(ucd.Dr_Referral, '') <> ''