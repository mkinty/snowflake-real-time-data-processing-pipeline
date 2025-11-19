/* =============================================================================================
    ACTIVATION / RUN : commandes d'activation (exécuter manuellement)
================================================================================================ */
-- Sélection du rôle devops_role pour les opérations suivantes
USE ROLE app_role;

-- Sélection de la base de données health_app_db pour les opérations suivantes
USE DATABASE health_app_db;

-- Suspendre la racine pour éviter déclenchement immédiat
ALTER TASK common.identify_new_data_task SUSPEND;

-- Reprendre les tasks dépendantes dans l'ordre (d'abord data_quality -> timeliness -> enrichments)
ALTER TASK common.data_quality_task RESUME;
ALTER TASK common.data_timeliness_task RESUME;
ALTER TASK common.hih_listener_manager RESUME;
ALTER TASK common.hih_hibroadcastutil RESUME;
ALTER TASK common.step_standstepcounter RESUME;
ALTER TASK common.step_sputils RESUME;
ALTER TASK common.step_lsc RESUME;
ALTER TASK common.hih_hihealthdatainsertstore RESUME;
ALTER TASK common.hih_datastatmanager RESUME;
ALTER TASK common.hih_hisyncutil RESUME;
ALTER TASK common.step_standreportreceiver RESUME;
ALTER TASK common.step_screenutil RESUME;
ALTER TASK common.finalize_transformation_task RESUME;

-- Reprendre la racine
ALTER TASK common.identify_new_data_task RESUME;

