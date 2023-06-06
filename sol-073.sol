// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract TimeLock {
    event Queue(
        bytes32 indexed txId,
        address indexed target,
        uint value,
        string func,
        bytes data,
        uint timestamp
    );
    event Execute(
        bytes32 indexed txId,
        address indexed target,
        uint value,
        string func,
        bytes data,
        uint timestamp
    );
    event Cancel(bytes32 indexed txId);

    uint public constant MIN_DELAY = 10; // seconds
    uint public constant MAX_DELAY = 1000; // seconds
    uint public constant GRACE_PERIOD = 1000; // seconds

    address public owner;
    // tx id => queued
    mapping(bytes32 => bool) public queued;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {}

    function getTxId(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_target, _value, _func, _data, _timestamp));
    }

    /**
     * @param _target Address of contract or account to call
     * @param _value Amount of ETH to send
     * @param _func Function signature, for example "foo(address,uint256)"
     * @param _data ABI encoded data send.
     * @param _timestamp Timestamp after which the transaction can be executed.
     */
    function queue(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) external returns (bytes32 txId) {
        // code
        require(msg.sender == owner, "owner only");
        require(block.timestamp + MIN_DELAY < _timestamp &&
            block.timestamp + MAX_DELAY > _timestamp, "invalid delay time");
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);
        require(!queued[txId], "queued");
        queued[txId] = true;
        emit Queue(txId, _target, _value, _func, _data, _timestamp);
    }

    function execute(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) external payable returns (bytes memory) {
        // code
        require(msg.sender == owner, "owner only");
        require(block.timestamp > _timestamp &&
            block.timestamp - GRACE_PERIOD < _timestamp, "invalid delay time");
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);
        require(queued[txId], "not queued");
        delete queued[txId];
        bytes memory data;
        if (bytes(_func).length > 0) {
            // data = func selector + _data
            data = abi.encodePacked(bytes4(keccak256(bytes(_func))), _data);
        } else {
            // call fallback with data
            data = _data;
        }
        (bool success, bytes memory result) = _target.call{value: _value}(data);
        require(success, "call failed");
        emit Execute(txId, _target, _value, _func, _data, _timestamp);
        return result;
    }

    function cancel(bytes32 _txId) external {
        // code
        require(msg.sender == owner, "owner only");
        require(queued[_txId], "not queued");
        delete queued[_txId];
        emit Cancel(_txId);
    }
}