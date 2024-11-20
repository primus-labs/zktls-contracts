// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

struct Attestation {
 address recipient;
 AttNetworkRequest request;
 AttNetworkResponseResolve[] reponse;
 string data; // json string
 string attParameters; // json string
 uint64 timestamp;
 Attestor[] attestors;
 bytes[] signatures;
}

struct AttNetworkRequest {
  string url;
  string header; // json string
  string method;
  string body;
}

struct AttNetworkResponseResolve {
  string keyName;
  string parseType; //json or html
  string parsePath;
}

struct Attestor {
  string attestorAddr;
  string url;
}

/**
 * @dev Interface of PrimusZkTLS.
 */
interface IPrimusZkTLS {
    function verifyAttestation(Attestation calldata attestaion) external;
    function attestationEncode(Attestation calldata attestation) external pure returns (bytes32);
    function encodeRequest(AttNetworkRequest calldata request) external pure returns (bytes32);
    function encodeResponse(AttNetworkResponseResolve[] calldata reponse) external pure returns (bytes32);
}