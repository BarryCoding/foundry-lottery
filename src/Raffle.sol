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

    error Raffle__SendMoreToEnterRaffle();

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
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
    }

    function pickWinner() public {}

    /** Getter Functions */

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
