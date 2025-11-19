/* =============================================================================================
    INGESTION AUTOMATIQUE
      - Format de fichier CSV
      - Stage interne Snowflake
      - Pipe auto_ingest (nécessite notifications externes)
================================================================================================ */
-- Sélection du rôle devops_role pour les opérations suivantes
USE ROLE devops_role;

-- Sélection de la base de données health_app_db pour les opérations suivantes
USE DATABASE health_app_db;

-- Format CSV
CREATE OR ALTER FILE FORMAT raw.csv_file
TYPE = CSV
FIELD_DELIMITER = '|'
TIMESTAMP_FORMAT = 'YYYYMMDD-HH24:MI:SS:FF3';

-- Stage interne
CREATE OR ALTER STAGE raw.internal_stage
FILE_FORMAT = raw.csv_file;

-- Pipe d’ingestion automatique (auto_ingest)
CREATE OR REPLACE PIPE raw.load_raw_data
  AUTO_INGEST = TRUE
  AS
    COPY INTO raw.raw_events (event_timestamp, process_name, process_id, message)
    FROM
    (SELECT
        $1 AS event_timestamp,
        $2 AS process_name,
        $3 AS process_id,
        $4 AS message
    FROM @raw.internal_stage)
  FILE_FORMAT = raw.csv_file;