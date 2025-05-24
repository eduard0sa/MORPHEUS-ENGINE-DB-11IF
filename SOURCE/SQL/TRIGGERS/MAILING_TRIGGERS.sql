--==================================================================================================================
--============= USER_QUERIES.sql ===================================================================================
--============= Contem queries para listagem e analise estatistica de dados inerentes ás empresas ==================
--==================================================================================================================

USE [_MORPHEUS_ENGINE_] -- DB CONNECTION
GO

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
    DECLARE _cursor CURSOR FOR (SELECT USER_FIRST_NAME,
        USER_LAST_NAME,
        USER_EMAIL,
        USER_PHONENUMBER,
        USER_PROFILE_PICTURE_PATH,
        USER_COUNTRY_ID FROM inserted (NOLOCK))

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
        @profile_name = 'Web client 1',
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
    DECLARE _cursor CURSOR FOR (SELECT LOG_ID,
        OPERATION_ID,
        POWER_PLANT_ID,
        MAINTENANCE_DESCRIPTION,
        MAINTENANCE_DATE,
        MAINTENANCE_TECHNITIAN_ID,
        MAINTENANCE_RESULTS_INFO FROM inserted (NOLOCK))

    OPEN _cursor
    FETCH NEXT FROM _cursor INTO @LOG_ID, @OPERATION_ID, @POWER_PLANT_ID, @MAINTENANCE_DESCRIPTION, @MAINTENANCE_DATE, @MAINTENANCE_TECHNITIAN, @MAINTENANCE_RESULTS_INFO
    --######################################################################

    SET @POWER_PLANT_NAME = (SELECT POWER_PLANT_NAME
        FROM POWER_PLANTS (NOLOCK)
        WHERE POWER_PLANT_ID = @POWER_PLANT_ID)
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

    SET @EMAIL = (SELECT USERS.USER_EMAIL
        FROM POWER_PLANTS (NOLOCK)
        INNER JOIN COMPANIES ON POWER_PLANTS.POWER_PLANT_COMPANY_ID = COMPANIES.COMPANY_ID
        INNER JOIN USERS ON COMPANIES.COMPANY_CEO_ID = USERS.USER_ID
        WHERE POWER_PLANTS.POWER_PLANT_ID = @POWER_PLANT_ID)

    EXEC msdb.dbo.sp_send_dbmail
        @profile_name = 'Web client 1',
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