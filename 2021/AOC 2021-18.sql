USE [AOC];
SET NOCOUNT ON;
GO

-- Another bad one, the second part takes about 6 minutes.

DROP TABLE IF EXISTS [#Input];
DROP TABLE IF EXISTS [#Number];

DROP PROCEDURE IF EXISTS [#up_Display];
DROP PROCEDURE IF EXISTS [#up_Insert];
DROP PROCEDURE IF EXISTS [#up_Add];
DROP PROCEDURE IF EXISTS [#up_Reduce];
DROP PROCEDURE IF EXISTS [#up_Magnitude];

GO

CREATE TABLE [#Input]
(
	[id]		int				IDENTITY (1,1)
	,[value]	varchar(MAX)
);

CREATE TABLE [#Number]
(
	[id]		int				IDENTITY(1,1)
								CONSTRAINT [PK_Number] PRIMARY KEY CLUSTERED
	,[step]		int
	,[level]	int
	,[value]	int

	,INDEX [idx_step] ([step])
);
GO

CREATE OR ALTER PROCEDURE [#up_Display]
	@step		int		= NULL
AS
BEGIN
	DECLARE	@level		int	= 0
			,@i			int
			,@max		int
			,@chLevel	int
			,@chValue	int
			,@number	varchar(MAX) = '';

	IF @step IS NULL
		SELECT	@step = MAX([step])
		FROM	[#Number];

	SELECT	@i		= MIN([id])
			,@max	= MAX([id])
	FROM	[#Number]
	WHERE	[step]	= @step;

	WHILE @i <= @max
	BEGIN
		SELECT	@chLevel	= [level]
				,@chValue	= [value]
		FROM	[#Number]
		WHERE	[id]		= @i;

		WHILE @level < @chLevel
			SELECT	@number += '['
					,@level	+= 1;
			
		WHILE @level > @chLevel
			SELECT	@number += ']'
					,@level	-= 1;

		SELECT	@number += IIF(@chValue = -1, ',', CAST(@chValue AS varchar(10)));

		SELECT	@i += 1;
	END

	WHILE @level > 0
		SELECT	@number += ']'
				,@level	-= 1;

	PRINT @number;
END
GO

CREATE OR ALTER PROCEDURE [#up_Insert]
	@number	varchar(MAX)
AS
BEGIN
	DECLARE	@level	int	= 0
			,@i		int	= 1
			,@step	int
			,@ch	char;

	SELECT	@step	= ISNULL(MAX([step]) + 1, 1)
	FROM	[#Number];

	WHILE @i < LEN(@number)
	BEGIN
		SELECT	@ch = SUBSTRING(@number, @i, 1);

		IF @ch = '['
			SELECT	@level += 1;
		ELSE IF @ch = ']'
			SELECT	@level -= 1;
		ELSE
			INSERT INTO [#Number] ([level], [step], [value])
			VALUES (@level, @step, IIF(@ch = ',', -1, CAST(@ch AS int)));

		SELECT	@i += 1;
	END
END
GO

CREATE OR ALTER PROCEDURE [#up_Add]
AS
BEGIN
	DECLARE	@step	int;

	SELECT	@step	= MAX([step])
	FROM	[#Number];

	INSERT INTO	[#Number] ([level], [step], [value])
	SELECT		[level] + 1, @step + 1, [value]
	FROM		[#Number]
	WHERE		[step]	= @step - 1
	ORDER BY	[id];

	INSERT INTO [#Number] ([level], [step], [value])
	SELECT	1, @step+1, -1;

	INSERT INTO	[#Number] ([level], [step], [value])
	SELECT		[level] + 1, @step + 1, [value]
	FROM		[#Number]
	WHERE		[step]	= @step
	ORDER BY	[id];
END
GO

CREATE OR ALTER PROCEDURE [#up_Reduce]
AS
BEGIN
	DECLARE	@step			int
			,@id			int
			,@idPrevious	int
			,@idNext		int
			,@valueLeft		int
			,@valueRight	int
			,@level			int
			,@workdone		bit	= 1;

	WHILE @workdone = 1
	BEGIN
		-- Start with a copy during testing
		INSERT INTO	[#Number] ([level], [step], [value])
		SELECT		[level], [step] + 1, [value]
		FROM		[#Number]
		WHERE		[step]	= (SELECT MAX([step]) FROM [#Number])
		ORDER BY	[id];

		SELECT	@step	= MAX([step])
		FROM	[#Number];

		SELECT	@workdone	= 0
				,@id		= 0;

		SELECT	@id		= MIN([id])
		FROM	[#Number]
		WHERE	[step]	= @step
		AND		[level]	> 4;

		-- An explode can be done here.  The first number is at @id, followed by
		-- the comma and the second number at @id+1 and @id+2.
		IF @id <> 0
		BEGIN
			SELECT	@idPrevious	= 0
					,@idNext	= 0;

			-- Find the previous and next numbers (if any).
			SELECT	@idPrevious = MAX([id])
			FROM	[#Number]
			WHERE	[step]	= @step
			AND		[value]	<> -1
			AND		[id]	< @id;

			SELECT	@idNext = MIN([id])
			FROM	[#Number]
			WHERE	[step]	= @step
			AND		[value]	<> -1
			AND		[id]	> @id + 2;

			-- And add the values on.
			IF @idPrevious <> 0
				UPDATE	[#Number]
				SET		[value]	+= (SELECT [value] FROM [#Number] WHERE [id] = @id)
				WHERE	[id]	= @idPrevious;

			IF @idNext <> 0
				UPDATE	[#Number]
				SET		[value]	+= (SELECT [value] FROM [#Number] WHERE [id] = @id + 2)
				WHERE	[id]	= @idNext;

			-- Zero out the first number
			UPDATE	[#Number]
			SET		[value]		= 0
					,[level]	-= 1
			WHERE	[id]	= @id;

			-- And duplicate (except the comma and second number) in order
			-- to keep the id values consecutive for future passes.
			INSERT INTO	[#Number] ([level], [step], [value])
			SELECT		[level], @step + 1, [value]
			FROM		[#Number]
			WHERE		[step]	= @step
			AND			[id]	NOT IN (@id + 1, @id + 2)
			ORDER BY	[id];

			SELECT	@workdone = 1;

			-- Back to the top, in case there's another.
			CONTINUE;
		END

		SELECT	@id		= MIN([id])
		FROM	[#Number]
		WHERE	[step]	= @step
		AND		[value]	> 9;

		-- This is a split, which is pretty simple.
		IF @id <> 0
		BEGIN
			SELECT	@valueLeft		= [value] / 2
					,@valueRight	= ([value] + 1)/ 2
					,@level			= [level]
			FROM	[#Number]
			WHERE	[id]	= @id;

			INSERT INTO	[#Number] ([level], [step], [value])
			SELECT		[level], @step + 1, [value]
			FROM		[#Number]
			WHERE		[step]	= @step
			AND			[id]	< @id
			ORDER BY	[id];

			INSERT INTO	[#Number] ([level], [step], [value])
			SELECT		@level+1, @step + 1, @valueLeft;

			INSERT INTO	[#Number] ([level], [step], [value])
			SELECT		@level+1, @step + 1, -1;

			INSERT INTO	[#Number] ([level], [step], [value])
			SELECT		@level+1, @step + 1, @valueRight;

			INSERT INTO	[#Number] ([level], [step], [value])
			SELECT		[level], @step + 1, [value]
			FROM		[#Number]
			WHERE		[step]	= @step
			AND			[id]	> @id
			ORDER BY	[id];

			SELECT	@workdone = 1;
		END
	END
END
GO

CREATE OR ALTER PROCEDURE [#up_Magnitude]
	@result	int		OUTPUT
AS
BEGIN
	DECLARE	@step	int
			,@id	int
			,@id1	int
			,@id2	int;

	DECLARE	@magnitude TABLE
	(
		[id]			int
		,[level]		int
		,[value]		int
	)

	SELECT	@step	= MAX([step])
	FROM	[#Number];

	INSERT INTO @magnitude ([id], [level], [value])
	SELECT	[id], [level], [value]
	FROM	[#Number]
	WHERE	[step]	= @step;

	WHILE (SELECT COUNT(*) FROM @magnitude) > 1
	BEGIN
		SELECT	@id = 0;

		SELECT TOP (1)
				@id		= [M].[id]
				,@id1	= [M1].[id]
				,@id2	= [M2].[id]
		FROM	@magnitude [M]
		CROSS APPLY	(	SELECT TOP (1)
									[M1].[id], [M1].[level], [M1].[value]
						FROM		@magnitude [M1]
						WHERE		[M1].[id]		> [M].[id]
						ORDER BY	[M1].[id]
					) [M1]
		CROSS APPLY	(	SELECT TOP (1)	
									[M2].[id], [M2].[level], [M2].[value]
						FROM		@magnitude [M2]
						WHERE		[M2].[id]		> [M1].[id]
						ORDER BY	[M2].[id]
					) [M2]
		WHERE		[M1].[level]	= [M].[level]
		AND			[M2].[level]	= [M].[level]
		AND			[M1].[value]	= -1
		AND			[M2].[value]	<> -1
		ORDER BY	[M].[id];

		IF @id = 0
		BEGIN
			BREAK;
		END

		UPDATE	@magnitude
		SET		[level]		-= 1
				,[value]	= 3 * (SELECT [value] FROM @magnitude WHERE [id] = @id)
								+ 2 * (SELECT [value] FROM @magnitude WHERE [id] = @id2)
		WHERE	[id]	= @id;

		DELETE
		FROM	@magnitude
		WHERE	[id]	IN (@id1, @id2);
	END

	SELECT	@result = [value]
	FROM	@magnitude;
END
GO

DECLARE	@inputM1	varchar(MAX)	= '[[1,2],[[3,4],5]]';										-- 143
DECLARE	@inputM2	varchar(MAX)	= '[[[[0,7],4],[[7,8],[6,0]]],[8,1]]';						-- 1384
DECLARE	@inputM3	varchar(MAX)	= '[[[[1,1],[2,2]],[3,3]],[4,4]]';							-- 445
DECLARE	@inputM4	varchar(MAX)	= '[[[[3,0],[5,3]],[4,4]],[5,5]]';							-- 791
DECLARE	@inputM5	varchar(MAX)	= '[[[[5,0],[7,4]],[5,5]],[6,6]]';							-- 1137
DECLARE	@inputM6	varchar(MAX)	= '[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]';	-- 3488

-- Magnitude testing only
DECLARE @magnitude	int;
EXEC [#up_Insert] @inputM1;
EXEC [#up_Magnitude] @result = @magnitude OUTPUT;
EXEC [#up_Insert] @inputM2;
EXEC [#up_Magnitude] @result = @magnitude OUTPUT;
EXEC [#up_Insert] @inputM3;
EXEC [#up_Magnitude] @result = @magnitude OUTPUT;
EXEC [#up_Insert] @inputM4;
EXEC [#up_Magnitude] @result = @magnitude OUTPUT;
EXEC [#up_Insert] @inputM5;
EXEC [#up_Magnitude] @result = @magnitude OUTPUT;
EXEC [#up_Insert] @inputM6;
EXEC [#up_Magnitude] @result = @magnitude OUTPUT;

-- Basic first example
DECLARE	@inputT1	varchar(MAX) = '
[1,1]
[2,2]
[3,3]
[4,4]
[5,5]
[6,6]
';

-- Addition example
DECLARE	@inputT2	varchar(MAX) = '
[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
[[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
[[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]
[7,[5,[[3,8],[1,4]]]]
[[2,[2,2]],[8,[8,1]]]
[2,9]
[1,[[[9,3],9],[[9,0],[0,7]]]]
[[[5,[7,4]],7],1]
[[[[4,2],2],6],[8,7]]
';

-- Final example
DECLARE	@inputT3	varchar(MAX) = '
[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
[[[5,[2,8]],4],[5,[[9,9],0]]]
[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
[[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
[[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
[[[[5,4],[7,7]],8],[[8,3],8]]
[[9,3],[[9,9],[6,[4,9]]]]
[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
[[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
';

-- Actual puzzle
DECLARE	@input	varchar(MAX) = '
[2,[0,[9,[5,9]]]]
[[2,[1,8]],3]
[[[[7,2],6],[[7,8],3]],[9,[[6,9],2]]]
[[[[7,2],[9,8]],7],[4,[[2,2],[5,0]]]]
[[8,[2,2]],[5,[9,[4,9]]]]
[[[[6,2],[4,8]],5],0]
[[3,[3,[6,6]]],[6,9]]
[[[9,5],[[8,2],[4,0]]],[[5,5],[[5,0],[1,9]]]]
[[[[7,4],[8,1]],[2,[7,1]]],2]
[[[[9,6],3],8],[[[9,8],7],[5,[0,8]]]]
[[[4,[4,0]],[[7,3],3]],[8,[3,[8,2]]]]
[[[[8,4],1],6],[[1,[8,7]],1]]
[[[8,2],[[1,4],3]],[[4,5],[[9,1],[7,2]]]]
[[[[5,0],[8,8]],[[4,2],4]],[2,[[4,3],[3,7]]]]
[[[8,7],[2,1]],[9,3]]
[[3,[7,4]],[0,3]]
[4,[[[5,0],[5,2]],3]]
[[[[0,1],0],8],[6,3]]
[[7,[[9,8],[2,7]]],[[[8,8],[9,4]],[[0,5],[4,1]]]]
[[[[3,7],[5,4]],[8,[1,8]]],[[1,8],[[6,9],9]]]
[[[[7,4],[7,7]],7],[1,[[8,2],[1,8]]]]
[[[[6,2],8],[[1,2],3]],[[[3,6],[4,9]],[[3,1],[9,8]]]]
[[[3,[1,1]],[[6,5],[2,2]]],9]
[[[[9,1],4],1],[[[1,3],3],[0,[1,4]]]]
[[[5,0],[4,[6,8]]],[[2,4],[[0,3],[2,6]]]]
[9,[[9,[1,5]],1]]
[[1,[[6,0],[9,2]]],[[[4,2],7],[[2,9],6]]]
[[[[8,2],8],9],[[[4,9],[3,8]],2]]
[[[9,1],[6,5]],[[[9,5],5],1]]
[[[[1,3],5],2],[1,1]]
[[[[0,0],[8,1]],8],8]
[[[[3,3],5],[[9,6],9]],[[3,[0,9]],7]]
[[[6,5],1],1]
[[[4,[1,3]],[[2,2],2]],[[8,0],[[8,1],[2,6]]]]
[9,[[4,6],2]]
[[[5,[8,8]],[[1,8],[4,9]]],[9,[3,6]]]
[[[[9,3],3],0],8]
[[[5,0],[[2,8],[1,1]]],[[[5,6],9],8]]
[[[[5,0],[5,2]],[[7,0],[9,8]]],[3,[[5,7],[5,9]]]]
[[3,[5,7]],1]
[[[[2,5],[0,7]],9],[[[3,2],1],[7,1]]]
[6,[7,[6,0]]]
[[[8,5],[[1,7],[7,6]]],[[1,3],[5,[1,9]]]]
[[[[9,4],[8,3]],1],[[1,6],[[2,5],1]]]
[[[[6,5],[6,6]],[5,5]],[1,8]]
[[[[7,7],[2,2]],3],[1,[[8,6],[5,1]]]]
[[6,[2,4]],[[8,8],[[3,5],6]]]
[[1,[[6,1],[9,3]]],[[2,0],5]]
[[[5,9],[6,[1,9]]],[3,[4,[7,7]]]]
[[[[3,6],[8,5]],[[9,4],[4,1]]],[3,3]]
[[[3,9],[1,6]],2]
[[[[0,9],7],6],[7,[9,[9,9]]]]
[[[5,[6,0]],[8,[7,5]]],[[[8,8],0],[8,1]]]
[[[[6,9],[9,0]],2],[[[0,3],[1,6]],[2,4]]]
[[[[8,2],[3,0]],[[3,8],8]],[6,[[9,3],4]]]
[[[6,6],2],[5,[1,4]]]
[[1,[1,4]],[[[4,3],0],1]]
[[[[9,9],3],0],[[[3,3],[2,8]],[1,0]]]
[[[[1,1],[3,5]],[9,7]],4]
[[[9,[3,6]],5],[[4,9],[9,3]]]
[[8,7],[5,[7,[7,7]]]]
[[[[0,5],[7,3]],[[8,6],8]],[[[4,4],[5,0]],[[2,2],2]]]
[[[5,0],[[1,9],[5,8]]],[[1,5],[[9,3],[0,7]]]]
[[[1,[1,5]],[8,[2,2]]],0]
[[[6,[7,8]],[[0,2],5]],[3,[5,[8,0]]]]
[[[[1,7],2],3],[[[8,7],[7,8]],[7,[5,5]]]]
[[1,[7,[3,3]]],[8,[9,[3,0]]]]
[[5,6],[[5,[2,8]],[[5,5],[8,8]]]]
[[8,[[7,7],[4,0]]],[[5,[0,4]],[6,[6,2]]]]
[[4,[[0,0],[0,1]]],[[3,1],[[6,7],4]]]
[[[[3,2],[4,2]],[[4,4],[6,3]]],[9,[0,[1,9]]]]
[[[[4,6],2],[[9,6],4]],[[9,[9,1]],[0,[1,8]]]]
[[[5,8],[[6,5],[0,4]]],[[0,[6,3]],[2,0]]]
[[6,8],[[5,5],[5,8]]]
[[[7,3],[8,[6,7]]],[[[1,5],2],7]]
[[6,[8,[8,9]]],[[[1,1],[3,0]],[[7,2],[3,7]]]]
[[[[8,1],6],[9,[5,1]]],[[[5,9],[1,9]],5]]
[[[[3,6],[5,7]],[[0,3],8]],[3,[[2,1],0]]]
[[7,[5,1]],[[[3,6],9],[[4,0],6]]]
[[[[3,8],8],0],[[1,[1,4]],[[4,5],[8,5]]]]
[[[8,[0,6]],[4,3]],[8,[[1,5],8]]]
[2,[[1,[9,7]],[[2,0],6]]]
[[[[7,4],4],[[4,9],3]],[[[6,5],[0,5]],[[9,8],[2,6]]]]
[[[3,[7,2]],[[7,7],4]],[[[3,4],[6,0]],[6,3]]]
[[[1,9],[[9,8],9]],5]
[[[4,2],2],[[[4,4],7],5]]
[[[9,1],[2,[1,5]]],[[4,3],[4,[9,5]]]]
[2,[[[8,4],1],[[2,4],2]]]
[[[0,6],5],[1,[[2,0],6]]]
[[[[2,4],[1,7]],[1,0]],[9,5]]
[[7,[3,[2,0]]],[[7,8],8]]
[[9,[1,0]],[[0,4],[[0,1],0]]]
[0,9]
[[[[2,9],[2,4]],[[5,6],8]],[[5,[1,4]],[3,[0,6]]]]
[[5,[[5,8],0]],[[[0,6],[4,5]],[[8,9],[8,3]]]]
[[[[5,2],[7,7]],[0,[4,1]]],[[8,7],[[5,3],7]]]
[[[5,3],5],[0,0]]
[3,5]
[[2,6],5]
[[5,[[6,0],3]],[[3,[8,7]],[2,0]]]
';

INSERT INTO	[#Input] ([value])
SELECT	[value]
FROM	STRING_SPLIT(REPLACE(@Input, CHAR(13), ''), CHAR(10))
WHERE	[value] <> '';

DECLARE	@i		int	= 1
		,@j		int
		,@line	varchar(MAX);

WHILE @i <= (SELECT MAX([id]) FROM [#Input])
BEGIN
	SELECT	@line	= [value]
	FROM	[#Input]
	WHERE	[id]	= @i;

	EXEC [#up_Insert] @number = @line;

	IF @i > 1
	BEGIN
		EXEC [#up_Add];
		EXEC [#up_Reduce];
	END

	SELECT	@i += 1;
END

EXEC [#up_Magnitude] @result = @magnitude OUTPUT;

SELECT	[Part 1] = @magnitude;

-- Quick reset
SELECT	@i = 1;

DECLARE	@biggest	int	= 0
		,@line2		varchar(MAX);

WHILE @i <= (SELECT MAX([id]) FROM [#Input])
BEGIN
	SELECT	@j = 1;

	SELECT	@line	= [value]
	FROM	[#Input]
	WHERE	[id]	= @i;

	WHILE @j <= (SELECT MAX([id]) FROM [#Input])
	BEGIN
		IF @i <> @j
		BEGIN
			SELECT	@line2	= [value]
			FROM	[#Input]
			WHERE	[id]	= @j;

			EXEC [#up_Insert] @line;
			EXEC [#up_Insert] @line2;
			EXEC [#up_Add]
			EXEC [#up_Reduce]
			EXEC [#up_Magnitude] @result = @magnitude OUTPUT;

			IF @biggest < @magnitude
				SELECT	@biggest = @magnitude;
		END

		SELECT	@j += 1;
	END

	SELECT	@i += 1;
END

SELECT	[Part 2] = @biggest;
