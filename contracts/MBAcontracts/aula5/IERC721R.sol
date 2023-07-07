// SPDX-License-Identifier: MIT
// Creator: Exo Digital Labs

pragma solidity ^0.8.4;

import "erc721a/contracts/IERC721A.sol";

/// @notice Refundable EIP-721 tokens
interface IERC721R is IERC721A {
    /// @notice           Emitted when a token is refunded
    /// @dev              Emitted by `refund`
    /// @param  _sender   The person that requested a refund
    /// @param  _tokenId  The `tokenId` that was refunded
    event Refund(address indexed _sender, uint256 indexed _tokenId);

    /// @notice         As long as the refund is active for the given `tokenId`, refunds the user
    /// @dev            Make sure to check that the user has the token, and be aware of potential re-entrancy vectors
    /// @param  tokenId The `tokenId` to refund
    function refund(uint256 tokenId) external;


    /// @notice         Gets the first block for which the refund is not active for a given `tokenId`
    /// @param  tokenId The `tokenId` to query
    /// @return _block   The block beyond which the token cannot be refunded
    function refundDeadlineOf(uint256 tokenId) external view returns (uint256 _block);
}
