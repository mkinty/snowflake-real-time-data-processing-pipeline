/* =============================================================================================
    PROCEDURES STOCKÉES (ordre d'exécution dépendant)
    Remarques générales :
        - Les procédures journalisent systématiquement via common.log_results
        - Elles utilisent SYSTEM$TASK_RUNTIME_INFO dans les tasks pour récupérer graph_run_group_id.
================================================================================================ */
-- Sélection du rôle devops_role pour les opérations suivantes
USE ROLE devops_role;

-- Sélection de la base de données health_app_db pour les opérations suivantes
USE DATABASE health_app_db;

-- 7.1 Procédure d'insertion dans la table de logs
CREATE OR REPLACE PROCEDURE common.log_results(graph_run_group_id STRING, table_name STRING, n_rows NUMBER, error_message STRING)
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
INSERT INTO common.logging (graph_run_group_id, table_name, n_rows, error_message)
VALUES (:graph_run_group_id, :table_name, :n_rows, :error_message);
$$;

-- 7.2 Identification des nouvelles données depuis le stream
CREATE OR REPLACE PROCEDURE common.identify_new_data(graph_run_group_id STRING)
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
DECLARE
    insert_exception EXCEPTION (-20001, 'Exception in data loading into common.data_to_process table');
BEGIN
    LET n_rows INT := 0;
    -- Copie depuis le stream (CDC) vers data_to_process
    INSERT INTO common.data_to_process (event_id, event_timestamp, process_name, process_id, message)
    WITH source AS (
        SELECT event_id, event_timestamp, process_name, process_id, message
        FROM raw.raw_events_stream
    )
    SELECT * FROM source;
    n_rows := SQLROWCOUNT;
    CALL common.log_results(:graph_run_group_id, 'common.data_to_process', :n_rows, NULL);
EXCEPTION
    WHEN OTHER THEN
        CALL common.log_results(:graph_run_group_id, 'common.data_to_process', NULL, :SQLERRM);
        RAISE insert_exception;
    RETURN :n_rows;
END;
$$;

-- 7.3 Contrôle qualité (détecte anomalies)
CREATE OR REPLACE PROCEDURE common.data_quality(graph_run_group_id STRING)
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
BEGIN
    LET number_of_incorrect_lines INT := 0;
    INSERT INTO common.data_anomalies (event_id, is_correct_timestamp, is_correct_process_name, graph_run_group_id)
    WITH source AS (
        SELECT
            event_id,
            common.check_correct_timestamp(event_timestamp) AS is_correct_timestamp,
            common.check_correct_process_name(process_name) AS is_correct_process_name
        FROM common.data_to_process
    )
    SELECT *, :graph_run_group_id
    FROM source
    WHERE is_correct_timestamp = FALSE OR is_correct_process_name = FALSE;
    number_of_incorrect_lines := SQLROWCOUNT;
    RETURN :number_of_incorrect_lines;
END;
$$;

-- 7.4 Timeliness: identifie arrivées tardives (> 5 jours)
CREATE OR REPLACE PROCEDURE common.data_timeliness(graph_run_group_id STRING)
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
BEGIN
    LET nb_late_arrivals INT := 0;
    INSERT INTO common.data_late_arrivals (event_id, is_late_arrival_timestamp, graph_run_group_id)
    WITH
        source AS
            (SELECT
                dtp.event_id,
                common.check_late_arrival_timestamp(dtp.event_timestamp) AS is_late_arrival_timestamp
            FROM common.data_to_process dtp
            LEFT JOIN common.data_anomalies da
            ON dtp.event_id = da.event_id
            WHERE da.event_id IS NULL
            )
    SELECT event_id, is_late_arrival_timestamp, :graph_run_group_id AS graph_run_group_id
    FROM source
    WHERE is_late_arrival_timestamp = TRUE;
    nb_late_arrivals := SQLROWCOUNT;
    RETURN :nb_late_arrivals;
END;
$$;

-- 7.5 Enrichissement des données : insertion dans les tables de staging
CREATE OR REPLACE PROCEDURE common.enrich_data(table_name STRING, process_name STRING, graph_run_group_id STRING)
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
DECLARE
    full_table_name STRING := CONCAT('staging.', :table_name);
    insert_exception EXCEPTION (-20002, 'Exception in data loading into staging tables');
BEGIN
    LET n_rows INT := 0;
    INSERT INTO IDENTIFIER(:full_table_name) (event_timestamp, process_id, log_trigger, message)
    WITH
        source AS
            (SELECT
                dtp.event_timestamp,
                dtp.process_id,
                common.extract_log_trigger(dtp.message) AS log_trigger,
                common.extract_log_message(dtp.message) as message
            FROM common.data_to_process dtp
            LEFT JOIN common.data_anomalies da
            ON dtp.event_id = da.event_id
            LEFT JOIN common.data_late_arrivals dla
            ON dtp.event_id = dla.event_id
            WHERE dtp.process_name = :process_name
          AND da.event_id IS NULL           -- exclure anomalies
          AND dla.event_id IS NULL          -- exclure late arrivals
            )
    SELECT
        event_timestamp,
        process_id,
        log_trigger,
        message
    FROM source;
    n_rows := SQLROWCOUNT;
    -- Log du succès
    CALL common.log_results(:graph_run_group_id, :table_name, :n_rows, NULL);
    -- Gestion des erreurs
    EXCEPTION
        WHEN OTHER THEN
            -- Enregistrement de l’erreur dans common.logging
            CALL common.log_results(:graph_run_group_id, :table_name, NULL, :SQLERRM);
            -- Relancer une erreur explicite
            RAISE insert_exception;
    RETURN :n_rows;
END;
$$;

-- 7.6 Finalisation du pipeline : état et nettoyage
CREATE OR REPLACE PROCEDURE common.finalize_transformation(graph_run_group_id STRING, started_at STRING)
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
DECLARE
    pipeline_exception EXCEPTION (-20003, 'Exception in the transformation pipeline');
BEGIN
    LET n_errors INT := 0;
    SELECT COUNT(*) INTO n_errors
    FROM common.logging
    WHERE graph_run_group_id = :graph_run_group_id AND error_message IS NOT NULL;

    INSERT INTO common.transformation_pipline_status (graph_run_group_id, started_at, finished_at, status)
    SELECT
        :graph_run_group_id,
        :started_at,
        CURRENT_TIMESTAMP(),
        IFF(:n_errors > 0, 'FAILED', 'SUCCEEDED');

    IF (:n_errors = 0) THEN
        TRUNCATE TABLE common.data_to_process;
    ELSE
        RAISE pipeline_exception;
    END IF;
END;
$$;