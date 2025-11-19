/* =============================================================================
   ROLE: engineer_role — Permissions d'accès aux objets Snowflake
   Objectif : Donner un accès complet des schémas en:
    - lecture sur les tables
============================================================================= */
USE ROLE devsecops_role; -- ou rôle avec privilèges de GRANT

/* =============================================================================
   UTILISATEURS : attribution du rôle engineer_role aux utilisateurs
============================================================================= */
GRANT ROLE engineer_role TO USER mkinty;

/* =============================================================================
   DATABASE : accès à la database
============================================================================= */
USE DATABASE health_app_db;
GRANT USAGE ON DATABASE health_app_db TO ROLE engineer_role;

/* =============================================================================
   DROITS SUR LES SCHEMAS (obligatoire pour accéder aux objets)
============================================================================= */
GRANT USAGE ON SCHEMA raw TO ROLE engineer_role;
GRANT USAGE ON SCHEMA staging TO ROLE engineer_role;
GRANT USAGE ON SCHEMA common TO ROLE engineer_role;
-- Pour futurs schémas si nécessaire :
GRANT USAGE ON FUTURE SCHEMAS IN DATABASE health_app_db TO ROLE engineer_role;

/* =============================================================================
   TABLES — Lecture + insertion (existantes et futures)
============================================================================= */
-- Tables existantes
GRANT SELECT ON ALL TABLES IN SCHEMA raw TO ROLE engineer_role;
GRANT SELECT ON ALL TABLES IN SCHEMA staging TO ROLE engineer_role;
GRANT SELECT ON ALL TABLES IN SCHEMA common TO ROLE engineer_role;
-- Tables futures
GRANT SELECT ON FUTURE TABLES IN SCHEMA raw TO ROLE engineer_role;
GRANT SELECT ON FUTURE TABLES IN SCHEMA staging TO ROLE engineer_role;
GRANT SELECT ON FUTURE TABLES IN SCHEMA common TO ROLE engineer_role;

/* =============================================================================
   FIN DE LA CONFIGURATION
============================================================================= */

