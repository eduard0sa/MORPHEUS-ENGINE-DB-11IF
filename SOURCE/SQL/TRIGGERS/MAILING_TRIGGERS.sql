--==================================================================================================================
--============= USER_QUERIES.sql ===================================================================================
--============= Contem queries para listagem e analise estatistica de dados inerentes ás empresas ==================
--==================================================================================================================

USE [_MORPHEUS_ENGINE_] -- DB CONNECTION
GO

CREATE TRIGGER AA
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

    DECLARE _cursor CURSOR FOR (SELECT USER_FIRST_NAME,
    USER_LAST_NAME,
    USER_EMAIL,
    USER_PHONENUMBER,
    USER_PROFILE_PICTURE_PATH,
    USER_COUNTRY_ID FROM inserted (NOLOCK))

    OPEN _cursor
    FETCH NEXT FROM _cursor INTO @FIRST_NAME, @LAST_NAME, @EMAIL, @PHONENUMBER, @PROFILE_PICTURE_PATH, @COUNTRY_ID

    EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'AGENT',
    @recipients = @EMAIL,
    @copy_recipients = '',
    @blind_copy_recipients = '',
    @body = 'Hello, dear ' + @FIRST_NAME + ' ' + @LAST_NAME + ', welcome to MORPHEUS_ENGINE.
    \n We are glad to have you with us.
    \nPlease check your profile and update any information if necessary.',
    @subject = 'Welcome to MORPHEUS_ENGINE',
	@from_address = '<from email>',
	@reply_to = ''
    @importance = 'Important',

    CLOSE _cursor
    DEALLOCATE _cursor
END

SELECT * FROM USERS (NOLOCK)