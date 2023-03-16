// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Lottery {
    uint16 public winningNumber;
    mapping(uint16 => mapping(address => bool)) private lottery_pool;
    uint8 public phase;
    // sell_phase = 0, draw_pahse = 1, claim_phase = 2
    uint start_time;
    mapping(uint16 => uint256) player;
    uint256 public reward;

    constructor() {}

    function buy(uint16 lottery_num) public payable {
        require(msg.value == 0.1 ether, "need only 0.1 ether");
        require(phase != 1, "can enter only sell_phase");
        phase = 0;

        if (start_time == 0) {
            start_time = block.timestamp;
        }
        require(start_time + 24 hours > block.timestamp);
        require(!lottery_pool[lottery_num][msg.sender], "already choosen");
        lottery_pool[lottery_num][msg.sender] = true;
        player[lottery_num] += 1;
    }

    function draw() public {
        require(phase == 0);
        require(
            start_time + 24 hours <= block.timestamp,
            "can enter only draw_phase"
        );
        phase = 1;
        winningNumber = (uint16)(block.timestamp % (2 ^ 16));
        reward = 0;
        if (player[winningNumber] != 0)
            reward = (address(this).balance) / player[winningNumber];
    }

    function claim() public payable {
        require(phase >= 1);
        require(
            start_time + 24 hours <= block.timestamp,
            "can enter only claim_phase"
        );
        phase = 2;
        start_time = 0;
        if (lottery_pool[winningNumber][msg.sender]) {
            lottery_pool[winningNumber][msg.sender] = false;
            payable(msg.sender).call{value: reward}("");
        }
    }

    receive() external payable {}
}
