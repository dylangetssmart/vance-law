
use [SAPerfectPracticeEmroch]
GO
/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_SpDamages] disable trigger all
delete [SAPerfectPracticeEmroch].[dbo].[sma_TRN_SpDamages]
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_SpDamages]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_SpDamages] enable trigger all
*/


---(0)---
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_SpDamages'))
begin
    ALTER TABLE [sma_TRN_SpDamages] ADD [saga] [varchar](32) NULL; 
end
GO

---(0)---
insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_SpecialDamageType] ([SpDamageTypeDescription])
select distinct 
	CL_phase.codelabel 
FROM [PerfectPracticeEmroch].[dbo].[transactions] T
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=T.actcode
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL_phase on CL_phase.id=T.phasecode
where CL.[codelabel] = 'Specials'

	except
select [SpDamageTypeDescription] from [SAPerfectPracticeEmroch].[dbo].[sma_MST_SpecialDamageType] 
GO



---(1)---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_SpDamages] disable trigger all
GO
insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_SpDamages]
(
	spdsRefTable,
    spddDamageType,
	spdnBillAmt,
	spdsComments,
	spddPlaintiff,
	spddCaseID,
	spdnRecUserID,
	spddDtCreated,
	spddDateFrom,
	spddDateTo,
	spdsAccntNo,
	spddSubmittedDt,
	spdnLevelNo,
	saga
)

select 
	'CustomDamage'					as spdsRefTable,
	(select SpDamageTypeID from [SAPerfectPracticeEmroch].[dbo].[sma_MST_SpecialDamageType] where [SpDamageTypeDescription]=CL_phase.codelabel) 
									as spddDamageType,
    T.amountact						as spdnBillAmt,
    isnull('transum:' + nullif(convert(varchar(max),T.transum),'') + CHAR(13),'') +
	''								as spdsComments,
    (select plnnPlaintiffID from sma_TRN_Plaintiff where plnnCaseID=CAS.casnCaseID and plnbIsPrimary=1)
									as spddPlaintiff,
    CAS.casnCaseID					as spddCaseID,
    368								as spdnRecUserID,
    getdate()						as spddDtCreated,
    try_convert(smalldatetime,T.startdtact)	as spddDateFrom,
    null							as spddDateTo,
    null							as spdsAccntNo,
    null							as spddSubmittedDt,
    null							as spdnLevelNo,
	T.id							as saga
FROM [PerfectPracticeEmroch].[dbo].[transactions] T
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=T.actcode
left join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL_phase on CL_phase.id=T.phasecode
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.entitynum=T.entitynum  
inner join [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS on CAS.saga_entitynum = E.entitynum
where CL.[codelabel] = 'Specials'
GO

-----------
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_SpDamages] enable trigger all







