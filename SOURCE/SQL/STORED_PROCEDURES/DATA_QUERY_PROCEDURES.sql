--=============================================================================================================================================================================================
--============= DATA_QUERY_PROCEDURES.sql =====================================================================================================================================================
--============= Cont�m SP's utilizadas na insers�o de dados em diversas tabelas (insers�es que envolvam mais que uma tabela em simult�neo), por parte do utilizador. =======================
--=============================================================================================================================================================================================

USE [_MORPHEUS_ENGINE_] -- DB CONNECTION
GO

CREATE PROCEDURE SP_LIST_USERS_BY_PERMISSION_LEVEL
@USER_LEVEL_NAME VARCHAR(50)
AS
BEGIN
SELECT USER_ID, USER_FIRST_NAME, USER_LAST_NAME, USER_EMAIL, USER_PHONENUMBER, USER_PROFILE_PICTURE_PATH, USER_BIRTHDATE, USER_GENDER_NAME, COUNTRY_NAME, USER_ADRESS, USER_JOB_NAME, USER_ACADEMIC_LEVEL_NAME, USER_LEVEL_NAME
FROM VW_USER_CARACTERISTICS (NOLOCK) WHERE USER_LEVEL_NAME = @USER_LEVEL_NAME
END