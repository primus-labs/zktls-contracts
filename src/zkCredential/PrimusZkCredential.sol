// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { Attestation, IPrimusZKTLS } from "../IPrimusZKTLS.sol";
import "./IPrimusZkCredential.sol";
import "../utils/StringUtils.sol";
import "../utils/JsonParser.sol";

contract PrimusZkCredential is OwnableUpgradeable, IPrimusZkCredential {
    using StringUtils for string;
    using JsonParser for string;

    IPrimusZKTLS internal primusZKTLS;
    // Store all predefined type zkCredentials, the key is holder address and credentialType.
    mapping(address => mapping(string => Credential[])) public zkCredentials;
    // Store all the credentialType source url and response json path. The key is credentialType.
    mapping(string => SourceInfo) public sourceInfos;

    function initialize(address owner, IPrimusZKTLS primusZKTLS_) public initializer {
        __Ownable_init(owner);
        primusZKTLS = primusZKTLS_;
    }

    /**
     * @dev Submit zkTLS attestation object to Primus zkCredential contracts.
     * @param attestation The attestation is returned by Primus zkTLS SDK.
     */
    function submitCredential(Attestation calldata attestation, string calldata credentialType) external payable {
        _checkSourceInfos(attestation, credentialType);
        primusZKTLS.verifyAttestation(attestation);
        if (credentialType.startsWith("SpotVol30_G")) {
            string memory value = _checkAndGetSpotVol30G(attestation);
        }
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


    function setSourceInfos(string[] calldata credentialTypes, SourceInfo[] calldata sourceInfos_) external onlyOwner {
        for (uint32 i=0; i<credentialTypes.length; i++) {
            sourceInfos[credentialTypes[i]] = sourceInfos_[i];
        }
    }


    function _checkSourceInfos(Attestation calldata att, string calldata creType) internal view {
        string memory urlCheck = att.additionParams.extractValue("requests[1].url");
        require(urlCheck.equals(""), "too more url");
        require(att.request.url.startsWith(sourceInfos[creType].url), "url err");
        require(att.reponseResolve.length == sourceInfos[creType].jsonPath.length, "res len err");
        for (uint8 i=0; i<att.reponseResolve.length; i++) {
            require(att.reponseResolve[i].parsePath.equals(sourceInfos[creType].jsonPath[i]), "res path err");
        }
    }

    function _checkAndGetSpotVol30G(Attestation calldata att) internal pure returns (string memory) {
        string memory op = att.attConditions.extractValue("op");
        require(op.equals(">") || op.equals(">="), "op err");
        return att.attConditions.extractValue("value");
    }

}