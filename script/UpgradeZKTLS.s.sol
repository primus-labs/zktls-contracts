// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../src/PrimusZKTLS.sol";

contract UpgradePrimusZKTLS is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy the new logic contract
        PrimusZKTLS newLogic = new PrimusZKTLS();

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
