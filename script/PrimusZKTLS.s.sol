// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../src/PrimusZKTLS.sol";

contract DeployPrimusZKTLS is Script {
    function run() external {
        // 1. Get private key
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);

        // 2. Deploy logic contract (implementation)
        PrimusZKTLS logic = new PrimusZKTLS();

        // 3. Prepare initialization data
        bytes memory initializeData = abi.encodeWithSelector(
            PrimusZKTLS.initialize.selector,
            deployerAddress // Replace with the actual owner address if needed
        );

        // 4. Deploy TransparentUpgradeableProxy
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(logic),
            deployerAddress,
            initializeData
        );

        // 5. Log contract addresses
        console.log("Logic Contract Address: ", address(logic));
        // console.log("Proxy Admin Address: ", address(proxyAdmin));
        console.log("Proxy Contract Address: ", address(proxy));

        vm.stopBroadcast();
    }
}

