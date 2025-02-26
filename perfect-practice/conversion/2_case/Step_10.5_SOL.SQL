

use SAPerfectPracticeEmroch
GO

/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_SOLs] disable trigger all
delete [SAPerfectPracticeEmroch].[dbo].[sma_TRN_SOLs]
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_SOLs]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_SOLs] enable trigger all

alter table [SAPerfectPracticeEmroch].[dbo].[sma_MST_SOLDetails] disable trigger all
delete [SAPerfectPracticeEmroch].[dbo].[sma_MST_SOLDetails]
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_MST_SOLDetails]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_MST_SOLDetails] enable trigger all
*/

---(1)---
insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_SOLDetails]
(
       [sldnSOLTypeID]
      ,[sldnCaseTypeID]
      ,[sldnDefRole]
      ,[sldnStateID]
      ,[sldnYears]
      ,[sldnMonths]
      ,[sldnDays]
      ,[sldnSOLDays]
      ,[sldnRecUserID]
      ,[slddDtCreated]
      ,[sldnModifyUserID]
      ,[slddDtModified]
      ,[sldnLevelNo]
      ,[sldsDorP]
      ,[sldsSOLName]
)
select 
	(select solnSOLTypeID from sma_MST_SOL where solsCode='SOL16') 
						as [sldnSOLTypeID], 
	A.CaseTypeID		as [sldnCaseTypeID],
	A.SubRole			as [sldnDefRole],
	A.StateID			as [sldnStateID],
	2					as [sldnYears],
	0					as [sldnMonths],
	0					as [sldnDays],
	null,
	368					as [sldnRecUserID],
	getdate()			as [slddDtCreated],
	368,
	getdate(),
	null				as [sldnLevelNo],
	'D'					as [sldsDorP],
    (select solsCode from sma_MST_SOL where solsCode='SOL16')	
						as sldsSOLName
from
(
--- Required Admin SOL ---
select distinct 
    CST.cstsCode		   as cstsCode,
    CST.cstnCaseTypeID	   as CaseTypeID,
    D.defnSubRole		   as SubRole,
    CAS.casnStateID		   as StateID
from sma_TRN_Cases CAS
inner join sma_MST_CaseType CST on CST.cstnCaseTypeID=CAS.casnOrgCaseTypeID
inner join sma_TRN_Defendants D on D.defnCaseID=CAS.casnCaseID 
where CST.VenderCaseType='EmrochCaseType'

    except

--- Existing Admin SOL ---
select distinct 
    CST.cstsCode		   as cstsCode,
    SLD.sldnCaseTypeID	   as CaseTypeID,
    SLD.sldnDefRole		   as SubRole,
    SLD.sldnStateID		   as StateID
from sma_MST_CaseType CST
inner join sma_MST_SOLDetails SLD on SLD.sldnCaseTypeID=CST.cstnCaseTypeID
where CST.VenderCaseType='EmrochCaseType'
) A
GO
-----
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_SOLs] disable trigger all
-----

---(2)---
insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_SOLs]
(
	[solnCaseID],
	[solnSOLTypeID],
	[soldSOLDate],
	[soldDateComplied],
	[soldSnCFilingDate],
	[soldServiceDate],
	[solnDefendentID],
	[soldToProcessServerDt],
	[soldRcvdDate],
	[solsType]
)
select distinct
    D.defnCaseID			as [solnCaseID],
    S.sldnSOLDetID			as [solnSOLTypeID],
	try_convert(smalldatetime,E.critdate)				
							as [soldSOLDate],
    null					as [soldDateComplied],
	null					as [soldSnCFilingDate],
    null					as [soldServiceDate],
    D.defnDefendentID		as [solnDefendentID],
    null					as [soldToProcessServerDt],
    null					as [soldRcvdDate],
    'D'						as [solsType]
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS on CAS.saga_entitynum = E.entitynum
inner join [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Defendants] D on D.defnCaseID=CAS.casnCaseID 
inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_SOLDetails] S on S.sldnDefRole=D.defnSubRole and S.sldnStateID=CAS.casnStateID
--left join
--(
--select 
--	EQANSWER.answertext,
--	E.entitynum,
--	ROW_NUMBER() over(partition by E.entitynum order by E.entitynum ) as row_index
--from [PerfectPracticeEmroch].[dbo].[eqanswer_base] EQANSWER
--inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] UCODES_LABEL on UCODES_LABEL.id=EQANSWER.entityrole -- 2102
--inner join [PerfectPracticeEmroch].[dbo].[uqobj_base] UQOBJ on UQOBJ.qlabel=UCODES_LABEL.id and UQOBJ.fieldnum=EQANSWER.fieldnum
--inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=EQANSWER.entitynum  
--where UCODES_LABEL.codeclass='QC' 
--and UQOBJ.labelname='Statute of limitations'
--) SOL on SOL.row_index=1 and SOL.entitynum=E.entitynum

-----
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_SOLs] enable trigger all
-----

----(Appendix)----
update sma_MST_SOLDetails set sldnFromIncident=0 where sldnFromIncident is NULL and sldnRecUserID=368



/*
select SOL.*
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS on CAS.cassCaseNumber = E.entityid
inner join [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Defendants] D on D.defnCaseID=CAS.casnCaseID 
inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_SOLDetails] S on S.sldnDefRole=D.defnSubRole and S.sldnStateID=CAS.casnStateID
left join
(
select 
	EQANSWER.answertext,
	E.entitynum,
	ROW_NUMBER() over(partition by E.entitynum order by E.entitynum ) as row_index
from [PerfectPracticeEmroch].[dbo].[eqanswer_base] EQANSWER
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] UCODES_LABEL on UCODES_LABEL.id=EQANSWER.entityrole -- 2102
inner join [PerfectPracticeEmroch].[dbo].[uqobj_base] UQOBJ on UQOBJ.qlabel=UCODES_LABEL.id and UQOBJ.fieldnum=EQANSWER.fieldnum
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=EQANSWER.entitynum  
where UCODES_LABEL.codeclass='QC' 
and UQOBJ.labelname='Statute of limitations'
) SOL on SOL.row_index=1 and SOL.entitynum=E.entitynum
*/