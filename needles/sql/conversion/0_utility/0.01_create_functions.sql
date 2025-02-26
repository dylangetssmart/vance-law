/**************************************************
 * Functions:
 *	dbo.myvarchar
 *	dbo.get_firstword
 *	dbo.get_lastword
 *	dbo.GetContactCtg
 *	dbo.MoneyToDecimal
 *	dbo.my_smalldatetime
 *	dbo.Integer2Date
 *	dbo.fn_ConvertToDateTime
 *	dbo.LeftWord
 *	dbo.FirstName_FromText
 *	dbo.MiddleName_FromText
 *	dbo.LastName_FromText
 *	dbo.Dworkin_FirstName_FromText
 *	dbo.Dworkin_LastName_FromText
 **************************************************/

USE JoelBieberSA_Needles
GO

-----
ALTER TABLE [sma_MST_OrgContacts] ALTER COLUMN [saga] VARCHAR(100)
GO
ALTER TABLE [sma_MST_IndvContacts] ALTER COLUMN [cinsGrade] VARCHAR(60)
GO

-----

IF OBJECT_ID(N'dbo.myvarchar', N'FN') IS NOT NULL
	DROP FUNCTION myvarchar;
GO
CREATE FUNCTION dbo.myvarchar (@DateParameter VARCHAR(100))
RETURNS VARCHAR(100)
AS

BEGIN
	DECLARE @ret VARCHAR(100);
	SELECT
		@ret = @DateParameter;
	RETURN @ret;
END;
GO


IF OBJECT_ID(N'dbo.get_firstword', N'FN') IS NOT NULL
	DROP FUNCTION get_firstword;
GO
CREATE FUNCTION dbo.get_firstword (@WordParameter VARCHAR(100))
RETURNS VARCHAR(100)
AS

BEGIN
	DECLARE @ret VARCHAR(100);
	SELECT
		@ret = (
			SELECT TOP 1
				data
			FROM dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @WordParameter))), ' ')
			ORDER BY ID ASC
		);
	RETURN @ret;
END;
GO

IF OBJECT_ID(N'dbo.get_lastword', N'FN') IS NOT NULL
	DROP FUNCTION get_lastword;
GO
CREATE FUNCTION dbo.get_lastword (@WordParameter VARCHAR(100))
RETURNS VARCHAR(100)
AS

BEGIN
	DECLARE @ret VARCHAR(100);
	SELECT
		@ret = (
			SELECT TOP 1
				Data
			FROM dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @WordParameter))), ' ')
			ORDER BY ID DESC
		);
	RETURN @ret;
END;
GO


/*
Single word - Organization
Two words - individual FirstName LastName
Three words with the second one as single letter with the period - FirstName M. LastName
Everything else - Organization
*/
IF OBJECT_ID(N'dbo.GetContactCtg', N'FN') IS NOT NULL
	DROP FUNCTION GetContactCtg;
GO
CREATE FUNCTION dbo.GetContactCtg (@name VARCHAR(500))
RETURNS INT
AS
BEGIN
	DECLARE @ret INT;

	DECLARE @wc INT = 0;
	SELECT
		@wc = COUNT(*)
	FROM dbo.split(@name, ' ')

	IF @wc = 1
	BEGIN
		SET @ret = 2;
	END

	IF @wc = 2
	BEGIN
		SET @ret = 1;
	END

	IF @wc = 3
	BEGIN
		IF EXISTS (
				SELECT
					*
				FROM dbo.split(@name, ' ')
				WHERE ID = 2
					AND Data LIKE '_.'
			)
		BEGIN
			SET @ret = 1;
		END
		ELSE
		BEGIN
			SET @ret = 2;
		END
	END

	IF @wc >= 4
	BEGIN
		SET @ret = 2;
	END

	RETURN @ret;
END;
GO

IF OBJECT_ID(N'dbo.MoneyToDecimal', N'FN') IS NOT NULL
	DROP FUNCTION MoneyToDecimal;
