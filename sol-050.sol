// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IERC20.sol";

contract ERC20 is IERC20 {
    uint public totalSupply = 1000;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "TestToken";
    string public symbol = "TEST";
    uint8 public decimals = 18;

    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address recipient, uint amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        require(balanceOf[sender] >= amount, "insufficient balance");
        require(allowance[sender][msg.sender] >= amount, "out of allowance");
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    // This function is not part of ERC20 standard but it is a common function present in many tokens.

    // Usually only an authorized account will be able to mint new tokens but for this exercise, we will skip the access control.
    function mint(uint amount) external {
        // code
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    // burn is not part of ERC20 standard but it is a common function present in many tokens.
    function burn(uint amount) external {
        // code
        require(balanceOf[msg.sender] >= amount, "insufficient balance");
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}