

use [SAPerfectPracticeEmroch]
GO

/*
alter table [SAPerfectPracticeEmroch].[dbo].[sma_MST_UDFDefinition] disable trigger all
delete [SAPerfectPracticeEmroch].[dbo].[sma_MST_UDFDefinition]
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_MST_UDFDefinition]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_MST_UDFDefinition] enable trigger all

alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_UDFValues] disable trigger all
delete [SAPerfectPracticeEmroch].[dbo].[sma_TRN_UDFValues]
DBCC CHECKIDENT ('[SAPerfectPracticeEmroch].[dbo].[sma_TRN_UDFValues]', RESEED, 0);
alter table [SAPerfectPracticeEmroch].[dbo].[sma_TRN_UDFValues] enable trigger all

select * from [SAPerfectPracticeEmroch].[dbo].[sma_MST_UDFDefinition] 
*/


---(0)--- Performance
--DBCC DBREINDEX('sma_MST_UDFDefinition',' ',90) WITH NO_INFOMSGS 
--DBCC DBREINDEX('sma_TRN_UDFValues',' ',90) WITH NO_INFOMSGS 


alter table sma_MST_UDFDefinition disable trigger all
----
alter table sma_TRN_UDFValues disable trigger all
----


---(1)--- UDF Definition
insert into [SAPerfectPracticeEmroch].[dbo].[sma_MST_UDFDefinition]
(
    [udfsUDFCtg]
    ,[udfnRelatedPK]
    ,[udfsUDFName]
    ,[udfsScreenName]
    ,[udfsType]
    ,[udfsLength]
    ,[udfbIsActive]
    ,[udfnLevelNo]
    ,[udfnSortOrder]
)
select distinct 
    'C'						as [udfsUDFCtg],
    CAS.casnOrgCaseTypeID	as [udfnRelatedPK],
    UQOBJ.labelname			as [udfsUDFName],   
    'Other3'				as [udfsScreenName],
    'Text'					as [udfsType],
    100						as [udfsLength],
    1						as [udfbIsActive],
	convert(int,UQOBJ.fieldnum)	as [udfnLevelNo],
	null					as udfnSortOrder --	row_number() over( order by UQOBJ.labelname) 
from [PerfectPracticeEmroch].[dbo].[eqanswer_base] EQANSWER
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] UCODES_LABEL on UCODES_LABEL.id=EQANSWER.entityrole -- 2102
inner join [PerfectPracticeEmroch].[dbo].[uqobj_base] UQOBJ on UQOBJ.qlabel=UCODES_LABEL.id and UQOBJ.fieldnum=EQANSWER.fieldnum
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=EQANSWER.entitynum  
inner join [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Cases] CAS on CAS.cassCaseNumber=E.entityid
where UCODES_LABEL.codeclass='QC' 
and UCODES_LABEL.codelabel='CLIENTPERSONAL'
order by convert(int,UQOBJ.fieldnum)

GO

insert into [SAPerfectPracticeEmroch].[dbo].[sma_TRN_UDFValues]
(
       [udvnUDFID]
      ,[udvsScreenName]
      ,[udvsUDFCtg]
      ,[udvnRelatedID]
      ,[udvnSubRelatedID]
      ,[udvsUDFValue]
      ,[udvnRecUserID]
      ,[udvdDtCreated]
      ,[udvnModifyUserID]
      ,[udvdDtModified]
      ,[udvnLevelNo]
)
select 
	(select udfnUDFID from [SAPerfectPracticeEmroch].[dbo].[sma_MST_UDFDefinition] 
	   where udfnRelatedPK=CAS.casnOrgCaseTypeID 
	   and udfsUDFName=UQOBJ.labelname 
	   and [udfnLevelNo]=convert(int,UQOBJ.fieldnum)
	   and udfsScreenName='Other3' )
						as [udvnUDFID],
	'Other3'			as [udvsScreenName],
	'C'					as [udvsUDFCtg],
	CAS.casnCaseID		as [udvnRelatedID],
	0					as[udvnSubRelatedID],

    EQANSWER.answertext	   as [udvsUDFValue],

	368				   as [udvnRecUserID],
	getdate()			   as [udvdDtCreated],
	null				   as [udvnModifyUserID],
	null				   as [udvdDtModified],
	null				   as [udvnLevelNo]

from [PerfectPracticeEmroch].[dbo].[eqanswer_base] EQANSWER
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] UCODES_LABEL on UCODES_LABEL.id=EQANSWER.entityrole -- 2102
inner join [PerfectPracticeEmroch].[dbo].[uqobj_base] UQOBJ on UQOBJ.qlabel=UCODES_LABEL.id and UQOBJ.fieldnum=EQANSWER.fieldnum
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=EQANSWER.entitynum  
inner join [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Cases] CAS on CAS.cassCaseNumber=E.entityid
where UCODES_LABEL.codeclass='QC' 
and UCODES_LABEL.codelabel='CLIENTPERSONAL'
GO
---
alter table sma_MST_UDFDefinition enable trigger all
alter table sma_TRN_UDFValues enable trigger all
---

