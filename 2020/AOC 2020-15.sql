USE [Richard];

SET NOCOUNT ON;

DECLARE @input	varchar(100)
		,@limit	int;

-- Part 1 tests
SELECT	@limit	= 2020;

SELECT	@input = '1,3,2';	-- 1
SELECT	@input = '2,1,3';	-- 10
SELECT	@input = '1,2,3';	-- 27
SELECT	@input = '2,3,1';	-- 78
SELECT	@input = '3,2,1';	-- 438
SELECT	@input = '3,1,2';	-- 1836

-- Part 2 tests
SELECT	@limit	= 30000000;

--SELECT	@input = '0,3,6';	-- 175594		Confirmed in about 35 minutes
--SELECT	@input = '1,3,2';	-- 2578
--SELECT	@input = '2,1,3';	-- 3544142
--SELECT	@input = '1,2,3';	-- 261214
--SELECT	@input = '2,3,1';	-- 6895259
--SELECT	@input = '3,2,1';	-- 18
--SELECT	@input = '3,1,2';	-- 362

-- Puzzle
SELECT	@input = '18,8,0,5,4,1,20';

DECLARE @number table
(
	[id]		int	NOT NULL		IDENTITY(1,1) PRIMARY KEY
	,[value]	int	NOT NULL

	,INDEX [xx] NONCLUSTERED ([value])
);

INSERT INTO
		@number ([value])
SELECT	[value]
FROM	STRING_SPLIT(@input, ',');

DECLARE	@i			int
		,@lowValue	int
		,@lowID		int
		,@progress	varchar(20);

SELECT	@i = COUNT(*)
FROM	@number;

WHILE @i < @limit
BEGIN
	INSERT INTO
			@number ([value])
	SELECT	CASE WHEN [N1].[id] IS NULL
				THEN 0
				ELSE [N].[id] - [N1].[id]
				END
	FROM		@number [N]
	OUTER APPLY	(	SELECT TOP (1)
								[id]
					FROM		@number [N1]
					WHERE		[N1].[id]		< [N].[id]
					AND			[N1].[value]	= [N].[value]
					ORDER BY	[N1].[id] DESC
				) [N1]
	WHERE	[N].[id] = @i;

	SELECT	@i += 1;

	IF @i % 100000 = 0
	BEGIN
		SELECT	@progress = CAST(@i/1000 AS varchar(10)) + 'k';
		RAISERROR(@progress, 0, 1) WITH NOWAIT;
	END
END

-- Part 1: 253
-- Part 2: 13710
SELECT	[id], [value]
FROM	@number
WHERE	[id] = @limit;
