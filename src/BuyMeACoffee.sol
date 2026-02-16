// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {PriceConvertor} from "./PriceConvertor.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {AggregatorV3Interface} from "foundry-chainlink-toolkit/src/interfaces/feeds/AggregatorV3Interface.sol";

contract BuyMeACoffee is Ownable {
    error MinimumUSDNotMet();

    event Funded(address indexed funder, uint256 amount);
    event Withdrawn(uint256 amount);

    modifier checkMinimumUSD() {
        if (msg.value.getConversionRate(address(priceFeed)) < i_minimumUSD) {
            revert MinimumUSDNotMet();
        }
        _;
    }

    using PriceConvertor for uint256;

    AggregatorV3Interface public priceFeed;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    uint256 public immutable i_minimumUSD;

    constructor(uint256 _minimumUSD, address _priceFeed) Ownable(msg.sender) {
        i_minimumUSD = _minimumUSD * 1e18;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function fund() public payable checkMinimumUSD {
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;

        emit Funded(msg.sender, msg.value);
    }

    function withdraw() public onlyOwner {
        uint256 amount;
        for (uint256 i; i < funders.length; i++) {
            address funder = funders[i];
            amount += addressToAmountFunded[funder];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        (bool success,) = payable(owner()).call{value: amount}("");
        require(success, "Withdraw failed");

        emit Withdrawn(amount);
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
