// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {PrimusZKTLS} from "../src/PrimusZKTLS.sol";
import {AttestationGuard} from "../src/AttestationGuard.sol";
import {Attestation, Attestor, AttNetworkRequest, AttNetworkResponseResolve} from "../src/IPrimusZKTLS.sol";

contract AttestationGuardTest is Test {
    PrimusZKTLS private zkTLS;
    AttestationGuard private guard;

    uint256 private signerPrivateKey = 0xA11CE;
    address private signer = vm.addr(signerPrivateKey);
    address private owner = address(0x123);
    address private recipient = address(0x456);

    string private constant EXPECTED_URL = "https://www.okx.com/api/v5/public/instruments?instType=SPOT&instId=BTC-USD";
    string private constant OTHER_URL =
        "https://www.okx.com/api/v5/public/mark-price?instType=SWAP&instId=BTC-USD-SWAP";
    string private constant PARSE_PATH = "$.data[0].instType";

    function setUp() public {
        Attestor[] memory initialAttestors = new Attestor[](1);
        initialAttestors[0] = Attestor({attestorAddr: signer, url: "https://primuslabs.xyz/"});

        zkTLS = new PrimusZKTLS();
        zkTLS.initialize(owner, initialAttestors);

        guard = new AttestationGuard(zkTLS);
        vm.warp(1_800_000_000);
    }

    function testVerifyAttestationAllowsValidButStaleAttestation() public view {
        Attestation memory attestation = _signedAttestation(EXPECTED_URL, uint64(block.timestamp - 2 days));

        zkTLS.verifyAttestation(attestation);
    }

    function testGuardRejectsStaleAttestation() public {
        Attestation memory attestation = _signedAttestation(EXPECTED_URL, uint64(block.timestamp - 2 days));
        AttestationGuard.Policy memory policy = _policy(attestation, 1 hours, true);

        vm.expectRevert(
            abi.encodeWithSelector(
                AttestationGuard.StaleAttestation.selector, attestation.timestamp, block.timestamp, policy.maxAgeSeconds
            )
        );
        guard.verifyAndConsume(attestation, policy);
    }

    function testGuardConsumesFreshAttestation() public {
        Attestation memory attestation = _signedAttestation(EXPECTED_URL, uint64(block.timestamp - 30));
        AttestationGuard.Policy memory policy = _policy(attestation, 1 hours, true);

        bytes32 nullifier = guard.verifyAndConsume(attestation, policy);

        assertTrue(guard.consumedNullifiers(nullifier));
    }

    function testGuardRejectsReplay() public {
        Attestation memory attestation = _signedAttestation(EXPECTED_URL, uint64(block.timestamp - 30));
        AttestationGuard.Policy memory policy = _policy(attestation, 1 hours, true);

        guard.verifyAndConsume(attestation, policy);

        bytes32 expectedNullifier = guard.nullifier(attestation);
        vm.expectRevert(abi.encodeWithSelector(AttestationGuard.AttestationAlreadyConsumed.selector, expectedNullifier));
        guard.verifyAndConsume(attestation, policy);
    }

    function testGuardRejectsFutureDatedAttestation() public {
        Attestation memory attestation = _signedAttestation(EXPECTED_URL, uint64(block.timestamp + 2 hours));
        AttestationGuard.Policy memory policy = _policy(attestation, 1 hours, true);
        policy.clockSkewSeconds = 30;

        vm.expectRevert(
            abi.encodeWithSelector(
                AttestationGuard.FutureAttestation.selector,
                attestation.timestamp,
                block.timestamp,
                policy.clockSkewSeconds
            )
        );
        guard.verifyAndConsume(attestation, policy);
    }

    function testGuardRejectsRequestSchemaDrift() public {
        Attestation memory expectedAttestation = _signedAttestation(EXPECTED_URL, uint64(block.timestamp - 30));
        Attestation memory driftedAttestation = _signedAttestation(OTHER_URL, uint64(block.timestamp - 30));
        AttestationGuard.Policy memory policy = _policy(expectedAttestation, 1 hours, false);

        zkTLS.verifyAttestation(driftedAttestation);

        vm.expectRevert(
            abi.encodeWithSelector(
                AttestationGuard.UnexpectedRequest.selector,
                policy.requestHash,
                guard.hashRequest(driftedAttestation.request)
            )
        );
        guard.verifyAndConsume(driftedAttestation, policy);
    }

    function _policy(Attestation memory attestation, uint64 maxAgeSeconds, bool checkReplay)
        private
        view
        returns (AttestationGuard.Policy memory)
    {
        return AttestationGuard.Policy({
            recipient: recipient,
            maxAgeSeconds: maxAgeSeconds,
            clockSkewSeconds: 30,
            requestHash: guard.hashRequest(attestation.request),
            responseResolveHash: guard.hashResponseResolve(attestation.reponseResolve),
            checkReplay: checkReplay
        });
    }

    function _signedAttestation(string memory url, uint64 timestamp)
        private
        view
        returns (Attestation memory attestation)
    {
        AttNetworkResponseResolve[] memory responseResolve = new AttNetworkResponseResolve[](1);
        responseResolve[0] = AttNetworkResponseResolve({keyName: "instType", parseType: "json", parsePath: PARSE_PATH});

        attestation = Attestation({
            recipient: recipient,
            request: AttNetworkRequest({url: url, header: "", method: "GET", body: ""}),
            reponseResolve: responseResolve,
            data: '{"instType":"SPOT"}',
            attConditions: "",
            timestamp: timestamp,
            additionParams: "",
            attestors: new Attestor[](1),
            signatures: new bytes[](1)
        });

        bytes32 digest = zkTLS.encodeAttestation(attestation);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPrivateKey, digest);
        attestation.signatures[0] = abi.encodePacked(r, s, v);
    }
}
