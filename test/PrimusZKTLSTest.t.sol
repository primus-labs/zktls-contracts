// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import "../src/PrimusZKTLS.sol";
import "../src/IPrimusZKTLS.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract PrimusZKTLSTest is Test {
    PrimusZKTLS private zkTLS;
    uint256 internal _signerPrivateKey;
    address internal _signer;
    using Strings for uint256;
    using Strings for address;

    address private owner = address(0x123);
    address private addr1 = address(0x456);
    address private addr2 = address(0x789);

    string constant urlString = "https://example.com/apiwdewd/121s1qs1qs?DDDSADWDDAWDWAWWAWW"; 
    string constant headerString = '{"Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwi.M0NTY3ODM0NTY3ODM0NTY3ODM0NTY3ODM0NTY3OD..","X-Custom-Header-1":""Very-Long-Custom-Header-Value-That-Exceeds-Normal-Limits-Here-1234567890l-Limits-Here-1234567l-Limits-Here-1234567l-Limits-Here-1234567l-Limits-Here-1234567l-Limits-Here-1234567...","X-Custom-Header-2":"Another-Custom-Value-1234567890abcdefghijklmnopqrstuvwxyzghijklmnopqrstuvwxyghijklmnopqrstuvwxyghijklmnopqrstuvwxyghijklmnopqrstuvwxy", "Content-Type": "application/json","Accept": "application/json","User-Agent": "MyCustomClient/1.0","Cache-Control": "no-cache"}';
    string constant bodyString = '{"metadata":{"timestamp": "2024-11-26T12:34:56Z","requestId": "123e4567-e89b-12d3-a456-426614174000","tags": ["large_request","test_data","example_usage"]},"data":{"items": [{"id": 1,"name": "Item One","description": "This is a detailed description of item one.","attributes": {"color": "red","size": "large","weight": 1.234}},{"id": 2,"name": "Item Two","description": "This is a detailed description of item two.","attributes": {"color": "blue","size": "medium","weight": 2.345}}],"extraData": {"subField1": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.","subField2": ["Value1","Value2","Value3","Value4"],"nestedField": {"innerField1": "Deeply nested value","innerField2": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]}}}}';

    Attestor private attestor1 = Attestor({attestorAddr: addr1, url: "Attestor 1"});
    Attestor private attestor2 = Attestor({attestorAddr: addr2, url: "Attestor 2"});
    function setUp() public {
        //deploy contract
        vm.prank(owner); // Set `owner` as the deployer
        zkTLS = new PrimusZKTLS();
        _signerPrivateKey = 0xA11CE;
        _signer = vm.addr(_signerPrivateKey);
        zkTLS.initialize(owner);
    }

    function addressToString(address addr) public pure returns (string memory) {
        return Strings.toHexString(uint160(addr), 20); 
    }

    function createSampleAttestation() internal view returns(Attestor[] memory){
        Attestor[] memory attes = new Attestor[] (1);
        for (uint256 i = 0; i < 1; i++) {
            attes[i] = Attestor({
                    attestorAddr: _signer,
                    url: "https://attestor1.com/profile"
            });
        }
        return attes;
    }

    function createSampleResponses() internal pure returns (AttNetworkResponseResolve[] memory) {
        AttNetworkResponseResolve[] memory response = new AttNetworkResponseResolve[] (3);
        for (uint256 i = 0; i < 3; i++) {
            response[i] = AttNetworkResponseResolve({
                    keyName: "dASCZCSQFEQSDCKMASODCNPOND[OJDL;AKNC;KA;LCZMOQNOQWNPWNEO2NEPIOWNEO2EQWDNLKJQBDIQNWIUNINOIEDN2ONEDOI2NEDO2ISDKSMD]ND LWHBLQBEDKJEBDIUWSILSBCLQVSCUYDUH@3344OIIOQWEJ02J0J3ajdhpohodh92njabdpuhcqnwejkbiuhc0[qwncjqnsdonqowfoqwno;9 ujdwkfpokwedm1jf[oi]wc9hce98cbuie9gd71gd87d817g219ge97129g19g2812912]",
                    parseType: "JSON121231uqwhdp9uh2i1ubdbjabdiwd1biu212",
                    parsePath: "$.data.key1kn;ni[onwendiohed2ij20djasdj09wndoiqweoqheqhefpqhf9p92hf238dhdohwuhpbfoqufp92hfo2iefinoiedn2o9302]"
            });
        }    
        
        return response;
    }

     function test_SetAttestor() public {
        vm.startPrank(owner); // Set the caller as the owner
        // Set an attestor for addr1
        zkTLS.setAttestor(attestor1);

        // Verify the attestor was set
        (address storedAttestorAddr, string memory storedMetadata) = zkTLS._attestorsMapping(addr1);
        assertEq(storedAttestorAddr, attestor1.attestorAddr, "Attestor address mismatch");
        assertEq(storedMetadata, attestor1.url, "Attestor metadata mismatch");

        // Set a new attestor for addr2
        zkTLS.setAttestor(attestor2);
        vm.stopPrank();
        (address storedAttestorAddr2, string memory storedMetadata2) = zkTLS._attestorsMapping(addr2);
        assertEq(storedAttestorAddr2, attestor2.attestorAddr, "Attestor address mismatch for addr2");
        assertEq(storedMetadata2, attestor2.url, "Attestor metadata mismatch for addr2");
    }

    function test_RemoveAttestor() public {
        vm.startPrank(owner); // Set the caller as the owner

        // Set an attestor for addr1
        zkTLS.setAttestor(attestor1);

        // Remove the attestor for addr1
        zkTLS.removeAttestor(addr1);
        vm.stopPrank();
        // Verify the attestor was removed
        (address storedAttestorAddr, string memory storedMetadata) = zkTLS._attestorsMapping(addr1);
        assertEq(storedAttestorAddr, address(0), "Attestor address was not removed");
        assertEq(bytes(storedMetadata).length, 0, "Attestor metadata was not removed");
    }

    // function test_SetAttestorNotOwner() public {
    //     vm.prank(addr1); // Set a non-owner as the caller

    //     // Expect the transaction to revert
    //     vm.expectRevert("Ownable: caller is not the owner");
    //     zkTLS.setAttestor(attestor1);
    // }

    // function test_RemoveAttestorNotOwner() public {
    //     vm.prank(addr1); // Set a non-owner as the caller

    //     // Expect the transaction to revert
    //     vm.expectRevert("Ownable: caller is not the owner");
    //     zkTLS.removeAttestor(addr1);
    // }


    function test_EncodeRequest() public {
        //constractor AttNetworkRequest data
        AttNetworkRequest memory request = AttNetworkRequest({
            url: urlString,
            header: headerString,
            method: "POST",
            body: bodyString
        });

        // get Gas used for encodeRequest
        uint256 gasStart = gasleft();
        zkTLS.encodeRequest(request);
        uint256 gasUsed = gasStart - gasleft();

        emit log_named_uint("Gas Used for encodeRequest", gasUsed);
    }

    function test_EncodeResponse() public {
        console.log("---test_EncodeResponse----");
        AttNetworkResponseResolve[] memory response = createSampleResponses();
        console.log("response length %d",response.length);
        // get Gas used for EncodeResponse
        uint256 gasStart = gasleft();
        zkTLS.encodeResponse(response);
        uint256 gasUsed = gasStart - gasleft();

        emit log_named_uint("Gas Used for encodeResponse", gasUsed);
    }

    function test_AttestationEncode() public {
        vm.prank(owner); // Set the caller as the owner

        // Set an attestor for addr1
        zkTLS.setAttestor(attestor1);
        //constractor AttNetworkRequest data
        AttNetworkRequest memory request = AttNetworkRequest({
            url: urlString,
            header: headerString,
            method: "GET",
            body: bodyString
        });

        AttNetworkResponseResolve[] memory response = createSampleResponses();
       
        Attestation memory attestation = Attestation({
            recipient: address(this),
            request: request,
            reponseResolve: response,
            data: bodyString,
            attConditions: '{"param":"value"}',
            timestamp: uint64(block.timestamp), 
            additionParams: '{"param":"value"}',
            attestors: new Attestor[] (1), // List of attestors who signed the attestation.
            signatures: new bytes[] (1)
        });

        //get Gas used for AttestationEncode
        uint256 gasStart = gasleft();
        zkTLS.encodeAttestation(attestation);
        uint256 gasUsed = gasStart - gasleft();

        emit log_named_uint("Gas Used for", gasUsed);
    }


    function test_VerifierSignature() public  {
        vm.prank(owner); // Set the caller as the owner
        
        zkTLS.setAttestor(Attestor({attestorAddr: _signer, url: "Attestor attestorSign"}));
        AttNetworkRequest memory request = AttNetworkRequest({
            url: urlString,
            header: headerString,
            method: "GET",
            body: bodyString
        });
        address bob = address(0x122222111111);
        AttNetworkResponseResolve[] memory response = createSampleResponses();
       
        Attestation memory attestation = Attestation({
            recipient: bob,
            request: request,
            reponseResolve: response,
            data: bodyString,
            attConditions: '{"param":"value"}',
            timestamp: uint64(block.timestamp), 
            additionParams: '{"param":"value"}', 
            attestors: new Attestor[] (1),      
            signatures: new bytes[] (1)
        });

        console.log("recipient----address:%s",addressToString(attestation.recipient));
        
        bytes32 digest = zkTLS.encodeAttestation(attestation);
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(_signerPrivateKey, digest);
        console.log("r:%d s:%d v:%d",uint256(r),uint256(s),v);

        bytes memory signature = abi.encodePacked(r, s, v); //get signature
        console.log("signature----%s",bytesToHexString(signature));


        attestation.signatures[0] = signature;

        uint256 gasStart = gasleft();
        zkTLS.verifyAttestation(attestation);
        uint256 gasUsed = gasStart - gasleft();

        emit log_named_uint("verifyAttestationWithSingleSignature Gas Used for", gasUsed);
       
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

    function bytesToHexString(bytes memory data) public pure returns (string memory) {
        bytes memory hexChars = "0123456789abcdef";
        bytes memory hexString = new bytes(data.length * 2); 

        for (uint256 i = 0; i < data.length; i++) {
            uint8 currentByte = uint8(data[i]);
            hexString[2 * i] = hexChars[currentByte >> 4]; 
            hexString[2 * i + 1] = hexChars[currentByte & 0x0f]; 
        }

        return string(hexString);
    }

}
