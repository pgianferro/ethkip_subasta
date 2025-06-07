// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract Subasta {

//Variables de estado
uint public highestBid;
address public highestBidder;
uint256 public startTime;
uint256 public stopTime;
address payable owner;
mapping(address => uint) bids;

//Variables de estado para el listado de oferentes y ofertas
struct BidInfo {
    address bidder;
    uint amount;
}

//Eventos
event NewBid(address indexed bidder, uint amount);
event AuctionEnded();

//Array para contener a los oferentes
BidInfo[] public bidHistory;

//Constructor para inicializar las variables de estado
constructor() {
    startTime = block.timestamp;
    stopTime = startTime + 7 days;
    owner = payable(msg.sender);
}

//Modificadores
modifier onlyOwner() {
    require(msg.sender == owner, "Only the owner can call this function.");
    _;
}

modifier auctionFinalized() {
    require(block.timestamp >= stopTime, "The auction is not over yet");
    _;
}

//Función para registrar una subasta
function bid() external payable {
    require(block.timestamp >= startTime && block.timestamp <= stopTime, "Bid is not active");
    require(msg.value > 0, "You must send some ETH");
    require(msg.value * 100 >= highestBid * 105, "Bid must be at least 5% higher");

    // Extender el tiempo si la oferta se hace dentro de los últimos 10 minutos
    if (stopTime - block.timestamp <= 10 minutes) {
    stopTime += 10 minutes;
    }
    
    //Emite el evento de nueva oferta registrada
    emit NewBid(msg.sender, msg.value);

    // Registro de la oferta (acumulativo, por si luego usamos reembolsos)
    bids[msg.sender] += msg.value;

    // Actualizamos solo si es la mejor oferta individual
    highestBid = msg.value;
    highestBidder = msg.sender;

    //Lo agregamos al historial de oferentes para consulta
    bidHistory.push(BidInfo(msg.sender, msg.value));
}

//Función para leer apuestas por contrato
function getBidOf(address bidder) external view returns (uint) {
    return bids[bidder];
}

//Función para mostrar quien va ganando
function showCurrentWinner() external view returns (address, uint) {
    return (highestBidder, highestBid);
}

//Mostrar oferentes y sus ofertas
function showOffers() external view returns (BidInfo[] memory) {
    return bidHistory;
}

//Función para mostrar ganador final
function showFinalWinner() external view auctionFinalized returns (address, uint) {
    return (highestBidder, highestBid);
}

//Función para devolver las ofertas a los no ganadores
function refundAll() external payable onlyOwner auctionFinalized { 
    for(uint i = 0; i < bidHistory.length; ++i) {
        if(bidHistory[i].bidder != highestBidder) {
            uint refundAmount = (bidHistory[i].amount) * 98 / 100;
            //payable(bidHistory[i].bidder).transfer(refundAmount);
            (bool sent, ) = payable(bidHistory[i].bidder).call{value: refundAmount}("");
            require(sent, "Refund failed");
        }
    }
    emit AuctionEnded();
}

}