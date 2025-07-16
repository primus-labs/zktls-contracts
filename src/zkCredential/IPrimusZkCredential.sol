// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { Attestation } from "../IPrimusZKTLS.sol";

struct Credential {
    string data;
    string attConditions;
    uint64 timestamp;
    string additionParams;
}

interface IPrimusZkCredential {
    /**
     * @dev Submit zkTLS attestation object to Primus zkCredential contracts.
     * @param attestation The attestation is returned by Primus zkTLS SDK.
     */
    function submitCredential(Attestation calldata attestation, string calldata credentialType) external payable;

    /**
     * @dev Retrieve credentials of a specified type and params for the holder.
     * @param holder The holder address for getting credential.
     * @param credentialType The credential type for getting. The parameter can be empty string.
     * @param params The parameters other than the credential type, which can be an empty bytes array. 
     */
    function getCredentials(address holder, string calldata credentialType, 
        bytes calldata params) external payable returns (Credential memory);

    /**
     * @dev Verify the holder whether have the specified credential.
     * @param holder The holder address for verification.
     * @param credentialType The verification credential type.
     * @param params The parameters other than the credential type, which can be an empty bytes array. 
     */
    function verifyCredential(address holder, string calldata credentialType, 
        bytes calldata params) external payable returns (bool);
}

string constant SpotVol30_G_Binance = "SpotVol30_G_Binance";
string constant SpotVol30_G_Okx = "SpotVol30_G_Okx";
string constant SpotVol30_G_Bybit = "SpotVol30_G_Bybit";
string constant SpotVol30_G_Bitget = "SpotVol30_G_Bitget";

string constant Account_Eq_X = "Account_Eq_X";
string constant Account_Eq_Tiktok = "Account_Eq_Tiktok";
string constant Account_Eq_Google = "Account_Eq_Google";
string constant Account_Eq_RedNote = "Account_Eq_RedNote";

string constant Account_X = "Account_X";
string constant Account_Tiktok = "Account_Tiktok";
string constant Account_Google = "Account_Google";
string constant Account_Rednote = "Account_Rednote";

string constant FollowAndAccount_X = "FollowAndAccount_X";


struct SourceInfo {
    string url;
    string[] jsonPath;
}