# AttNetworkRequest
[Git Source](https://github.com/primus-labs/zkTLS-contracts/blob/c34826da72b2646b30fc46afeef78c9dafa36cd0/src/IPrimusZKTLS.sol)

*Structure for representing a network request send to jsk and related to the attestation.*


```solidity
struct AttNetworkRequest {
    string url;
    string header;
    string method;
    string body;
}
```

