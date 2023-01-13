USE [AOC];
SET NOCOUNT ON;
GO

DROP TABLE IF EXISTS [#Input];
DROP TABLE IF EXISTS [#Node];
DROP TABLE IF EXISTS [#Path];
GO

CREATE TABLE [#Input]
(
	[id]		int				NOT NULL	IDENTITY (1,1)
	,[value]	varchar(MAX)
);

CREATE TABLE [#Node]
(
	[id]		int				NOT NULL	IDENTITY (1,1)
	,[name]		varchar(20)
	,[upper]	bit

	,CONSTRAINT [PK_Node] PRIMARY KEY ([id], [name])
);

CREATE TABLE [#Path]
(
	[From]		int
	,[To]		int

	,CONSTRAINT [PK_Path] PRIMARY KEY ([From], [To])
);
GO

DECLARE @InputT1 varchar(MAX) = '
start-A
start-b
A-c
A-b
b-d
A-end
b-end
';


DECLARE @InputT2 varchar(MAX) = '
dc-end
HN-start
start-kj
dc-start
dc-HN
LN-dc
HN-end
kj-sa
kj-HN
kj-dc
';

DECLARE @InputT3 varchar(MAX) = '
fs-end
he-DX
fs-he
start-DX
pj-DX
end-zg
zg-sl
zg-pj
pj-he
RW-he
fs-DX
pj-RW
zg-RW
start-pj
he-WI
zg-he
pj-fs
start-RW
';

DECLARE @Input varchar(MAX) = '
mx-IQ
mx-HO
xq-start
start-HO
IE-qc
HO-end
oz-xq
HO-ni
ni-oz
ni-MU
sa-IE
IE-ni
end-sa
oz-sa
MU-start
MU-sa
oz-IE
HO-xq
MU-xq
IE-end
MU-mx
';

INSERT INTO	[#Input] ([value])
SELECT	[value]
FROM	STRING_SPLIT(
			REPLACE(@Input, CHAR(13), '')
			, CHAR(10))
WHERE	[value] <> '';

DECLARE	@i			int = 1
		,@pos		int
		,@start		varchar(10)
		,@end		varchar(10)
		,@startid	int
		,@endid		int
		,@line	varchar(20);

WHILE @i <= (SELECT MAX([id]) FROM [#Input])
BEGIN
	SELECT	@line = [value]
	FROM	[#Input]
	WHERE	[id] = @i;

	SELECT	@pos = CHARINDEX('-', @line);

	SELECT	@start	= LEFT(@line, @pos-1)
			,@end	= RIGHT(@line, LEN(@line)-@pos);

	IF NOT EXISTS (SELECT 1 FROM [#Node] WHERE [name] = @start)
		INSERT INTO [#Node] ([name], [upper])
		VALUES (@start, IIF(BINARY_CHECKSUM(@start) = BINARY_CHECKSUM(UPPER(@start)), 1, 0));

	IF NOT EXISTS (SELECT 1 FROM [#Node] WHERE [name] = @end)
		INSERT INTO [#Node] ([name], [upper])
		VALUES (@end, IIF(BINARY_CHECKSUM(@end) = BINARY_CHECKSUM(UPPER(@end)), 1, 0));

	SELECT	@startid	= [id]	FROM [#Node] WHERE [name] = @start;
	SELECT	@endid		= [id]	FROM [#Node] WHERE [name] = @end;

	INSERT INTO [#Path] ([From], [To])
	VALUES	(@startid, @endid), (@endid, @startid);

	SELECT	@i += 1;
END;

WITH [Route] ([PathList], [LastNode]) AS
(
	SELECT	CAST(('/start/') AS varchar(200))
			,[id]
	FROM	[#Node]
	WHERE	[name] = 'start'

	UNION ALL

	SELECT	CAST([R].[PathList] + [N].[name] + '/' AS varchar(200))
			,[P].[To]
	FROM	[Route] [R]
	JOIN	[#Path] [P]		ON	[P].[From]	= [R].[LastNode]
	JOIN	[#Node] [N]		ON	[N].[id]	= [P].[To]
	WHERE	[N].[upper]	= 1
	OR		CHARINDEX('/' + [N].[name] + '/', [R].[PathList]) = 0
)
SELECT	[Part 1] = COUNT(*)
FROM	[Route]
WHERE	[PathList]	LIKE '%/end/';

WITH [Route] ([PathList], [LastNode], [Double]) AS
(
	SELECT	CAST(('/start/') AS varchar(200))
			,[id]
			,CAST(NULL as varchar(20))
	FROM	[#Node]
	WHERE	[name] = 'start'

	UNION ALL

	SELECT	CAST([R].[PathList] + [N].[name] + '/' AS varchar(200))
			,[P].[To]
			,IIF([Double].[Allowed] = 1, [N].[name], [R].[Double])
	FROM	[Route] [R]
	JOIN	[#Path] [P]		ON	[P].[From]	= [R].[LastNode]
	JOIN	[#Node] [N]		ON	[N].[id]	= [P].[To]
	CROSS APPLY	(	SELECT	[Found]		= IIF(CHARINDEX('/' + [N].[name] + '/', [R].[PathList]) > 0, 1, 0)) [Small]
	CROSS APPLY	(	SELECT	[Allowed]	= IIF([Small].[Found] = 1 AND [N].[upper] = 0 AND [R].[Double] IS NULL, 1, 0)) [Double]
	WHERE	[R].[PathList]			NOT LIKE '%/end/'
	AND		[R].[PathList]			NOT LIKE '/start/%/start/'
	AND		(	[N].[upper]			= 1
			OR	[Small].[Found]		= 0
			OR	[Double].[Allowed]	= 1
			)
)
SELECT	[Part 2] = COUNT(*)
FROM	[Route]
WHERE	[PathList]	LIKE '%/end/';
