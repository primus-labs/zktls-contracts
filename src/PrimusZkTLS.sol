// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {IPrimusZkTLS, Attestation, AttNetworkRequest, AttNetworkResponseResolve} from "./IPrimusZkTLS.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
/**
 * @dev Implementation of the {IPrimusZkTLS} interface, providing 
 * functionality to encode and verify attestations.
 *
 * This contract also inherits {OwnableUpgradeable} to enable ownership control,
 * allowing for upgradeable contract management.
 */
contract PrimusZkTLS is OwnableUpgradeable, IPrimusZkTLS {
    using Strings for uint256;
    using Strings for address;
    /**
     * @dev Verifies the validity of a given attestation.
     *
     * Requirements:
     * - Attestation must contain valid signatures from attestors.
     * - The data, request, and response must be consistent.
     * - The attestation must not be expired based on its timestamp.
     *
     * @param attestation The attestation data to be verified.
     */
    function verifyAttestation(Attestation calldata attestation) external pure returns (bool) {
        bytes memory signature = attestation.signature;
        require(signature.length == 65,"Invalid signature length");
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }
        require(v == 27 || v == 28, "Invalid signature v value");

        for (uint256 i = 0; i < attestation.attestors.length; i++) {
            address currentAddr = parseAddr(attestation.attestors[i].attestorAddr);
            require(currentAddr != address(0), "Invalid attestation");
            address attestorAddr = ecrecover(attestationEncode(attestation), v, r, s);
            if (attestorAddr == currentAddr) {
                return true;
            }
        }
        return false;
    }

    function parseAddr(string memory addrStr) internal pure returns (address) {
        bytes memory temp = bytes(addrStr);
         uint160 addr;
        for (uint256 i = 2; i < 42; i++) {
             uint8 b = uint8(temp[i]);
             if (b >= 48 && b <= 57) {
                addr = addr * 16 + (b - 48);
            } else if (b >= 97 && b <= 102) {
                addr = addr * 16 + (b - 87);
            } else if (b >= 65 && b <= 70) {
                addr = addr * 16 + (b - 55);
            }
        }
        return address(addr);
    }

    function addressToString(address _signer) public pure returns (string memory) {
        return Strings.toHexString(uint160(_signer), 20); // 20 是地址字节长度
    }

    function bytesToHexString(bytes memory data) public pure returns (string memory) {
        bytes memory hexChars = "0123456789abcdef";
        bytes memory hexString = new bytes(data.length * 2); // 每字节占两字符

        for (uint256 i = 0; i < data.length; i++) {
            uint8 currentByte = uint8(data[i]);
            hexString[2 * i] = hexChars[currentByte >> 4]; // 高4位
            hexString[2 * i + 1] = hexChars[currentByte & 0x0f]; // 低4位
        }

        return string(hexString);
    }

    /**
     * @dev Encodes an attestation into a bytes32 hash.
     *
     * The encoding includes all fields in the attestation structure,
     * ensuring a unique hash representing the data.
     *
     * @param attestation The attestation data to encode.
     * @return A bytes32 hash of the encoded attestation.
     */
    function attestationEncode(
        Attestation calldata attestation
    ) public pure returns (bytes32) {
        bytes memory encodeData = abi.encode(
            attestation.recipient,
            encodeRequest(attestation.request),
            encodeResponse(attestation.reponse),
            attestation.data,
            attestation.attParameters,
            attestation.timestamp
        );
        return keccak256(encodeData);
    }

    function attestationEncode1(
        Attestation calldata attestation
    ) public pure returns (bytes32) {
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

    /**
     * @dev Encodes a network request into a bytes32 hash.
     *
     * The encoding includes the URL, headers, HTTP method, and body of the request.
     *
     * @param request The network request to encode.
     * @return A bytes32 hash of the encoded network request.
     */
    function encodeRequest(
        AttNetworkRequest calldata request
    ) public pure returns (bytes32) {
        bytes memory encodeData = abi.encode(
            request.url,
            request.header,
            request.method,
            request.body
        );
        return keccak256(encodeData);
    }

    function encodeRequest1(
        AttNetworkRequest calldata request
    ) public pure returns (bytes32) {
        bytes memory encodeData = abi.encodePacked(
            request.url,
            request.header,
            request.method,
            request.body
        );
        return keccak256(encodeData);
    }

    /**
     * @dev Encodes a list of network response resolutions into a bytes32 hash.
     *
     * This iterates through the response array and encodes each field, creating
     * a unique hash representing the full response data.
     *
     * @param reponse The array of response resolutions to encode.
     * @return A bytes32 hash of the encoded response resolutions.
     */
    function encodeResponse(
        AttNetworkResponseResolve[] calldata reponse
    ) public pure returns (bytes32) {
        bytes memory encodeData;
        for (uint256 i = 0; i < reponse.length; i++) {
            encodeData = abi.encode(
                encodeData,
                reponse[i].keyName,
                reponse[i].parseType,
                reponse[i].parsePath
            );
        }
        return keccak256(encodeData);
    }

    function encodeResponse1(
        AttNetworkResponseResolve[] calldata reponse
    ) public pure returns (bytes32) {
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
