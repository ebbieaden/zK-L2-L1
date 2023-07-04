// The Example contract below sends its address to L1 via the Messenger system contract.
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// Importing interfaces and addresses of the system contracts
import "@matterlabs/zksync-contracts/l2/system-contracts/Constants.sol";

contract Example {
    function sendMessageToL1() external returns(bytes32 messageHash) {
        // Construct the message directly on the contract
        bytes memory message = abi.encode(address(this));

        messageHash = L1_MESSENGER_CONTRACT.sendToL1(message);
    }
}