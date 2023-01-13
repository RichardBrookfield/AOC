USE [Richard];
GO

--DECLARE @input varchar(MAX) = '1,9,10,3,2,3,11,0,99,30,40,50';	-- Result: 3500,9,10,70,2,3,11,0,99,30,40,50
--DECLARE @input varchar(MAX) = '1,0,0,0,99';						-- Result: 2,0,0,0,99 (1 + 1 = 2).	
--DECLARE @input varchar(MAX) = '2,3,0,3,99';						-- Result: 2,3,0,6,99 (3 * 2 = 6).
--DECLARE @input varchar(MAX) = '2,4,4,5,99,0';						-- Result: 2,4,4,5,99,9801 (99 * 99 = 9801).
--DECLARE @input varchar(MAX) = '1,1,1,4,99,5,6,0,99';				-- Result: 30,1,1,4,2,5,6,0,99.

-- NOTE: The actual test has a manual edit of [1] = 12 and [2] = 2;
DECLARE @input varchar(MAX) = '1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,1,13,19,1,9,19,23,2,13,23,27,2,27,13,31,2,31,10,35,1,6,35,39,1,5,39,43,1,10,43,47,1,5,47,51,1,13,51,55,2,55,9,59,1,6,59,63,1,13,63,67,1,6,67,71,1,71,10,75,2,13,75,79,1,5,79,83,2,83,6,87,1,6,87,91,1,91,13,95,1,95,13,99,2,99,13,103,1,103,5,107,2,107,10,111,1,5,111,115,1,2,115,119,1,119,6,0,99,2,0,14,0';

DECLARE @ApplyUpdate bit = 1;

-- 19690720
DECLARE @noun int = 65, @verb int = 33;

DECLARE @opcode table
(
	[Position]	int	IDENTITY(0,1)
	,[Value]	int	NOT NULL
)

INSERT INTO @opcode
SELECT value FROM STRING_SPLIT(@input, ',');

UPDATE	@opcode
SET		[Value]		= CASE WHEN [Position] = 1 THEN @noun ELSE @verb END
WHERE	[Position]	IN (1,2)
AND		@ApplyUpdate = 1;

DECLARE @sp int = 0, @op int, @r1 int, @r2 int, @r3 int, @res int, @stop int = 0;

WHILE @stop = 0 AND @sp < (SELECT COUNT(*) FROM @opcode)
BEGIN
	SELECT @op = [Value] FROM @opcode WHERE [Position] = @sp;

	IF @op = 99
	BEGIN
		SET @stop = 1
	END
	ELSE
	BEGIN
		SELECT @r1 = [Value]	FROM @opcode WHERE [Position] = @sp+1;
		SELECT @r2 = [Value]	FROM @opcode WHERE [Position] = @sp+2;
		SELECT @r3 = [Value]	FROM @opcode WHERE [Position] = @sp+3;

		SELECT @r1 = [Value]	FROM @opcode WHERE [Position] = @r1;
		SELECT @r2 = [Value]	FROM @opcode WHERE [Position] = @r2;

		SELECT @res = CASE
						WHEN @op = 1 THEN @r1 + @r2
						WHEN @op = 2 THEN @r1 * @r2
						ELSE 1/0			-- Force a SQL halt
						END

		UPDATE	@opcode
		SET		[Value]		= @res
		WHERE	[Position]	= @r3;

		SELECT @sp += 4;
	END
END

SELECT [Value] FROM @opcode WHERE [Position] = 0;
