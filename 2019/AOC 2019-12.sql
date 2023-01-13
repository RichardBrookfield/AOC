USE [Richard];
GO

SET NOCOUNT ON;
SET STATISTICS IO, TIME OFF;

DECLARE	@input varchar(MAX), @maxsteps int;

-- Example 1
--SELECT	@maxsteps = 10, @input = '
--<x=-1, y=0, z=2>
--<x=2, y=-10, z=-7>
--<x=4, y=-8, z=8>
--<x=3, y=5, z=-1>
--';
/*
After 10 steps:
pos=<x= 2, y= 1, z=-3>, vel=<x=-3, y=-2, z= 1>
pos=<x= 1, y=-8, z= 0>, vel=<x=-1, y= 1, z= 3>
pos=<x= 3, y=-6, z= 1>, vel=<x= 3, y= 2, z=-3>
pos=<x= 2, y= 0, z= 4>, vel=<x= 1, y=-1, z=-1>

Energy:
Energy after 10 steps:
pot: 2 + 1 + 3 =  6;   kin: 3 + 2 + 1 = 6;   total:  6 * 6 = 36
pot: 1 + 8 + 0 =  9;   kin: 1 + 1 + 3 = 5;   total:  9 * 5 = 45
pot: 3 + 6 + 1 = 10;   kin: 3 + 2 + 3 = 8;   total: 10 * 8 = 80
pot: 2 + 0 + 4 =  6;   kin: 1 + 1 + 1 = 3;   total:  6 * 3 = 18
Sum of total energy: 36 + 45 + 80 + 18 = 179
*/

-- Example 2
--SELECT	@maxsteps = 100, @input = '
--<x=-8, y=-10, z=0>
--<x=5, y=5, z=10>
--<x=2, y=-7, z=3>
--<x=9, y=-8, z=-3>
--';
/*
After 100 steps:
pos=<x=  8, y=-12, z= -9>, vel=<x= -7, y=  3, z=  0>
pos=<x= 13, y= 16, z= -3>, vel=<x=  3, y=-11, z= -5>
pos=<x=-29, y=-11, z= -1>, vel=<x= -3, y=  7, z=  4>
pos=<x= 16, y=-13, z= 23>, vel=<x=  7, y=  1, z=  1>

Energy after 100 steps:
pot:  8 + 12 +  9 = 29;   kin: 7 +  3 + 0 = 10;   total: 29 * 10 = 290
pot: 13 + 16 +  3 = 32;   kin: 3 + 11 + 5 = 19;   total: 32 * 19 = 608
pot: 29 + 11 +  1 = 41;   kin: 3 +  7 + 4 = 14;   total: 41 * 14 = 574
pot: 16 + 13 + 23 = 52;   kin: 7 +  1 + 1 =  9;   total: 52 *  9 = 468
Sum of total energy: 290 + 608 + 574 + 468 = 1940
*/

-- Part 1: Energy = 7988
-- Part 2: Repeats after = 337721412394184 (takes about 3m to run).
SELECT	@maxsteps = 1000, @input = '
<x=-1, y=-4, z=0>
<x=4, y=7, z=-1>
<x=-14, y=-10, z=9>
<x=1, y=2, z=17>
';

SELECT	@input = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@input
					,'x','')
					,'y','')
					,'z','')
					,'<','')
					,'>','')
					,'=','')
					,CHAR(13),'');