GO
CREATE FUNCTION dbo.MoneyToDecimal (@WordParameter VARCHAR(100))
RETURNS DECIMAL(18, 2)
AS
BEGIN
	DECLARE @ret DECIMAL(18, 2);
	IF ISNULL(@WordParameter, '') <> ''
	BEGIN
		SELECT
			@ret = REPLACE(REPLACE(@WordParameter, '$', ''), ',', '')
	END
	ELSE
	BEGIN
		SELECT
			@ret = 0.0
	END
	RETURN @ret;
END;
GO

/*
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
*/

IF OBJECT_ID(N'dbo.my_smalldatetime', N'FN') IS NOT NULL
	DROP FUNCTION my_smalldatetime;
GO
CREATE FUNCTION dbo.my_smalldatetime (@WordParameter VARCHAR(100))
RETURNS SMALLDATETIME
AS

BEGIN
	DECLARE @ret SMALLDATETIME;
	SET @ret = CONVERT(SMALLDATETIME, @WordParameter);
	RETURN @ret;
END
GO


--example:
--select dbo.Integer2DateTime(75293, 75293 ); --2007-02-19 00:13:00
--select dbo.Integer2DateTime(77246, 4254001 ); --2012-06-25 11:49:00
--SELECT dbo.Integer2DateTime(36163,0); --1900-01-01 00:00:00
IF OBJECT_ID(N'dbo.Integer2DateTime', N'FN') IS NOT NULL
	DROP FUNCTION Integer2DateTime;
GO

-- CREATE FUNCTION dbo.Integer2DateTime( @intDate int, @intTime int )
-- RETURNS smalldatetime 
-- AS 

-- BEGIN
-- 	DECLARE @ret smalldatetime;
-- 	DECLARE @date date;
-- 	DECLARE @time time;

-- 	SELECT @date = cast(dateadd(day,@intDate,'1800-12-28') as date)

-- 	SELECT @time = cast(dateadd(second,@intTime/100,'1800-12-28 00:00:00') as time)

-- 	SET @ret= @date + cast(@time as smalldatetime);

--     RETURN @ret;
-- END
CREATE FUNCTION dbo.Integer2DateTime (@intDate INT, @intTime INT)
RETURNS DATETIME
AS
BEGIN
	DECLARE @ret DATETIME;
	DECLARE @date DATETIME;
	DECLARE @time DATETIME;

	-- Convert intDate to date
	SET @date = DATEADD(DAY, @intDate, '1800-12-28')

	-- Convert intTime to time (as smalldatetime)
	SET @time = CAST(DATEADD(SECOND, @intTime / 100, '1800-12-28 00:00:00') AS SMALLDATETIME)

	-- Combine date and time
	SET @ret = DATEADD(DAY, DATEDIFF(DAY, '19000101', @date), @time)

	RETURN @ret;
END
GO

CREATE FUNCTION dbo.Integer2Date (@intDate INT)
RETURNS DATE
AS

BEGIN
	DECLARE @date DATE;

	SELECT
		@date = CAST(DATEADD(DAY, @intDate, '1800-12-28') AS DATE)

	RETURN @date;
END
GO



-- Unix Timestamp:

IF OBJECT_ID(N'dbo.fn_ConvertToDateTime', N'FN') IS NOT NULL
	DROP FUNCTION dbo.fn_ConvertToDateTime;
GO

CREATE FUNCTION dbo.fn_ConvertToDateTime (@Datetime BIGINT)
RETURNS DATETIME
AS
BEGIN
	DECLARE @LocalTimeOffset BIGINT
		   ,@AdjustedLocalDatetime BIGINT;
	SET @LocalTimeOffset = DATEDIFF(SECOND, GETDATE(), GETUTCDATE())
	SET @AdjustedLocalDatetime = @Datetime - @LocalTimeOffset
	RETURN (
		SELECT
			DATEADD(SECOND, @AdjustedLocalDatetime, CAST('1970-01-01 00:00:00' AS DATETIME))
	)
END;

GO
---example:
---select dbo.LeftWord('WE 2013/12/3') -- WE

IF OBJECT_ID(N'dbo.LeftWord', N'FN') IS NOT NULL
	DROP FUNCTION LeftWord;
GO

