#!/bin/bash
set -e

if ! command -v keytool &> /dev/null; then
    echo "Error: keytool not found. Install Java JDK first."
    exit 1
fi

if [ ! -f "keystore.properties" ]; then
    echo "Error: keystore.properties not found. Create it from keystore.properties.template"
    exit 1
fi

. keystore.properties
mkdir -p keystore

echo "Generating keystore..."
keytool -genkey -v \
  -keystore ${storeFile} \
  -keyalg RSA \
  -keysize 2048 \
  -validity ${validity}000 \
  -alias ${alias} \
  -dname "CN=${name}, OU=${organizationalUnit}, O=${organization}, L=${city}, ST=${state}, C=${country}" \
  -storetype JKS \
  -storepass ${storePassword} \
  -keypass ${keyPassword}

echo "Keystore generated at: ${storeFile}"
echo "Back it up and never commit it to version control!"
