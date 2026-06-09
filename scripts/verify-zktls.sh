#!/usr/bin/env bash
set -euo pipefail

ADMIN_SLOT="0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103"
ZERO_ADDRESS="0x0000000000000000000000000000000000000000"

CHAIN="${CHAIN:-bsc}"
TIMELOCK_MIN_DELAY="${TIMELOCK_MIN_DELAY:-86400}"

required_env() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "Missing required env: ${name}" >&2
    exit 1
  fi
}

verify_contract() {
  local address="$1"
  local contract="$2"
  local constructor_args="${3:-}"

  local args=(
    verify-contract
    "$address"
    "$contract"
    --chain "$CHAIN"
    --verifier etherscan
    --etherscan-api-key "$ETHERSCAN_API_KEY"
    --via-ir
    --num-of-optimizations 200
    --watch
  )

  if [[ -n "$constructor_args" ]]; then
    args+=(--constructor-args "$constructor_args")
  fi

  forge "${args[@]}"
}

address_from_storage_word() {
  local word="$1"
  echo "0x${word: -40}"
}

required_env ETHERSCAN_API_KEY
required_env LOGIC_ADDRESS
required_env TIMELOCK_ADDRESS
required_env PROXY_ADDRESS
required_env MULTISIG_ADDRESS
required_env ATTESTOR_1_ADDRESS
required_env ATTESTOR_1_URL
required_env ATTESTOR_2_ADDRESS
required_env ATTESTOR_2_URL
required_env ATTESTOR_3_ADDRESS
required_env ATTESTOR_3_URL

if [[ -z "${PROXY_ADMIN_ADDRESS:-}" ]]; then
  required_env RPC_URL
  PROXY_ADMIN_ADDRESS="$(address_from_storage_word "$(cast storage "$PROXY_ADDRESS" "$ADMIN_SLOT" --rpc-url "$RPC_URL")")"
fi

INITIAL_ATTESTORS="[($ATTESTOR_1_ADDRESS,$ATTESTOR_1_URL),($ATTESTOR_2_ADDRESS,$ATTESTOR_2_URL),($ATTESTOR_3_ADDRESS,$ATTESTOR_3_URL)]"
INITIALIZE_DATA="$(cast calldata "initialize(address,(address,string)[])" "$TIMELOCK_ADDRESS" "$INITIAL_ATTESTORS")"

TIMELOCK_ARGS="$(
  cast abi-encode \
    "constructor(uint256,address[],address[],address)" \
    "$TIMELOCK_MIN_DELAY" \
    "[$MULTISIG_ADDRESS]" \
    "[$ZERO_ADDRESS]" \
    "$MULTISIG_ADDRESS"
)"

PROXY_ARGS="$(
  cast abi-encode \
    "constructor(address,address,bytes)" \
    "$LOGIC_ADDRESS" \
    "$TIMELOCK_ADDRESS" \
    "$INITIALIZE_DATA"
)"

PROXY_ADMIN_ARGS="$(cast abi-encode "constructor(address)" "$TIMELOCK_ADDRESS")"

echo "Verifying PrimusZKTLS implementation: $LOGIC_ADDRESS"
verify_contract "$LOGIC_ADDRESS" "src/PrimusZKTLS.sol:PrimusZKTLS"

echo "Verifying TimelockController: $TIMELOCK_ADDRESS"
verify_contract \
  "$TIMELOCK_ADDRESS" \
  "lib/openzeppelin-contracts/contracts/governance/TimelockController.sol:TimelockController" \
  "$TIMELOCK_ARGS"

echo "Verifying TransparentUpgradeableProxy: $PROXY_ADDRESS"
verify_contract \
  "$PROXY_ADDRESS" \
  "lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol:TransparentUpgradeableProxy" \
  "$PROXY_ARGS"

echo "Verifying ProxyAdmin: $PROXY_ADMIN_ADDRESS"
verify_contract \
  "$PROXY_ADMIN_ADDRESS" \
  "lib/openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol:ProxyAdmin" \
  "$PROXY_ADMIN_ARGS"
