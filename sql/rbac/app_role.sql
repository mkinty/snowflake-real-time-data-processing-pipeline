/* =============================================================================
   ROLE: app_role — Permissions d'accès aux objets Snowflake
   Objectif : Donner un accès complet des schémas en:
    - lecture sur les tables, fonctions et procédures,
    - écriture les tables et streams,
    - exécution sur tasks.
============================================================================= */
USE ROLE devsecops_role; -- ou rôle avec privilèges de GRANT

/* =============================================================================
   UTILISATEURS : attribution du rôle app_role aux utilisateurs
============================================================================= */
GRANT ROLE app_role TO USER deployment_user;
GRANT ROLE app_role TO USER mkinty;

/* =============================================================================
   DATABASE : accès à la database
============================================================================= */
USE DATABASE health_app_db;
GRANT USAGE ON DATABASE health_app_db TO ROLE app_role;

/* =============================================================================
   DROITS SUR LES SCHEMAS (obligatoire pour accéder aux objets)
============================================================================= */
GRANT USAGE ON SCHEMA raw TO ROLE app_role;
GRANT USAGE ON SCHEMA staging TO ROLE app_role;
GRANT USAGE ON SCHEMA common TO ROLE app_role;
-- Pour futurs schémas si nécessaire :
GRANT USAGE ON FUTURE SCHEMAS IN DATABASE health_app_db TO ROLE app_role;

/* =============================================================================
   TABLES — Lecture + insertion (existantes et futures)
============================================================================= */
-- Tables existantes
GRANT SELECT, INSERT ON ALL TABLES IN SCHEMA raw TO ROLE app_role;
GRANT SELECT, INSERT ON ALL TABLES IN SCHEMA staging TO ROLE app_role;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA common TO ROLE app_role;
-- Tables futures
GRANT SELECT, INSERT ON FUTURE TABLES IN SCHEMA raw TO ROLE app_role;
GRANT SELECT, INSERT ON FUTURE TABLES IN SCHEMA staging TO ROLE app_role;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES IN SCHEMA common TO ROLE app_role;
/* =============================================================================
   STREAMS — Lecture (existants et futurs)
============================================================================= */
GRANT SELECT ON ALL STREAMS IN SCHEMA raw TO ROLE app_role;
GRANT SELECT ON FUTURE STREAMS IN SCHEMA raw TO ROLE app_role;

/* =============================================================================
   FUNCTIONS — Usage + exécution (existantes et futures)
============================================================================= */
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA common TO ROLE app_role;
GRANT USAGE ON FUTURE FUNCTIONS IN SCHEMA common TO ROLE app_role;


/* =============================================================================
   PROCEDURES — Exécution (existantes et futures)
============================================================================= */
GRANT USAGE ON ALL PROCEDURES IN SCHEMA common TO ROLE app_role;
GRANT USAGE ON FUTURE PROCEDURES IN SCHEMA common TO ROLE app_role;

/* =============================================================================
   TASKS — Usage + exécution (existantes et futures)
============================================================================= */
GRANT CREATE TASK ON SCHEMA common TO ROLE app_role;
GRANT EXECUTE TASK ON ACCOUNT TO ROLE app_role;

/* =============================================================================
   WAREHOUSE — Nécessaire pour exécuter des tasks & procédures
============================================================================= */
GRANT USAGE, OPERATE ON WAREHOUSE COMPUTE_WH TO ROLE app_role;

/* =============================================================================
   FIN DE LA CONFIGURATION
============================================================================= */

-- afficher les privileges du app_role
SHOW GRANTS TO ROLE app_role;

