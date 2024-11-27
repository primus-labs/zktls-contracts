# AttNetworkRequest
[Git Source](https://github.com/primus-labs/zkTLS-contracts/blob/39da5d93e5284e511f38cef54cdf2b68d70d73c9/src/IPrimusZkTLS.sol)

*Structure for representing a network request send to jsk and related to the attestation.*


```solidity
struct AttNetworkRequest {
    string url;
    string header;
    string method;
    string body;
}
```

