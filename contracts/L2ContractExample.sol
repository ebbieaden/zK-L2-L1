// This contract receives the information related to the transaction sent to the L2 messenger contract.
// It then proves that the message was included in an L2 block.
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// Importing zkSync contract interface
import "@matterlabs/zksync-contracts/l1/contracts/zksync/interfaces/IZkSync.sol";

contract Example {
  // NOTE: The zkSync contract implements only the functionality for proving that a message belongs to a block
  // but does not guarantee that such a proof was used only once. That's why a contract that uses L2 to L1
  // communication must take care of the double handling of the message.
  /// @dev mapping L2 block number => message number => flag
  /// @dev Used to indicated that zkSync L2 to L1 message was already processed
  mapping(uint256 => mapping(uint256 => bool)) isL2ToL1MessageProcessed;

  function consumeMessageFromL2(
    // The address of the zkSync smart contract.
    // It is not recommended to hardcode it during the alpha testnet as regenesis may happen.
    address _zkSyncAddress,
    // zkSync block number in which the message was sent
    uint256 _l2BlockNumber,
    // Message index, that can be received via API
    uint256 _index,
    // The tx number in block
    uint16 _l2TxNumberInBlock,
    // The message that was sent from l2
    bytes calldata _message,
    // Merkle proof for the message
    bytes32[] calldata _proof
  ) external {
    // check that the message has not been processed yet
    require(!isL2ToL1MessageProcessed[_l2BlockNumber][_index]);

    IZkSync zksync = IZkSync(_zkSyncAddress);
    address someSender = 0x19A5bFCBE15f98Aa073B9F81b58466521479DF8D;
    L2Message memory message = L2Message({sender: someSender, data: _message, txNumberInBlock:_l2TxNumberInBlock});

    bool success = zksync.proveL2MessageInclusion(
      _l2BlockNumber,
      _index,
      message,
      _proof
    );
    require(success, "Failed to prove message inclusion");

    // Mark message as processed
    isL2ToL1MessageProcessed[_l2BlockNumber][_index] = true;
  }
}