
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- populate sma_MST_SiteMaps ---
--drop table sma_MST_SiteMaps_Org2
select * into sma_MST_SiteMaps_Org2 from sma_MST_SiteMaps
--select * into sma_MST_SiteMaps_Org from sma_MST_SiteMaps

truncate table sma_MST_SiteMaps

insert into [dbo].[sma_MST_SiteMaps] ([csmnParentId],[csmsUrl],[csmsTitle],[csmnCaseGroupId],[csmbVisible],[csmnNodeLevel],[csmnNodeId],[csmsUniqueTitle])
select  
      [csmnParentId],[csmsUrl],[csmsTitle],
      -1	as [csmnCaseGroupId], 
	  case
		when csmnParentId is not null then 1
		else 0
      end [csmbVisible],
      [csmnNodeLevel],
	  ROW_NUMBER() over(partition by csmnCaseGroupId order by
		case
			when csmnParentId is not null  then csmnParentId
		   else 999
		end asc,
		case
		   when csmnParentId is not null  then csmnNodeId
		   else 999
		end
	  )			as index_number,  
      [csmsUniqueTitle]
from [dbo].[sma_MST_Sitemaps_Org2] where [csmnCaseGroupId]=-1  


-- loop all groups 
declare @groupid int;
DECLARE OtherContact_cursor CURSOR FOR 


select csmnCaseGroupId --,count(csmnCaseGroupId) 
from [dbo].[sma_MST_SiteMaps_Org2]
where csmnCaseGroupId<>-1
group by csmnCaseGroupId



OPEN OtherContact_cursor 
FETCH NEXT FROM OtherContact_cursor 
INTO @groupid

WHILE @@FETCH_STATUS = 0
BEGIN

insert into [dbo].[sma_MST_SiteMaps] ([csmnParentId],[csmsUrl],[csmsTitle],[csmnCaseGroupId],[csmbVisible],[csmnNodeLevel],[csmnNodeId],[csmsUniqueTitle])

select  
      [csmnParentId],[csmsUrl],[csmsTitle],
      @groupid	as [csmnCaseGroupId], 
	  case
		when csmnParentId is not null then 1
		else 0
      end [csmbVisible],
      [csmnNodeLevel],
	  ROW_NUMBER() over(partition by csmnCaseGroupId order by
		case
			when csmnParentId is not null  then csmnParentId
		   else 999
		end asc,
		case
		   when csmnParentId is not null  then csmnNodeId
		   else 999
		end
	  )			as index_number,  
      [csmsUniqueTitle]
from [dbo].[sma_MST_SiteMaps_Org2] where [csmnCaseGroupId]=0 --@groupid  

FETCH NEXT FROM OtherContact_cursor 
INTO @groupid

END 

CLOSE OtherContact_cursor;
DEALLOCATE OtherContact_cursor;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



