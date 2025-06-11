// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract Subasta {


// STATE VARIABLES
uint public highestBid;                       // Highest bid received so far
address public highestBidder;                 // Address of the current highest bidder
uint256 public startTime;                     // Timestamp when the auction starts
uint256 public stopTime;                      // Timestamp when the auction ends
address payable public owner;                 // Address of the contract owner
bool public paused = false;                   // Indicates if the contract is paused
mapping(address => uint) bids;                // Mapping of bidders to their cumulative bid amounts

// STRUCTS

/// @notice Struct to store information about each individual bid
struct BidInfo {
    address bidder;       // Address of the bidder
    uint256 amount;       // Amount of ETH bid
    uint256 time;         // Timestamp of the bid
    bool refunded;        // Whether this bid has been refunded
}


// EVENTS

/// @notice Emitted when a new bid is placed
/// @param bidder Address of the bidder
/// @param amount Amount of the bid
event NewBid(address indexed bidder, uint amount); 

/// @notice Emitted when the auction ends and refunds are issued
event AuctionEnded(); 


// ARRAYS

/// @notice Stores the history of all bids placed during the auction
BidInfo[] public bidHistory;


// CONSTRUCTOR

/// @notice Initializes the auction with default start and stop times.
/// The auction starts immediately and lasts for 5 minutes.
/// The contract deployer is set as the owner.
constructor() {
    startTime = block.timestamp;
    stopTime = startTime + 7 days;
    owner = payable(msg.sender);
}


//MODIFIERS

/// @notice Restricts access to the contract owner only
modifier onlyOwner() {
    require(msg.sender == owner, "Owner only");
    _;
}

/// @notice Ensures the auction is currently active
modifier auctionActive() {
    require(block.timestamp >= startTime && block.timestamp <= stopTime, "Auction is not active");
    _;
}

/// @notice Ensures the auction has already ended
modifier auctionFinalized() {
    require(block.timestamp >= stopTime, "Auction is active");
    _;
}

/// @notice Allows execution only when the contract is paused
modifier whenPaused() {
    require(paused, "Paused == false");
    _;
}

/// @notice Allows execution only when the contract is not paused
modifier whenNotPaused() {
    require(!paused, "Paused == true");
    _;
}



//FUNCTIONS

/// @notice Places a new bid during the active auction period.
/// @dev Extends the auction by 10 minutes if the bid is made within the last 10 minutes.
/// Requirements:
/// - The contract must not be paused.
/// - The bid must be at least 5% higher than the current highest bid.
/// - The value sent must be greater than 0.
function bid() external payable auctionActive whenNotPaused {
    require(msg.value > 0, "No ETH");
    require(msg.value * 100 >= highestBid * 105, "Bid < 5%");

    // Extends auction if bid is placed within the last 10 minutes
    if (stopTime - block.timestamp <= 10 minutes) {
    stopTime += 10 minutes;
    }
    
    // Emits event for new bid
    emit NewBid(msg.sender, msg.value);

    // Accumulates user's bid total
    bids[msg.sender] += msg.value;

    // Updates current highest bid and bidder
    highestBid = msg.value;
    highestBidder = msg.sender;

    // Stores bid details for history and potential refunds
    bidHistory.push(BidInfo(msg.sender, msg.value, block.timestamp, false));
}


/// @notice Returns the total amount bid by a given address.
/// @param bidder The address of the bidder.
/// @return The total amount bid by the specified address.
function getBidOf(address bidder) external view returns (uint) {
    return bids[bidder];
}


/// @notice Returns the address and amount of the current highest bidder.
/// @return The highest bidder's address and their bid amount.
function showCurrentWinner() external view returns (address, uint) {
    return (highestBidder, highestBid);
}


/// @notice Returns the full history of all bids placed in the auction.
/// @return An array of BidInfo structs containing details of each bid.
function showBids() external view returns (BidInfo[] memory) {
    return bidHistory;
}


/// @notice Allows bidders to request a partial refund of 98% of all but their latest bid.
/// @dev Only available during the active auction and if the contract is not paused.
/// Iterates over bid history, marks refunded bids, and sends accumulated refund.
function partialRefund() external auctionActive whenNotPaused {
    uint256 count = 0;
    uint256 len = bidHistory.length;

    // 1. Counts active (non-refunded) bids from sender
    for (uint i = 0; i < len; i++) {
        if (bidHistory[i].bidder == msg.sender && !bidHistory[i].refunded) {
            count++;
        }
    }

    require(count > 1, "No refundable bids");

    uint256 counter = 0;
    uint256 refundAmount = 0;
    
    // 2. Marks all but the last one as refunded and accumulates refund amount
    for (uint i = 0; i < len; i++) {
        if (bidHistory[i].bidder == msg.sender && !bidHistory[i].refunded) {
            counter++;
            if (counter < count) {
                refundAmount += (bidHistory[i].amount * 98) / 100;
                bidHistory[i].refunded = true;
            }
        }
    }

    require(refundAmount > 0, "Nothing to refund");

    // 3. Transfers the total refund
    (bool sent, ) = payable(msg.sender).call{value: refundAmount}("");
    require(sent, "Refund failed");

    // 4. Update bids mapping by subtracting refunded amount
    bids[msg.sender] -= refundAmount;
}



/// @notice Returns the final winner of the auction after it has ended.
/// @dev Can only be called after the auction period has finished.
/// @return The address of the highest bidder and the final bid amount.
function showFinalWinner() external view auctionFinalized returns (address, uint) {
    return (highestBidder, highestBid);
}



/// @notice Refunds 98% of all bids (except the winning one) after the auction ends.
/// @dev Only callable by the owner, and only after the auction has finalized. The contract must not be paused.
/// Iterates through bid history, sends refund to eligible bidders, and marks bids as refunded.
function refundAll() external payable onlyOwner auctionFinalized whenNotPaused { 
        uint256 len = bidHistory.length;
        uint256 refundAmount;


    for(uint i = 0; i < len; ++i) {
        // Process all non-winning and non-refunded bids
        if(bidHistory[i].amount != highestBid && bidHistory[i].refunded == false) { 
            // Calculates refund (98% of bid amount)
            refundAmount = (bidHistory[i].amount) * 98 / 100; 
            // Sends refund to bidder
            (bool sent, ) = payable(bidHistory[i].bidder).call{value: refundAmount}(""); 
            require(sent, "Refund failed");
            // Marks bid as refunded
            bidHistory[i].refunded = true;
            // Updates bids mapping
            bids[bidHistory[i].bidder] -= refundAmount;
        }
    }
    // Emits auction end event
    emit AuctionEnded();
}


/// @notice Enables or disables the paused state of the contract.
/// @dev Only callable by the owner.
/// @param _status Set to true to pause the contract, or false to resume.
function setPaused(bool _status) external onlyOwner {
    paused = _status;
}


/// @notice Withdraws all ETH from the contract in case of emergency.
/// @dev Only callable by the owner and only when the contract is paused.
/// Reverts if there is no ETH balance to withdraw.
function emergencyWithdraw() external onlyOwner whenPaused {
    uint balance = address(this).balance;
    require(balance > 0, "No ETH to withdraw");

    (bool sent, ) = owner.call{value: balance}("");
    require(sent, "Withdraw failed");
}

/// @notice Returns the current block timestamp.
/// @dev Used for testing purposes only.
/// @return The current block timestamp in seconds.
function getTimeNow() external view returns (uint) {
    return block.timestamp;
}

}