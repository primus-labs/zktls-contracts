// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {PrimusZKTLS} from "../src/PrimusZKTLS.sol";
import {Attestation, AttNetworkRequest, AttNetworkResponseResolve, Attestor} from "../src/IPrimusZKTLS.sol";

contract PrimusZKTLSSignatureMalleabilityTest is Test {
    uint256 private constant SIGNER_KEY = 0xA11CE;
    uint256 private constant SECP256K1_N = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;

    PrimusZKTLS private verifier;
    address private signer;

    function setUp() public {
        signer = vm.addr(SIGNER_KEY);
        verifier = new PrimusZKTLS();

        Attestor[] memory allowed = new Attestor[](1);
        allowed[0] = Attestor({attestorAddr: signer, url: "https://example.com"});
        verifier.initialize(address(this), allowed);
    }

    function testAcceptsCanonicalSignature() public {
        Attestation memory attestation = _sampleAttestation();
        bytes32 digest = verifier.encodeAttestation(attestation);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(SIGNER_KEY, digest);

        assertLe(uint256(s), SECP256K1_N / 2);
        attestation.signatures[0] = abi.encodePacked(r, s, v);
        verifier.verifyAttestation(attestation);
    }

    function testRejectsMalleatedHighSSignature() public {
        Attestation memory attestation = _sampleAttestation();
        bytes32 digest = verifier.encodeAttestation(attestation);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(SIGNER_KEY, digest);

        uint256 highS = SECP256K1_N - uint256(s);
        uint8 flippedV = v == 27 ? 28 : 27;

        assertGt(highS, SECP256K1_N / 2);
        assertEq(ecrecover(digest, flippedV, r, bytes32(highS)), signer);

        attestation.signatures[0] = abi.encodePacked(r, bytes32(highS), flippedV);
        vm.expectRevert(bytes("Invalid signature s value"));
        verifier.verifyAttestation(attestation);
    }

    function testRejectsInvalidRecoveryId() public {
        Attestation memory attestation = _sampleAttestation();
        bytes32 digest = verifier.encodeAttestation(attestation);
        (, bytes32 r, bytes32 s) = vm.sign(SIGNER_KEY, digest);

        attestation.signatures[0] = abi.encodePacked(r, s, uint8(29));
        vm.expectRevert(bytes("Invalid signature v value"));
        verifier.verifyAttestation(attestation);
    }

    function _sampleAttestation() private view returns (Attestation memory attestation) {
        attestation.recipient = address(this);
        attestation.request =
            AttNetworkRequest({url: "https://example.com/profile", header: "", method: "GET", body: ""});
        attestation.reponseResolve = new AttNetworkResponseResolve[](0);
        attestation.data = "{\"approved\":true}";
        attestation.attConditions = "";
        attestation.timestamp = uint64(block.timestamp);
        attestation.additionParams = "";
        attestation.attestors = new Attestor[](0);
        attestation.signatures = new bytes[](1);
    }
}
