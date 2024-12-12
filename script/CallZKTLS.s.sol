// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script } from "forge-std/Script.sol";
import "../src/PrimusZKTLS.sol";

contract CallZkTLS is Script {
    function run() public {
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        //address senderAddress = vm.addr(senderPrivateKey);
        vm.startBroadcast(senderPrivateKey);

        PrimusZKTLS primusZkTLS = PrimusZKTLS(address(0xB3d8DDDc793F75a930313785e5d1612747093f25));
        Attestor memory attestor = Attestor({
            attestorAddr: address(0xe02bD7a6c8aA401189AEBb5Bad755c2610940A73),
            url: "https://primuslabs.xyz/"
        });
        primusZkTLS.setAttestor(attestor);

        vm.stopBroadcast();
    }
}
