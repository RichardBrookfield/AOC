USE [Richard];
GO

WITH [Numbers1M] AS
(
	SELECT TOP (1000000)
				[N] = ROW_NUMBER() OVER (PARTITION BY NULL ORDER BY (SELECT NULL))
	FROM		[master].[dbo].[spt_values] [A]
	CROSS JOIN	[master].[dbo].[spt_values] [B]
)
SELECT	[N],*
FROM	[Numbers1M]
CROSS APPLY (	SELECT	[D0]	= [N] / 100000 % 10
						,[D1]	= [N] /  10000 % 10
						,[D2]	= [N] /   1000 % 10
						,[D3]	= [N] /    100 % 10
						,[D4]	= [N] /     10 % 10
						,[D5]	= [N] /      1 % 10
			) [Digits]
WHERE	[N] BETWEEN 359282 AND 820401
AND		[Digits].[D0] <= [Digits].[D1]
AND		[Digits].[D1] <= [Digits].[D2]
AND		[Digits].[D2] <= [Digits].[D3]
AND		[Digits].[D3] <= [Digits].[D4]
AND		[Digits].[D4] <= [Digits].[D5]
-- This for part one
--AND		(	[Digits].[D0] = [Digits].[D1]
--		OR	[Digits].[D1] = [Digits].[D2]
--		OR	[Digits].[D2] = [Digits].[D3]
--		OR	[Digits].[D3] = [Digits].[D4]
--		OR	[Digits].[D4] = [Digits].[D5]
--		)
-- And for part two
AND		(	[Digits].[D0] = [Digits].[D1] AND NOT ([Digits].[D1] = [Digits].[D2])
		OR	[Digits].[D1] = [Digits].[D2] AND NOT ([Digits].[D0] = [Digits].[D1] OR [Digits].[D2] = [Digits].[D3])
		OR	[Digits].[D2] = [Digits].[D3] AND NOT ([Digits].[D1] = [Digits].[D2] OR [Digits].[D3] = [Digits].[D4])
		OR	[Digits].[D3] = [Digits].[D4] AND NOT ([Digits].[D2] = [Digits].[D3] OR [Digits].[D4] = [Digits].[D5])
		OR	[Digits].[D4] = [Digits].[D5] AND NOT ([Digits].[D3] = [Digits].[D4])
		)

