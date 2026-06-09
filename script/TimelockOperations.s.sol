// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {PrimusZKTLS} from "../src/PrimusZKTLS.sol";
import {Attestor} from "../src/IPrimusZKTLS.sol";

library PrimusZKTLSTimelockOps {
    bytes32 internal constant PREDECESSOR = bytes32(0);

    function setAttestorData(address attestorAddr, string memory url) internal pure returns (bytes memory) {
        return abi.encodeCall(PrimusZKTLS.setAttestor, (Attestor({attestorAddr: attestorAddr, url: url})));
    }

    function removeAttestorData(address attestorAddr) internal pure returns (bytes memory) {
        return abi.encodeCall(PrimusZKTLS.removeAttestor, (attestorAddr));
    }

    function upgradeData(address proxy, address implementation) internal pure returns (bytes memory) {
        return
            abi.encodeCall(ProxyAdmin.upgradeAndCall, (ITransparentUpgradeableProxy(proxy), implementation, bytes("")));
    }

    function setAttestorSalt(address proxy, address attestorAddr, string memory url) internal view returns (bytes32) {
        return keccak256(abi.encode("PrimusZKTLS:setAttestor", block.chainid, proxy, attestorAddr, url));
    }

    function removeAttestorSalt(address proxy, address attestorAddr) internal view returns (bytes32) {
        return keccak256(abi.encode("PrimusZKTLS:removeAttestor", block.chainid, proxy, attestorAddr));
    }

    function upgradeSalt(address proxyAdmin, address proxy, address implementation) internal view returns (bytes32) {
        return keccak256(abi.encode("PrimusZKTLS:upgrade", block.chainid, proxyAdmin, proxy, implementation));
    }
}

contract PrimusZKTLSProxyAdminResolver is Script {
    bytes32 internal constant ERC1967_ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    function _proxyAdmin(address proxy) internal view returns (address) {
        return address(uint160(uint256(vm.load(proxy, ERC1967_ADMIN_SLOT))));
    }
}

contract ScheduleSetAttestorPrimusZKTLS is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        TimelockController timelock = TimelockController(payable(vm.envAddress("TIMELOCK_ADDRESS")));
        address proxy = vm.envAddress("PROXY_ADDRESS");
        address attestorAddr = vm.envAddress("ATTESTOR_ADDRESS");
        string memory url = vm.envString("ATTESTOR_URL");

        bytes memory data = PrimusZKTLSTimelockOps.setAttestorData(attestorAddr, url);
        bytes32 salt = PrimusZKTLSTimelockOps.setAttestorSalt(proxy, attestorAddr, url);
        uint256 delay = timelock.getMinDelay();

        vm.startBroadcast(privateKey);
        timelock.schedule(proxy, 0, data, PrimusZKTLSTimelockOps.PREDECESSOR, salt, delay);
        vm.stopBroadcast();

        console.log("Scheduled setAttestor");
        console.log("Target proxy:", proxy);
        console.log("Attestor:", attestorAddr);
        console.log("Delay:", delay);
        console.logBytes32(salt);
    }
}

contract ExecuteSetAttestorPrimusZKTLS is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        TimelockController timelock = TimelockController(payable(vm.envAddress("TIMELOCK_ADDRESS")));
        address proxy = vm.envAddress("PROXY_ADDRESS");
        address attestorAddr = vm.envAddress("ATTESTOR_ADDRESS");
        string memory url = vm.envString("ATTESTOR_URL");

        bytes memory data = PrimusZKTLSTimelockOps.setAttestorData(attestorAddr, url);
        bytes32 salt = PrimusZKTLSTimelockOps.setAttestorSalt(proxy, attestorAddr, url);

        vm.startBroadcast(privateKey);
        timelock.execute(proxy, 0, data, PrimusZKTLSTimelockOps.PREDECESSOR, salt);
        vm.stopBroadcast();

        console.log("Executed setAttestor");
        console.logBytes32(salt);
    }
}

