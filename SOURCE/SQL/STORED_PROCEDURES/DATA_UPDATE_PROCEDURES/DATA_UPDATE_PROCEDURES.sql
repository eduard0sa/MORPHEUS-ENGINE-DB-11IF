--=============================================================================================================================================================================================
--============= DATA_INSERTION_PROCEDURES.sql =================================================================================================================================================
--============= Cont�m SP's utilizadas na insers�o de dados em diversas tabelas (insers�es que envolvam mais que uma tabela em simult�neo), por parte do utilizador. ==========================
--=============================================================================================================================================================================================

USE [_MORPHEUS_ENGINE_] -- DB CONNECTION
GO

--#region USERS
CREATE PROCEDURE SP_UPDATE_USER_PASSWORD
@USER_ID INT, @NEW_PASSWORD VARCHAR(100), @NEW_PASSWORD_CONFIRM VARCHAR(100)
AS
BEGIN
    IF(SELECT COUNT(USER_ID) FROM USERS WHERE USER_ID = @USER_ID) > 0
    BEGIN
        IF @NEW_PASSWORD = @NEW_PASSWORD_CONFIRM AND dbo.FN_VERIFY_PASSWORD(@NEW_PASSWORD) = 1
        BEGIN
            UPDATE USERS SET USER_PASSWORD_HASH = dbo.FN_ENCRYPT_PASSWORD(@NEW_PASSWORD, 'SHA2_512') WHERE USER_ID = @USER_ID
            PRINT 'A password foi alterada com sucesso.'
        END
        ELSE IF dbo.FN_VERIFY_PASSWORD(@NEW_PASSWORD) != 1
        BEGIN
            PRINT 'A nova password não é válida. A password deve ter entre 8 e 100 caracteres, conter pelo menos 2 letras maiúsculas, 2 letras minúsculas, 2 números e 2 caracteres especiais.'
        END
        ELSE IF @NEW_PASSWORD != @NEW_PASSWORD_CONFIRM
        BEGIN
            PRINT 'A nova password não coincide com a confirmação da nova password.'
        END
    END
    ELSE
    BEGIN
        PRINT 'O utilizador não existe.'
    END
END

GO

CREATE PROCEDURE SP_UPDATE_USER_PROFILE_PICTURE
@USER_ID INT, @PROFILE_PICTURE VARCHAR(1000)
AS
BEGIN
    IF(SELECT COUNT(USER_ID) FROM USERS WHERE USER_ID = @USER_ID) > 0
    BEGIN
        UPDATE USERS
            SET USER_PROFILE_PICTURE_PATH = @PROFILE_PICTURE
            WHERE USER_ID = @USER_ID
            
        PRINT 'A imagem de perfil foi alterada com sucesso.'
    END
    ELSE
    BEGIN
        PRINT 'O utilizador não existe.'
    END
END

GO

CREATE PROCEDURE SP_UPDATE_CITIZEN_CARD_NUMBER
@USER_ID INT, @CITIZEN_CARD_NUMBER VARCHAR(20)
AS
BEGIN
    IF((SELECT COUNT(*) FROM USERS WHERE @USER_ID = USER_ID) > 0)
    BEGIN
        UPDATE USERS
            SET USER_CITIZEN_CARD_NUMBER = @CITIZEN_CARD_NUMBER
            WHERE USER_ID = @USER_ID

        PRINT 'O número do cartão de cidadão foi alterado com sucesso.'
    END
    ELSE
    BEGIN
        PRINT 'O utilizador não existe.'
    END
END

--#endregion USERS

GO

--#region COMPANIES

CREATE PROCEDURE SP_UPDATE_COMPANY_CAPITAL
@COMPANY_ID INT, @NEW_COMPANY_CAPITAL FLOAT
AS
BEGIN
    IF((SELECT COUNT(*) FROM COMPANIES WHERE @COMPANY_ID = COMPANY_ID) > 0)
    BEGIN
        UPDATE COMPANIES
            SET COMPANY_CAPITAL = @NEW_COMPANY_CAPITAL
            WHERE COMPANY_ID = @COMPANY_ID

        PRINT 'O capital da empresa foi alterado com sucesso.'
    END
    ELSE
    BEGIN
        PRINT 'A empresa não existe.'
    END
END

GO

CREATE PROCEDURE SP_UPDATE_COMPANY_CEO
@COMPANY_ID INT, @NEW_COMPANY_CEO_ID INT
AS
BEGIN
    IF((SELECT COUNT(*) FROM COMPANIES WHERE @COMPANY_ID = COMPANY_ID) > 0)
    BEGIN
        IF((SELECT COUNT(*) FROM USERS WHERE @NEW_COMPANY_CEO_ID = USER_ID) > 0)
        BEGIN
            UPDATE COMPANIES
                SET COMPANY_CEO_ID = @NEW_COMPANY_CEO_ID
                WHERE COMPANY_ID = @COMPANY_ID

            PRINT 'O CEO da empresa foi alterado com sucesso.'
        END
        ELSE
        BEGIN
            PRINT 'O novo CEO não existe.'
        END
    END
    ELSE
    BEGIN
        PRINT 'A empresa não existe.'
    END
END

GO

CREATE PROCEDURE SP_UPDATE_COMPANY_NAME
@COMPANY_ID INT, @NEW_COMPANY_NAME VARCHAR(100)
AS
BEGIN
    IF((SELECT COUNT(*) FROM COMPANIES WHERE @COMPANY_ID = COMPANY_ID) > 0)
    BEGIN
        UPDATE COMPANIES
            SET COMPANY_NAME = @NEW_COMPANY_NAME
            WHERE COMPANY_ID = @COMPANY_ID

        PRINT 'O nome da empresa foi alterado com sucesso.'
    END
    ELSE
    BEGIN
        PRINT 'A empresa não existe.'
    END
END

--#endregion COMPANIES

GO

--#region POWER_PLANTS

CREATE PROCEDURE SP_UPDATE_POWER_PLANT_STATUS
@POWER_PLANT_ID INT, @NEW_POWER_PLANT_STATUS_ID INT
AS
BEGIN
    IF((SELECT COUNT(*) FROM POWER_PLANTS WHERE @POWER_PLANT_ID = POWER_PLANT_ID) > 0)
    BEGIN
        IF((SELECT COUNT(*) FROM MACHINE_STATUS WHERE @NEW_POWER_PLANT_STATUS_ID = MACHINE_STATUS_ID) > 0)
        BEGIN
            UPDATE POWER_PLANTS
                SET POWER_PLANT_STATUS_ID = @NEW_POWER_PLANT_STATUS_ID
                WHERE POWER_PLANT_ID = @POWER_PLANT_ID

            PRINT 'O estado da central foi alterado com sucesso.'
        END
        ELSE
        BEGIN
            PRINT 'O novo estado da central não existe.'
        END
    END
    ELSE
    BEGIN
        PRINT 'A central não existe.'
    END
END

--endregion POWER_PLANTS