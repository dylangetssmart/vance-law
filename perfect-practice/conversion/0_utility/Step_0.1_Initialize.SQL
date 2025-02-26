
use [SAPerfectPracticeEmroch]

-----
delete sma_MST_Sitemaps
where csmnCaseGroupId not in ( select cgpnCaseGroupID from sma_MST_CaseGroup where cgpnCaseGroupID is not null)
and csmnCaseGroupId <> 0
and csmnCaseGroupId <> -1
GO
-----
update sma_MST_OrgContacts set saga=null
update sma_MST_IndvContacts set saga=null
GO
-----
ALTER TABLE [sma_MST_OrgContacts] ALTER COLUMN [saga] varchar(32)
ALTER TABLE [sma_MST_IndvContacts] ALTER COLUMN [saga] varchar(32)
GO
ALTER TABLE [sma_MST_IndvContacts] ALTER COLUMN [cinsGrade] varchar(60)
GO
-----

IF OBJECT_ID (N'dbo.myvarchar', N'FN') IS NOT NULL
    DROP FUNCTION myvarchar;
GO
CREATE FUNCTION dbo.myvarchar(@DateParameter varchar(100) )
RETURNS varchar(100) 
AS 

BEGIN
    DECLARE @ret varchar(100);
	select @ret=@DateParameter;
    RETURN @ret;
END;
GO


IF OBJECT_ID (N'dbo.get_firstword', N'FN') IS NOT NULL
    DROP FUNCTION get_firstword;
GO
CREATE FUNCTION dbo.get_firstword(@WordParameter varchar(100) )
RETURNS varchar(100) 
AS 

BEGIN
    DECLARE @ret varchar(100);
	select @ret=(select top 1 data from dbo.split(RTRIM(LTRIM(convert(varchar,@WordParameter))) ,' ') order by ID  asc);
    RETURN @ret;
END;
GO

IF OBJECT_ID (N'dbo.get_lastword', N'FN') IS NOT NULL
    DROP FUNCTION get_lastword;
GO
CREATE FUNCTION dbo.get_lastword(@WordParameter varchar(100) )
RETURNS varchar(100) 
AS 

BEGIN
    DECLARE @ret varchar(100);
	select @ret=(select top 1 data from dbo.split(RTRIM(LTRIM(convert(varchar,@WordParameter))) ,' ') order by ID  desc);
    RETURN @ret;
END;
GO


/*
Single word - Organization
Two words - individual FirstName LastName
Three words with the second one as single letter with the period - FirstName M. LastName
Everything else - Organization
*/
IF OBJECT_ID (N'dbo.GetContactCtg', N'FN') IS NOT NULL
    DROP FUNCTION GetContactCtg;
GO
CREATE FUNCTION dbo.GetContactCtg(@name varchar(500) )
RETURNS int 
AS 
BEGIN
    DECLARE @ret int;

	declare @wc int=0;
	select @wc=count(*) from dbo.split(@name,' ') 

	if @wc = 1
	begin
		set @ret=2;
	end 

	if @wc = 2
	begin
		set @ret=1;
	end 

	if @wc = 3 
	begin
		if exists (select * from dbo.split(@name,' ') where ID=2 and Data like '_.')
		begin
			set @ret=1;
		end
		else
		begin
			set @ret=2;
		end
	end

	if @wc >= 4 
	begin
		set @ret=2;
	end

    RETURN @ret;
END;
GO

IF OBJECT_ID (N'dbo.MoneyToDecimal', N'FN') IS NOT NULL
    DROP FUNCTION MoneyToDecimal;
GO
CREATE FUNCTION dbo.MoneyToDecimal(@WordParameter varchar(100) )
RETURNS decimal(18,2) 
AS 
BEGIN
    DECLARE @ret decimal(18,2);
	if isnull(@WordParameter,'')<>''
	begin
		select @ret=replace(replace(@WordParameter,'$',''),',','')
	end
	else
	begin
		select @ret=0.0
	end
    RETURN @ret;
END;
GO


