#!/bin/sh
set -eu

template_path="${TFS_CONFIG_TEMPLATE:-/opt/tfs/config.lua.template}"
config_path="${TFS_CONFIG_PATH:-/opt/tfs/config.lua}"

cp "$template_path" "$config_path"

set_config_string() {
  key="$1"
  value="$2"
  escaped_value=$(printf '%s' "$value" | sed 's/[\/&]/\\&/g')
  sed -i "s/^${key} = \".*\"$/${key} = \"${escaped_value}\"/" "$config_path"
}

set_config_number() {
  key="$1"
  value="$2"
  sed -i "s/^${key} = .*$/${key} = ${value}/" "$config_path"
}

if [ "${TFS_DB_HOST:-}" ]; then
  set_config_string "mysqlHost" "$TFS_DB_HOST"
fi

if [ "${TFS_DB_USER:-}" ]; then
  set_config_string "mysqlUser" "$TFS_DB_USER"
fi

if [ "${TFS_DB_PASS:-}" ]; then
  set_config_string "mysqlPass" "$TFS_DB_PASS"
fi

if [ "${TFS_DB_NAME:-}" ]; then
  set_config_string "mysqlDatabase" "$TFS_DB_NAME"
fi

if [ "${TFS_DB_PORT:-}" ]; then
  set_config_number "mysqlPort" "$TFS_DB_PORT"
fi

if [ "${TFS_SERVER_IP:-}" ]; then
  set_config_string "ip" "$TFS_SERVER_IP"
fi

if [ "${TFS_SERVER_NAME:-}" ]; then
  set_config_string "serverName" "$TFS_SERVER_NAME"
fi

if [ "${TFS_LOGIN_PORT:-}" ]; then
  set_config_number "loginProtocolPort" "$TFS_LOGIN_PORT"
  set_config_number "statusProtocolPort" "$TFS_LOGIN_PORT"
fi

if [ "${TFS_GAME_PORT:-}" ]; then
  set_config_number "gameProtocolPort" "$TFS_GAME_PORT"
fi

exec "$@"
