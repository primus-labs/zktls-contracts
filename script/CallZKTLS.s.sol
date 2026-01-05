// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script } from "forge-std/Script.sol";
import "../src/PrimusZKTLS.sol";

contract CallZkTLS is Script {
    function run() public {
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        //address senderAddress = vm.addr(senderPrivateKey);
        vm.startBroadcast(senderPrivateKey);

        // PrimusZKTLS primusZkTLS = PrimusZKTLS(address(0x1Ad7fD53206fDc3979C672C0466A1c48AF47B431));
        // Attestor memory attestor = Attestor({
        //     attestorAddr: address(0xe02bD7a6c8aA401189AEBb5Bad755c2610940A73),
        //     url: "https://primuslabs.xyz/"
        // });

        PrimusZKTLS primusZkTLS = PrimusZKTLS(address(0x4E78940F0019EbAEDc6F4995D7B8ABf060F7a341));
        Attestor memory attestor = Attestor({
            attestorAddr: address(0xDB736B13E2f522dBE18B2015d0291E4b193D8eF6),
            url: "https://primuslabs.xyz/"
        });

        primusZkTLS.setAttestor(attestor);

        vm.stopBroadcast();
    }
}
