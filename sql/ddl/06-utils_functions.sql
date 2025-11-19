/* =============================================================================================
    FONCTIONS SQL UTILES (contrôles)
================================================================================================ */
-- Sélection du rôle devops_role pour les opérations suivantes
USE ROLE devops_role;

-- Sélection de la base de données health_app_db pour les opérations suivantes
USE DATABASE health_app_db;

-- Vérifie si le timestamp est "correct" (ex : pas dans le futur, pas NULL)
CREATE OR REPLACE FUNCTION common.check_correct_timestamp(event_timestamp TIMESTAMP)
RETURNS BOOLEAN
LANGUAGE SQL
AS
$$
    event_timestamp > '2016-01-01 00:00:00'::TIMESTAMP AND event_timestamp <= CURRENT_TIMESTAMP()
$$;

-- Vérifie si le process_name est dans un format attendu
CREATE OR REPLACE FUNCTION common.check_correct_process_name(process_name STRING)
RETURNS BOOLEAN
LANGUAGE SQL
AS
$$
    process_name  IN ('HiH_ListenerManager', 'HiH_HiBroadcastUtil', 'Step_StandStepCounter', 'Step_SPUtils',
    'Step_NotificationUtil', 'Step_LSC', 'HiH_HiHealthDataInsertStore', 'HiH_DataStatManager', 'HiH_HiSyncUtil',
    'Step_StandReportReceiver', 'Step_ScreenUtil', 'Step_StandStepDataManager', 'Step_ExtSDM', 'HiH_HiHealthBinder',
    'Step_DataCache', 'Step_HGNH', 'Step_FlushableStepDataCache', 'HiH_HiAppUtil', 'HiH_HiSyncControl')
$$;

-- Vérifie si l'arrivée est tardive (> 5 jours)
CREATE OR REPLACE FUNCTION common.check_late_arrival_timestamp(event_timestamp TIMESTAMP)
RETURNS BOOLEAN
LANGUAGE SQL
AS
$$
    DATEDIFF('day', event_timestamp, CURRENT_TIMESTAMP()) > 5
$$;
