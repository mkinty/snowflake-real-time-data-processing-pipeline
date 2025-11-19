/* =============================================================================================
    TABLES INTERMÉDIAIRES, DE LOGS ET D'ANALYSES
================================================================================================ */
-- Sélection du rôle devops_role pour les opérations suivantes
USE ROLE devops_role;

-- Sélection de la base de données health_app_db pour les opérations suivantes
USE DATABASE health_app_db;

-- Table temporaire/ponctuelle pour emprunter des données depuis le stream
-- avant enrichissement. Peut être vidée après chaque run.
CREATE OR ALTER TABLE common.data_to_process (
    event_id NUMBER,
    event_timestamp TIMESTAMP,
    process_name STRING,
    process_id NUMBER,
    message STRING
);

-- Table de logs (audit des étapes) ; useful pour debug et SLA.
CREATE OR ALTER TABLE common.logging (
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    graph_run_group_id STRING,
    table_name STRING,
    n_rows NUMBER,
    error_message STRING DEFAULT NULL
);

-- Table listant anomalies détectées lors du contrôle qualité.
CREATE OR ALTER TABLE common.data_anomalies (
    event_id NUMBER,
    is_correct_timestamp BOOLEAN,
    is_correct_process_name BOOLEAN,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    graph_run_group_id STRING
);

-- Table pour les arrivées tardives (données avec +5 jours de retard)
CREATE OR ALTER TABLE common.data_late_arrivals (
    event_id INT,
    is_late_arrival_timestamp BOOLEAN,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    graph_run_group_id STRING
);

-- staging tables: Création des tables à partire des process_name
CREATE OR ALTER TABLE staging.hih_listener_manager (
    event_timestamp TIMESTAMP,
    log_trigger STRING,
    process_id NUMBER,
    message STRING
);

CREATE OR ALTER TABLE staging.hih_hi_broadcast_util (
    event_timestamp TIMESTAMP,
    log_trigger STRING,
    process_id NUMBER,
    message STRING
);

CREATE OR ALTER TABLE staging.step_stand_step_counter (
    event_timestamp TIMESTAMP,
    log_trigger STRING,
    process_id NUMBER,
    message STRING
);

CREATE OR ALTER TABLE staging.step_sp_utils (
    event_timestamp TIMESTAMP,
    log_trigger STRING,
    process_id NUMBER,
    message STRING
);

CREATE OR ALTER TABLE staging.step_lsc (
    event_timestamp TIMESTAMP,
    log_trigger STRING,
    process_id NUMBER,
    message STRING
);

CREATE OR ALTER  TABLE staging.hih_hi_health_data_insert_store (
    event_timestamp TIMESTAMP,
    log_trigger STRING,
    process_id NUMBER,
    message STRING
);

CREATE OR ALTER TABLE staging.hih_data_stat_manager (
    event_timestamp TIMESTAMP,
    log_trigger STRING,
    process_id NUMBER,
    message STRING
);

CREATE OR ALTER  TABLE staging.hih_hi_sync_util (
    event_timestamp TIMESTAMP,
    log_trigger STRING,
    process_id NUMBER,
    message STRING
);

CREATE OR ALTER  TABLE staging.step_stand_report_receiver (
    event_timestamp TIMESTAMP,
    log_trigger STRING,
    process_id NUMBER,
    message STRING
);

CREATE OR ALTER TABLE staging.step_screen_util (
    event_timestamp TIMESTAMP,
    log_trigger STRING,
    process_id NUMBER,
    message STRING
);

-- Statut global du pipeline
CREATE OR ALTER TABLE common.transformation_pipline_status (
    graph_run_group_id STRING,
    started_at TIMESTAMP,
    finished_at TIMESTAMP,
    status STRING
);