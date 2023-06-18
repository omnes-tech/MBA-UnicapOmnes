// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// @author www.omnestech.org

/**
 * @dev External interface of IMentoring
 */
interface IMentoring {

    // =============================================================
    //                         STRUCTS AND ENUNS
    // =============================================================

    /** @dev struct for when interest.
        @param definiteHours: hours you want mentoring 
        @param name: name of the contractor (obs. you do not need to identify yourself completely)
        @param email: email for service provider to contact 
        @param approved: Approval status for mentoring. If true, it was approved and we will contact you
        */

    struct aboutMentoring{
        uint256 definiteHours;
        string name;
        string email;
        string socialnetwork;
        bool approved;
    }

    // =============================================================
    //                         EVENTS
    // =============================================================

    /** @dev event when interested in consulting
        @param addrInterested: new mint price 
        @param priceDeposited: token/coin of transfer */
    event addressAndCost(address indexed addrInterested, uint256 indexed priceDeposited);

    /** @dev event when Omnes Accept
        @param addrApproved: accept for consulting */
    event acceptOmnesConculting(address indexed addrApproved);

    /** @dev event when Omnes Accept
        @param addrApproved: approved for mintAllowed */
    event addrApproved(address indexed addrApproved, bool);

    /** @dev event Soulbound
        @param to: address to 
        @param tokenId: id soulbound */
    event Attest(address indexed to, uint256 indexed tokenId);
    event Revoke(address indexed to, uint256 indexed tokenId);

    // =============================================================
    //                         TOKEN COUNTERS
    // =============================================================

    /**
     * @dev Returns the information from mentees to the operator.
     */
    function mentoringData(address _mentored) external view returns (aboutMentoring memory);

} 