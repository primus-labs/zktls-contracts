# AttNetworkRequest
[Git Source](https://github.com/primus-labs/zkTLS-contracts/blob/598ebb1789581520b0b29d02a686bfae9b7ffe60/src/IPrimusZKTLS.sol)

*Structure for representing a network request send to jsk and related to the attestation.*


```solidity
struct AttNetworkRequest {
    string url;
    string header;
    string method;
    string body;
}
```

