--==================================================================================================================
--============= USER_QUERIES.sql ===================================================================================
--============= Contem queries para listagem e analise estatistica de dados inerentes ás empresas ==================
--==================================================================================================================

USE [_MORPHEUS_ENGINE_] -- DB CONNECTION
GO

CREATE PROCEDURE SP_INSERT_LIFE_SUPPORT_SYSTEM_LINK_CITY
    @LSS_ID INT,
    @CITY_ID INT
AS
BEGIN
    IF((SELECT COUNT(*) FROM CITIES WHERE CITY_ID = @CITY_ID) > 0)
    BEGIN
        INSERT INTO CITY_REL_LIFE_SUPPORT_SYSTEMS (CITY_ID, CITY_LIFE_SUPPORT_SYSTEM_ID)
        VALUES (
            @CITY_ID, -- ID da cidade onde o sistema de suporte de vida está localizado
            @LSS_ID -- ID do sistema de suporte de vida
        );
    END
    ELSE
    BEGIN
        PRINT 'A cidade especificada n��o existe.';
    END 
END

GO

CREATE PROCEDURE SP_INSERT_LIFE_SUPPORT_SYSTEM
    @LSS_NAME VARCHAR(50),
    @LSS_TYPE_ID INT,
    @LSS_COMPANY_ID INT,
    @LSS_LOCATION VARCHAR(100),
    @LSS_STATUS_ID INT,
    @LSS_MAX_OUTPUT_CAPACITY FLOAT,
    @LSS_INSTALLATION_DATE DATE,
    @LSS__NEXT_MAINTENANCE_DATE DATE,
    @LSS_CITY_ID INT

AS
BEGIN
    INSERT INTO LIFE_SUPPORT_SYSTEMS (
        SYSTEM_NAME,
        SYSTEM_TYPE_ID,
        SYSTEM_COMPANY_ID,
        SYSTEM_LOCATION,
        SYSTEM_STATUS_ID,
        SYSTEM_MAX_OUTPUT_CAPACITY,
        SYSTEM_INSTALLATION_DATE,
        SYSTEM_NEXT_MAINTENANCE_DATE
    ) VALUES (
        @LSS_NAME,
        @LSS_TYPE_ID,
        @LSS_COMPANY_ID,
        @LSS_LOCATION,
        @LSS_STATUS_ID,
        @LSS_MAX_OUTPUT_CAPACITY,
        @LSS_INSTALLATION_DATE,
        @LSS__NEXT_MAINTENANCE_DATE
    );

    DECLARE @LAST_LSS_ID INT = SCOPE_IDENTITY();

    EXEC SP_INSERT_LIFE_SUPPORT_SYSTEM_LINK_CITY
    @LSS_ID = @LAST_LSS_ID,
    @CITY_ID = @LSS_CITY_ID;
END