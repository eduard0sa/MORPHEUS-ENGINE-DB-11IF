--==================================================================================================================
--============= USER_QUERIES.sql ===================================================================================
--============= Contem queries para listagem e analise estatistica de dados inerentes ás empresas ==================
--==================================================================================================================

USE [_MORPHEUS_ENGINE_] -- DB CONNECTION
GO

ALTER TRIGGER AA
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
    
    --EXEC msdb.dbo.so_create_profile

    EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'Web client 1',
    @recipients = @EMAIL,
    @copy_recipients = '',
    @blind_copy_recipients = '',
    @body = 'safinsifjnasfm',
    @subject = 'Welcome to MORPHEUS_ENGINE',
	@from_address = 'eduardoxaviersa@gmail.com',
	@reply_to = '',
    @importance = 'Normal';

    CLOSE _cursor
    DEALLOCATE _cursor
END

SELECT * FROM USERS (NOLOCK)

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
) VALUES ('EDUARDO', 'SÁ', 0x4B4B4B, 'eduardoxaviersa@gmail.com', '192168301', 'C:\Pics\EXOS.jpg', '1993-11-11', 1, 1, '112 K St', 1011, 105000, 2011, 8, 2, 4);