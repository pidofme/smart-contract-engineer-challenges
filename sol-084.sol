// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IERC20.sol";

contract DiscreteStakingRewards {
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardToken;
    
    // Declare state variables for storing the amounts of token staked
    mapping(address => uint) public balanceOf;
    uint public totalSupply;
    
    // Declare state variables for calculating rewards
    // A state variable to store the sum of reward amounts / total staked
    uint private rewardIndex;
    // Mapping that stores the current rewardIndex per staker when the staker either stakes, unstakes or claim rewards.
    mapping(address => uint) private rewardIndexOf;
    // Mapping that stores the amount of rewards earned for each staker
    mapping(address => uint) private earned;
    // A number multiplied with reward amounts. 
    // This is used to prevent divisions rounding down to 0.
    uint private constant MULTIPLIER = 1e18;

    constructor(address _stakingToken, address _rewardToken) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
    }

    function updateRewardIndex(uint reward) external {
        // Code
        rewardToken.transferFrom(msg.sender, address(this), reward);
        rewardIndex += (reward * MULTIPLIER) / totalSupply;
    }

    function _calculateRewards(address account) private view returns (uint) {
        // Code
        return balanceOf[account] * (rewardIndex - rewardIndexOf[account]) / MULTIPLIER;
    }

    function calculateRewardsEarned(
        address account
    ) external view returns (uint) {
        // Code
        return earned[account] + _calculateRewards(account);
    }

    function _updateRewards(address account) private {
        // Code
        earned[account] += _calculateRewards(msg.sender);
        rewardIndexOf[account] = rewardIndex;
    }

    function stake(uint amount) external {
        // Code
        _updateRewards(msg.sender);
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        stakingToken.transferFrom(msg.sender, address(this), amount);
    }

    function unstake(uint amount) external {
        // Code
        _updateRewards(msg.sender);
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        stakingToken.transfer(msg.sender, amount);
    }

    function claim() external returns (uint) {
        // Code
        _updateRewards(msg.sender);
        uint reward = earned[msg.sender];
        if (reward > 0) {
            earned[msg.sender] = 0;
            rewardToken.transfer(msg.sender, reward);
        }
        return reward;
    }
}