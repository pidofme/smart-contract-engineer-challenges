// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./DeployWithCreate2.sol";

contract Create2Factory {
    event Deploy(address addr);

    function deploy(uint _salt) external {
        // Write your code here
        bytes32 salt = bytes32(_salt);
        
        DeployWithCreate2 _contract = new DeployWithCreate2{
            salt: salt
        }(msg.sender);
        
        emit Deploy(address(_contract));
    }
}