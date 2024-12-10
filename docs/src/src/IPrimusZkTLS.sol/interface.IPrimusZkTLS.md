# IPrimusZKTLS
[Git Source](https://github.com/primus-labs/zkTLS-contracts/blob/598ebb1789581520b0b29d02a686bfae9b7ffe60/src/IPrimusZKTLS.sol)

*Interface of PrimusZKTLS, which defines functions for handling attestations and related operations.*


## Functions
### verifyAttestation

*Verifies the validity of a given attestation.
This includes checking the signature of attestor,
the integrity of the data, and the attestation's consistency.*


```solidity
function verifyAttestation(Attestation calldata attestation) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`attestation`|`Attestation`|The attestation data to be verified. It contains details about the recipient, request, response, and attestors. Requirements: - The attestation must have valid signatures from all listed attestors. - The data must match the provided request and response structure. - The attestation must not be expired (based on its timestamp). Emits no events.|


