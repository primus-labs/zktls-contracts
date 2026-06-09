// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

library JsonParser {
    /**
     * @dev Extracts the value of a given key from a JSON string, supports nested keys.
     * @param json The JSON string to parse.
     * @param key The key whose value needs to be extracted.
     * @return The value associated with the given key.
     */
    function extractValue(string memory json, string memory key) internal pure returns (string memory) {
        bytes memory jsonBytes = bytes(json);
        bytes memory keyBytes = bytes(key);

        // Find the starting position of the key
        for (uint256 i = 0; i < jsonBytes.length; i++) {
            if (isMatch(jsonBytes, keyBytes, i)) {
                // Skip over the `":"` character
                uint256 start = i + keyBytes.length + 3;
                uint256 end = start;

                // Search for the closing quote of the value
                while (end < jsonBytes.length && jsonBytes[end] != '"') {
                    end++;
                }

                bytes memory valueBytes = new bytes(end - start);
                for (uint256 j = start; j < end; j++) {
                    valueBytes[j - start] = jsonBytes[j];
                }

                return string(valueBytes);
            }
        }

        return ""; // Return an empty string if the key is not found
    }

    function extractArrayValue(string memory json, string[] memory keys) internal pure returns (string[] memory) {
        bytes memory jsonBytes = bytes(json);
        string[] memory values = new string[](keys.length);
        bool[] memory found = new bool[](keys.length);
        uint256 foundCount = 0;

        for (uint256 i = 0; i < jsonBytes.length && foundCount < keys.length; i++) {
            if (jsonBytes[i] != '"') continue;

            uint256 keyStart = i + 1;
            uint256 keyEnd = keyStart;

            // Find the '"' at the end of the key
            while (keyEnd < jsonBytes.length && jsonBytes[keyEnd] != '"') {
                keyEnd++;
            }
            if (keyEnd >= jsonBytes.length) break;

            uint256 keyLen = keyEnd - keyStart;

            for (uint256 k = 0; k < keys.length; k++) {
                if (found[k]) continue;

                bytes memory target = bytes(keys[k]);
                if (target.length != keyLen) {
                    continue;
                }

                bool isMatched = true;
                for (uint256 j = 0; j < keyLen; j++) {
                    if (jsonBytes[keyStart + j] != target[j]) {
                        isMatched = false;
                        break;
                    }
                }

                if (!isMatched) continue;

                // Find the ':' (skip the space in between)
                uint256 colon = keyEnd + 1;
                while (colon < jsonBytes.length && jsonBytes[colon] != ":") colon++;
                colon++;
                while (colon < jsonBytes.length && (jsonBytes[colon] == " ")) colon++;

                // Determine if it is a string value (starting with ")
                bool isQuoted = (colon < jsonBytes.length && jsonBytes[colon] == '"');
                if (isQuoted) colon++;

                uint256 valStart = colon;
                uint256 valEnd = valStart;

                if (isQuoted) {
                    while (valEnd < jsonBytes.length && jsonBytes[valEnd] != '"') valEnd++;
                } else {
                    while (valEnd < jsonBytes.length && jsonBytes[valEnd] != "," && jsonBytes[valEnd] != "}") valEnd++;
                }

                bytes memory valBytes = new bytes(valEnd - valStart);
                for (uint256 j = 0; j < valBytes.length; j++) {
                    valBytes[j] = jsonBytes[valStart + j];
                }

                values[k] = string(valBytes);
                found[k] = true;
                foundCount++;

                i = valEnd;
                break;
            }

            i = keyEnd;
        }

        return values;
    }

    /**
     * @dev Checks if the given key matches the JSON substring at the specified position.
     * @param jsonBytes The JSON string as bytes.
     * @param keyBytes The key as bytes.
     * @param start The starting index to compare.
     * @return True if the key matches, false otherwise.
     */
    function isMatch(bytes memory jsonBytes, bytes memory keyBytes, uint256 start) internal pure returns (bool) {
        if (start + keyBytes.length >= jsonBytes.length) {
            return false;
        }

        for (uint256 i = 0; i < keyBytes.length; i++) {
            if (jsonBytes[start + i] != keyBytes[i]) {
                return false;
            }
        }

        return true;
    }
}
