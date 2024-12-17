## Primus zktls-contract

The Primus zkTLS protocol is compatible with multiple blockchains. We provide smart contracts that can be deployed on different blockchains to verify data proofs generated by users through the zkTLS SDK.

## Documentation

You can find the documentation here:
[Primus-Doc](https://docs.primuslabs.xyz/)

### Supported Blockchains

You can check the contract address on the [Contract Addresses List](https://docs.primuslabs.xyz/data-verification/zk-tls-sdk/solidity/overview/).

### Supported Languages

- [x] Solidity

### Usage Example

- using Primus ZKTLs contracts in Foundry

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IPrimusZKTLS, Attestation } from "@primuslabs/zktls-contracts/src/IPrimusZKTLS.sol";
contract AttestorTest {
   address public primusAddress;

   constructor(address _primusAddress) {
      // Replace with the network you are deploying on
      primusAddress = _primusAddress;
   }

   function verifySignature(Attestation calldata attestation) public view returns(bool) {
        IPrimusZKTLS(primusAddress).verifyAttestation(attestation);

        // Your business logic upon successful verification
        // Example: Verify that proof.context matches your expectations
        return true;
   }
}

```

## Usage

### Test

```shell
$ forge test
```

### Deploy

```shell
$ forge script script/PrimusZKTLS.s.sol --rpc-url <your_rpc_url> --private-key <your_private_key> --broadcast
```

### Upgrade

```shell
$ forge script script/UpgradeZKTLS.s.sol --rpc-url <your_rpc_url> --private-key <your_private_key> --broadcast

```

### Verify

```shell
forge verify-contract --chain-id chian_ID \
    --etherscan-api-key your_private_apikey \
    contract_address \
    src/PrimusZKTLS.sol:PrimusZKTLS \
    --watch
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
