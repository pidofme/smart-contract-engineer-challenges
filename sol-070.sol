// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IERC20.sol";

contract CrowdFund {
    event Launch(
        uint id,
        address indexed creator,
        uint goal,
        uint32 startAt,
        uint32 endAt
    );
    event Cancel(uint id);
    event Pledge(uint indexed id, address indexed caller, uint amount);
    event Unpledge(uint indexed id, address indexed caller, uint amount);
    event Claim(uint id);
    event Refund(uint id, address indexed caller, uint amount);

    struct Campaign {
        // Creator of campaign
        address creator;
        // Amount of tokens to raise
        uint goal;
        // Total amount pledged
        uint pledged;
        // Timestamp of start of campaign
        uint32 startAt;
        // Timestamp of end of campaign
        uint32 endAt;
        // True if goal was reached and creator has claimed the tokens.
        bool claimed;
    }

    IERC20 public immutable token;
    // Total count of campaigns created.
    // It is also used to generate id for new campaigns.
    uint public count;
    // Mapping from id to Campaign
    mapping(uint => Campaign) public campaigns;
    // Mapping from campaign id => pledger => amount pledged
    mapping(uint => mapping(address => uint)) public pledgedAmount;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function launch(uint _goal, uint32 _startAt, uint32 _endAt) external {
        // code
        require(_startAt >= block.timestamp, "wrong _startAt");
        require(_startAt <= _endAt, "_startAt > _endAt");
        require(_endAt <= block.timestamp + 90 days, "more than 90 days");
        
        count += 1;
        campaigns[count] = Campaign(msg.sender, _goal, 0, _startAt, _endAt, false);
        emit Launch(count, msg.sender, _goal, _startAt, _endAt);
    }

    function cancel(uint _id) external {
        // code
        require(msg.sender == campaigns[_id].creator, "only creator");
        require(campaigns[_id].startAt > block.timestamp, "already started");
        
        delete campaigns[_id];
        emit Cancel(_id);
    }

    function pledge(uint _id, uint _amount) external {
        // code
        Campaign storage campaign = campaigns[_id];
        require(campaign.startAt <= block.timestamp, "not started");
        require(campaign.endAt >= block.timestamp, "ended");
        
        token.transferFrom(msg.sender, address(this), _amount);
        campaign.pledged += _amount;
        pledgedAmount[_id][msg.sender] += _amount;
        emit Pledge(_id, msg.sender, _amount);
    }

    function unpledge(uint _id, uint _amount) external {
        // code
        Campaign storage campaign = campaigns[_id];
        require(campaign.endAt >= block.timestamp, "ended");
        require(pledgedAmount[_id][msg.sender] >= _amount, "too much");

        campaign.pledged -= _amount;
        pledgedAmount[_id][msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);
        emit Unpledge(_id, msg.sender, _amount);
    }

    function claim(uint _id) external {
        // code
        Campaign storage campaign = campaigns[_id];
        require(msg.sender == campaign.creator, "creator only");
        require(campaign.endAt < block.timestamp, "not ended");
        require(campaign.pledged >= campaign.goal, "campaign failed");
        require(!campaign.claimed, "claimed");
        
        campaign.claimed = true;
        token.transfer(campaign.creator, campaign.pledged);
        emit Claim(_id);
    }

    function refund(uint _id) external {
        // code
        Campaign storage campaign = campaigns[_id];
        require(campaign.endAt < block.timestamp, "not ended");
        require(campaign.pledged < campaign.goal, "campaign success");
        
        uint amount = pledgedAmount[_id][msg.sender];
        campaign.pledged -= amount;
        delete pledgedAmount[_id][msg.sender];
        token.transfer(msg.sender, amount);
        emit Refund(_id, msg.sender, amount);
    }
}