USE [AOC];
SET NOCOUNT ON;
GO

DROP TABLE IF EXISTS [#Input];
DROP TABLE IF EXISTS [#Throw];
DROP TABLE IF EXISTS [#Progress];

GO

CREATE TABLE [#Input]
(
	[id]		int		IDENTITY(1,1)
	,[value]	varchar(MAX)
);

CREATE TABLE [#Throw]
(
	[score]			int
	,[occurrences]	int
);

CREATE TABLE [#Progress]
(
	[level]			int
	,[position1]	int
	,[score1]		int
	,[position2]	int
	,[score2]		int
	,[winner]		int
	,[occurrences]	bigint
);

GO

DECLARE	@inputT	varchar(MAX) = '
Player 1 starting position: 4
Player 2 starting position: 8
';

DECLARE	@input	varchar(MAX) = '
Player 1 starting position: 5
Player 2 starting position: 10
';

INSERT INTO	[#Input] ([value])
SELECT	[value]
FROM	STRING_SPLIT(REPLACE(@Input, CHAR(13), ''), CHAR(10))
WHERE	[value] <> '';

DECLARE	@Score1		int	= 0
		,@Score2	int	= 0
		,@Start1	int
		,@Start2	int
		,@Position1	int
		,@Position2	int
		,@i			int	= 1
		,@line		varchar(100)
		,@value		int
		,@pos		int;

WHILE @i <= 2
BEGIN
	SELECT	@line = [value]
	FROM	[#Input]
	WHERE	[id]	= @i;

	SELECT	@pos	= CHARINDEX('position: ', @line);

	SELECT	@value	= CAST(RIGHT(@line, LEN(@line) - @pos - 9) AS int);

	IF @i = 1
		SELECT	@Start1	= @value;
	ELSE
		SELECT	@Start2	= @value;

	SELECT	@i += 1;
END

DECLARE	@die		int	= 1
		,@round		int	= 0
		,@score		int;

SELECT	@Position1	= @Start1
		,@Position2	= @Start2;

WHILE @Score1 < 1000 AND @Score2 < 1000
BEGIN
	SELECT	@round	+= 1
			,@score	= 0
			,@i		= 0;

	WHILE @i < 3
	BEGIN
		SELECT	@score	+= @die;
		SELECT	@die	= IIF(@die = 100, 1, @die+1);
		SELECT	@i		+= 1;
	END

	IF @round % 2 = 1
	BEGIN
		SELECT	@Position1	= (@Position1 + @score - 1)%10 + 1;
		SELECT	@Score1		+= @Position1;
	END
	ELSE
	BEGIN
		SELECT	@Position2	= (@Position2 + @score - 1)%10 + 1;
		SELECT	@Score2		+= @Position2;
	END
END

SELECT	[Part 1] = IIF(@Score1 >= 1000, @Score2, @Score1) * @round * 3;

WITH [Die] AS
(
	SELECT	[score] = 1
	UNION ALL
	SELECT	2
	UNION ALL
	SELECT	3
)
INSERT INTO
		[#Throw] ([score], [occurrences])
SELECT	[Total].[score], COUNT(*)
FROM	[Die] [D1]
CROSS JOIN	[Die] [D2]
CROSS JOIN	[Die] [D3]
CROSS APPLY	(	SELECT	[score]	= [D1].[score] + [D2].[score] + [D3].[score]
			) [Total]
GROUP BY	[Total].[score];

DECLARE	@level		int = 0
		,@player	int	= 1;

INSERT INTO
		[#Progress] ([level], [position1], [score1], [position2], [score2], [winner], [occurrences])
SELECT	@level, @Start1, 0, @Start2, 0, 0, 1;

WHILE EXISTS (SELECT 1 FROM [#Progress] WHERE [level] = @level AND [winner] = 0)
BEGIN
	IF @player = 1
	BEGIN
		INSERT INTO	[#Progress]
					([level], [position1], [score1], [position2], [score2], [winner], [occurrences])
		SELECT		@level+1, [Next1].[position], [Next2].[score], [P].[position2], [P].[score2], [Next3].[winner], SUM([P].[occurrences] * [T].[occurrences])
		FROM		[#Progress] [P]
		CROSS JOIN	[#Throw] [T]	
		CROSS APPLY	(	SELECT	[position]	= IIF([P].[position1] + [T].[score] > 10, [P].[position1] + [T].[score] - 10, [P].[position1] + [T].[score])
					) [Next1]
		CROSS APPLY	(	SELECT	[score]		= [P].[score1] + [Next1].[position]
					) [Next2]
		CROSS APPLY	(	SELECT	[winner]	= IIF([Next2].[score] >= 21, 1, 0)
					) [Next3]
		WHERE		[level]			= @level
		AND			[P].[winner]	= 0
		GROUP BY	[Next1].[position], [Next2].[score], [P].[position2], [P].[score2], [Next3].[winner];
	END
	ELSE
	BEGIN
		INSERT INTO	[#Progress]
					([level], [position1], [score1], [position2], [score2], [winner], [occurrences])
		SELECT		@level+1, [P].[position1], [P].[score1], [Next1].[position], [Next2].[score], [Next3].[winner], SUM([P].[occurrences] * [T].[occurrences])
		FROM		[#Progress] [P]
		CROSS JOIN	[#Throw] [T]	
		CROSS APPLY	(	SELECT	[position]	= IIF([P].[position2] + [T].[score] > 10, [P].[position2] + [T].[score] - 10, [P].[position2] + [T].[score])
					) [Next1]
		CROSS APPLY	(	SELECT	[score]		= [P].[score2] + [Next1].[position]
					) [Next2]
		CROSS APPLY	(	SELECT	[winner]	= IIF([Next2].[score] >= 21, 2, 0)
					) [Next3]
		WHERE		[level]			= @level
		AND			[P].[winner]	= 0
		GROUP BY	[P].[position1], [P].[score1], [Next1].[position], [Next2].[score], [Next3].[winner];
	END

	-- Swap the player between 1 and 2.
	SELECT	@player = 3 - @player
			,@level	+= 1;
END

SELECT TOP (1)
			[Part 2]	= SUM([occurrences])
FROM		#Progress
GROUP BY	[winner]
HAVING		[winner]	> 0
ORDER BY	SUM([occurrences]) DESC;
