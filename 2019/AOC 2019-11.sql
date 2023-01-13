USE [Richard];
GO

DROP PROCEDURE IF EXISTS [#up_Computer];
DROP TABLE IF EXISTS [##SavedState];
DROP TABLE IF EXISTS [##opcode];
GO

CREATE TABLE [##SavedState]
(
	[Phase]		bigint	NOT NULL
	,[Position]	bigint	NOT NULL
	,[Value]	bigint	NOT NULL
);

CREATE TABLE ##opcode
(
	[Position]	bigint	IDENTITY(0,1)
	,[Value]	bigint	NOT NULL
);
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
		--INSERT INTO ##opcode
		--SELECT		[Value]
		--FROM		[##SavedState]
		--WHERE		[Phase]		= @phase
		--AND			[Position]	>= 0
		--ORDER BY	[Position];

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
				--SELECT	@pos = CASE WHEN @pm3 = 1 THEN @p3 ELSE ISNULL(
				--				(	SELECT	[Value]
				--					FROM	##opcode
				--					WHERE	[Position] =  CASE WHEN @pm3 = 2 THEN @base ELSE 0 END + @p3
				--				),0)
				--				END;
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

			--SELECT	@phase, [Position], [Value] 
			--FROM	##opcode

			--UNION ALL

			SELECT	@phase, -1, @sp

			UNION ALL

			SELECT	@phase, -2, @base;
		END
	END
END
GO

-- Part 1: straight in...
DECLARE @output bigint = 0, @stop bit = 0, @x int = 0, @y int = 0, @direction int = 0, @userinput int, @reload int = 0;
DECLARE @input varchar(MAX) = '3,8,1005,8,328,1106,0,11,0,0,0,104,1,104,0,3,8,1002,8,-1,10,1001,10,1,10,4,10,1008,8,0,10,4,10,1001,8,0,29,1,104,7,10,3,8,1002,8,-1,10,101,1,10,10,4,10,1008,8,0,10,4,10,1001,8,0,55,1,2,7,10,1006,0,23,3,8,102,-1,8,10,1001,10,1,10,4,10,1008,8,0,10,4,10,1001,8,0,84,1006,0,40,1,1103,14,10,1,1006,16,10,3,8,102,-1,8,10,101,1,10,10,4,10,108,1,8,10,4,10,1002,8,1,116,1006,0,53,1,1104,16,10,3,8,102,-1,8,10,101,1,10,10,4,10,1008,8,1,10,4,10,102,1,8,146,2,1104,9,10,3,8,102,-1,8,10,101,1,10,10,4,10,1008,8,1,10,4,10,1001,8,0,172,1006,0,65,1,1005,8,10,1,1002,16,10,3,8,102,-1,8,10,1001,10,1,10,4,10,108,0,8,10,4,10,102,1,8,204,2,1104,9,10,1006,0,30,3,8,102,-1,8,10,101,1,10,10,4,10,108,0,8,10,4,10,102,1,8,233,2,1109,6,10,1006,0,17,1,2,6,10,3,8,102,-1,8,10,101,1,10,10,4,10,108,1,8,10,4,10,102,1,8,266,1,106,7,10,2,109,2,10,2,9,8,10,3,8,102,-1,8,10,101,1,10,10,4,10,1008,8,1,10,4,10,1001,8,0,301,1,109,9,10,1006,0,14,101,1,9,9,1007,9,1083,10,1005,10,15,99,109,650,104,0,104,1,21102,1,837548789788,1,21101,0,345,0,1106,0,449,21101,0,846801511180,1,21101,0,356,0,1106,0,449,3,10,104,0,104,1,3,10,104,0,104,0,3,10,104,0,104,1,3,10,104,0,104,1,3,10,104,0,104,0,3,10,104,0,104,1,21101,235244981271,0,1,21101,403,0,0,1105,1,449,21102,1,206182744295,1,21101,0,414,0,1105,1,449,3,10,104,0,104,0,3,10,104,0,104,0,21102,837896937832,1,1,21101,0,437,0,1106,0,449,21101,867965862668,0,1,21102,448,1,0,1106,0,449,99,109,2,22102,1,-1,1,21101,40,0,2,21102,1,480,3,21101,0,470,0,1106,0,513,109,-2,2106,0,0,0,1,0,0,1,109,2,3,10,204,-1,1001,475,476,491,4,0,1001,475,1,475,108,4,475,10,1006,10,507,1101,0,0,475,109,-2,2106,0,0,0,109,4,1201,-1,0,512,1207,-3,0,10,1006,10,530,21102,1,0,-3,22102,1,-3,1,21201,-2,0,2,21102,1,1,3,21102,549,1,0,1106,0,554,109,-4,2105,1,0,109,5,1207,-3,1,10,1006,10,577,2207,-4,-2,10,1006,10,577,21202,-4,1,-4,1106,0,645,21202,-4,1,1,21201,-3,-1,2,21202,-2,2,3,21101,596,0,0,1106,0,554,21201,1,0,-4,21102,1,1,-1,2207,-4,-2,10,1006,10,615,21101,0,0,-1,22202,-2,-1,-2,2107,0,-3,10,1006,10,637,22102,1,-1,1,21101,637,0,0,105,1,512,21202,-2,-1,-2,22201,-4,-2,-4,109,-5,2106,0,0';
DECLARE @row int, @maxrow int, @col int, @mincol int, @maxcol int, @line varchar(MAX);
DECLARE @painting table (
	[x]			int
	,[y]		int
	,[white]	bit
);
DECLARE @moves int = 0;

SET NOCOUNT ON;

-- Just for part 2:
INSERT INTO @painting ([x], [y], [white])
	VALUES (0, 0, 1);

WHILE @stop = 0
BEGIN
	SELECT	@userinput = CASE WHEN EXISTS (
								SELECT	1
								FROM	@painting
								WHERE	[x]		= @x
								AND		[y]		= @y
								AND		[white]	= 1
								)
							THEN 1 ELSE 0 END;

	EXEC [dbo].[#up_Computer] @input = @input, @userinput = @userinput, @reload = @reload, @output = @output OUTPUT, @stop = @stop OUTPUT, @maxloops = -1, @pauseonoutput = 1;

	SELECT @reload = 1;

	IF @stop = 0
	BEGIN
		-- 0=Black	1=White
		UPDATE	@painting
		SET		[white] = @output
		WHERE	[x] = @x
		AND		[y] = @y;

		IF @@ROWCOUNT = 0
			INSERT INTO
					@painting ([x], [y], [white])
			VALUES	(@x, @y, @output);

		EXEC [dbo].[#up_Computer] @input = @input, @userinput = @userinput, @reload = @reload, @output = @output OUTPUT, @stop = @stop OUTPUT, @maxloops = -1, @pauseonoutput = 1;
	END

	-- 0=Left	1=Right
	SELECT	@direction	= (@direction +
							CASE WHEN @output = 0 THEN 3 ELSE 1 END
							) % 4
	SELECT	@x			+= CASE @direction
								WHEN 0 THEN 0
								WHEN 1 THEN 1
								WHEN 2 THEN 0
								WHEN 3 THEN -1
								ELSE 1/0
								END
			,@y			+= CASE @direction
								WHEN 0 THEN -1
								WHEN 1 THEN 0
								WHEN 2 THEN 1
								WHEN 3 THEN 0
								ELSE 1/0
								END;

	IF (SELECT COUNT(*) FROM @painting) > 20000 OR @moves > 12000
		SELECT @stop = 1;

	SELECT @moves += 1;

	-- PRINT 'x=' + CAST(@x AS varchar(3)) + ' y=' + CAST(@y AS varchar(3)) + ' dir=' + CAST(@direction AS varchar(1));

	IF (@moves%1000) = 0 OR @stop = 1
	BEGIN
		WITH [XandY] AS
		(
			SELECT	*
			FROM	@painting

			UNION ALL

			SELECT	@x, @y, 0
		)
		SELECT	@row		= MIN([y])
				,@maxrow	= MAX([y])
				,@mincol	= MIN([x])
				,@maxcol	= MAX([x])
		FROM	[XandY];

		SELECT	@col = @mincol;

		PRINT 'Progress: ' + CAST(@moves AS varchar(10));

		WHILE @row <= @maxrow
		BEGIN
			SELECT @line = '', @col = @mincol;

			WHILE @col <= @maxcol
			BEGIN
				SELECT @line += CASE
									WHEN @row = @y AND @col = @x
									THEN CASE @direction
											WHEN 0 THEN '^ '
											WHEN 1 THEN '> '
											WHEN 2 THEN 'V '
											WHEN 3 THEN '< '
											ELSE CAST(1/0 AS varchar(1))
											END
									WHEN EXISTS (
											SELECT	1
											FROM	@painting
											WHERE	[x]		= @col
											AND		[y]		= @row
											AND		[white]	= 1
											)
									THEN 'X ' ELSE '. ' END;
				SELECT @col +=1;
			END

			PRINT @line;
			SELECT @row += 1;
		END
	END
END

SELECT COUNT(*) FROM @painting;
GO

-- Part 1: 2511
-- Part 2: HJKJKGPH
