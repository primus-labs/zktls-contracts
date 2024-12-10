# Attestation
[Git Source](https://github.com/primus-labs/zkTLS-contracts/blob/598ebb1789581520b0b29d02a686bfae9b7ffe60/src/IPrimusZKTLS.sol)

*Structure representing an attestation, which is a signed statement of fact.*


```solidity
struct Attestation {
    address recipient;
    AttNetworkRequest request;
    AttNetworkResponseResolve[] reponseResolve;
    string data;
    string attConditions;
    uint64 timestamp;
    string additionParams;
    Attestor[] attestors;
    bytes[] signatures;
}
```

