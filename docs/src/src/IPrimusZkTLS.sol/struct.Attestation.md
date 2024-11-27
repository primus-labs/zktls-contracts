# Attestation
[Git Source](https://github.com/primus-labs/zkTLS-contracts/blob/39da5d93e5284e511f38cef54cdf2b68d70d73c9/src/IPrimusZkTLS.sol)

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

