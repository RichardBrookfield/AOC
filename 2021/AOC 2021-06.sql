USE [AOC];
SET NOCOUNT ON;
GO

DROP TABLE IF EXISTS [#Fish];
DROP TABLE IF EXISTS [#FishAge];
DROP TABLE IF EXISTS [#FishAgeNext];
GO

CREATE TABLE [#Fish]
(
	[id]		int				NOT NULL	IDENTITY (1,1)
	,[age]		int
);

CREATE TABLE [#FishAge]
(
	[age]		int
	,[number]	bigint
);

CREATE TABLE [#FishAgeNext]
(
	[age]		int
	,[number]	bigint
);

DECLARE @InputT varchar(MAX) = '3,4,3,1,2';
DECLARE @Input varchar(MAX) = '1,5,5,1,5,1,5,3,1,3,2,4,3,4,1,1,3,5,4,4,2,1,2,1,2,1,2,1,5,2,1,5,1,2,2,1,5,5,5,1,1,1,5,1,3,4,5,1,2,2,5,5,3,4,5,4,4,1,4,5,3,4,4,5,2,4,2,2,1,3,4,3,2,3,4,1,4,4,4,5,1,3,4,2,5,4,5,3,1,4,1,1,1,2,4,2,1,5,1,4,5,3,3,4,1,1,4,3,4,1,1,1,5,4,3,5,2,4,1,1,2,3,2,4,4,3,3,5,3,1,4,5,5,4,3,3,5,1,5,3,5,2,5,1,5,5,2,3,3,1,1,2,2,4,3,1,5,1,1,3,1,4,1,2,3,5,5,1,2,3,4,3,4,1,1,5,5,3,3,4,5,1,1,4,1,4,1,3,5,5,1,4,3,1,3,5,5,5,5,5,2,2,1,2,4,1,5,3,3,5,4,5,4,1,5,1,5,1,2,5,4,5,5,3,2,2,2,5,4,4,3,3,1,4,1,2,3,1,5,4,5,3,4,1,1,2,2,1,2,5,1,1,1,5,4,5,2,1,4,4,1,1,3,3,1,3,2,1,5,2,3,4,5,3,5,4,3,1,3,5,5,5,5,2,1,1,4,2,5,1,5,1,3,4,3,5,5,1,4,3';

INSERT INTO	[#Fish] ([age])
SELECT	CAST([value] AS int)
FROM	STRING_SPLIT(@Input, ',');

INSERT INTO [#FishAge] ([age])
VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8);

UPDATE	[FA]
SET		[FA].[number]	= [T].[number]
FROM	[#FishAge] [FA]
JOIN	(	SELECT		[number] = COUNT(*)
						,[age]
			FROM		[#Fish]
			GROUP BY	[age]
		) [T]	ON	[T].[age]	= [FA].[age]

DECLARE	@day	int = 0;

WHILE @day < 256
BEGIN
	DELETE FROM [#FishAgeNext];

	INSERT INTO [#FishAgeNext] ([age], [number])
	SELECT	[age]-1, [number]
	FROM	[#FishAge]
	WHERE	[age] > 0

	UNION ALL

	SELECT	8, [number]
	FROM	[#FishAge]
	WHERE	[age] = 0

	UNION ALL

	SELECT	6, [number]
	FROM	[#FishAge]
	WHERE	[age] = 0;

	DELETE FROM [#FishAge];

	INSERT INTO	[#FishAge] ([age], [number])
	SELECT		[age], SUM([number])
	FROM		[#FishAgeNext]
	GROUP BY	[age];

	SELECT	@day += 1;

	IF @day = 80
		SELECT [Part 1] = SUM([number]) FROM [#FishAge];
END

SELECT [Part 2] = SUM([number]) FROM [#FishAge];
