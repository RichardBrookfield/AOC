USE [Richard];

SET NOCOUNT ON;

DROP TABLE IF EXISTS [#ordered];
DROP PROCEDURE IF EXISTS [#CountOrdered];

CREATE TABLE [#ordered]
(
	[id]		int	NOT NULL
	,[jolts]	int	NOT NULL
);
GO

CREATE PROCEDURE #CountOrdered
	@combinations	int		OUTPUT
AS
BEGIN
	SELECT	@combinations	= 1;

	WITH [Chain] AS
	(
		SELECT	[display]	= CAST(CAST([O].[jolts] AS varchar(10)) + ';' AS varchar(1000))
				,[id]		= [O].[id]
				,[jolts]	= [O].[jolts]
		FROM	[#ordered] [O]
		WHERE	[O].[id] = (SELECT MIN([id]) FROM [#ordered])

		UNION ALL

		SELECT	CAST([C].[display] + CAST([O].[jolts] AS varchar(10)) + ';' AS varchar(1000))
				,[O].[id]
				,[O].[jolts]
		FROM	[Chain] [C]
		JOIN	[#ordered] [O]	ON	[O].[id]	>  [C].[id]
								AND	[O].[jolts]	<= [C].[jolts]+3
	)
	SELECT	@combinations = COUNT(*)
	FROM	[Chain] [C]
	WHERE	[C].[jolts] = (SELECT MAX([jolts]) FROM [#ordered]);
END
GO

-- Test
DECLARE @inputT	varchar(MAX) = '
28
33
18
42
31
14
46
20
48
47
24
23
49
45
19
38
39
11
1
32
25
35
8
17
7
9
4
2
34
10
3
';

-- Puzzle input
DECLARE @input	varchar(MAX) = '
67
118
90
41
105
24
137
129
124
15
59
91
94
60
108
63
112
48
62
125
68
126
131
4
1
44
77
115
75
89
7
3
82
28
97
130
104
54
40
80
76
19
136
31
98
110
133
84
2
51
18
70
12
120
47
66
27
39
109
61
34
121
38
96
30
83
69
13
81
37
119
55
20
87
95
29
88
111
45
46
14
11
8
74
101
73
56
132
23
';

DECLARE	@number table
(
	[id]		int		NOT NULL	IDENTITY(1,1)
	,[jolts]	int		NOT NULL
);

INSERT INTO @number
		([jolts])
SELECT	[value]
FROM	STRING_SPLIT(REPLACE(@input, CHAR(13), ''), CHAR(10))
WHERE	LEN([value]) > 0;

DECLARE	@ordered table
(
	[id]		int		NOT NULL	IDENTITY(1,1)
	,[jolts]	int		NOT NULL
);

-- Remember to add in the socket and your device...
INSERT INTO @ordered
			([jolts])
SELECT		[jolts] = 0

UNION ALL

SELECT		MAX([jolts]) + 3
FROM		@number

UNION ALL

SELECT		[jolts]
FROM		@number
ORDER BY	[jolts];

-- 1625
SELECT	[Part 1] = SUM([Calc2].[Diff1]) * SUM([Calc2].[Diff3])
FROM	@ordered [O]
JOIN	@ordered [O2]	ON	[O2].[id] = [O].[id] + 1
CROSS APPLY	(	SELECT	[Difference] = [O2].[jolts] - [O].[jolts]
			) [Calc]
CROSS APPLY	(	SELECT	[Diff1]		= CASE WHEN [Calc].[Difference] = 1 THEN 1 ELSE 0 END
						,[Diff3]	= CASE WHEN [Calc].[Difference] = 3 THEN 1 ELSE 0 END
			) [Calc2];

DECLARE @combinations	int
		,@total			bigint	= 1
		,@first			int		= 1
		,@last			int;

WHILE @first < (SELECT MAX([id]) FROM @ordered)
BEGIN
	SELECT	@last = NULL;

	SELECT	@last = MIN([O2].[id])
	FROM	@ordered [O]
	JOIN	@ordered [O2]	ON	[O2].[id] = [O].[id] + 1
	CROSS APPLY	(	SELECT	[Difference] = [O2].[jolts] - [O].[jolts]
				) [Calc]
	WHERE	[Calc].[Difference]	= 3
	AND		[O].[id]			>= @first
	AND		[O2].[id]			>= @first;

	-- The "last difference" is always from adapter to device (and +3), so we won't "miss" anything.
	IF @last IS NULL
		BREAK;

	TRUNCATE TABLE [#ordered];

	INSERT INTO [#ordered]
			([id], [jolts])
	SELECT	[id], [jolts]
	FROM	@ordered [O]
	WHERE	[O].[id] BETWEEN @first AND @last;

	EXEC [dbo].[#CountOrdered] @combinations = @combinations OUTPUT

	SELECT	@total	*= @combinations
			,@first	=  @last;
END

-- 3100448333024
SELECT	[Part 2] = @total;