IF OBJECT_ID (N'dbo.GetDWorkinContactCtg', N'FN') IS NOT NULL
    DROP FUNCTION GetDWorkinContactCtg;
GO
CREATE FUNCTION dbo.GetDWorkinContactCtg(@name varchar(MAX) )
RETURNS int 
AS 
BEGIN
    DECLARE @ret int;
		
		set @ret=1;
	if exists ( select * from [TimeMattersMcCoy].[lntmu11].[contact] CT where org='O' and full_name=@name)
	begin
		set @ret=2;
	end
    RETURN @ret;
END;
GO


IF OBJECT_ID (N'dbo.my_smalldatetime', N'FN') IS NOT NULL
    DROP FUNCTION my_smalldatetime;
GO
CREATE FUNCTION dbo.my_smalldatetime(@WordParameter varchar(100) )
RETURNS smalldatetime 
AS 

BEGIN
    DECLARE @ret smalldatetime;
	set @ret = convert(smalldatetime,@WordParameter);
    RETURN @ret;
END
GO


--example:
--select dbo.Integer2DateTime(75293, 75293 ); --2007-02-19 00:13:00
--select dbo.Integer2DateTime(77246, 4254001 ); --2012-06-25 11:49:00
--SELECT dbo.Integer2DateTime(36163,0); --1900-01-01 00:00:00
IF OBJECT_ID (N'dbo.Integer2DateTime', N'FN') IS NOT NULL
    DROP FUNCTION Integer2DateTime;
GO

--CREATE FUNCTION dbo.Integer2DateTime( @intDate int, @intTime int )
--RETURNS smalldatetime 
--AS 

--BEGIN
--	declare @ret smalldatetime;
--	declare @date date;
--	declare @time time;

--	select @date = cast(dateadd(day,@intDate,'1800-12-28') as date)

--	select @time = cast(dateadd(second,@intTime/100,'1800-12-28 00:00:00') as time)

--	set @ret= @date + cast(@time as smalldatetime);

--    RETURN @ret;
--END
--GO

--CREATE FUNCTION dbo.Integer2Date( @intDate int)
--RETURNS date 
--AS 

--BEGIN
--	declare @date date;

--	select @date = cast(dateadd(day,@intDate,'1800-12-28') as date)

--    RETURN @date;
--END
--GO



-- Unix Timestamp:

