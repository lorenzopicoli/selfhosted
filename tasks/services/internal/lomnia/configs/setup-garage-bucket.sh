#!/bin/bash
echo "Garage Bucket & Key Setup"
echo "=============================="
echo ""

# Ask for container name/id
read -p "Enter Garage container name or ID (default: garage): " CONTAINER_NAME
CONTAINER_NAME=${CONTAINER_NAME:-garage}

# Check if container exists and is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  if ! docker ps --format '{{.ID}}' | grep -q "^${CONTAINER_NAME}"; then
    echo "❌ Error: Container '$CONTAINER_NAME' not found or not running"
    echo "Available running containers:"
    docker ps --format "  - {{.Names}} ({{.ID}})"
    exit 1
  fi
fi

echo "✓ Found container: $CONTAINER_NAME"
echo ""

# Check if Garage is properly configured
STATUS=$(docker exec $CONTAINER_NAME ./garage status 2>/dev/null)
if [ $? -ne 0 ]; then
  echo "❌ Error: Could not connect to Garage. Is it running?"
  exit 1
fi

if echo "$STATUS" | grep -q "NO ROLE ASSIGNED"; then
  echo "❌ Error: Garage layout is not configured yet"
  echo "Please run the layout setup script first."
  exit 1
fi

echo "✓ Garage is configured and ready"
echo ""

# Bucket Creation
echo "=============================="
echo "Bucket Setup"
echo "=============================="
echo ""

read -p "Would you like to create a bucket? (Y/n): " CREATE_BUCKET
CREATE_BUCKET=${CREATE_BUCKET:-Y}

BUCKET_NAME=""
BUCKET_ID=""

if [[ $CREATE_BUCKET =~ ^[Yy]$ ]]; then
  read -p "Enter bucket name: " BUCKET_NAME

  if [ -z "$BUCKET_NAME" ]; then
    echo "❌ Error: Bucket name cannot be empty"
    exit 1
  fi

  echo "Creating bucket '$BUCKET_NAME'..."
  BUCKET_OUTPUT=$(docker exec $CONTAINER_NAME ./garage bucket create $BUCKET_NAME 2>&1)

  if [ $? -eq 0 ]; then
    echo "✓ Bucket created successfully"
    echo "$BUCKET_OUTPUT"

    # Extract bucket ID
    BUCKET_ID=$(echo "$BUCKET_OUTPUT" | grep -i "bucket" | awk '{print $2}' | head -n1)
    echo ""
  else
    echo "❌ Error creating bucket: $BUCKET_OUTPUT"
    exit 1
  fi
else
  # List existing buckets and allow selection
  echo "Existing buckets:"
  docker exec $CONTAINER_NAME ./garage bucket list
  echo ""

  read -p "Enter existing bucket name to use (or leave empty to skip): " BUCKET_NAME
fi

echo ""

# Key Creation
echo "=============================="
echo "Access Key Setup"
echo "=============================="
echo ""

read -p "Would you like to create access keys? (Y/n): " CREATE_KEY
CREATE_KEY=${CREATE_KEY:-Y}

ACCESS_KEY=""
SECRET_KEY=""

if [[ $CREATE_KEY =~ ^[Yy]$ ]]; then
  read -p "Enter key name [default: default-key]: " KEY_NAME
  KEY_NAME=${KEY_NAME:-default-key}

  echo "Creating access key '$KEY_NAME'..."
  KEY_OUTPUT=$(docker exec $CONTAINER_NAME ./garage key create $KEY_NAME 2>&1)

  if [ $? -eq 0 ]; then
    echo "✓ Access key created successfully"
    echo ""
    echo "$KEY_OUTPUT"
    echo ""

    # Extract credentials
    ACCESS_KEY=$(echo "$KEY_OUTPUT" | grep "Key ID:" | awk '{print $3}')
    SECRET_KEY=$(echo "$KEY_OUTPUT" | grep "Secret key:" | awk '{print $3}')

  else
    echo "❌ Error creating key: $KEY_OUTPUT"
    exit 1
  fi
