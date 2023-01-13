USE [Richard];
GO

DROP PROCEDURE IF EXISTS [#up_FindBest];
GO

CREATE OR ALTER PROCEDURE [#up_FindBest]
	@UserInput	varchar(MAX)
	,@ForceX	int	= NULL
	,@ForceY	int = NULL
AS
BEGIN
	DECLARE	@Coords table
    (
		[Id]		int IDENTITY(1,1)
		,[X]		int		NOT NULL
		,[Y]		int		NOT NULL
		,[Filled]	tinyint	NOT NULL

		PRIMARY KEY ([X], [Y])
	);

	DECLARE @x int = 0, @y int = 0, @line varchar(MAX);

	DECLARE c CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
	SELECT	[value]
	FROM	STRING_SPLIT(
				REPLACE(@userinput, CHAR(13), '')
				,CHAR(10));

	OPEN c;
	FETCH NEXT FROM c INTO @line;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		WHILE LEN(@line) > 0
		BEGIN
			INSERT INTO @Coords ([X], [Y], [Filled])
			SELECT	@x, @y, CASE WHEN LEFT(@line,1) = '#' THEN 1 ELSE 0 END;

			SELECT	@line = RIGHT(@line, LEN(@line)-1), @x += 1;
		END

		SELECT	@x = 0, @y += 1;

		FETCH NEXT FROM c INTO @line;
	END

	CLOSE c;
	DEALLOCATE c;

	DECLARE @BestId int;

	-- This is because the worked example doesn't actually use the "best" site...
	IF @ForceX IS NOT NULL AND @ForceY IS NOT NULL
	BEGIN
		SELECT	@BestId = [C].[Id]
		FROM	@Coords [C]
		WHERE	[C].[X] = @ForceX
		AND		[C].[Y] = @ForceY;

		SELECT	'Replacement Best Id', @BestId;
	END
	ELSE
	BEGIN
		WITH [Pairs] AS
		(
			SELECT	[BaseId]	= [B].[Id]
					,[BaseX]	= [B].[X]
					,[BaseY]	= [B].[Y]
					,[OtherId]	= [O].[Id]
					,[OtherX]	= [O].[X]
					,[OtherY]	= [O].[Y]
			FROM	@Coords [B]
			INNER JOIN	@Coords [O]	ON	[O].[Filled]	= 1
									AND [O].[Id]		<> [B].[Id]
			WHERE	[B].[Filled] = 1
		)
		, [Best] AS
		(
			SELECT	[P].[BaseId]
					,[ObscuredTotal]	= [Obscured].[Total]
					,[TheCount]			= COUNT(*)
			FROM	[Pairs] [P]
			CROSS APPLY	(	SELECT	[OnX]	= (	SELECT	COUNT(*)
												FROM	@Coords [O]
												WHERE	[O].[Filled]	= 1
												AND		[O].[Id]		NOT IN ([P].[BaseId], [P].[OtherId])
												AND		[O].[Y]			= [P].[BaseY]
												AND		[O].[Y]			= [P].[OtherY]
												AND		(
														[O].[X]			BETWEEN [P].[BaseX] AND [P].[OtherX]
												OR		[O].[X]			BETWEEN [P].[OtherX] AND [P].[BaseX]
														)
												)
									,[OnY]	= ( SELECT	COUNT(*)
												FROM	@Coords [O]
												WHERE	[O].[Filled]	= 1
												AND		[O].[Id]		NOT IN ([P].[BaseId], [P].[OtherId])
												AND		[O].[X]			= [P].[BaseX]
												AND		[O].[X]			= [P].[OtherX]
												AND		(
														[O].[Y]			BETWEEN [P].[BaseY] AND [P].[OtherY]
												OR		[O].[Y]			BETWEEN [P].[OtherY] AND [P].[BaseY]
														)
												)
									,[OnD]	= ( SELECT	COUNT(*)
												FROM	@Coords [O]
												WHERE	[O].[Filled]	= 1
												AND		[O].[Id]		NOT IN ([P].[BaseId], [P].[OtherId])
												AND		(
														[O].[X]			BETWEEN [P].[BaseX] AND [P].[OtherX]
												OR		[O].[X]			BETWEEN [P].[OtherX] AND [P].[BaseX]
														)
												AND		(
														[O].[Y]			BETWEEN [P].[BaseY] AND [P].[OtherY]
												OR		[O].[Y]			BETWEEN [P].[OtherY] AND [P].[BaseY]
														)
												AND		([P].[OtherX] - [O].[X]) * ([O].[Y] - [P].[BaseY]) =
														([P].[OtherY] - [O].[Y]) * ([O].[X] - [P].[BaseX])
												)
						) [Sighting]
			CROSS APPLY (	SELECT	[Total]	= [Sighting].[OnX] + [Sighting].[OnY] + [Sighting].[OnD]
						) [Obscured]
			GROUP BY	[P].[BaseId], [Obscured].[Total]
		)
		SELECT	*
		INTO	#TempBest
		FROM	[Best] [B]
		INNER JOIN	@Coords [C]	ON [C].[Id] = [B].[BaseId]

		SELECT TOP (1)
					@BestId = [BaseId]
		FROM		#TempBest [TB]
		WHERE		[TB].[ObscuredTotal] = 0
		ORDER BY	[TB].[TheCount] DESC;

		SELECT	*
		FROM	#TempBest [TB]
		WHERE	[TB].[ObscuredTotal]	= 0
		AND		[TB].[BaseId]			= @BestId;
	END

	SELECT	*
	FROM	@Coords [Base]
	JOIN	@Coords [Other]		ON	[Other].[Id]		<> [Base].[Id]
								AND	[Other].[Filled]	= 1
	CROSS APPLY (	SELECT	[TheCount] = COUNT(*)
					FROM	@Coords [B]
					WHERE	[B].[Filled]	= 1
					AND		[B].[Id]	NOT IN ([Base].[Id], [Other].[Id])
					AND		(	[Base].[X]	= [Other].[X]
							AND [B].[X]		= [Other].[X]
							AND	(
								[B].[Y] BETWEEN [Base].[Y] AND [Other].[Y]
								OR
								[B].[Y] BETWEEN [Other].[Y] AND [Base].[Y]
								)
							OR	[Base].[Y]	= [Other].[Y]
							AND [B].[Y]		= [Other].[Y]
							AND	(
								[B].[X] BETWEEN [Base].[X] AND [Other].[X]
								OR
								[B].[X] BETWEEN [Other].[X] AND [Base].[X]
								)
							OR	(
								[B].[X] BETWEEN [Base].[X] AND [Other].[X]
								OR
								[B].[X] BETWEEN [Other].[X] AND [Base].[X]
								)
							AND	(
								[B].[Y] BETWEEN [Base].[Y] AND [Other].[Y]
								OR
								[B].[Y] BETWEEN [Other].[Y] AND [Base].[Y]
								)
							AND	([Other].[X] - [B].[X]) * ([B].[Y] - [Base].[Y]) =
								([Other].[Y] - [B].[Y]) * ([B].[X] - [Base].[X])
							)
				) [Blockers]
	CROSS APPLY (	SELECT	[Value] = CASE
								WHEN [Other].[X] = [Base].[X]
								THEN CASE	WHEN [Other].[Y] < [Base].[Y]
											THEN 1
											ELSE 5
											END
								WHEN [Other].[Y] = [Base].[Y]
								THEN CASE	WHEN [Other].[X] > [Base].[X]
											THEN 3
											ELSE 7
											END
								WHEN [Other].[X] > [Base].[X] AND [Other].[Y] < [Base].[Y]
								THEN 2
								WHEN [Other].[X] > [Base].[X] AND [Other].[Y] > [Base].[Y]
								THEN 4
								WHEN [Other].[X] < [Base].[X] AND [Other].[Y] > [Base].[Y]
								THEN 6
								WHEN [Other].[X] < [Base].[X] AND [Other].[Y] < [Base].[Y]
								THEN 8
								END
				) [AxisQuad]
	CROSS APPLY (	SELECT		[X]		= CAST(ABS([Base].[X] - [Other].[X]) AS float)
								,[Y]	= CAST(ABS([Base].[Y] - [Other].[Y]) AS float)
				) [Diff]
	CROSS APPLY	(	SELECT	[Angle] = CASE [AxisQuad].[Value]
								WHEN 2 THEN ATAN([Diff].[X] / [Diff].[Y])
								WHEN 4 THEN ATAN([Diff].[Y] / [Diff].[X])
								WHEN 6 THEN ATAN([Diff].[X] / [Diff].[Y])
								WHEN 8 THEN ATAN([Diff].[Y] / [Diff].[X])
								ELSE 0
								END
				) [Radial]
	WHERE		[Base].[Id]	= @BestId
	ORDER BY	[Blockers].[TheCount], [AxisQuad].[Value], [Radial].[Angle];
END
GO

/*
-- Test 1: 3,4 @ 8
DECLARE @userinput varchar(MAX) = 
'.#..#
.....
#####
....#
...##';

EXEC [dbo].[#up_FindBest] @UserInput = @userinput;
GO

-- Test 2: 5,8 @ 33
DECLARE @userinput varchar(MAX) = 
'......#.#.
#..#.#....
..#######.
.#.#.###..
.#..#.....
..#....#.#
#..#....#.
.##.#..###
##...#..#.
.#....####';

EXEC [dbo].[#up_FindBest] @UserInput = @userinput;
GO

-- Test 3: 1,2 @ 35
DECLARE @userinput varchar(MAX) = 
'#.#...#.#.
.###....#.
.#....#...
##.#.#.#.#
....#.#.#.
.##..###.#
..#...##..
..##....##
......#...
.####.###.';

EXEC [dbo].[#up_FindBest] @UserInput = @userinput;
GO

-- Test 4: 6,3 @ 41
DECLARE @userinput varchar(MAX) = 
'.#..#..###
####.###.#
....###.#.
..###.##.#
##.##.#.#.
....###..#
..#.#..#.#
#..#.#.###
.##...##.#
.....#.#..';

EXEC [dbo].[#up_FindBest] @UserInput = @userinput;
GO

-- Test 5: 11,13 @ 210
DECLARE @userinput varchar(MAX) = 
'.#..##.###...#######
##.############..##.
.#.######.########.#
.###.#######.####.#.
#####.##.#.##.###.##
..#####..#.#########
####################
#.####....###.#.#.##
##.#################
#####.##.###..####..
..######..##.#######
####.##.####...##..#
.#####..#.######.###
##...#.##########...
#.##########.#######
.####.#.###.###.#.##
....##.##.###..#####
.#.#.###########.###
#.#.#.#####.####.###
###.##.####.##.#..##';

EXEC [dbo].[#up_FindBest] @UserInput = @userinput;
GO

-- Part 1: 22,19 @ 282
DECLARE @userinput varchar(MAX) = 
'###..#.##.####.##..###.#.#..
#..#..###..#.......####.....
#.###.#.##..###.##..#.###.#.
..#.##..##...#.#.###.##.####
.#.##..####...####.###.##...
##...###.#.##.##..###..#..#.
.##..###...#....###.....##.#
#..##...#..#.##..####.....#.
.#..#.######.#..#..####....#
#.##.##......#..#..####.##..
##...#....#.#.##.#..#...##.#
##.####.###...#.##........##
......##.....#.###.##.#.#..#
.###..#####.#..#...#...#.###
..##.###..##.#.##.#.##......
......##.#.#....#..##.#.####
...##..#.#.#.....##.###...##
.#.#..#.#....##..##.#..#.#..
...#..###..##.####.#...#..##
#.#......#.#..##..#...#.#..#
..#.##.#......#.##...#..#.##
#.##..#....#...#.##..#..#..#
#..#.#.#.##..#..#.#.#...##..
.#...#.........#..#....#.#.#
..####.#..#..##.####.#.##.##
.#.######......##..#.#.##.#.
.#....####....###.#.#.#.####
....####...##.#.#...#..#.##.';

EXEC [dbo].[#up_FindBest] @UserInput = @userinput;
GO

-- Part 2 testing:
DECLARE @userinput varchar(MAX) = 
'.#....#####...#..
##...##.#####..##
##...#...#.#####.
..#.....X...###..
..#.#.....#....##';

EXEC [dbo].[#up_FindBest] @UserInput = @userinput, @ForceX = 8, @ForceY = 3;
GO
*/

-- Part 2 testing: assume 11,13
DECLARE @userinput varchar(MAX) = 
'.#..##.###...#######
##.############..##.
.#.######.########.#
.###.#######.####.#.
#####.##.#.##.###.##
..#####..#.#########
####################
#.####....###.#.#.##
##.#################
#####.##.###..####..
..######..##.#######
####.##.####...##..#
.#####..#.######.###
##...#.##########...
#.##########.#######
.####.#.###.###.#.##
....##.##.###..#####
.#.#.###########.###
#.#.#.#####.####.###
###.##.####.##.#..##';

EXEC [dbo].[#up_FindBest] @UserInput = @userinput, @ForceX = 11, @ForceY = 13;
GO

-- Part 2: 22,19 gives 200th = 10,8 = 1008
DECLARE @userinput varchar(MAX) = 
'###..#.##.####.##..###.#.#..
#..#..###..#.......####.....
#.###.#.##..###.##..#.###.#.
..#.##..##...#.#.###.##.####
.#.##..####...####.###.##...
##...###.#.##.##..###..#..#.
.##..###...#....###.....##.#
#..##...#..#.##..####.....#.
.#..#.######.#..#..####....#
#.##.##......#..#..####.##..
##...#....#.#.##.#..#...##.#
##.####.###...#.##........##
......##.....#.###.##.#.#..#
.###..#####.#..#...#...#.###
..##.###..##.#.##.#.##......
......##.#.#....#..##.#.####
...##..#.#.#.....##.###...##
.#.#..#.#....##..##.#..#.#..
...#..###..##.####.#...#..##
#.#......#.#..##..#...#.#..#
..#.##.#......#.##...#..#.##
#.##..#....#...#.##..#..#..#
#..#.#.#.##..#..#.#.#...##..
.#...#.........#..#....#.#.#
..####.#..#..##.####.#.##.##
.#.######......##..#.#.##.#.
.#....####....###.#.#.#.####
....####...##.#.#...#..#.##.';

EXEC [dbo].[#up_FindBest] @UserInput = @userinput, @ForceX = 22, @ForceY = 19;
GO