CREATE FUNCTION dbo.LeftWord (@string VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @Ret VARCHAR(MAX);

	SET @string = RTRIM(LTRIM(@string))

	IF (CHARINDEX(' ', @string) = 0)
	BEGIN
		SET @Ret = @string
	END
	ELSE
	BEGIN
		SET @Ret = LEFT(@string, CHARINDEX(' ', @string) - 1)
	END
	RETURN @Ret
END

GO


---
IF OBJECT_ID(N'dbo.FirstName_FromText', N'FN') IS NOT NULL
	DROP FUNCTION FirstName_FromText;
GO

CREATE FUNCTION dbo.FirstName_FromText (@Str VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS
BEGIN

	DECLARE @Ret VARCHAR(MAX);

	SET @Str = RTRIM(LTRIM(@Str));

	IF CHARINDEX(',', @Str) <> 0
	BEGIN
		SET @Ret = RIGHT(@Str, LEN(@Str) - CHARINDEX(',', @Str));
	END

	ELSE
	BEGIN

		IF (CHARINDEX(' ', @Str) = 0)
		BEGIN
			IF ISDATE(@Str) = 1
			BEGIN
				SET @Ret = NULL;
			END
			ELSE
			BEGIN
				SET @Ret = @Str  -- 1 word
			END
		END
		ELSE
		BEGIN
			SET @Ret = LEFT(@Str, CHARINDEX(' ', @Str) - 1)
		END
	END

	RETURN @Ret;

END

GO


----------------------------
IF OBJECT_ID(N'dbo.LastName_FromText', N'FN') IS NOT NULL
	DROP FUNCTION LastName_FromText;
GO

CREATE FUNCTION dbo.LastName_FromText (@Str VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS
BEGIN

	DECLARE @Ret VARCHAR(MAX);

	SET @Str = RTRIM(LTRIM(@Str));

	IF CHARINDEX(',', @Str) <> 0
	BEGIN
		SET @Ret = LEFT(@Str, CHARINDEX(',', @Str) - 1);
	END

	ELSE
	BEGIN

		IF (CHARINDEX(' ', @Str) = 0)
		BEGIN
			IF ISDATE(@Str) = 1
			BEGIN
				SET @Ret = NULL;
			END
			ELSE
			BEGIN
				SET @Ret = @Str  -- 1 word
			END
		END
		ELSE
		BEGIN
			SET @Ret = RIGHT(@Str, LEN(@Str) - CHARINDEX(' ', @Str))
		END
	END

	RETURN @Ret;

END

GO

------------------
------------------
------------------

IF OBJECT_ID(N'dbo.FirstName_FromText', N'FN') IS NOT NULL
	DROP FUNCTION dbo.FirstName_FromText;
GO

CREATE FUNCTION dbo.FirstName_FromText (@StringParameter VARCHAR(100))
RETURNS VARCHAR(100)
AS
BEGIN

	DECLARE @Result VARCHAR(100) = '';
	DECLARE @WordCount INT;

	IF CHARINDEX(',', @StringParameter) > 0
	BEGIN
		SELECT
			@Result = Data
		FROM dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ',')
		WHERE ID = 2
		RETURN @Result
	END


	IF CHARINDEX('&', @StringParameter) > 0
	BEGIN
		SELECT
			@StringParameter = SUBSTRING(@StringParameter, 0, CHARINDEX('&', @StringParameter))
	END

	SELECT
		@WordCount = COUNT(Data)
	FROM dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ' ')

	IF @WordCount >= 1
	BEGIN
		SELECT
			@Result = Data
		FROM dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ' ')
		WHERE ID = 1
	END

	RETURN @Result;

END

GO

--
IF OBJECT_ID(N'dbo.MiddleName_FromText', N'FN') IS NOT NULL
	DROP FUNCTION dbo.MiddleName_FromText;
GO

CREATE FUNCTION dbo.MiddleName_FromText (@StringParameter VARCHAR(100))
RETURNS VARCHAR(100)
AS
BEGIN

	DECLARE @Result VARCHAR(100) = '';
	DECLARE @WordCount INT;

	IF CHARINDEX('&', @StringParameter) > 0
	BEGIN
		SELECT
			@StringParameter = SUBSTRING(@StringParameter, 0, CHARINDEX('&', @StringParameter))
	END

	SELECT
		@WordCount = COUNT(Data)
	FROM dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ' ')

	IF @WordCount >= 3
	BEGIN
		SELECT
			@Result = Data
		FROM dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ' ')
		WHERE ID = 2
	END
	RETURN @Result;

