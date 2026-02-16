// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {AggregatorV3Interface} from "foundry-chainlink-toolkit/src/interfaces/feeds/AggregatorV3Interface.sol";

library PriceConvertor {
    // ETH/USD address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
    function getETHPrice(address priceFeedAddress) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(priceFeedAddress);
        (, int256 price,,,) = priceFeed.latestRoundData();
        return uint256(price * 1e10);
    }

    function getConversionRate(uint256 ethAmount, address priceFeedAddress) public view returns (uint256) {
        uint256 ethPrice = getETHPrice(priceFeedAddress);
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUSD;
    }

    function getVersion(address priceFeedAddress) public view returns (uint256) {
        // sepolia ETH/USD: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        AggregatorV3Interface priceFeed = AggregatorV3Interface(priceFeedAddress);
        return priceFeed.version();
    }
}
