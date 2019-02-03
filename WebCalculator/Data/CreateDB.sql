-- 1. Создайте БД 'Calculator'

USE [master]
GO

CREATE DATABASE [Calculator]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Calculator', FILENAME = N'D:\DB\Calculator.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Calculator_log', FILENAME = N'D:\DB\Calculator_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO

ALTER DATABASE [Calculator] SET COMPATIBILITY_LEVEL = 110
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Calculator].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

-- 2. Таблица Expressions
-- Первичный ключ из двух полей: ip адреса и даты создания выражения
-- поле ip адреса для удобства храниеия и поиска хэщ-функцией конвертируем в int
-- Применил кластерный индекс
-- дата заносится автоматически
USE [Calculator]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Expressions](
	[Adress] [bigint] NOT NULL,
	[DT] [datetime] NOT NULL,
	[Expression] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_Expressions] PRIMARY KEY CLUSTERED 
(
	[Adress] ASC,
	[DT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Expressions] ADD  CONSTRAINT [DF_Expressions_DT]  DEFAULT (getdate()) FOR [DT]
GO

-- 3. Хранимая процедура длбавления записей

CREATE PROCEDURE [dbo].[sp_AddExpression] 
	@Adress nvarchar(15) = '127.0.0.1',
	@Expression nvarchar(MAX) = N'абракадабра'
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO dbo.Expressions(Adress, Expression) VALUES (dbo.ip_hash(@Adress), @Expression)
END
GO

-- 4. Хранимая процедура извлечения записей

CREATE PROCEDURE [dbo].[sp_GetExpressions]
	@Adress nvarchar(15) = '127.0.0.1'
AS
BEGIN
	DECLARE @DT datetime
	SET @DT = GETDATE()

	SET NOCOUNT ON;
	SELECT
		-- Convert(nvarchar, DT, 104) + '  ' + 
		-- FORMAT( @DT, 'dd.MM.yyyy', 'ru-RU' ) + '  ' +
		Expression
	FROM [dbo].[Expressions] 
		WHERE 
			DT BETWEEN @DT-1 AND @DT -- интервал 1 день
			AND Adress = dbo.ip_hash(@Adress)
        ORDER BY
            DT DESC
END
GO

-- 5. Скалярная Хэш-функция свёртки Ip адреса в int

CREATE FUNCTION [dbo].[ip_hash] (@Adress nvarchar(15))

RETURNS bigint
AS
BEGIN
	DECLARE  @split table(
					[val] bigint NOT NULL		-- столбец преобразованных в число байтов
				   ,[pow] tinyint NOT NULL )	-- степень позиции байта

	DECLARE  @result bigint		-- результирующий хэш
			,@str nvarchar(3)	-- подстрока байта ip адреса
			,@level tinyint = 3	-- номер текущего байта ip адреса
			,@pos tinyint		-- текущая позиция шаблона поиска
			,@prv tinyint = 1	-- предыдущая позиция шаблона поиска

    SELECT @pos = CHARINDEX('.', @Adress)
	IF @pos = 0
		RETURN 2130706433 -- соответствует адресу 127.0.0.1 (защита от мусора)

	WHILE @pos > 0
		BEGIN  -- поочерёдно вычленяем байты и складываем в таблицу
			SELECT @str = SUBSTRING(@Adress, @prv, @pos - @prv)
			INSERT INTO @split SELECT CONVERT(bigint, @str), @level*8
			SELECT @level = @level - 1, @prv = @pos + 1
			SELECT @pos = CHARINDEX('.', @Adress, @pos + 1)
		END
	-- дописываем последний байт
	INSERT INTO @split SELECT CONVERT(bigint, SUBSTRING(@Adress, @prv, 3)), 0
	-- считаем хэш
	SELECT @result = SUM(val*POWER(2, pow)) from @split

	RETURN @result
END
GO

