USE [Richard];
GO

DROP TABLE IF EXISTS [##Reagent], [##Source], [##Target], [##Ingredient];
DROP PROCEDURE IF EXISTS #up_Compute;
GO

CREATE PROCEDURE #up_Compute(
	@input		varchar(MAX)
	,@debug		bit		= 0
	,@fuel		bigint
	,@ore		bigint	OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	DROP TABLE IF EXISTS [#Ingredient];

	CREATE TABLE [#Ingredient]
	(
		[Step]		int			NOT NULL
		,[Amount]	bigint		NOT NULL
		,[Name]		varchar(10)	NOT NULL
		,[Required]	bit			NOT NULL
		,[Substep]	int			NOT NULL
					IDENTITY(1,1)
		,[Previous]	int			NOT NULL
	);

	IF @debug = 1
	BEGIN
		SELECT		*
		FROM		[##Source];

		SELECT		*
		FROM		[##Target]
		ORDER BY	[Level] DESC, [Name];
	END

	DECLARE @step int = 1, @level int;

	SELECT	@level = MAX([T].[Level])
	FROM	[##Target] [T];

	INSERT INTO [#Ingredient] ([Step], [Amount], [Name], [Required], [Previous])
	SELECT	@step, @fuel, 'FUEL', 1, -1;

	WHILE @level > 0
	BEGIN
		WITH [RoundedUp] AS
		(
			SELECT	[IngredientAmount]	= [I].[Amount]
					,[TargetName]		= [T].[Name]
					,[TargetAmount]		= [T].[Amount]
					,[TargetBatches]	= [Calc].[Batched]
					,[SourceName]		= [S].[Name]
					,[SourceAmount]		= [Calc].[Batched] * [S].[Amount]
					,[I].[Substep]
			FROM	[#Ingredient] [I]
			JOIN	[##Target] [T]	ON	[T].[Name]		= [I].[Name]
			JOIN	[##Source] [S]	ON	[S].[TargetId]	= [T].[Id]
			CROSS APPLY	(	SELECT	[Batched] = (([I].[Amount] + [T].[Amount] - 1) / [T].[Amount])
						) [Calc]
			WHERE	[I].[Step]		= @step
			AND		[I].[Required]	= 1
			AND		[T].[Level]		= @level
		)
		INSERT INTO [#Ingredient] ([Step], [Amount], [Name], [Required], [Previous])
		SELECT	@step+1
				,[RU].[SourceAmount]
				,[RU].[SourceName]
				,1
				,10000+[RU].[Substep]
		FROM	[RoundedUp] [RU]

		UNION ALL

		SELECT		@step+1
					,[RU].[TargetBatches] * [RU].[TargetAmount] - [RU].[IngredientAmount]
					,[TargetName]
					,0
					,20000+MIN([Substep])
		FROM		[RoundedUp] [RU]
		GROUP BY	[RU].[TargetName], [RU].[TargetBatches], [RU].[TargetAmount], [RU].[IngredientAmount]
		HAVING		[RU].[TargetBatches] * [RU].[TargetAmount] - [RU].[IngredientAmount] > 0

		UNION ALL

		SELECT	@step+1
				,[I].[Amount]
				,[I].[Name]
				,[I].[Required]
				,30000+[I].[Substep]
		FROM	[#Ingredient] [I]
		LEFT OUTER JOIN	[##Target] [T]	ON	[T].[Name]	= [I].[Name]
		WHERE	[I].[Step]	= @step-1
		AND		(	[I].[Name]		= 'ORE'
				OR	[T].[Level]		< @level
				OR	[I].[Required]	= 0
				);

		SELECT	@step += 1;

		-- Aggregate
		INSERT INTO [#Ingredient] ([Step], [Amount], [Name], [Required], [Previous])
		SELECT		@step+1
					,SUM([I].[Amount])
					,[I].[Name]
					,[I].[Required]
					,40000+MIN([I].[Substep])
		FROM		[#Ingredient] [I]
		WHERE		[I].[Step]	= @step
		GROUP BY	[I].[Name], [I].[Required];

		SELECT	@step += 1, @level -= 1;
	END

	IF @debug = 1
		SELECT		*
		FROM		[#Ingredient]
		ORDER BY	[Step], [Name];

	SELECT	@ore = [Amount]
	FROM	[#Ingredient]
	WHERE	[Step]	= @step
	AND		[Name]	= 'ORE';
END
GO

DECLARE @input varchar(MAX) = '';

-- Example 1: (165 ORE)
SELECT @input = '
9 ORE => 2 A
8 ORE => 3 B
7 ORE => 5 C
3 A, 4 B => 1 AB
5 B, 7 C => 1 BC
4 C, 1 A => 1 CA
2 AB, 3 BC, 4 CA => 1 FUEL
';

-- Example 2: (13312 ORE)
SELECT @input = '
157 ORE => 5 NZVS
165 ORE => 6 DCFZ
44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
179 ORE => 7 PSHF
177 ORE => 5 HKGWZ
7 DCFZ, 7 PSHF => 2 XJWVT
165 ORE => 2 GPVTF
3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT
';

-- Example 3: (180697 ORE)
SELECT @input = '
2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
17 NVRVD, 3 JNWZP => 8 VPVL
53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
22 VJHF, 37 MNCFX => 5 FWMGM
139 ORE => 4 NVRVD
144 ORE => 7 JNWZP
5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
145 ORE => 6 MNCFX
1 NVRVD => 8 CXFTF
1 VJHF, 6 MNCFX => 4 RFSQX
176 ORE => 6 VJHF
';

-- Example 4: (2210736 ORE)
SELECT @input = '
171 ORE => 8 CNZTR
7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
114 ORE => 4 BHXH
14 VRPVC => 6 BMBT
6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL
6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT
15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW
13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW
5 BMBT => 4 WPTQ
189 ORE => 9 KTJDG
1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP
12 VRPVC, 27 CNZTR => 2 XDBXC
15 KTJDG, 12 BHXH => 5 XCVML
3 BHXH, 2 VRPVC => 7 MZWV
121 ORE => 7 VRPVC
7 XCVML => 6 RJRHP
5 BHXH, 4 VRPVC => 5 LTCX
';

-- Part 1:
SELECT @input = '
3 PTZH, 14 MHDKS, 9 MPBVZ => 4 BDRP
4 VHPGT, 12 JSPDJ, 1 WNSC => 2 XCTCF
174 ORE => 4 JVNH
7 JVNH => 4 BTZH
12 XLNZ, 1 CZLDF => 8 NDHSR
1 VDVQ, 1 PTZH => 7 LXVZ
1 ZDQRT => 5 KJCJL
2 SGDXK, 6 VDVQ, 1 RLFHL => 7 GFNQ
8 JFBD => 5 VDVQ
1 SGDXK => 6 ZNBSR
2 PNZD, 1 JFBD => 7 TVRMW
11 TRXG, 4 CVHR, 1 VKXL, 63 GFNQ, 1 MGNW, 59 PFKHV, 22 KFPT, 3 KFCJC => 1 FUEL
6 BTZH => 8 GTWKH
5 WHVKJ, 1 QMZJX => 6 XLNZ
18 JSPDJ, 11 QMZJX => 5 RWQC
2 WFHXK => 4 JSPDJ
2 GHZW => 3 RLFHL
4 WHVKJ, 2 RWQC, 2 PTZH => 8 WNSC
1 QPJVR => 2 VFXSL
1 NCMQC => 6 GDLFK
199 ORE => 5 PNZD
2 RZND, 1 GTWKH, 2 VFXSL => 1 WHVKJ
1 VDVQ => 8 WFHXK
2 VFXSL => 4 VHMT
21 SBLQ, 4 XLNZ => 6 MGNW
6 SGDXK, 13 VDVQ => 9 NBSMG
1 SLKRN => 5 VKXL
3 ZNBSR, 1 WNSC => 1 TKWH
2 KJCJL => 6 LNRX
3 HPSK, 4 KZQC, 6 BPQBR, 2 MHDKS, 5 VKXL, 13 NDHSR => 9 TRXG
1 TKWH, 36 BDRP => 5 BNQFL
2 BJSWZ => 7 RZND
2 SLKRN, 1 NDHSR, 11 PTZH, 1 HPSK, 1 NCMQC, 1 BNQFL, 10 GFNQ => 2 KFCJC
3 LXVZ, 9 RWQC, 2 KJCJL => 7 VHPGT
2 GTWKH, 1 LNRX, 2 RZND => 1 MHDKS
18 RZND, 2 VHPGT, 7 JSPDJ => 9 NCMQC
2 NBSMG, 3 KJCJL => 9 BPQBR
124 ORE => 1 JFBD
1 QPJVR, 2 QMZJX => 4 SGDXK
4 BPQBR, 1 LNRX => 2 KZQC
1 KJCJL, 15 GTWKH => 2 SBLQ
1 ZDQRT, 3 CZLDF, 10 GDLFK, 1 BDRP, 10 VHMT, 6 XGVF, 1 RLFHL => 7 CVHR
1 KZQC => 8 MPBVZ
27 GRXH, 3 LNRX, 1 BPQBR => 6 XGVF
1 XCTCF => 6 KFPT
7 JFBD => 4 GHZW
19 VHPGT => 2 SLKRN
9 JFBD, 1 TVRMW, 10 BTZH => 6 BJSWZ
6 ZNBSR => 4 PTZH
1 JSPDJ, 2 BHNV, 1 RLFHL => 3 QMZJX
2 RCWX, 1 WNSC => 4 GRXH
2 TKWH, 5 NCMQC, 9 GRXH => 3 HPSK
32 KZQC => 5 RCWX
4 GHZW, 1 TVRMW => 1 QPJVR
2 QPJVR, 8 GHZW => 5 ZDQRT
1 VDVQ, 1 WFHXK => 6 BHNV
1 ZNBSR, 6 TKWH => 8 CZLDF
1 MGNW => 5 PFKHV
';

CREATE TABLE [##Reagent]
(
	[Row]		int			NOT NULL
	,[Side]		int			NOT NULL
	,[Element]	int			NOT NULL
	,[Amount]	bigint		NOT NULL
	,[Name]		varchar(10)	NOT NULL
);

CREATE TABLE [##Target]
(
	[Id]		int			NOT NULL
	,[Amount]	bigint		NOT NULL
	,[Name]		varchar(10)	NOT NULL
	,[Level]	int			NOT NULL
);

CREATE TABLE [##Source]
(
	[TargetId]	int			NOT NULL
	,[Amount]	bigint		NOT NULL
	,[Name]		varchar(10)	NOT NULL
);

SELECT @input = REPLACE(REPLACE(@input
					,CHAR(13),'')
					,'=','');

WITH [Lines] AS
(
	SELECT	[Equation]		= LTRIM(RTRIM([value]))
			,[RowNumber]	= ROW_NUMBER() OVER (PARTITION BY NULL ORDER BY (SELECT NULL))
	FROM	STRING_SPLIT(@input, CHAR(10))
)
, [IO] AS
(
	SELECT	[L].[RowNumber]
			,[SplitIO].[SideNumber]
			,[SplitIO].[Side]
			,[L].[Equation]
	FROM	[Lines] [L]
	CROSS APPLY	(	SELECT	[Side]			= [value]
							,[SideNumber]	= ROW_NUMBER() OVER (PARTITION BY NULL ORDER BY (SELECT NULL))
					FROM	STRING_SPLIT([L].[Equation], '>')
				) [SplitIO]
	WHERE	[L].[Equation] <> ''
)
, [Elements] AS
(
	SELECT	[I].[RowNumber]
			,[I].[SideNumber]
			,[SplitSide].[ElementNumber]
			,[Element]	= LTRIM(RTRIM([SplitSide].[Element]))
			,[I].[Equation]
	FROM	[IO] [I]
	CROSS APPLY	(	SELECT	[Element]			= [value]
							,[ElementNumber]	= ROW_NUMBER() OVER (PARTITION BY NULL ORDER BY (SELECT NULL))
					FROM	STRING_SPLIT([I].[Side], ',')
				) [SplitSide]
)
, [Reagents] AS
(
	SELECT	[E].[RowNumber]
			,[E].[SideNumber]
			,[E].[ElementNumber]
			,[Amount]	= TRY_CAST(LEFT([E].[Element], [Space].[Pos]) AS int)
			,[Name]		= SUBSTRING([E].[Element], [Space].[Pos]+1, 100)
			,[E].[Element]
			,[E].[Equation]
	FROM	[Elements] [E]
	CROSS APPLY	(	SELECT	[Pos] = CHARINDEX(' ', [E].[Element])
				) [Space]

)
INSERT INTO [##Reagent] ([Row], [Side], [Element], [Name], [Amount])
SELECT	[RowNumber], [SideNumber], [ElementNumber], [Name], [Amount]
FROM	[Reagents];

INSERT INTO
		[##Target] ([Id], [Amount], [Name], [Level])
SELECT	[R].[Row], [R].[Amount], [R].[Name], 0
FROM	[##Reagent] [R]
WHERE	[Side] = 2;

INSERT INTO
		[##Source] ([TargetId], [Amount], [Name])
SELECT	[R].[Row], [R].[Amount], [R].[Name]
FROM	[##Reagent] [R]
WHERE	[Side] = 1;

UPDATE	[T]
SET		[Level]	= 1
FROM	[##Target] [T]
CROSS APPLY	(	SELECT [NonOre] = CASE WHEN EXISTS (
									SELECT	1
									FROM	[##Source] [S]
									WHERE	[S].[TargetId]	= [T].[Id]
									AND		[S].[Name]		<> 'ORE'
									) THEN 1 ELSE 0 END
			) [SourceFinder]
WHERE	[SourceFinder].[NonOre]	= 0;

WHILE EXISTS (SELECT 1 FROM [##Target] WHERE [Level] = 0)
BEGIN
	UPDATE	[T]
	SET		[Level]	= [SourceFinder].[Highest] + 1
	FROM	[##Target] [T]
	CROSS APPLY (	SELECT [Lowest]		= MIN([Level].[NonZero])
							,[Highest]	= MAX([Level].[NonZero])
					FROM	[##Source] [S]
					LEFT OUTER JOIN	[##Target] [ST]	ON [ST].[Name]	= [S].[Name]
					CROSS APPLY (SELECT [NonZero] = ISNULL([ST].[Level],0)) [Level]
					WHERE	[S].[TargetId]	= [T].[id]
					AND		[S].[Name]		<> 'ORE'
					) [SourceFinder]
	WHERE	[T].[Level]	= 0
	AND		[SourceFinder].[Lowest]		<> 0;
END

-- ************************************************************************************************************************

DECLARE @fuel_target bigint, @new_target bigint, @fuel_increment bigint = 1, @required_ore bigint, @available_ore bigint = 1E12;

EXEC [dbo].[#up_Compute] @input = @input, @debug = 0, @fuel = 1, @ore = @required_ore OUTPUT;

-- Part 1: simple decomposition
SELECT @required_ore;

-- First estimate, which will produce lots of leftovers, thus the true answer will be higher.
SELECT @fuel_target = @available_ore / @required_ore;

WHILE @fuel_target / (@fuel_increment * 10) > 0
	SELECT @fuel_increment *= 10;

WHILE @fuel_increment > 0
BEGIN
	SELECT @new_target = @fuel_target + @fuel_increment;

	EXEC [dbo].[#up_Compute] @input = @input, @debug = 0, @fuel = @new_target, @ore = @required_ore OUTPUT;

	IF @required_ore <= @available_ore
		SELECT @fuel_target += @fuel_increment;
	ELSE
		SELECT @fuel_increment = CASE WHEN @fuel_increment = 1
									THEN 0
									ELSE @fuel_increment / 10
									END;
END

-- Part 2 examples:
--	82892753
--  5586022
--	460664 

-- Problem: 6216589
SELECT @fuel_target;
