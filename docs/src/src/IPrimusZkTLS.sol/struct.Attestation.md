# Attestation
[Git Source](https://github.com/primus-labs/zkTLS-contracts/blob/22782d123c4a94bbb8308ff89b2388f9394ba26e/src/IPrimusZkTLS.sol)

*Structure representing an attestation, which is a signed statement of fact.*


```solidity
struct Attestation {
    address recipient;
    AttNetworkRequest request;
    AttNetworkResponseResolve[] reponse;
    string data;
    string attConditions;
    uint64 timestamp;
    string attitionParams;
    bytes[] signature;
}
```

