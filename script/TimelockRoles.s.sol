// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

contract GrantTimelockRolesToMultisig is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        TimelockController timelock = TimelockController(payable(vm.envAddress("TIMELOCK_ADDRESS")));
        address multisig = vm.envAddress("MULTISIG_ADDRESS");

        vm.startBroadcast(privateKey);
        timelock.grantRole(timelock.DEFAULT_ADMIN_ROLE(), multisig);
        timelock.grantRole(timelock.PROPOSER_ROLE(), multisig);
        timelock.grantRole(timelock.CANCELLER_ROLE(), multisig);
        vm.stopBroadcast();

        console.log("Granted timelock roles to multisig:", multisig);
        console.log("DEFAULT_ADMIN_ROLE:", timelock.hasRole(timelock.DEFAULT_ADMIN_ROLE(), multisig));
        console.log("PROPOSER_ROLE:", timelock.hasRole(timelock.PROPOSER_ROLE(), multisig));
        console.log("CANCELLER_ROLE:", timelock.hasRole(timelock.CANCELLER_ROLE(), multisig));
    }
}

contract RevokeTimelockOperationRolesFromAccount is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        TimelockController timelock = TimelockController(payable(vm.envAddress("TIMELOCK_ADDRESS")));
        address account = vm.envAddress("ACCOUNT_ADDRESS");

        vm.startBroadcast(privateKey);
        timelock.revokeRole(timelock.PROPOSER_ROLE(), account);
        timelock.revokeRole(timelock.CANCELLER_ROLE(), account);
        vm.stopBroadcast();

        console.log("Revoked timelock operation roles from account:", account);
        console.log("PROPOSER_ROLE:", timelock.hasRole(timelock.PROPOSER_ROLE(), account));
        console.log("CANCELLER_ROLE:", timelock.hasRole(timelock.CANCELLER_ROLE(), account));
    }
}

contract RevokeTimelockDefaultAdminFromAccount is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        TimelockController timelock = TimelockController(payable(vm.envAddress("TIMELOCK_ADDRESS")));
        address account = vm.envAddress("ACCOUNT_ADDRESS");

        vm.startBroadcast(privateKey);
        timelock.revokeRole(timelock.DEFAULT_ADMIN_ROLE(), account);
        vm.stopBroadcast();

        console.log("Revoked timelock default admin from account:", account);
        console.log("DEFAULT_ADMIN_ROLE:", timelock.hasRole(timelock.DEFAULT_ADMIN_ROLE(), account));
    }
}

contract PrintTimelockRoles is Script {
    function run() external view {
        TimelockController timelock = TimelockController(payable(vm.envAddress("TIMELOCK_ADDRESS")));
        address account = vm.envAddress("ACCOUNT_ADDRESS");

        console.log("Timelock:", address(timelock));
        console.log("Account:", account);
        console.log("DEFAULT_ADMIN_ROLE:", timelock.hasRole(timelock.DEFAULT_ADMIN_ROLE(), account));
        console.log("PROPOSER_ROLE:", timelock.hasRole(timelock.PROPOSER_ROLE(), account));
        console.log("CANCELLER_ROLE:", timelock.hasRole(timelock.CANCELLER_ROLE(), account));
        console.log("EXECUTOR_ROLE:", timelock.hasRole(timelock.EXECUTOR_ROLE(), account));
    }
}
