/* =============================================================================================
    ORCHESTRATION - TASKS (ordre et dépendances)
    NOTE : Remplacer COMPUTE_WH par le nom de votre entrepôt
================================================================================================ */

-- Sélection du rôle devops_role pour les opérations suivantes
USE ROLE app_role;

-- Sélection de la base de données health_app_db pour les opérations suivantes
USE DATABASE health_app_db;

-- Suspendre la racine pour éviter déclenchement immédiat
ALTER TASK common.identify_new_data_task SUSPEND;

-- Racine : ingestion de nouvelles données déclenchée par le stream
CREATE OR ALTER TASK common.identify_new_data_task
WAREHOUSE = COMPUTE_WH
WHEN SYSTEM$STREAM_HAS_DATA('raw.raw_events_stream')
AS
    CALL common.identify_new_data(SYSTEM$TASK_RUNTIME_INFO('CURRENT_TASK_GRAPH_RUN_GROUP_ID'));

-- Contrôle qualité
CREATE OR ALTER TASK common.data_quality_task
WAREHOUSE = COMPUTE_WH
AFTER common.identify_new_data_task
AS
    CALL common.data_quality(SYSTEM$TASK_RUNTIME_INFO('CURRENT_TASK_GRAPH_RUN_GROUP_ID'));

-- Timeliness
CREATE OR ALTER TASK common.data_timeliness_task
WAREHOUSE = COMPUTE_WH
AFTER common.data_quality_task
AS
    CALL common.data_timeliness(SYSTEM$TASK_RUNTIME_INFO('CURRENT_TASK_GRAPH_RUN_GROUP_ID'));

-- Tasks d'enrichissement (par process). Elles démarrent après la task de timeliness.
CREATE OR ALTER TASK common.hih_listener_manager
WAREHOUSE = COMPUTE_WH
AFTER common.data_timeliness_task
AS
    CALL common.enrich_data('hih_listener_manager', 'HiH_ListenerManager', SYSTEM$TASK_RUNTIME_INFO('CURRENT_TASK_GRAPH_RUN_GROUP_ID'));

CREATE OR ALTER TASK common.hih_hibroadcastutil
WAREHOUSE = COMPUTE_WH
AFTER common.data_timeliness_task
AS
    CALL common.enrich_data('hih_hi_broadcast_util', 'HiH_HiBroadcastUtil', SYSTEM$TASK_RUNTIME_INFO('CURRENT_TASK_GRAPH_RUN_GROUP_ID'));

CREATE OR ALTER TASK common.step_standstepcounter
WAREHOUSE = COMPUTE_WH
AFTER common.data_timeliness_task
AS
    CALL common.enrich_data('step_stand_step_counter', 'Step_StandStepCounter', SYSTEM$TASK_RUNTIME_INFO('CURRENT_TASK_GRAPH_RUN_GROUP_ID'));

CREATE OR ALTER TASK common.step_sputils
WAREHOUSE = COMPUTE_WH
AFTER common.data_timeliness_task
AS
    CALL common.enrich_data('step_sp_utils', 'Step_SPUtils', SYSTEM$TASK_RUNTIME_INFO('CURRENT_TASK_GRAPH_RUN_GROUP_ID'));

CREATE OR ALTER TASK common.step_lsc
WAREHOUSE = COMPUTE_WH
AFTER common.data_timeliness_task
AS
    CALL common.enrich_data('step_lsc', 'Step_LSC', SYSTEM$TASK_RUNTIME_INFO('CURRENT_TASK_GRAPH_RUN_GROUP_ID'));

CREATE OR ALTER TASK common.hih_hihealthdatainsertstore
WAREHOUSE = COMPUTE_WH
AFTER common.data_timeliness_task
AS
    CALL common.enrich_data('hih_hi_health_data_insert_store', 'HiH_HiHealthDataInsertStore', SYSTEM$TASK_RUNTIME_INFO('CURRENT_TASK_GRAPH_RUN_GROUP_ID'));

CREATE OR ALTER TASK common.hih_datastatmanager
WAREHOUSE = COMPUTE_WH
AFTER common.data_timeliness_task
AS
    CALL common.enrich_data('hih_data_stat_manager', 'HiH_DataStatManager', SYSTEM$TASK_RUNTIME_INFO('CURRENT_TASK_GRAPH_RUN_GROUP_ID'));

CREATE OR ALTER TASK common.hih_hisyncutil
WAREHOUSE = COMPUTE_WH
AFTER common.data_timeliness_task
AS
    CALL common.enrich_data('hih_hi_sync_util', 'HiH_HiSyncUtil', SYSTEM$TASK_RUNTIME_INFO('CURRENT_TASK_GRAPH_RUN_GROUP_ID'));

CREATE OR ALTER TASK common.step_standreportreceiver
WAREHOUSE = COMPUTE_WH
AFTER common.data_timeliness_task
AS
    CALL common.enrich_data('step_stand_report_receiver', 'Step_StandReportReceiver', SYSTEM$TASK_RUNTIME_INFO('CURRENT_TASK_GRAPH_RUN_GROUP_ID'));

CREATE OR ALTER TASK common.step_screenutil
WAREHOUSE = COMPUTE_WH
AFTER common.data_timeliness_task
AS
    CALL common.enrich_data('step_screen_util', 'Step_ScreenUtil', SYSTEM$TASK_RUNTIME_INFO('CURRENT_TASK_GRAPH_RUN_GROUP_ID'));

-- Task finale (finalize) : s'exécute après la racine identif_new_data_task
CREATE OR ALTER TASK common.finalize_transformation_task
WAREHOUSE = COMPUTE_WH
FINALIZE = 'common.identify_new_data_task'
AS
    CALL common.finalize_transformation(SYSTEM$TASK_RUNTIME_INFO('CURRENT_TASK_GRAPH_RUN_GROUP_ID'), SYSTEM$TASK_RUNTIME_INFO('CURRENT_TASK_GRAPH_ORIGINAL_SCHEDULED_TIMESTAMP'));
