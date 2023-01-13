USE [Richard];
GO

SET NOCOUNT ON;
SET STATISTICS IO, TIME ON;

DROP TABLE IF EXISTS [##Values], [##NewValues], [##Pattern];

CREATE TABLE [##Values]
(
	[Position]	int	NOT NULL
				PRIMARY KEY
	,[Value]	int	NULL
);

CREATE TABLE [##NewValues]
(
	[Position]	int	NOT NULL
				PRIMARY KEY
	,[Value]	int	NULL
);

CREATE TABLE [##Pattern]
(
	[Position]	int	NOT NULL
				PRIMARY KEY
	,[Value]	int	NOT NULL
);

INSERT INTO
	[##Pattern] ([Position], [Value])
SELECT	[Position], [Value]
FROM	(	VALUES
					 (0, 0)
					,(1, 1)
					,(2, 0)
					,(3, -1)
		) [Pattern]([Position], [Value])

DECLARE @phase int = 0, @maxphase int, @input varchar(MAX);

-- Test 1: 01029498
SELECT	@maxphase = 4, @input = '12345678';

-- Test 2: 24176176
SELECT	@maxphase = 100, @input = '80871224585914546619083218645595';
SELECT	@maxphase =   2, @input = '80871224585914546619083218645595';
-- Current answer Phase=20, Times= 100: 90565291			0m 33s / 0.6M
-- Current answer Phase=20, Times= 150: 69484029			1m 04s / 1.2M
-- Current answer Phase=20, Times= 200: 75731900			1m 46s / 1.7M
-- Current answer Phase= 2, Times= 500: 37611125			1m 07s / 0.8M
-- Current answer Phase= 2, Times=1000: 82394774			2m 50s / 2.7M

-- Test 3: 73745418
--SELECT	@maxphase = 100, @input = '19617804207202209144916044189917';

-- Test 4: 52432133
--SELECT	@maxphase = 100, @input = '69317163492948606335995924319873';

-- Part 1: 28430146 (tooks about 30s to run)
--SELECT	@maxphase = 100, @input = '59704176224151213770484189932636989396016853707543672704688031159981571127975101449262562108536062222616286393177775420275833561490214618092338108958319534766917790598728831388012618201701341130599267905059417956666371111749252733037090364984971914108277005170417001289652084308389839318318592713462923155468396822247189750655575623017333088246364350280299985979331660143758996484413769438651303748536351772868104792161361952505811489060546839032499706132682563962136170941039904873411038529684473891392104152677551989278815089949043159200373061921992851799948057507078358356630228490883482290389217471790233756775862302710944760078623023456856105493';
-- 7000000

DECLARE @fullinput varchar(MAX) = @input, @multiplier int = 1000;

WHILE LEN(@fullinput) < @multiplier * LEN(@input)
	SELECT @fullinput += @fullinput;

SELECT @fullinput = LEFT(@fullinput, @multiplier * LEN(@input));

WITH [Base] AS
(
	SELECT	[N] = [number]
	FROM	[master].[dbo].[spt_values]
	WHERE	[type]		= 'P'
	AND		[number]	< 1000
)
, [BaseCubed] AS
(
	SELECT	[N] = ROW_NUMBER() OVER (PARTITION BY NULL ORDER BY (SELECT NULL))
	FROM	[Base] [B1], [Base] [B2], [Base] [B3]
)
, [Numbers] AS
(
	SELECT	[N]
	FROM	[BaseCubed]
	WHERE	[N]	<= LEN(@fullinput)
)
INSERT INTO [##Values] ([Position])
SELECT	[N].[N]-1
FROM	[Numbers] [N];

UPDATE	[V]
SET		[Value] = TRY_CAST(SUBSTRING(@fullinput, [Position]+1, 1) AS int)
FROM	[##Values] [V];

WHILE @phase < @maxphase
BEGIN
	WITH [NewValues] AS
	(
		SELECT	[V1].[Position]
				,[Value]	= SUM([V2].[Value] * [P].[Value])
		FROM	[##Values] [V1]
		JOIN	[##Values] [V2]		ON	[V1].[Position]	<= [V2].[Position]
		INNER JOIN [##Pattern] [P]	ON	[P].[Position]	= (([V2].[Position]-[V1].[Position])/([v1].[Position]+1) + 1) % 4
									--AND [P].[Value]		<> 0
									--AND	[V2].[Value]	<> 0
		GROUP BY	[V1].[Position]
	)
	UPDATE	[V]
	SET		[Value]	= ABS([N].[Value]) % 10
	FROM	[##Values] [V]
	INNER JOIN	[NewValues]	[N]	ON	[N].[Position]	= [V].[Position]

	--TRUNCATE TABLE [##NewValues];

	--INSERT INTO [##NewValues]
	--		([Position], [Value])
	--SELECT	[V2].[Position]
	--		,SUM([V1].[Value] * [P].[Value])
	--FROM	[##Values] [V1]
	--CROSS JOIN	[##Values] [V2]
	--CROSS APPLY	(	SELECT	[MultipleOffset]	= CASE WHEN [V2].[Position] > [V1].[Position]
	--												THEN 0
	--												ELSE (([V1].[Position]-[V2].[Position])/([v2].[Position]+1) + 1) % 4
	--												END
	--			) [Calc]
	--INNER JOIN [##Pattern] [P]	ON [P].[Position]	= [Calc].[MultipleOffset]
	--GROUP BY	[V2].[Position]

	--UPDATE	[V]
	--SET		[Value]	= ABS([N].[Value] % 10)
	--FROM	[##Values] [V]
	--INNER JOIN	[##NewValues]	[N]	ON	[N].[Position]	= [V].[Position]

	SELECT @phase += 1;
END

DECLARE @answer varchar(10) = '';

SELECT		@answer += CAST([Value] AS varchar(2))
FROM		[##Values]
WHERE		[Position] < 8
ORDER BY	[Position];

SELECT @answer;
