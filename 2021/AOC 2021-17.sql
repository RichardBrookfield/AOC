USE [AOC];
SET NOCOUNT ON;
GO

DROP PROCEDURE IF EXISTS [#up_Test];

GO

CREATE OR ALTER PROCEDURE [#up_Test]
	@minX		int
	,@maxX		int
	,@minY		int
	,@maxY		int
	,@initialX	int
	,@initialY	int
	,@result	bit		OUTPUT
	,@highY		int		OUTPUT
	,@debug		bit		= 0
AS
BEGIN
	SELECT	@result = 0
			,@highY	= 0;

	DECLARE	@currentX	int	= @initialX
			,@currentY	int	= @initialY
			,@posX		int	= 0
			,@posY		int	= 0;

	WHILE 1=1
	BEGIN
		-- Are we there?
		IF @posX BETWEEN @minX AND @maxX
			AND @posY BETWEEN @minY AND @maxY
		BEGIN
			SELECT	@result = 1;
			BREAK;
		END

		-- Have we definitely passed the target?
		IF @posX > @maxX
			OR @currentY < 0 AND @posY < @minY
		BEGIN
			BREAK;
		END

		-- Do the step transformation
		SELECT	@posX	+= @currentX
				,@posY	+= @currentY;

		SELECT	@highY	= IIF(@posY > @highY, @posY, @highY);

		SELECT	@currentX	= IIF(@currentX > 0, @currentX - 1, 0)
				,@currentY	-= 1;

		--IF @debug = 1
		--	PRINT 'X = ' + CAST(@posX AS varchar(10)) + '  Y = ' + CAST(@posY AS varchar(10));
	END

	IF @debug = 1
		PRINT IIF(@result = 1, 'Hit', 'Miss') + ': high Y = ' + CAST(@highY AS varchar(10));
END
GO

DECLARE	@inputT	varchar(MAX) = 'target area: x=20..30, y=-10..-5';
DECLARE	@input	varchar(MAX) = 'target area: x=235..259, y=-118..-62'

DECLARE	@setup		varchar(MAX)	= @input
		,@minX		int
		,@maxX		int
		,@minY		int
		,@maxY		int
		,@posEqual	int
		,@posDots	int
		,@posComma	int;


SELECT	@posEqual	= CHARINDEX('=', @setup)
		,@posDots	= CHARINDEX('..', @setup)
		,@posComma	= CHARINDEX(',', @setup);

SELECT	@minX	= CAST(SUBSTRING(@setup, @posEqual + 1, @posDots - @posEqual - 1) AS int)
		,@maxX	= CAST(SUBSTRING(@setup, @posDots + 2, @posComma - @posDots - 2) AS int)

SELECT	@posEqual	= CHARINDEX('=', @setup, @posDots+2)
		,@posDots	= CHARINDEX('..', @setup, @posDots+2);

SELECT	@minY	= CAST(SUBSTRING(@setup, @posEqual + 1, @posDots - @posEqual - 1) AS int)
		,@maxY	= CAST(RIGHT(@setup, LEN(@setup) - @posDots - 1) AS int)

DECLARE	@result		int
		,@highY		int
		,@highestY	int	= 0
		,@hits		int	= 0
		,@initialX	int	= 1
		,@initialY	int;

-- These should be hits:
--EXEC [#up_Test] @minX=@minX, @maxX=@maxX, @minY=@minY, @maxY=@maxY, @initialX=7, @initialY=2, @result=@result OUTPUT, @highY=@highY OUTPUT;
--EXEC [#up_Test] @minX=@minX, @maxX=@maxX, @minY=@minY, @maxY=@maxY, @initialX=6, @initialY=3, @result=@result OUTPUT, @highY=@highY OUTPUT;
--EXEC [#up_Test] @minX=@minX, @maxX=@maxX, @minY=@minY, @maxY=@maxY, @initialX=9, @initialY=0, @result=@result OUTPUT, @highY=@highY OUTPUT;

-- And this is a miss:
--EXEC [#up_Test] @minX=@minX, @maxX=@maxX, @minY=@minY, @maxY=@maxY, @initialX=17, @initialY=-4, @result=@result OUTPUT, @highY=@highY OUTPUT;

-- Best Y is:
--EXEC [#up_Test] @minX=@minX, @maxX=@maxX, @minY=@minY, @maxY=@maxY, @initialX=6, @initialY=9, @result=@result OUTPUT, @highY=@highY OUTPUT;

WHILE @initialX <= @maxX
BEGIN
	SELECT	@initialY = @minY;

	WHILE @initialY < ABS(@minY)
	BEGIN
		EXEC [#up_Test] @minX=@minX, @maxX=@maxX, @minY=@minY, @maxY=@maxY,
							@initialX=@initialX, @initialY=@initialY,
							@result=@result OUTPUT, @highY=@highY OUTPUT;

		IF @result = 1
		BEGIN
			SELECT	@hits += 1;

			IF @highY > @highestY
				SELECT	@highestY = @highY;
		END

		SELECT	@initialY += 1;
	END

	SELECT	@initialX += 1;
END

SELECT	[Part 1] = @highestY;
SELECT	[Part 2] = @hits;
