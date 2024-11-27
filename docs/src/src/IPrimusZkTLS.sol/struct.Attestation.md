# Attestation
[Git Source](https://github.com/primus-labs/zkTLS-contracts/blob/596b57486bd7765762e19e6acbd41fefd71e6a25/src/IPrimusZkTLS.sol)

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

