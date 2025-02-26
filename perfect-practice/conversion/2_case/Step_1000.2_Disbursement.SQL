
use [SAPerfectPracticeEmroch]
GO

/*
alter table [dbo].[sma_TRN_Disbursement] disable trigger all
delete from [dbo].[sma_TRN_Disbursement] 
DBCC CHECKIDENT ('[dbo].[sma_TRN_Disbursement]', RESEED, 0);
alter table [dbo].[sma_TRN_Disbursement] enable trigger all
*/



---(0)---
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_Disbursement'))
begin
    ALTER TABLE [sma_TRN_Disbursement] ADD [saga] varchar(32) NULL; 
end
GO

---(0)---
insert into [dbo].[sma_MST_DisbursmentType] (  dissTypeName )
(
select distinct
	CL.codelabel
FROM [PerfectPracticeEmroch].[dbo].[transactions] T
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=T.entitynum  
left join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=T.actcode
where T.trantype=3 -- Time Cost
and CL.codelabel is not null
)
	except 
select dissTypeName from [dbo].[sma_MST_DisbursmentType] 


insert into [dbo].[sma_MST_CheckRequestStatus] ( [Description] ) 
(
select distinct 
	T.transtatus
FROM [PerfectPracticeEmroch].[dbo].[transactions] T
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=T.entitynum  
where T.trantype=3 -- Time Cost
)
	except
select [Description] from [dbo].[sma_MST_CheckRequestStatus] 


---
alter table [dbo].[sma_TRN_Disbursement] disable trigger all
---
GO
---(1)---
insert into [dbo].[sma_TRN_Disbursement]
(
disnCaseID,
disnPayeeContactCtgID,
disnPayeeContactID,
disnAmount,
disnPlaintiffID,
dissDisbursementType,
UniquePayeeID,
dissDescription,
dissComments,
disnCheckRequestStatus,
disdBillDate,
disdDueDate,
disnRecUserID,
disdDtCreated,
saga
)
select 
	CAS.casnCaseID			as disnCaseID,
    null					as disnPayeeContactCtgID,
    null					as disnPayeeContactID,
    T.amountbilled			as disnAmount,
    (select plnnPlaintiffID from sma_TRN_Plaintiff where plnnCaseID=CAS.casnCaseID and plnbIsPrimary=1) 		
							as disnPlaintiffID,
    (select disnTypeID from [dbo].[sma_MST_DisbursmentType] where dissTypeName=CL.codelabel)
							as dissDisbursementType,
    null					as UniquePayeeID,
    T.transum				as dissDescription,

    isnull('trantext:' + nullif(convert(varchar(max),T.trantext),'') + CHAR(13),'') +
    isnull('rateact:' + nullif(convert(varchar(max),T.rateact),'') + CHAR(13),'') +
    isnull('billrate:' + nullif(convert(varchar(max),T.billrate),'') + CHAR(13),'') +
    ''						as dissComments,
    (select Id FROM [dbo].[sma_MST_CheckRequestStatus] where Description=T.transtatus)	
							as disnCheckRequestStatus,
    try_convert(datetime,T.startdtact)				   
							as disdBillDate,
    null					as disdDueDate,
	null					as disnRecUserID,
    try_convert(datetime,T.dateentered)				   
    						as disdDtCreated,
	'TimeCost:'+convert(varchar,T.id)	as [saga]
FROM [PerfectPracticeEmroch].[dbo].[transactions] T
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=T.entitynum  
inner join [dbo].[sma_TRN_cases] CAS on CAS.cassCaseNumber = E.entityid
left join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=T.actcode
where T.trantype=3 -- Time Cost
GO
---
alter table [dbo].[sma_TRN_Disbursement] enable trigger all
---




