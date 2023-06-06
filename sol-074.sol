// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// gas golf
contract GasGolf {
    uint public total;

    function sumIfEvenAndLessThan99(uint[] calldata nums) external {
        uint _total = total;
        uint len = nums.length;

        for (uint i = 0; i < len; ++i) {
            uint n = nums[i];
            if (n % 2 == 0 && n < 99) {
                _total += n;
            }
        }

        total = _total;
    }
}