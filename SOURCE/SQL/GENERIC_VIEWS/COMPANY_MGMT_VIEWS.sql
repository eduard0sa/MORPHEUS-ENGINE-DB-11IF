--==================================================================================================================================
--============= COMPANY_MGMY_VIEWS.sql =============================================================================================
--============= Aqui são criadas views para a obtenção de dados das empresas registadas. ===========================================
--==================================================================================================================================

USE [_MORPHEUS_ENGINE_] -- DB CONNECTION
GO

--ESTA VIEW CONCENTRA OS DADOS DE CADA UTILIZADOR;
CREATE VIEW VW_COMPANY_DATA AS (SELECT COMPANY_ID,
COMPANY_NAME,
COMPANIES.COMPANY_TYPE_ID,
COMPANY_TYPES.COMPANY_TYPE_NAME,
COMPANY_COUNTRY_ID,
COUNTRIES.COUNTRY_NAME,
COMPANY_CEO_ID,
USERS.USER_FIRST_NAME,
USERS.USER_LAST_NAME,
COMPANY_CAPITAL
FROM COMPANIES (NOLOCK)
INNER JOIN COUNTRIES ON COMPANY_COUNTRY_ID = COUNTRIES.COUNTRY_ID
INNER JOIN USERS ON USERS.USER_ID = COMPANY_CEO_ID
INNER JOIN COMPANY_TYPES ON COMPANY_TYPES.COMPANY_TYPE_ID = COMPANIES.COMPANY_TYPE_ID);
GO