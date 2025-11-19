-- Utiliser un rôle administratif pour la configuration initiale
USE ROLE ACCOUNTADMIN;

-- S’assurer que le rôle existe
CREATE OR ALTER ROLE devsecops_role;

-- Assigner le rôle à l’utilisateur (ici, mkinty et deployment_user)
GRANT ROLE devsecops_role TO USER mkinty;
GRANT ROLE devsecops_role TO USER deployment_user;

-- Autorise le rôle devsecops_role à créer des bases de données, des utilisateurs
-- et des rôles au niveau du compte Snowflake
GRANT CREATE DATABASE, CREATE USER, CREATE ROLE ON ACCOUNT TO ROLE devsecops_role;

-- Permet au rôle devsecops_role de gérer les privilèges (GRANT/REVOKE) sur tout le compte
-- C’est une permission très puissante, équivalente à une gestion globale des accès
GRANT MANAGE GRANTS ON ACCOUNT TO ROLE devsecops_role;

-- Autorise le rôle devsecops_role à créer des warehouses au niveau du compte
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE devsecops_role;

-- Permet au rôle devsecops_role de créer des intégrations (AWS, Azure, GCP, OAuth, etc.)
-- Le GRANT OPTION permet à ce rôle de déléguer cette permission à d'autres rôles
GRANT CREATE INTEGRATION ON ACCOUNT TO ROLE devsecops_role WITH GRANT OPTION;

-- Donne au rôle devsecops_role le droit d’exécuter des tâches programmées (tasks)
-- Le GRANT OPTION permet également de transférer ce privilège à d'autres rôles
GRANT EXECUTE TASK ON ACCOUNT TO ROLE devsecops_role WITH GRANT OPTION;



