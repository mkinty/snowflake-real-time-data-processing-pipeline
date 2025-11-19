snow --config-file ./config.toml sql -f sql/rbac/privileges.sql
snow --config-file ./config.toml sql -f sql/rbac/devops_role.sql
snow --config-file ./config.toml sql -f sql/rbac/app_role.sql
snow --config-file ./config.toml sql -f sql/rbac/engineer_role.sql
snow --config-file ./config.toml sql --role devops_role -f sql/ddl/01-initialisation.sql
snow --config-file ./config.toml sql --role devops_role -f sql/ddl/02-automatic_ingestion.sql
snow --config-file ./config.toml sql --role devops_role -f sql/ddl/03-tream.sql
snow --config-file ./config.toml sql --role devops_role -f sql/ddl/04-intermediaries_tables.sql
snow --config-file ./config.toml sql --role devops_role -f sql/ddl/05-udf.sql
snow --config-file ./config.toml sql --role devops_role -f sql/ddl/06-utils_functions.sql
snow --config-file ./config.toml sql --role devops_role -f sql/ddl/07-procedures.sql
snow --config-file ./config.toml sql --role app_role -f sql/ddl/08-tasks.sql
snow --config-file ./config.toml sql --role app_role -f sql/ddl/09-activation_run.sql
snow --config-file ./config.toml sql --role app_role -f sql/dml/insert_into.sql
snow --config-file ./config.toml sql --role app_role -f sql/dml/task_history.sql
