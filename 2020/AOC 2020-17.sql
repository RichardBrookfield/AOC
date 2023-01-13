USE [Richard];

SET NOCOUNT ON;

DROP TABLE IF EXISTS [#LayoutRaw];
DROP TABLE IF EXISTS [#Layout3D];
DROP TABLE IF EXISTS [#Layout4D];
GO

-- Test
DECLARE @inputT	varchar(MAX) = '
.#.
..#
###
';

-- Puzzle
DECLARE @input	varchar(MAX) = '
#...#.#.
..#.#.##
..#..#..
.....###
...#.#.#
#.#.##..
#####...
.#.#.##.
';

CREATE TABLE [#LayoutRaw]
(
	[row]			int				NOT NULL	IDENTITY(1,1)
	,[layout]		varchar(200)	NOT NULL
);

CREATE TABLE [#Layout3D]
(
	[id]			int				NOT NULL	IDENTITY(1,1)
	,[x]			int				NOT NULL
	,[y]			int				NOT NULL
	,[z]			int				NOT NULL
	,[active]		bit				NOT NULL
	,[next]			bit				NOT NULL

	,INDEX [idx_Layout]		CLUSTERED		([x], [y], [z])
	,INDEX [idx_id]			NONCLUSTERED	([id])
);

CREATE TABLE [#Layout4D]
(
	[id]			int				NOT NULL	IDENTITY(1,1)
	,[x]			int				NOT NULL
	,[y]			int				NOT NULL
	,[z]			int				NOT NULL
	,[w]			int				NOT NULL
	,[active]		bit				NOT NULL
	,[next]			bit				NOT NULL

	,INDEX [idx_Layout]		CLUSTERED		([x], [y], [z], [w])
	,INDEX [idx_id]			NONCLUSTERED	([id])
);

INSERT INTO [#LayoutRaw]
SELECT	[value]
FROM	STRING_SPLIT(REPLACE(@input, CHAR(13), ''), CHAR(10))
WHERE	LEN([value]) > 0;

DECLARE	@X			int
		,@Y			int = 1
		,@minX		int
		,@minY		int
		,@minZ		int
		,@minW		int
		,@maxX		int	= (SELECT MAX(LEN([layout])) FROM [#LayoutRaw])
		,@maxY		int	= (SELECT MAX([row]) FROM [#LayoutRaw])
		,@maxZ		int
		,@maxW		int
		,@i			int;

WHILE @Y <= @maxY
BEGIN
	SELECT	@X = 1;

	WHILE @X <= @maxX
	BEGIN
		IF EXISTS (	SELECT	1
					FROM	[#LayoutRaw]
					WHERE	[row] = @Y
					AND		SUBSTRING([layout], @X, 1) = '#'
					)
		BEGIN
			INSERT INTO [#Layout3D]
					([x], [y], [z], [active], [next])
			SELECT	@X, @Y, 0, 1, 0
		END

		SELECT	@X += 1;
	END

	SELECT	@Y += 1;
END

INSERT INTO [#Layout4D]
		([x], [y], [z], [w], [active], [next])
SELECT	[x], [y], [z], 0, [active], [next]
FROM	[#Layout3D]

-- First in 3D
SELECT	@i = 1;

WHILE @i <= 6
BEGIN
	-- First off the ones which will die off
	UPDATE	[L]
	SET		[next] = CASE WHEN [Adjacent].[TheCount] IN (2,3)
						THEN 1 ELSE 0 END
	FROM	[#Layout3D] [L]
	CROSS APPLY	(	SELECT	[TheCount] = COUNT(*)
					FROM	[#Layout3D] [A]
					WHERE	[A].[id] <> [L].[id]
					AND		ABS([A].[x] - [L].[x])	<= 1
					AND		ABS([A].[y] - [L].[y])	<= 1
					AND		ABS([A].[z] - [L].[z])	<= 1
				) [Adjacent]

	-- Then the new ones
	SELECT	@minX = MIN([x])
			,@maxX = MAX([x])
			,@minY = MIN([y])
			,@maxY = MAX([y])
			,@minZ = MIN([z])
			,@maxZ = MAX([z])
	FROM	[#Layout3D];

	WITH [Number] AS
	(
		SELECT	[N] = [number]
		FROM	[master]..[spt_values]
		WHERE	[type] = 'P'
	)
	, [Xrange] AS
	(
		SELECT	[X] = @minX + [N] - 1
		FROM	[Number]
		WHERE	[N] < @maxX - @minX + 3
	)
	, [Yrange] AS
	(
		SELECT	[Y] = @minY + [N] - 1
		FROM	[Number]
		WHERE	[N] < @maxY - @minY + 3
	)
	, [Zrange] AS
	(
		SELECT	[Z] = @minZ + [N] - 1
		FROM	[Number]
		WHERE	[N] < @maxZ - @minZ + 3
	)
	, [AllPoints] AS
	(
		SELECT	*
		FROM	[Xrange]
		CROSS JOIN	[Yrange]
		CROSS JOIN	[Zrange]
	)
	INSERT INTO [#Layout3D]
			([x], [y], [z], [active], [next])
	SELECT	[O].[X], [O].[Y], [O].[Z], 0, 1
	FROM	[AllPoints] [O]
	CROSS APPLY	(	SELECT	[TheCount] = COUNT(*)
					FROM	[#Layout3D] [A]
					WHERE	ABS([A].[x] - [O].[x])	<= 1
					AND		ABS([A].[y] - [O].[y])	<= 1
					AND		ABS([A].[z] - [O].[z])	<= 1
				) [Adjacent]
	WHERE	NOT EXISTS (	SELECT	1
							FROM	[#Layout3D] [A]
							WHERE	[A].[x] = [O].[x]
							AND		[A].[y] = [O].[y]
							AND		[A].[z] = [O].[z]
						)
	AND		[Adjacent].[TheCount] = 3

	UPDATE	[L]
	SET		[active]	= [L].[next]
	FROM	[#Layout3D] [L]
	WHERE	[L].[next] = 1;

	DELETE	[L]
	FROM	[#Layout3D] [L]
	WHERE	[L].[next] = 0;

	SELECT	@i += 1;
END

-- Then again in 4D.
SELECT	@i = 1;

WHILE @i <= 6
BEGIN
	-- First off the ones which will die off
	UPDATE	[L]
	SET		[next] = CASE WHEN [Adjacent].[TheCount] IN (2,3)
						THEN 1 ELSE 0 END
	FROM	[#Layout4D] [L]
	CROSS APPLY	(	SELECT	[TheCount] = COUNT(*)
					FROM	[#Layout4D] [A]
					WHERE	[A].[id] <> [L].[id]
					AND		ABS([A].[x] - [L].[x])	<= 1
					AND		ABS([A].[y] - [L].[y])	<= 1
					AND		ABS([A].[z] - [L].[z])	<= 1
					AND		ABS([A].[w] - [L].[w])	<= 1
				) [Adjacent]

	-- Then the new ones
	SELECT	@minX = MIN([x])
			,@maxX = MAX([x])
			,@minY = MIN([y])
			,@maxY = MAX([y])
			,@minZ = MIN([z])
			,@maxZ = MAX([z])
			,@minW = MIN([w])
			,@maxW = MAX([w])
	FROM	[#Layout4D];

	WITH [Number] AS
	(
		SELECT	[N] = [number]
		FROM	[master]..[spt_values]
		WHERE	[type] = 'P'
	)
	, [Xrange] AS
	(
		SELECT	[X] = @minX + [N] - 1
		FROM	[Number]
		WHERE	[N] < @maxX - @minX + 3
	)
	, [Yrange] AS
	(
		SELECT	[Y] = @minY + [N] - 1
		FROM	[Number]
		WHERE	[N] < @maxY - @minY + 3
	)
	, [Zrange] AS
	(
		SELECT	[Z] = @minZ + [N] - 1
		FROM	[Number]
		WHERE	[N] < @maxZ - @minZ + 3
	)
	, [Wrange] AS
	(
		SELECT	[W] = @minW + [N] - 1
		FROM	[Number]
		WHERE	[N] < @maxW - @minW + 3
	)
	, [AllPoints] AS
	(
		SELECT	*
		FROM	[Xrange]
		CROSS JOIN	[Yrange]
		CROSS JOIN	[Zrange]
		CROSS JOIN	[Wrange]
	)
	INSERT INTO [#Layout4D]
			([x], [y], [z], [w], [active], [next])
	SELECT	[O].[X], [O].[Y], [O].[Z], [O].[W], 0, 1
	FROM	[AllPoints] [O]
	CROSS APPLY	(	SELECT	[TheCount] = COUNT(*)
					FROM	[#Layout4D] [A]
					WHERE	ABS([A].[x] - [O].[x])	<= 1
					AND		ABS([A].[y] - [O].[y])	<= 1
					AND		ABS([A].[z] - [O].[z])	<= 1
					AND		ABS([A].[w] - [O].[w])	<= 1
				) [Adjacent]
	WHERE	NOT EXISTS (	SELECT	1
							FROM	[#Layout4D] [A]
							WHERE	[A].[x] = [O].[x]
							AND		[A].[y] = [O].[y]
							AND		[A].[z] = [O].[z]
							AND		[A].[w] = [O].[w]
						)
	AND		[Adjacent].[TheCount] = 3

	UPDATE	[L]
	SET		[active]	= [L].[next]
	FROM	[#Layout4D] [L]
	WHERE	[L].[next] = 1;

	DELETE	[L]
	FROM	[#Layout4D] [L]
	WHERE	[L].[next] = 0;

	SELECT	@i += 1;
END

SELECT	[Part 1] = COUNT(*)
FROM	[#Layout3D];

SELECT	[Part 2] = COUNT(*)
FROM	[#Layout4D];