contract ScheduleRemoveAttestorPrimusZKTLS is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        TimelockController timelock = TimelockController(payable(vm.envAddress("TIMELOCK_ADDRESS")));
        address proxy = vm.envAddress("PROXY_ADDRESS");
        address attestorAddr = vm.envAddress("ATTESTOR_ADDRESS");

        bytes memory data = PrimusZKTLSTimelockOps.removeAttestorData(attestorAddr);
        bytes32 salt = PrimusZKTLSTimelockOps.removeAttestorSalt(proxy, attestorAddr);
        uint256 delay = timelock.getMinDelay();

        vm.startBroadcast(privateKey);
        timelock.schedule(proxy, 0, data, PrimusZKTLSTimelockOps.PREDECESSOR, salt, delay);
        vm.stopBroadcast();

        console.log("Scheduled removeAttestor");
        console.log("Target proxy:", proxy);
        console.log("Attestor:", attestorAddr);
        console.log("Delay:", delay);
        console.logBytes32(salt);
    }
}

contract ExecuteRemoveAttestorPrimusZKTLS is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        TimelockController timelock = TimelockController(payable(vm.envAddress("TIMELOCK_ADDRESS")));
        address proxy = vm.envAddress("PROXY_ADDRESS");
        address attestorAddr = vm.envAddress("ATTESTOR_ADDRESS");

        bytes memory data = PrimusZKTLSTimelockOps.removeAttestorData(attestorAddr);
        bytes32 salt = PrimusZKTLSTimelockOps.removeAttestorSalt(proxy, attestorAddr);

        vm.startBroadcast(privateKey);
        timelock.execute(proxy, 0, data, PrimusZKTLSTimelockOps.PREDECESSOR, salt);
        vm.stopBroadcast();

        console.log("Executed removeAttestor");
        console.logBytes32(salt);
    }
}

contract ScheduleUpgradePrimusZKTLS is PrimusZKTLSProxyAdminResolver {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        TimelockController timelock = TimelockController(payable(vm.envAddress("TIMELOCK_ADDRESS")));
        address proxy = vm.envAddress("PROXY_ADDRESS");
        address proxyAdmin = _proxyAdmin(proxy);

        vm.startBroadcast(privateKey);
        PrimusZKTLS newLogic = new PrimusZKTLS();
        bytes memory data = PrimusZKTLSTimelockOps.upgradeData(proxy, address(newLogic));
        bytes32 salt = PrimusZKTLSTimelockOps.upgradeSalt(proxyAdmin, proxy, address(newLogic));
        uint256 delay = timelock.getMinDelay();

        timelock.schedule(proxyAdmin, 0, data, PrimusZKTLSTimelockOps.PREDECESSOR, salt, delay);
        vm.stopBroadcast();

        console.log("New Logic Contract Address:", address(newLogic));
        console.log("Scheduled upgrade");
        console.log("ProxyAdmin:", proxyAdmin);
        console.log("Proxy:", proxy);
        console.log("Delay:", delay);
        console.logBytes32(salt);
    }
}

contract ExecuteUpgradePrimusZKTLS is PrimusZKTLSProxyAdminResolver {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        TimelockController timelock = TimelockController(payable(vm.envAddress("TIMELOCK_ADDRESS")));
        address proxy = vm.envAddress("PROXY_ADDRESS");
        address proxyAdmin = _proxyAdmin(proxy);
        address newLogic = vm.envAddress("NEW_LOGIC_ADDRESS");

        bytes memory data = PrimusZKTLSTimelockOps.upgradeData(proxy, newLogic);
        bytes32 salt = PrimusZKTLSTimelockOps.upgradeSalt(proxyAdmin, proxy, newLogic);

        vm.startBroadcast(privateKey);
        timelock.execute(proxyAdmin, 0, data, PrimusZKTLSTimelockOps.PREDECESSOR, salt);
        vm.stopBroadcast();

        console.log("Executed upgrade");
        console.logBytes32(salt);
    }
}
