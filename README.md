# Pipeline de traitement des données en temps réel dans Snowflake avec Snow CLI 

___

**Objectif**

Ce projet décrit la création, la configuration et le déploiement d’une pipeline Snowflake automatisée pour :

- L’ingestion de données.

- La transformation des données.

- L’orchestration via des tasks Snowflake.

La pipeline inclut la gestion des utilisateurs, rôles, privilèges, tables, fonctions, procédures et tasks, et utilise `snow CLI` pour l’automatisation.

## Prérequis

- Compte Snowflake avec rôle ACCOUNTADMIN.

- CLI Snowflake (snow) installée sur votre environnement local.

- OpenSSL pour générer les clés RSA.

- Git (facultatif) pour cloner le projet.

## Télécharger le projet
Vous pouvez télécharger ce projet ou le cloner.
Les scripts SQL sont organisés dans les dossiers suivants :

- `sql/rbac/` : configuration des rôles et privilèges.

- `sql/ddl/` : objets de base (tables, streams, UDF, fonctions, procédures, tasks).

- `sql/dml/ : insertion de données de test et historique des tasks.

## Création de l’utilisateur de service pour CI/CD

Créer un utilisateur service pour l’automatisation (CI/CD) depuis l’interface Snowflake :

```sql
CREATE OR REPLACE USER deployment_user TYPE = SERVICE;
```

## Génération des clés RSA pour authentification

Générer une clé privée RSA et la clé publique correspondante :

```bash
# Clé privée RSA 2048 bits
openssl genpkey -algorithm RSA -out snowflake_rsa_key.p8 -pkeyopt rsa_keygen_bits:2048

# Clé publique correspondante
openssl rsa -pubout -in snowflake_rsa_key.p8 -out snowflake_rsa_public_key.pub

```
Associer la clé publique à l’utilisateur Snowflake :

```sql
ALTER USER deployment_user 
SET RSA_PUBLIC_KEY = '-----BEGIN PUBLIC KEY----- ... -----END PUBLIC KEY-----';
```

## Configuration du rôle devsecops_role

Créer le rôle `devsecops_role et lui attribuer les privilèges nécessaires pour la gestion des objets Snowflake.

Le script SQL `sql/rbac/devsecops_role.sql configure :

- La création de bases de données, utilisateurs, rôles et warehouses.

- La gestion des grants (privilèges).

- La capacité d’exécuter des tasks et de créer des intégrations.

## Configuration du fichier config.toml via Snow CLI

Utiliser le script config_snow_cli.sh pour créer la connexion avec Snowflake et générer le fichier config.toml.

**Exemple d’exécution :**

```bash
bash ./config_snow_cli.sh.sh
```
**Le fichier `config.toml` généré doit ressembler à ceci :**

```toml
[connections.default]
account = "ZDECZEM-L362471"
user = "deployment_user"
authenticator = "SNOWFLAKE_JWT"
private_key_file = "./snowflake_rsa_key.p8"
```
**Tester la connexion :**

La commande suivante permet de tester la connexion:
```bash
snow --config-file ./config.toml connection test
```
## Déploiement de la pipeline via snow_cli_commandes.sh

Le script `snow_cli_commandes.sh contient toutes les commandes nécessaires pour :

- Configurer les rôles (`devops_role`, `app_role`, `engineer_role`).

- Créer les tables, streams, UDF, fonctions et procédures.

- Déployer les tasks et activer la pipeline.

- Insérer les données de test et consulter les historiques.

**Exécution du script :**

```bash
bash ./snow_cli_commandes.sh
```

Il est possible d’exécuter les commandes ligne par ligne pour plus de contrôle ou en une seule fois pour un déploiement complet.
