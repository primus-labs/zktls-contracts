// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { IPrimusZkCredential, Credential } from "./IPrimusZkCredential.sol";
import { Attestation } from "../IPrimusZKTLS.sol";

contract PrimusZkCredential is OwnableUpgradeable, IPrimusZkCredential {
    // Store all predefined type zkCredentials, the key is holder address and credentialType.
    mapping(address => mapping(string => Credential[])) zkCredentials;

    /**
     * @dev Submit zkTLS attestation object to Primus zkCredential contracts.
     * @param attestation The attestation is returned by Primus zkTLS SDK.
     */
    function submitCredential(Attestation calldata attestation) external payable {

    }

    /**
     * @dev Retrieve credentials of a specified type and params for the holder.
     * @param holder The holder address for getting credential.
     * @param credentialType The credential type for getting. The parameter can be empty string.
     * @param params The parameters other than the credential type, which can be an empty bytes array. 
     */
    function getCredentials(address holder, string calldata credentialType, 
        bytes calldata params) external payable returns (Credential memory) {

    }

    /**
     * @dev Verify the holder whether have the specified credential.
     * @param holder The holder address for verification.
     * @param credentialType The verification credential type.
     * @param params The parameters other than the credential type, which can be an empty bytes array. 
     */
    function verifyCredential(address holder, string calldata credentialType, 
        bytes calldata params) external payable returns (bool) {

    }

}