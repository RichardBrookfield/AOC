USE [AOC];
SET NOCOUNT ON;
GO

DROP TABLE IF EXISTS [#Input];
DROP TABLE IF EXISTS [#Rule];
DROP TABLE IF EXISTS [#Polymer];
GO

CREATE TABLE [#Input]
(
	[id]		int				NOT NULL	IDENTITY (1,1)
	,[value]	varchar(MAX)
);

CREATE TABLE [#Rule]
(
	[id]		int				NOT NULL	IDENTITY (1,1)
	,[First]	char(1)
	,[Second]	char(1)
	,[New]		char(1)
);

CREATE TABLE [#Polymer]
(
	[id]		int			NOT NULL	IDENTITY (1,1)
	,[First]	char(1)
	,[Second]	char(1)
	,[Number]	bigint
);
GO

DECLARE @InputT varchar(MAX) = '
NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C
';

DECLARE @Input varchar(MAX) = '
PHVCVBFHCVPFKBNHKNBO

HK -> F
VN -> S
NB -> F
HF -> B
CK -> N
VP -> B
HO -> P
NH -> N
CC -> N
FC -> P
OK -> S
OO -> P
ON -> C
VF -> B
NN -> O
KS -> P
FK -> K
HB -> V
SH -> O
OB -> K
PB -> V
BO -> O
NV -> K
CV -> H
PH -> H
KO -> B
BC -> B
KC -> B
SO -> P
CF -> V
VS -> F
OV -> N
NS -> K
KV -> O
OP -> O
HH -> C
FB -> S
CO -> K
SB -> K
SN -> V
OF -> F
BN -> F
CP -> C
NC -> H
VH -> S
HV -> V
NF -> B
SS -> K
FO -> F
VO -> H
KK -> C
PF -> V
OS -> F
OC -> H
SK -> V
FF -> H
PK -> N
PC -> O
SP -> B
CB -> B
CH -> H
FN -> V
SV -> O
SC -> P
NP -> B
BB -> S
PV -> S
VB -> P
SF -> H
VC -> O
HN -> V
BF -> O
NO -> O
HP -> N
VV -> K
HS -> P
FH -> N
KB -> F
KF -> B
PN -> K
KH -> K
CN -> S
PP -> O
BP -> O
OH -> B
FS -> O
BK -> B
PO -> V
CS -> C
BV -> N
KP -> O
KN -> B
VK -> F
HC -> O
BH -> B
FP -> H
NK -> V
BS -> C
FV -> F
PS -> P
';

INSERT INTO	[#Input] ([value])
SELECT	[value]
FROM	STRING_SPLIT(
			REPLACE(@Input, CHAR(13), '')
			, CHAR(10))
WHERE	[value] <> '';

DECLARE	@i			int = 1
		,@line		varchar(20)
		,@pos		int
		,@thisch	char(1)
		,@nextch	char(1)
		,@lastch	char(1)
		,@ch		int	= 1;

WHILE @i <= (SELECT MAX([id]) FROM [#Input])
BEGIN
	SELECT	@line = [value]
	FROM	[#Input]
	WHERE	[id] = @i;

	IF @i = 1
	BEGIN
		WHILE @ch < LEN(@line)
		BEGIN
			SELECT	@thisch		= SUBSTRING(@line, @ch, 1)
					,@nextch	= SUBSTRING(@line, @ch+1, 1);

			IF EXISTS (SELECT 1 FROM [#Polymer] WHERE [First] = @thisch AND [Second] = @nextch)
				UPDATE	[#Polymer]
				SET		[Number]	+= 1
				WHERE	[First]		= @thisch
				AND		[Second]	= @nextch;
			ELSE
				INSERT INTO [#Polymer] ([First], [Second], [Number])
				SELECT	@thisch, @nextch, 1;

			SELECT	@ch += 1;
		END

		SELECT	@lastch = RIGHT(@line, 1);
	END
	ELSE
	BEGIN
		INSERT INTO [#Rule] ([First], [Second], [New])
		SELECT	SUBSTRING(@line, 1, 1)
				,SUBSTRING(@line, 2, 1)
				,SUBSTRING(@line, 7, 1);
	END

	SELECT	@i += 1;
END

DECLARE	@step			int = 0
		,@highest		int
		,@MostCommon	bigint
		,@LeastCommon	bigint;

WHILE @step < 40
BEGIN
	SELECT	@highest = MAX([id])
	FROM	[#Polymer];

	WITH [NewPair] AS
	(
		SELECT	[P].[First]
				,[Second] = [R].[New]
				,[P].[Number]
		FROM	[#Polymer] [P]
		JOIN	[#Rule] [R]		ON	[R].[First]		= [P].[First]
								AND	[R].[Second]	= [P].[Second]

		UNION ALL

		SELECT	[R].[New]
				,[P].[Second]
				,[P].[Number]
		FROM	[#Polymer] [P]
		JOIN	[#Rule] [R]		ON	[R].[First]		= [P].[First]
								AND	[R].[Second]	= [P].[Second]
	)
	, [Grouped] AS
	(
		SELECT		[First]
					,[Second]
					,[Number] = SUM([Number])
		FROM		[NewPair]
		GROUP BY	[First], [Second]
	)
	INSERT INTO	[#Polymer] ([First], [Second], [Number])
	SELECT		[First], [Second], [Number]
	FROM		[Grouped];

	DELETE FROM [#Polymer]
	WHERE	[id] <= @highest;

	SELECT	@step += 1;

	IF @step IN (10, 40)
	BEGIN
		WITH [Letter] AS
		(
			SELECT	[First], [Number]
			FROM	[#Polymer]

			UNION ALL

			SELECT	@lastch, 1
		)
		, [Grouped] AS
		(
			SELECT		[First]
						,[Number] = SUM([Number])
			FROM		[Letter]
			GROUP BY	[First]
		)
		SELECT	@MostCommon		= MAX([Number])
				,@LeastCommon	= MIN([Number])
		FROM	[Grouped]

		IF @step = 10
			SELECT	[Part 1] = @MostCommon - @LeastCommon;
		ELSE
			SELECT	[Part 2] = @MostCommon - @LeastCommon;
	END
END
