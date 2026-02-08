// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {PriceConvertor} from "./PriceConvertor.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

contract BuyMeACoffee is Ownable {
    error MinimumUSDNotMet();

    event Funded(address indexed funder, uint256 amount);
    event Withdrawn(uint256 amount);

    using PriceConvertor for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    uint256 public immutable i_minimumUSD;

    constructor(uint256 _minimumUSD) Ownable() {
        i_minimumUSD = _minimumUSD * 1e18;
    }

    modifier checkMinimumUSD() {
        if (msg.value.getConversionRate() < i_minimumUSD) {
            revert MinimumUSDNotMet();
        }
        _;
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
}
