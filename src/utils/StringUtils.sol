// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library StringUtils {
    /**
     * Compares two strings for equality.
     *
     * @param str1 The first string to compare.
     * @param str2 The second string to compare.
     * @return True if the strings are equal, false otherwise.
     */
    function equals(string memory str1, string memory str2) internal pure returns (bool) {
        return keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2));
    }

    function startsWith(string memory str, string memory prefix) internal pure returns (bool) {
        bytes memory strBytes = bytes(str);
        bytes memory prefixBytes = bytes(prefix);
        if (prefixBytes.length > strBytes.length) {
            return false;
        }
        for (uint256 i = 0; i < prefixBytes.length; i++) {
            if (strBytes[i] != prefixBytes[i]) {
                return false;
            }
        }
        return true;
    }

    function addPrefix(string memory original, string memory prefix) internal pure returns (string memory) {
        return string(abi.encodePacked(prefix, original));
    }

    function suffixWith(string memory original, string memory suffix) internal pure returns (bool) {
        bytes memory originalBytes = bytes(original);
        bytes memory suffixBytes = bytes(suffix);
        uint256 suffixLength = suffixBytes.length;
        uint256 originalLength = originalBytes.length;

        if (suffixLength > originalLength) {
            return false;
        }

        for (uint i = 0; i < suffixLength; i++) {
            if (originalBytes[originalLength - suffixLength + i] != suffixBytes[i]) {
                return false;
            }
        }

        return true;
    }

    function extractStr(string memory original, bytes1 symbol) internal pure returns (string memory) {
        bytes memory urlBytes = bytes(original);
        uint256 queryStart = urlBytes.length;
        for (uint256 i = 0; i < urlBytes.length; i++) {
            if (urlBytes[i] == symbol) {
                queryStart = i;
                break;
            }
        }
        bytes memory baseUrlBytes = new bytes(queryStart);
        for (uint256 i = 0; i < queryStart; i++) {
            baseUrlBytes[i] = urlBytes[i];
        }
        return string(baseUrlBytes);
    }

    /**
     * Extract the base URL (ignoring query parameters)
     * @param url The full URL
     * @return The base URL without query parameters
     */
    function extractBaseUrl(string memory url) internal pure returns (string memory) {
        bytes memory urlBytes = bytes(url);
        uint256 queryStart = urlBytes.length;
        for (uint256 i = 0; i < urlBytes.length; i++) {
            if (urlBytes[i] == "?") {
                queryStart = i;
                break;
            }
        }
        bytes memory baseUrlBytes = new bytes(queryStart);
        for (uint256 i = 0; i < queryStart; i++) {
            baseUrlBytes[i] = urlBytes[i];
        }
        return string(baseUrlBytes);
    }

    function split(string memory _str, string memory _delimiter) internal pure returns (string[] memory) {
        bytes memory strBytes = bytes(_str);
        bytes memory delimBytes = bytes(_delimiter);
        require(delimBytes.length > 0, "Delimiter must not be empty");

        string[] memory partsTemp = new string[](strBytes.length);
        uint partCount = 0;

        uint lastIndex = 0;
        uint i = 0;
        while (i <= strBytes.length - delimBytes.length) {
            bool matchDelimiter = true;
            for (uint j = 0; j < delimBytes.length; j++) {
                if (strBytes[i + j] != delimBytes[j]) {
                    matchDelimiter = false;
                    break;
                }
            }

            if (matchDelimiter) {
                partsTemp[partCount++] = substring(_str, lastIndex, i);
                i += delimBytes.length;
                lastIndex = i;
            } else {
                i++;
            }
        }

        partsTemp[partCount++] = substring(_str, lastIndex, strBytes.length);

        string[] memory parts = new string[](partCount);
        for (uint k = 0; k < partCount; k++) {
            parts[k] = partsTemp[k];
        }

        return parts;
    }

    function substring(string memory str, uint startIndex, uint endIndex) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        require(endIndex >= startIndex && endIndex <= strBytes.length, "Invalid indices");
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }
}
