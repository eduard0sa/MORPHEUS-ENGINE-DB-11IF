--==================================================================================================================================
--============= MATH_FUNCTIONS.sql =================================================================================================
--============= Contém funções genéricas recorrentemente utilizadas no calculo de diversas estatisticas, num âmbito geral. =========
--==================================================================================================================================

USE [_MORPHEUS_ENGINE_] -- DB CONNECTION
GO

-- FUNÇÃO PARA CALCULAR A IDADE ATUAL EM FUNÇÃO DA DATA DE NASCIMENTO
CREATE FUNCTION FN_CALC_AGE ( @initialDate date )
RETURNS INT
BEGIN
	RETURN DATEDIFF(YEAR, @initialDate, GETDATE())
END
GO

-- FUNÇÃO PARA CALCULAR PERCENTAGENS
CREATE FUNCTION FN_CALC_PERCENTAGE ( @total float, @part float)
RETURNS float
BEGIN
	RETURN @part / @total * 100
END
GO

--FUNÇÃO PARA LIMITAR UM VALOR A UM DETERMINADO INTERVALO
CREATE FUNCTION FN_CLAMP_FLOAT ( @num float, @min float, @max float )
RETURNS float
BEGIN
	DECLARE @NUMBER float = @num
	SET @NUMBER = IIF(@NUMBER < @min, @MIN, @NUMBER)
	SET @NUMBER = IIF(@NUMBER > @max, @max, @NUMBER)
	RETURN @NUMBER
END