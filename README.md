# 🧾 Subasta Solidity – Trabajo Final Módulo 2

Este proyecto implementa un contrato inteligente de subastas en Solidity con funcionalidades extendidas, seguridad reforzada y manejo detallado de historial de ofertas.

## ✨ Funcionalidades principales

- ✅ Ofertas válidas solo si superan la mejor en al menos un 5%.
- 🕒 Extensión automática del tiempo si se recibe una oferta en los últimos 10 minutos.
- 💸 Reembolsos parciales durante la subasta con comisión del 2%.
- 🔚 Reembolsos al finalizar, ejecutados por el owner (refundAll).
- 🧾 Historial completo de todas las ofertas.
- 🔐 Pausable y con funciones exclusivas para el owner.

---

## 🚀 Contrato desplegado

- **Red**: Sepolia  
- **Dirección del contrato**: https://sepolia.etherscan.io/address/0x541f6fb52cb45c124651db0a6794353e912596b2#code 
- **Código verificado**: ✅ en Etherscan

---

## 🔬 Batería de tests ejecutada

## ✔️ Escenarios de Prueba Completados

| #  | Escenario                                                              | Resultado |
|----|------------------------------------------------------------------------|:---------:|
| 1  | Deploy exitoso                                                         | ✅        |
| 2  | Bidder A realiza oferta inicial (1 ETH)                                | ✅        |
| 3  | Bidder B realiza oferta válida superior (2 ETH)                        | ✅        |
| 4  | Bidder A ofrece 5 ETH (se actualiza highestBid y se extiende el tiempo) | ✅      |
| 5  | showFinalWinner antes del cierre revierte correctamente                | ✅        |
| 6  | Bidder A ejecuta `partialRefund()` correctamente                      | ✅        |
| 7  | showFinalWinner luego del cierre devuelve el ganador                   | ✅        |
| 8  | `refundAll()` ejecutado solo por el owner, reembolsos correctos        | ✅        |
| 9  | Solo la última oferta del ganador queda sin reembolso                  | ✅        |
| 10 | `emergencyWithdraw()` fallido sin pause, exitoso tras `setPaused(true)` | ✅       |

---

## 📁 Repositorio

- GitHub: [https://github.com/pgianferro/ethkip_subasta](https://github.com/pgianferro/ethkip_subasta)

---

## 🛡️ Notas de Seguridad

- Uso de `.call{value: ...}` en vez de `.transfer` por seguridad.
- Funciones críticas restringidas por `onlyOwner` y `whenPaused`.
- Sin almacenamiento individual de balances; se trabaja con acumulados y ajustes tras reembolsos.

---