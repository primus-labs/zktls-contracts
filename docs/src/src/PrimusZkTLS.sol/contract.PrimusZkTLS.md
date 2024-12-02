# PrimusZkTLS
[Git Source](https://github.com/primus-labs/zkTLS-contracts/blob/22782d123c4a94bbb8308ff89b2388f9394ba26e/src/PrimusZkTLS.sol)

**Inherits:**
OwnableUpgradeable, [IPrimusZkTLS](/src/IPrimusZkTLS.sol/interface.IPrimusZkTLS.md)

*Implementation of the {IPrimusZkTLS} interface, providing
functionality to encode and verify attestations.
This contract also inherits {OwnableUpgradeable} to enable ownership control,
allowing for upgradeable contract management.*


## State Variables
### _attestorsMapping

```solidity
mapping(address => Attestor) public _attestorsMapping;
```


### _attestors

```solidity
Attestor[] public _attestors;
```


## Functions
### initialize

*initialize function to set the owner of the contract.
This function is called during the contract deployment.*


```solidity
function initialize(address _owner) public initializer;
```

### setupDefaultAttestor


```solidity
function setupDefaultAttestor(address defaultAddr) internal;
```

### setAttestor

*Allows the owner to set the attestor for a specific recipient.
Requirements:
- The caller must be the owner of the contract.*


```solidity
function setAttestor(Attestor calldata attestor) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`attestor`|`Attestor`|The attestor to associate with the recipient.|


### removeAttestor

*Removes the attestor for a specific recipient.
Requirements:
- The caller must be the owner of the contract.
attestorAddr*


```solidity
function removeAttestor(address attestorAddr) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`attestorAddr`|`address`|The address of the recipient whose attestor is to be removed.|


### verifyAttestation

*Verifies the validity of a given attestation.
Requirements:
- Attestation must contain valid signatures from attestors.
- The data, request, and response must be consistent.
- The attestation must not be expired based on its timestamp.*


```solidity
function verifyAttestation(Attestation calldata attestation) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`attestation`|`Attestation`|The attestation data to be verified.|


### encodeAttestation

*Encodes an attestation into a bytes32 hash.
The encoding includes all fields in the attestation structure,
ensuring a unique hash representing the data.*


```solidity
function encodeAttestation(Attestation calldata attestation) public pure returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`attestation`|`Attestation`|The attestation data to encode.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|A bytes32 hash of the encoded attestation.|


### encodeRequest

*Encodes a network request into a bytes32 hash.
The encoding includes the URL, headers, HTTP method, and body of the request.*


```solidity
function encodeRequest(AttNetworkRequest calldata request) public pure returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`request`|`AttNetworkRequest`|The network request to encode.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|A bytes32 hash of the encoded network request.|


### encodeResponse

*Encodes a list of network response resolutions into a bytes32 hash.
This iterates through the response array and encodes each field, creating
a unique hash representing the full response data.*


```solidity
function encodeResponse(AttNetworkResponseResolve[] calldata reponse) public pure returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`reponse`|`AttNetworkResponseResolve[]`|The array of response resolutions to encode.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|A bytes32 hash of the encoded response resolutions.|


