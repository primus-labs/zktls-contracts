// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../src/PrimusZkTLS.sol";

contract DeployPrimusZkTLS is Script {
    function run() external {
        // 1. Get private key
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);

        // 2. Deploy logic contract (implementation)
        PrimusZkTLS logic = new PrimusZkTLS();

        // 3. Deploy ProxyAdmin
        ProxyAdmin proxyAdmin = new ProxyAdmin(deployerAddress);

        // 4. Prepare initialization data
        bytes memory initializeData = abi.encodeWithSelector(
            PrimusZkTLS.initialize.selector,
            deployerAddress // Replace with the actual owner address if needed
        );

        // 5. Deploy TransparentUpgradeableProxy
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(logic),
            address(proxyAdmin),
            initializeData
        );

        // 6. Log contract addresses
        console.log("Logic Contract Address: ", address(logic));
        console.log("Proxy Admin Address: ", address(proxyAdmin));
        console.log("Proxy Contract Address: ", address(proxy));

        vm.stopBroadcast();
    }
}

contract UpgradePrimusZkTLS is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy the new logic contract
        PrimusZkTLS newLogic = new PrimusZkTLS();

        // 2. Retrieve the ProxyAdmin address and Proxy contract address
        address proxyAdminAddr = address(0x11111); // Replace with the actual ProxyAdmin address
        address proxyAddr = address(0x2222);           // Replace with the actual Proxy address

        // 3. Call the upgrade method of ProxyAdmin
        ProxyAdmin proxyAdmin = ProxyAdmin(proxyAdminAddr);
        ITransparentUpgradeableProxy proxy = ITransparentUpgradeableProxy(proxyAddr);
        proxyAdmin.upgradeAndCall(proxy, address(newLogic),"");

        console.log("Upgraded Proxy to New Logic Address: ", address(newLogic));

        vm.stopBroadcast();
    }
}