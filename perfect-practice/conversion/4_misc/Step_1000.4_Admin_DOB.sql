
use [SAPerfectPracticeEmroch]

--(1)--
alter table sma_MST_IndvContacts disable trigger all
GO

update sma_MST_IndvContacts set cinsSSNNo=A.SSN
from
(
select 
	I.cinnContactID							as ID,
	I.cinsSSNNo,
	I.cindBirthDate,
	try_convert(varchar(100),E.closednum)	as SSN,
	try_convert(datetime,E.initials)		as DOB
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=E.entitynum and R.assocrole=(select id from [PerfectPracticeEmroch].[dbo].[ucodes_label] where codeclass='EPR' and codelabel='CLIENT')
inner join [dbo].[sma_MST_IndvContacts] I on I.saga=R.assocnum
where E.casemarker=1
) A
where ( isnull(A.cinsSSNNo,'')='' and A.SSN is not null )
and cinnContactID=A.ID

alter table sma_MST_IndvContacts enable trigger all


--(2)--
alter table sma_MST_IndvContacts disable trigger all
GO

update sma_MST_IndvContacts set cindBirthDate=A.DOB
from
(
select 
	I.cinnContactID							as ID,
	I.cinsSSNNo,
	I.cindBirthDate,
	try_convert(varchar(100),E.closednum)	as SSN,
	try_convert(datetime,E.initials)		as DOB
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=E.entitynum and R.assocrole=(select id from [PerfectPracticeEmroch].[dbo].[ucodes_label] where codeclass='EPR' and codelabel='CLIENT')
inner join [dbo].[sma_MST_IndvContacts] I on I.saga=R.assocnum
where E.casemarker=1
) A
where ( isnull(A.cindBirthDate,'')='' and A.DOB is not null )
and cinnContactID=A.ID

alter table sma_MST_IndvContacts enable trigger all

--------------------


select 
E.entityid,count(E.entityid)	
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=E.entitynum and R.assocrole=(select id from [PerfectPracticeEmroch].[dbo].[ucodes_label] where codeclass='EPR' and codelabel='CLIENT')
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum
group by E.entityid
having count(E.entityid) > 1



select
	ER.*
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=E.entitynum and R.assocrole=(select id from [PerfectPracticeEmroch].[dbo].[ucodes_label] where codeclass='EPR' and codelabel='CLIENT')
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum
where E.entityid='00-0665'



select
	E.*,
	ER.*
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=E.entitynum and R.assocrole=(select id from [PerfectPracticeEmroch].[dbo].[ucodes_label] where codeclass='EPR' and codelabel='CLIENT')
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum
where E.entityid='08-7257'

id		entitynum	entityrole	entityrole_id	casemarker	entityid
154280	154280		CLIENT		996				0			087257


select
	count(*) -- 2984
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=E.entitynum and R.assocrole=(select id from [PerfectPracticeEmroch].[dbo].[ucodes_label] where codeclass='EPR' and codelabel='CLIENT')
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum and ER.lastname=E.lastname and ER.firstname=E.firstname and ER.middlename=E.middlename and ER.refname=E.refname 
--where E.entityid='08-7257'


select count(*) -- 11099
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=E.entitynum and R.assocrole=(select id from [PerfectPracticeEmroch].[dbo].[ucodes_label] where codeclass='EPR' and codelabel='CLIENT')
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum and ER.entityid=replace(E.entityid,'-','') 
and E.casemarker=1
--where E.entityid='08-7257'



select E.entityid
from [PerfectPracticeEmroch].[dbo].[entities] E
where E.casemarker=1
	
	intersect

select E.entityid
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=E.entitynum and R.assocrole=(select id from [PerfectPracticeEmroch].[dbo].[ucodes_label] where codeclass='EPR' and codelabel='CLIENT')
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum and ER.entityid=replace(E.entityid,'-','') 
where E.casemarker=1



select
	E.id,E.entitynum,E.entityid,
	ER.id,ER.entitynum,ER.entityid
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=E.entitynum and R.assocrole=(select id from [PerfectPracticeEmroch].[dbo].[ucodes_label] where codeclass='EPR' and codelabel='CLIENT')
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum
where E.casemarker=1
and E.entityid='00-0658'




---primary client----
select count(*) -- 19798
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [PerfectPracticeEmroch].[dbo].[entities] CE on CE.entityid=replace(E.entityid,E.entitynum,'') and CE.casemarker<>1
where E.casemarker=1

select  
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [PerfectPracticeEmroch].[dbo].[entities] CE on CE.entityid=replace(E.entityid,E.entitynum,'') 
where E.casemarker=1
and E.entityid='08-7257'





select count(*) -- 11099
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=E.entitynum and R.assocrole=(select id from [PerfectPracticeEmroch].[dbo].[ucodes_label] where codeclass='EPR' and codelabel='CLIENT')
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum and ER.entityid=replace(E.entityid,'-','') 
where E.casemarker=1



