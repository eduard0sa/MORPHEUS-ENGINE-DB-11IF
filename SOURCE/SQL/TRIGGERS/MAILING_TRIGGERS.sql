--==================================================================================================================
--============= USER_QUERIES.sql ===================================================================================
--============= Contem queries para listagem e analise estatistica de dados inerentes ás empresas ==================
--==================================================================================================================

USE [_MORPHEUS_ENGINE_] -- DB CONNECTION
GO

--TRIGGER PARA ENVIO DE EMAIL AUTOMÁTICO DE BOAS VINDAS, QUANDO UM NOVO UTILIZADOR É CRIADO
CREATE TRIGGER TG_CREATE_USER
ON USERS
AFTER INSERT
AS
BEGIN
    DECLARE @FIRST_NAME VARCHAR(50)
    DECLARE @LAST_NAME VARCHAR(50)
    DECLARE @EMAIL VARCHAR(100)
    DECLARE @PHONENUMBER VARCHAR(20)
    DECLARE @PROFILE_PICTURE_PATH VARCHAR(255)
    DECLARE @COUNTRY_ID INT
    DECLARE @BODY NVARCHAR(MAX)

    --######################################################################
    DECLARE _cursor CURSOR FOR (
        SELECT USER_FIRST_NAME,
        USER_LAST_NAME,
        USER_EMAIL,
        USER_PHONENUMBER,
        USER_PROFILE_PICTURE_PATH,
        USER_COUNTRY_ID
        FROM inserted (NOLOCK)
    )

    OPEN _cursor
    FETCH NEXT FROM _cursor INTO @FIRST_NAME, @LAST_NAME, @EMAIL, @PHONENUMBER, @PROFILE_PICTURE_PATH, @COUNTRY_ID
    --######################################################################

    SET @BODY = '<html>
    <body>
    <h1>Welcome to MORPHEUS_ENGINE!</h1>
    <p>Dear '
    SET @BODY = @BODY + @FIRST_NAME + ' ' + @LAST_NAME
    SET @BODY = @BODY + ',</p>
    <p>Thank you for registering with us. We are excited to have you on board!</p>
    <p>Best regards,</p>
    <p>The MORPHEUS_ENGINE Team</p>
    </body></html>'
    
    EXEC msdb.dbo.sp_send_dbmail
        @profile_name = 'MORPHEUS_ENGINE_NOREPLY_BOT',
        @recipients = @EMAIL,
        @copy_recipients = '',
        @blind_copy_recipients = '',
        @body_format = 'HTML',
        @body = @BODY,
        @subject = 'Welcome to MORPHEUS_ENGINE!',
        @from_address = 'eduardoxaviersa@gmail.com',
        @reply_to = '',
        @importance = 'Normal';

    CLOSE _cursor
    DEALLOCATE _cursor
END

GO

