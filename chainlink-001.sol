// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./AggregatorV3Interface.sol";

contract PriceOracle {
    AggregatorV3Interface private constant priceOracle = 
        AggregatorV3Interface(0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c);
    
    function getPrice() public view returns (int) {
        // Code
        (
            uint80 roundId,
            int answer,
            uint startedAt,
            uint updatedAt,
            uint80 answeredInRound
        ) = priceOracle.latestRoundData();
        
        require(updatedAt >= block.timestamp - 3 * 3600, "stale price");
        
        return answer * 1e10;
    }
}