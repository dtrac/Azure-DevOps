#!/bin/bash

# ==== Config ====
RESOURCE_GROUP="dant-rg-01"
LOCATION="swedencentral"
STORAGE_ACCOUNT="squidproxy$RANDOM$RANDOM"
SHARE_NAME="squidconfig"
ACI_NAME="squidproxy"
LOCAL_CONFIG_DIR="./squid_conf"

# ==== Step 1: Create Azure resources ====
echo "Creating resource group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

echo "Creating storage account: $STORAGE_ACCOUNT..."
az storage account create --name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP --sku Standard_LRS

echo "Fetching storage key..."
STORAGE_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT --query '[0].value' -o tsv)

echo "Creating file share..."
az storage share create --account-name $STORAGE_ACCOUNT --account-key $STORAGE_KEY --name $SHARE_NAME

echo "Uploading config files from $LOCAL_CONFIG_DIR..."
az storage file upload-batch \
  --account-name $STORAGE_ACCOUNT \
  --account-key $STORAGE_KEY \
  --destination $SHARE_NAME \
  --source $LOCAL_CONFIG_DIR

# ==== Step 2: Deploy Squid container ====
echo "Deploying Squid proxy container..."
az container create \
  --resource-group $RESOURCE_GROUP \
  --name $ACI_NAME \
  --image ubuntu/squid \
  --ports 3128 \
  --ip-address public \
  --azure-file-volume-account-name $STORAGE_ACCOUNT \
  --azure-file-volume-account-key $STORAGE_KEY \
  --azure-file-volume-share-name $SHARE_NAME \
  --azure-file-volume-mount-path /etc/squid \
  --restart-policy Always

# ==== Step 3: Output Public IP ====
echo "Fetching public IP..."
PROXY_IP=$(az container show --resource-group $RESOURCE_GROUP --name $ACI_NAME --query ipAddress.ip -o tsv)

echo ""
echo " Squid proxy is live!"
echo " Proxy address: http://$PROXY_IP:3128"
echo " Whitelist is mounted from Azure Files and can be updated by re-uploading to:"
echo "   https://portal.azure.com > Storage Accounts > $STORAGE_ACCOUNT > File shares > $SHARE_NAME"
