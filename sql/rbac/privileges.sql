/* =============================================================================
   ROLE: devsecops_role — Permissions d'accès aux objets Snowflake
   Objectif : donner à ce rôle des droits d'administration sur les objets du compte Snowflake
============================================================================= */

-- Utiliser le rôle devsecops_role pour les opérations suivantes
USE ROLE devsecops_role;

/* =============================================================================
   DROITS SUR LES DATABASES: droits de : créer, utiliser et accéder
============================================================================= */
CREATE OR ALTER DATABASE health_app_db;
USE DATABASE health_app_db;
GRANT USAGE ON DATABASE health_app_db TO ROLE devsecops_role;

/* =============================================================================
   DROITS SUR LES SCHEMAS : droits de créer, utiliser et accéder
============================================================================= */
-- Droit de créer les schémas
GRANT CREATE SCHEMA ON DATABASE health_app_db TO ROLE devsecops_role;

-- Création ou modification des schémas
CREATE OR ALTER SCHEMA raw;
CREATE OR ALTER SCHEMA staging;
CREATE OR ALTER SCHEMA common;

-- Droit d'utiliser les schémas
GRANT USAGE ON SCHEMA raw TO ROLE devsecops_role;
GRANT USAGE ON SCHEMA staging TO ROLE devsecops_role;
GRANT USAGE ON SCHEMA common TO ROLE devsecops_role;

-- Création (ou modification) des rôle:  devops_role, app_role, engineer_role
CREATE OR ALTER ROLE devops_role;
CREATE OR ALTER ROLE app_role;
CREATE OR ALTER ROLE engineer_role;

/* =============================================================================
   WAREHOUSE — Nécessaire pour exécuter des tasks & procédures
============================================================================= */
GRANT USAGE, OPERATE ON WAREHOUSE COMPUTE_WH TO ROLE devsecops_role;


/* =============================================================================
   FIN DE LA CONFIGURATION
============================================================================= */