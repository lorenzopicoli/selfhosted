#!/usr/bin/with-contenv bash

echo "****** Installing wg-portal ******"
apt update
apt install golang-go -y
export PATH=$PATH:/usr/local/go/bin

git clone https://github.com/h44z/wg-portal.git /app/wg-portal-project
cd /app/wg-portal-project

make build
cp ./dist/wg-portal /app/
rm -rf /app/wg-portal-project