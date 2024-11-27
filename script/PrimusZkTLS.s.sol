// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../src/PrimusZkTLS.sol"; 

contract DeployPrimusZkTLS is Script {
    function run() external {
        // 1. 获取私钥
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // 2. 部署逻辑合约（Implementation）
        PrimusZkTLS logic = new PrimusZkTLS();

        // 3. 部署 ProxyAdmin
        ProxyAdmin proxyAdmin = new ProxyAdmin(address(0x11111111));
        
        // 4. 准备初始化数据
        bytes memory initializeData = abi.encodeWithSelector(
            PrimusZkTLS.initialize.selector,
            address(0x11111111) // 替换为实际的合约所有者地址
        );

        // 5. 部署 TransparentUpgradeableProxy
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(logic),
            address(proxyAdmin),
            initializeData
        );

        // 6. 打印部署的合约地址
        console.log("Logic Contract Address: ", address(logic));
        console.log("Proxy Admin Address: ", address(proxyAdmin));
        console.log("Proxy Contract Address: ", address(proxy));

        vm.stopBroadcast();
    }
}


// contract UpgradePrimusZkTLS is Script {
//     function run() external {
//         uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
//         vm.startBroadcast(deployerPrivateKey);

//         // 1. 部署新逻辑合约
//         PrimusZkTLS newLogic = new PrimusZkTLS();

//         // 2. 获取 ProxyAdmin 的地址和 Proxy 合约地址
//         address proxyAdminAddr = 0xProxyAdminAddress; // 替换为实际 ProxyAdmin 地址
//         address proxyAddr = 0xProxyAddress;          // 替换为实际 Proxy 地址

//         // 3. 调用 ProxyAdmin 的 upgrade 方法
//         ProxyAdmin proxyAdmin = ProxyAdmin(proxyAdminAddr);
//         proxyAdmin.upgrade(proxyAddr, address(newLogic));

//         console.log("Upgraded Proxy to New Logic Address: ", address(newLogic));

//         vm.stopBroadcast();
//     }
// }
