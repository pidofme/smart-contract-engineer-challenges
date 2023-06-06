// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./StorageSlot.sol";

contract TransparentUpgradeableProxy {
    // Code here
    
    // Define storage slots to store the address of admin and implementation contract
    bytes32 private constant IMPLEMENTATION_SLOT =
        bytes32(uint(keccak256("eip1967.proxy.implementation")) - 1);
    bytes32 private constant ADMIN_SLOT =
        bytes32(uint(keccak256("eip1967.proxy.admin")) - 1);

    modifier ifAdmin() {
        // Code here
        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _delegate(_getImplementation());
        }
    }
    
    fallback() external payable {
        _delegate(_getImplementation());
    }
    
    receive() external payable {
        _delegate(_getImplementation());
    }
    
    // Use the library StorageSlot to get address of admin stored at ADMIN_SLOT
    function _getAdmin() private view returns (address) {
        StorageSlot.AddressSlot storage data = StorageSlot.getAddressSlot(
              ADMIN_SLOT
          );
          return data.value;
    }
    
    // Require that _admin is not zero address
    // Use the library StorageSlot to set the admin address to the new admin _admin
    function _setAdmin(address _admin) private {
        require(_admin != address(0), "admin = zero address");
        StorageSlot.getAddressSlot(ADMIN_SLOT).value = _admin;
    }
    
    function _getImplementation() private view returns (address) {
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }
    
    function _setImplementation(address _impl) private {
        require(_impl.code.length > 0, "not contract");
        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = _impl;
    }
    
    constructor() {
        _setAdmin(msg.sender);
    }
    
    function changeAdmin(address _admin) external ifAdmin {
        _setAdmin(_admin);
    }
    
    function upgradeTo(address _impl) external  ifAdmin {
        _setImplementation(_impl);
    }
    
    // Note that this function cannot be a read-only function since StorageSlot has assembly code.
    function admin() external ifAdmin returns (address) {
        return _getAdmin();
    }
    
    function implementation() external ifAdmin returns (address) {
        return _getImplementation();
    }
    
    function _delegate(address _implementation) internal {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
    
            // calldatacopy(t, f, s) - copy s bytes from calldata at position f to mem at position t
            // calldatasize() - size of call data in bytes
            calldatacopy(0, 0, calldatasize())
    
            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
    
            // delegatecall(g, a, in, insize, out, outsize) -
            // - call contract at address a
            // - with input mem[in…(in+insize))
            // - providing g gas
            // - and output area mem[out…(out+outsize))
            // - returning 0 on error (eg. out of gas) and 1 on success
            let result := delegatecall(
                gas(),
                _implementation,
                0,
                calldatasize(),
                0,
                0
            )
    
            // Copy the returned data.
            // returndatacopy(t, f, s) - copy s bytes from returndata at position f to mem at position t
            // returndatasize() - size of the last returndata
            returndatacopy(0, 0, returndatasize())
    
            switch result
            // delegatecall returns 0 on error.
            case 0 {
                // revert(p, s) - end execution, revert state changes, return data mem[p…(p+s))
                revert(0, returndatasize())
            }
            default {
                // return(p, s) - end execution, return data mem[p…(p+s))
                return(0, returndatasize())
            }
        }
    }
}