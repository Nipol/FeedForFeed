// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/FFF.sol";

contract FFFScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        FFF fff = new FFF();

        vm.stopBroadcast();
    }
}
