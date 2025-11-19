/* =============================================================================================
    STREAM SUR LA TABLE RAW
      - Détecte les nouvelles lignes pour le pipeline
================================================================================================ */
-- Sélection du rôle devops_role pour les opérations suivantes
USE ROLE devops_role;

-- Sélection de la base de données health_app_db pour les opérations suivantes
USE DATABASE health_app_db;

CREATE OR REPLACE STREAM raw.raw_events_stream
ON TABLE raw.raw_events
APPEND_ONLY = TRUE;






