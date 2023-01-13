USE [AOC];
SET NOCOUNT ON;
GO

DROP PROCEDURE IF EXISTS [#up_Decode];

DROP TABLE IF EXISTS [#Binary];
GO

CREATE TABLE [#Binary]
(
	[decimal]	int
	,[hex]		char(1)
	,[binary]	char(4)
);

INSERT INTO [#Binary] ([decimal], [hex], [binary])
VALUES	 ( 0, '0', '0000')
		,( 1, '1', '0001')
		,( 2, '2', '0010')
		,( 3, '3', '0011')
		,( 4, '4', '0100')
		,( 5, '5', '0101')
		,( 6, '6', '0110')
		,( 7, '7', '0111')
		,( 8, '8', '1000')
		,( 9, '9', '1001')
		,(10, 'A', '1010')
		,(11, 'B', '1011')
		,(12, 'C', '1100')
		,(13, 'D', '1101')
		,(14, 'E', '1110')
		,(15, 'F', '1111');
GO

CREATE OR ALTER PROCEDURE [#up_Decode]
	@message		varchar(MAX)
	,@remainder		varchar(MAX)	OUTPUT
	,@versionSum	int				OUTPUT
	,@packetResult	bigint			OUTPUT
	,@level			int = 0
	,@inBinary		bit = 0
	,@recurse		bit = 1
	,@debug			bit = 0
AS
BEGIN
	DECLARE	@binary		varchar(MAX)	= ''
			,@prefix	varchar(100)	= REPLICATE('  ', @level)
			,@i			int				= 1
			,@j			int
			,@nextLevel	int				= @level + 1;

	DECLARE	@localResults TABLE
	(
		[id]		int		IDENTITY(1,1)
		,[result]	bigint
	);

	SELECT	@versionSum = 0;

	IF @inBinary = 0
	BEGIN
		IF @debug = 1
			PRINT 'Hex: ' + @message;

		WHILE @i <= LEN(@message)
		BEGIN
			SELECT	@binary += [binary]
			FROM	[#Binary]
			WHERE	[hex] = SUBSTRING(@message, @i, 1);

			SELECT	@i += 1;
		END
	END
	ELSE
	BEGIN
		SELECT	@binary = @message;
	END

	IF @debug = 1
		PRINT @prefix + 'Binary: ' + @binary;

	DECLARE	@version			varchar(3)
			,@type				varchar(3)
			,@subPacket			varchar(MAX)
			,@length			varchar(20)
			,@literalPart		varchar(10)
			,@packetTotal		int
			,@literalValue		bigint
			,@localResult		bigint
			,@operatorLength	int
			,@versionValue		int
			,@localVersion		int
			,@typeValue			int
			,@lengthValue		int;

	WHILE LEN(REPLACE(@binary, '0', '')) > 0
	BEGIN
		SELECT	@version	= SUBSTRING(@binary, 1, 3)
				,@type		= SUBSTRING(@binary, 4, 3);

		SELECT	@typeValue	= [decimal]
				,@i			= 7
		FROM	#Binary
		WHERE	[binary] = '0' + @type;

		SELECT	@versionValue	= [decimal]
		FROM	#Binary
		WHERE	[binary] = '0' + @version;

		SELECT	@versionSum += @versionValue;

		IF @debug = 1
			PRINT @prefix + 'Version: ' + CAST(@versionValue AS varchar(10)) + '  Type: ' + CAST(@typeValue AS varchar(10));
	
		IF @typeValue = 4
		BEGIN
			-- Literal value
			SELECT	@literalValue = 0;

			WHILE 1=1
			BEGIN
				SELECT	@literalPart = SUBSTRING(@binary, @i, 5);

				IF @debug = 1
					PRINT @prefix + 'Literal Part: ' + @literalPart;

				SELECT	@literalValue *= 16;

				SELECT	@literalValue += [decimal]
				FROM	[#Binary]
				WHERE	[binary] = RIGHT(@literalPart, 4);

				SELECT	@i += 5;

				IF LEFT(@literalPart, 1) = '0'
					BREAK;
			END

			IF @debug = 1
				PRINT @prefix + 'Literal: ' + CAST(@literalValue AS varchar(20));

			SELECT	@remainder		= IIF(@i > LEN(@binary), '', SUBSTRING(@binary, @i, LEN(@binary) - @i + 1))
					,@packetResult	= @literalValue;

			BREAK;
		END
		ELSE
		BEGIN
			IF @debug = 1
				PRINT @prefix + 'Operator Packet'

			IF SUBSTRING(@binary, @i, 1) = '0'
			BEGIN
				SELECT	@length			= '0' + SUBSTRING(@binary, @i+1, 15)
						,@lengthValue	= 0
						,@j				= 1;

				IF @debug = 1
					PRINT @prefix + 'Length = ' + @length;

				WHILE @j < LEN(@length)
				BEGIN
					SELECT	@lengthValue *= 16;

					SELECT	@lengthValue += [decimal]
					FROM	[#Binary]
					WHERE	[binary]	= SUBSTRING(@length, @j, 4);

					SELECT	@j += 4;
				END

				SELECT	@subPacket	= SUBSTRING(@binary, @i+16, @lengthValue);

				IF @debug = 1
					PRINT @prefix + 'Sub-packet (fixed, len = ' + CAST(@lengthValue AS varchar(20)) + '): ' + @subPacket;

				WHILE LEN(@subPacket) > 0
				BEGIN
					EXEC [#up_Decode] @message=@subPacket, @remainder=@subPacket OUTPUT,
								@versionSum=@localVersion OUTPUT, @packetResult=@localResult OUTPUT, @level=@nextLevel, @inBinary=1;

					INSERT INTO @localResults VALUES(@localResult);

					SELECT	@versionSum	+= @localVersion;
				END

				SELECT	@remainder	= RIGHT(@binary, LEN(@binary) - @i - 15 - @lengthValue);
			END
			ELSE
			BEGIN
				SELECT	@length			= '0' + SUBSTRING(@binary, @i + 1, 11)
						,@packetTotal	= 0
						,@j				= 1;

				IF @debug = 1
					PRINT @prefix + 'Length = ' + @length;

				WHILE @j < LEN(@length)
				BEGIN
					SELECT	@packetTotal *= 16;

					SELECT	@packetTotal += [decimal]
					FROM	[#Binary]
					WHERE	[binary]	= SUBSTRING(@length, @j, 4);

					SELECT	@j += 4;
				END

				IF @debug = 1
					PRINT @prefix + 'Sub-packet count: ' + CAST(@packetTotal AS varchar(20));

				SELECT	@subPacket = RIGHT(@binary, LEN(@binary) - @i - 11);

				WHILE @packetTotal > 0
				BEGIN
					EXEC [#up_Decode] @message=@subPacket, @remainder=@subPacket OUTPUT,
								@versionSum=@localVersion OUTPUT, @packetResult=@localResult OUTPUT, @level=@nextLevel, @inBinary=1, @recurse=0;

					INSERT INTO @localResults VALUES(@localResult);

					SELECT	@versionSum		+= @localVersion
							,@packetTotal	-= 1
				END

				SELECT	@remainder = @subPacket;
			END

			IF @debug = 1
				PRINT @prefix + 'Calculating...';

			IF @typeValue IN (0,2,3)
			BEGIN
				SELECT	@packetResult	= CASE @typeValue
											WHEN 0	THEN SUM([result])
											WHEN 2	THEN MIN([result])
											WHEN 3	THEN MAX([result])
											ELSE 1/0
											END
				FROM	@localResults;
			END
			ELSE IF @typeValue IN (1)
			BEGIN
				SELECT	@packetResult = 1;

				SELECT	@packetResult *= [result]
				FROM	@localResults;
			END
			ELSE
			BEGIN
				DECLARE	@v1		bigint
						,@v2	bigint;

				SELECT	@v1 = [result] FROM @localResults WHERE [id] = 1;
				SELECT	@v2 = [result] FROM @localResults WHERE [id] = 2;

				SELECT	@packetResult	= CASE @typeValue
							WHEN 5	THEN IIF(@v1 > @v2, 1, 0)
							WHEN 6	THEN IIF(@v1 < @v2, 1, 0)
							WHEN 7	THEN IIF(@v1 = @v2, 1, 0)
							ELSE 1/0
							END;
			END

			-- Since we've calculated a result, we break and throw it up to the caller.
			-- It will then be up to the caller to loop round etc. and process more packets.
			BREAK;
		END

		IF @recurse = 1
			SELECT	@binary = @remainder
		ELSE
			BREAK
	END

	IF @debug = 1
	BEGIN
		PRINT @prefix + 'Remainder: ' + @remainder;
		PRINT @prefix + 'Result   : ' + CAST(@packetResult AS varchar(20));
	END

	IF @level = 0
	BEGIN
		PRINT 'End: Version Sum = ' + CAST(@versionSum AS varchar(10)) + '  Final Result: ' + CAST(@packetResult AS varchar(20));
	END
END
GO

DECLARE @Input varchar(MAX) = '620D79802F60098803B10E20C3C1007A2EC4C84136F0600BCB8AD0066E200CC7D89D0C4401F87104E094FEA82B0726613C6B692400E14A305802D112239802125FB69FF0015095B9D4ADCEE5B6782005301762200628012E006B80162007B01060A0051801E200528014002A118016802003801E2006100460400C1A001AB3DED1A00063D0E25771189394253A6B2671908020394359B6799529E69600A6A6EB5C2D4C4D764F7F8263805531AA5FE8D3AE33BEC6AB148968D7BFEF2FBD204CA3980250A3C01591EF94E5FF6A2698027A0094599AA471F299EA4FBC9E47277149C35C88E4E3B30043B315B675B6B9FBCCEC0017991D690A5A412E011CA8BC08979FD665298B6445402F97089792D48CF589E00A56FFFDA3EF12CBD24FA200C9002190AE3AC293007A0A41784A600C42485F0E6089805D0CE517E3C493DC900180213D1C5F1988D6802D346F33C840A0804CB9FE1CE006E6000844528570A40010E86B09A32200107321A20164F66BAB5244929AD0FCBC65AF3B4893C9D7C46401A64BA4E00437232D6774D6DEA51CE4DA88041DF0042467DCD28B133BE73C733D8CD703EE005CADF7D15200F32C0129EC4E7EB4605D28A52F2C762BEA010C8B94239AAF3C5523CB271802F3CB12EAC0002FC6B8F2600ACBD15780337939531EAD32B5272A63D5A657880353B005A73744F97D3F4AE277A7DA8803C4989DDBA802459D82BCF7E5CC5ED6242013427A167FC00D500010F8F119A1A8803F0C62DC7D200CAA7E1BC40C7401794C766BB3C58A00845691ADEF875894400C0CFA7CD86CF8F98027600ACA12495BF6FFEF20691ADE96692013E27A3DE197802E00085C6E8F30600010882B18A25880352D6D5712AE97E194E4F71D279803000084C688A71F440188FB0FA2A8803D0AE31C1D200DE25F3AAC7F1BA35802B3BE6D9DF369802F1CB401393F2249F918800829A1B40088A54F25330B134950E0';

DECLARE @InputT1_1 varchar(MAX) = '38006F45291200';
DECLARE @InputT1_2 varchar(MAX) = '8A004A801A8002F478';
DECLARE @InputT1_3 varchar(MAX) = '620080001611562C8802118E34';
DECLARE @InputT1_4 varchar(MAX) = 'C0015000016115A2E0802F182340';
DECLARE @InputT1_5 varchar(MAX) = 'A0016C880162017C3686B18A3D4780';

DECLARE @InputT2_1 varchar(MAX) = 'C200B40A82';
DECLARE @InputT2_2 varchar(MAX) = '04005AC33890';
DECLARE @InputT2_3 varchar(MAX) = '880086C3E88112';
DECLARE @InputT2_4 varchar(MAX) = 'CE00C43D881120';
DECLARE @InputT2_5 varchar(MAX) = 'D8005AC2A8F0';
DECLARE @InputT2_6 varchar(MAX) = 'F600BC2D8F';
DECLARE @InputT2_7 varchar(MAX) = '9C005AC2F8F0';
DECLARE @InputT2_8 varchar(MAX) = '9C0141080250320F1802104A08';

DECLARE	@remainder	varchar(MAX)
		,@sum		int
		,@result	bigint;

-- Part 1 various tests
--EXEC [#up_Decode] @message=@InputT1_1, @remainder=@remainder OUTPUT, @versionSum=@sum OUTPUT, @packetResult=@result OUTPUT;
--EXEC [#up_Decode] @message=@InputT1_2, @remainder=@remainder OUTPUT, @versionSum=@sum OUTPUT, @packetResult=@result OUTPUT;
--EXEC [#up_Decode] @message=@InputT1_3, @remainder=@remainder OUTPUT, @versionSum=@sum OUTPUT, @packetResult=@result OUTPUT;
--EXEC [#up_Decode] @message=@InputT1_4, @remainder=@remainder OUTPUT, @versionSum=@sum OUTPUT, @packetResult=@result OUTPUT;
--EXEC [#up_Decode] @message=@InputT1_5, @remainder=@remainder OUTPUT, @versionSum=@sum OUTPUT, @packetResult=@result OUTPUT;

-- Part 2 various tests
--EXEC [#up_Decode] @message=@InputT2_1, @remainder=@remainder OUTPUT, @packetResult=@result OUTPUT, @versionSum=@sum OUTPUT;
--EXEC [#up_Decode] @message=@InputT2_2, @remainder=@remainder OUTPUT, @packetResult=@result OUTPUT, @versionSum=@sum OUTPUT;
--EXEC [#up_Decode] @message=@InputT2_3, @remainder=@remainder OUTPUT, @packetResult=@result OUTPUT, @versionSum=@sum OUTPUT;
--EXEC [#up_Decode] @message=@InputT2_4, @remainder=@remainder OUTPUT, @packetResult=@result OUTPUT, @versionSum=@sum OUTPUT;
--EXEC [#up_Decode] @message=@InputT2_5, @remainder=@remainder OUTPUT, @packetResult=@result OUTPUT, @versionSum=@sum OUTPUT;
--EXEC [#up_Decode] @message=@InputT2_6, @remainder=@remainder OUTPUT, @packetResult=@result OUTPUT, @versionSum=@sum OUTPUT;
--EXEC [#up_Decode] @message=@InputT2_7, @remainder=@remainder OUTPUT, @packetResult=@result OUTPUT, @versionSum=@sum OUTPUT;
--EXEC [#up_Decode] @message=@InputT2_8, @remainder=@remainder OUTPUT, @packetResult=@result OUTPUT, @versionSum=@sum OUTPUT;

-- The actual problem!
EXEC [#up_Decode] @message=@Input, @remainder=@remainder OUTPUT, @packetResult=@result OUTPUT, @versionSum=@sum OUTPUT;

SELECT	[Part 1] = @sum;

SELECT	[Part 2] = @result;
