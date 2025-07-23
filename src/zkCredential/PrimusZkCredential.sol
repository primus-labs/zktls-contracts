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
    mapping(address => mapping(string => Credential[])) private zkCredentials;
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
        if (credentialType.startsWith("SpotVol30G_")) {
            string memory value = _checkAndGetSpotVol30G(attestation);
        } else if (credentialType.startsWith("AccountEq_")) {
            string memory value = _checkAndGetAccountEq(attestation);
        } else if (credentialType.startsWith("Account_")) {
            string memory value = _checkAndGetAccount(attestation);
        } else if (credentialType.equals(FollowEqAndAccount_X)) {
            (string memory followingUsername, string memory userName) = _checkAndGetFollowEqAndAccountX(attestation);
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
        require(sourceInfos[creType].sourceItems.length == 1 || sourceInfos[creType].sourceItems.length == 2, "url len err");
        if (sourceInfos[creType].sourceItems.length == 1) {
            _checkSourceInfosOne(att, creType);
        } else {
            _checkSourceInfosTwo(att, creType);
        }
    }

    function _checkSourceInfosOne(Attestation calldata att, string calldata creType) internal view {
        string memory urlCheck = att.additionParams.extractValue("requests[1].url");
        require(urlCheck.equals(""), "too more url");
        _checkSourceInfosFirstRequest(att, creType);
    }

    function _checkSourceInfosTwo(Attestation calldata att, string calldata creType) internal view {
        _checkSourceInfosFirstRequest(att, creType);
        string[] memory keys = new string[](5);
        keys[0] = "requests[2].url";
        keys[1] = "reponseResolves[1][1].parsePath";
        keys[2] = "requests[1].url";
        keys[3] = "reponseResolves[1][0].parsePath";
        // keys[4] = "reponseResolves[1][0].keyName";
        string[] memory values = att.additionParams.extractArrayValue(keys);
        string memory urlCheck = values[0];
        require(urlCheck.equals(""), "too more url");
        string memory parseCheck = values[1];
        require(parseCheck.equals(""), "too more reponseResolves");

        string memory url1 = values[2];
        string memory reponseResolve1 = values[3];
        // string memory keyName1 = values[4];
        require(url1.startsWith(sourceInfos[creType].sourceItems[1].url), "url1 error");
        require(reponseResolve1.equals(sourceInfos[creType].sourceItems[1].jsonPath[0]), "json path error");
    }

    function _checkSourceInfosFirstRequest(Attestation calldata att, string calldata creType) internal view {
        require(att.request.url.startsWith(sourceInfos[creType].sourceItems[0].url), "url err");
        require(att.reponseResolve.length == sourceInfos[creType].sourceItems[0].jsonPath.length, "res len err");
        for (uint8 i=0; i<att.reponseResolve.length; i++) {
            require(att.reponseResolve[i].parsePath.equals(sourceInfos[creType].sourceItems[0].jsonPath[i]), "res path err");
        }
    }

    function _checkAndGetSpotVol30G(Attestation calldata att) internal pure returns (string memory) {
        string memory op = att.attConditions.extractValue("op");
        require(op.equals(">") || op.equals(">="), "op err");
        return att.attConditions.extractValue("value");
    }

    function _checkAndGetAccountEq(Attestation calldata att) internal pure returns (string memory) {
        string memory op = att.attConditions.extractValue("op");
        require(op.equals("STREQ"), "op err");
        return att.attConditions.extractValue("value");
    }

    function _checkAndGetAccount(Attestation calldata att) internal pure returns (string memory) {
        string memory userName = att.data.extractValue(att.reponseResolve[0].keyName);
        return userName;
    }

    function _checkAndGetFollowEqAndAccountX(Attestation calldata att) internal pure returns (string memory, string memory) {
        string memory followingUsername;
        string[] memory strs = att.attConditions.split("},{");
        for (uint i=0; i<strs.length; i++) {
            string[] memory keysConditions = new string[](3);
            keysConditions[0] = "op";
            keysConditions[1] = "field";
            keysConditions[2] = "value";
            string[] memory valuesConditions = strs[i].extractArrayValue(keysConditions);
            if (valuesConditions[1].equals("$.data.user.result.relationship_perspectives.following")) {
                require(valuesConditions[2].equals("true") && valuesConditions[0].equals("STREQ"), "following error");
            }
            if (valuesConditions[1].equals("$.data.user.result.core.screen_name")) {
                require(valuesConditions[0].equals("STREQ"), "following name error");
                followingUsername = valuesConditions[2];
            }
            if (valuesConditions[1].equals("$.screen_name")) {
                require(valuesConditions[0].equals("REVEAL_STRING"), "name op error");
            }
        }
        string memory keyName1 = att.additionParams.extractValue("reponseResolves[1][0].keyName");
        string memory userName = att.data.extractValue(keyName1);
        return (followingUsername, userName);
    }

}