IF OBJECT_ID (N'dbo.fn_ConvertToDateTime', N'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_ConvertToDateTime;
GO

CREATE FUNCTION dbo.fn_ConvertToDateTime (@Datetime BIGINT)
RETURNS DATETIME
AS
BEGIN
    DECLARE @LocalTimeOffset BIGINT
           ,@AdjustedLocalDatetime BIGINT;
    SET @LocalTimeOffset = DATEDIFF(second,GETDATE(),GETUTCDATE())
    SET @AdjustedLocalDatetime = @Datetime - @LocalTimeOffset
    RETURN (SELECT DATEADD(second,@AdjustedLocalDatetime, CAST('1970-01-01 00:00:00' AS datetime)))
END;

GO
---example:
---select dbo.LeftWord('WE 2013/12/3') -- WE

IF OBJECT_ID (N'dbo.LeftWord', N'FN') IS NOT NULL
    DROP FUNCTION LeftWord;
GO

CREATE FUNCTION dbo.LeftWord( @string varchar(MAX) )
RETURNS varchar(MAX) 
AS 
BEGIN
declare @Ret varchar(MAX);

SEt @string=rtrim(ltrim(@string))

IF (CHARINDEX(' ', @string) = 0 ) 
BEGIN
	set @Ret=@string
END
ELSE
BEGIN
	set @Ret=LEFT(@string, CHARINDEX(' ', @string)-1)
END
	return @Ret
END

GO


---
IF OBJECT_ID (N'dbo.FirstName_FromText', N'FN') IS NOT NULL
    DROP FUNCTION FirstName_FromText;
GO

CREATE FUNCTION dbo.FirstName_FromText( @Str varchar(MAX) )
RETURNS varchar(MAX) 
AS 
BEGIN

declare @Ret varchar(MAX);

set  @Str=rtrim(ltrim(@Str));

if CHARINDEX(',', @Str) <> 0
	begin
		set @Ret = right(@Str,len(@Str)-CHARINDEX(',', @Str));
	end  

else
	begin

	if (CHARINDEX(' ', @Str) = 0 ) 
		begin
			if ISDATE(@Str)=1
				begin
					set @Ret=null;
				end
			else
				begin
					set @Ret=@Str  -- 1 word
				end
		end
	else
		begin
			set @Ret=LEFT(@Str, CHARINDEX(' ', @Str)-1)
		end
	end

	return @Ret;

END

GO


----------------------------
IF OBJECT_ID (N'dbo.LastName_FromText', N'FN') IS NOT NULL
    DROP FUNCTION LastName_FromText;
GO

CREATE FUNCTION dbo.LastName_FromText( @Str varchar(MAX) )
RETURNS varchar(MAX) 
AS 
BEGIN

declare @Ret varchar(MAX);

set  @Str=rtrim(ltrim(@Str));

if CHARINDEX(',', @Str) <> 0
	begin
		set @Ret = LEFT(@Str,CHARINDEX(',', @Str)-1);
	end  

else
	begin

	if (CHARINDEX(' ', @Str) = 0 ) 
		begin
			if ISDATE(@Str)=1
				begin
					set @Ret=null;
				end
			else
				begin
					set @Ret=@Str  -- 1 word
				end
		end
	else
		begin
			set @Ret=RIGHT(@Str, LEN(@Str)-CHARINDEX(' ', @Str))
		end
	end

	return @Ret;

END

GO

------------------
------------------
------------------

IF OBJECT_ID (N'dbo.FirstName_FromText', N'FN') IS NOT NULL
    DROP FUNCTION dbo.FirstName_FromText;
GO

CREATE FUNCTION dbo.FirstName_FromText( @StringParameter varchar(100) )
RETURNS varchar(100) 
AS 
BEGIN

	declare @Result varchar(100)='';
     declare @WordCount int;

	--(1)-- 'X,Y' => 'Y'
	if CHARINDEX(',',@StringParameter) > 0
	begin
		select @Result=Data from dbo.split(RTRIM(LTRIM(convert(varchar,@StringParameter))) ,',') WHERE ID=2
		return @Result
	end

	if CHARINDEX('&',@StringParameter) > 0
	begin
		select @StringParameter=substring(@StringParameter,0, CHARINDEX('&',@StringParameter))
	end

	select @WordCount=count(Data) from dbo.split(RTRIM(LTRIM(convert(varchar,@StringParameter))) ,' ') 

	--(2)--'X' => ''		    
	if @WordCount = 1
	begin
		select @Result='';
	end
	--(3)--'X Y Z' => 'X'
	else if @WordCount > 1
	begin
		select @Result=Data from dbo.split(RTRIM(LTRIM(convert(varchar,@StringParameter))) ,' ') WHERE ID=1
	end

	return @Result;
END

GO

--
IF OBJECT_ID (N'dbo.MiddleName_FromText', N'FN') IS NOT NULL
    DROP FUNCTION dbo.MiddleName_FromText;
GO

CREATE FUNCTION dbo.MiddleName_FromText( @StringParameter varchar(100) )
RETURNS varchar(100) 
AS 
BEGIN

	declare @Result varchar(100)='';
    declare @WordCount int;

	if CHARINDEX('&',@StringParameter) > 0
	begin
		select @StringParameter=substring(@StringParameter,0, CHARINDEX('&',@StringParameter))
	end

	select @WordCount=count(Data) from dbo.split(RTRIM(LTRIM(convert(varchar,@StringParameter))) ,' ') 

	if @WordCount >= 3
	begin
		select @Result=Data from dbo.split(RTRIM(LTRIM(convert(varchar,@StringParameter))) ,' ') WHERE ID=2
	end
	return @Result;

END

GO

--
IF OBJECT_ID (N'dbo.LastName_FromText', N'FN') IS NOT NULL
    DROP FUNCTION dbo.LastName_FromText;
GO

CREATE FUNCTION dbo.LastName_FromText( @StringParameter varchar(100) )
RETURNS varchar(100) 
AS 
BEGIN

	declare @Marker varchar(100);
	declare @Result varchar(100)=''
    declare @WordCount int;

	if CHARINDEX(',',@StringParameter) > 0
	begin
		select @Result=Data from dbo.split(RTRIM(LTRIM(convert(varchar,@StringParameter))) ,',') WHERE ID=1
		return @Result
	end

	if CHARINDEX('&',@StringParameter) > 0
	begin
		select @StringParameter=substring(@StringParameter,0, CHARINDEX('&',@StringParameter))
	end


	select @WordCount=count(Data) from dbo.split(RTRIM(LTRIM(convert(varchar,@StringParameter))) ,' ') 

	if @WordCount > 3
	begin
		select @Marker=Data from dbo.split(RTRIM(LTRIM(convert(varchar,@StringParameter))) ,' ') WHERE ID=3
		select @Result=SUBSTRING( @StringParameter ,CHARINDEX ( @Marker,@StringParameter),len(@StringParameter))
	end
	else if @WordCount = 3
	begin
		select @Result=Data from dbo.split(RTRIM(LTRIM(convert(varchar,@StringParameter))) ,' ') WHERE ID=3
	end
	else if @WordCount = 2
	begin
		select @Result=Data from dbo.split(RTRIM(LTRIM(convert(varchar,@StringParameter))) ,' ') WHERE ID=2
	end
	else if @WordCount = 1
	begin
		select @Result=Data from dbo.split(RTRIM(LTRIM(convert(varchar,@StringParameter))) ,' ') WHERE ID=1
	end
	return @Result

END

GO

------------------

GO

------

IF OBJECT_ID (N'dbo.Dworkin_FirstName_FromText', N'FN') IS NOT NULL
    DROP FUNCTION dbo.Dworkin_FirstName_FromText;
GO

CREATE FUNCTION dbo.Dworkin_FirstName_FromText( @StringParameter varchar(100) )
RETURNS varchar(100) 
AS 
BEGIN

	declare @Result varchar(100)='';
    declare @WordCount int;


	if CHARINDEX('&',@StringParameter) > 0
	begin
		select @StringParameter=substring(@StringParameter,0, CHARINDEX('&',@StringParameter))
	end

	select @WordCount=count(Data) from dbo.split(RTRIM(LTRIM(convert(varchar,@StringParameter))) ,' ') 

	if @WordCount >= 1
	begin
		select @Result=Data from dbo.split(RTRIM(LTRIM(convert(varchar,@StringParameter))) ,' ') WHERE ID=1
	end

	return @Result;

END

GO

------

IF OBJECT_ID (N'dbo.Dworkin_LastName_FromText', N'FN') IS NOT NULL
    DROP FUNCTION dbo.Dworkin_LastName_FromText;
GO

CREATE FUNCTION dbo.Dworkin_LastName_FromText( @StringParameter varchar(100) )
RETURNS varchar(100) 
AS 
BEGIN

	declare @Marker varchar(100);
	declare @Result varchar(100)=''
    declare @WordCount int;


	if CHARINDEX('&',@StringParameter) > 0
	begin
		select @StringParameter=substring(@StringParameter,0, CHARINDEX('&',@StringParameter))
	end


	select @WordCount=count(Data) from dbo.split(RTRIM(LTRIM(convert(varchar,@StringParameter))) ,' ') 

	if @WordCount >= 2
	begin
		select @Marker=Data from dbo.split(RTRIM(LTRIM(convert(varchar,@StringParameter))) ,' ') WHERE ID=2
		select @Result=SUBSTRING( @StringParameter ,CHARINDEX ( @Marker,@StringParameter),len(@StringParameter))
	end
	return @Result

END

GO

