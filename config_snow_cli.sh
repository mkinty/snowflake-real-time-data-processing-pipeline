snow --config-file ./config.toml connection add \
    --connection-name default \
    --user deployment_user \
    --authenticator SNOWFLAKE_JWT \
    --private-key-file ./snowflake_rsa_key.p8 \
    --account KSTCZAM-LW62471 \
    --no-interactive