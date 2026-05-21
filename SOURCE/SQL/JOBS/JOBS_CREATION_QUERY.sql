--==================================================================================================================
--============= JOBS_CREATION_QUERY.sql ===========================================================================
--================ Permite a criação automatizada das tarefas agendadas (JOBS). ====================================
--==================================================================================================================

USE msdb;
GO
----------------------------------------------------------------------------------------
EXEC dbo.sp_add_job @job_name = N'POWER_FLUX_REPORT_JOB' ;
GO
EXEC sp_add_jobstep
    @job_name = N'POWER_FLUX_REPORT_JOB',
    @step_name = N'STEP_1',
    @subsystem = N'TSQL',
    @command = N'USE _MORPHEUS_ENGINE_; EXEC GENERATE_AND_SEND_POWER_FLUX_REPORT',
    @retry_attempts = 5,
    @retry_interval = 5 ;
GO
EXEC dbo.sp_add_schedule
    @schedule_name = N'RunWeekly',
    @freq_type = 8, -- Todas as semanas
    @freq_interval = 1, -- Aos Domingos
    @freq_recurrence_factor = 1, -- Recorrência semanal
    @active_start_time = 090000; -- Ás 09:00:00
    
GO
EXEC sp_attach_schedule
    @job_name = N'POWER_FLUX_REPORT_JOB',
    @schedule_name = N'RunWeekly';
GO
EXEC dbo.sp_add_jobserver @job_name = N'POWER_FLUX_REPORT_JOB';
GO
----------------------------------------------------------------------------------------