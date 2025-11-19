/* =============================================================================================
    Afficher les historiques des tâches
================================================================================================ */
-- Utilisation du warehouse COMPUTE_WH pour les opérations suivantes
USE WAREHOUSE COMPUTE_WH;

-- Sélection du rôle app_role pour les opérations suivantes
USE ROLE app_role;

-- Sélection de la base de données health_app_db pour les opérations suivantes
USE DATABASE health_app_db;

SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
    SCHEDULED_TIME_RANGE_START=>DATEADD('hour',-1,current_timestamp())
))
WHERE schema_name = 'COMMON';