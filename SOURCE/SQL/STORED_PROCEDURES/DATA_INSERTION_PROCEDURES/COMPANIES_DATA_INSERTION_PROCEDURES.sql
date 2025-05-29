--=============================================================================================================================================================================================
--============= DATA_INSERTION_PROCEDURES.sql =================================================================================================================================================
--============= Cont�m SP's utilizadas na insers�o de dados em diversas tabelas (insers�es que envolvam mais que uma tabela em simult�neo), por parte do utilizador. ==========================
--=============================================================================================================================================================================================

USE [_MORPHEUS_ENGINE_] -- DB CONNECTION
GO

--#region COMPANIES

--PROCEDURE PARA INSERIR UMA NOVA EMPRESA
CREATE PROCEDURE SP_INSERT_COMPANY
	@COMPANY_NAME VARCHAR(100),
	@COMPANY_TYPE_ID INT,
	@COMPANY_COUNTRY_ID INT,
	@COMPANY_CEO_ID INT,
	@COMPANY_CAPITAL FLOAT

AS
BEGIN
	INSERT INTO COMPANIES (
		COMPANY_NAME,
		COMPANY_TYPE_ID,
		COMPANY_COUNTRY_ID,
		COMPANY_CEO_ID,
		COMPANY_CAPITAL
	) VALUES (
		@COMPANY_NAME,
		@COMPANY_TYPE_ID,
		@COMPANY_COUNTRY_ID,
		@COMPANY_CEO_ID,
		@COMPANY_CAPITAL
	);
END

--#endregion COMPANIES