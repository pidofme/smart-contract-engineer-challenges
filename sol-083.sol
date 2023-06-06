// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract MostSignificantBit {
    function findMostSignificantBit(uint x) external pure returns (uint8 r) {
        // Code
        for (uint8 i = 128; i >= 1; i /= 2) {
            if (x >= 2 ** i) {
                x >>= i;
                r += i;
            }
        }
        
        return r;
    }
}