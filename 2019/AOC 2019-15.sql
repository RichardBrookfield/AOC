USE [Richard];
GO

DROP PROCEDURE IF EXISTS [#up_Computer];
DROP PROCEDURE IF EXISTS [#up_Show];
DROP TABLE IF EXISTS [##SavedState];
DROP TABLE IF EXISTS [##opcode];
DROP TABLE IF EXISTS [##map];
GO

CREATE TABLE [##SavedState]
(
	[Phase]		bigint	NOT NULL
	,[Position]	bigint	NOT NULL
	,[Value]	bigint	NOT NULL
);

CREATE TABLE [##opcode]
(
	[Position]	bigint	IDENTITY(0,1)
	,[Value]	bigint	NOT NULL
);

CREATE TABLE [##map]
(
	[x]			int
	,[y]		int
	,[Value]	int
	,[From]		int
	,[Order]	int NOT NULL IDENTITY(1,1)
	,[Distance]	int
	,[Oxygen]	int
);
GO

CREATE PROCEDURE [#up_Show](
	@moves		int
)
AS
BEGIN
	DECLARE @row int, @col int, @mincol int, @maxcol int, @maxrow int, @value int, @line varchar(MAX);

	WITH [XandY] AS
	(
		SELECT	*
		FROM	[##map]
	)
	SELECT	@row		= MIN([y])
			,@maxrow	= MAX([y])
			,@mincol	= MIN([x])
			,@maxcol	= MAX([x])
	FROM	[XandY];

	SELECT	@col = @mincol;

	PRINT 'Progress: ' + CAST(@moves AS varchar(10))
			+ ' X=[' + CAST(@mincol AS varchar(10))	+ ',' + CAST(@maxcol AS varchar(10)) + ']'
			+ ' Y=[' + CAST(@row AS varchar(10))	+ ',' + CAST(@maxrow AS varchar(10)) + ']';

	WHILE @row <= @maxrow
	BEGIN
		SELECT @line = '', @col = @mincol;

		WHILE @col <= @maxcol
		BEGIN
			SELECT	@value = -1;

			SELECT	@value = [value]
			FROM	[##map]
			WHERE	[x]		= @col
			AND		[y]		= @row;

				
			SELECT @line += CASE WHEN @col = 0 AND @row = 0
								THEN '+'
								ELSE CASE @value
									WHEN 0 THEN '#'
									WHEN 1 THEN '.'
									WHEN 2 THEN 'O'
									ELSE '?'
									END
								END;

			SELECT @col +=1;
		END

		PRINT @line;
		SELECT @row += 1;
	END

	PRINT '';
END
GO

CREATE PROCEDURE [#up_Computer]
	@input			varchar(MAX)
	,@phase			int		= 0
	,@usephase		bit		= 0
	,@userinput		int
	,@debug			bit		= 0
	,@pauseonoutput	bit		= 0
	,@output		bigint	OUTPUT
	,@stop			bit		OUTPUT
	,@reload		bit		= 0
	,@maxloops		int		= 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @loops int = 0, @phaseused bit = 0;

	DECLARE @sp int = 0, @op int, @p1 bigint, @p2 bigint, @p3 bigint, @res bigint, @pause bit = 0, @base bigint = 0;
	DECLARE @v1 bigint, @v2 bigint, @pm1 int, @pm2 int, @pm3 int, @pos bigint;

	IF @reload = 1
	BEGIN
		SELECT		@sp			= [Value]
					,@phaseused	= 1
		FROM		[##SavedState]
		WHERE		[Phase]		= @phase
		AND			[Position]	= -1;

		SELECT		@base		= [Value]
		FROM		[##SavedState]
		WHERE		[Phase]		= @phase
		AND			[Position]	= -2;
	END
	ELSE
	BEGIN
		INSERT INTO ##opcode ([value])
		SELECT [value] FROM STRING_SPLIT(@input, ',');
	END

	SELECT @stop = 0;

	WHILE @stop = 0 AND @pause = 0 --AND @sp < (SELECT COUNT(*) FROM ##opcode)
	BEGIN
		SELECT	@op		= [Value] % 100
				,@pm1	= [Value] /   100 % 10
				,@pm2	= [Value] /  1000 % 10
				,@pm3	= [Value] / 10000 % 10
		FROM	##opcode
		WHERE	[Position] = @sp;

		IF @debug = 1
			SELECT CASE @op
						WHEN 1	THEN	'01: p3 = p1+p2'
						WHEN 2	THEN	'02: p3 = p1*p2'
						WHEN 3	THEN	'03: p3 = <input>'
						WHEN 4	THEN	'04: output p1'
						WHEN 5	THEN	'05: if p1 <> 0  then sp = p2'
						WHEN 6	THEN	'06: if p1 == 0  then sp = p2'
						WHEN 7	THEN	'07: if p1 <  p2 then p3 = 1 else p3 = 0'
						WHEN 8	THEN	'08: if p1 == p2 then p3 = 1 else p3 = 0'
						WHEN 9	THEN	'09: base += p1'
						WHEN 99	THEN	'99: stop'
						ELSE			'UKNOWN'
						END;
		IF @op = 99
		BEGIN
			SET @stop = 1;
		END
		ELSE
		BEGIN
			SELECT @p1 = [Value]	FROM ##opcode WHERE [Position] = @sp+1;
			SELECT @p2 = [Value]	FROM ##opcode WHERE [Position] = @sp+2;
			SELECT @p3 = [Value]	FROM ##opcode WHERE [Position] = @sp+3;

			IF @debug = 1
				SELECT 111,
						op=@op, res=@res, sp=@sp, base=@base, p1=@p1, p2=@p2, p3=@p3, pm1=@pm1, pm2=@pm2, pm3=@pm3, v1=@v1, v2=@v2;

			SELECT	@v1 = CASE WHEN @pm1 = 1 THEN @p1 ELSE ISNULL(
							(	SELECT	[Value]
								FROM	##opcode
								WHERE	[Position] =  CASE WHEN @pm1 = 2 THEN @base ELSE 0 END + @p1
							),0)
							END;

			SELECT	@v2 = CASE WHEN @pm2 = 1 THEN @p2 ELSE ISNULL(
							(	SELECT	[Value]
								FROM	##opcode
								WHERE	[Position] = CASE WHEN @pm2 = 2 THEN @base ELSE 0 END + @p2
							),0)
							END;

			IF @debug = 1
				SELECT 222,
						op=@op, res=@res, sp=@sp, base=@base, p1=@p1, p2=@p2, p3=@p3, pm1=@pm1, pm2=@pm2, pm3=@pm3, v1=@v1, v2=@v2;

			SELECT @res = CASE
							WHEN @op = 1				THEN @v1 + @v2
							WHEN @op = 2				THEN @v1 * @v2
							WHEN @op BETWEEN 3 AND 9	THEN 0
							ELSE 1/0					-- Force a SQL halt on all unknown values
							END

			IF @op = 3
			BEGIN
				IF @usephase = 0
					SELECT @phaseused = 1;

				IF @phaseused = 1
				BEGIN
					SELECT @res = @userinput;
				END
				ELSE
				BEGIN
					SELECT @res = @phase, @phaseused = 1;
				END
			END

			IF @op = 4
			BEGIN
				SELECT	@output = @v1, @pause = @pauseonoutput;

				IF @pauseonoutput = 0
					SELECT [Output] = @output;
			END

			IF @op = 5
				SELECT @sp = CASE WHEN @v1 <> 0 THEN @v2 ELSE @sp+3 END;

			IF @op = 6
				SELECT @sp = CASE WHEN @v1 = 0 THEN @v2 ELSE @sp+3 END;

			IF @op IN (7,8)
			BEGIN
				SELECT @pos = CASE WHEN @pm3 = 2 THEN @base ELSE 0 END + @p3;

				IF NOT EXISTS (SELECT 1 FROM ##opcode WHERE [Position] = @pos)
				BEGIN
					SET IDENTITY_INSERT [##opcode] ON;
					INSERT INTO ##opcode ([Position], [Value])
						VALUES (@pos, 0);
					SET IDENTITY_INSERT [##opcode] OFF;
				END

				UPDATE	##opcode
				SET		[Value]		= CASE WHEN @op = 7 AND @v1 < @v2 OR @op = 8 AND @v1 = @v2
										THEN 1 ELSE 0 END
				WHERE	[Position]	= @pos;
			END

			IF @op = 9
				SELECT @base += @v1;

			IF @debug = 1
				SELECT 333,
						op=@op, res=@res, sp=@sp, base=@base, p1=@p1, p2=@p2, p3=@p3, pm1=@pm1, pm2=@pm2, pm3=@pm3, v1=@v1, v2=@v2;

			IF @op IN (1,2,3)
			BEGIN
				SELECT @pos = CASE WHEN @op IN (1,2)
								THEN @p3 + CASE WHEN @pm3 = 2 THEN @base ELSE 0 END
								ELSE @p1 + CASE WHEN @pm1 = 2 THEN @base ELSE 0 END
								END;

				IF NOT EXISTS (SELECT 1 FROM ##opcode WHERE [Position] = @pos)
				BEGIN
					SET IDENTITY_INSERT [##opcode] ON;
					INSERT INTO ##opcode ([Position], [Value])
						VALUES (@pos, 0);
					SET IDENTITY_INSERT [##opcode] OFF;
				END

				UPDATE	##opcode
				SET		[Value]		= @res
				WHERE	[Position]	= @pos;
			END

			IF @debug = 1
				SELECT 444,
						op=@op, res=@res, sp=@sp, base=@base, p1=@p1, p2=@p2, p3=@p3, pm1=@pm1, pm2=@pm2, pm3=@pm3, v1=@v1, v2=@v2;

			IF @debug = 1
				SELECT * FROM ##opcode WHERE [Value] <> 0;

			SELECT @sp += CASE
							WHEN @op IN (1,2)	THEN 4
							WHEN @op IN (3,4)	THEN 2
							WHEN @op IN (7,8)	THEN 4
							WHEN @op IN (9)		THEN 2
							ELSE 0
							END;

			-- Stops any craziness... just in case.
			SELECT @loops += 1;

			IF @maxloops > 0 AND @loops > @maxloops
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

			SELECT	@phase, -1, @sp

			UNION ALL

			SELECT	@phase, -2, @base;
		END
	END
END
GO

-- Part 1: straight in...
DECLARE @output bigint = 0, @stop bit = 0, @x int = 0, @y int = 0, @xnew int = 0, @ynew int = 0, @value int = 0, @userinput int = 0, @reload int = 0;
DECLARE @input varchar(MAX) = '3,1033,1008,1033,1,1032,1005,1032,31,1008,1033,2,1032,1005,1032,58,1008,1033,3,1032,1005,1032,81,1008,1033,4,1032,1005,1032,104,99,1002,1034,1,1039,102,1,1036,1041,1001,1035,-1,1040,1008,1038,0,1043,102,-1,1043,1032,1,1037,1032,1042,1106,0,124,1002,1034,1,1039,1001,1036,0,1041,1001,1035,1,1040,1008,1038,0,1043,1,1037,1038,1042,1105,1,124,1001,1034,-1,1039,1008,1036,0,1041,1001,1035,0,1040,1002,1038,1,1043,101,0,1037,1042,1105,1,124,1001,1034,1,1039,1008,1036,0,1041,102,1,1035,1040,1001,1038,0,1043,101,0,1037,1042,1006,1039,217,1006,1040,217,1008,1039,40,1032,1005,1032,217,1008,1040,40,1032,1005,1032,217,1008,1039,1,1032,1006,1032,165,1008,1040,9,1032,1006,1032,165,1102,1,2,1044,1105,1,224,2,1041,1043,1032,1006,1032,179,1102,1,1,1044,1106,0,224,1,1041,1043,1032,1006,1032,217,1,1042,1043,1032,1001,1032,-1,1032,1002,1032,39,1032,1,1032,1039,1032,101,-1,1032,1032,101,252,1032,211,1007,0,35,1044,1106,0,224,1101,0,0,1044,1105,1,224,1006,1044,247,102,1,1039,1034,1002,1040,1,1035,1002,1041,1,1036,102,1,1043,1038,101,0,1042,1037,4,1044,1105,1,0,1,5,41,19,22,1,39,81,29,20,15,82,33,18,45,30,32,55,28,26,70,13,56,32,28,18,3,59,90,11,95,15,85,8,61,25,59,24,34,1,85,5,25,54,57,18,20,54,80,91,28,65,36,12,44,36,13,92,24,56,13,39,69,29,79,10,41,27,23,25,72,20,3,61,15,51,11,12,12,48,10,45,13,29,49,90,30,17,9,41,21,18,7,30,48,17,83,71,4,10,31,10,96,81,77,9,50,39,21,36,33,72,12,3,23,79,18,4,75,17,58,64,8,7,97,60,72,72,1,94,55,42,2,94,2,21,88,19,82,57,96,19,25,27,41,62,15,40,23,61,86,27,73,61,13,46,52,81,12,34,23,73,23,59,1,30,47,9,99,10,37,17,28,98,5,92,73,8,63,4,86,76,79,7,30,68,28,91,12,12,98,74,4,22,44,10,23,45,37,16,90,76,23,74,75,12,21,38,14,15,76,28,49,71,7,6,6,71,53,33,12,87,15,92,66,21,38,13,53,92,34,49,25,6,67,21,27,89,24,61,25,30,41,30,99,28,19,41,90,51,74,14,33,54,48,10,14,42,2,67,76,10,21,2,67,43,27,69,11,16,78,7,36,9,24,48,63,81,53,29,94,34,25,99,66,47,17,97,33,52,11,62,22,52,30,23,89,95,15,13,50,48,26,10,6,69,78,13,6,94,1,28,67,10,70,16,50,19,24,15,79,50,27,3,19,62,4,31,83,20,17,83,67,5,80,26,36,62,87,3,10,80,22,65,60,10,78,4,20,60,30,11,7,83,10,13,72,81,37,22,14,55,63,51,27,32,77,52,20,50,16,48,2,55,10,53,26,84,6,87,43,37,26,3,85,62,25,78,50,16,10,37,22,54,5,80,24,7,32,49,18,27,12,41,70,82,20,34,91,15,98,77,22,6,79,3,8,54,17,32,4,44,2,97,14,15,65,30,97,14,79,75,11,77,5,61,37,20,91,20,45,74,19,40,2,41,89,12,34,44,18,62,57,17,68,22,96,7,59,63,2,60,70,2,26,75,26,3,53,19,80,16,97,7,34,58,52,66,24,75,25,30,75,42,13,12,89,13,3,84,92,1,75,30,54,43,2,56,15,1,15,84,99,6,98,42,17,29,1,18,26,70,71,29,91,23,21,87,66,18,38,32,18,81,65,2,58,99,12,4,84,24,32,88,30,67,49,29,59,64,18,70,10,24,56,5,27,97,50,4,28,85,65,16,67,83,15,16,61,18,86,8,36,25,36,29,97,45,19,81,41,29,45,30,69,26,57,93,27,72,34,30,99,61,2,48,16,12,76,98,28,14,32,32,90,48,10,30,57,23,39,2,8,39,33,13,88,34,31,74,15,60,8,47,60,31,5,79,1,98,86,33,3,99,33,62,11,96,25,22,38,98,84,3,56,70,49,3,8,56,87,4,29,59,65,26,34,77,7,14,78,26,25,70,49,3,31,45,92,24,95,17,4,9,4,96,64,92,27,67,4,99,6,44,7,16,86,2,75,1,6,68,81,4,1,44,49,7,92,8,40,36,25,81,13,56,99,10,2,30,72,6,43,30,12,43,93,19,20,23,95,10,19,66,63,28,96,40,50,8,15,56,38,13,93,42,71,12,18,87,8,4,21,85,9,2,66,77,10,80,26,61,9,43,20,88,10,39,67,55,31,49,17,58,26,80,20,84,54,49,5,73,11,52,15,63,7,62,24,57,92,61,25,87,56,37,31,38,14,99,0,0,21,21,1,10,1,0,0,0,0,0,0';

DECLARE @moves int = 0, @goback bit = 0, @newtarget bit;

SET NOCOUNT ON;

INSERT INTO	[##map] ([x], [y], [Value], [From])
VALUES (0, 0, 1, 1);

WHILE @stop = 0 AND @moves < 4000
BEGIN
	SELECT @moves += 1, @newtarget = 0;

	-- Directions: 1-N, 2-S, 3-W, 4-E
	IF @goback <> 1
		SELECT @userinput = 1;

	--PRINT 'Current location';
	--PRINT @x;
	--PRINT @y;

	WHILE @userinput < 5 AND @newtarget = 0
	BEGIN
		SELECT	@xnew	= @x + CASE @userinput
								WHEN 3 THEN -1
								WHEN 4 THEN 1
								ELSE 0
								END
				,@ynew	= @y + CASE @userinput
								WHEN 1 THEN -1
								WHEN 2 THEN 1
								ELSE 0
								END;
		--PRINT 'Try direction';
		--PRINT @xnew;
		--PRINT @ynew;

		IF @goback = 1
			OR NOT EXISTS (SELECT 1 FROM [##map] WHERE [x] = @xnew AND [y] = @ynew)
		BEGIN
			--PRINT 'Choose direction';
			SELECT @newtarget = 1;
		END
		ELSE
		BEGIN
			--PRINT 'Increment direction';
			SELECT @userinput += 1;
		END
	END

	-- No valid routes so go back...
	IF @newtarget = 0
	BEGIN
		SELECT	@userinput = CASE [From]
								WHEN 1 THEN 2
								WHEN 2 THEN 1
								WHEN 3 THEN 4
								WHEN 4 THEN 3
								ELSE (SELECT 1/0)
								END
		FROM	[##map]
		WHERE	[x] = @x
		AND		[y] = @y;

		--PRINT 'Go back';
		--PRINT @xnew;
		--PRINT @ynew;

		IF @x = 0 AND @y = 0
			SELECT @stop = 1;
		ELSE
		BEGIN
			SELECT @goback = 1;
			CONTINUE;
		END
	END

	IF @stop = 0
	BEGIN
		EXEC [dbo].[#up_Computer] @input = @input, @userinput = @userinput, @reload = @reload, @output = @output OUTPUT, @stop = @stop OUTPUT, @maxloops = -1, @pauseonoutput = 1;

		SELECT @reload = 1, @value = @output;
		--PRINT 'Result';
		--PRINT @userinput;
		--PRINT @output;

		-- Replies: 0 - wall, 1 - moved, 2 - moved and O-location
		IF @value <> 0
		BEGIN
			--PRINT 'Move';
			SELECT	@x = @xnew, @y = @ynew;
		END

		--PRINT 'New insert'
		IF @goback = 0
			INSERT INTO
					[##map] ([x], [y], [Value], [From])
			VALUES	(@xnew, @ynew, @value, @userinput);
		ELSE
			SELECT @goback = 0;
	END

	IF (@moves%100) = 0 OR @stop = 1
	BEGIN
		EXEC [dbo].[#up_Show] @moves=@moves;
	END
END

UPDATE	[##map]
SET		[Distance]	= 0
		,[Oxygen]	= 0;

UPDATE	[##map]
SET		[Distance]	= 1
WHERE	[x]			= 0
AND		[y]			= 0;

UPDATE	[##map]
SET		[Oxygen]	= 1
WHERE	[Value]		= 2;

/*
-- During the following loop, you can use this SQL to get progress:

SELECT	COUNT(*)
FROM	[##map]
WHERE	[Value]			<> 0
AND		(	[Distance]	=  0
		OR	[Oxygen]	=  0
		)

*/

WHILE EXISTS (SELECT 1 FROM [##map] WHERE [Value] <> 0 AND [Distance] = 0)
	OR EXISTS (SELECT 1 FROM [##map] WHERE [Value] <> 0 AND [Oxygen] = 0)
BEGIN
	UPDATE	[M1]
	SET		[M1].[Distance] = [M0].[Distance]+1
	FROM	[##map] [M1]
	JOIN	[##map] [M0]	ON	[M0].[Distance]		<> 0
							AND	[M0].[Value]		<> 0
							AND	ABS([M1].[x] - [M0].[x]) + ABS([M1].[y] - [M0].[y]) = 1
	WHERE	[M1].[Distance]	= 0
	AND		[M1].[Value]	<> 0

	UPDATE	[M1]
	SET		[M1].[Oxygen] = [M0].[Oxygen]+1
	FROM	[##map] [M1]
	JOIN	[##map] [M0]	ON	[M0].[Oxygen]		<> 0
							AND	[M0].[Value]		<> 0
							AND	ABS([M1].[x] - [M0].[x]) + ABS([M1].[y] - [M0].[y]) = 1
	WHERE	[M1].[Oxygen]	= 0
	AND		[M1].[Value]	<> 0
END

-- We started at 1, so the target is one less (in both cases).
SELECT	[Distance]-1
FROM	[##map]
WHERE	[Value] = 2;

SELECT	MAX([Oxygen])-1
FROM	[##map];
