-- 1. �������� �� 'Calculator'

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

-- 2. ������� Expressions
-- ��������� ���� �� ���� �����: ip ������ � ���� �������� ���������
-- ���� ip ������ ��� �������� �������� � ������ ���-�������� ������������ � int
-- �������� ���������� ������
-- ���� ��������� �������������
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

-- 3. �������� ��������� ���������� �������

CREATE PROCEDURE [dbo].[sp_AddExpression] 
	@Adress nvarchar(15) = '127.0.0.1',
	@Expression nvarchar(MAX) = N'�����������'
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO dbo.Expressions(Adress, Expression) VALUES (dbo.ip_hash(@Adress), @Expression)
END
GO

-- 4. �������� ��������� ���������� �������

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
			DT BETWEEN @DT-1 AND @DT -- �������� 1 ����
			AND Adress = dbo.ip_hash(@Adress)
        ORDER BY
            DT DESC
END
GO

-- 5. ��������� ���-������� ������ Ip ������ � int

CREATE FUNCTION [dbo].[ip_hash] (@Adress nvarchar(15))

RETURNS bigint
AS
BEGIN
	DECLARE  @split table(
					[val] bigint NOT NULL		-- ������� ��������������� � ����� ������
				   ,[pow] tinyint NOT NULL )	-- ������� ������� �����

	DECLARE  @result bigint		-- �������������� ���
			,@str nvarchar(3)	-- ��������� ����� ip ������
			,@level tinyint = 3	-- ����� �������� ����� ip ������
			,@pos tinyint		-- ������� ������� ������� ������
			,@prv tinyint = 1	-- ���������� ������� ������� ������

    SELECT @pos = CHARINDEX('.', @Adress)
	IF @pos = 0
		RETURN 2130706433 -- ������������� ������ 127.0.0.1 (������ �� ������)

	WHILE @pos > 0
		BEGIN  -- ��������� ��������� ����� � ���������� � �������
			SELECT @str = SUBSTRING(@Adress, @prv, @pos - @prv)
			INSERT INTO @split SELECT CONVERT(bigint, @str), @level*8
			SELECT @level = @level - 1, @prv = @pos + 1
			SELECT @pos = CHARINDEX('.', @Adress, @pos + 1)
		END
	-- ���������� ��������� ����
	INSERT INTO @split SELECT CONVERT(bigint, SUBSTRING(@Adress, @prv, 3)), 0
	-- ������� ���
	SELECT @result = SUM(val*POWER(2, pow)) from @split

	RETURN @result
END
GO

