/* =============================================================================
   ROLE: devops_role — Permissions d'accès aux objets Snowflake
   Objectif : Donner un accès complet à tous les schémas avec tous les droits
============================================================================= */
USE ROLE devsecops_role;

/* =============================================================================
   UTILISATEURS : attribution du rôle devops_role aux utilisateurs
============================================================================= */
GRANT ROLE devops_role TO USER deployment_user;
GRANT ROLE devops_role TO USER mkinty;

/* =============================================================================
   DATABASE : accès à la database
============================================================================= */
USE DATABASE health_app_db;
GRANT USAGE ON DATABASE health_app_db TO ROLE devops_role;

/* =============================================================================
   DROITS SUR LES SCHEMAS : avoir tous les droits
============================================================================= */
GRANT ALL ON SCHEMA raw TO ROLE devops_role;
GRANT ALL ON SCHEMA staging TO ROLE devops_role;
GRANT ALL ON SCHEMA common TO ROLE devops_role;

/* =============================================================================
   WAREHOUSE — Nécessaire pour exécuter des tasks & procédures
============================================================================= */
GRANT USAGE, OPERATE ON WAREHOUSE COMPUTE_WH TO ROLE devops_role;

/* =============================================================================
   FIN DE LA CONFIGURATION
============================================================================= */