DROP TABLE IF EXISTS [##Position], [##Velocity], [##Initial], [##RepeatsAt];

CREATE TABLE [##Position]
(
	[id]		smallint
	,[coord]	int
				PRIMARY KEY ([id], [coord])
	,[value]	int
);

CREATE TABLE [##Initial]
(
	[id]		smallint
	,[coord]	int
				PRIMARY KEY ([id], [coord])
	,[value]	int
);

CREATE TABLE [##Velocity]
(
	[id]		smallint
	,[coord]	int
				PRIMARY KEY ([id], [coord])
	,[value]	int
);

CREATE TABLE [##RepeatsAt]
(
	[coord]		int
				PRIMARY KEY ([coord])
	,[step]		int
);

WITH [Lines] AS
(
	SELECT	[Variables]		= [value]
			,[RowNumber]	= ROW_NUMBER() OVER (PARTITION BY NULL ORDER BY (SELECT NULL))
	FROM	STRING_SPLIT(@input, CHAR(10))
	WHERE	[value] <> ''
)
, [Variables] AS
(
	SELECT	[L].[RowNumber]
			,[SplitVariables].[VariableNumber]
			,[SplitVariables].[Variable]
	FROM	[Lines] [L]
	CROSS APPLY	(	SELECT	[Variable]			= [value]
							,[VariableNumber]	= ROW_NUMBER() OVER (PARTITION BY NULL ORDER BY (SELECT NULL))
					FROM	STRING_SPLIT([L].[Variables], ',')
				) [SplitVariables]
)
INSERT INTO
		[##Position] ([id], [coord], [value])
SELECT	[V].[RowNumber], [V].[VariableNumber], [V].[Variable]
FROM	[Variables] [V];

INSERT INTO
		[##Velocity] ([id], [coord], [value])
SELECT	[id], [coord], 0
FROM	[##Position];

INSERT INTO
		[##Initial] ([id], [coord], [value])
SELECT	[id], [coord], [value]
FROM	[##Position];

INSERT INTO
		[##RepeatsAt] ([coord], [step])
SELECT DISTINCT
		[coord], 0
FROM	[##Position];

DECLARE @steps int = 0;

WHILE @steps < @maxsteps
	OR EXISTS (SELECT 1 FROM [##RepeatsAt] WHERE [step] = 0)
BEGIN

	WITH [PositionPairs] AS
	(
		SELECT	[P1].[id]
				,[P1].[coord]
				,[offset]	= CASE
								WHEN [P1].[value] = [P2].[value]	THEN 0
								WHEN [P1].[value] < [P2].[value]	THEN 1
								WHEN [P1].[value] > [P2].[value]	THEN -1
								ELSE (SELECT 1/0)
								END
		FROM	[##Position] [P1]
		INNER JOIN	[##Position] [P2]	ON	[P2].[id]		<> [P1].[id]
										AND	[P2].[coord]	= [P1].[coord]
	)
	, [SummedPP] AS
	(
		SELECT		[PP].[id]
					,[PP].[coord]
					,[offset]	= SUM([PP].[offset])
		FROM		[PositionPairs] [PP]
		GROUP BY	[PP].[id], [PP].[coord]
	)
	UPDATE	[V]
	SET		[V].[value] += [SPP].[offset]
	FROM	[##Velocity] [V]
	INNER JOIN [SummedPP] [SPP]	ON	[SPP].[id]		= [V].[id]
								AND	[SPP].[coord]	= [V].[coord]

	UPDATE	[P]
	SET		[P].[value] += [V].[value]
	FROM	[##Position] [P]
	INNER JOIN	[##Velocity] [V]	ON	[V].[id]	= [P].[id]
									AND	[V].[coord]	= [P].[coord]

	SELECT @steps += 1;

	UPDATE	[##RepeatsAt]
	SET		[step] = @steps
	FROM	[##RepeatsAt] [R]
	WHERE	[R].[step] = 0
	AND		(	SELECT	COUNT(*)
				FROM	[##Position] [P]
				INNER JOIN	[##Initial] [I]		ON	[I].[id]	= [P].[id]
												AND	[I].[coord]	= [P].[coord]
												AND	[I].[value] = [P].[value]
				INNER JOIN	[##Velocity] [V]	ON	[V].[id]	= [P].[id]
												AND [V].[coord] = [P].[coord]
												AND	[V].[value]	= 0
				WHERE	[P].[coord]	= [R].[coord]
			) = 4;

	IF @@ROWCOUNT <> 0 OR @steps%10000 = 0
		SELECT @steps,* FROM [##RepeatsAt];

	IF @steps = @maxsteps
	BEGIN
		SELECT	[P1].[id], [P1].[value], [P2].[value], [P3].[value]
		FROM	[##Position] [P1]
		INNER JOIN	[##Position] [P2]	ON	[P2].[id]		= [P1].[id]
										AND	[P2].[coord]	= 2
		INNER JOIN	[##Position] [P3]	ON	[P3].[id]		= [P1].[id]
										AND	[P3].[coord]	= 3
		WHERE	[P1].[coord]	= 1;

		SELECT	[V1].[id], [V1].[value], [V2].[value], [V3].[value]
		FROM	[##Velocity] [V1]
		INNER JOIN	[##Velocity] [V2]	ON	[V2].[id]		= [V1].[id]
										AND	[V2].[coord]	= 2
		INNER JOIN	[##Velocity] [V3]	ON	[V3].[id]		= [V1].[id]
										AND	[V3].[coord]	= 3
		WHERE	[V1].[coord]	= 1;

		WITH [SummedPosition] AS
		(
			SELECT		[P].[id]
						,[value]	= SUM(ABS([P].[value]))
			FROM		[##Position] [P]
			GROUP BY	[P].[id]
		)
		, [SummedVelocity] AS
		(
			SELECT		[V].[id]
						,[value]	= SUM(ABS([V].[value]))
			FROM		[##Velocity] [V]
			GROUP BY	[V].[id]
		)
		SELECT	[Energy] = SUM([SP].[value] * [SV].[value])
		FROM	[SummedPosition] [SP]
		INNER JOIN	[SummedVelocity] [SV]	ON	[SV].[id]		= [SP].[id];
	END
END;

SELECT	[coord], [step]
FROM	[##RepeatsAt];

-- Finally we need to find the Least Common Multiple of all these numbers.
-- Easiest way is to make a list of primes and, at the same time, remove them from the numbers
-- until they are all reduced to 1, whilst adding the factors to the answer.
DECLARE @LCM bigint = 1, @PossiblePrime int = 2;
DECLARE @Prime table ([i] int);
DECLARE @Number table ([i] int);

INSERT INTO
		@Number
SELECT	[step]
FROM	[##RepeatsAt];

WHILE EXISTS (SELECT 1 FROM @Number)
BEGIN
	WHILE EXISTS (SELECT 1 FROM @Number WHERE [i]%@PossiblePrime = 0)
	BEGIN
		UPDATE	[N]
		SET		[i] /= @PossiblePrime
		FROM	@Number [N]
		WHERE	[i]%@PossiblePrime = 0;

		IF @@ROWCOUNT <> 0
		BEGIN
			SELECT [OldLCM] = @LCM, [NewFactor] = @PossiblePrime;
			SELECT @LCM *= @PossiblePrime;
		END
	END

	DELETE	[N]
	FROM	@Number [N]
	WHERE	[N].[i] = 1;

	SELECT @PossiblePrime = CASE WHEN @PossiblePrime = 2
								THEN 3
								ELSE @PossiblePrime+2
								END;
END

SELECT [LCM] = @LCM;