--TRIGGER PARA ENVIO DE EMAIL AUTOMÁTICO QUANDO A PASSWORD DE UM UTILIZADOR É ALTERADA (PARA CONFIRMAÇÃO DE ALTERAÇÃO)
CREATE TRIGGER TG_USER_PASSWORD_CHANGE
ON USERS
AFTER UPDATE
AS
BEGIN
    DECLARE @PASSWORD_CHANGED_RECORDS INT = (
        SELECT COUNT(*)
        FROM inserted (NOLOCK)
        INNER JOIN deleted (NOLOCK) ON inserted.USER_ID = deleted.USER_ID
        WHERE inserted.USER_PASSWORD_HASH != deleted.USER_PASSWORD_HASH
    );

    IF(@PASSWORD_CHANGED_RECORDS > 0)
    BEGIN
        DECLARE @USER_ID INT
        DECLARE @USER_FIRST_NAME VARCHAR(75)
        DECLARE @USER_LAST_NAME VARCHAR(75)
        DECLARE @EMAIL VARCHAR(100)
        DECLARE @BODY VARCHAR(MAX)
        DECLARE @SUBJECT VARCHAR(255)
        DECLARE @TMP INT = (SELECT COUNT(*) FROM inserted (NOLOCK));
        PRINT @TMP;
        ---------------------------------------------------------------------------------
        DECLARE _cursor CURSOR FOR (
            SELECT USER_ID,
            USER_FIRST_NAME,
            USER_LAST_NAME,
            USER_EMAIL
            FROM inserted (NOLOCK)
        )

        OPEN _cursor
        FETCH NEXT FROM _cursor INTO @USER_ID, @USER_FIRST_NAME, @USER_LAST_NAME, @EMAIL
        ---------------------------------------------------------------------------------

        DECLARE @I INT = 1;
        WHILE @I <= @TMP
        BEGIN
            SET @SUBJECT = 'Morpheus Engine Password Changed'
            SET @BODY = '<html>
            <body>
            <h1>Morpheus Engine Password Changed!</h1>
            <p>Greetings, dear ' + @USER_FIRST_NAME + ' ' + @USER_LAST_NAME + '.</p>
            <p>Your password has been changed, at '
            + CAST(DAY(GETDATE()) AS VARCHAR) + '/' + CAST(MONTH(GETDATE()) AS VARCHAR) + '/' + CAST(YEAR(GETDATE()) AS VARCHAR) + ', '
            + CAST(DATEPART(HOUR, GETDATE()) AS VARCHAR) + ':' + CAST(DATEPART(MINUTE, GETDATE()) AS VARCHAR) + ':' + CAST(DATEPART(SECOND, GETDATE()) AS VARCHAR) + ':' + CAST(DATEPART(MILLISECOND, GETDATE()) AS VARCHAR)
            + ' (Portuguese DateTime Format).</p>
            <p>If you did not request this change, please contact support immediately.</p>
            <p>Best regards,</p>
            <p>The MORPHEUS_ENGINE Team.</p>
            </body></html>'

            EXEC msdb.dbo.sp_send_dbmail
                @profile_name = 'MORPHEUS_ENGINE_NOREPLY_BOT',
                @recipients = @EMAIL,
                @copy_recipients = '',
                @blind_copy_recipients = '',
                @body_format = 'HTML',
                @body = @BODY,
                @subject = @SUBJECT,
                @from_address = 'eduardoxaviersa@gmail.com',
                @reply_to = '',
                @importance = 'Normal';

            FETCH NEXT FROM _cursor INTO @USER_ID, @USER_FIRST_NAME, @USER_LAST_NAME, @EMAIL
            
            SET @I = @I + 1;
        END
        
        CLOSE _cursor
        DEALLOCATE _cursor
    END
END

GO

--TRIGGER PARA ENVIO DE EMAIL AUTOMÁTICO QUANDO É REGISTADA UMA MANUTENÇÃO DE UMA CENTRAL ELÉTRICA
CREATE TRIGGER TG_POWER_PLANT_MAINTENANCE_REPORT
ON POWER_PLANT_MAINTENANCE_LOGS
AFTER INSERT
AS
BEGIN
    -----------------------------------------------------------------------
    DECLARE @LOG_ID INT
    DECLARE @OPERATION_ID INT
    DECLARE @POWER_PLANT_ID INT
    DECLARE @MAINTENANCE_DESCRIPTION VARCHAR(MAX)
    DECLARE @MAINTENANCE_DATE DATE
    DECLARE @MAINTENANCE_TECHNITIAN INT
    DECLARE @MAINTENANCE_RESULTS_INFO VARBINARY(255)
    -----------------------------------------------------------------------
    DECLARE @POWER_PLANT_NAME VARCHAR(50)
    -----------------------------------------------------------------------
    DECLARE @SUBJECT VARCHAR(255)
    DECLARE @BODY VARCHAR(MAX)
    DECLARE @EMAIL VARCHAR(100)
    
    --######################################################################
    DECLARE _cursor CURSOR FOR (
        SELECT LOG_ID,
        OPERATION_ID,
        POWER_PLANT_ID,
        MAINTENANCE_DESCRIPTION,
        MAINTENANCE_DATE,
        MAINTENANCE_TECHNITIAN_ID,
        MAINTENANCE_RESULTS_INFO
        FROM inserted (NOLOCK)
    )

    OPEN _cursor
    FETCH NEXT FROM _cursor INTO @LOG_ID, @OPERATION_ID, @POWER_PLANT_ID, @MAINTENANCE_DESCRIPTION, @MAINTENANCE_DATE, @MAINTENANCE_TECHNITIAN, @MAINTENANCE_RESULTS_INFO
    --######################################################################

    SET @POWER_PLANT_NAME = (
        SELECT POWER_PLANT_NAME
        FROM POWER_PLANTS (NOLOCK)
        WHERE POWER_PLANT_ID = @POWER_PLANT_ID
    )
    SET @SUBJECT = 'Maintenace Report for <' + CAST(@POWER_PLANT_NAME AS VARCHAR) + '> Power Plant'

    SET @BODY = '<html>
    <body>
    <h1>Power Plant Maintenance Report</h1>
    <p>Dear Team,</p>
    <p>Maintenance done in the following power plant</p>
    <p>Details:</p>
    <ul>
        <li>Log ID: '
    SET @BODY = @BODY + CAST(@LOG_ID AS VARCHAR) + '</li>'

    SET @EMAIL = (
        SELECT USERS.USER_EMAIL
        FROM POWER_PLANTS (NOLOCK)
        INNER JOIN COMPANIES ON POWER_PLANTS.POWER_PLANT_COMPANY_ID = COMPANIES.COMPANY_ID
        INNER JOIN USERS ON COMPANIES.COMPANY_CEO_ID = USERS.USER_ID
        WHERE POWER_PLANTS.POWER_PLANT_ID = @POWER_PLANT_ID
    )

    EXEC msdb.dbo.sp_send_dbmail
        @profile_name = 'MORPHEUS_ENGINE_NOREPLY_BOT',
        @recipients = @EMAIL,
        @copy_recipients = '',
        @blind_copy_recipients = '',
        @body_format = 'HTML',
        @body = @BODY,
        @subject = @SUBJECT,
        @from_address = 'eduardoxaviersa@gmail.com',
        @reply_to = '',
        @importance = 'Normal';

    CLOSE _cursor
    DEALLOCATE _cursor
