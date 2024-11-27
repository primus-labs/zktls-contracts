# AttNetworkRequest
[Git Source](https://github.com/primus-labs/zkTLS-contracts/blob/596b57486bd7765762e19e6acbd41fefd71e6a25/src/IPrimusZkTLS.sol)

*Structure for representing a network request send to jsk and related to the attestation.*


```solidity
struct AttNetworkRequest {
    string url;
    string header;
    string method;
    string body;
}
```

