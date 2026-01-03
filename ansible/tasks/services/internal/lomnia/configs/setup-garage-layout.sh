#!/bin/bash

echo "Garage Layout Setup Wizard"
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

# Get current status
echo "Fetching cluster status..."
STATUS=$(docker exec $CONTAINER_NAME ./garage status 2>/dev/null)

if [ $? -ne 0 ]; then
  echo "❌ Error: Could not connect to Garage. Is it running?"
  exit 1
fi

echo "$STATUS"
echo ""

# Check if already configured
if echo "$STATUS" | grep -q "NO ROLE ASSIGNED"; then
  echo "ℹ️  Layout not configured yet"
else
  read -p "⚠️  Layout appears to be already configured. Continue anyway? (y/N): " CONTINUE
  if [[ ! $CONTINUE =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi
fi

echo ""

# Get node ID
NODE_ID=$(echo "$STATUS" | grep -v "^ID" | grep -v "^$" | grep -v "^===" | awk '{print $1}' | head -n1)

if [ -z "$NODE_ID" ]; then
  echo "❌ Error: Could not extract node ID"
  exit 1
fi

echo "Node ID detected: $NODE_ID"
echo ""

# Ask for parameters
read -p "Enter storage capacity (e.g., 10G, 100G, 1T) [default: 100G]: " CAPACITY
CAPACITY=${CAPACITY:-100G}

read -p "Enter zone name [default: dc1]: " ZONE
ZONE=${ZONE:-dc1}

read -p "Enter replication factor (1 or 3) [default: 1]: " REPLICATION
REPLICATION=${REPLICATION:-1}

echo ""
echo "Configuration Summary:"
echo "======================"
echo "Container:    $CONTAINER_NAME"
echo "Node ID:      $NODE_ID"
echo "Capacity:     $CAPACITY"
echo "Zone:         $ZONE"
echo "Replication:  $REPLICATION"
echo ""

read -p "Proceed with this configuration? (y/N): " CONFIRM

if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

echo ""
echo "Applying layout configuration..."

# Assign layout
docker exec $CONTAINER_NAME ./garage layout assign -z $ZONE -c $CAPACITY $NODE_ID

if [ $? -ne 0 ]; then
  echo "❌ Error: Failed to assign layout"
  exit 1
fi

echo "✓ Layout assigned"
echo ""

# Get current layout version
CURRENT_VERSION=$(docker exec $CONTAINER_NAME ./garage layout show 2>/dev/null | grep "Current cluster layout version:" | awk '{print $5}')

if [ -z "$CURRENT_VERSION" ]; then
  LAYOUT_VERSION=1
else
  LAYOUT_VERSION=$((CURRENT_VERSION + 1))
fi

echo "Applying layout version $LAYOUT_VERSION..."

# Apply layout
docker exec $CONTAINER_NAME ./garage layout apply --version $LAYOUT_VERSION

if [ $? -ne 0 ]; then
  echo "❌ Error: Failed to apply layout"
  exit 1
fi

echo ""
echo "✅ Garage layout configured successfully!"
echo ""
echo "Next steps:"
echo "  • Create a bucket: docker exec $CONTAINER_NAME garage bucket create my-bucket"
echo "  • Create keys: docker exec $CONTAINER_NAME garage key create my-key"
echo "  • Check status: docker exec $CONTAINER_NAME garage status"
