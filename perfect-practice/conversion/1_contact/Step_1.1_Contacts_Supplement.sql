
use [SAPerfectPracticeEmroch]

--(1)--
alter table sma_MST_IndvContacts disable trigger all
GO
update sma_MST_IndvContacts set cinsSSNNo=A.answertext
from
(
select
	I.saga as ID,
	EQANSWER.answertext
from [PerfectPracticeEmroch].[dbo].[eqanswer_base] EQANSWER
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] UCODES_LABEL on UCODES_LABEL.id=EQANSWER.entityrole -- 2102
inner join [PerfectPracticeEmroch].[dbo].[uqobj_base] UQOBJ on UQOBJ.qlabel=UCODES_LABEL.id and UQOBJ.fieldnum=EQANSWER.fieldnum
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=EQANSWER.entitynum  
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=E.entitynum and R.assocrole=(select id from [PerfectPracticeEmroch].[dbo].[ucodes_label] where codeclass='EPR' and codelabel='CLIENT')
inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts] I on I.saga=R.assocnum
and UCODES_LABEL.codeclass='QC' 
and UCODES_LABEL.codelabel='CLIENTPERSONAL'
and UQOBJ.labelname='Social Security #'
and EQANSWER.answertext is not null
--and E.entityid='22-15082'
) A
where saga=A.ID
GO
alter table sma_MST_IndvContacts enable trigger all
GO

--(2)--
alter table sma_MST_IndvContacts disable trigger all
GO
update sma_MST_IndvContacts set cindBirthDate=A.answertext
from
(
select
	I.saga as ID,
	try_convert(date,EQANSWER.answertext) as answertext
from [PerfectPracticeEmroch].[dbo].[eqanswer_base] EQANSWER
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] UCODES_LABEL on UCODES_LABEL.id=EQANSWER.entityrole -- 2102
inner join [PerfectPracticeEmroch].[dbo].[uqobj_base] UQOBJ on UQOBJ.qlabel=UCODES_LABEL.id and UQOBJ.fieldnum=EQANSWER.fieldnum
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=EQANSWER.entitynum  
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=E.entitynum and R.assocrole=(select id from [PerfectPracticeEmroch].[dbo].[ucodes_label] where codeclass='EPR' and codelabel='CLIENT')
inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts] I on I.saga=R.assocnum
and UCODES_LABEL.codeclass='QC' 
and UCODES_LABEL.codelabel='CLIENTPERSONAL'
and UQOBJ.labelname='Date of Birth'
and EQANSWER.answertext is not null
) A
where saga=A.ID
GO
alter table sma_MST_IndvContacts enable trigger all


--(3)--
alter table sma_MST_IndvContacts disable trigger all
GO
update sma_MST_IndvContacts set [cinnGender]=A.answertext
from
(
select
	I.saga as ID,
	case 
		when EQANSWER.answertext='M' then 1
		when EQANSWER.answertext='F' then 2
		else 0
	end				as answertext
from [PerfectPracticeEmroch].[dbo].[eqanswer_base] EQANSWER
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] UCODES_LABEL on UCODES_LABEL.id=EQANSWER.entityrole -- 2102
inner join [PerfectPracticeEmroch].[dbo].[uqobj_base] UQOBJ on UQOBJ.qlabel=UCODES_LABEL.id and UQOBJ.fieldnum=EQANSWER.fieldnum
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=EQANSWER.entitynum  
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=E.entitynum and R.assocrole=(select id from [PerfectPracticeEmroch].[dbo].[ucodes_label] where codeclass='EPR' and codelabel='CLIENT')
inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts] I on I.saga=R.assocnum
and UCODES_LABEL.codeclass='QC' 
and UCODES_LABEL.codelabel='CLIENTPERSONAL'
and UQOBJ.labelname='Sex (M,F)'
and EQANSWER.answertext is not null
) A
where saga=A.ID
GO
alter table sma_MST_IndvContacts enable trigger all

