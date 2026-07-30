// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IPrimusZKTLS, Attestation, AttNetworkRequest, AttNetworkResponseResolve} from "./IPrimusZKTLS.sol";

/**
 * @dev Optional business-logic guard for contracts that consume Primus zkTLS
 * attestations after IPrimusZKTLS.verifyAttestation succeeds.
 */
contract AttestationGuard {
    error FutureAttestation(uint64 timestamp, uint256 nowTimestamp, uint64 clockSkewSeconds);
    error StaleAttestation(uint64 timestamp, uint256 nowTimestamp, uint64 maxAgeSeconds);
    error UnexpectedRecipient(address expected, address actual);
    error UnexpectedRequest(bytes32 expected, bytes32 actual);
    error UnexpectedResponseResolve(bytes32 expected, bytes32 actual);
    error AttestationAlreadyConsumed(bytes32 nullifier);

    struct Policy {
        address recipient;
        uint64 maxAgeSeconds;
        uint64 clockSkewSeconds;
        bytes32 requestHash;
        bytes32 responseResolveHash;
        bool checkReplay;
    }

    IPrimusZKTLS public immutable primusZKTLS;
    mapping(bytes32 => bool) public consumedNullifiers;

    event AttestationConsumed(bytes32 indexed nullifier, address indexed recipient);

    constructor(IPrimusZKTLS _primusZKTLS) {
        primusZKTLS = _primusZKTLS;
    }

    function verify(Attestation calldata attestation, Policy calldata policy)
        external
        view
        returns (bytes32 attestationNullifier)
    {
        primusZKTLS.verifyAttestation(attestation);
        attestationNullifier = _checkPolicy(attestation, policy);
        if (policy.checkReplay && consumedNullifiers[attestationNullifier]) {
            revert AttestationAlreadyConsumed(attestationNullifier);
        }
    }

    function verifyAndConsume(Attestation calldata attestation, Policy calldata policy)
        external
        returns (bytes32 attestationNullifier)
    {
        primusZKTLS.verifyAttestation(attestation);
        attestationNullifier = _checkPolicy(attestation, policy);
        if (policy.checkReplay) {
            if (consumedNullifiers[attestationNullifier]) {
                revert AttestationAlreadyConsumed(attestationNullifier);
            }
            consumedNullifiers[attestationNullifier] = true;
            emit AttestationConsumed(attestationNullifier, attestation.recipient);
        }
    }

    function hashRequest(AttNetworkRequest calldata request) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(request.url, request.header, request.method, request.body));
    }

    function hashResponseResolve(AttNetworkResponseResolve[] calldata responseResolve) public pure returns (bytes32) {
        bytes memory encoded;
        for (uint256 i = 0; i < responseResolve.length; i++) {
            encoded = abi.encodePacked(
                encoded, responseResolve[i].keyName, responseResolve[i].parseType, responseResolve[i].parsePath
            );
        }
        return keccak256(encoded);
    }

    function nullifier(Attestation calldata attestation) public pure returns (bytes32) {
        return keccak256(
            abi.encode(
                attestation.recipient,
                hashRequest(attestation.request),
                hashResponseResolve(attestation.reponseResolve),
                attestation.data,
                attestation.attConditions,
                attestation.timestamp,
                attestation.additionParams,
                attestation.signatures
            )
        );
    }

    function _checkPolicy(Attestation calldata attestation, Policy calldata policy) internal view returns (bytes32) {
        uint256 nowTimestamp = block.timestamp;
        if (attestation.timestamp > nowTimestamp + policy.clockSkewSeconds) {
            revert FutureAttestation(attestation.timestamp, nowTimestamp, policy.clockSkewSeconds);
        }
        if (policy.maxAgeSeconds > 0 && nowTimestamp > attestation.timestamp + policy.maxAgeSeconds) {
            revert StaleAttestation(attestation.timestamp, nowTimestamp, policy.maxAgeSeconds);
        }
        if (policy.recipient != address(0) && attestation.recipient != policy.recipient) {
            revert UnexpectedRecipient(policy.recipient, attestation.recipient);
        }
        if (policy.requestHash != bytes32(0)) {
            bytes32 actualRequestHash = hashRequest(attestation.request);
            if (actualRequestHash != policy.requestHash) {
                revert UnexpectedRequest(policy.requestHash, actualRequestHash);
            }
        }
        if (policy.responseResolveHash != bytes32(0)) {
            bytes32 actualResponseResolveHash = hashResponseResolve(attestation.reponseResolve);
            if (actualResponseResolveHash != policy.responseResolveHash) {
                revert UnexpectedResponseResolve(policy.responseResolveHash, actualResponseResolveHash);
            }
        }
        return nullifier(attestation);
    }
}
