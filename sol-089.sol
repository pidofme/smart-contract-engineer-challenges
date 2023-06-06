// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// We need to wrap address in a struct so that it can be passed around as a storage pointer.
library StorageSlot {
    // Code here
    struct AddressSlot {
        address value;
    }
    
    // This function will return the storage pointer at the slot from the input.
    function getAddressSlot(
        bytes32 slot
    ) internal pure returns (AddressSlot storage pointer) {
        assembly {
            // Get the pointer to AddressSlot stored at slot
            pointer.slot := slot
        }
    }
}

contract TestSlot {
    bytes32 public constant TEST_SLOT = keccak256("TEST_SLOT");

    // This function will store the address from the input _addr at the slot TEST_SLOT.
    function write(address _addr) external {
        // Code here
        // Use the library StorageSlot.getAddressSlot(TEST_SLOT) to get the storage pointer at TEST_SLOT.
        StorageSlot.AddressSlot storage data = StorageSlot.getAddressSlot(
            TEST_SLOT
        );
        data.value = _addr;
    }

    // This function will get the address stored at TEST_SLOT.
    function get() external view returns (address) {
        // Code here
        StorageSlot.AddressSlot storage data = StorageSlot.getAddressSlot(
            TEST_SLOT
        );
        return data.value;
    }
}
}