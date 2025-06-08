// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract Subasta {

//Variables de estado
uint public highestBid;
address public highestBidder;
uint256 public startTime;
uint256 public stopTime;
address payable public owner;
mapping(address => uint) bids;

//Variables de estado para el listado de oferentes y ofertas
struct BidInfo {
    address bidder;
    uint amount;
    uint time;
    bool refunded;
}

//Eventos
event NewBid(address indexed bidder, uint amount);
event AuctionEnded();

//Array para contener a los oferentes
BidInfo[] public bidHistory;

//Array

//Constructor para inicializar las variables de estado
constructor() {
    startTime = block.timestamp;
    stopTime = startTime + 5 minutes;
    owner = payable(msg.sender);
}

//Modificadores
//Solo permite que el owner llame a la función
modifier onlyOwner() {
    require(msg.sender == owner, "Only the owner can call this function.");
    _;
}

//Chequea que esté activa la Subasta
modifier auctionActive() {
    require(block.timestamp >= startTime && block.timestamp <= stopTime, "Bid is not active");
    _;
}

//Chequea que esté terminada la Subasta
modifier auctionFinalized() {
    require(block.timestamp >= stopTime, "The auction is not over yet");
    _;
}

//Función para registrar una subasta
function bid() external payable auctionActive {
    //require(block.timestamp >= startTime && block.timestamp <= stopTime, "Bid is not active");
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
    bidHistory.push(BidInfo(msg.sender, msg.value, block.timestamp, false));
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
function showBids() external view returns (BidInfo[] memory) {
    return bidHistory;
}


//Función para devoluciones parciales
function partialRefund() external auctionActive {
    uint256 count = 0;

    // 1. Contar cuántas ofertas activas (no reembolsadas) tiene este bidder
    for (uint i = 0; i < bidHistory.length; i++) {
        if (bidHistory[i].bidder == msg.sender && !bidHistory[i].refunded) {
            count++;
        }
    }

    require(count > 1, "No refundable bids found");

    uint256 counter = 0;
    uint256 refundAmount = 0;

    // 2. Volver a recorrer el array, marcar como refunded todas menos la última, y acumular montos
    for (uint i = 0; i < bidHistory.length; i++) {
        if (bidHistory[i].bidder == msg.sender && !bidHistory[i].refunded) {
            counter++;
            if (counter < count) {
                refundAmount += bidHistory[i].amount;
                bidHistory[i].refunded = true;
            }
        }
    }

    require(refundAmount > 0, "Nothing to refund");

    // 3. Transferir el monto acumulado
    (bool sent, ) = payable(msg.sender).call{value: refundAmount}("");
    require(sent, "Refund failed");

    // 4. Restar del total acumulado del mapping
    bids[msg.sender] -= refundAmount;
}

//Función para mostrar ganador final
function showFinalWinner() external view auctionFinalized returns (address, uint) {
    return (highestBidder, highestBid);
}

//Función para devolver las ofertas a los no ganadores
function refundAll() external payable onlyOwner auctionFinalized { 
    for(uint i = 0; i < bidHistory.length; ++i) {
        if(bidHistory[i].bidder != highestBidder && bidHistory[i].refunded == false) {
            uint refundAmount = (bidHistory[i].amount) * 98 / 100;
            //payable(bidHistory[i].bidder).transfer(refundAmount);
            (bool sent, ) = payable(bidHistory[i].bidder).call{value: refundAmount}("");
            require(sent, "Refund failed");
            
            bidHistory[i].refunded = true;
        }
    }
    emit AuctionEnded();
}


//Funcion para saber la hora actual, solo para testeo
function getTimeNow() external view returns (uint) {
    return block.timestamp;
}

}