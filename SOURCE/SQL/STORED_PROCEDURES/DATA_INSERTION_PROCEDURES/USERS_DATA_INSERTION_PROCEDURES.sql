--=============================================================================================================================================================================================
--============= DATA_INSERTION_PROCEDURES.sql =================================================================================================================================================
--============= Cont�m SP's utilizadas na insers�o de dados em diversas tabelas (insers�es que envolvam mais que uma tabela em simult�neo), por parte do utilizador. ==========================
--=============================================================================================================================================================================================

USE [_MORPHEUS_ENGINE_] -- DB CONNECTION
GO

--#region USERS

--PROCEDURE PARA INSERIR UM NOVO UTILIZADOR
CREATE PROCEDURE SP_INSERT_USER
    @USER_FIRST_NAME VARCHAR(75),
    @USER_LAST_NAME VARCHAR(75),
    @USER_PASSWORD_HASH VARBINARY(255),
    @USER_EMAIL varchar(255),
    @USER_PHONENUMBER varchar(12),
    @USER_PROFILE_PICTURE_PATH varchar(1000),
    @USER_BIRTHDATE DATE,
    @USER_GENDER_ID INT,
    @USER_COUNTRY_ID INT,
    @USER_ADRESS VARCHAR(255),
    @USER_CITIZEN_CARD_NUMBER INT,
    @USER_SALARY FLOAT,
    @USER_BANK_ACCOUNT_NUMBER INT,
    @USER_ACADEMIC_LEVEL_ID INT,
    @USER_JOB_ID INT,
    @USER_LEVEL_ID INT,
	@USER_EMPLOYER_COMPANY_ID INT
AS
BEGIN
	INSERT INTO USERS (
    USER_FIRST_NAME,
    USER_LAST_NAME,
    USER_PASSWORD_HASH,
    USER_EMAIL,
    USER_PHONENUMBER,
    USER_PROFILE_PICTURE_PATH,
    USER_BIRTHDATE,
    USER_GENDER_ID,
    USER_COUNTRY_ID,
    USER_ADRESS,
    USER_CITIZEN_CARD_NUMBER,
    USER_SALARY,
    USER_BANK_ACCOUNT_NUMBER,
    USER_ACADEMIC_LEVEL_ID,
    USER_JOB_ID,
    USER_LEVEL_ID
	) VALUES
	(@USER_FIRST_NAME,
	@USER_LAST_NAME,
	@USER_PASSWORD_HASH,
	@USER_EMAIL,
	@USER_PHONENUMBER,
	@USER_PROFILE_PICTURE_PATH,
	@USER_BIRTHDATE,
	@USER_GENDER_ID,
	@USER_COUNTRY_ID,
	@USER_ADRESS,
	@USER_CITIZEN_CARD_NUMBER,
	@USER_SALARY,
	@USER_BANK_ACCOUNT_NUMBER,
	@USER_ACADEMIC_LEVEL_ID,
	@USER_JOB_ID,
	@USER_LEVEL_ID);

	DECLARE @USER_ID INT;
	SET @USER_ID = (SELECT MAX(USER_ID) FROM USERS (NOLOCK))

	INSERT INTO USER_REL_COMPANY (USER_COMPANY_ID, USER_ID)
	VALUES (@USER_EMPLOYER_COMPANY_ID, @USER_ID)
END

--#endregion USERS