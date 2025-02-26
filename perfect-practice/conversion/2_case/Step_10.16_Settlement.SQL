
use [SAPerfectPracticeEmroch]
GO

/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Settlements] disable trigger all
delete [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Settlements]
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_Settlements]', RESEED, 1);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Settlements] enable trigger all
*/


---(0)---
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_Settlements'))
begin
    ALTER TABLE [sma_TRN_Settlements] ADD [saga] varchar(32) NULL; 
end


----(1)----(  specified items go to settlement rows )
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Settlements] disable trigger all
GO

insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Settlements]
(
    stlnCaseID,
    stlnSetAmt,
    stlnNet,
    stlnNetToClientAmt,
    stlnPlaintiffID,
    stlnStaffID, 
    stlnLessDisbursement,
    stlnGrossAttorneyFee,
    stlnOther,
    stlnForwarder,
    InterestOnDisbursement,
    stlsComments,
    stlTypeID,
	stldSettlementDate,
	saga
)
select 
    CAS.casnCaseID					as stlnCaseID,
    set_amount						as stlnSetAmt,
    null							as stlnNet,
    null							as stlnNetToClientAmt, 
    (select plnnPlaintiffID from sma_TRN_Plaintiff where plnnCaseID=CAS.casnCaseID and plnbIsPrimary=1)					
									as stlnPlaintiffID,
    null							as stlnStaffID, 
    null							as stlnLessDisbursement,
    att_amount						as stlnGrossAttorneyFee,
    null							as stlnOther,
    null							as stlnForwarder,
    null							as InterestOnDisbursement,
    isnull('attorneyname:' + nullif(attorneyname,'') + CHAR(13),'') +
    isnull('att_pct:' + nullif(att_pct,'') + CHAR(13),'') +
    isnull('current_due:' + nullif(current_due,'') + CHAR(13),'') +
	''								as [stlsComments],
	null							as stlTypeID,
    null							as stldSettlementDate,
    E.entitynum						as saga
FROM [PerfectPracticeEmroch].[dbo].[settle] S
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.entitynum=S.matternum and E.casemarker=1
inner join [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Cases] CAS on CAS.saga_entitynum=E.entitynum
GO
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Settlements] enable trigger all


---(2)---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Settlements] disable trigger all
GO
insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Settlements]
(
    stlnCaseID,
    stlnSetAmt,
    stlnNet,
    stlnNetToClientAmt,
    stlnPlaintiffID,
    stlnStaffID, 
    stlnLessDisbursement,
    stlnGrossAttorneyFee,
    stlnOther,
    stlnForwarder,
    InterestOnDisbursement,
    stlsComments,
    stlTypeID,
	stldSettlementDate,
	saga
)
select 
    CAS.casnCaseID					as stlnCaseID,
    try_convert(money,E.party9pct )	as stlnSetAmt,
    null							as stlnNet,
    null							as stlnNetToClientAmt, 
    (select plnnPlaintiffID from sma_TRN_Plaintiff where plnnCaseID=CAS.casnCaseID and plnbIsPrimary=1)					
									as stlnPlaintiffID,
    null							as stlnStaffID, 
    null							as stlnLessDisbursement,
    null							as stlnGrossAttorneyFee,
    null							as stlnOther,
    null							as stlnForwarder,
    null							as InterestOnDisbursement,
	''								as [stlsComments],
	null							as stlTypeID,
    try_convert(smalldatetime,E.party8pct)	as stldSettlementDate,
    'party8:' + E.entitynum			as saga
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS on CAS.saga_entitynum = E.entitynum
where try_convert(smalldatetime,E.party8pct) is not null
GO
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Settlements] enable trigger all






----------------------------------------
---(3)---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Settlements] disable trigger all
GO
insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Settlements]
(
    stlnCaseID,
    stlnSetAmt,
    stlnNet,
    stlnNetToClientAmt,
    stlnPlaintiffID,
    stlnStaffID, 
    stlnLessDisbursement,
    stlnGrossAttorneyFee,
    stlnOther,
    stlnForwarder,
    InterestOnDisbursement,
    stlsComments,
    stlTypeID,
	stldSettlementDate,
	saga
)

select 
    CAS.casnCaseID					as stlnCaseID,
    try_convert(money,E.party9pct )	as stlnSetAmt, --S$: party9pct
    null							as stlnNet,
    null							as stlnNetToClientAmt, 
    (select plnnPlaintiffID from sma_TRN_Plaintiff where plnnCaseID=CAS.casnCaseID and plnbIsPrimary=1)					
									as stlnPlaintiffID,
    null							as stlnStaffID, 
    null							as stlnLessDisbursement,
    null							as stlnGrossAttorneyFee,
    null							as stlnOther,
    null							as stlnForwarder,
    null							as InterestOnDisbursement,
	''								as [stlsComments],
	null							as stlTypeID,
    try_convert(smalldatetime,E.party8pct)	as stldSettlementDate,	--STL: party8pct
    'party8:' + E.entitynum			as saga
--select E.party8pct,E.party9pct
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS on CAS.saga_entitynum = E.entitynum
where try_convert(smalldatetime,E.party8pct) is null
and try_convert(money,E.party9pct ) is not null

alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Settlements] enable trigger all


--select 
--	E.entityid,
--	E.casemarker,
--	E.party8pct	as [STL],
--	E.party9pct	as [S$]
--from [PerfectPracticeEmroch].[dbo].[entities] E
--where E.entityid='04-4575'

