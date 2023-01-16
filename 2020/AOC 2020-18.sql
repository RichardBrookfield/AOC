USE [Richard];

SET NOCOUNT ON;

DROP PROCEDURE IF EXISTS #Evaluate;
GO

CREATE PROCEDURE #Evaluate
	@input		varchar(200)
	,@LtoR		bit
	,@result	bigint			OUTPUT
AS
BEGIN
	SELECT	@result = 0;

	DECLARE	@posFirst		int
			,@posOpen		int
			,@posClose		int
			,@posSpace		int
			,@posPlus		int
			,@operatorAdd	bit		
			,@term			varchar(200)
			,@value			bigint;

	SELECT	@posFirst	= CHARINDEX('(', @input);

	IF @posFirst > 0
	BEGIN
		-- We found an open bracket, so look for both the next open and close.
		SELECT	@posOpen	= CHARINDEX('(', @input, @posFirst+1)
				,@posClose	= CHARINDEX(')', @input, @posFirst+1);

		IF @posOpen > 0
		BEGIN
			-- If there's another open bracket then it's complicated.
			SELECT	@posOpen = @posClose-1;

			-- Need to find first open less before the first close, i.e. the first subexpression.
			WHILE SUBSTRING(@input, @posOpen, 1) <> '('
			BEGIN
				SELECT	@posOpen -= 1;
			END

			-- Evaluate that subexpression.
			SELECT	@term = SUBSTRING(@input, @posOpen+1, @posClose-@posOpen-1);

			EXEC [dbo].[#Evaluate] @input = @term, @LtoR = @LtoR, @result = @value OUTPUT;
			
			-- And substitute the result in-place and re-evaluate.
			SELECT	@input = LEFT(@input, @posOpen-1) + CAST(@value AS varchar(20)) + RIGHT(@input, LEN(@input)-@posClose);

			EXEC [dbo].[#Evaluate] @input = @input, @LtoR = @LtoR, @result = @result OUTPUT;
		END
		ELSE IF @posClose > 0
		BEGIN
			-- No other opens and we found the close.
			-- We can just process the innermost set of brackets.
			SELECT	@term = SUBSTRING(@input, @posFirst+1, @posClose-@posFirst-1);

			EXEC [dbo].[#Evaluate] @input = @term, @LtoR = @LtoR, @result = @value OUTPUT;
				
			-- And substitute the result in-place and re-evaluate
			SELECT	@input = LEFT(@input, @posFirst-1) + CAST(@value AS varchar(20)) + RIGHT(@input, LEN(@input)-@posClose);

			EXEC [dbo].[#Evaluate] @input = @input, @LtoR = @LtoR, @result = @result OUTPUT;
		END
		ELSE
		BEGIN
			-- Something went horribly wrong, so forcefully bail out.
			PRINT 'Matching close not found';
			SELECT 1/0;
		END
	END
	ELSE IF @LtoR = 1
	BEGIN
		-- At this we have no brackets and are simply consuming the value left-to-right until complete.
		-- Identify the first value...
		SELECT	@posSpace	= CHARINDEX(' ', @input);
		SELECT	@result		= CAST(SUBSTRING(@input, 1, @posSpace-1) AS int);
		SELECT	@input		= RIGHT(@input, LEN(@input)-@posSpace);

		-- ...then continue to combine with operator-value pairs.
		WHILE LEN(@input) > 0
		BEGIN
			-- Identify the operator
			IF LEFT(@input, 2) = '+ '
			BEGIN
				SELECT	@operatorAdd = 1;
			END
			ELSE IF LEFT(@input, 2) = '* '
			BEGIN
				SELECT	@operatorAdd = 0;
			END
			ELSE
			BEGIN
				SELECT	1/0;
			END

			-- Consume the operator
			SELECT	@input		= RIGHT(@input, LEN(@input)-2);
			SELECT	@posSpace	= CHARINDEX(' ', @input);

			-- Look for the next value (or whole string).
			IF @posSpace > 0
			BEGIN
				SELECT	@value	= CAST(SUBSTRING(@input, 1, @posSpace-1) AS int);
				SELECT	@input	= RIGHT(@input, LEN(@input)-@posSpace);
			END
			ELSE
			BEGIN
				SELECT	@value	= CAST(@input AS int);
				SELECT	@input	= '';
			END

			-- Combine it with the current result.
			SELECT	@result = CASE WHEN @operatorAdd = 1
									THEN @result + @value
									ELSE @result * @value
									END;
		END
	END
	ELSE
	BEGIN
		SELECT	@posPlus = CHARINDEX('+', @input);

		IF @posPlus > 0
		BEGIN
			-- We have a plus sign and no brackets
			SELECT	@posFirst = @posPlus - 2;

			-- Locate the term before...
			WHILE @posFirst > 1
			BEGIN
				IF SUBSTRING(@input, @posFirst, 1) = ' '
				BEGIN
					SELECT	@posFirst += 1;
					BREAK;
				END

				SELECT	@posFirst -= 1;
			END

			-- ...and the one after.
			SELECT	@posPlus += 2;

			WHILE @posPlus < LEN(@input)
			BEGIN
				IF SUBSTRING(@input, @posPlus, 1) = ' '
				BEGIN
					SELECT	@posPlus -= 1;
					BREAK;
				END

				SELECT	@posPlus += 1;
			END
		
			-- Evaluate the sum
			SELECT	@term = SUBSTRING(@input, @posFirst, @posPlus-@posFirst+1);

			EXEC [dbo].[#Evaluate] @input = @term, @LtoR = 1, @result = @value OUTPUT;

			-- And substitute the result in-place and re-evaluate
			SELECT	@input = SUBSTRING(@input, 1, @posFirst-1) + CAST(@value AS varchar(20)) + RIGHT(@input, LEN(@input)-@posPlus);

			EXEC [dbo].[#Evaluate] @input = @input, @LtoR = @LtoR, @result = @result OUTPUT;
		END
		ELSE IF CHARINDEX('*', @input) > 0
		BEGIN
			EXEC [dbo].[#Evaluate] @input = @input, @LtoR = 1, @result = @result OUTPUT;
		END
		ELSE
		BEGIN
			-- If there's no multiply then it's just a value
			SELECT	@result = CAST(@input AS bigint);
		END
	END
END
GO

-- Test
DECLARE @inputT	varchar(MAX) = '
1 + 2 * 3 + 4 * 5 + 6
1 + (2 * 3) + (4 * (5 + 6))
2 * 3 + (4 * 5)
5 + (8 * 3 + 9 + 3 * 4 * 3)
5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))
((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2
';

-- Puzzle
DECLARE @input	varchar(MAX) = '
9 * 8 + 2 + (4 * (2 * 2 + 9 * 2) * 9 * 3 * 8) + 8 * 5
8 * (9 + 5 + 5 * 6 + 8 * 3) * 5 * 7 * 4 + 9
(9 + (2 * 6 + 7 * 5)) * (7 + 7 * 5 + (6 + 2 + 6) * (7 * 8 * 8 + 9)) + 4 * 2
((8 + 3 * 6 * 2) * 9 + 3) + 5 + 6 * 3
6 * (9 + 6 * (7 + 4 + 2 + 5 + 6) * 7 + 3 * (5 * 8 * 6 + 6 * 7 * 8)) + (8 * 8 + 4) + (5 * (2 + 9) * 8) * 4 * 2
(8 * 6 + 8) + 6 * 8 * (9 * (6 + 8 * 3 + 8) + (7 * 9 * 6 * 3) * 3 + 8 * 4)
3 * 4 * 8 * 7 + (4 + 5 + 8 * (3 + 3 + 3 * 6) + 4 + (3 * 8 * 8 * 6)) + (8 + 8 * (4 + 2 + 5 * 8 + 9))
8 * ((2 + 8 * 8 * 2 + 3) * 8 + 7 * 4) * (5 + 6) + 4 * 7
5 * (6 * 2 * 3 + 9) * (3 + 3 * (6 + 6 * 3) + 3 * 5 * 2)
5 * (7 + (2 * 7 * 2 * 6) * (9 * 7 + 8 * 7)) * 8 * 5
4 * (7 + 2 + (2 * 5 + 2 * 4 * 8))
6 * 3 + (7 * 3)
8 * 9 + (3 + (3 * 5 + 3 * 8 * 8) + 8) + 3
2 * 3 + (4 + 7 + 2)
8 + 2 * 6 + 9 + 7 * (9 + (9 * 9) + 3 * (8 * 3 * 7) + 2 + (7 + 5 * 5 * 2 + 9))
6 + 9 * (6 * 9 + 5 + 7)
3 * (5 + 5)
(4 + 9 * 7 * 8 * (5 * 6 + 4 * 7)) * 6
5 + (3 * 7 + 5)
(5 + 2 * (3 * 2 + 6 + 3)) + (2 * 7 * 9 * 2) * (8 * 3 * 5)
2 * ((3 + 7 + 4) * 4 + 3 * 3) + 4 + 2
(8 * 3) * 5 * 9 + (7 + 8 + 4 * (2 * 8 + 8 * 3)) + 3
5 + (4 * 8) + 3 + 7 + 6
4 + 9 + 4 + 5 * 9 + (9 + 2 * 2 * (5 * 6) + 8)
9 + (5 + (6 + 6 * 4) * 8 * (7 * 9 * 3 + 8 * 3)) * 5 * 9 + 6
2 + 6 * 4 + ((9 + 8 + 6 + 9) * 7 + 2 + 5 * 3 + 3) * (9 * (5 * 4 + 4) + 3 * 7 + (6 + 4 * 9 + 5 + 4 + 5)) * 4
3 * 6 + 4 + (7 * (5 + 5 * 5) + (3 * 4 * 7 + 3) * 5 + 5 * 5)
8 + 8 * 7 + (6 + (9 + 2)) + 4
2 * 3 * (6 + (2 * 9) + 7 * 3 * 3 + 6) + 6 + 4
8 + 8 + 8 * ((7 + 5 + 9) * 6 + 9 + 9)
(3 * 7) + 5 * (9 * 6) * 2 + (9 * 9)
7 + 8 + 6 + 6 * 4 * 2
6 * 3 + 5 * (4 * (6 + 3 + 5 * 9 * 8) * (4 + 7) * (2 * 6) + 3 * 9) * 9
((2 * 2 + 9 * 4) + 3 + (3 + 5)) * 6 + 8 * 9
4 + 6 + (3 * (2 + 2 + 2 + 2) + 6 + 9 + 3 + (5 + 9 + 9 + 6))
(5 + (3 * 7 * 7 + 7 * 2)) + (9 * 3 * 6 + 8 + 5 + 8) * 8 * 5 + 9
4 + 6 * 7 + (2 + 3 + 4 * 8 * (3 * 4 * 9 * 2 * 5 * 6)) + 9
4 + ((6 + 9) * 7 * (8 * 7 * 4 + 7 + 5 + 3) * 9 * 6) * 9 + (3 * (6 * 7 + 6 + 2 * 4) * 3 + (4 + 8 + 9 + 7 + 8 + 9) * 6 + (6 + 9 + 2 * 3)) * 7
6 * ((8 * 6 * 7 * 7 * 9 * 7) + (9 + 8 * 5 * 8) + 5 * (9 + 2 * 6))
2 + 8 + 8 + 9 * (9 * (7 + 8 * 4 + 4 * 8 + 6))
2 * 6 * 4 * ((2 * 2 * 6 * 7 + 3 * 8) + (7 + 8 + 7) * 4 + 9) + 7 * (4 + (5 + 7 * 9))
(6 * (5 + 6 + 3 * 5 + 4 + 2) + 9 * 2 * 6) + 2 * (8 * (6 * 3)) * 2 + 4
9 + 5 + 5 * ((3 * 3 * 8) * (2 * 9 + 7) * 4 + 4) * (3 + 6 * 5)
((9 * 8 * 8) * 4 * 6 * 7) + 4 + 4 + 2 * 7 * 8
(5 * 4) + 6 * 3 + 8 * 2
7 * 8 * 2 + 2 * 7
2 * 2 * 9 + 4 * ((4 + 3 * 5 * 6 + 5 + 8) + 4 + 7 * 6 + (4 + 6 * 9 * 5 + 5)) + 3
3 + (2 * 3 * 9 * 7 * (5 + 6 * 6 * 5 + 4) + 7)
(9 * 7 * 7 * (9 * 9) + 5 + 3) + 9 * 7 + 9 + 9 + (3 * 9 * 2 * 2 + 2)
7 + 3 + (4 * 6 + (5 * 6 * 2)) * 3
9 + (3 * (8 * 5 * 6 + 8)) * ((8 + 6 + 9 + 8 + 5 * 6) + 6) + 6 + 4 * 2
3 + 2 * 6 + 8 * 7 * (9 * 6 + 3 * 7)
4 * 9 + 4 + 7 + ((9 * 8) + 7 + 8 * 9 * 4) * 9
(9 * 3 * 7 * 6 + 3) * 3 + 5 + (4 + 7 + 9) + 2 * 2
4 * 6 + ((6 + 5 + 3 + 8 + 7) + 5 + 6 + 2 + 5) * 3
6 + 3 * 6 + 8 * 2 + 6
(6 + 6 * (8 * 8 + 7 * 8 + 2)) + 9 * (6 + (7 * 9) + (6 + 6 + 3) + 8 * 5 + 6) * 5
9 + 4 * (5 * 4 * 5 + 4 * (4 + 7 * 9) + 2) + (6 * 7 * (2 + 5 * 5 * 6) * 8) + 8 * 3
3 * 4 * 6 * 9 * 7 + ((9 + 9 + 2) + (8 * 2 + 9 + 2 + 5) * 9 + (9 + 7 * 5 * 3 + 7 + 8) + 4)
(4 * 8 + 4 + 9 * 8) * 7 * 8 * 5 + 6 + 2
7 * (9 * (9 * 3 * 5) * 7 + 5 * 3 + 9) + 3
(6 * (9 + 4) * 4 * (5 * 7 * 4 + 6 * 5)) * 2 + 9 + 5
4 + ((5 + 3 * 7 * 8 + 3) + (8 * 3 + 5 + 9 * 7 * 8) + 5 + 3 + (2 + 3 * 7 + 2) + 8)
(2 * 4 * 7 * 2 + 7 * (3 + 8 + 9 + 7 + 9)) * 3 * (9 + (6 + 5 * 7 * 7) * 2 + (4 * 3 * 5 * 8 * 2 + 6)) * 6 + (8 + 6 + (9 * 6))
4 * 9 + (8 * (6 + 5 + 7 * 8 * 7 * 3) + 9 * 8 * 5) + 5
2 * 6 + (5 * (6 * 9 * 8 * 9) * 3) + 4 + 8
2 * 8
(8 * (4 + 6 + 5 + 3 * 5) + (2 * 5 * 8 * 9 + 3 + 6) * 2 * 6 * 2) * 3 + (8 + 6 * 2 + 4 + 7)
((6 + 4 * 8) * 3 * 5) * 3
(7 * 8 + 5 + 5) * 8 + (5 * 7 * 8 * 9) * (8 + 6 + (3 + 9)) * 5
7 * (6 * (6 + 8 + 6) * 7 * 3 * 9 + (9 + 8 * 5 * 3 * 6)) + 5 + 5
3 + (6 * 3 + 7) * 4
(7 + 8 + 3 + 5 * 2) + 2
4 + (7 * 7 * 3 + (6 + 6) * 8 + 6) + (4 * (9 + 7 + 5 * 4) * 2) * 6 * (2 * 3) + 4
2 * ((3 + 5 * 6 + 6 + 3 * 6) + 5) + 5
4 * 6 + (3 + 2 + 2 * 6 * 4 * 5) * 6 + (9 + 2 + 2 + (9 * 2 * 2 * 3 + 8) * (7 + 6 + 3 + 5)) + 8
4 * 3 * (6 + 8 + (6 + 2 + 4 * 7 * 7 * 6) * 9 * 7) * 7
8 * (8 * 2 + 8 + (3 * 2))
5 + ((4 * 8) * (3 * 9 * 8 * 8) * 6 * 2 * 2 + 6) + 3
2 * 7 * 6 * (7 * 8 + 4 + 5) * (2 * 5) + 7
3 * 5 * (5 * 2 + 6 + 9 + 8 * 4)
(3 + 3 + 8) + 3 * 8 + 6
2 * (9 * (2 * 2 + 4 * 2 + 8) * 5) * 4
3 * (2 + 5 * (3 + 4 * 6 + 4 * 5) + 2) * (4 + 8 * 2 * 9 * 7 + 6) + (6 * 4 * 6) * 5
8 + (5 * 6 * 4 * 8) * (4 * 2 + (2 * 6) * (5 * 9 + 8 + 7 + 2) + 9) + (3 + (8 * 6) + 2 * (5 * 4 + 9 + 7 + 3 * 3) + 9) * 9
(3 + 4) + 5 * 6 + 4 * 7 + (2 + 3 + (5 * 9 + 8 + 2) + 6)
(8 + 5 + 2) + (7 + 3 + 6 + 6 * 9) + 3 * 5 + ((3 + 7 + 3 * 2 * 6) + 6 + 6)
(2 * 6) + 6
5 + (9 + 6 + 4 * 4 + 6 * (5 * 4 * 2 * 3)) * 8 * 6
(2 + (4 * 5 * 2 + 4)) + 8 * 8 * 8 + 5
7 * 5
3 * 2 * 3 + (9 + 4 * 6) * ((3 * 4 + 9 * 5) * 2 + 5 * 6)
(4 * 8 * (5 * 5) + (3 * 5 + 9 * 8 + 4 + 4)) * 5 + 4 * 6
5 * 6 * (5 * 3 * 3) + 6 * 5
(6 + 4 + (6 + 5 * 6 + 8 * 9 * 9) + 4) + 4 * 5 + 9 + 5
4 + 2 * 4 * 2 * (5 * 4 + 9 * 8)
2 + (6 + (9 * 4 * 6 + 8 + 4 + 3) * 6 + (3 * 8 + 6 + 2 * 4) + (4 * 4 * 2 * 8))
8 + (2 + 5 * 6 * 7) + (5 * 3 * 6 * 5 + 8)
7 * 6 * 9 * 8 + (2 + 7)
(2 + 7 + (6 + 5 + 7 * 4 + 7)) + 4
((7 * 5 + 8 + 2 + 7) + 9 * 2) + 3 + 8 + (9 + 7 + 8 * 6 * (5 + 3 * 5 + 6))
8 * 5 + (8 + (7 + 4 * 9 + 2)) + 2 + (7 + 2) * 7
9 + 4 * 9 + (9 * 6 + 2 * 6 + 5 + (4 * 9 * 6 * 7 + 5 + 8)) * (7 + 4 * 5 * (4 * 8 * 4 * 7) * 6) * 4
3 * 5 + (2 * 9 + (2 * 5 * 5) * 5 + 8)
3 * 9 * (8 + 6 + (9 + 2 + 2 + 8 + 4) * 6 + 7 * 3) * 2
2 + 8 * 7 + (4 * 4 * 5) * 7 * 9
5 + 9 * 6 * (4 + 9 + (8 * 7 * 9) + 9 * 9) + 6 + 8
9 * 6 + 9 * (3 * 8 + (9 * 9 * 8 + 2 + 3 * 6) + 5 * 6) * 7
4 + 6 + (2 + 2) + 7 * (9 + 3 * 5 * (3 + 3 + 8 + 3)) * 9
3 * ((2 + 4) * 7 * (2 * 3 * 8 * 6 * 7) + 4 + 3) + 7
9 + 3 + 4 * 8 * 5 + 9
8 + (4 * 4 + (7 * 5 * 7 + 2) + (9 * 3)) * (2 * 9 * 9 * (6 + 7 * 8 + 9 + 6 + 3) + 3 * (3 * 9 + 7 + 6 + 5 + 8)) + 5 * (5 + (4 + 2 + 8) + (9 * 7 * 4) + 3) * 8
(4 * 8 + 7 * 6 + 5 + 6) * (3 * 6 + 7 + (2 * 3 * 5)) + 4 * 4 * 5
2 * 6 + 4 * 7
6 + 8 * 7 * ((5 + 4 * 2 + 7 + 7 + 8) + 9 * 7 * 5) * 3 + (6 + 2)
(6 + 3 * 8) * 4 * 3
3 * 2 + 8 + (4 * (5 + 2 * 5 * 6) + 3 * 6)
8 * (4 * 3 + 8 * 5) * 3 * 8 + 8
5 * 4 + (3 + (2 + 6 * 8 + 3) * 4 * 3 * 6 + 4) + (8 + 6 + 2 * 3) * 4
((5 + 8) * (6 * 6 + 4 * 8 + 7) + 7 * 3 + (9 * 5 + 9) * (7 * 9)) + 7 + 7 + ((9 + 7 * 4 + 9) + 3)
(9 * 9 + 4) + (3 * 2 * 6 + 6 * 8)
((3 * 6 + 9 * 9) + 6 * 4) * (9 + 6 + 9 * 2) * 8 * 8
2 + 8 * (9 * 6 * 5) * 6 * 8 + 9
(6 + 6 + 7) + 7
8 + 7 * 9 + (9 + 5 + (5 * 5 + 2 * 9 * 8 * 6) + 6 + (4 + 6 * 8 * 2 + 2 + 9) + (5 + 8 + 9 + 4))
3 + (7 + 9 * 2 + 6 * 6) * 2 + 5
3 * 5 + 5 * 6 + (4 * 7 + 6 + 9 * 8 + 7) * 8
5 + 5 + (5 * 8 + 5 * (4 + 5) + 4)
(4 * (7 + 2 * 4 + 3 + 2 + 2)) * 2 + (4 + 3)
(3 * 3 * 2 * 7 + 6 * (6 * 5 + 9 + 5)) * 4 + 3 * 7 * (4 + 2 * 2 + 8 + 7 * 4) + 7
6 * 4 + 8 * 7 * (9 * 4 * 6 * (4 * 7 * 7 * 4) * (5 * 2 * 4))
4 * 8 * (4 * 2 + 3 * 6) + (8 * 4) + 8
9 + 5 + 3 + ((3 + 2) + 8 + 5 * 5 + 3) * 5
4 * ((6 + 6 * 2 * 8) * 9 * (4 + 5 * 8) * 9 * 7 * 2) + 6
6 * 5 * 2 * 2 * 7
6 * 6 + (8 * 4 * 5) + 9
3 * ((9 * 5 + 2 + 3 * 9 + 8) + 2 + (8 * 4 + 8 + 7 * 5) + 7) * 8 + 6
4 + (2 + 7 + 7 + 2 * 7)
2 + 3 + (2 + 5 + (3 + 4 + 7 + 5 * 9) * 3) * 8 * 5 * 9
4 * ((8 + 9 * 4 + 2 * 9) * 9 + 6 * 4 + (3 * 9)) * 3 + 6 + 3
4 + 4 * (5 * 2 + 6 + 6) + 6
((5 + 6 * 7 * 2) + 7 * 7 + 9 + 7 * 8) + (9 * 5 + 4 * 5 * 7 * 8) * 3 * 2
2 * 6 + 6 * (2 + 7 * 3 * 3 + 9 * 2) * 6
(4 * 5 * 2 * 5 * 4) * 6 + (2 + 3) * 2 * 9 + (8 * 6 * 7 + 8)
(3 * 6 + 3) + ((4 + 4 * 3) + 5 + 8 + 8) + 5
8 * 4 + 3 + (8 * 2) + ((2 + 6 * 3 + 8) * 2 + 4) + 3
5 * 7 * (6 * 5) * 8 + 9 * 9
9 * (4 + 8 * 8) * (5 + 7 + 6 + (3 + 2 + 7 + 4)) * ((2 + 8) + 6 * (3 * 3 * 5) + 5)
6 + (5 * (2 + 6 + 8 * 2 * 7 * 3) * (6 + 8) * 9 + 6)
(9 * 7) * 2 * 6 + 2 + 4 + 6
3 + 9 * 6 + 4 * (3 * 4) * 5
(8 * 3) + (9 * (3 * 6 + 5) * 9 + 9) + (4 * 3 * 5) + 6
6 + 3 * (4 + 2 * (2 * 5 + 7 * 2) * (2 + 2 + 5 + 2 * 7 + 7)) * 5 * 9 * 9
9 * ((5 + 3 + 3 + 5) + 8 * 8 + (9 + 3 * 4 * 7 * 3 + 7) + 7 * 8) * 3 * 6 + 2 + 3
6 * (7 + 9) + (2 * (7 * 3 + 5) * (6 * 5) * 7) * 6
(5 * 8 + 7 * 5 + 5 * 6) * (3 * 6 + 8) * 8
4 + ((5 * 6 * 5) * 9 * 2 * 3) * 4 * (2 + 9 + 3 + 6)
(2 + 4 * 2 * 5 + 3) * 9 + ((5 * 8 + 9 * 2 + 3 * 6) + 4 * 4) + 6 + 4 + 7
((2 + 4) * 3 * 3 + 4 + 3) + 8 * 3 + 4
7 * (7 + 5 + 7) + 7 * 3 * (8 * 7 * 7)
((9 + 8 * 6) + 3 * 2 * 5) * 2 * 4 * 9
((3 * 2 + 2 + 3 + 9) + 8 * 3) * 9 + 8 + 3 + 4
6 * 4 * 6 + 3 * (3 + 5 + (7 + 8 + 4 + 7 + 6) + 5 * 2 + 7)
((5 + 5 * 2 + 3) * 7) + 6 + (8 * 3 * 9 + (3 * 9 * 5 + 7 * 4)) * 9 * 8 * 6
(3 + 2 + 2 * 7 + 8 + 8) * (9 + 3) * 8 * 8
9 * (9 + (2 + 6)) * 2 * 7
6 * 4 + 2 * (9 + (6 * 2 * 7 * 6) * 7 + 8 + 3)
5 * 9 + 8 + (9 * 3) + 9
6 + ((5 * 6 + 6) + (4 * 3 + 3 + 4 * 5 + 4))
4 + 6 + 7 * 7 * (2 * 7 * (9 * 4 * 9) + 2 * 5)
(2 + 5) + 9 + 3 + 9
((7 + 6) * 4 + 6) + 3 * (4 + 4 * 8 + 6 + (7 * 3 + 4 * 9) + (4 + 6)) + 3 * 9
(2 + (8 * 8 + 9 * 8 * 6) * 2 * 3 * 2 + 6) + 6 * 5 * 8 * 6 + (7 * 9 + 6)
2 + 4 * 8 + (9 * 9 + 3) + (2 * (4 + 4 * 7) * 3 + 6 * 9) * 5
7 + 7 * 6 * 8
8 * (7 + 4) + 7 * 8 * 5 + 3
8 * 3 + (6 + 7 + 2 * 3 + 5) * 3
(7 + 3 + (6 * 5 * 5 * 2 + 5 + 8)) * 8 + 2 + 8 + 5 + 3
((5 * 9 + 6 * 2 * 7 * 6) * 7 * 5) + ((4 * 3) * 4 * 2 + (8 + 4 * 8 + 4) + (8 + 7 + 3 * 6)) * 6 + 8 + 9 * 5
((9 * 3 * 3 * 6 + 4 * 3) + (7 * 5 * 9) * 7 * 7 + 2) * 9
9 * 7 + 4 * (8 * 2 + 5 * (5 + 6) + 8 + 6) * 3 + 5
((5 + 3) * 5 + 6 + 8 + 5 + 3) * 8 * 6 * 5 * (6 + 8 + 3 * 8)
(4 * 3 * 7 + 6 * 6 + (4 * 5 + 6 + 5 + 8)) + 6 + 7 + 4 + 4 * 5
((6 + 8 + 5 + 7 * 7 * 6) * (7 * 9 * 4 * 6)) + 5 * 4 * 9
((9 * 2 * 7 * 7) * 7 * (4 + 9 * 9 * 2 + 6 * 5) + 4 + 2 * 8) + 9 * 7
(4 * 5 + 7 + 3) + 8
7 + 9 + 4 * 2 + 9
(9 * (4 + 2 * 9 + 5 * 5 * 3)) * 2 * 5
8 + ((6 * 3 + 4) * 4 + 4 * 9 + 3) * 9 * 6 + 4 + 6
(6 * 4 * 8 + 7 * 5 + 4) * 8 + (5 * 4 * 2 * 3) * 5
3 + 2 * (8 + 2 * 3 + 3 + (5 + 8 + 4 * 8 * 5)) * (4 * 6 + 8 + 9 * 8)
2 + 7 + 3 * 6 * 8 * (6 + (3 * 4 * 5 + 4))
(8 + 3 * 7 * (4 + 6 + 8 * 4 + 8 * 8)) + (9 * 9 * 2 * (3 + 4 * 4 * 8 + 3 + 8) + 6)
((8 * 9 + 2 * 8) * 5 + 6 + 3 * 3) + 3 * 7
4 + (2 + (6 * 5 * 3) * 2 + 2 * (3 + 7) * 9)
(5 * 4 * (6 + 4 + 9 + 5) * 4) + 4 * 3 * 4 * ((9 * 6 + 9 + 8 * 8 + 6) * 2 * 7 * 4) * 2
6 * 6 * (7 + 2 * (8 * 4 + 4)) + 7 * (9 * 6 * (5 + 6 + 2 + 2) + (9 * 4 * 5 * 5 * 5 + 6) * (6 * 6 * 5 * 6 + 8) + 5)
5 * (4 + (7 + 7 * 9 + 5) * 5 * 9) * 3
2 + (8 * 6 * 7 * 8 * 6 + 2) * 3
4 * (9 * 3 * 9 + 3 + 9 * 8) + 3 + (9 + 8 + 4 * 8)
4 * ((2 + 9 * 7 * 6 * 4 + 9) + 5 * 6 + 7)
(5 + (2 + 3 * 4 + 7) + (4 + 6) + 6) + 9 * 7 + 5 * (7 + 5 * (8 * 7 * 3 + 2 * 4) + 4) + 7
4 + 4 + (8 + 9 * (9 + 4 * 9 * 4 + 8 + 8) + 3 + 2 * 8)
5 * (5 + 5 * 3 * 2 + 2 + 3) * (5 + 3 * 8 + 9 + 8 + 7) * 2
8 + (3 * 9) + ((5 + 7 + 6 + 9) * 8 * 4 + (8 * 3 + 9 * 4 * 3)) + 4 * 4 * (3 + 3 * 7 * 6 * 2 + 7)
6 * (6 * 4 * 3 * 2) + 8 * 9 * (2 + 5 + 6)
4 + (8 + (3 + 2 + 6) * 5 + 2 * 7 + 9) + 5 + 4 + 3 * 4
2 + 4 * ((5 * 4 * 2 + 8) + (5 + 4 + 6 + 9) + 7 * 2 + (4 * 4 + 3 * 6 + 3)) * 6
((7 + 5 + 6 + 6 * 7) * 6 * 6 + (7 + 6 * 3 * 9) + 4 + 9) * 4 * 8 * 3
8 * 3 + 7 + 2 * (8 + 7 + 5 + (9 * 4)) * 6
8 + 3 + (3 + 5 * 6 + 5 + 6 + 3) + 3 * 9 + (2 + 6)
5 * 4 * (4 * 5 * 6 * 5) + (8 + 7 * 3) + 6
(5 + (7 + 4)) * 2 * (4 + 7 * (2 * 7 * 9) * (6 + 5 * 7 * 4) * 3 * 7) * (6 + 8) * 2 * (4 + (8 * 7 * 9) * 3 + (4 + 5 + 7 + 6 + 9))
((2 + 2 + 5 + 8 * 7) + (9 + 6 + 4 + 7) + (7 + 3 + 7 * 7 * 2 * 6) * 6) + 8
5 + (3 + 6) * 2 + (4 + (3 + 7) * 6 + 8 * 5 * 5) * (2 * 4 * 3) * 7
(4 * 5 * 3 * 8 + 6) + 9 * 2
(2 * 2 * 6 + (7 * 5 + 2 + 4 + 3) + 4) + 3
9 + 4 + 4 + 6 + 4
9 + 9 * 9
6 + 6 + 4 + ((9 * 8) + 3 + 5 + 6 + 6 + 5) + (7 * 6 + 7 + 7 * 8) + (7 * 7 + 7 * 2)
(2 * (4 + 2 * 4) * 7) + 5 * 8 * 7 * (5 * 3 * 5) * 6
(5 + 5 + 5 + 3 + 2) + (9 * 9 + 3) * 6
(5 + 2 + 2) * 5 * 7 * (9 + 6) * ((9 * 4 + 8) * 2)
((9 * 8 + 9) * 6 + 6) * 6 + 7 * 7
5 * (9 * 9 * 7 + 2 + 4) * 9 * 8 + 4 * ((4 * 5 + 9) + (9 * 6 + 9 * 8) * 4)
4 * (7 + 7 + (4 + 6 + 4)) * (6 + 5 * 2 + 5 + 3 + 4)
(4 * 5) + 4 * 4
4 * 8 * 9 + 4 + 3 * ((9 * 6) * 6 + 3 * (8 * 8 + 2))
3 * 7 + 7 * (5 + 5 * 8 * 9) * 7
5 + (7 + 4) * 6 * 7
7 * (2 + 2 + 5 + (6 * 6 + 5)) + 7 * 3 + (4 + (6 * 4) * 6 * 9) * 6
6 * (6 + 9 + 4 * 7) * 8 * 9
((3 * 6 + 8 + 5) * 9) * 7 + 6 * 8 + 2 * 3
(8 + 9 + 5 + 9 + 5 * (2 + 6 * 3 * 5 + 8 + 8)) + 7 * 7 + (3 + 2 * 4 + 3) + 5
7 + 7 * 6 + 9
5 + (3 + 3 + 4 + (8 * 3 * 2)) + 6 * 5 + 8
(3 * 6 + (2 + 2 + 9) * (3 * 2 + 2 * 3 * 8 * 6) + 5) + 3 + 2 + 4
2 + 6 * ((4 * 8) + 3 + 4 + 4 * (5 * 6 * 4 * 6 * 4) + 9) * 7 * (9 + (6 * 2) + 8 + 8) + (3 + 2)
8 + (2 + 6) * 3 + 4 + (7 * 4 * 9)
9 + (7 + 4 + (4 * 9 * 2 + 7 + 7) * (9 + 2 + 7)) * 3 + 3 + 4 + 7
9 * 5 + 5 + 5 * (2 + 7 + (3 * 2 * 4)) + 3
9 + 4 + 2 + ((5 + 7 + 6 + 2) + 2) * 8
7 + ((5 + 2 * 5) + 6 + 6 + 5 * (6 * 8) + 5) * 4 + 4
4 + (3 + 5 * 4 + 8 * 3 * 4) * 8 * 4
5 * (6 * 4 * 9 + 4 + (6 + 8 * 8 * 5)) + (6 * 9 + 2 + 6) * ((6 * 6 + 8 + 7) + 7 + 5 * 7)
2 * 2 + 8 * 8 * 6 + (3 * 6 + (4 * 8 + 4 * 9 * 5 + 6))
9 + (9 + 3 * 4 * 7 + 3 + 5) * (6 + 8 * 3 + 2) + 6 + 2
9 + 5 + 7 * ((9 + 9 * 5 * 8 * 5 + 3) * 8 + (8 * 8 * 5) * 4 * 2) + 3 + 8
9 * 2 + 8 * 7
6 + (5 * 6 + (5 * 9 * 2 + 4 * 3 + 2) + 8) + (3 + 4 + 9 + 9 + 5) + 3 + 8
(5 + 4 * (6 * 5 * 7 * 9 * 3) + 6 * 7 + 9) + 6 * 4 + 3 * 6 * 9
(5 + 2 + 2 + 2 * 9 * 3) + 8 + 2
3 + (8 + 6) * 7
(8 + 9) + 6 + (2 + 4) * 5 + (5 + 6 * 8) * 3
(6 * 2 + (4 + 2 * 2 + 3 * 9 + 8) * 8) + (7 + 5 + (4 * 5 + 7 * 7) + 2 * 8 + (4 + 6 * 6 * 2))
(8 + 7 * 5 * 4 * 2) * 9 + 5 + 6 + 8
3 * 7 * (6 * 8 + 6 * (3 * 2 * 4 + 9 * 3 * 3)) + 5
8 * (6 + (5 * 6) * 8 * 3 + (2 + 9))
(3 + 9 + 8 * 7) + 3 * 7 * (6 * (6 + 3) * 7 + (9 * 4) + 7 + 6)
4 * 3 * (3 * 8 * 7 * 8 * 4 * (8 + 2)) * (7 * (4 * 4 * 5 * 7 + 4) + 6 + 4) + 8
(2 + 3) * ((3 * 8) + 2 * 2 + 8 * 8) * (9 + 6) + 2
4 * 6 + ((2 * 4 * 2 + 6 * 9) + 6) * 9
9 * 8 * (2 * 7 + 6 * 7 + (8 + 8 * 4 + 9 * 7 + 6)) * 5 * (5 * (5 + 6 + 2) + (3 * 6 * 8 + 9 * 5))
2 + 2 * (4 + 5 * (9 + 5 * 3 * 3) + 7 * 7 + 6) * 2
2 + ((3 + 8 + 6 + 7) * 4 + 8 * 8 + 8) * (4 + 4 * 7 + 2 * 9 * 5) + 7
8 * (7 + 6 * 7) * 2 * 5 + (9 + 5 + 9 + 9 * 6) + 9
3 + (4 + (2 + 9 + 4 + 4 * 3 * 7) * (5 + 9 * 5 + 5)) + 2 * 7 * 4 + (2 * 4)
4 * (2 * (2 + 5) * 9 + 5 + 5 * 3) * (2 * 4 + 4 * (3 + 6 + 2))
6 + ((8 + 4) * 3 * 8)
(9 * (8 + 3 * 2 * 9 * 7) + 9 + 5 + (8 * 8 + 8 * 5 * 3 * 4)) * (9 + 5 + 4 * 9) + 3
2 * 8 + (8 * 4 + 2) * (5 * 5 + 6 + (6 * 4 * 4 * 4 * 3)) + 2
7 * 4 * (7 * (3 * 4 + 3) + 8) + 9 + 2 * (6 + 7 + (5 + 4 * 2 + 4) * 6)
5 + (9 * (5 * 7 + 6)) * 4 * 2
6 + 7 * (8 + 6) * 8 * ((4 + 7 * 5 + 2 * 3) + (2 * 3 * 5 * 6 + 9)) + 9
6 * (2 + 5 + (8 * 6 * 5 * 4 + 7 * 9) * 8 + 2) + 8 + 5 + 5
2 + 7 + 8 + (3 + (5 * 6 + 6) + 9) * 3 + (7 * (7 + 6) * 9 * (4 + 5 + 3 + 3) + 4)
7 * 8 + 2 + 3 + ((7 + 3 * 4 * 3 * 2 + 9) * (6 * 2) * 4 + 6 + 3) * 6
3 + 4 + 5
(4 + 4 * 3 * 2 * 6) + (9 * 3)
3 + (9 * 8 * 2 + 7 * 6) + 7 + (3 + (3 * 4 * 2) + 3 * (2 + 3 * 4 * 5 * 4 * 6) * 2) * (6 + 4 * 9) + 5
7 + (7 * 4 * (9 + 8 + 2 + 2 * 5) + 2 * (4 * 3 + 7 * 8) * 9) * (3 * 9 * 2 * (7 * 8 * 4 + 8 + 5 * 6)) * 3
((6 + 4 + 5 * 5) * 5 * 2 + (2 + 2) + 9 + (4 * 3 + 9)) + 7
2 + 2 * 4 + (4 * 9 * 7 * (9 * 8 * 6 * 7))
6 + 4
7 + (3 * 4 + 2) * 8 + 7 * 4
7 + 4 + 8 + (9 + 7 * 4 * 8 * 4) + 4 * 8
5 + 8 * 3 * ((8 * 9) * 2 + 6 * (2 + 5 * 8 + 3 * 9) * 4) + 9 + 8
8 + 6 + 6
6 * 6 * 6
6 + 9 + 5 * ((3 * 8 + 6) + 8 * 7 + 3 + 7 + 6) + 2
4 * 9 + 3 + 8 * ((2 + 2) * 5 * 3)
6 * (4 + 7 + 4) * 5 * 7 * 7 + 6
6 + 7 + (6 + 6) * (3 * (8 * 8 * 4 * 4 + 3 * 9) + 2 + 5 + 8) + 5 * 6
8 * 8 + (9 * 9 * (2 * 3) + 2 + 6) * (5 * (4 + 9 * 5 + 2 + 4 + 7))
9 + 5 + 7 * (4 * (4 + 4 * 4 + 7 * 7) * 9 + 6 * 5 * 3) * 5 * 9
(6 + 8 + 4 + 8) + 6 + 9 + ((6 + 4 * 9 * 9) + (6 * 6 + 7 + 9 * 2) * 7) * 5 * 9
8 + ((7 * 8) + 5 + 6) * 4 * 7 * 9
(6 + 2 + 2 * 3 * (8 * 6) * (5 * 9 * 6)) + 9 * (4 + 3 + (5 * 2) * 2 + 3 + 6)
4 * 8 + 7 * ((5 + 4 * 6) + 5 + 3) + 3 + 4
3 + (6 * (8 + 8) * 9) * 4 + 4 * (5 * (9 * 3 * 7 * 4) * (4 + 6 * 8 * 8 * 4) * 8) * 3
7 * 3 * 4 * 5 * 7 + (3 + 7 + (3 * 5 * 3 * 3 + 3) + 6)
(5 + 5 * 4 + 5 + 7) + (8 + 7 + 8 + 2 + 3)
(9 + 8 + 8 + 3 * 2 + 5) + 4 + (8 * 5 + 3 + 9 * 8) + (7 * 4) + 5 * 2
(5 * 9 * 2 * 9) + 5 * 8 + 4
9 * 3 * 9 + (9 + 3 + 2)
4 * 5 * 7 + (7 * 6) + 6 + 9
(3 + 8) + 4 + (7 + 2 * 9) * 7 * 8 + 4
8 + 3 + 4 + 6 * ((6 + 7 * 4 + 6) + 6 + 3 + 9 * 6)
(4 * 8) * (9 + (2 + 4 * 6 + 4 + 8)) * 3 + 9 * 4 + 8
5 * 4 + (9 + (2 * 8)) + 9 * 2
9 * 2 + (3 * 2 + 5 + (3 * 8 + 5 * 2 * 5 + 6) * 5 + 8) * 7 * 2
8 + (3 * 5 + 2 * 7 + 8 * 2)
5 + (4 * 7 + 2) + (5 + 8 * 5 + (4 * 9) + (3 + 3))
((4 * 5 * 8 + 6 + 8) * 9 * 3 + 4) * 8 + 9 * 7
((6 * 6 + 5 * 4 + 2 + 4) * 7 + 5 + 9 * 8) * 5 + 9
5 + (9 + 5 * 9 + 6 * 3) * ((3 * 6) * 2 + 8) + 3
((6 + 5) * 5 * 6 * 9 * 8) + 3 * 7
(8 * 6 + (5 + 5) + 4) * 7 + 3 + 8
4 + (2 * 3 * 8 + 3 + 3) * 8
2 * (7 + 6 + 2 + 3) * 8 + 2 + 2 * (4 * 3 * 5 * 8)
6 * (8 + (3 * 6 + 8 + 8 + 6) * 9)
((8 * 3 + 2) * 6 * 2 * (5 + 6 * 2 * 8)) + 8
6 + (6 * 5 + (5 * 9) * (6 * 5 + 8 * 2 + 5)) * (8 * (3 * 3 * 5) + 9) * 7
(7 + 6 + 2 * 5) + 2 + 6
(8 * 7 * (6 * 4 + 6 * 3) * 6) + 4 * 5 * (5 * (2 * 2 * 9) * 4 + (2 * 6 * 5) + 9 + 9)
((3 * 2) + 7 + 6 + 4 * 9) + 4 + 2 + 7 + (4 * (7 * 9 * 2) * 3)
(3 * (5 * 9 + 9 + 9 * 9)) + (9 + (4 * 4 * 6) * 9) + 9 * 7 + 4 * 9
4 + (6 * 6) * (9 * 8) * 9 + (6 + 7 * 5 + (2 + 9))
(8 + (5 + 7)) + 7 * 8 * 9 + 9
8 + 4 + 6 * (5 * 3 + 8 + 7) * 6 * 3
3 + 9 + 6 + (2 + 8 + (8 + 5 * 5) * 4 + 4 * 8) * 9 * 3
(4 + 4 * 3 + 4) * 8 * 4 + 4 + 6
2 * (3 * 6) + (4 + 3 * 8 + 5 + (6 * 5 * 2 + 5 + 2 * 9))
4 * 3 + (7 + 7 * 3 * 5 * 4 * 4) + (8 + 5 * 8) * (2 * 4) + 8
(4 * 9 * 6 + 6) * (6 * (8 + 4 * 9)) + 6 + ((4 + 2 * 9) * (3 + 3 + 6 + 3) + 9 * 9 + 8 * 7)
2 * 5 + 5 * (8 + 4 * 3 + (7 + 6) * 7 + 3) * 8
((3 * 4 + 4 * 9) * 6 + 7 * 4 + 7 * 2) * 7 * (7 + 9 + 6 * 8) + (3 * (6 * 6 * 9 * 7 + 4) * 5 * 2 + 3 + 4) * 8
(5 + 6 + 9 + 3 * 3 + (2 + 8 + 5 + 3)) + (2 * 5 + 6 * 9 * 6) * 2 + 9 * ((5 * 9) + 8 * 8 * (7 * 4 * 3 * 4 * 4 * 7))
2 + 8 + 4 + 7 * ((8 + 7 + 8 * 3) + 9 * 2 + 6 + 3) + 6
4 * (8 * 8 * 4) * 9 + (7 + 7 + 2 * 2) * 6 + 8
3 + (6 * 4 * 6 + 3 * 9 + 3) * 7 + 3 + 4
3 * 4
(4 * 6 * 4) + 3 + 7 + 6 * 9 + 7
3 * (6 + 8 * 4 * 2) + 5 + 5 * (4 + 6 + 2 + 6)
(5 + 2 + 4 * 2 * 2) + (5 + 5 * 5 * 3) + 3 * (4 + 9 + 6 * 6 + 2)
((6 + 9) * 6 + (3 + 7 * 4 + 2 + 5 * 6) + 3 + 5 * 2) * (2 * (5 * 9 + 9) * 5) + 8
9 * 8 * 9 * 8
6 * 8 * 4 * 4 + 4 * 4
((8 * 7 * 6 * 3) + 7 * 2 * 6 * (4 + 6 * 5 * 9 * 5) * 8) * (3 * (4 * 6 + 8 + 2 + 6 * 2) + (2 * 4 + 4 * 7 + 3 * 5) * 9 + 9 + 8)
(3 * 5 * 7 * 4 + (4 + 6 + 6 + 9 * 6 * 3) * 5) * 6
(4 * 4 * 5 * 8 * (3 + 4) + 7) + 6 + 4 + (8 + 3)
9 * 7 + 8 + 2 * 3 * (3 + (2 * 3 * 7 * 5 * 9) + 8 * 9 * 5)
((3 * 6) + 3 + 9) + 7 * 8 * 3 * 9
8 * 4 * (6 * 9) * 3
9 + ((5 + 3 + 4 * 3 * 9 * 6) * 6 + 9 + 3 + 8 * (5 + 4 + 7)) + 9 * 4
(4 + 6 * 3 + 2 * 9) * (6 * 9 * 4 + 7) + 8 + 8 + 6
(5 * 3 * 6 * 3) * 7 * (5 + 6 * 6 * 5)
4 * 6 * 8 + ((4 + 7 + 6) * 4 + (4 * 7)) * 8
6 + ((4 * 9 + 6 + 5 * 5 * 7) * 5 * 3) + 7
(8 * 4 + 8 + 9 * 9) + (5 * 6 + 3 + 6 * (9 + 8 * 7 * 6 * 8 + 6) + 5) * 9 + (6 + 6 * 2 + 2 * 4 + 8) * 5 * (8 + 5 + 2 + 3)
(8 * 2 + (7 * 9) + 8) + 3
2 + 9 * 6 + 5 * (3 * 7 + 8) + 3
((9 * 2 * 5) + (9 + 8 + 8 * 9) * 7 * 7 + 9) + 2 + 8 + 3 + (5 + 7)
5 + 9 + 5 * 4 + 3 + 5
4 + 9 * (6 * (7 + 7 + 9 * 3) * 5 + 3 * 3)
2 + 8 + 6 * 8 * (4 + (9 * 8) * 2) + 2
3 + 7
8 + 7 + 8 * (5 + 7 * 9 * 9 * 8)
6 + (3 + (5 * 3) + (9 + 6 * 9) * 4 + 8)
7 * 2 + (5 * 6 + 2 + 6 * 3 + (9 + 7 + 7 * 8 + 9 * 7)) * 8 * 7 * 7
(6 + 3 * 5 * 6) + (2 * 2 * 5) + 8 * 3 * 3 + 5
(2 * 8 + 6 * (6 + 3 * 2 + 7 * 7 + 6) * 5 + 5) * 3
(6 * 9 + (5 + 9 * 8) + 2 * (6 * 8 * 8 + 6 + 3) * 7) * (7 + 3 * 5)
4 * 2 + 8 * 9 + 3
8 * ((5 * 2 * 5 + 9 + 4) * 4 * 2) * 8 + (3 + 2 + 3 * 7 * 8 + 5) + 4
9 * 9 * 5
3 * 2 * 8 * (6 + 5 * 9 + 6)';

DECLARE @inputRaw table
(
	[id]			int				NOT NULL	IDENTITY(1,1)
	,[value]		varchar(200)	NOT NULL
);

INSERT INTO @inputRaw
		([value])
SELECT	[value]
FROM	STRING_SPLIT(REPLACE(@input, CHAR(13), ''), CHAR(10))
WHERE	LEN([value]) > 0;

DECLARE	@id				int		= 1
		,@expression	varchar(200)
		,@result1		bigint
		,@result2		bigint
		,@sum1			bigint	= 0
		,@sum2			bigint	= 0;

WHILE @id <= (SELECT MAX([id]) FROM @inputRaw)
BEGIN
	SELECT	@expression = [value]
	FROM	@inputRaw
	WHERE	[id] = @id;

	EXEC [dbo].[#Evaluate] @input = @expression, @LtoR = 1, @result = @result1 OUTPUT
	EXEC [dbo].[#Evaluate] @input = @expression, @LtoR = 0, @result = @result2 OUTPUT

	PRINT	@result1;
	PRINT	@result2;

	SELECT	@sum1	+= @result1
			,@sum2	+= @result2
			,@id	+= 1;
END

-- Test output 1: 71, 51, 26, 437, 12240, 13632
-- Test output 2: 231, 51, 46, 1445, 669060, 23340

-- Part 1: 16332191652452
-- Part 2: 351175492232654
SELECT [Part 1] = @sum1;
SELECT [Part 2] = @sum2;