/* =============================================================================================
    INITIALISATION
      - Table brute d’ingestion
================================================================================================ */
-- Sélection du rôle devops_role pour les opérations suivantes
USE ROLE devops_role;

-- Sélection de la base de données health_app_db pour les opérations suivantes
USE DATABASE health_app_db;

-- Table brute recevant les événements entrants
CREATE OR ALTER TABLE raw.raw_events (
    event_timestamp TIMESTAMP,
    process_name STRING,
    process_id NUMBER,
    message STRING,
    event_id NUMBER AUTOINCREMENT
);