--(4)--
alter table sma_MST_IndvContacts disable trigger all
GO
update sma_MST_IndvContacts set cinsSpouse=A.answertext
from
(
select
	I.saga as ID,
	 EQANSWER.answertext
from [PerfectPracticeEmroch].[dbo].[eqanswer_base] EQANSWER
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] UCODES_LABEL on UCODES_LABEL.id=EQANSWER.entityrole -- 2102
inner join [PerfectPracticeEmroch].[dbo].[uqobj_base] UQOBJ on UQOBJ.qlabel=UCODES_LABEL.id and UQOBJ.fieldnum=EQANSWER.fieldnum
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=EQANSWER.entitynum  
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=E.entitynum and R.assocrole=(select id from [PerfectPracticeEmroch].[dbo].[ucodes_label] where codeclass='EPR' and codelabel='CLIENT')
inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts] I on I.saga=R.assocnum
and UCODES_LABEL.codeclass='QC' 
and UCODES_LABEL.codelabel='CLIENTPERSONAL'
and UQOBJ.labelname='Spouse''s name'
and EQANSWER.answertext is not null
) A
where saga=A.ID
GO
alter table sma_MST_IndvContacts enable trigger all

--(5)--
alter table sma_MST_IndvContacts disable trigger all
GO
update sma_MST_IndvContacts set cinnMaritalStatusID=A.answertext
from
(
select
	I.saga as ID,
	case
		when EQANSWER.answertext='MAR' then (select mtsnMaritalStatusID from sma_MST_MaritalStatus where mtssDscrptn='Married')
		when EQANSWER.answertext='M'   then (select mtsnMaritalStatusID from sma_MST_MaritalStatus where mtssDscrptn='Married')
		when EQANSWER.answertext='SIN' then (select mtsnMaritalStatusID from sma_MST_MaritalStatus where mtssDscrptn='Single')
		when EQANSWER.answertext='S'   then (select mtsnMaritalStatusID from sma_MST_MaritalStatus where mtssDscrptn='Single')
		when EQANSWER.answertext='WID' then (select mtsnMaritalStatusID from sma_MST_MaritalStatus where mtssDscrptn='Widowed')
		when EQANSWER.answertext='DIV' then (select mtsnMaritalStatusID from sma_MST_MaritalStatus where mtssDscrptn='Divorced')
		when EQANSWER.answertext='SEP' then (select mtsnMaritalStatusID from sma_MST_MaritalStatus where mtssDscrptn='Separated')
		else (select mtsnMaritalStatusID from sma_MST_MaritalStatus where mtssDscrptn='Other')
	end as answertext
from [PerfectPracticeEmroch].[dbo].[eqanswer_base] EQANSWER
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] UCODES_LABEL on UCODES_LABEL.id=EQANSWER.entityrole -- 2102
inner join [PerfectPracticeEmroch].[dbo].[uqobj_base] UQOBJ on UQOBJ.qlabel=UCODES_LABEL.id and UQOBJ.fieldnum=EQANSWER.fieldnum
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=EQANSWER.entitynum  
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=E.entitynum and R.assocrole=(select id from [PerfectPracticeEmroch].[dbo].[ucodes_label] where codeclass='EPR' and codelabel='CLIENT')
inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts] I on I.saga=R.assocnum
and UCODES_LABEL.codeclass='QC' 
and UCODES_LABEL.codelabel='CLIENTPERSONAL'
and UQOBJ.labelname='Marital Status (S,M,D)'
and EQANSWER.answertext is not null
) A
where saga=A.ID
GO
alter table sma_MST_IndvContacts enable trigger all
GO

--(from admin 1)--
alter table sma_MST_IndvContacts disable trigger all
GO
update sma_MST_IndvContacts set cinsSSNNo=A.SSN
from
(
select
	 I.saga as ID,
	 EQANSWER.answertext,
	 E.closednum		as [SSN]
from [PerfectPracticeEmroch].[dbo].[eqanswer_base] EQANSWER
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] UCODES_LABEL on UCODES_LABEL.id=EQANSWER.entityrole -- 2102
inner join [PerfectPracticeEmroch].[dbo].[uqobj_base] UQOBJ on UQOBJ.qlabel=UCODES_LABEL.id and UQOBJ.fieldnum=EQANSWER.fieldnum
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=EQANSWER.entitynum  
inner join [PerfectPracticeEmroch].[dbo].[erelated_base] R on R.entitynum=E.entitynum and R.assocrole=(select id from [PerfectPracticeEmroch].[dbo].[ucodes_label] where codeclass='EPR' and codelabel='CLIENT')
inner join [SAPerfectPracticeEmroch].[dbo].[sma_MST_IndvContacts] I on I.saga=R.assocnum
and UCODES_LABEL.codeclass='QC' 
and UCODES_LABEL.codelabel='CLIENTPERSONAL'
and UQOBJ.labelname='Social Security #'
and EQANSWER.answertext is null
) A
where saga=A.ID
GO
alter table sma_MST_IndvContacts enable trigger all
GO









