#!/bin/sh

function set_config_string() {
    sed -i "s/\(${1//\//\\/} *= *\).*/\1\"${2//\//\\/}\"/" $3
}

function set_config_object() {
    sed -i "s/\(${1//\//\\/} *= *\).*/\1${2//\//\\/}/" $3
}

if [[ -z "${BITCOIN_RPC_ADDRESS}" ]]; then
    echo "BITCOIN_RPC_ADDRESS env not set."
    exit 1
fi

if [[ -z "${BITCOIN_RPC_PORT}" ]]; then
    echo "BITCOIN_RPC_PORT env not set."
    exit 1
fi

if [[ -z "${ETH_RCP_ADDRESS}" ]]; then
    echo "ETH_RCP_ADDRESS env not set."
    exit 1
fi

if [[ -z "${ETH_RPC_PORT}" ]]; then
    echo "ETH_RPC_PORT env not set."
    exit 1
fi

if [[ -z "${CONTRACT_ADDRESS}" ]]; then
    echo "CONTRACT_ADDRESS env not set."
    exit 1
fi

if [[ -z "${OPERATOR_PRIVATE_KEY}" ]]; then
    echo "OPERATOR_PRIVATE_KEY env not set."
    exit 1
fi

if [[ -z "${ETH_CHAIN_ID}" ]]; then
    echo "ETH_CHAIN_ID env not set."
    exit 1
fi

CORE_CONFIG_FILE="./relay/config/.conf.env"
set_config_object "SUMMA_RELAY_BCOIN_HOST" 127.0.0.1 $CORE_CONFIG_FILE
set_config_object "SUMMA_RELAY_BCOIN_PORT" 7070 $CORE_CONFIG_FILE
set_config_object "SUMMA_RELAY_ETHER_HOST" 127.0.0.1 $CORE_CONFIG_FILE
set_config_object "SUMMA_RELAY_ETHER_PORT" 6060 $CORE_CONFIG_FILE

set_config_object "SUMMA_RELAY_CONTRACT" $CONTRACT_ADDRESS $CORE_CONFIG_FILE
set_config_object "SUMMA_RELAY_OPERATOR_KEY" $OPERATOR_PRIVATE_KEY $CORE_CONFIG_FILE
set_config_object "SUMMA_RELAY_ETH_CHAIN_ID" $ETH_CHAIN_ID $CORE_CONFIG_FILE

cd proxy
TARGET_URL=$ETH_RCP_ADDRESS \
TARGET_PORT=$ETH_RPC_PORT \
PROXY_PORT=6060 \
HTTP_MODE=1 \
MATCH_REQUESTS=0 \
MUTE_LOGGING=0 \
pm2 start eth.js --name eth-rsk-proxy

TARGET_URL=$BITCOIN_RPC_ADDRESS \
TARGET_PORT=$BITCOIN_RPC_PORT \
TARGET_USERNAME="user" \
TARGET_PASSWORD="password" \
PROXY_PORT=7070 \
MATCH_REQUESTS=0 \
MUTE_LOGGING=0 \
pm2 start btc.js --name btc-rsk-proxy
cd ..

cat ./relay/config/.conf.env

./run.sh
