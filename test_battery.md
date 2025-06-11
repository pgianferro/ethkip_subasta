# 🧪 Battery of Manual Tests – `Subasta.sol`

Este archivo documenta la ejecución y resultados de las pruebas manuales del contrato inteligente `Subasta`, desplegado en la red Sepolia. Se utilizan tres cuentas:
🧪 Nota: Las pruebas se realizaron con `stopTime = startTime + 5 minutes` para facilitar la verificación temporal. En producción, `stopTime` se define como `startTime + 7 days`.

## Cuentas

| Rol       | Dirección                                                 |
|-----------|-----------------------------------------------------------|
| Owner     | 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db                |
| Bidder A  | 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4                |
| Bidder B  | 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2                |

---

## ✅ Test 1 – Deploy del contrato

- 📌 `startTime`: `1749644528`
- 📌 `stopTime`: `1749644828`
- ✅ Variables iniciales correctas
- ✅ `paused = false`
- ✅ `highestBid = 0`
- ✅ `bidHistory.length = 0`

---

## 🧪 Test 2 – Bidder A ofrece 1 ETH

- 🟢 Transacción ejecutada exitosamente
- ✅ Evento `NewBid` emitido
- ✅ `highestBid = 1 ETH`
- ✅ `highestBidder = Bidder A`
- ✅ `bidHistory.length = 1`

---

## 🧪 Test 3 – Bidder B ofrece 2 ETH

- 🟢 Transacción ejecutada exitosamente
- ✅ `highestBid = 2 ETH`
- ✅ `highestBidder = Bidder B`
- ✅ `bidHistory.length = 2`

---

## 🧪 Test 4 – Bidder A ofrece 5 ETH

- 🟢 Transacción ejecutada exitosamente
- ✅ `highestBid = 5 ETH`
- ✅ `highestBidder = Bidder A`
- ✅ `bidHistory.length = 3`
- ⏳ `stopTime` extendido correctamente a: `1749646028`

---

## 🧪 Test 5 – showFinalWinner antes del final

- ❌ Llamada a `showFinalWinner()` revertida
- 🛑 Mensaje esperado: `"Auction is active"`

---

## 🧪 Test 6 – partialRefund() ejecutado por Bidder A

- 🟢 Se ejecutó `partialRefund()`
- ✅ Se reembolsó el 98% de la primera oferta (1 ETH)
- ✅ Se marcó como `refunded = true`
- ✅ `getBidOf(Bidder A)` se actualizó correctamente
- ✅ Confirmado por `showBids`

---

## 🧪 Test 7 – showFinalWinner luego de la subasta

- ⌛ Tiempo actual > `stopTime`
- ✅ `showFinalWinner()` retorna `Bidder A` y su oferta de 5 ETH
- ❌ Nuevas bids y reembolsos revertidos por `Auction is not active`

---

## 🧪 Test 8 – refundAll() ejecutado por el owner

- ❌ Llamada desde cuenta no owner revertida (`Owner only`)
- ✅ Llamado desde el owner ejecutado con éxito
- ✅ Evento `AuctionEnded` emitido
- ✅ Se reembolsó el 98% de la oferta no ganadora (2 ETH de Bidder B)

---

## 🧪 Test 9 – Verificación post refundAll()

- ✅ `bidHistory.refunded` actualizado correctamente
- ✅ Solo la última oferta del ganador quedó sin reembolsar

---

## 🧪 Test 10 – Emergency Withdraw

1. 🔐 `emergencyWithdraw()` sin pausar → revertido: `"Paused == false"`
2. ⏸️ `setPaused(true)` ejecutado por owner
3. ✅ `emergencyWithdraw()` ejecutado correctamente
4. ✅ Balance del contrato transferido al owner