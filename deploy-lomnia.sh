#!/usr/bin/env bash

set -euo pipefail

# ---- Hardcoded config ----
DB_HOST="192.168.40.35"
DB_PORT="5432"
DB_NAME="lomnia"
DB_USER="lomnia"

BACKUP_DIR="$HOME/lomnia-backup"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${TIMESTAMP}.dump"

ANSIBLE_PLAYBOOK="lomnia.yml"
ANSIBLE_INVENTORY="inventory.yml"

# ---- Ensure backup directory exists ----
mkdir -p "$BACKUP_DIR"

# ---- Ask for DB password securely ----
read -s -p "Postgres password for user '$DB_USER': " PGPASSWORD
echo
export PGPASSWORD

# ---- Run pg_dump ----
echo "Running pg_dump..."
pg_dump \
  -h "$DB_HOST" \
  -p "$DB_PORT" \
  -U "$DB_USER" \
  -F c \
  -f "$BACKUP_FILE" \
  "$DB_NAME"

echo "Backup saved to: $BACKUP_FILE"

# ---- Unset password ASAP ----
unset PGPASSWORD

# ---- Run ansible ----
echo "Running ansible-playbook..."
ansible-playbook "$ANSIBLE_PLAYBOOK" \
  --inventory="$ANSIBLE_INVENTORY" \
  -vvv \
  --ask-vault-pass \
  -b

echo "All done ✅"
