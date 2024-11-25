// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import "../src/PrimusZkTLS.sol";
import "../src/IPrimusZkTLS.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract PrimusZkTLSTest is Test {
    PrimusZkTLS private zkTLS;
    uint256 internal _signerPrivateKey;
    address internal _signer;
    using Strings for uint256;
    using Strings for address;

    function setUp() public {
        // 部署合约
        zkTLS = new PrimusZkTLS();
        _signerPrivateKey = 0xA11CE;
        _signer = vm.addr(_signerPrivateKey);
    }

    function addressToString(address addr) public pure returns (string memory) {
        return Strings.toHexString(uint160(addr), 20); // 20 是地址字节长度
    }

    function createSampleAttestation() internal view returns(Attestor[] memory){
        Attestor[] memory attes = new Attestor[] (1);
        string memory addr = addressToString(_signer);
        for (uint256 i = 0; i < 1; i++) {
            attes[i] = Attestor({
                    attestorAddr: addr,
                    url: "https://attestor1.com/profile"
            });
        }
        return attes;
    }

    function createSampleResponses() internal pure returns (AttNetworkResponseResolve[] memory) {
        AttNetworkResponseResolve[] memory response = new AttNetworkResponseResolve[] (3);
        for (uint256 i = 0; i < 3; i++) {
            response[i] = AttNetworkResponseResolve({
                    keyName: "key1",
                    parseType: "JSON",
                    parsePath: "$.data.key1"
            });
        }    
        
        return response;
    }

    function test_EncodeRequest() public {
        // 构造请求数据
        AttNetworkRequest memory request = AttNetworkRequest({
            url: "https://example.com/api",
            header: '{"Authorization":"Bearer token"}',
            method: "POST",
            body: '{"key":"value"}'
        });

        // 测量 Gas 消耗
        uint256 gasStart = gasleft();
        zkTLS.encodeRequest(request);
        uint256 gasUsed = gasStart - gasleft();

        emit log_named_uint("Gas Used for encodeRequest", gasUsed);
    }

    function test_EncodeRequest1() public {
          // 构造请求数据
        AttNetworkRequest memory request = AttNetworkRequest({
            url: "https://example.com/api",
            header: '{"Authorization":"Bearer token"}',
            method: "POST",
            body: '{"key":"value"}'
        });

        // 测量 Gas 消耗
        uint256 gasStart = gasleft();
        zkTLS.encodeRequest1(request);
        uint256 gasUsed = gasStart - gasleft();

        emit log_named_uint("Gas Used for encodeRequest packedencode", gasUsed);
    }


    function test_EncodeResponse() public {
        // To modify, use a storage array
        console.log("---test_EncodeResponse----");
        AttNetworkResponseResolve[] memory response = createSampleResponses();
        console.log("response length %d",response.length);
        // 测量 Gas 消耗
        uint256 gasStart = gasleft();
        zkTLS.encodeResponse(response);
        uint256 gasUsed = gasStart - gasleft();

        emit log_named_uint("Gas Used for encodeResponse", gasUsed);
    }

    function test_EncodeResponse1() public {
        // 构造响应数据
        AttNetworkResponseResolve[] memory response = createSampleResponses();
        console.log("response length %d",response.length);
        // 测量 Gas 消耗
        uint256 gasStart = gasleft();
        zkTLS.encodeResponse1(response);
        uint256 gasUsed = gasStart - gasleft();

        emit log_named_uint("Gas Used for encodeResponse packedencode", gasUsed);
    }


    function test_AttestationEncode() public {
        // 构造测试数据
        AttNetworkRequest memory request = AttNetworkRequest({
            url: "https://example.com/api",
            header: '{"Authorization":"Bearer token"}',
            method: "GET",
            body: '{"key":"value"}'
        });

        AttNetworkResponseResolve[] memory response = createSampleResponses();
        Attestor[] memory attes = createSampleAttestation();
        Attestation memory attestation = Attestation({
            recipient: address(this),
            request: request,
            reponse: response,
            data: '{"key":"value"}',
            attParameters: '{"param":"value"}',
            timestamp: uint64(block.timestamp),
            attestors: attes,         
            signature: new bytes(0)
        });

        // 测量 Gas 消耗
        uint256 gasStart = gasleft();
        zkTLS.attestationEncode(attestation);
        uint256 gasUsed = gasStart - gasleft();

        emit log_named_uint("Gas Used for", gasUsed);
    }

    
     function test_AttestationEncode1() public {
        // 构造测试数据
        AttNetworkRequest memory request = AttNetworkRequest({
            url: "https://example.com/api",
            header: '{"Authorization":"Bearer token"}',
            method: "GET",
            body: '{"key":"value"}'
        });

        AttNetworkResponseResolve[] memory response = createSampleResponses();
        console.log("response leng",response.length);
        Attestor[] memory attes = createSampleAttestation();
        console.log("attes leng",attes.length);

        Attestation memory attestation = Attestation({
            recipient: address(this),
            request: request,
            reponse: response,
            data: '{"key":"value"}',
            attParameters: '{"param":"value"}',
            timestamp: uint64(block.timestamp),
            attestors: attes,
            signature: new bytes(0)
        });

        // 测量 Gas 消耗
        uint256 gasStart = gasleft();
        zkTLS.attestationEncode1(attestation);
        uint256 gasUsed = gasStart - gasleft();

        emit log_named_uint("Gas Used for attestationEncode packedencode", gasUsed);
    }


    function test_VerifierSignature() public view {
        
        AttNetworkRequest memory request = AttNetworkRequest({
            url: "https://example.com/api",
            header: '{"Authorization":"Bearer token"}',
            method: "GET",
            body: '{"key":"value"}'
        });
        address bob = address(0x122222111111);
        AttNetworkResponseResolve[] memory response = createSampleResponses();
        Attestor[] memory attes = createSampleAttestation();
        console.log("attestorAddr:%s",attes[0].attestorAddr);
       
        Attestation memory attestation = Attestation({
            recipient: bob,
            request: request,
            reponse: response,
            data: '{"key":"value"}',
            attParameters: '{"param":"value"}',
            timestamp: uint64(block.timestamp),
            attestors: attes,         
            signature: new bytes(0)
        });

        console.log("recipient----address:%s",addressToString(attestation.recipient));

        bytes32 digest = zkTLS.attestationEncode(attestation);
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(_signerPrivateKey, digest);
        console.log("r:%d s:%d v:%d",uint256(r),uint256(s),v);

        bytes memory signature = abi.encodePacked(r, s, v); //get signature
        console.log("signature----%s",bytesToHexString(signature));



        attestation.signature = signature;
        assertEq(zkTLS.verifyAttestation(attestation), true);

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
        bytes memory hexString = new bytes(data.length * 2); // 每字节占两字符

        for (uint256 i = 0; i < data.length; i++) {
            uint8 currentByte = uint8(data[i]);
            hexString[2 * i] = hexChars[currentByte >> 4]; // 高4位
            hexString[2 * i + 1] = hexChars[currentByte & 0x0f]; // 低4位
        }

        return string(hexString);
    }

}
