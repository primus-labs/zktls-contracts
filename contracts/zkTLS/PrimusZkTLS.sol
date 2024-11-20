// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {IPrimusZkTLS, Attestation, AttNetworkRequest, AttNetworkResponseResolve} from "./IPrimusZkTLS.sol";

/**
 * @dev Implementation of the {IPrimusZkTLS} interface.
 */
contract PrimusZkTLS is OwnableUpgradeable, IPrimusZkTLS {

    function verifyAttestation(Attestation calldata attestaion) external {
    }

    function attestationEncode(Attestation calldata attestation) public pure returns (bytes32) {
        bytes memory encodeData = abi.encodePacked(
            attestation.recipient,
            encodeRequest(attestation.request),
			encodeResponse(attestation.reponse),
            attestation.data,
            attestation.attParameters,
            attestation.timestamp
		);
		return keccak256(encodeData);
    }

    function encodeRequest(AttNetworkRequest calldata request) public pure returns (bytes32) {
        bytes memory encodeData = abi.encodePacked(
            request.url,
            request.header,
            request.method,
            request.body
        );
		return keccak256(encodeData);
    }

    function encodeResponse(AttNetworkResponseResolve[] calldata reponse) public pure returns (bytes32) {
        bytes memory encodeData;
        for (uint256 i = 0; i < reponse.length; i++) {
            encodeData = abi.encodePacked(
                encodeData,
                reponse[i].keyName,
                reponse[i].parseType,
                reponse[i].parsePath
            );
        }
		return keccak256(encodeData);
    }
}