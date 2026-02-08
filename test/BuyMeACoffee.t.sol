// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {BuyMeACoffee} from "../src/BuyMeACoffee.sol";
import {Test} from "forge-std/Test.sol";

contract BuyMeACoffeeTest is Test {
    address public owner = address(1);
    address public funder1 = address(2);
    address public funder2 = address(3);
    address public funder3 = address(4);

    address public priceFeedAddress = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    BuyMeACoffee public buyMeACoffee;

    event Funded(address indexed funder, uint256 amount);
    event Withdrawn(uint256 amount);

    function setUp() public {
        // Allocate ETH to test accounts
        vm.deal(funder1, 10e18);
        vm.deal(funder2, 10e18);
        vm.deal(funder3, 10e18);

        vm.prank(owner);
        // Initialize the contract with a minimum USD value of 50
        buyMeACoffee = new BuyMeACoffee(50);

        assertEq(address(owner), buyMeACoffee.owner());

        // Mock the price feed to return 2000 USD per ETH
        bytes memory mockData = abi.encode(uint80(0), int256(200000000000), uint256(0), uint256(0), uint80(0));
        vm.mockCall(priceFeedAddress, abi.encodeWithSignature("latestRoundData()"), mockData);
    }

    function testFund() public {
        vm.prank(funder1);
        // expect revert with MinimumUSDNotMet error when sending less than 50 USD worth of ETH
        vm.expectRevert(BuyMeACoffee.MinimumUSDNotMet.selector);
        // 20 wei
        buyMeACoffee.fund{value: 20}();

        vm.prank(funder1);
        vm.expectEmit();
        emit Funded(funder1, 1e18);
        buyMeACoffee.fund{value: 1e18}();

        assertEq(buyMeACoffee.addressToAmountFunded(funder1), 1e18);
        assertEq(buyMeACoffee.funders(0), funder1);
    }

    function testWithdraw() public {
        vm.prank(funder1);
        buyMeACoffee.fund{value: 1e18}();
        vm.prank(funder2);
        buyMeACoffee.fund{value: 4e18}();
        vm.prank(funder3);
        buyMeACoffee.fund{value: 2e18}();

        assertEq(buyMeACoffee.addressToAmountFunded(funder1), 1e18);
        assertEq(buyMeACoffee.addressToAmountFunded(funder2), 4e18);
        assertEq(buyMeACoffee.addressToAmountFunded(funder3), 2e18);

        vm.prank(funder1);
        vm.expectRevert();
        buyMeACoffee.withdraw();

        vm.prank(owner);
        vm.expectEmit();
        emit Withdrawn(7e18);

        buyMeACoffee.withdraw();
        assertEq(owner.balance, 7e18);
        assertEq(address(buyMeACoffee).balance, 0);

        assertEq(buyMeACoffee.addressToAmountFunded(funder1), 0);
        assertEq(buyMeACoffee.addressToAmountFunded(funder2), 0);
        assertEq(buyMeACoffee.addressToAmountFunded(funder3), 0);
    }
}
