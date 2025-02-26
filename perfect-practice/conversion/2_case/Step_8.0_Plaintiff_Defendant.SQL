
use SAPerfectPracticeEmroch

/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Defendants] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Defendants] 
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_Defendants]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Defendants] enable trigger all

alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Plaintiff] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Plaintiff] 
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_Plaintiff]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Plaintiff] enable trigger all
*/

---(0)---
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga_party' AND Object_ID = Object_ID(N'sma_TRN_Plaintiff'))
begin
    ALTER TABLE [sma_TRN_Plaintiff] ADD [saga_party] int NULL; 
end

if not exists (SELECT * FROM sys.columns WHERE Name = N'saga_party' AND Object_ID = Object_ID(N'sma_TRN_Defendants'))
begin
    ALTER TABLE [sma_TRN_Defendants] ADD [saga_party] int NULL; 
end

---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Plaintiff] disable trigger all
GO
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Defendants] disable trigger all
GO

-------(1) sma_TRN_Plaintiff
insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Plaintiff]
(
 [plnnCaseID],[plnnContactCtg],[plnnContactID],[plnnAddressID],[plnnRole],[plnbIsPrimary],[plnbWCOut],[plnnPartiallySettled],[plnbSettled],[plnbOut],
 [plnbSubOut],[plnnSeatBeltUsed],[plnnCaseValueID],[plnnCaseValueFrom],[plnnCaseValueTo],[plnnPriority],[plnnDisbursmentWt],[plnbDocAttached],[plndFromDt],
 [plndToDt],[plnnRecUserID],[plndDtCreated],[plnnModifyUserID],[plndDtModified],[plnnLevelNo],[plnsMarked],[saga],[plnnNoInj],[plnnMissing],
 [plnnLIPBatchNo],[plnnPlaintiffRole],[plnnPlaintiffGroup],[plnnPrimaryContact],[plnbIsClient],[saga_party]
)
select 
	CAS.casnCaseID				as [plnnCaseID],
	IOC.CTG						as [plnnContactCtg],
	IOC.CID						as [plnnContactID],
	IOC.AID						as [plnnAddressID],
	S.sbrnSubRoleId				as [plnnRole],
	1							as [plnbIsPrimary],
	0,0,0,0,0,0,null,null,null,null,null,null,GETDATE(),null,
	368							as [plnnRecUserID],
	GETDATE()					as [plndDtCreated],
	null,null,
	null						as [plnnLevelNo],  
	null,'',null,null,null,null,null,
	1							as [plnnPrimaryContact],
	1							as [plnbIsClient],
	R.assocnum					as [saga_party]
--select count(*) -- 20753
from [PerfectPracticeEmroch].[dbo].[erelated_base] R 
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.entitynum=R.entitynum and E.casemarker=1
inner join [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Cases] CAS on CAS.cassCaseNumber=E.entityid
inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_SubRole] S on CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID
inner join [SAPerfectPracticeEmroch].[dbo].[IndvOrgContacts_Indexed] IOC on IOC.SAGA = R.assocnum
where S.sbrnRoleID=4 and S.sbrsDscrptn='(P)-Default Role'
and (select codelabel from [PerfectPracticeEmroch].[dbo].[ucodes_label] where id=R.assocrole and codeclass='EPR') = 'CLIENT'
GO

-------(2) [sma_TRN_Defendants]
insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Defendants]
   (
	[defnCaseID],[defnContactCtgID],[defnContactID],[defnAddressID],[defnSubRole],[defbIsPrimary],[defbCounterClaim],[defbThirdParty],
    [defsThirdPartyRole],[defnPriority],[defdFrmDt],[defdToDt],[defnRecUserID],[defdDtCreated],[defnModifyUserID],[defdDtModified],
    [defnLevelNo],[defsMarked],[saga],[defbIsClient],[saga_party]
   )
select 
	casnCaseID				as [defnCaseID],
	IOC.CTG					as [defnContactCtgID],
	IOC.CID					as [defnContactID],
	IOC.AID					as [defnAddressID],
	sbrnSubRoleId			as [defnSubRole],
	1						as [defbIsPrimary], 
	null,null,null,null,null,null,
	368						as [defnRecUserID],
	GETDATE()				as [defdDtCreated],
	null					as [defnModifyUserID],
	null					as [defdDtModified],
     null					as [defnLevelNo],	 
	null,null,
	0						as [defbIsClient],
	R.assocnum				as [saga_party]
--select count(*) -- 17152
from [PerfectPracticeEmroch].[dbo].[erelated_base] R 
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.entitynum=R.entitynum and E.casemarker=1
inner join [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Cases] CAS on CAS.cassCaseNumber=E.entityid
inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_SubRole] S on CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID
inner join [SAPerfectPracticeEmroch].[dbo].[IndvOrgContacts_Indexed] IOC on IOC.SAGA = R.assocnum
where S.sbrnRoleID=5 and S.sbrsDscrptn='(D)-Default Role'
and (select codelabel from [PerfectPracticeEmroch].[dbo].[ucodes_label] where id=R.assocrole and codeclass='EPR') = 'DEFENDANT'

GO


