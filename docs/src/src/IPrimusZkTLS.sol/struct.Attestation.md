# Attestation
[Git Source](https://github.com/primus-labs/zkTLS-contracts/blob/c34826da72b2646b30fc46afeef78c9dafa36cd0/src/IPrimusZKTLS.sol)

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
    Attestor[] attestors;
    bytes[] signature;
}
```

