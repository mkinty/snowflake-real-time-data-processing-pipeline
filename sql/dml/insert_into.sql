/* =============================================================================================
    TESTS (exemples) : Insertion / observation
================================================================================================ */
-- Utilisation du warehouse COMPUTE_WH pour les opérations suivantes
USE WAREHOUSE COMPUTE_WH;

-- Sélection du rôle app_role pour les opérations suivantes
USE ROLE app_role;

-- Sélection de la base de données health_app_db pour les opérations suivantes
USE DATABASE health_app_db;

-- Exemple d'insertion manuelle pour tester le pipeline (timestamp passé, futur, présent)
INSERT INTO raw.raw_events (event_timestamp, process_name, process_id, message)
VALUES ('2017-12-23 22:15:29.606'::TIMESTAMP, 'Step_LSC', 30002312, 'onStandStepChanged 3579'),
('2025-12-23 22:15:29.606'::TIMESTAMP, 'Step_LSC', 30002312, 'onStandStepChanged 3579'),
(CURRENT_TIMESTAMP(), 'Step_LSC', 30002313, 'onStandStepChanged 4000');

SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
    SCHEDULED_TIME_RANGE_START=>DATEADD('hour',-1,current_timestamp())
))
WHERE schema_name = 'COMMON';