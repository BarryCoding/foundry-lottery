// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

/**
 * @title A sample Raffle Contract
 * @author Springer Barry
 * @notice This contract is for creating a sample raffle
 * @dev It implements Chainlink VRFv2.5 and Chainlink Automation
 */
contract Raffle {
    uint256 private immutable i_entranceFee;

    // @dev Duration of the lottery in seconds
    uint256 private immutable i_interval;

    // address payable
    address payable[] private s_players;

    uint256 private s_lastTimestamp;

    // event param indexed is for quick search!
    event EnteredRaffle(address indexed player);

    error Raffle__SendMoreToEnterRaffle();

    constructor(uint256 entranceFee, uint256 interval) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimestamp = block.timestamp;
    }

    // more gas efficient: external is better than public
    function enterRaffle() external payable {
        // using string is not gas efficient!
        // require(msg.value >= i_entranceFee, "Send More To Enter Raffle");

        // refactor1: more gas efficient: custom error is better than require
        // if (msg.value < i_entranceFee) {
        //     revert Raffle__SendMoreToEnterRaffle();
        // }

        // refactor2: one line
        if (msg.value < i_entranceFee) revert Raffle__SendMoreToEnterRaffle();
        // address is diff from address payable
        s_players.push(payable(msg.sender));
        // emit a event when contract state change
        emit EnteredRaffle(msg.sender);
    }

    // 1. Get a random number
    // 2. Use the random number to pick a player
    // 3. Automatically called
    function pickWinner() external view {
        if ((block.timestamp - s_lastTimestamp) < i_interval) revert();
    }

    /** Getter Functions */

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