END

GO

--
IF OBJECT_ID(N'dbo.LastName_FromText', N'FN') IS NOT NULL
	DROP FUNCTION dbo.LastName_FromText;
GO

CREATE FUNCTION dbo.LastName_FromText (@StringParameter VARCHAR(100))
RETURNS VARCHAR(100)
AS
BEGIN

	DECLARE @Marker VARCHAR(100);
	DECLARE @Result VARCHAR(100) = ''
	DECLARE @WordCount INT;

	IF CHARINDEX(',', @StringParameter) > 0
	BEGIN
		SELECT
			@Result = Data
		FROM dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ',')
		WHERE ID = 1
		RETURN @Result
	END

	IF CHARINDEX('&', @StringParameter) > 0
	BEGIN
		SELECT
			@StringParameter = SUBSTRING(@StringParameter, 0, CHARINDEX('&', @StringParameter))
	END


	SELECT
		@WordCount = COUNT(Data)
	FROM dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ' ')

	IF @WordCount > 3
	BEGIN
		SELECT
			@Marker = Data
		FROM dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ' ')
		WHERE ID = 3
		SELECT
			@Result = SUBSTRING(@StringParameter, CHARINDEX(@Marker, @StringParameter), LEN(@StringParameter))
	END
	ELSE
	IF @WordCount = 3
	BEGIN
		SELECT
			@Result = Data
		FROM dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ' ')
		WHERE ID = 3
	END
	ELSE
	BEGIN
		IF @WordCount = 2
		BEGIN
			SELECT
				@Result = Data
			FROM dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ' ')
			WHERE ID = 2
		END
	END
	RETURN @Result

END

GO



------------------

GO

------

IF OBJECT_ID(N'dbo.Dworkin_FirstName_FromText', N'FN') IS NOT NULL
	DROP FUNCTION dbo.Dworkin_FirstName_FromText;
GO

CREATE FUNCTION dbo.Dworkin_FirstName_FromText (@StringParameter VARCHAR(100))
RETURNS VARCHAR(100)
AS
BEGIN

	DECLARE @Result VARCHAR(100) = '';
	DECLARE @WordCount INT;


	IF CHARINDEX('&', @StringParameter) > 0
	BEGIN
		SELECT
			@StringParameter = SUBSTRING(@StringParameter, 0, CHARINDEX('&', @StringParameter))
	END

	SELECT
		@WordCount = COUNT(Data)
	FROM dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ' ')

	IF @WordCount >= 1
	BEGIN
		SELECT
			@Result = Data
		FROM dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ' ')
		WHERE ID = 1
	END

	RETURN @Result;

END

GO

------

IF OBJECT_ID(N'dbo.Dworkin_LastName_FromText', N'FN') IS NOT NULL
	DROP FUNCTION dbo.Dworkin_LastName_FromText;
GO

CREATE FUNCTION dbo.Dworkin_LastName_FromText (@StringParameter VARCHAR(100))
RETURNS VARCHAR(100)
AS
BEGIN

	DECLARE @Marker VARCHAR(100);
	DECLARE @Result VARCHAR(100) = ''
	DECLARE @WordCount INT;


	IF CHARINDEX('&', @StringParameter) > 0
	BEGIN
		SELECT
			@StringParameter = SUBSTRING(@StringParameter, 0, CHARINDEX('&', @StringParameter))
	END


	SELECT
		@WordCount = COUNT(Data)
	FROM dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ' ')

	IF @WordCount >= 2
	BEGIN
		SELECT
			@Marker = Data
		FROM dbo.split(RTRIM(LTRIM(CONVERT(VARCHAR, @StringParameter))), ' ')
		WHERE ID = 2
		SELECT
			@Result = SUBSTRING(@StringParameter, CHARINDEX(@Marker, @StringParameter), LEN(@StringParameter))
	END
	RETURN @Result

END

GO

