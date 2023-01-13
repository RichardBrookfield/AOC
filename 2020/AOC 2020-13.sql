USE [Richard];

SET NOCOUNT ON;

DECLARE @inputT	varchar(MAX) = '
939
7,13,x,x,59,x,31,19
';

DECLARE @input	varchar(MAX) = '
1000340
13,x,x,x,x,x,x,37,x,x,x,x,x,401,x,x,x,x,x,x,x,x,x,x,x,x,x,17,x,x,x,x,19,x,x,x,23,x,x,x,x,x,29,x,613,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,41
';

DECLARE @inputRaw table
(
	[id]		int				NOT NULL	IDENTITY(1,1)
	,[value]	varchar(300)	NOT NULL
);

DECLARE	@bus table
(
	[id]		int				NOT NULL	IDENTITY(1,1)
	,[bus]		int				NULL
);

DECLARE	@start		int
		,@depart	int
		,@selected	int;

INSERT INTO @inputRaw ([value])
SELECT	[value]
FROM	STRING_SPLIT(REPLACE(@input, CHAR(13), ''), CHAR(10))
WHERE	LEN([value]) > 0;

SELECT	@start = [value]
FROM	@inputRaw
WHERE	[id] = 1;

INSERT INTO @bus
SELECT	[bus]
FROM	@inputRaw [I]
CROSS APPLY (	SELECT	* FROM STRING_SPLIT([I].[value],',')
			) [Split]
CROSS APPLY	(	SELECT [bus] = TRY_CAST([Split].[value] AS int)
			) [Calc]
WHERE	[id] = 2;

SELECT	@depart = @start;

WHILE @depart < @start + 1000
BEGIN
	SELECT	@selected = NULL;

	SELECT TOP (1)
			@selected = [B].[bus]
	FROM	@bus [B]
	CROSS APPLY	(	SELECT [remainder]	= @depart % [B].[bus]
				) [Calc]
	WHERE	[Calc].[remainder]	= 0
	AND		[B].[bus]			IS NOT NULL

	IF @selected IS NOT NULL
	BEGIN
		-- 136
		SELECT	[Part 1] = (@depart - @start) * @selected;
		BREAK;
	END

	SELECT	@depart += 1;
END

-- For part 2, fortunately all the numbers in the examples and puzzle are prime.
-- Therefore each time we include an additional number, we can increase the current
-- solution by the LCM, which is the product of all the numbers.
DECLARE	@t		bigint	= 1
		,@lcm	bigint	= 1
		,@id	int		= 1;

WHILE @id <= (SELECT COUNT(*) FROM @bus)
BEGIN
	SELECT	@selected = [bus]
	FROM	@bus
	WHERE	[id] = @id;

	IF @selected IS NOT NULL
	BEGIN
		WHILE @t % @selected <> @selected - @id % @selected
		BEGIN
			SELECT	@t += @lcm;
		END

		SELECT	@lcm *= @selected;
	END

	SELECT	@id += 1;
END

-- 305068317272992
SELECT	[Part 2] = @t + 1;
