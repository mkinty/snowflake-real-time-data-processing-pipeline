/* =============================================================================================
    FONCTIONS UDF(User-Defined Functions) pour parsing (Python UDF)
      REMARQUE :
        - L'utilisation de Python UDF nécessite que l'account ait des permissions
        - et que la runtime 3.12 soit disponible.
================================================================================================ */
-- Sélection du rôle devops_role pour les opérations suivantes
USE ROLE devops_role;

-- Sélection de la base de données health_app_db pour les opérations suivantes
USE DATABASE health_app_db;

-- selection du warehouse
USE WAREHOUSE COMPUTE_WH;

-- Extraction du "log trigger" (ex: 'onStandStepChanged' ou clef)
CREATE OR REPLACE FUNCTION common.extract_log_trigger(message STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.12'
HANDLER = 'extract_log_trigger'
AS $$
def extract_log_trigger(message: str):
    return message.strip().split(" ")[0].split(":")[0].split("=")[0].strip()
$$;

-- Extraction du message sans le trigger
CREATE OR REPLACE FUNCTION common.extract_log_message(message STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.12'
HANDLER = 'extract_log_trigger'
AS $$
def extract_log_trigger(message: str):
    msg_trigger = message.strip().split(" ")[0].split(":")[0].split("=")[0].strip()
    return message.replace(msg_trigger, "").strip()
$$;

