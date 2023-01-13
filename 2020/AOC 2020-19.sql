USE [Richard];

DROP PROCEDURE IF EXISTS [#Decompose];

SET STATISTICS IO OFF;
SET NOCOUNT OFF;

GO

CREATE PROCEDURE [#Decompose]
	@part		varchar(20)
	,@input		varchar(MAX)
AS
BEGIN
	DROP TABLE IF EXISTS #inputRaw, #rule, #ruleDecomposed, #message

	CREATE TABLE [#inputRaw]
	(
		[id]			int				NOT NULL		IDENTITY(1,1)
		,[value]		varchar(100)	NOT NULL
	);

	CREATE TABLE [#rule]
	(
		[id]			int				NOT NULL		IDENTITY(1,1)	PRIMARY KEY
		,[ruleID]		int				NOT NULL
		,[A]			int				NULL
		,[B]			int				NULL

		,INDEX [idx_rule]	NONCLUSTERED	([ruleID])
	);

	CREATE TABLE [#ruleDecomposed]
	(
		[id]			int				NOT NULL		IDENTITY(1,1)	PRIMARY KEY
		,[ruleID]		int				NOT NULL
		,[originalID]	int				NOT NULL
		,[value]		varchar(100)	NULL

		,INDEX [idx_rule]		NONCLUSTERED	([ruleID])
	);

	CREATE TABLE [#message]
	(
		[id]			int				NOT NULL		IDENTITY(1,1)	PRIMARY KEY
		,[message]		varchar(100)	NOT NULL
	);

	INSERT INTO [#inputRaw]
	SELECT	[value]
	FROM	STRING_SPLIT(REPLACE(@input, CHAR(13), ''), CHAR(10))
	WHERE	LEN([value]) > 0;

	DECLARE	@i			int = 1
			,@posColon	int
			,@posPipe	int
			,@posSpace1	int
			,@posSpace2	int
			,@ruleID	int
			,@a			int
			,@b			int
			,@line		varchar(100);

	WHILE @i <= (SELECT MAX([id]) FROM [#inputRaw])
	BEGIN
		SELECT	@line = [value]
		FROM	[#inputRaw]
		WHERE	[id] = @i;

		IF SUBSTRING(@line, 1, 1) IN ('-')
		BEGIN
			-- Rule delete: -n
			DELETE	[R]
			FROM	[#ruleDecomposed] [R]
			WHERE	[R].[ruleID] = CAST(RIGHT(@line, LEN(@line)-1) AS int);
		END
		ELSE IF SUBSTRING(@line, 1, 1) IN ('a', 'b')
		BEGIN
			-- Message not a rule
			INSERT INTO [#message] ([message])
			VALUES (@line);
		END
		ELSE
		BEGIN
			SELECT	@posColon	= CHARINDEX(':', @line)
					,@posPipe	= CHARINDEX('|', @line);

			SELECT	@ruleID = CAST(LEFT(@line, @posColon-1) AS int);

			IF CHARINDEX('"', @line) > 0
			BEGIN
				-- Explicit rule: n aa
				INSERT INTO [#ruleDecomposed] ([ruleID], [value], [originalID])
				VALUES (@ruleID, SUBSTRING(@line, @posColon+3, 1), 0);
			END
			ELSE
			BEGIN
				SELECT	@posSpace1	= CHARINDEX(' ', @line, @posColon+2);

				IF @posPipe > 0
					SELECT	@posSpace2	= CHARINDEX(' ', @line, @posPipe+2);

				IF @posSpace1 > 0 AND @posSpace1 = @posPipe-1
				BEGIN
					-- Rule: n: a | b
					SELECT	@a	= SUBSTRING(@line, @posColon+2, @posPipe-@posColon-3)
							,@b	= RIGHT(@line, LEN(@line)-@posPipe-1);

					INSERT INTO [#rule] ([ruleID], [A])
					VALUES (@ruleID, @a);

					INSERT INTO [#rule] ([ruleID], [A])
					VALUES (@ruleID, @b);
				END
				ELSE IF @posSpace1 > 0
				BEGIN
					-- Rule: n: a b | <something>
					IF @posPipe > 0
					BEGIN
						IF @posSpace2 > 0
						BEGIN
							-- <something> = a b
							SELECT	@a	= CAST(SUBSTRING(@line, @posPipe+2, @posSpace2-@posPipe-2) AS int)
									,@b	= CAST(RIGHT(@line, LEN(@line)-@posSpace2) AS int);
						END
						ELSE
						BEGIN
							-- <something> = a
							SELECT	@a	= CAST(RIGHT(@line, LEN(@line)-@posPipe) AS int)
									,@b	= NULL;
						END

						INSERT INTO [#rule] ([ruleID], [A], [B])
						VALUES (@ruleID, @a, @b);

						SELECT	@b	= CAST(SUBSTRING(@line, @posSpace1+1, @posPipe-@posSpace1-2) AS int);
					END
					ELSE
					BEGIN
						SELECT	@b	= RIGHT(@line, LEN(@line)-@posSpace1+1);
					END

					-- Now we're processing the first part
					SELECT	@a	= SUBSTRING(@line, @posColon+2, @posSpace1-@posColon-2);

					INSERT INTO [#rule] ([ruleID], [A], [B])
					VALUES (@ruleID, @a, @b);
				END
				ELSE
				BEGIN
					-- Rule: n: a
					SELECT	@a	= RIGHT(@line, LEN(@line)-@posColon-1);

					INSERT INTO [#rule] ([ruleID], [A])
					VALUES (@ruleID, @a);
				END
			END
		END

		SELECT	@i += 1;
	END;

	--SELECT * FROM @rule ORDER BY [ruleID];
	--RETURN;
	--SET STATISTICS IO ON;

	SELECT	@i = -1;

	WHILE @i <> 0
	BEGIN
		WITH [FullyDecomposed] AS
		(
			SELECT	*
			FROM	[#ruleDecomposed] [D]
			WHERE	NOT EXISTS (SELECT 1 FROM [#rule] [R] WHERE [R].[ruleID] = [D].[ruleID])
		)
		INSERT INTO [#ruleDecomposed] ([ruleID], [value], [originalID])
		SELECT	[R].[ruleID], [DA].[value], [R].[id]
		FROM	[#rule] [R]
		JOIN	[FullyDecomposed] [DA]	ON	[DA].[ruleID]	= [R].[A]
		WHERE	[R].[B] IS NULL

		UNION ALL

		SELECT	[R].[ruleID], [DA].[value]+[DB].[value], [R].[id]
		FROM	[#rule] [R]
		JOIN	[FullyDecomposed] [DA]	ON	[DA].[ruleID]	= [R].[A]
		JOIN	[FullyDecomposed] [DB]	ON	[DB].[ruleID]	= [R].[B]
		WHERE	[R].[B] IS NOT NULL;

		DELETE	[R]
		FROM	[#rule] [R]
		JOIN	[#ruleDecomposed] [D]	ON	[D].[originalID]	= [R].[ID]

		SELECT	@i = COUNT(*) FROM [#rule];

		SELECT	@a = COUNT(*), @b = MAX(LEN([value]))
		FROM	[#ruleDecomposed];
		PRINT	'values';
		PRINT	@a;
		PRINT	@b;
		PRINT	@i;

		IF @i < 20
		SELECT * FROM [#rule];
	END

	SET STATISTICS IO OFF;

	SELECT	[Part]		= @part
			,[Answer]	= COUNT(DISTINCT [M].[message])
	FROM	[#message] [M]
	JOIN	[#ruleDecomposed] [R]	ON	[R].[value]		= [M].[message]
									AND	[R].[ruleID]	= 0;
END
GO

-- Test
DECLARE @inputT	varchar(MAX) = '
0: 4 6
1: 2 3 | 3 2
2: 4 4 | 5 5
3: 4 5 | 5 4
4: "a"
5: "b"
6: 1 5

ababbb
bababa
abbbab
aaabbb
aaaabbb
';

-- Puzzle
DECLARE @inputP1	varchar(MAX) = '
19: 33 53 | 123 7
3: 33 82 | 123 45
92: 47 123 | 91 33
34: 123 60 | 33 63
91: 123 9 | 33 7
20: 33 46 | 123 79
101: 33 27 | 123 56
47: 52 33 | 84 123
115: 116 33 | 7 123
41: 57 33 | 127 123
33: "a"
109: 123 89 | 33 33
106: 33 72 | 123 6
8: 42
104: 92 123 | 41 33
75: 123 22 | 33 100
21: 76 123 | 28 33
102: 95 33 | 81 123
54: 33 44 | 123 2
77: 123 13 | 33 116
1: 33 26 | 123 34
83: 123 90 | 33 66
11: 42 31
58: 9 33 | 63 123
136: 33 74 | 123 109
25: 59 123 | 52 33
17: 123 91 | 33 136
116: 89 89
32: 116 33 | 53 123
72: 9 123 | 111 33
70: 33 9
80: 33 20 | 123 1
18: 111 33 | 74 123
86: 33 122 | 123 55
14: 33 108 | 123 37
84: 33 33 | 123 123
67: 6 123 | 18 33
78: 123 58 | 33 96
38: 111 123 | 52 33
119: 125 33 | 77 123
69: 33 32 | 123 64
10: 110 123 | 3 33
118: 69 33 | 107 123
85: 123 62 | 33 17
61: 33 117 | 123 93
62: 70 123 | 117 33
4: 123 52 | 33 7
52: 123 33
40: 84 123 | 60 33
49: 123 47 | 33 65
79: 13 33 | 84 123
6: 7 33 | 116 123
113: 33 133 | 123 115
98: 116 89
53: 123 123
42: 33 35 | 123 21
44: 33 15 | 123 55
100: 123 67 | 33 121
27: 88 33 | 9 123
76: 33 23 | 123 85
16: 33 24 | 123 73
9: 123 33 | 33 123
26: 109 123 | 59 33
36: 7 33 | 52 123
50: 123 88 | 33 63
65: 59 33 | 84 123
105: 9 123 | 7 33
112: 74 33 | 60 123
120: 111 123 | 84 33
23: 106 33 | 126 123
110: 104 123 | 102 33
128: 33 12 | 123 5
31: 123 114 | 33 10
30: 57 123 | 98 33
82: 33 51 | 123 128
125: 7 123 | 9 33
99: 123 120 | 33 93
87: 52 123 | 59 33
37: 33 101 | 123 16
43: 123 7 | 33 88
117: 123 63 | 33 7
12: 33 88 | 123 53
55: 33 111
2: 123 132 | 33 38
96: 33 116 | 123 7
135: 33 109 | 123 111
126: 112 123 | 36 33
97: 111 33 | 60 123
22: 33 113 | 123 48
24: 74 33 | 84 123
130: 91 33 | 103 123
132: 33 109 | 123 53
59: 33 89 | 123 123
51: 123 40 | 33 50
28: 54 123 | 68 33
66: 33 111 | 123 52
64: 13 33 | 9 123
15: 33 13 | 123 111
114: 14 123 | 75 33
35: 123 131 | 33 39
90: 60 123 | 52 33
124: 33 32 | 123 71
63: 123 123 | 33 123
121: 33 97 | 123 19
71: 116 123 | 53 33
5: 33 53 | 123 63
111: 33 33 | 123 33
74: 33 123 | 33 33
48: 94 123 | 105 33
56: 111 33 | 84 123
29: 30 33 | 130 123
45: 99 123 | 119 33
93: 52 33 | 52 123
122: 33 9 | 123 7
103: 13 33 | 63 123
68: 61 33 | 49 123
94: 33 88 | 123 129
129: 89 33 | 33 123
133: 123 59 | 33 129
127: 33 74 | 123 59
0: 8 11
134: 78 123 | 83 33
73: 111 33 | 116 123
89: 33 | 123
123: "b"
131: 80 123 | 134 33
81: 123 43 | 33 56
7: 123 33 | 123 123
13: 123 33 | 89 123
60: 33 33
108: 124 123 | 86 33
39: 123 29 | 33 118
95: 123 87 | 33 135
88: 33 123
57: 123 60 | 33 9
107: 123 4 | 33 25
46: 123 60 | 33 7

aababbaabaabbaaaaabaaabb
aabbabababbabbbabaabbbaa
aaaaabbababbbabaaabaabaaaaaaabaabababababaaabaabbbbbaaaa
aaaaaababbaabbaaaabbaaab
aabbbaababaabaaaabbbbaba
bababaaaabaabaaabaababba
aaabbabaababbaabaababaabbababababaababbbabaabbababababbb
baaaabbabbaabbaabbbbaabb
aabaaaaaababbaababaabbbb
abaaabbababbabbbbaabbbaa
baababbbbbbbbbabbaaabaaa
aabbbaaabbbaaabababbaaabababbaabbaababaaabbbbbaa
aaababaabbaabbabbaaaaabb
abaaabbbabbabbbbbaabaaabbaaabaabaaaababbaaaaaaba
abbbabbbabbbaabbbbabbabbbabaababbabbbbba
babaaabbbaaabbabaabbbbaabaaababaaaaaabab
babbabaabbaabbbbbbaaabab
baabaabaaaabbbabbbbbbabb
bbabbabbaabaaaaaaabaaabb
bbaaaaabbbaaaaabaababbba
aabbbbaaabbababbaabbaaab
ababbbbababababaababaaba
abbaababaabaaaaabaaaaaba
abbbaababbbabbbaabbbabab
baaaabaababbbbabbaaabaaa
aabaabaabbaaaabbbbbbabbb
aabababbbaabbabaabbbaaab
abbabbbbbbabbaaaababaabbabbaababbabababbbbbaaaaaaababbbaabaabbabbabbbbaaaaababaabbbaabba
bbbaabababbbbbbbaabaabbbaaabaabbbbbbbbbb
aaabbaaaaaaaabaababaaabbbaaaaabb
bbbababbaabbaabbaaaabbaabbabbaba
aaababaababbbbabaababababbaabbaabbabbabbbaaaabababbabaaabbbbaaababbabaaa
bbbababaababbbbbbbababababbbaabbaabaabbabbbaabab
aabbbbaababbbbaabaaaaaaa
baabbabababababaabbbaaaabaaaabbbaaaaabab
aabbaabbbaaabbabaaabbbba
abbaaabbbaaaabaabababbbb
baabaaabaabbabaaaababaabbaaababb
abbabbbbbbbabbbaabaabaabbabaaaab
bbaabbbbbbbbbbabbababbbb
bbaaaabbababaabbaaabbbaaaabbaaaaaabaabaaabbabaab
aababbababaabaaababaaaab
baaababaabbaabaaabbaabbb
bbaabbaaaaaabbbaaaaababb
abbbbaabbbbababbbababaab
baaaaaabbbbabbababaabaaabbbabbbaaaaababb
aabbabaaabaaaababbabaaaa
aaaabbaabbababbaaababbba
aaaabaabaababbabbbbabbba
babaaabaabaababaaabaaaaabaabbbab
aababaaaaabbaaaaaaabbabb
aabbbabbabaaaaaaaabaaaab
babaaabbabaabaabbbaabbaabaabbaab
aaaaaabbbaabbabaaaaaaaba
aabbbbaaabbaabaaaabbabaabbbaaaaabbababbababaabbb
aabbaaaaabaabaaabbabababbbbabbbb
baabaaabbabbbbabaaaaabbbaababbaabbbabbababaaaabbbbabbaab
aababbabaabababaabaabbaa
aababbbbaaababbaabbbbbbaaababaaaabaabbbabbaabaaabbbbbaab
baabaaabbaaababaaabbaaaabaaabababbaabababaabbabb
baaabbbaaaababbbaabbaaab
bbaabbaaabbababbaaabbbbb
aabbababbaababaabaaaaaabaababbaaaaabaaabaabaaaab
aaaaaabbabbabbbbaaabaaaa
babbbbabbabbaaabababaaaa
abbaaaabbaabbbbbbbbbbbbabaabaaababbbbaababaaaaaabbaababa
bbbababaaaababaabbaababa
baabababbbaabbabbaaababaaabbbbabbaabbbab
abaabaabaaabbababaabbbab
baaaabaaabbbaabaaabbbbba
aababaaaaabbbbbbababbaabababaaaa
bbbabbabaabbbaaabbbabbbb
baabbbbbaaaabbabababbaaabaabaabbbaaabaabbaaababbbaaaaaaaabbaabbbabbabaaabbbbaaba
abaaaabaaaababbabbbbbbabbababbaa
bbabbbabbababaabbaababbaababaababaaabaaaabbabaab
aaababbaababbbbaabababaa
aabbaabbbbababbabbabbaaa
bbbabbbabaababbbbabbbbabbbabbaabbbbbabba
abaaaaaabaaabbabaaaabbab
bbaabaabbaaabbabbabbbbabbaabbbab
baaabbbaaaabbbababbabaaa
aabaaaaaababbbbaaaabbaaaaaabbabb
baaababababababbaabaabaabaaaaaabababaaaaababbabbbaaaabab
babbababbbbaaaaaaababaabaaaabaaababbaabababaabbabababbaa
abbbbaabaabbbaaabaabbbbb
babbaabbaaababaabbaaaabbbbaabbaaabaababbbaaaaabaaaaababb
baababaaaaababaaababbababaababaabbabaabaaabbbaba
abbaaabbbaaabbbbabbabbbbababbabaabbabbbababbbbbb
babbaabbbbbabababbaababb
baaabbaabababababbbabbbaaaabaaababaaaabb
bbaaabbaaaabaaabbbaaabaabbabaaabaabbabbaaababbbbbbabbabb
aaabbabababbbbaabbabbbbb
aabbababaaabbbaaabbbbabb
aababaabaaabbbaaaaabaabb
ababbbbbbaabbabaaabbabbb
baaaabaabbabbabbbbbabababbbababb
abbabbbabbbabbbabbbbaabb
bbbaaaabaababbbbbababbbb
aaabaaabababbbababababbabbbababaabbaaabaaaaaabab
bbaaaabaaabbaabaaabaabbbbabbabbbbaabbabaaababaaaaabbaabbbaabaaaabaaabbaabbabaaaa
abbbabbaabaabbbbbbabaaab
abbbabbbbabaaabaaaabbbbb
abaaabbabbbbbbaaabaaabbbbbaababbababbabb
ababbbbaaaabbaaaaabbabbb
bababaaaabbaaabbbbaaaaba
aaabbaaaabaaabbaababaaaa
babaaababbbaabbbbbaaaaba
aaababbabbabbbbabbbaababbbaaaaba
baaaabaabaaababaaaabababaaaaabbbabaaaaaaabababaaabbbabab
aaababbbabbbbbbabbbaaababaaaaaba
abbabbbbbbbabababbbabaabbabbabaabbaaababaabaaabbabbbabab
aaaaabaaaaaabbbababaaabaaabaabaabaaababb
bbabababaabbbaabbaabaaaaabbabbaa
bbbabababaababbbbbbabbabaabbaaab
baabaaaabbababbabbbaabab
bbababbabbbbbbbabaabababbbbaaaaabbbbaaaa
aaabbabaaaaaaaaabbaabaaa
babbababaaababaabbabbbba
baababaabbaabaabababbbaa
bbaabaabbaaabbaaabaaaabb
baaabbaabbbaaabaababaaab
bbbaaabaabaabababbaaaabbaaababbaabbbaabaaaaaabba
babbabaaaabbaaaabaabbbaa
babbaaabbbbaaababaaababaaabbbaaaaababaabaaaabaabbbbbaabbabaaaabbaaaaababbaaaaabb
aabbbaaabbabbabbbbbbaaba
bbabbbabbaaabbabaaabaabb
bbbababaaababbbbaabaabab
bbaabbbbbbbababbabbaaaaa
aaabababbabbbbbaabbabbaaaaaababa
aabaabaaaaaabbbbabbaababaaaaaabbaabbabba
bbbaaaaaaababaaaaaabbaaabbaaabbabbbbbaabbabaabaa
ababbbabbbbbbbaabbaaaaaa
aaaabaabaabbabbbaabbbabaababbabababbbabbababaabbbaaaabbb
aabbbbbbaababbbbbabbbabb
babbbbaaaabaabbaaaaaaabbbabbbaaabbbbaabb
abaaabbabbaabbbbaaaabaabbbbbabbb
bbabbbababbaaabbabbabaab
aaababaaaabbaabaaaaabbaaabbaababbbaaabab
bbaabbbbaabbbbbbaaababbbabbbbbbabbbbaabb
aababbabbaabaababbbbbbbabbbbbaaaaaabbaab
abbaaabbbbbabaabbabaabaa
aaabababbabababbbabbbaabbbaabbabbaababaaabbaaaaa
baaabbbbaabbbbbbbbbaabaabbaaaabbaaaaaabbbbbabbaa
aabaaaaaaaababababaaaabb
bbbbbbaaabbaaabbabbbabba
aaaabbbbaaaabbbbaaababba
baaabbabbbbbbbabbababbaa
aaabbbabbaabbaaabbabbbabbaabaaabaaabaaba
baaaabbbabaaaabaabbaaaaa
aabbabaaaaabbbaaabaaaabaababbbbaaabaaababbbbaaba
bbabaababbbabbababaabbab
aababbaabbaaaabbbbabbbba
bbababbaaabbbabbbbbabaaabaaaabbbabbbabbbaaaabaababbbbbaa
bbbbbbabbbabbbabaaabaabb
babababababbbbaabbaaaaabbbbbbaaa
baaabbbbbabababaaaaababa
bbababbbbbaababbbabaabaa
babaaabbabbbaabbbbabaabaaabbbaababbbaaabaabaabbbabaabbaa
abaaababaaabbbabababbababbbbaaaa
abaaaabaabaababaabaaaababbabababaaaaaaba
abbbaaaabbaabaababbbabab
abbababaaabbbbbbabbaaaaa
baabbaaaaababbbbbbaaabaa
baabbaaaaabbababaababbabbbbbbbbabbabbbabbbbbbababbabbbbbbbaaaabaaaaaaaab
bbbaabbbababbabaaabbbaaabbbabbbbbbabaaaa
aaaaaaaabbbbbbbaabbbbbaa
bababababbbaaaaabbbaaaab
bbabbabbbbaabbaaaabbabaabbbbbaab
bbbaabbbbaaaabbbbbaabbabbbabbbba
baabbabaababaabbaaabbaab
aabbaababaababbbababbbaaaaaaaabbbbbabababaabbbbaabbabbba
bbbaaababbabbbababababba
aaaabaaaaababbabbbbbabababababbb
babbbaabbbbaaaaabbabbbbb
abbbbaabbbbababbbabbaaabaabbabba
babbaabbaaababbbababbbabbabbaabbbabababbaababbbabbbbaaab
abaaabbbbbbaaaaabaabbaaabbaabaaaabababaa
baaaaaababbaababaaaabbbbbbabbbbb
bababaaababaababaaababbbbabbababbbaabbaaaaabbbbb
bbababbbbbaabbaaabaaaaaaababaaab
abaaababaababbababaaaabb
abaaaabababbbaabbbababbaaaabbbbaaababbba
aaaaaabbbababaaababaaaaa
bababaaaaabbababbbaaaabbabaabaabababaabaabbbaaab
bbbbababbbbaabaaabababbb
abaabababababaaaaabababbbabbaaba
abababbbaaaaaabbaababbabaabaababaabbaabbaaabaababbbbbbba
baaaaaabbbaabaabbbababbbbaaabaaa
ababaabbbbaaaababbbbbaab
aababbbbabbaaabbbbbaaaab
baaabbbaabaaabbaaaaaabab
bbbaabbbbabababbbbabaaaa
aaaaabbbabaaabbbababaaab
aaaabaabbaabbaaaaaaabbab
abbaaabbbbbabbabbabaabba
bbbbababaaabbaaaabbbbbab
abaabbbaaababbbbababababbaabababbbababba
baaaabbabbbbbbbaaabaabaabababaab
ababbbabababbababbbbabababbabbbbbbabaaaaabbbbbab
baabaaaabbbbbbababbbaaaabbabbbbb
bbaabaabababaabbbaaaaabb
abbababbbbbabababbbabbbaaaabbabaabbbaababaababaaabbbaaabbbabaaab
baababaabbbabbbabbaaabbabaabaaababaabbab
bbbababbabaaabbaaabaabaabbbaabaabaabaaababbababbbbbbaaaa
baabaaabaabababaabbbaabbbabbaabbbbaabababbabbababbaaaaaa
baabaababaabababbbababbbbbaabbaababaaabbaaaabbab
bababbabaabaabbaabbaaaabbabaaabbababbbabbaababaabaaaaabaaabbbbabbbbbabaa
babbaaabaababaaabaabaabb
ababbbbabbbaabaabaaababb
abbaaabbbbaabbaaaaaabbbababaaaaa
aabbaabaaaaabbaaaaabaaaa
babaabababbabbbabbbaaabb
bbababbbabbbabbbbbaabbabbbbabbbaabbbbbbaabbbbbaa
bbabababbbbabbabbbbabbaa
bbbbbbbaabbababbbabbbbba
baabaaaababbabaaaaaabbaaaaabbabb
abaababaabbbaabaaaabbbaaabaababb
baaaabbababbbbabbababbabababbaabbbabaabaabaababb
abbaaabbbaababaaaabaaabb
babbaaabbbababbaaabbbbab
abbaaabbaaababbbabbbbaba
baabbbabbaaaabbaaaaaabbaabbbbabbaaabaababbaaaaaababaaaaabbbbbaaa
baababbaabbaabbbbbabbbaabbbbaabbbbbbaaaabababbbbaaaababaaaababbbaabbbbbabbbabbaaaabbabaa
baabbaaaaaabbababababbabbaabbbab
ababaabbbbbaabbbbabababbbabbbaaabbababbabaaababbababaaab
bbabababbabbbaaabbabbbba
bbaaaaababbababbaaaaaaaaaaabbbba
aababaaabbbaaababbaabbabbaaababaabaabaaaaabaaaab
babbabaabababbababbbabab
aababbaabaabaaaaaabbaaaaabbbbaabbabbbabb
bbabaababaaabbabbbbbbabb
babaaabbababbababbbaabaaabaabbaa
abbbbbbaaaaaaaaababaaaaa
aabababaaabaaaaabaabbbaa
abbaabaabaabbababbbaaabaaabbbbaabbbaaaaaaabaabaaabbbbababbabaaab
abbabbabbbabaabaababaaaa
babaababbababbabbbbbaaaa
aabaabbaaaaaabaabaabbaaabbaabbbbbabbababaaabbbbaaaaaaabaaabbbababbbbbaaa
baabaababbababbbbbbbbabaaabaaaaaaaabbbbbaaabababbbabbbbbbabbabaaabbbbaba
abbbaabbabbaaaabbabaabaa
aaaabbbbaabababbabbbaabaabbababaabababaaabbbbbababaababb
baabaaaaabaabbbabbbabbaa
abbbbaabbbbabbbaabbabbabaaaaabbbababaaab
aaabababbbababbbbbbbbbbb
aabaaaaababbbaababaabbab
baaabbbaabbbaabaaabaaaaaabbabababbbaaaabbaabbbaa
babbaabbababbaabbbbbaaba
abbbbaababbbabbbaabbbabbabbbbbbbbaabbbab
aaaabbaaaaaababaabaabbababababaa
aabbababbbbabbabbabbbabb
bababbabbbbbababaaaababa
aaaaabaaaabababbabaabbbaabbaababaabaabbabbbabbaaaabaaaba
aabbbabbabaaaababaababba
aaaabbaaabbbbaabaaaababb
bbababbbbabbababababaabbbaabaaaaaaaaabba
aaabbaaaaababbbbbababbabbababbababaabbbaaaaabbab
bbabbbabababbbabbaabbbba
ababbbbaabbabbbbabbbbabb
baaaabbbabaaaaaaabababaa
bbababbabababbabbbabaabb
aabbaabbabbababaabbaaaba
abbbaaaaaaabbbbaababbabb
bbbbbbaabbbaaaaabbabbbbb
aabbabaaabbbaababbaababa
abbbaabaabbaabaaabbbabba
bbbabbabaabbbbaaabbbbbabbabbabbabbaaabab
aababbaaaaaabbbabbbbbbbb
abbabbabababbaabbabbbbbb
baaaabbbbaaaaababbbbaaaaaababbba
bbbbbbababbababaaabbaaab
aabbaaaabababaaaaaababbaabbbbbab
aabababaabbaababababbaaaabbaababbbaaaabbbaabbbba
bbabababbabbabaaaabbbaabaabbbaababaababb
aaaaabbbbbbbbbaaabbbaaab
abbbbaabbaaabbaaabababaa
babbbbaabbaaaaabbbaaaaba
aabbaabababbbaaaaababaaaaababbabbaaabaab
baaaabbaaaaabaaaaaabaaba
bbaaaabbaabbababababaaaa
aaaabbaabaababbbaabbbbba
babaaabaababbaabbababbbb
abbbaaaaaababaabbabbabaaaaaabaabaaabaababaaaaabb
baabaaaabbaaabbaababababbbbaabaabbaaaaaa
bbbbbbababbbaababaabbabb
aababaababaaaababbbabbaa
ababbababbababbbbbaaaabbbaababbabaabbbaa
babbbbaababbaaabbbaaaabbaabbbaaabaaabbbabbaababb
bbbbaabbaaabbbbbaaaaaaabbabaaaab
abbbabbbbaabaabaabbbabaa
ababbaaaaabbaababbaabbbbaabbabbaababaaba
aababbabaaaabaababaabbaa
abbababbabbabbbaaabbbbab
babbbbabbaaaababbababbaa
aaabbbbaabbbbaaaabbabbaabbabbbbaaaabaabb
ababbaaaaabbbabbbbbabbbb
abaaaababbbbbbbabababbabaaabbbabbbbaabbbbbaabbba
ababbaababbaaabbbbbabbaa
baabaabaabaaabbaaaaaababaabaabababbbabbbbbabbbabababbbbabaaaabba
baabbaaabaaabbaaababaaaa
bbababbaaaaaabaabbbabbaa
babbaaabbabaaabbbbabaaab
aaaaaaaaabbbaabbabaaaaaaababbaaabbabaaab
ababbbbbbababbbaaabaaabb
baaabbaaaaabbaaaabbabaab
aaaaabbbbabaababaababaabaababaaaaaabbbba
abaaababaabaaaaaabbbbbbabbbbaabb
abaaabababbababbaababbabbaabbbaa
aabbbaabbababababaababba
abbbaababbbababbabaabbbbabaabbabbabbaaaabbabbbababbbbbbaaabbbabbbaaaabbb
abbabbbabaaabababbaababb
aaabababaabaabbabbaababa
babaababbbbaabaaaaababbbbababbba
babababbababbbbababbaaaa
aaaabbbbabbbbbbabbbbabbb
abbbaabaaaaaabbbbabbabbb
baaabbaaabaaababaabbbabbbaaabbbaaaaaabbb
bbbabaaaaaabbaaabbaaabaa
abbbaababaabaababaabaaaabbaaabbb
babaabababbbaabbbbbababbabbaaabbbbababababbabaaabababbaabbaabaaabbbbbabb
bbbbbbbabaabaaabbababbbb
aaababbbbaabbababbabbbaa
aaabbbabbaaaabaaaaaaabab
babaaabaaababbbbbaaaaabb
abbaaaababbaabaabaabbbbb
aaababbabbaaaabbbaababba
aaababbaabaaaababbaaabab
aaaaaaaabbabbabbbbbaabba
aaabaabbbbabaaababaaaabbbbbbbabbbabaaaaabaabbaaaabaaaabbaaabbbaabbaaabbb
aaaabaaabaabbabaabbababaabaabbbbbbbabbaa
abaabaaaabbbaaaaabbaabbb
aabbbbbbbbbbbbbaaabbaababababaaaababaaab
aaababaabbbaabaabaaabababbbbbbababaabbabbbbbbaaa
aabbababaaaaaabbbabaaabbbabaaabababbbbba
abababbabbbaabbaabbaabbaabaaabbaaabbbaab
babbabaaabaaabbaaabbbaaaababbbababbbbabbabbbbaba
aaababaabbbbababbabbbaabbbababbabbabbbba
aaababbbbaaabbaaaaaababa
aaaabbbbaaabbabababbabaabbaaabaa
bbabaababbaabaabbaabbabaabbbbbbababbbbbababbabba
ababbbabbababbabbabbbbba
abbaaaabaabbbbbbbbabaaaa
baabbaaaaaaaabaabbaababa
bbbabaaaaabababaabbbabbbbaaababababbabaababaaaaababbabba
bbbabbbababaabababbbbabb
aaabbbabaabaabaabbbbbbba
aaaaabaaababbaaabbbaaaab
bbaaabbaaaaabbbaaaaaaaab
baaabbaaabbabbabbaaaaaaa
aaaabbbbbbbababbaababbba
aaaaabaaaababbaaaabbbabbbbabbaab
aabbababaababbbbbaabaaabbaabbbbb
aabbaaaaabbaabababaaaaaaaaabbbaabbbbbabb
abaabbbaababbaaabbbbbbaaaaaaabaabbabbaaa
aaaabbaabaaaabbbabaabaabaaabbbabababaaaabbbbabbabbbbabaa
baaaabbbbaaabbbaabababaa
bbbbababbbbabbabbaaaabbaabbbaaaababbbbbbbbababaabaaaabab
baaabbbbabaaabbbaaababaaabbabbbaaaaaabba
bbabaabaaabbabaabbabbaaa
abaaabbaabbaabaababbbbaaaabaabab
abaaabbaaaabbbaabababbbb
bbabbbabbaabbabaaaabababbbaabbbaaabbbbba
babbbaaaabbabababaaabaaa
bbbbbbbaaaaaabbbbbbbbaaa
aabbaaaabaaaabaabbbaaaaaaabaaaab
baababaabaaabbabbababaaaababbabaabbbbaba
aabbaaaaabbaabaabaabbbaa
abbbaabaababbbabaabbaababababbba
abbbbbbabaaabbababbbbaabbbabbaabbbaaabaa
aaabbaaaaabbbabbbabaabba
aaababbbbaabbaaabaaaabbaaabaabab
baababbbababbbabbaabbbab
abbbbbbaaaaaaabbaabaaaaaabaaaabb
aabaabbaaabbaababbbababbaaabaaab
aabababababbbbabaabaabaabaabbaaaabababbaaabbabbbbbaaabaa
baaabbbaaaaaaaaabbabaaaa
baaaabaaabaaabbaabbabbaa
aabbaaaaabbaaabbbabbbbba
bbbabbbaaaaaabbbbbbbbaaa
aababbaaabaaaaaaaaaabbbababbaaaa
ababbbbabbaabbabbbabbbbb
babbbaabababababbaabbabb
aabbbbaabbbabbbaaaabaabb
babaaabaaabaaaaabbaaabab
aabbabbabbbbaababbabbbbbbbbbababaaabbaab
bbbababbaababaababababbb
bbaabbbbbbbbbbbaaabbbbaaabaabbbaaaabaababbaabaaa
baaabbbaabbaaabbbabbbbba
ababaabbabaaababbbaaaaababbaaabbbaaaabaabaaaaaaa
bbabababbbbaaaaaaabbaaaabaaababbbaabbbab
ababaabbabaabbbababbbbbb
baabaaaabbaabbabbaaabbaaaaaabbbabbaabaaa
babaaabbbaaabbbbbaaaabbbbabbbbbb
abaababbbbaabbbaaabaabab
bbaaabbaaaabababaaaaaaab
abaabababaaaabbbbabaaaaa
bbababbbabbbbbbaaaaaaabbbababaaabbbbbaba
abbbbbbabbaaaaabaabbbaabaaabaaaa
abbaabaabbbabababbbbabaa
bbabbbabaaaaabbbbaaabaaa
ababbbbaaaabbbababbbaaaabbaabbba
babbbaabbaaaaaababbbabab
baabababaabababbbbabababbabaababbbabbaababbbbaaa
bbbaabaabbbbbaabbbabbaabababbabaaabbbbaaaabbbbabbaabbaaaaababbbababaaabb
aabbaabaabbbbaabbbaaabaa
baaaabaaaabababbbbbabbbabbbabbaa
aaaabbbaabbababaaabaaaba
babbbbabaabbabaabaaabaaa
baaababbbbabbabbabaaaaabbaababbaaabaaaaaaabbaaaa
bbababbbbbbaaaaabbbaabbbbbbbababbababaab
aababaabababbaaabbbabaaabbabaabaabaaababbabaabbabbababaa
aaababbbbbababbaaaabababababbabaaabaaaab
bbaaaabbabbaabababbbabbbaababbabbabbbaba
bbbabaababaaabbbbabaababbabbaaababbbbaba
abbbaababbbabaababbbbbaa
ababbbabbaabaaabaaabababaababbba
bbabbbabbabaabbbabaaabaaaaaaaaab
bbaabbaaaaabbababbaaaaabaabbbbaaabaaabaa
aababaaaababbbabbbbabbaa
aabbbaaaaabaabaabbaababb
abaabababababaaaabbabbbbbabbbbbb
bbaaaaabbabaaabbaaabbabaabaaaabbababbabb
ababaabbaabbbabbbbbbbaaa
abbabbbbabbabbbbabbbabab
bbabbabbabbabbbababbabaaabbabbbbaaabaabb
ababbababbbaaaaabbaabbaaabaabababaabababbaaaabaabbbabbaa
bbabababbbbaabbbbbabbbba
abbaabbaabbbbbabbabbababbbbabbbababbbaaaabbbbabbaaabbaabbbbbbaba
aaababbabbbaabbbaaaabbab
aabbaaaaababbabaabbbabbbaaabbbababbaaaba
baaabbbabbbabbababbbaaab
aabbabaabbbaaaaababbbbaaabbababbbbabbaaa
bababaaaaababbaabbaababb
aabbabaababbbaaababbaaaa
bbbabaababaaaabababbbaba
ababbbbbabbbaaaabbbabbbb
babaabaabaabbbbaaaabaabbbaaababaababbaaaaaababaaaaabababaaabaaaa
bbbbabababaabaaaaabbbaaabbaaaaabbabbabbabaaaaaaa
abbaabaaabaabaabbbaaabbb
ababbabaaaabbbabbabaabaa
bbbababbaaaaabaabaaaabaabbbbabaaaabbabba
bbabaabaaabbaabababbabbb
baababababbbaabbbbbbaaabbabbaaba
aababababaaabbaabbbabbbabbbbabba
aaababaabaabaabababbbbabbababababbabaabb
abbaaabbabbbaaaabbbaabaaaababbaabaaaaabb
aabbaabbaabaaaaaabababbb
ababbbbbbbaabbaabbabaaab
bbaaaabbbbabababbaabbaab
aabababbaaabbbabbbabaaaa
abaabaaaabbabbbaaaaabbbababbbbba
baaababaaabbabaaabababba
ababaaaabaaabbababaabbaaabbbbbbabbababbaaaaabbbaaaaaaaabaabbbaaabaabbbba
aababaabbaaabbbabbaaaaba
baababaaabbbaaaaabbbabab
ababbbabaaaabaaaaabaabbabbbababaaaaababbbaaababbabaabbbb
aabbbabbaaababaaabbbbaaa
aaaaaabbaaababbabbbbbaaa
aabbaaaabaaaaaabbbaabbba
abaabbbabbbaabbbbbabbaab
bbabababbaabbaaaabaabbbb
ababaabbaaaaaaaaababaabbabbbaabbbababbbbbbabaaaa
aaabababaaaabbbaaabbbbaaababbbbabbaabababaaaaabb
aaabbbabaaaaaabbbaabbbbb
baaabbbababbabaaaabbbbba
baaabbbabbabbabbbbbabaabababababbabbbbbaabbaaaba
aaaabaaaaababbababbabaab
baaaaaabbbbabaaabaababaaabbabaabaaabaabb
bbabbbababbbaaaabbbbbabb
aaababaabaaaaaababbbabaa
bababaaaaabababbbaabbbaa
aababaaababaaabbaabbbbab
abaababaaaaabbbbabbbbbaa
babaababaababbababbbbaaa
ababbbabbaaaabaababbbbabbaaaabbababaabaabbbbaaabbbbbabba
aabbaabaababaabbaaababaaaaaaaabbaaaaabbbabbabaab
';

-- Extras to define:
--	8: 42 | 42 8
--	11: 42 31 | 42 11 31
-- Rule removal can be done with a hyphen prefix, to allow replacement
DECLARE @inputP2	varchar(MAX) = '
-8
8: 200
200: 42 | 201
201: 42 42
';

-- 'NEED TO LOOK AT RULES WHICH ARE STRAIGHT SUBSTITUTIONS AS THEY COULD JUST BE UPDATED'

/*


300: 31
301: 300 31

400: 42
401: 400 42

-11
11: 500
500: 300 400 | 501
501: 301 401


201: 42 42 | 42 202
202: 42 42

300: 31
301: 300 31
302: 301 31
303: 302 31
304: 303 31

400: 42
401: 400 42
402: 401 42
403: 402 42
404: 403 42

-11
11: 500
500: 300 400 | 501
501: 301 401 | 502
502: 302 402 | 503
503: 303 403 | 504
504: 304 404
*/

DECLARE @input	varchar(MAX)
		,@part	varchar(20);

--SELECT	@part		= 'Test'
--		,@input		= @inputT;

-- 241 - takes about 40s to run.
--SELECT	@part		= 'Part 1'
--		,@input		= @inputP1;

SELECT	@part		= 'Part 2'
		,@input		= @inputP1 --+ @inputP2;

EXEC [dbo].[#Decompose] @part = @part, @input = @input;
