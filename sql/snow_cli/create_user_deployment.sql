-- Création d’un utilisateur de service pour CI/CD
CREATE
OR REPLACE USER deployment_user TYPE = SERVICE;

-- Associer la clé publique à l'utilisateur de service
ALTER USER deployment_user
SET
    RSA_PUBLIC_KEY = '-----BEGIN PUBLIC KEY----- ... -----END PUBLIC KEY-----';
