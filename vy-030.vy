# @version ^0.3.7

from vyper.interfaces import ERC20

implements: ERC20

event Transfer:
    _from: indexed(address)
    _to: indexed(address)
    _amount: uint256

event Approval:
    _owner: indexed(address)
    _spender: indexed(address)
    _amount: uint256

balanceOf: public(HashMap[address, uint256])
allowance: public(HashMap[address, HashMap[address, uint256]])
totalSupply: public(uint256)


@external
def __init__(initial_supply: uint256):
    self.balanceOf[msg.sender] += initial_supply
    self.totalSupply += initial_supply


@external
def transfer(_to : address, _amount : uint256) -> bool:
    assert self.balanceOf[msg.sender] >= _amount, "bal not enough"
    self.balanceOf[msg.sender] -= _amount
    self.balanceOf[_to] += _amount
    log Transfer(msg.sender, _to, _amount)
    return True


@external
def transferFrom(_from : address, _to : address, _amount : uint256) -> bool:
    assert self.allowance[_from][msg.sender] >= _amount, "not allowed"
    self.balanceOf[_to] += _amount
    self.balanceOf[_from] -= _amount
    self.allowance[_from][msg.sender] -= _amount
    log Transfer(_from, _to, _amount)
    return True


@external
def approve(_spender : address, _amount : uint256) -> bool:
    self.allowance[msg.sender][_spender] = _amount
    log Approval(msg.sender, _spender, _amount)
    return True