END

GO

CREATE TRIGGER TG_LIFE_SUPPORT_SYSTEM_MAINTENANCE_REPORT
ON LIFE_SUPPORT_SYSTEM_MAINTENANCE_LOGS
AFTER INSERT
AS
BEGIN
    DECLARE @LOG_ID INT
    DECLARE @OPERATION_ID INT
    DECLARE @SYSTEM_ID INT
    DECLARE @MAINTENANCE_DESCRIPTION VARCHAR(MAX)
    DECLARE @MAINTENANCE_DATE DATE
    DECLARE @MAINTENANCE_TECHNITIAN INT
    DECLARE @MAINTENANCE_RESULTS_INFO VARBINARY(255)

    DECLARE @SYSTEM_NAME VARCHAR(50)
    DECLARE @SUBJECT VARCHAR(255)
    DECLARE @BODY VARCHAR(MAX)
    DECLARE @EMAIL VARCHAR(100)

    --######################################################################
    DECLARE _cursor CURSOR FOR (
        SELECT LOG_ID,
        OPERATION_ID,
        SYSTEM_ID,
        MAINTENANCE_DESCRIPTION,
        MAINTENANCE_DATE,
        MAINTENANCE_TECHNITIAN_ID,
        MAINTENANCE_RESULTS_INFO
        FROM LIFE_SUPPORT_SYSTEM_MAINTENANCE_LOGS (NOLOCK)
    )

    OPEN _cursor
    FETCH NEXT FROM _cursor INTO @LOG_ID, @OPERATION_ID, @SYSTEM_ID, @MAINTENANCE_DESCRIPTION, @MAINTENANCE_DATE, @MAINTENANCE_TECHNITIAN, @MAINTENANCE_RESULTS_INFO
    --######################################################################

    SET @SYSTEM_NAME = (
        SELECT SYSTEM_NAME
        FROM LIFE_SUPPORT_SYSTEMS (NOLOCK)
        WHERE SYSTEM_ID = @SYSTEM_ID
    )
    
    SET @SUBJECT = 'Maintenace Report for <' + CAST(@SYSTEM_NAME AS VARCHAR) + '> Life Support System'

    SET @BODY = '<html>
    <body>
    <h1>Life Support System Maintenance Report</h1>
    <p>Dear Team,</p>
    <p>Maintenance done in the following life support system</p>
    <p>Details:</p>
    <ul>
        <li>Log ID: '
    
    SET @BODY = @BODY + CAST(@LOG_ID AS VARCHAR) + '</li></body></html>'

    SET @EMAIL = (
        SELECT USERS.USER_EMAIL
        FROM LIFE_SUPPORT_SYSTEMS (NOLOCK)
        INNER JOIN COMPANIES ON LIFE_SUPPORT_SYSTEMS.SYSTEM_COMPANY_ID = COMPANIES.COMPANY_ID
        INNER JOIN USERS ON COMPANIES.COMPANY_CEO_ID = USERS.USER_ID
        WHERE LIFE_SUPPORT_SYSTEMS.SYSTEM_ID = @SYSTEM_ID
    )

    EXEC msdb.dbo.sp_send_dbmail
        @profile_name = 'MORPHEUS_ENGINE_NOREPLY_BOT',
        @recipients = @EMAIL,
        @copy_recipients = '',
        @blind_copy_recipients = '',
        @body_format = 'HTML',
        @body = @BODY,
        @subject = @SUBJECT,
        @from_address = 'eduardoxaviersa@gmail.com',
        @reply_to = '',
        @importance = 'Normal';

    CLOSE _cursor
    DEALLOCATE _cursor
END