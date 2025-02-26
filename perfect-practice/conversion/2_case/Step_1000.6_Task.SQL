
use [SAPerfectPracticeEmroch]
GO

---(0)---
alter table [dbo].[sma_TRN_TaskNew] disable trigger all
delete [dbo].[sma_TRN_TaskNew] 
from
(
select TS.tskID as ID
from [dbo].[sma_TRN_TaskNew] TS
inner join [PerfectPracticeEmroch].[dbo].[transactions] T on T.id=TS.[saga]
where T.trantype=1 -- To Do
) A where tskID=A.ID
alter table [dbo].[sma_TRN_TaskNew] enable trigger all
GO




---(1)---
alter table [dbo].[sma_TRN_TaskNew] disable trigger all
GO

insert into [dbo].[sma_TRN_TaskNew]
(
       [tskCaseID]
      ,[tskDueDate]
      ,[tskStartDate]
      ,[tskRequestorID]
      ,[tskAssigneeId]
      ,[tskReminderDays]
      ,[tskDescription]
      ,[tskCreatedDt]
      ,[tskCreatedUserID]
      ,[tskMasterID]
      ,[tskCtgID]
      ,[tskSummary]
      ,[tskPriority]
      ,[tskCompleted]
	 ,[saga]
)  
select
    CAS.casnCaseID								as [tskCaseID],
	try_convert(smalldatetime,T.startdtact)		as [tskDueDate],
    try_convert(smalldatetime,T.startdtact)		as [tskStartDate],
    null										as [tskRequestorID],
	(select M.usrnUserID from usermap_helper M where M.entitynum=T.accompby)	
												as [tskAssigneeId],
    null										as [tskReminderDays],
    T.trantext									as [tskDescription],
    null										as [tskCreatedDt],
    null										as tskCreatedUserID,
    (select tskMasterID from sma_mst_Task_Template where tskMasterDetails = 'Custom Task')	
												as [tskMasterID], 
    (select tskCtgID from sma_MST_TaskCategory where tskCtgDescription = CL.codelabel)
												as [tskCtgID], 
    T.trantext									as [tskSummary],  --task subject--
    (select uId from PriorityTypes where PriorityType = 'Normal')							
												as [tskPriority],
	case     
		when T.transtatus='FINISH' then (select StatusID from TaskStatusTypes where StatusType = 'Completed' )					
		when T.transtatus='Open' then (select StatusID from TaskStatusTypes where StatusType = 'Not Started')					
		else (select StatusID from TaskStatusTypes where StatusType = 'Not Started')					
	end											as [tskCompleted], 
    T.id										as [saga]
--select count(*) -- 9149
FROM [PerfectPracticeEmroch].[dbo].[transactions] T
left join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=T.actcode
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=T.entitynum  
inner join [dbo].[sma_TRN_cases] CAS on CAS.cassCaseNumber = E.entityid
where T.trantype=1 -- To Do
and try_convert(smalldatetime,T.startdtact)>try_convert(smalldatetime,'2024-03-11')
GO

alter table [dbo].[sma_TRN_TaskNew] enable trigger all
																			 
