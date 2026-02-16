// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {BuyMeACoffee} from "../src/BuyMeACoffee.sol";

contract BuyMeACoffeeScript is Script {
    BuyMeACoffee public buyMeACoffee;

    function run() external returns (BuyMeACoffee) {
        address priceFeedAddress = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
        vm.startBroadcast();
        buyMeACoffee = new BuyMeACoffee(50, priceFeedAddress);
        vm.stopBroadcast();

        return buyMeACoffee;
    }
}
