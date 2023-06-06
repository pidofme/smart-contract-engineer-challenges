// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IERC721.sol";

contract ERC721 is IERC721 {
    event Transfer(address indexed from, address indexed to, uint indexed id);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint indexed id
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    // Mapping from token ID to owner address
    mapping(uint => address) internal _ownerOf;

    // Mapping owner address to token count
    mapping(address => uint) internal _balanceOf;

    // Mapping from token ID to approved address
    mapping(uint => address) internal _approvals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    function supportsInterface(
        bytes4 interfaceId
    ) external pure returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    function ownerOf(uint id) external view returns (address) {
        // code
        address owner = _ownerOf[id];
        require(owner != address(0), "token not exist");
        return owner;
    }

    function balanceOf(address owner) external view returns (uint) {
        // code
        require(owner != address(0), "zero address");
        return _balanceOf[owner];
    }

    function setApprovalForAll(address operator, bool approved) external {
        // code
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function getApproved(uint id) external view returns (address) {
        // code
        require(_ownerOf[id] != address(0), "toekn doesn't exist");
        return _approvals[id];
    }

    function approve(address to, uint id) external {
        // code
        address owner = _ownerOf[id];
        require(_ownerOf[id] != address(0), "token doesn't exist");
        require(owner == msg.sender || isApprovedForAll[owner][msg.sender], 
            "not allowed");
        _approvals[id] = to;
        emit Approval(owner, to, id);
    }

    function transferFrom(address from, address to, uint id) public {
        // code
        require(_ownerOf[id] != address(0), "token doesn't exist");
        require(to != address(0), "to is address(0)");
        
        address owner = _ownerOf[id];
        require(owner == from, "from != owner");
        require(owner == msg.sender || 
            isApprovedForAll[owner][msg.sender] || 
            msg.sender == _approvals[id], 
            "not allowed");
        
        _balanceOf[from]--;
        _balanceOf[to]++;
        _ownerOf[id] = to;
        delete _approvals[id];
        
        emit Transfer(from, to, id);
    }
    
    function isContract(address to) public view returns (bool) {
        return to.code.length > 0;
    }

    function safeTransferFrom(address from, address to, uint id) external {
        // code
        transferFrom(from, to, id);
        
        require(
            !isContract(to) ||
                IERC721Receiver(to).onERC721Received(msg.sender, from, id, "") ==
                IERC721Receiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint id,
        bytes calldata data
    ) external {
        // code
        transferFrom(from, to, id);
        
        require(
            !isContract(to) ||
                IERC721Receiver(to).onERC721Received(msg.sender, from, id, data) ==
                IERC721Receiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }

    function mint(address to, uint id) external {
        // code
        require(_ownerOf[id] == address(0), "token already exist");
        require(to != address(0), "to = address(0)");
        _ownerOf[id] = to;
        _balanceOf[to] += 1;
        emit Transfer(address(0), to, id);
    }

    function burn(uint id) external {
        // code
        address owner = _ownerOf[id];
        require(_ownerOf[id] != address(0), "token doesn't exist");
        require(owner == msg.sender, "not allowed");
        
        _balanceOf[owner]--;
        delete _ownerOf[id];
        delete _approvals[id];
        
        emit Transfer(owner, address(0), id);
    }
}