USE [Richard];

SET NOCOUNT ON;

-- Test
DECLARE @inputT	varchar(MAX) = '
Player 1:
9
2
6
3
1

Player 2:
5
8
4
7
10
';

-- Puzzle
DECLARE @input	varchar(MAX) = '
Player 1:
5
20
28
30
48
7
41
24
29
8
37
32
16
17
34
27
46
43
14
49
35
11
6
38
1

Player 2:
22
18
50
31
12
13
33
39
45
21
19
26
44
10
42
3
4
15
36
2
40
47
9
23
25
';

DECLARE	@inputRaw table
(
	[id]			int				NOT NULL		IDENTITY(1,1)
	,[value]		varchar(100)	NOT NULL
);

INSERT INTO @inputRaw
SELECT	[value]
FROM	STRING_SPLIT(REPLACE(@input, CHAR(13), ''), CHAR(10))
WHERE	LEN([value]) > 0;

DECLARE	@card table
(
	[id]			int				NOT NULL		IDENTITY(1,1)
	,[player]		int				NOT NULL
	,[value]		int				NOT NULL
);

DECLARE	@i			int	= 1
		,@line		varchar(100)
		,@player	int;

WHILE @i <= (SELECT COUNT(*) FROM @inputRaw)
BEGIN
	SELECT	@line = [value]
	FROM	@inputRaw
	WHERE	[id] = @i;

	IF LEFT(@line, 6) = 'player'
	BEGIN
		SELECT	@player = CAST(SUBSTRING(@line, 8, 1) AS int);
	END
	ELSE
	BEGIN
		INSERT INTO @card ([player], [value])
		VALUES (@player, CAST(@line AS int));
	END

	SELECT	@i += 1;
END

DECLARE @round table
(
	[player]		int NOT NULL
	,[value]		int NOT NULL
);

DECLARE	@winner	int;

WHILE (		SELECT	COUNT(*)
			FROM	(	SELECT DISTINCT [player]
						FROM		@card
					) [PlayerCount]
		) = 2
BEGIN
	DELETE FROM @round;

	WITH [TopCard] As
	(
		SELECT		[player],
					[id] = MIN([id])
		FROM		@card
		GROUP BY	[player]
	)
	INSERT INTO @round ([player], [value])
	SELECT	[C].[player], [C].[value]
	FROM	@card [C]
	JOIN	[TopCard] [TC]	ON	[TC].[id]	= [C].[id];

	DELETE	[C]
	FROM	@card [C]
	JOIN	@round [R]	ON	[R].[value]	= [C].[value];

	SELECT TOP (1)
				@winner = [player]
	FROM		@round
	ORDER BY	[value] DESC;

	INSERT INTO @card ([player], [value])
	SELECT	@winner, [value]
	FROM	@round
	ORDER BY	[value] DESC;
END

SELECT * from @card ORDER BY [id];

DECLARE	@score			int	= 0
		,@multiplier	int	= (SELECT COUNT(*) FROM @card)
		;

SELECT	@i = MIN([id])
FROM	@card;

WHILE @i <= (SELECT MAX([id]) FROM @card)
BEGIN
	SELECT	@score += @multiplier * [value]
	FROM	@card
	WHERE	[id] = @i;

	-- cards may not be consecutive at this point
	IF @@ROWCOUNT <> 0
		SELECT	@multiplier -= 1;

	PRINT @score;

	SELECT	@i += 1
END

SELECT	[Part 1] = @score;
