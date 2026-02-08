// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {PriceConvertor} from "../src/PriceConvertor.sol";
import {Test} from "forge-std/Test.sol";

contract PriceConvertorTest is Test {
    using PriceConvertor for uint256;

    address public priceFeedAddress = 0x694AA1769357215DE4FAC081bf1f309aDC325306;

    uint80 constant ROUND_ID = 123;
    int256 constant MOCK_PRICE = 200000000000; // 2000 USD per ETH (8 decimals)
    uint256 constant STARTED_AT = 1000;
    uint256 constant UPDATED_AT = 1000;
    uint80 constant ANSWERED_IN_ROUND = 123;

    function setUp() public {
        // Mock the latestRoundData call
        bytes memory mockData = abi.encode(ROUND_ID, MOCK_PRICE, STARTED_AT, UPDATED_AT, ANSWERED_IN_ROUND);
        vm.mockCall(priceFeedAddress, abi.encodeWithSignature("latestRoundData()"), mockData);

        // Mock the version call
        bytes memory versionData = abi.encode(uint256(4));
        vm.mockCall(priceFeedAddress, abi.encodeWithSignature("version()"), versionData);
    }

    function testGetETHPrice() public view {
        // MOCK_PRICE is 200000000000 (2000 USD in 8 decimals)
        // getETHPrice() multiplies by 1e10 to convert to 18 decimals
        // Expected: 200000000000 * 1e10 = 2000 * 1e18
        uint256 expectedPrice = 2000 * 1e18;
        uint256 actualPrice = PriceConvertor.getETHPrice();
        assertEq(actualPrice, expectedPrice);
    }

    function testGetConversionRate() public view {
        // 1 ETH should convert to 2000 USD (based on mock price)
        uint256 ethAmount = 1e18;
        uint256 expectedUSD = 2000 * 1e18;
        uint256 actualUSD = PriceConvertor.getConversionRate(ethAmount);
        assertEq(actualUSD, expectedUSD);
    }

    function testGetConversionRate_HalfETH() public view {
        // 0.5 ETH should convert to 1000 USD
        uint256 ethAmount = 5e17; // 0.5 ETH
        uint256 expectedUSD = 1000 * 1e18;
        uint256 actualUSD = PriceConvertor.getConversionRate(ethAmount);
        assertEq(actualUSD, expectedUSD);
    }

    function testGetConversionRate_TenETH() public view {
        // 10 ETH should convert to 20000 USD
        uint256 ethAmount = 10e18;
        uint256 expectedUSD = 20000 * 1e18;
        uint256 actualUSD = PriceConvertor.getConversionRate(ethAmount);
        assertEq(actualUSD, expectedUSD);
    }

    function testGetVersion() public view {
        uint256 expectedVersion = 4;
        uint256 actualVersion = PriceConvertor.getVersion();
        assertEq(actualVersion, expectedVersion);
    }

    function testLibraryIntegration_UsingForSyntax() public view {
        // Test the library using "using for" syntax
        uint256 ethAmount = 1e18;
        uint256 expectedUSD = 2000 * 1e18;
        uint256 actualUSD = ethAmount.getConversionRate();
        assertEq(actualUSD, expectedUSD);
    }
}
