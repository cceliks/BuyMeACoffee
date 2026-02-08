// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {BuyMeACoffee} from "../src/BuyMeACoffee.sol";

contract BuyMeACoffeeScript is Script {
    BuyMeACoffee public buyMeACoffee;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        buyMeACoffee = new BuyMeACoffee(50);
        vm.stopBroadcast();
    }
}
