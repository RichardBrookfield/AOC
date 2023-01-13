USE [Richard];

SET NOCOUNT ON;

-- Test
DECLARE @inputT	varchar(MAX) = '
17807724
5764801
';

-- Puzzle
DECLARE @input	varchar(MAX) = '
14012298
74241
';

DECLARE	@inputRaw table
(
	[id]			int				NOT NULL		IDENTITY(1,1)
	,[value]		varchar(100)	NOT NULL
);

INSERT INTO @inputRaw
SELECT	[value]
FROM	STRING_SPLIT(REPLACE(@input, CHAR(13), ''), CHAR(10))
WHERE	LEN([value]) > 0;


SELECT * FROM @inputRaw;
