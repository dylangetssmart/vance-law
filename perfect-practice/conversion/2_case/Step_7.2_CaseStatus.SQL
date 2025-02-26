
use SAPerfectPracticeEmroch
GO

/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_CaseStatus] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_CaseStatus]
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_CaseStatus]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_CaseStatus] enable trigger all

select  csssDescription,count(csssDescription)
from sma_MST_CaseStatus 
group by csssDescription
having count(csssDescription) > 1


select * from Status_Helper

*/

---(0)---
insert into sma_MST_CaseStatus ( csssDescription,cssnStatusTypeID )

select 
    A.name,
    (select stpnStatusTypeID from sma_MST_CaseStatusType where stpsStatusType='Status')
from
(
select MAP.[Status in SA] as [name]
from
(
select distinct
    E.thestatus as dscrptn
from [PerfectPracticeEmroch].[dbo].[entities] E
) ENT
inner join 
(
select distinct
	[Status in PP],[Status in SA]
from [PerfectPracticeEmroch].[dbo].[StatusMapping]
) MAP on MAP.[Status in PP]=ENT.dscrptn
where MAP.[Status in SA] not in ( select csssDescription from sma_MST_CaseStatus where cssnStatusTypeID=1 )

    except
select csssDescription as name from sma_MST_CaseStatus
where cssnStatusTypeID = (select stpnStatusTypeID from sma_MST_CaseStatusType where stpsStatusType='Status')
) A

---(0)---
if exists (select * from sys.objects where name='Status_Helper' and type='U')
begin
	drop table Status_Helper
end
GO

select MAP.[Status in PP],MAP.[Status in SA] into Status_Helper
from
(
select distinct
    E.thestatus as dscrptn
from [PerfectPracticeEmroch].[dbo].[entities] E
) ENT
inner join 
(
select distinct
	[Status in PP],[Status in SA]
from [PerfectPracticeEmroch].[dbo].[StatusMapping]
) MAP on MAP.[Status in PP]=ENT.dscrptn
GO

---(1)---
alter table [sma_TRN_CaseStatus] disable trigger all
---------

INSERT INTO [sma_TRN_CaseStatus]
([cssnCaseID],
 [cssnStatusTypeID],
 [cssnStatusID],
 [cssnExpDays],
 [cssdFromDate],
 [cssdToDt],
 [csssComments],
 [cssnRecUserID],
 [cssdDtCreated],
 [cssnModifyUserID],
 [cssdDtModified],
 [cssnLevelNo],
 [cssnDelFlag]
)
select 
    CAS.casnCaseID	as [cssnCaseID],
    (select stpnStatusTypeID from sma_MST_CaseStatusType where stpsStatusType='Status') 
					as [cssnStatusTypeID],
    case
	   when CAS.casdClosingDate between '1900-01-01' and '2079-06-06' 
--		  then (select cssnStatusID,* from sma_MST_CaseStatus where csssDescription='Closed Case')
		  then (select cssnStatusID from sma_MST_CaseStatus where csssDescription='08 Closed Case 02')
	   when exists (select cssnStatusID from sma_MST_CaseStatus where csssDescription=SH.[Status in SA]) 
		  then (select cssnStatusID from sma_MST_CaseStatus where csssDescription=SH.[Status in SA])
	   else 162 -->(select cssnStatusID from sma_MST_CaseStatus where csssDescription='Presign - Not scheduled for Sign Up')
    end				as [cssnStatusID],
    ''				as [cssnExpDays],
    case
	   when CAS.casdClosingDate between '1900-01-01' and '2079-06-06' 
		  then CAS.casdClosingDate 
	   else getdate()
    end				as [cssdFromDate],
    null			as [cssdToDt],
    case
	   when CAS.casdClosingDate between '1900-01-01' and '2079-06-06' 
		  then 'Prior Status : ' + E.thestatus
	   else null
    end				as [csssComments],

    368				as [cssnRecUserID],
    GETDATE()		as [cssdDtCreated],
    null,null,null,null 
from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Cases] CAS
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.entityid=CAS.cassCaseNumber
left join [SAPerfectPracticeEmroch].[dbo].[status_helper] SH on SH.[Status in PP]=E.thestatus 

GO
--------
alter table [sma_TRN_CaseStatus] enable trigger all
--------


---(2)---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Cases] disable trigger all
---------
update CAS set CAS.casnStatusValueID=S.cssnStatusID
from sma_TRN_Cases CAS
left join sma_TRN_CaseStatus S on S.cssnCaseID=CAS.casnCaseID 
where S.cssnStatusTypeID=1 and S.cssdToDt is null
---------
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Cases] enable trigger all
---------










