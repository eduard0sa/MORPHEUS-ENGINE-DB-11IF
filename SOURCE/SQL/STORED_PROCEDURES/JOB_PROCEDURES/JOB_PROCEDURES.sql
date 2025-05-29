--==================================================================================================================
--============= USER_QUERIES.sql ===================================================================================
--============= Contem queries para listagem e analise estatistica de dados inerentes ás empresas ==================
--==================================================================================================================

USE [_MORPHEUS_ENGINE_] -- DB CONNECTION
GO

--PROCEDURE PARA GERAR E ENVIAR RELATÓRIO DE FLUXO DE ENERGIA DAS CENTRAIS ELÉTRICAS, VIA EMAIL, PARA OS CEO'S DE TODAS AS EMPRESAS DETENTORAS DAS CENTRAIS ELÉTRICAS.
CREATE PROCEDURE GENERATE_AND_SEND_POWER_FLUX_REPORT
AS
BEGIN
    DECLARE @POWER_PLANTS_COUNT INT = (SELECT COUNT(POWER_PLANT_ID) FROM POWER_PLANTS (NOLOCK))
    DECLARE @POWER_PLANT_ID INT
    DECLARE @POWER_PLANT_NAME VARCHAR(50)
    DECLARE @POWER_PLANT_COMPANY_ID INT
    DECLARE @POWER_PLANT_COMPANY_NAME VARCHAR(100)
    DECLARE @POWER_PLANT_CEO VARCHAR(75)
    DECLARE @POWER_PLANT_TYPE_ID INT
    DECLARE @POWER_PLANT_TYPE_NAME VARCHAR(50)
    DECLARE @POWER_PLANT_LOCATION VARCHAR(100)
    DECLARE @POWER_PLANT_MAX_OUTPUT_CAPACITY FLOAT
    DECLARE @POWER_PLANT_STATUS_ID INT
    DECLARE @POWER_PLANT_STATUS_NAME VARCHAR(50)
    DECLARE @POWER_PLANT_LAST_MAINTENANCE_DATE DATE
    DECLARE @POWER_PLANT_NEXT_MAINTENANCE_DATE DATE
    DECLARE @POWER_PLANT_INSTALLATION_DATE DATE

    -----------------------------------------------------------------------------

    DECLARE @LOG_SOURCE_ID INT
    DECLARE @LOG_POWER_OUTPUT FLOAT
    DECLARE @LOG_POWER_CONSUMPTION FLOAT
    DECLARE @LOG_POWER_STORAGE FLOAT

    -----------------------------------------------------------------------------

    DECLARE @SUBJECT VARCHAR(255)
    DECLARE @BODY NVARCHAR(MAX)
    DECLARE @EMAIL VARCHAR(100)

    -----------------------------------------------------------------------------

    DECLARE _cursor CURSOR FOR(SELECT POWER_PLANT_ID,
        POWER_PLANT_NAME,
        POWER_PLANT_COMPANY_ID,
        POWER_PLANT_TYPE_ID,
        POWER_PLANT_LOCATION,
        POWER_PLANT_MAX_OUTPUT_CAPACITY,
        POWER_PLANT_STATUS_ID,
        POWER_PLANT_NEXT_MAINTENANCE_DATE,
        POWER_PLANT_INSTALLATION_DATE FROM POWER_PLANTS (NOLOCK))

    OPEN _cursor
    FETCH NEXT FROM _cursor INTO @POWER_PLANT_ID,
        @POWER_PLANT_NAME,
        @POWER_PLANT_COMPANY_ID,
        @POWER_PLANT_TYPE_ID,
        @POWER_PLANT_LOCATION,
        @POWER_PLANT_MAX_OUTPUT_CAPACITY,
        @POWER_PLANT_STATUS_ID,
        @POWER_PLANT_NEXT_MAINTENANCE_DATE,
        @POWER_PLANT_INSTALLATION_DATE;

    ------------------------------------------------------------------------------

    DECLARE @I INT = 1; -- Contador para o ciclo WHILE
    WHILE (@I <= @POWER_PLANTS_COUNT)
    BEGIN
        SET @LOG_SOURCE_ID = @POWER_PLANT_ID

        SET @POWER_PLANT_CEO = (
            SELECT TOP(1) USER_FIRST_NAME + ' ' + USER_LAST_NAME
            FROM USERS (NOLOCK)
            INNER JOIN COMPANIES ON USERS.USER_ID = COMPANIES.COMPANY_CEO_ID
            WHERE COMPANIES.COMPANY_ID = @POWER_PLANT_COMPANY_ID
        )
        SET @POWER_PLANT_COMPANY_NAME = (
            SELECT COMPANY_NAME
            FROM COMPANIES (NOLOCK)
            WHERE COMPANY_ID = @POWER_PLANT_COMPANY_ID
        )
        SET @POWER_PLANT_TYPE_NAME = (
            SELECT POWER_PLANT_TYPE_NAME
            FROM POWER_PLANT_TYPE (NOLOCK)
            WHERE POWER_PLANT_TYPE_ID = @POWER_PLANT_TYPE_ID
        )
        SET @LOG_POWER_OUTPUT = (
            SELECT SUM(LOG_POWER_OUTPUT)
            FROM POWER_FLUX_LOGS (NOLOCK)
            WHERE LOG_SOURCE_ID = @LOG_SOURCE_ID
            AND LOG_TIME >= DATEADD(WEEK, -1, GETDATE())
            AND LOG_TIME <= GETDATE()
        )
        SET @LOG_POWER_CONSUMPTION = (
            SELECT SUM(LOG_POWER_CONSUMPTION)
            FROM POWER_FLUX_LOGS (NOLOCK)
            WHERE LOG_SOURCE_ID = @LOG_SOURCE_ID
            AND LOG_TIME >= DATEADD(WEEK, -1, GETDATE())
            AND LOG_TIME <= GETDATE()
        )
        SET @LOG_POWER_STORAGE = (
            SELECT SUM(LOG_POWER_STORAGE)
            FROM POWER_FLUX_LOGS (NOLOCK)
            WHERE LOG_SOURCE_ID = @LOG_SOURCE_ID
            AND LOG_TIME >= DATEADD(WEEK, -1, GETDATE())
            AND LOG_TIME <= GETDATE()
        )
        SET @POWER_PLANT_STATUS_NAME = (
            SELECT MACHINE_STATUS_NAME
            FROM MACHINE_STATUS (NOLOCK)
            WHERE MACHINE_STATUS_ID = @POWER_PLANT_STATUS_ID
        )
        SET @POWER_PLANT_LAST_MAINTENANCE_DATE = (
            SELECT MAX(MAINTENANCE_DATE)
            FROM POWER_PLANT_MAINTENANCE_LOGS (NOLOCK)
            WHERE POWER_PLANT_ID = @POWER_PLANT_ID
        )
        ----------------------------------------------------------
        SET @SUBJECT = 'POWER FLUX REPORT'
        SET @EMAIL = (
            SELECT USER_EMAIL
            FROM USERS (NOLOCK)
            INNER JOIN COMPANIES ON USERS.USER_ID = COMPANIES.COMPANY_CEO_ID
            WHERE COMPANIES.COMPANY_ID = @POWER_PLANT_COMPANY_ID
        )
        SET @BODY = '<!DOCTYPE html>
            <html lang="pt">
            <head>
            <meta charset="UTF-8">
            <title>Relatório da Central Elétrica</title>
            </head>
            <body style="margin:0; padding:0; background-color:#ffffff; font-family:Arial, sans-serif; color:#131314;">
            <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                    <td align="center">
                    <table width="600" cellpadding="30" cellspacing="0" style="background-color: #131314; box-shadow:0 2px 8px rgba(0,0,0,0.05); text-align:left;">
                        <tr>
                        <td align="center">
                            <img src="https://cicpt-my.sharepoint.com/personal/a16606_cic_pt/Documents/11%c2%ba%20ANO/BD/MORPHEUS%20ENGINE/RESOURCE%20HOSTING/MORPHEUS_ENGINE_FLAT.png?Web=1" alt="Morpheus Engine Logo" width="600">
                            <hr/>
                        </td>
                        </tr>
                    </table>
                    </td>
                </tr>
                <tr>
                <td align="center">
                    <table width="600" cellpadding="30" cellspacing="0" style="background-color: #f9f9f9; box-shadow:0 2px 8px rgba(0,0,0,0.05); text-align:left;">
                    <tr>
                        <td>
                        <h1 style="margin-top:0; font-size:24px; color:#131314; font-weight:600; text-align:center;">RELATORIO DE PRODUÇÃO DE ENERGIA</h1>

                        <p style="line-height:1.6;">Bom dia, exmo(a) CEO da <strong>' + @POWER_PLANT_COMPANY_NAME + '</strong>, Sr(a). <strong>' + @POWER_PLANT_CEO + '</strong>,</p>

                        <p style="line-height:1.6;">Enviamo-lhe o relatório energético relativo à central <strong>' + @POWER_PLANT_NAME + '</strong>, detida e gerida pela sua empresa.</p>

                        <p style="line-height:1.6;">Este relatório contém informações sobre a produção, consumo e armazenamento de energia da sua central, bem como detalhes sobre a sua manutenção.</p>

                        <h2 style="font-size:18px; color:#131314; border-bottom:1px solid #eeeeee; padding-bottom:6px;">Informação da central</h2>
                        <ul style="list-style:none; padding-left:0; margin:15px 0; line-height:1.8;">
                            <li><strong>ID:</strong> ' + CAST(@POWER_PLANT_ID AS VARCHAR) + '</li>
                            <li><strong>Nome:</strong> ' + CAST(@POWER_PLANT_NAME AS VARCHAR) + '</li>
                            <li><strong>Tipo:</strong> ' + CAST(@POWER_PLANT_TYPE_NAME AS VARCHAR) + '</li>
                            <li><strong>Status:</strong> ' + CAST(@POWER_PLANT_STATUS_ID AS VARCHAR) + ' - ' + CAST(@POWER_PLANT_STATUS_NAME AS VARCHAR) + '</li>
                            <li><strong>Company ID:</strong> ' + CAST(@POWER_PLANT_COMPANY_ID AS VARCHAR) + '</li>
                            <li><strong>Data de Instalação:</strong> ' + CAST(@POWER_PLANT_INSTALLATION_DATE AS VARCHAR) + '</li>
                            <li><strong>Localização:</strong> ' + CAST(@POWER_PLANT_LOCATION AS VARCHAR) + '</li>
                            <li><strong>Capacidade Máxima:</strong> ' + CAST(@POWER_PLANT_MAX_OUTPUT_CAPACITY AS VARCHAR) + '</li>
                            <li><strong>Última Manutenção:</strong> ' + CAST(@POWER_PLANT_LAST_MAINTENANCE_DATE AS VARCHAR) + '</li>
                            <li><strong>Próxima Manutenção:</strong> ' + CAST(@POWER_PLANT_NEXT_MAINTENANCE_DATE AS VARCHAR) + '</li>
                        </ul>

                        <h2 style="font-size:18px; color:#131314; border-bottom:1px solid #eeeeee; padding-bottom:6px;">Balanço energético</h2>
                        <ul style="list-style:none; padding-left:0; line-height:1.8;">
                            <li><strong>Produção Total (última semana):</strong> ' + CAST(@LOG_POWER_OUTPUT AS VARCHAR) + ' kWh</li>
                            <li><strong>Consumo Total (última semana):</strong> ' + CAST(@LOG_POWER_CONSUMPTION AS VARCHAR) + ' kWh</li>
                            <li><strong>Armazenamento Total (última semana):</strong> ' + CAST(@LOG_POWER_STORAGE AS VARCHAR) + ' kWh</li>
                            <li><strong>Desperdício Energético:</strong> ' + CAST(dbo.FN_CALC_WASTED_ENERGY(@LOG_POWER_OUTPUT, @LOG_POWER_CONSUMPTION, @LOG_POWER_STORAGE) AS VARCHAR) + ' kWh (' + CAST(dbo.FN_CALC_PERCENTAGE(@LOG_POWER_OUTPUT, dbo.FN_CALC_WASTED_ENERGY(@LOG_POWER_OUTPUT, @LOG_POWER_CONSUMPTION, @LOG_POWER_STORAGE)) AS VARCHAR) + '% da energia total produzida)</li>
                        </ul>
                        <hr/>
                        <p style="margin-top:30px;">Com os melhores cumprimentos,</p>
                        <p><strong>A equipa Morpheus Engine.</strong></p>

                        <p style="font-size:12px; color:#131314; margin-top:40px; border-top:1px solid #dddddd; padding-top:20px;">
                            Esta mensagem foi gerada automaticamente pelos sistemas informáticos da Morpheus Engine. Por favor, não responda a este e-mail.
                        </p>
                        </td>
                    </tr>
                    </table>
                </td>
                </tr>
            </table>
            </body>
            </html>'

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

        FETCH NEXT FROM _cursor INTO @POWER_PLANT_ID,
            @POWER_PLANT_NAME,
            @POWER_PLANT_COMPANY_ID,
            @POWER_PLANT_TYPE_ID,
            @POWER_PLANT_LOCATION,
            @POWER_PLANT_MAX_OUTPUT_CAPACITY,
            @POWER_PLANT_STATUS_ID,
            @POWER_PLANT_NEXT_MAINTENANCE_DATE,
            @POWER_PLANT_INSTALLATION_DATE;

        SET @I = @I + 1;
    END

    CLOSE _cursor
    DEALLOCATE _cursor
END