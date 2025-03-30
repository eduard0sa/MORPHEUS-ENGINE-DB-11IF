--==================================================================================================================================
--============= ENERGY_MGMT_FUNCTIONS.sql ==========================================================================================
--============= Contém funções bastante uteis na obtenção de estatisticas relativamente á gestão e produção de energia.=============
--==================================================================================================================================

USE [_MORPHEUS_ENGINE_] -- DB CONNECTION
GO

-- FUNÇÃO QUE CALCULA A ENERGIA DESPERDIÇADA, POR UMA DETERMINADA CENTRAL DE PRODUÇÃO, RECORRENDO Á ENERGIA PRODUZIDA, CONSUMIDA E ARMAZENADA
CREATE FUNCTION FN_CALC_WASTED_ENERGY ( @energy_production float, @energy_consumption float, @energy_storage float)
RETURNS float
BEGIN
	DECLARE @wasted_energy float
	SET @wasted_energy = @energy_production - @energy_consumption - @energy_storage
	RETURN @wasted_energy
END
GO

-- FUNÇÃO PARA CALCULAR A ENERGIA PRODUZIDA NUM DETERMINADO MÊS
CREATE FUNCTION FN_ENERGY_PRODUCTION_LAST_MONTH ( @POWER_PLANT_ID int, @month int )
RETURNS float
BEGIN
	DECLARE @total_energy_production float
	SET @total_energy_production = (SELECT SUM(LOG_POWER_OUTPUT) AS TOTAL_ENERGY_PRODUCTION FROM POWER_FLUX_LOGS (NOLOCK) WHERE LOG_SOURCE_ID = @POWER_PLANT_ID AND MONTH(LOG_TIME) = @month)
	RETURN @total_energy_production
END
GO

-- FUNÇÃO PARA CALCULAR A ENERGIA CONSUMIDA NUM DETERMINADO MÊS
CREATE FUNCTION FN_ENERGY_CONSUMPTION_LAST_MONTH ( @POWER_PLANT_ID int, @month int )
RETURNS float
BEGIN
	DECLARE @total_energy_consumption float
	SET @total_energy_consumption = (SELECT SUM(LOG_POWER_CONSUMPTION) AS TOTAL_ENERGY_CONSUMPTION FROM POWER_FLUX_LOGS WHERE LOG_SOURCE_ID = @POWER_PLANT_ID AND MONTH(LOG_TIME) = @month)
	RETURN @total_energy_consumption
END
GO

-- FUNÇÃO PARA CALCULAR A ENERGIA ARMAZENADA NUM DETERMINADO MÊS
CREATE FUNCTION FN_ENERGY_STORAGE_LAST_MONTH ( @POWER_PLANT_ID int, @month int )
RETURNS float
BEGIN
	DECLARE @total_energy_storage float
	SET @total_energy_storage = (SELECT SUM(LOG_POWER_STORAGE) AS TOTAL_ENERGY_STORAGE FROM POWER_FLUX_LOGS WHERE LOG_SOURCE_ID = @POWER_PLANT_ID AND MONTH(LOG_TIME) = @month)
	RETURN @total_energy_storage
END
GO