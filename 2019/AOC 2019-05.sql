USE [Richard];
GO

--DECLARE @input varchar(MAX) = '3,0,4,0,99';	-- Result: 1
--DECLARE @input varchar(MAX) = '1002,4,3,4,33';	-- Result: None, just terminates correctly
--DECLARE @input varchar(MAX) = '1101,100,-1,4,0';	-- Result: None, just terminates correctly

-- Actual problem Part 1: 12896948, Part 2: 7704130
DECLARE @input varchar(MAX) = '3,225,1,225,6,6,1100,1,238,225,104,0,1102,46,47,225,2,122,130,224,101,-1998,224,224,4,224,1002,223,8,223,1001,224,6,224,1,224,223,223,1102,61,51,225,102,32,92,224,101,-800,224,224,4,224,1002,223,8,223,1001,224,1,224,1,223,224,223,1101,61,64,225,1001,118,25,224,101,-106,224,224,4,224,1002,223,8,223,101,1,224,224,1,224,223,223,1102,33,25,225,1102,73,67,224,101,-4891,224,224,4,224,1002,223,8,223,1001,224,4,224,1,224,223,223,1101,14,81,225,1102,17,74,225,1102,52,67,225,1101,94,27,225,101,71,39,224,101,-132,224,224,4,224,1002,223,8,223,101,5,224,224,1,224,223,223,1002,14,38,224,101,-1786,224,224,4,224,102,8,223,223,1001,224,2,224,1,223,224,223,1,65,126,224,1001,224,-128,224,4,224,1002,223,8,223,101,6,224,224,1,224,223,223,1101,81,40,224,1001,224,-121,224,4,224,102,8,223,223,101,4,224,224,1,223,224,223,4,223,99,0,0,0,677,0,0,0,0,0,0,0,0,0,0,0,1105,0,99999,1105,227,247,1105,1,99999,1005,227,99999,1005,0,256,1105,1,99999,1106,227,99999,1106,0,265,1105,1,99999,1006,0,99999,1006,227,274,1105,1,99999,1105,1,280,1105,1,99999,1,225,225,225,1101,294,0,0,105,1,0,1105,1,99999,1106,0,300,1105,1,99999,1,225,225,225,1101,314,0,0,106,0,0,1105,1,99999,1008,677,226,224,1002,223,2,223,1005,224,329,1001,223,1,223,107,677,677,224,102,2,223,223,1005,224,344,101,1,223,223,1107,677,677,224,102,2,223,223,1005,224,359,1001,223,1,223,1108,226,226,224,1002,223,2,223,1006,224,374,101,1,223,223,107,226,226,224,1002,223,2,223,1005,224,389,1001,223,1,223,108,226,226,224,1002,223,2,223,1005,224,404,1001,223,1,223,1008,677,677,224,1002,223,2,223,1006,224,419,1001,223,1,223,1107,677,226,224,102,2,223,223,1005,224,434,1001,223,1,223,108,226,677,224,102,2,223,223,1006,224,449,1001,223,1,223,8,677,226,224,102,2,223,223,1006,224,464,1001,223,1,223,1007,677,226,224,1002,223,2,223,1006,224,479,1001,223,1,223,1007,677,677,224,1002,223,2,223,1005,224,494,1001,223,1,223,1107,226,677,224,1002,223,2,223,1006,224,509,101,1,223,223,1108,226,677,224,102,2,223,223,1005,224,524,1001,223,1,223,7,226,226,224,102,2,223,223,1005,224,539,1001,223,1,223,8,677,677,224,1002,223,2,223,1005,224,554,101,1,223,223,107,677,226,224,102,2,223,223,1006,224,569,1001,223,1,223,7,226,677,224,1002,223,2,223,1005,224,584,1001,223,1,223,1008,226,226,224,1002,223,2,223,1006,224,599,101,1,223,223,1108,677,226,224,102,2,223,223,1006,224,614,101,1,223,223,7,677,226,224,102,2,223,223,1005,224,629,1001,223,1,223,8,226,677,224,1002,223,2,223,1006,224,644,101,1,223,223,1007,226,226,224,102,2,223,223,1005,224,659,101,1,223,223,108,677,677,224,1002,223,2,223,1006,224,674,1001,223,1,223,4,223,99,226';

-- Part 2 tests...

--DECLARE @input varchar(MAX) = '3,9,8,9,10,9,4,9,99,-1,8';	-- Result: 1 if input = 8 else 0
--DECLARE @input varchar(MAX) = '3,9,7,9,10,9,4,9,99,-1,8';	-- Result: 1 if input < 8 else 0
--DECLARE @input varchar(MAX) = '3,3,1108,-1,8,3,4,3,99';	-- Result: 1 if input = 8 else 0
--DECLARE @input varchar(MAX) = '3,3,1107,-1,8,3,4,3,99';	-- Result: 1 if input < 8 else 0

--DECLARE @input varchar(MAX) = '3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9';	-- Result: 0 if input = 0 else 1
--DECLARE @input varchar(MAX) = '3,3,1105,-1,9,1101,0,0,12,4,12,99,1';	-- Result: 0 if input = 0 else 1

-- Result: <8 -> 999, =8 -> 1000, >8 -> 1001
--DECLARE @input varchar(MAX) = '3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99';

DECLARE @userinput int = 5;

DECLARE @debug bit = 0, @loops int = 0, @maxloops int = 200;

DECLARE @opcode table
(
	[Position]	int	IDENTITY(0,1)
	,[Value]	int	NOT NULL
)

INSERT INTO @opcode
SELECT value FROM STRING_SPLIT(@input, ',');

DECLARE @sp int = 0, @op int, @p1 int, @p2 int, @p3 int, @res int, @stop int = 0;
DECLARE @v1 int, @v2 int, @v3 int, @pm1 int, @pm2 int, @pm3 int;

WHILE @stop = 0 AND @sp < (SELECT COUNT(*) FROM @opcode)
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
						WHEN @op = 3				THEN @userinput
						WHEN @op BETWEEN 4 AND 8	THEN 0
						ELSE 1/0					-- Force a SQL halt on all unknown values
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
			SELECT	[Output] = @v1;
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
END
