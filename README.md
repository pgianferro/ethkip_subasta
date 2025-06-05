# Subasta Smart Contract

Este contrato inteligente implementa una subasta básica con las siguientes funcionalidades:

- Ofertar con validación de mínimo 5% adicional
- Gestión de depósitos
- Eventos para ofertas y finalización
- Extensión del tiempo si la oferta es en los últimos 10 minutos
- Reembolsos para ofertantes no ganadores

## Estructura

- `constructor(...)`: Inicializa la subasta
- `ofertar()`: Permite hacer una oferta
- `finalizarSubasta()`: Cierra la subasta y distribuye fondos
- `mostrarGanador()`: Devuelve el ganador
- `mostrarOfertas()`: Lista de todas las ofertas

_Desarrollado como entrega final del Módulo 2 - EDP 2025._