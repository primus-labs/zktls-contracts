// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {PrimusZKTLS} from "../src/PrimusZKTLS.sol";
import {Attestor} from "../src/IPrimusZKTLS.sol";

library PrimusZKTLSDeploymentLib {
    function deploy(address logic, address multisig, uint256 minDelay, Attestor[] memory initialAttestors)
        internal
        returns (TimelockController timelock, TransparentUpgradeableProxy proxy)
    {
        require(logic != address(0), "Invalid logic");
        require(multisig != address(0), "Invalid multisig");
        require(initialAttestors.length > 0, "Initial attestors required");

        address[] memory proposers = new address[](1);
        proposers[0] = multisig;

        address[] memory executors = new address[](1);
        executors[0] = address(0);

        timelock = new TimelockController(minDelay, proposers, executors, multisig);

        bytes memory initializeData =
            abi.encodeWithSelector(PrimusZKTLS.initialize.selector, address(timelock), initialAttestors);

        proxy = new TransparentUpgradeableProxy(logic, address(timelock), initializeData);
    }
}

contract DeployPrimusZKTLS is Script {
    function run() external {
        // 1. Get private key
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);
        address multisig = vm.envAddress("MULTISIG_ADDRESS");
        uint256 minDelay = vm.envOr("TIMELOCK_MIN_DELAY", uint256(1 days));
        Attestor[] memory initialAttestors = initialAttestorsFromEnv();

        console.log("Deployer Address: ", deployerAddress);
        console.log("Multisig Address: ", multisig);
        console.log("Timelock Min Delay: ", minDelay);
        vm.startBroadcast(deployerPrivateKey);

        // 2. Deploy logic contract (implementation)
        PrimusZKTLS logic = new PrimusZKTLS();

        (TimelockController timelock, TransparentUpgradeableProxy proxy) =
            PrimusZKTLSDeploymentLib.deploy(address(logic), multisig, minDelay, initialAttestors);

        // 5. Log contract addresses
        console.log("Logic Contract Address: ", address(logic));
        console.log("Timelock Address: ", address(timelock));
        console.log("Proxy Contract Address: ", address(proxy));

        vm.stopBroadcast();
    }

    function initialAttestorsFromEnv() internal view returns (Attestor[] memory initialAttestors) {
        initialAttestors = new Attestor[](3);
        initialAttestors[0] = Attestor({attestorAddr: vm.envAddress("ATTESTOR_1_ADDRESS"), url: ""});
        initialAttestors[1] = Attestor({attestorAddr: vm.envAddress("ATTESTOR_2_ADDRESS"), url: ""});
        initialAttestors[2] = Attestor({attestorAddr: vm.envAddress("ATTESTOR_3_ADDRESS"), url: ""});
    }
}
