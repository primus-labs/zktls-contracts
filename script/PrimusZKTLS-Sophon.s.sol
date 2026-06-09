// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../src/PrimusZKTLS.sol";
import "../src/IPrimusZKTLS.sol";
import {TestExt} from "lib/forge-zksync-std/src/TestExt.sol";

contract DeployPrimusZKTLS is Script, TestExt {
    function run() external {
        // 1. Get private key
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);

        // Encode paymaster input
        bytes memory paymaster_encoded_input = abi.encodeWithSelector(bytes4(keccak256("general(bytes)")), bytes("0x"));
        vmExt.zkUsePaymaster(vm.envAddress("PAYMASTER_ADDRESS"), paymaster_encoded_input);

        // 2. Deploy logic contract (implementation)
        // PrimusZKTLS logic = new PrimusZKTLS();
        // sophontestnet logic: 0x73bb5892283c0d5420AB9B8B66F662b90D937096
        Attestor[] memory initialAttestors = initialAttestorsFromEnv();

        // 3. Prepare initialization data
        bytes memory initializeData = abi.encodeWithSelector(
            PrimusZKTLS.initialize.selector,
            deployerAddress, // Replace with the actual owner address if needed
            initialAttestors
        );

        // 4. Deploy TransparentUpgradeableProxy
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(0x73bb5892283c0d5420AB9B8B66F662b90D937096), deployerAddress, initializeData
        );
        // sophontestnet proxy: 0x7068da2522c3Ba1f24594ce20E7d7A8EF574E89f

        // 5. Log contract addresses
        // console.log("Logic Contract Address: ", address(logic));
        // console.log("Proxy Admin Address: ", address(proxyAdmin));
        // console.log("Proxy Contract Address: ", address(proxy));

        vm.stopBroadcast();
    }

    function initialAttestorsFromEnv() internal view returns (Attestor[] memory initialAttestors) {
        initialAttestors = new Attestor[](3);
        initialAttestors[0] =
            Attestor({attestorAddr: vm.envAddress("ATTESTOR_1_ADDRESS"), url: vm.envString("ATTESTOR_1_URL")});
        initialAttestors[1] =
            Attestor({attestorAddr: vm.envAddress("ATTESTOR_2_ADDRESS"), url: vm.envString("ATTESTOR_2_URL")});
        initialAttestors[2] =
            Attestor({attestorAddr: vm.envAddress("ATTESTOR_3_ADDRESS"), url: vm.envString("ATTESTOR_3_URL")});
    }
}
