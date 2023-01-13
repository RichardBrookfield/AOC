USE [Richard];
GO

DROP PROCEDURE IF EXISTS [#up_Computer];
DROP TABLE IF EXISTS [##SavedState];
GO

CREATE TABLE [##SavedState]
(
	[Phase]		int NOT NULL
	,[Position]	int NOT NULL
	,[Value]	int NOT NULL
);
GO

CREATE PROCEDURE [#up_Computer]
	@input		varchar(MAX)
	,@phase		int
	,@userinput	int
	,@debug		bit
	,@output	int	OUTPUT
	,@stop		bit OUTPUT
	,@reload	bit		= 0
AS
BEGIN
	DECLARE @loops int = 0, @maxloops int = 200, @phaseused bit = 0;

	DECLARE @opcode table
	(
		[Position]	int	IDENTITY(0,1)
		,[Value]	int	NOT NULL
	)

	DECLARE @sp int = 0, @op int, @p1 int, @p2 int, @p3 int, @res int, @pause bit = 0;
	DECLARE @v1 int, @v2 int, @v3 int, @pm1 int, @pm2 int, @pm3 int;

	IF @reload = 1
	BEGIN
		INSERT INTO @opcode
		SELECT		[Value]
		FROM		[##SavedState]
		WHERE		[Phase]		= @phase
		AND			[Position]	>= 0
		ORDER BY	[Position];

		SELECT		@sp			= [Value]
					,@phaseused	= 1
		FROM		[##SavedState]
		WHERE		[Phase]		= @phase
		AND			[Position]	= -1;
	END
	ELSE
	BEGIN
		INSERT INTO @opcode
		SELECT value FROM STRING_SPLIT(@input, ',');
	END

	SELECT @stop = 0;

	WHILE @stop = 0 AND @pause = 0 AND @sp < (SELECT COUNT(*) FROM @opcode)
	BEGIN
		SELECT	@op		= [Value] % 100
				,@pm1	= [Value] / 100 % 10
				,@pm2	= [Value] / 1000 % 10
				,@pm3	= [Value] / 10000 % 10
		FROM	@opcode
		WHERE	[Position] = @sp;

		IF @op = 99
		BEGIN
			SET @stop = 1;
		END
		ELSE
		BEGIN
			SELECT @p1 = [Value]	FROM @opcode WHERE [Position] = @sp+1;
			SELECT @p2 = [Value]	FROM @opcode WHERE [Position] = @sp+2;
			SELECT @p3 = [Value]	FROM @opcode WHERE [Position] = @sp+3;

			IF @debug = 1
				SELECT 111, op=@op, res=@res, p1=@p1, p2=@p2, p3=@p3, pm1=@pm1, pm2=@pm2, pm3=@pm3, v1=@v1, v2=@v2, v3=@v3, sp=@sp;

			SELECT	@v1 = CASE WHEN @pm1 = 1 THEN @p1 ELSE 
							(	SELECT	[Value]
								FROM	@opcode
								WHERE	[Position] = @p1
							)
							END;

			SELECT	@v2 = CASE WHEN @pm2 = 1 THEN @p2 ELSE 
							(	SELECT	[Value]
								FROM	@opcode
								WHERE	[Position] = @p2
							)
							END;

			IF @debug = 1
				SELECT 222, op=@op, res=@res, p1=@p1, p2=@p2, p3=@p3, pm1=@pm1, pm2=@pm2, pm3=@pm3, v1=@v1, v2=@v2, v3=@v3, sp=@sp;

			SELECT @res = CASE
							WHEN @op = 1				THEN @v1 + @v2
							WHEN @op = 2				THEN @v1 * @v2
							WHEN @op BETWEEN 3 AND 8	THEN 0
							ELSE 1/0					-- Force a SQL halt on all unknown values
							END

			IF @op = 3
			BEGIN
				IF @phaseused = 1
				BEGIN
					SELECT @res = @userinput;
				END
				ELSE
				BEGIN
					SELECT @res = @phase, @phaseused = 1;
				END
			END

			IF @op = 5
				SELECT @sp = CASE WHEN @v1 <> 0 THEN @v2 ELSE @sp+3 END;

			IF @op = 6
				SELECT @sp = CASE WHEN @v1 = 0 THEN @v2 ELSE @sp+3 END;

			IF @op IN (7,8)
				UPDATE	@opcode
				SET		[Value]		= CASE WHEN @op = 7 AND @v1 < @v2 OR @op = 8 AND @v1 = @v2
										THEN 1 ELSE 0 END
				WHERE	[Position]	= @p3;

			IF @debug = 1
				SELECT 333, op=@op, res=@res, p1=@p1, p2=@p2, p3=@p3, pm1=@pm1, pm2=@pm2, pm3=@pm3, v1=@v1, v2=@v2, v3=@v3, sp=@sp;

			IF @op IN (1,2,3)
			BEGIN
				UPDATE	@opcode
				SET		[Value]		= @res
				WHERE	[Position]	= CASE WHEN @op IN (1,2) THEN @p3 ELSE @p1 END;
			END

			IF @debug = 1
				SELECT 444, op=@op, res=@res, p1=@p1, p2=@p2, p3=@p3, pm1=@pm1, pm2=@pm2, pm3=@pm3, v1=@v1, v2=@v2, v3=@v3, sp=@sp;

			IF @op = 4
			BEGIN
				SELECT	@output = @v1, @pause = 1;
			END

			IF @debug = 1
				SELECT * FROM @opcode;

			SELECT @sp += CASE
							WHEN @op IN (1,2) THEN 4
							WHEN @op IN (3,4) THEN 2
							WHEN @op IN (7,8) THEN 4
							ELSE 0
							END;

			-- Stops any craziness... just in case.
			SELECT @loops += 1;

			IF @loops > @maxloops
			BEGIN
				SELECT 'Error safety limit reached';
				SELECT @stop = 1;
			END
		END

		IF @pause = 1
		BEGIN
			DELETE	[SS]
			FROM	[##SavedState] [SS]
			WHERE	[Phase]	= @phase;

			INSERT INTO	[##SavedState]
					([Phase], [Position], [Value])

			SELECT	@phase, [Position], [Value] 
			FROM	@opcode

			UNION ALL

			SELECT	@phase, -1, @sp;
		END
	END
END
GO

-- Test 1: result 43210
DECLARE @output int = 0, @stop bit;
DECLARE @input varchar(MAX) = '3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0';

EXEC [dbo].[#up_Computer] @input = @input, @phase=4, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT;
EXEC [dbo].[#up_Computer] @input = @input, @phase=3, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT;
EXEC [dbo].[#up_Computer] @input = @input, @phase=2, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT;
EXEC [dbo].[#up_Computer] @input = @input, @phase=1, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT;
EXEC [dbo].[#up_Computer] @input = @input, @phase=0, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT;

SELECT [Ouput] = @output;
GO

-- Test 2: result 54321
DECLARE @output int = 0, @stop bit;
DECLARE @input varchar(MAX) = '3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0';

EXEC [dbo].[#up_Computer] @input = @input, @phase=0, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT;
EXEC [dbo].[#up_Computer] @input = @input, @phase=1, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT;
EXEC [dbo].[#up_Computer] @input = @input, @phase=2, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT;
EXEC [dbo].[#up_Computer] @input = @input, @phase=3, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT;
EXEC [dbo].[#up_Computer] @input = @input, @phase=4, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT;

SELECT [Ouput] = @output;
GO

-- Test 3: result 65210
DECLARE @output int = 0, @stop bit;
DECLARE @input varchar(MAX) = '3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0';

EXEC [dbo].[#up_Computer] @input = @input, @phase=1, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT;
EXEC [dbo].[#up_Computer] @input = @input, @phase=0, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT;
EXEC [dbo].[#up_Computer] @input = @input, @phase=4, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT;
EXEC [dbo].[#up_Computer] @input = @input, @phase=3, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT;
EXEC [dbo].[#up_Computer] @input = @input, @phase=2, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT;

SELECT [Ouput] = @output;
GO

-- Actual problem Part 1: 117312
DECLARE @output int, @stop bit, @bestoutput int = 0;
DECLARE @input varchar(MAX) = '3,8,1001,8,10,8,105,1,0,0,21,38,55,64,81,106,187,268,349,430,99999,3,9,101,2,9,9,1002,9,2,9,101,5,9,9,4,9,99,3,9,102,2,9,9,101,3,9,9,1002,9,4,9,4,9,99,3,9,102,2,9,9,4,9,99,3,9,1002,9,5,9,1001,9,4,9,102,4,9,9,4,9,99,3,9,102,2,9,9,1001,9,5,9,102,3,9,9,1001,9,4,9,102,5,9,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,1,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,101,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,1,9,9,4,9,99,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,99,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,99';

DECLARE @sequence table
(
	[sequence]	varchar(5) NOT NULL
);

WITH [Numbers] AS
(
	SELECT N=0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
)
, [Combos] AS
(
	SELECT	[Sequence] = CAST([N] AS varchar(10)), [Level]=0
	FROM	[Numbers]

	UNION ALL 

	SELECT	CAST([C].[Sequence] + [ToString].[NC] AS varchar(10)), [C].[Level]+1
	FROM	[Combos] [C]
	CROSS JOIN [Numbers] [N]
	CROSS APPLY (SELECT [NC] = CAST([N].[N] AS varchar(1))) [ToString]
	WHERE	[C].[Level]<4
	AND		CHARINDEX([ToString].[NC], [C].[Sequence]) = 0
)
INSERT INTO	@sequence
SELECT		[C].[Sequence]
FROM		[Combos] [C]
WHERE		[C].[Level] = 4

DECLARE c CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
SELECT [sequence] FROM @sequence

OPEN c

DECLARE @value varchar(10), @phase0 int, @phase1 int, @phase2 int, @phase3 int, @phase4 int;

FETCH NEXT FROM c INTO @value;

WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT	@phase0		= TRY_CAST(SUBSTRING(@value, 1, 1) AS int)
			,@phase1	= TRY_CAST(SUBSTRING(@value, 2, 1) AS int)
			,@phase2	= TRY_CAST(SUBSTRING(@value, 3, 1) AS int)
			,@phase3	= TRY_CAST(SUBSTRING(@value, 4, 1) AS int)
			,@phase4	= TRY_CAST(SUBSTRING(@value, 5, 1) AS int)
			,@output	= 0;

	EXEC [dbo].[#up_Computer] @input = @input, @phase=@phase0, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT;
	EXEC [dbo].[#up_Computer] @input = @input, @phase=@phase1, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT;
	EXEC [dbo].[#up_Computer] @input = @input, @phase=@phase2, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT;
	EXEC [dbo].[#up_Computer] @input = @input, @phase=@phase3, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT;
	EXEC [dbo].[#up_Computer] @input = @input, @phase=@phase4, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT;

	IF @bestoutput < @output
		SELECT @bestoutput = @output;

	FETCH NEXT FROM c INTO @value;
END

CLOSE c;
DEALLOCATE c;

SELECT @bestoutput;
GO

-- Part 2 testing 1: 139629729
DECLARE @output int = 0, @stop bit = 0, @reload bit = 0;
DECLARE @input varchar(MAX) = '3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5';

WHILE @stop = 0
BEGIN
	EXEC [dbo].[#up_Computer] @input = @input, @phase=9, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT, @reload = @reload;
	EXEC [dbo].[#up_Computer] @input = @input, @phase=8, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT, @reload = @reload;
	EXEC [dbo].[#up_Computer] @input = @input, @phase=7, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT, @reload = @reload;
	EXEC [dbo].[#up_Computer] @input = @input, @phase=6, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT, @reload = @reload;
	EXEC [dbo].[#up_Computer] @input = @input, @phase=5, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT, @reload = @reload;

	SELECT @reload = 1;
END

SELECT [Ouput] = @output;
GO

-- Part 2 testing 2: 18216
DECLARE @output int = 0, @stop bit = 0, @reload bit = 0;
DECLARE @input varchar(MAX) = '3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10';

WHILE @stop = 0
BEGIN
	EXEC [dbo].[#up_Computer] @input = @input, @phase=9, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT, @reload = @reload;
	EXEC [dbo].[#up_Computer] @input = @input, @phase=7, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT, @reload = @reload;
	EXEC [dbo].[#up_Computer] @input = @input, @phase=8, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT, @reload = @reload;
	EXEC [dbo].[#up_Computer] @input = @input, @phase=5, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT, @reload = @reload;
	EXEC [dbo].[#up_Computer] @input = @input, @phase=6, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT, @reload = @reload;

	SELECT @reload = 1;
END

SELECT [Ouput] = @output;
GO

-- Actual problem Part 2: 1336480
DECLARE @output int, @stop bit = 0, @bestoutput int = 0, @reload bit;
DECLARE @input varchar(MAX) = '3,8,1001,8,10,8,105,1,0,0,21,38,55,64,81,106,187,268,349,430,99999,3,9,101,2,9,9,1002,9,2,9,101,5,9,9,4,9,99,3,9,102,2,9,9,101,3,9,9,1002,9,4,9,4,9,99,3,9,102,2,9,9,4,9,99,3,9,1002,9,5,9,1001,9,4,9,102,4,9,9,4,9,99,3,9,102,2,9,9,1001,9,5,9,102,3,9,9,1001,9,4,9,102,5,9,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,1,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,101,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,1,9,9,4,9,99,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,99,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,99';

DECLARE @sequence table
(
	[sequence]	varchar(5) NOT NULL
);

WITH [Numbers] AS
(
	SELECT N=5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9
)
, [Combos] AS
(
	SELECT	[Sequence] = CAST([N] AS varchar(10)), [Level]=0
	FROM	[Numbers]

	UNION ALL 

	SELECT	CAST([C].[Sequence] + [ToString].[NC] AS varchar(10)), [C].[Level]+1
	FROM	[Combos] [C]
	CROSS JOIN [Numbers] [N]
	CROSS APPLY (SELECT [NC] = CAST([N].[N] AS varchar(1))) [ToString]
	WHERE	[C].[Level]<4
	AND		CHARINDEX([ToString].[NC], [C].[Sequence]) = 0
)
INSERT INTO	@sequence
SELECT		[C].[Sequence]
FROM		[Combos] [C]
WHERE		[C].[Level] = 4

DECLARE c CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
SELECT [sequence] FROM @sequence

OPEN c

DECLARE @value varchar(10), @phase0 int, @phase1 int, @phase2 int, @phase3 int, @phase4 int;

FETCH NEXT FROM c INTO @value;

WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT	@phase0		= TRY_CAST(SUBSTRING(@value, 1, 1) AS int)
			,@phase1	= TRY_CAST(SUBSTRING(@value, 2, 1) AS int)
			,@phase2	= TRY_CAST(SUBSTRING(@value, 3, 1) AS int)
			,@phase3	= TRY_CAST(SUBSTRING(@value, 4, 1) AS int)
			,@phase4	= TRY_CAST(SUBSTRING(@value, 5, 1) AS int)
			,@output	= 0
			,@reload	= 0
			,@stop		= 0;

	WHILE @stop = 0
	BEGIN
		EXEC [dbo].[#up_Computer] @input = @input, @phase=@phase0, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT, @reload = @reload;
		EXEC [dbo].[#up_Computer] @input = @input, @phase=@phase1, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT, @reload = @reload;
		EXEC [dbo].[#up_Computer] @input = @input, @phase=@phase2, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT, @reload = @reload;
		EXEC [dbo].[#up_Computer] @input = @input, @phase=@phase3, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT, @reload = @reload;
		EXEC [dbo].[#up_Computer] @input = @input, @phase=@phase4, @userinput = @output, @debug = 0, @output = @output OUTPUT, @stop = @stop OUTPUT, @reload = @reload;

		SELECT @reload = 1;
	END

	IF @bestoutput < @output
	BEGIN
		SELECT @bestoutput = @output;
	END

	FETCH NEXT FROM c INTO @value;
END

CLOSE c;
DEALLOCATE c;

SELECT @bestoutput;
GO
