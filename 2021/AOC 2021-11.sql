USE [AOC];
SET NOCOUNT ON;
GO

DROP TABLE IF EXISTS [#Input];
DROP TABLE IF EXISTS [#Array];
GO

CREATE TABLE [#Input]
(
	[id]		int				NOT NULL	IDENTITY (1,1)
	,[value]	varchar(MAX)
);

CREATE TABLE [#Array]
(
	[row]		int
	,[column]	int
	,[value]	int
);
GO

DECLARE @InputT varchar(MAX) = '
5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526
';

DECLARE @Input varchar(MAX) = '
6744638455
3135745418
4754123271
4224257161
8167186546
2268577674
7177768175
2662255275
4655343376
7852526168
';

INSERT INTO	[#Input] ([value])
SELECT	[value]
FROM	STRING_SPLIT(
			REPLACE(@Input, CHAR(13), '')
			, CHAR(10))
WHERE	[value] <> '';

DECLARE	@row		int	= 1
		,@value		varchar(100)
		,@column	int;

WHILE @row <= (SELECT MAX([id]) FROM [#Input])
BEGIN
	SELECT	@column = 1;

	SELECT	@value = [value]
	FROM	[#Input]
	WHERE	[id] = @row;

	WHILE @column <= LEN(@value)
	BEGIN
		INSERT INTO
				[#Array] ([row], [column], [value])
		SELECT	@row, @column, CAST(SUBSTRING(@value, @column, 1) AS int);

		SELECT	@column += 1;
	END


	SELECT	@row += 1;
END

DECLARE	@step				int	= 0
		,@flashes			int = 0
		,@flashes_thisstep	int
		,@local_rowcount	int;

WHILE @step < 1000
BEGIN
	UPDATE	[#Array]
	SET		[value] += 1
	WHERE	1=1;

	SELECT	@local_rowcount		= -1
			,@flashes_thisstep	= 0;

	WHILE @local_rowcount <> 0
	BEGIN
		UPDATE	[A]
		SET		[value]	= CASE
							WHEN [value] = 0				THEN 0
							WHEN [value] BETWEEN 1 AND 9	THEN [value] + [Near].[Increment]
							WHEN [value] >= 10				THEN 100
							END
		FROM	[#Array] [A]
		CROSS APPLY (	SELECT	[Increment] = COUNT(*)
						FROM	[#Array] [O]
						WHERE	[O].[value]							>= 10
						AND		ABS([O].[row] - [A].[row])			<= 1
						AND		ABS([O].[column] - [A].[column])	<= 1
						AND		NOT ([O].[row] = [A].[row]
								AND [O].[column] = [A].[column])
					) [Near];

		UPDATE	[#Array]
		SET		[value] = 0
		WHERE	[value] = 100;

		SELECT	@local_rowcount = @@ROWCOUNT;

		SELECT	@flashes_thisstep += @local_rowcount;

	END

	SELECT	@flashes	+= @flashes_thisstep
			,@step		+= 1;

	IF @step = 100
		SELECT	[Part 1] = @flashes;

	IF @flashes_thisstep = 100
	BEGIN
		SELECT	[Part 2] = @step;
		BREAK;
	END
END
