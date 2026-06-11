// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {
    ITransparentUpgradeableProxy,
    TransparentUpgradeableProxy
} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {PrimusZKTLS} from "../src/PrimusZKTLS.sol";
import {Attestor} from "../src/IPrimusZKTLS.sol";
import {PrimusZKTLSDeploymentLib} from "../script/PrimusZKTLS.s.sol";
import {PrimusZKTLSTimelockOps, PrimusZKTLSProxyAdminResolver} from "../script/TimelockOperations.s.sol";

contract TimelockProxyAdminResolverHarness is PrimusZKTLSProxyAdminResolver {
    function proxyAdminOf(address proxy) external view returns (address) {
        return _proxyAdmin(proxy);
    }
}

contract PrimusZKTLSTimelockTest is Test {
    bytes32 private constant ERC1967_ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;
    bytes32 private constant ERC1967_IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    uint256 private constant MIN_DELAY = 1 days;

    address private multisig = address(0xBEEF);
    address private attestor = address(0xA77E5702);

    function testDeploysProxyAndContractOwnershipBehindTimelock() public {
        PrimusZKTLS logic = new PrimusZKTLS();
        Attestor[] memory initialAttestors = _initialAttestors();

        (TimelockController timelock, TransparentUpgradeableProxy proxy) =
            PrimusZKTLSDeploymentLib.deploy(address(logic), multisig, MIN_DELAY, initialAttestors);

        ProxyAdmin proxyAdmin = ProxyAdmin(_proxyAdmin(address(proxy)));
        PrimusZKTLS zktls = PrimusZKTLS(address(proxy));

        assertEq(zktls.owner(), address(timelock));
        assertEq(proxyAdmin.owner(), address(timelock));
        assertTrue(timelock.hasRole(timelock.PROPOSER_ROLE(), multisig));
        assertTrue(timelock.hasRole(timelock.CANCELLER_ROLE(), multisig));
        assertTrue(timelock.hasRole(timelock.EXECUTOR_ROLE(), address(0)));
        assertEq(timelock.getMinDelay(), MIN_DELAY);

        (address firstAttestor,) = zktls._attestors(0);
        (address secondAttestor,) = zktls._attestors(1);
        (address thirdAttestor,) = zktls._attestors(2);

        assertEq(firstAttestor, initialAttestors[0].attestorAddr);
        assertEq(secondAttestor, initialAttestors[1].attestorAddr);
        assertEq(thirdAttestor, initialAttestors[2].attestorAddr);

        (address timelockAttestor,) = zktls._attestorsMapping(address(timelock));
        assertEq(timelockAttestor, address(0));
    }

    function testTimelockRolesCanMigrateFromEoaToMultisig() public {
        address eoaAdmin = address(0xE0A);
        address safeMultisig = address(0x5AFE);
        address[] memory proposers = new address[](1);
        proposers[0] = eoaAdmin;
        address[] memory executors = new address[](1);
        executors[0] = address(0);
        TimelockController timelock = new TimelockController(MIN_DELAY, proposers, executors, eoaAdmin);

        vm.startPrank(eoaAdmin);
        timelock.grantRole(timelock.DEFAULT_ADMIN_ROLE(), safeMultisig);
        timelock.grantRole(timelock.PROPOSER_ROLE(), safeMultisig);
        timelock.grantRole(timelock.CANCELLER_ROLE(), safeMultisig);
        timelock.revokeRole(timelock.PROPOSER_ROLE(), eoaAdmin);
        timelock.revokeRole(timelock.CANCELLER_ROLE(), eoaAdmin);
        timelock.revokeRole(timelock.DEFAULT_ADMIN_ROLE(), eoaAdmin);
        vm.stopPrank();

        assertTrue(timelock.hasRole(timelock.DEFAULT_ADMIN_ROLE(), safeMultisig));
        assertTrue(timelock.hasRole(timelock.PROPOSER_ROLE(), safeMultisig));
        assertTrue(timelock.hasRole(timelock.CANCELLER_ROLE(), safeMultisig));
        assertFalse(timelock.hasRole(timelock.DEFAULT_ADMIN_ROLE(), eoaAdmin));
        assertFalse(timelock.hasRole(timelock.PROPOSER_ROLE(), eoaAdmin));
        assertFalse(timelock.hasRole(timelock.CANCELLER_ROLE(), eoaAdmin));
        assertTrue(timelock.hasRole(timelock.EXECUTOR_ROLE(), address(0)));

        bytes memory data = "";
        bytes32 salt = keccak256("multisig controls timelock");

        vm.expectRevert();
        vm.prank(eoaAdmin);
        timelock.schedule(address(0x1234), 0, data, bytes32(0), salt, MIN_DELAY);

        vm.prank(safeMultisig);
        timelock.schedule(address(0x1234), 0, data, bytes32(0), salt, MIN_DELAY);
    }

    function testAttestorChangesRequireTimelockDelay() public {
        PrimusZKTLS logic = new PrimusZKTLS();

        (TimelockController timelock, TransparentUpgradeableProxy proxy) =
            PrimusZKTLSDeploymentLib.deploy(address(logic), multisig, MIN_DELAY, _initialAttestors());

        PrimusZKTLS zktls = PrimusZKTLS(address(proxy));
        Attestor memory nextAttestor = Attestor({attestorAddr: attestor, url: "https://attestor.example"});
        bytes memory data = abi.encodeCall(PrimusZKTLS.setAttestor, (nextAttestor));
        bytes32 predecessor = bytes32(0);
        bytes32 salt = keccak256("add attestor");

        vm.expectRevert();
        zktls.setAttestor(nextAttestor);

        vm.prank(multisig);
        timelock.schedule(address(zktls), 0, data, predecessor, salt, MIN_DELAY);

        vm.expectRevert();
        timelock.execute(address(zktls), 0, data, predecessor, salt);

        vm.warp(block.timestamp + MIN_DELAY);
        timelock.execute(address(zktls), 0, data, predecessor, salt);

        (address storedAttestor, string memory storedUrl) = zktls._attestorsMapping(attestor);
        assertEq(storedAttestor, attestor);
        assertEq(storedUrl, nextAttestor.url);
    }

    function testUpgradesRequireTimelockDelay() public {
        PrimusZKTLS logic = new PrimusZKTLS();

        (TimelockController timelock, TransparentUpgradeableProxy proxy) =
            PrimusZKTLSDeploymentLib.deploy(address(logic), multisig, MIN_DELAY, _initialAttestors());

        ProxyAdmin proxyAdmin = ProxyAdmin(_proxyAdmin(address(proxy)));
        PrimusZKTLS newLogic = new PrimusZKTLS();
        bytes memory data = abi.encodeCall(
            ProxyAdmin.upgradeAndCall, (ITransparentUpgradeableProxy(address(proxy)), address(newLogic), bytes(""))
        );
        bytes32 predecessor = bytes32(0);
        bytes32 salt = keccak256("upgrade zktls");

        vm.expectRevert();
        proxyAdmin.upgradeAndCall(ITransparentUpgradeableProxy(address(proxy)), address(newLogic), bytes(""));

        vm.prank(multisig);
        timelock.schedule(address(proxyAdmin), 0, data, predecessor, salt, MIN_DELAY);

        vm.expectRevert();
        timelock.execute(address(proxyAdmin), 0, data, predecessor, salt);

        vm.warp(block.timestamp + MIN_DELAY);
        timelock.execute(address(proxyAdmin), 0, data, predecessor, salt);

        assertEq(_implementation(address(proxy)), address(newLogic));
    }

    function testTimelockOperationsResolveProxyAdminFromProxy() public {
        PrimusZKTLS logic = new PrimusZKTLS();

        (, TransparentUpgradeableProxy proxy) =
            PrimusZKTLSDeploymentLib.deploy(address(logic), multisig, MIN_DELAY, _initialAttestors());

        TimelockProxyAdminResolverHarness resolver = new TimelockProxyAdminResolverHarness();

        assertEq(resolver.proxyAdminOf(address(proxy)), _proxyAdmin(address(proxy)));
    }

    function testTimelockOperationsEncodeSafeScheduleCalldata() public view {
        address target = address(0x1234);
        bytes memory data = abi.encodeCall(PrimusZKTLS.removeAttestor, (attestor));
        bytes32 salt = keccak256("safe schedule");

        bytes memory safeCalldata = PrimusZKTLSTimelockOps.scheduleCalldata(target, data, salt, MIN_DELAY);

        assertEq(
            safeCalldata,
            abi.encodeCall(
                TimelockController.schedule, (target, 0, data, PrimusZKTLSTimelockOps.PREDECESSOR, salt, MIN_DELAY)
            )
        );
    }

    function testTimelockOperationsEncodeSafeExecuteCalldata() public view {
        address target = address(0x1234);
        bytes memory data = abi.encodeCall(PrimusZKTLS.removeAttestor, (attestor));
        bytes32 salt = keccak256("safe execute");

        bytes memory safeCalldata = PrimusZKTLSTimelockOps.executeCalldata(target, data, salt);

        assertEq(
            safeCalldata,
            abi.encodeCall(TimelockController.execute, (target, 0, data, PrimusZKTLSTimelockOps.PREDECESSOR, salt))
        );
    }

    function _proxyAdmin(address proxy) private view returns (address) {
        return address(uint160(uint256(vm.load(proxy, ERC1967_ADMIN_SLOT))));
    }

    function _implementation(address proxy) private view returns (address) {
        return address(uint160(uint256(vm.load(proxy, ERC1967_IMPLEMENTATION_SLOT))));
    }

    function _initialAttestors() private pure returns (Attestor[] memory initialAttestors) {
        initialAttestors = new Attestor[](3);
        initialAttestors[0] = Attestor({attestorAddr: address(0xA11CE), url: "https://attestor-1.example"});
        initialAttestors[1] = Attestor({attestorAddr: address(0xB0B), url: "https://attestor-2.example"});
        initialAttestors[2] = Attestor({attestorAddr: address(0xCAFE), url: "https://attestor-3.example"});
    }
}