select count(*) -- 11099
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on 
	E.casemarker=1 and
	R.entitynum=E.entitynum and 
	R.assocrole=(select id from [PerfectPracticeEmroch].[dbo].[ucodes_label] where codeclass='EPR' and codelabel='CLIENT')
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum and ER.entityid=replace(E.entityid,'-','') 


----Primary Client contacts --- 11099
select 
	E.firstname,E.lastname,
	ER.firstname,ER.lastname
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on 
	E.casemarker=1 and
	R.entitynum=E.entitynum and 
	R.assocrole=(select id from [PerfectPracticeEmroch].[dbo].[ucodes_label] where codeclass='EPR' and codelabel='CLIENT')
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum and ER.entityid=replace(E.entityid,'-','') 


--- multiple client
select 
	E.entitynum,count(E.entitynum)
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on 
	E.casemarker=1 and
	R.entitynum=E.entitynum and 
	R.assocrole=(select id from [PerfectPracticeEmroch].[dbo].[ucodes_label] where codeclass='EPR' and codelabel='CLIENT')
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum --and ER.entityid=replace(E.entityid,'-','') 
group by E.entitynum
having count(E.entitynum) > 1
order by E.entitynum



select 
	R.*
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on 
	E.casemarker=1 and
	R.entitynum=E.entitynum and 
	R.assocrole=(select id from [PerfectPracticeEmroch].[dbo].[ucodes_label] where codeclass='EPR' and codelabel='CLIENT')
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum --and ER.entityid=replace(E.entityid,'-','') 
where E.entitynum='122038'


select 
	E.entitynum,E.entityid,	
	ER.firstname,ER.lastname,ER.refname,ER.entityid
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on 
	E.casemarker=1 and
	R.entitynum=E.entitynum and 
	R.assocrole=(select id from [PerfectPracticeEmroch].[dbo].[ucodes_label] where codeclass='EPR' and codelabel='CLIENT')
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum --and ER.entityid=replace(E.entityid,'-','') 
where E.entitynum='121940'


select 
	E.entitynum,E.entityid,	
	ER.firstname,ER.lastname,ER.refname,ER.entityid
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on 
	E.casemarker=1 and
	R.entitynum=E.entitynum and 
	R.assocrole=(select id from [PerfectPracticeEmroch].[dbo].[ucodes_label] where codeclass='EPR' and codelabel='CLIENT')
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum --and ER.entityid=replace(E.entityid,'-','') 
where E.entitynum='121940'


select count(*) -- 18426
from
(
select 
	case
		when charindex('-',E.entityid)> 0 then replace(E.entityid,'-','')
		else replace(E.entityid,E.entitynum,'')
	end		as tryit
from [PerfectPracticeEmroch].[dbo].[entities] E
where E.casemarker=1 
) A
inner join [PerfectPracticeEmroch].[dbo].[entities] CE on CE.entityid=A.tryit and CE.casemarker<>1



---- Primary Client ----
select count(*) -- 18426
from
(
select 
	case
		when charindex('-',E.entityid)> 0 then replace(E.entityid,'-','')
		else replace(E.entityid,E.entitynum,'')
	end		as tryit
from [PerfectPracticeEmroch].[dbo].[entities] E
where E.casemarker=1 
) A
inner join [PerfectPracticeEmroch].[dbo].[entities] CE on CE.entityid=A.tryit and CE.casemarker<>1


---- Primary Client ---- ( Test )
select 
	A.entityid,A.casemarker, A.firstname,A.lastname,
	CE.entityid,CE.casemarker, CE.firstname,CE.lastname
from
(
select 
	E.*,
	case
		when charindex('-',E.entityid)> 0 then replace(E.entityid,'-','')
		else replace(E.entityid,E.entitynum,'')
	end		as tryit
from [PerfectPracticeEmroch].[dbo].[entities] E
where E.casemarker=1 
) A
inner join [PerfectPracticeEmroch].[dbo].[entities] CE on CE.entityid=A.tryit and CE.casemarker<>1





--- non-primary clients
select ER.entitynum
from [PerfectPracticeEmroch].[dbo].[entities] E
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on 
	E.casemarker=1 and
	R.entitynum=E.entitynum and 
	R.assocrole=(select id from [PerfectPracticeEmroch].[dbo].[ucodes_label] where codeclass='EPR' and codelabel='CLIENT')
inner join [PerfectPracticeEmroch].[dbo].[entities] ER on ER.entitynum=R.assocnum 
	except
(
	select  
		CE.entitynum
	from
	(
	select 
		case
			when charindex('-',E.entityid)> 0 then replace(E.entityid,'-','')
			else replace(E.entityid,E.entitynum,'')
		end		as tryit
	from [PerfectPracticeEmroch].[dbo].[entities] E
	where E.casemarker=1 
	) A
	inner join [PerfectPracticeEmroch].[dbo].[entities] CE on CE.entityid=A.tryit and CE.casemarker<>1
)