---(Appendix A)-- every case need at least one plaintiff
insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Plaintiff]
(
 [plnnCaseID],[plnnContactCtg],[plnnContactID],[plnnAddressID],[plnnRole],[plnbIsPrimary],[plnbWCOut],[plnnPartiallySettled],[plnbSettled],[plnbOut],
 [plnbSubOut],[plnnSeatBeltUsed],[plnnCaseValueID],[plnnCaseValueFrom],[plnnCaseValueTo],[plnnPriority],[plnnDisbursmentWt],[plnbDocAttached],[plndFromDt],
 [plndToDt],[plnnRecUserID],[plndDtCreated],[plnnModifyUserID],[plndDtModified],[plnnLevelNo],[plnsMarked],[saga],[plnnNoInj],[plnnMissing],
 [plnnLIPBatchNo],[plnnPlaintiffRole],[plnnPlaintiffGroup],[plnnPrimaryContact]
)

select 
	casnCaseID		   as [plnnCaseID],
	1				   as [plnnContactCtg],
	(select cinnContactID 
	from sma_MST_IndvContacts I
	inner join sma_MST_Address A on A.addnContactID=I.cinnContactID and A.addnContactCtgID=I.cinnContactCtg 
	where I.cinsFirstName='unidentified' and I.cinsLastName='plaintiff' and I.saga=-1)
					   as [plnnContactID],   -- Unidentified Plaintiff
	(select A.addnAddressID 
	from sma_MST_IndvContacts I
	inner join sma_MST_Address A on A.addnContactID=I.cinnContactID and A.addnContactCtgID=I.cinnContactCtg 
	where I.cinsFirstName='unidentified' and I.cinsLastName='plaintiff' and I.saga=-1)
					   as [plnnAddressID],
	(select sbrnSubRoleId from sma_MST_SubRole S inner join sma_MST_SubRoleCode C on C.srcnCodeId = S.sbrnTypeCode and C.srcsDscrptn='(P)-Default Role'
	where S.sbrnCaseTypeID=CAS.casnOrgCaseTypeID)	 as plnnRole,
	1				   as [plnbIsPrimary],
	0,0,0,0,0,0,null,null,null,null,null,null,GETDATE(),null,
	368				   as [plnnRecUserID],
	GETDATE()			   as [plndDtCreated],
	null,null,'',null,'',null,null,null,null,null,
	0				   as [plnnPrimaryContact] 
FROM sma_trn_cases CAS
left join [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Plaintiff] T on T.plnnCaseID=CAS.casnCaseID
where plnnCaseID is null
GO

update sma_TRN_Plaintiff set plnbIsPrimary=0

update sma_TRN_Plaintiff set plnbIsPrimary=1
from
(
select distinct 
	   T.plnnCaseID, ROW_NUMBER() OVER (Partition BY T.plnnCaseID order by T.plnnPlaintiffID) as RowNumber,
	   T.plnnPlaintiffID as ID  
    from sma_TRN_Plaintiff T
) A
where A.RowNumber=1
and plnnPlaintiffID = A.ID


---(Appendix B)-- every case need at least one defendant
insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Defendants]
   (
	[defnCaseID],[defnContactCtgID],[defnContactID],[defnAddressID],[defnSubRole],[defbIsPrimary],[defbCounterClaim],[defbThirdParty],
    [defsThirdPartyRole],[defnPriority],[defdFrmDt],[defdToDt],[defnRecUserID],[defdDtCreated],[defnModifyUserID],[defdDtModified],
    [defnLevelNo],[defsMarked],[saga]
   )
select 
	casnCaseID			as [defnCaseID],
	1					as [defnContactCtgID],
	(select cinnContactID 
	from sma_MST_IndvContacts I
	inner join sma_MST_Address A on A.addnContactID=I.cinnContactID and A.addnContactCtgID=I.cinnContactCtg 
	where I.cinsFirstName='unidentified' and I.cinsLastName='defendant' and I.saga=-1)
						as [defnContactID],
	(select A.addnAddressID 
	from sma_MST_IndvContacts I
	inner join sma_MST_Address A on A.addnContactID=I.cinnContactID and A.addnContactCtgID=I.cinnContactCtg 
	where I.cinsFirstName='unidentified' and I.cinsLastName='defendant' and I.saga=-1)
						as [defnAddressID],

	(select sbrnSubRoleId from sma_MST_SubRole S inner join sma_MST_SubRoleCode C on C.srcnCodeId = S.sbrnTypeCode and C.srcsDscrptn='(D)-Default Role' 
	where S.sbrnCaseTypeID=CAS.casnOrgCaseTypeID)	 as [defnSubRole],
	1					as [defbIsPrimary], -- reexamine??
	null,null,null,null,null,null,
	368					as [defnRecUserID],
	GETDATE()		    as [defdDtCreated],
	368					as [defnModifyUserID],
	GETDATE()		    as [defdDtModified],
	null,null,null
FROM sma_trn_cases CAS
left join [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Defendants] D on D.defnCaseID=CAS.casnCaseID
where D.defnCaseID is null
----
update sma_TRN_Defendants set defbIsPrimary=0

update sma_TRN_Defendants set defbIsPrimary=1
from
(
    select distinct 
    D.defnCaseID, 
    ROW_NUMBER() OVER (Partition BY D.defnCaseID order by D.defnDefendentID) as RowNumber,
    D.defnDefendentID as ID  
    from sma_TRN_Defendants D
) A
where A.RowNumber=1
and defnDefendentID = A.ID
GO



---(Appendix C)--- reset primaryContact flag to all plaintiffs
update sma_TRN_Plaintiff set plnnPrimaryContact=0 where plnbIsPrimary=0 
update sma_TRN_Plaintiff set plnnPrimaryContact=1 where plnbIsPrimary=1 


---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Defendants] enable trigger all
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Plaintiff] enable trigger all
---







