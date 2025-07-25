// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleAuctionHouse {
    address public auctioneer;
    uint public highestBid;
    address public highestBidder;
    bool public auctionEnded;

    event NewBid(address indexed bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    constructor() {
        auctioneer = msg.sender;
    }

    modifier onlyAuctioneer() {
        require(msg.sender == auctioneer, "Only auctioneer can call this.");
        _;
    }

    modifier auctionActive() {
        require(!auctionEnded, "Auction has ended.");
        _;
    }

    function bid() external payable auctionActive {
        require(msg.value > highestBid, "Bid must be higher than current highest bid.");

        // Refund previous highest bidder
        if (highestBidder != address(0)) {
            payable(highestBidder).transfer(highestBid);
        }

        highestBid = msg.value;
        highestBidder = msg.sender;
        emit NewBid(msg.sender, msg.value);
    }

    function endAuction() external onlyAuctioneer auctionActive {
        auctionEnded = true;
        payable(auctioneer).transfer(highestBid);
        emit AuctionEnded(highestBidder, highestBid);
    }

    function getCurrentHighestBid() external view returns (uint, address) {
        return (highestBid, highestBidder);
    }
}
