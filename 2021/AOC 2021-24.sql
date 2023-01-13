USE [AOC];
SET NOCOUNT ON;
GO

DROP TABLE IF EXISTS [#Input];

DROP PROCEDURE IF EXISTS [#up_Process]

GO

CREATE TABLE [#Input]
(
	[id]		int		IDENTITY(1,1)
	,[value]	varchar(MAX)
);

GO

CREATE OR ALTER PROCEDURE [#up_Process]
	@input		varchar(20)
--	,@output	int			OUTPUT
AS
BEGIN
	DECLARE	@w			bigint	= 0
			,@x			bigint	= 0
			,@y			bigint	= 0
			,@z			bigint	= 0
			,@line		varchar(100)
			,@op		varchar(10)
			,@register	varchar(1)
			,@argument	varchar(10)
			,@value		bigint
			,@result	bigint
			,@inputPos	int	= 1
			,@i			int	= 1;

	PRINT 'Input: ' + @input;

	WHILE @i <= (SELECT MAX([id]) FROM [#Input])
	BEGIN
		SELECT	@line	= [value]
		FROM	[#Input]
		WHERE	[id]	= @i;

		SELECT	@op			= SUBSTRING(@line, 1, 3)
				,@register	= SUBSTRING(@line, 5, 1);

		SELECT	@argument	= IIF(@op <> 'inp', SUBSTRING(@line, 7, LEN(@line) - 6), '');


		--PRINT @op + '/' + @register + '/' + @argument;

		--PRINT	'  Pre-op    w=' + CAST(@w AS char(3))
		--		+ '  x=' + CAST(@x AS char(12))
		--		+ '  y=' + CAST(@y AS char(3))
		--		+ '  z=' + CAST(@z AS char(30));

		IF @op = 'inp'
		BEGIN
			--PRINT '---';

			--PRINT	'  Pre-inp   w=' + CAST(@w AS char(3))
			--		+ '  x=' + CAST(@x AS char(12))
			--		+ '  y=' + CAST(@y AS char(3))
			--		+ '  z=' + CAST(@z AS char(30));

			SELECT	@value		= CAST(SUBSTRING(@input, @inputPos, 1) AS int);
			SELECT	@inputPos	+= 1;

			IF @register = 'w'
				SELECT	@w = @value;
			ELSE IF @register = 'x'
				SELECT	@x = @value;
			ELSE IF @register = 'y'
				SELECT	@y = @value;
			ELSE IF @register = 'z'
				SELECT	@z = @value;
			ELSE
				SELECT 'Invalid register';

			PRINT	'  Post-inp  w=' + CAST(@w AS char(3))
					+ '  x=' + CAST(@x AS char(12))
					+ '  y=' + CAST(@y AS char(3))
					+ '  z=' + CAST(@z AS char(30));
		END
		ELSE
		BEGIN
			SELECT	@value = CASE @argument
								WHEN 'w' THEN	@w
								WHEN 'x' THEN	@x
								WHEN 'y' THEN	@y
								WHEN 'z' THEN	@z
								ELSE			CAST(@argument AS int)
								END;

			SELECT	@result = CASE @register
								WHEN 'w' THEN	@w
								WHEN 'x' THEN	@x
								WHEN 'y' THEN	@y
								WHEN 'z' THEN	@z
								ELSE			(SELECT 1/0)
								END;

			IF @op = 'add'
				SELECT	@result += @value;
			ELSE IF @op = 'mul'
				SELECT	@result *= @value;
			ELSE IF @op = 'div'
				SELECT	@result /= @value;
			ELSE IF @op = 'mod'
				SELECT	@result = @result % @value;
			ELSE IF @op = 'eql'
				SELECT	@result = IIF(@result = @value, 1, 0);
			ELSE
				SELECT	1/0;
				
			IF @register = 'w'
				SELECT	@w = @result;
			ELSE IF @register = 'x'
				SELECT	@x = @result;
			ELSE IF @register = 'y'
				SELECT	@y = @result;
			ELSE IF @register = 'z'
				SELECT	@z = @result;
		END

		--PRINT	'  Post-op   w=' + CAST(@w AS char(3))
		--		+ '  x=' + CAST(@x AS char(12))
		--		+ '  y=' + CAST(@y AS char(3))
		--		+ '  z=' + CAST(@z AS char(30));

		SELECT	@i += 1;
	END

	PRINT	'END         w=' + CAST(@w AS char(3))
			+ '  x=' + CAST(@x AS char(12))
			+ '  y=' + CAST(@y AS char(3))
			+ '  z=' + CAST(@z AS char(30));

	--SELECT	[w]		= @w
	--		,[x]	= @x
	--		,[y]	= @y
	--		,[z]	= @z;
	IF @z = 0
	PRINT @input + '    ' + IIF(@z = 0, 'YESSSSSS', CAST(@z AS varchar(20)));
END
GO

DECLARE	@inputT varchar(MAX) = '
inp w
mul x 0
add x z
mod x 26
div z 1
add x 13
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 8
mul y x
add z y
';

/*


';

declare @xxx varchar(max) = '



*/

DECLARE	@input varchar(MAX) = '
inp w
mul x 0
add x z
mod x 26
div z 1
add x 13
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 8
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 1
add x 12
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 16
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 1
add x 10
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 4
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 26
add x -11
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 1
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 1
add x 14
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 13
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 1
add x 13
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 5
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 1
add x 12
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 0
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 26
add x -5
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 10
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 1
add x 10
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 7
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 26
add x 0
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 2
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 26
add x -11
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 13
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 26
add x -13
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 15
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 26
add x -13
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 14
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 26
add x -11
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 9
mul y x
add z y
';

INSERT INTO	[#Input] ([value])
SELECT	[value]
FROM	STRING_SPLIT(REPLACE(@Input, CHAR(13), ''), CHAR(10))
WHERE	[value] <> '';





go

--select * from #input

declare	@input	bigint	= 41811961183141
		,@s		varchar(20)
		,@items	int		= 0;

while @items < 1
begin
	select	@s = CAST(@input + @items AS varchar(20));
	if CHARINDEX('0', @s) = 0
	begin
		EXEC [#up_Process] @s;
		print '----------';
	end
	select @items += 1;

	if @items % 100 = 0
	begin
		select	@s = CAST(@items AS varchar(20));
		raiserror(@s,0,0) WITH NOWAIT;
	end
end