else
  # List existing keys and allow selection
  echo "Existing keys:"
  docker exec $CONTAINER_NAME ./garage key list
  echo ""

  read -p "Enter existing key name to use (or leave empty to skip): " KEY_NAME

  if [ -n "$KEY_NAME" ]; then
    KEY_INFO=$(docker exec $CONTAINER_NAME ./garage key info $KEY_NAME 2>&1)
    if [ $? -eq 0 ]; then
      ACCESS_KEY=$(echo "$KEY_INFO" | grep "Key ID:" | awk '{print $3}')
      SECRET_KEY=$(echo "$KEY_INFO" | grep "Secret key:" | awk '{print $3}')
    fi
  fi
fi

echo ""

# Grant bucket permissions
if [ -n "$BUCKET_NAME" ] && [ -n "$KEY_NAME" ]; then
  echo "=============================="
  echo "Grant Permissions"
  echo "=============================="
  echo ""

  read -p "Grant '$KEY_NAME' access to bucket '$BUCKET_NAME'? (Y/n): " ALLOW_BUCKET
  ALLOW_BUCKET=${ALLOW_BUCKET:-Y}

  if [[ $ALLOW_BUCKET =~ ^[Yy]$ ]]; then
    read -p "Grant read access? (Y/n): " GRANT_READ
    GRANT_READ=${GRANT_READ:-Y}

    read -p "Grant write access? (Y/n): " GRANT_WRITE
    GRANT_WRITE=${GRANT_WRITE:-Y}

    ALLOW_CMD="docker exec $CONTAINER_NAME ./garage bucket allow"

    if [[ $GRANT_READ =~ ^[Yy]$ ]]; then
      ALLOW_CMD="$ALLOW_CMD --read"
    fi

    if [[ $GRANT_WRITE =~ ^[Yy]$ ]]; then
      ALLOW_CMD="$ALLOW_CMD --write"
    fi

    ALLOW_CMD="$ALLOW_CMD $BUCKET_NAME --key $KEY_NAME"

    echo "Granting access..."
    eval $ALLOW_CMD

    if [ $? -eq 0 ]; then
      echo "✓ Access granted successfully"
    else
      echo "❌ Error granting access"
    fi
  fi
fi

echo ""

# Save credentials
if [ -n "$ACCESS_KEY" ] && [ -n "$SECRET_KEY" ]; then
  echo "=============================="
  echo "Save Credentials"
  echo "=============================="
  echo ""

  read -p "Would you like to save credentials to a file? (Y/n): " SAVE_CREDS
  SAVE_CREDS=${SAVE_CREDS:-Y}

  if [[ $SAVE_CREDS =~ ^[Yy]$ ]]; then
    read -p "Enter filename [default: garage-credentials.txt]: " CREDS_FILE
    CREDS_FILE=${CREDS_FILE:-garage-credentials.txt}

    cat > $CREDS_FILE << EOF
Garage S3 Credentials
=====================
Generated: $(date)
Container: $CONTAINER_NAME

Access Key ID: $ACCESS_KEY
Secret Access Key: $SECRET_KEY
Key Name: $KEY_NAME
Bucket Name: ${BUCKET_NAME:-N/A}
Bucket ID: ${BUCKET_ID:-N/A}
Endpoint: http://localhost:3900
Region: garage
EOF

    echo "✓ Credentials saved to: $CREDS_FILE"
    echo ""
    echo "⚠️  IMPORTANT: Keep this file secure and do not commit it to version control!"
    echo "   Add '$CREDS_FILE' to your .gitignore file"
  fi
fi

echo ""
echo "=============================="
echo "✅ Setup Complete!"
echo "=============================="
echo ""

if [ -n "$BUCKET_NAME" ]; then
  echo "Bucket: $BUCKET_NAME"
fi

if [ -n "$KEY_NAME" ]; then
  echo "Key: $KEY_NAME"
fi
