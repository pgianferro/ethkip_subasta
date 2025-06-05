// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract Subasta {

//Variables de estado
uint256 startTime;
uint256 stopTime;
address payable owner;
mapping(address => uint) bids;

//Constructor para inicializar las variables de estado
constructor() {
    startTime = block.timestamp;
    stopTime = startTime + 7 days;
    owner = payable(msg.sender);
}

//Función para registrar una subasta
function bid() external payable {
    require(block.timestamp >= startTime && block.timestamp <= stopTime, "Bid is not active");
    require(msg.value > 0, "You must send some ETH");

    bids[msg.sender] += msg.value;
}

function getBidOf(address bidder) external view returns (uint) {
    return bids[bidder];
}


}