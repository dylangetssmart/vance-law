
use [SAPerfectPracticeEmroch]
GO

/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_TaskNew] disable trigger all
delete from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_TaskNew]
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_TaskNew]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_TaskNew] disable trigger all
*/

----(0)----
insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_TaskCategory] (tskCtgDescription)
select distinct
	CL.codelabel
FROM [PerfectPracticeEmroch].[dbo].[transactions] T
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=T.actcode
--where ( CL.codelabel like '%_DUE' or CL.codelabel like 'SOL_%' )
where T.trantype=1 -- To Do
except
select tskCtgDescription from [SAPerfectPracticeEmroch].[dbo].[sma_MST_TaskCategory] 

GO
---(0)---
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_TaskNew'))
begin
    ALTER TABLE [sma_TRN_TaskNew] ADD [saga] varchar(32) NULL;
end
GO

---(1)---
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_TaskNew] disable trigger all
GO

insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_TaskNew]
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
	(
		select U.usrnUserID
		from [PerfectPracticeEmroch].[dbo].[uusers] UU 
		inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_Users] U on U.saga = UU.userid
		where UU.entitynum=T.accompby
	)
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
FROM [PerfectPracticeEmroch].[dbo].[transactions] T
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] CL on CL.id=T.actcode
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=T.entitynum  
inner join [SAPerfectPracticeEmroch].[dbo].[sma_TRN_cases] CAS on CAS.cassCaseNumber = E.entityid
--where [codeclass] in ( '1' )
where T.trantype=1 -- To Do
and try_convert(smalldatetime,T.startdtact)>try_convert(smalldatetime,'2024-03-11')
GO

alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_TaskNew] enable trigger all
																			 
