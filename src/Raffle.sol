// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

// install at https://github.com/smartcontractkit/chainlink-brownie-contracts
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title A sample Raffle Contract
 * @author Springer Barry
 * @notice This contract is for creating a sample raffle
 * @dev It implements Chainlink VRFv2.5 and Chainlink Automation
 */
contract Raffle is VRFConsumerBaseV2Plus {
    uint256 private immutable i_entranceFee;

    // @dev Duration of the lottery in seconds
    uint256 private immutable i_interval;

    // address payable
    address payable[] private s_players;

    uint256 private s_lastTimestamp;

    // Chainlink VRF Variables
    bytes32 private immutable i_gasLane;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    // event param indexed is for quick search!
    event EnteredRaffle(address indexed player);

    error Raffle__SendMoreToEnterRaffle();

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address _vrfCoordinator,
        bytes32 gasLane, // keyHash
        uint256 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2Plus(_vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;

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
    function pickWinner() external {
        if ((block.timestamp - s_lastTimestamp) < i_interval) revert();

        // s_vrfCoordinator is a state in VRFConsumerBaseV2Plus
        uint256 requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_gasLane,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override {}

    /** Getter Functions */

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
