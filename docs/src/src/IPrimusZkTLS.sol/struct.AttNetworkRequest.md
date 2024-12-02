# AttNetworkRequest
[Git Source](https://github.com/primus-labs/zkTLS-contracts/blob/22782d123c4a94bbb8308ff89b2388f9394ba26e/src/IPrimusZkTLS.sol)

*Structure for representing a network request send to jsk and related to the attestation.*


```solidity
struct AttNetworkRequest {
    string url;
    string header;
    string method;
    string body;
}
```

