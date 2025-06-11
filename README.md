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
- **Dirección del contrato**: [0x...](https://sepolia.etherscan.io/address/0xNUEVADIRECCION#code)  
- **Código verificado**: ✅ en Etherscan

---

## 🔬 Batería de tests ejecutada

| # | Escenario                                                              | Resultado |
|--:|------------------------------------------------------------------------|:---------:|
| 1 | Deploy exitoso                                                         | ✅        |
| 2 | Oferta inicial válida                                                  | ✅        |
| 3 | Oferta menor al 5% rechazada                                           | ✅        |
| 4 | Oferta mayor al 5% aceptada                                            | ✅        |
| 5 | Extensión de tiempo dentro de los últimos 10 minutos                   | ✅        |
| 6 | Múltiples ofertas registradas                                          | ✅        |
| 7 | Reembolso parcial correcto con comisión                               | ✅        |
| 8 | Subasta finalizada y `refundAll()` ejecutado por el owner             | ✅        |
| 9 | Verificación de solo última oferta del ganador sin reembolsar         | ✅        |
|10 | Retiro de emergencia ejecutado al pausar el contrato                  | ✅        |

---

## 📁 Repositorio

- GitHub: [https://github.com/pgianferro/ethkip_subasta](https://github.com/pgianferro/ethkip_subasta)

---

## 🛡️ Notas de Seguridad

- Uso de `.call{value: ...}` en vez de `.transfer` por seguridad.
- Funciones críticas restringidas por `onlyOwner` y `whenPaused`.
- Sin almacenamiento individual de balances; se trabaja con acumulados y ajustes tras reembolsos.

---

## 📦 Entrega oficial

🧾 **Trabajo Final Módulo 2**  
🔗 Contrato inteligente desplegado y verificado en Sepolia:  
📄 [0xNUEVADIRECCION](https://sepolia.etherscan.io/address/0xNUEVADIRECCION#code)  
💻 Código fuente abierto y documentado en GitHub:  
📁 [https://github.com/pgianferro/ethkip_subasta](https://github.com/pgianferro/ethkip_subasta)