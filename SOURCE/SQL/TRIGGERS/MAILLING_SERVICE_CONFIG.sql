--==================================================================================================================
--============= MAILLING_SERVICE_CONFIG.sql ========================================================================
--============= Script para a configuração do serviço de mailling do SQL Server, para o MORPHEUS ENGINE ============
--==================================================================================================================

USE [_MORPHEUS_ENGINE_] -- DB CONNECTION
GO

--Criação da conta de email para o serviço de mailing do SQL Server
EXECUTE msdb.dbo.sysmail_add_account_sp  
    @account_name = 'MORPHEUS_ENGINE_NOREPLY_BOT_ACCOUNT',
    @description = 'Mail account for noreply emails from Morpheus Engine',  
    @email_address = 'eduardoxaviersa@gmail.com',
    @display_name = 'MORPHEUS ENGINE (NO_REPLY)',
    @mailserver_name = 'in-v3.mailjet.com',
    @port = 587,
    @username = '08e243f091fc1a69513f50c243624be5',
    @password = 'e049f4d6b6178797cb0077febb9a1833',
    @enable_ssl = 1;

--Criação do perfil de email para o serviço de mailing do SQL Server
EXECUTE msdb.dbo.sysmail_add_profile_sp
  @profile_name = 'MORPHEUS_ENGINE_NOREPLY_BOT'
, @description = 'Description';

-- Associa a conta de email ao perfil de email criado
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
  @profile_name = 'MORPHEUS_ENGINE_NOREPLY_BOT'
, @account_name = 'MORPHEUS_ENGINE_NOREPLY_BOT_ACCOUNT'
, @sequence_number = 1;

-- Associa o perfil de email ao utilizador 'sa' e define-o como padrão
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp  
    @profile_name = 'MORPHEUS_ENGINE_NOREPLY_BOT',
    @principal_name = 'sa',
    @is_default = 1;