

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


---(0)--- 
if exists (select * from sys.objects where name='QC_Helper' and type='U')
begin
	drop table QC_Helper
end
GO

CREATE TABLE [dbo].[QC_Helper](
	[order_index] [int] IDENTITY(1,1) NOT NULL,
	[labelname] varchar(max) NULL,
	[fieldnum] varchar(max) NULL
)


insert into QC_Helper (labelname,fieldnum )
select A.labelname,A.fieldnum 
from
(
select 
	UQOBJ.labelname,
	UQOBJ.fieldnum,
ROW_NUMBER() over( partition by	UQOBJ.labelname, UQOBJ.fieldnum order by UQOBJ.id ) as row_index
from [PerfectPracticeEmroch].[dbo].[eqanswer_base] EQANSWER
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] UCODES_LABEL on UCODES_LABEL.id=EQANSWER.entityrole -- 2102
inner join [PerfectPracticeEmroch].[dbo].[uqobj_base] UQOBJ on UQOBJ.qlabel=UCODES_LABEL.id and UQOBJ.fieldnum=EQANSWER.fieldnum
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=EQANSWER.entitynum  
where UCODES_LABEL.codeclass='QC' 
and	UQOBJ.labelname is not null
) A where A.row_index=1
order by A.labelname



--select count(*) from QC_Helper -- 1001

--select * from QC_Helper -- 1001


---(0)--- Performance

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
select 
    'C'						as [udfsUDFCtg],
    CAS.casnOrgCaseTypeID	as [udfnRelatedPK],
    H.labelname				as [udfsUDFName],   
    'Case'					as [udfsScreenName],
    'Text'					as [udfsType],
    100						as [udfsLength],
    1						as [udfbIsActive],
	H.fieldnum				as [udfnLevelNo],
	null					as udfnSortOrder 
from ( select distinct casnOrgCaseTypeID from [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Cases] ) CAS
cross join [SAPerfectPracticeEmroch].[dbo].[QC_Helper] H 
GO

---(1)--- UDF Values
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
	   and [udfnLevelNo]=UQOBJ.fieldnum
	   and udfsScreenName='Case' )
							as [udvnUDFID],
	'Case'					as [udvsScreenName],
	'C'						as [udvsUDFCtg],
	CAS.casnCaseID			as [udvnRelatedID],
	0						as[udvnSubRelatedID],
    EQANSWER.answertext		as [udvsUDFValue],
	368						as [udvnRecUserID],
	getdate()				as [udvdDtCreated],
	null					as [udvnModifyUserID],
	null					as [udvdDtModified],
	null					as [udvnLevelNo]
from [PerfectPracticeEmroch].[dbo].[eqanswer_base] EQANSWER
inner join [PerfectPracticeEmroch].[dbo].[ucodes_label] UCODES_LABEL on UCODES_LABEL.id=EQANSWER.entityrole -- 2102
inner join [PerfectPracticeEmroch].[dbo].[uqobj_base] UQOBJ on UQOBJ.qlabel=UCODES_LABEL.id and UQOBJ.fieldnum=EQANSWER.fieldnum
inner join [PerfectPracticeEmroch].[dbo].[entities] E on E.casemarker=1 and E.entitynum=EQANSWER.entitynum  
inner join [SAPerfectPracticeEmroch].[dbo].[sma_TRN_Cases] CAS on CAS.cassCaseNumber=E.entityid
inner join [SAPerfectPracticeEmroch].[dbo].[QC_Helper] H on H.labelname=UQOBJ.labelname and H.fieldnum=UQOBJ.fieldnum
where UCODES_LABEL.codeclass='QC' 
and EQANSWER.answertext is not null
GO
---
alter table sma_MST_UDFDefinition enable trigger all
alter table sma_TRN_UDFValues enable trigger all
---

