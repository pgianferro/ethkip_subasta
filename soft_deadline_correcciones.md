# 📘 Correcciones y Mejoras - Trabajo Final Módulo 2

Este archivo documenta las correcciones sugeridas por el profesor para mejorar la nota del trabajo final, así como las mejoras ya implementadas en el smart contract.

---

## Correcciones sugeridas

A tener en cuenta para mejorar nota a más de 70:

1. Hacer withdraw partial.
2. Usar short string y no long strings, sobre todo en los `require`.
3. Los `require` siempre lo más arriba posible.
4. No calcular longitudes dentro del `for`.
5. Nunca hacer más de una lectura y una escritura a una variable de estado en una función.
6. Usar variables sucias en vez de variables limpias (declararlas fuera de los bucles).
7. Función de recuperación de ETH de emergencia.
8. Documentación del código: cada función debe incluir descripción, parámetros y retorno.
9. Documentación y código en inglés.

---

## ✅ Cambios Implementados

### 1. Withdraw Partial

La función `partialRefund()` ya existía y cumple con el requisito.

Permite a cualquier oferente reclamar el reembolso del 98% de todas sus ofertas anteriores a la última, manteniendo su oferta más reciente como válida en la subasta.

Se testearon exitosamente los siguientes escenarios:

- Reembolsos parciales del actual `highestBidder`.
- Reembolsos anteriores a una bid ganadora.
- Protección ante múltiples ejecuciones por el mismo usuario.
- Para más información verificar el punto 6 del archivo test_battery.md

Función ubicada en el contrato en la línea **147**.

---

### 2. Uso de short strings en `require`

🔹 Se reemplazaron los mensajes de error largos por versiones cortas y claras.

| Función / Lugar       | Mensaje original                                  | Mensaje nuevo         |
|-----------------------|----------------------------------------------------|------------------------|
| onlyOwner (modifier)  | Only the owner can call this function.             | Owner only             |
| auctionActive         | Bid is not active                                  | Auction is not active  |
| auctionFinalized      | The auction is not over yet                        | Auction is active      |
| bid()                 | You must send some ETH                             | No ETH                 |
| bid()                 | Bid must be at least 5% higher                     | Bid < 5%               |
| partialRefund()       | No refundable bids found                           | No refundable bids     |
| partialRefund()       | Nothing to refund                                  | Nothing to refund      |
| partialRefund()       | Refund failed                                      | Refund failed          |
| refundAll()           | Refund failed                                      | Refund failed          |

Algunas expresiones como `"Refund failed"` ya eran suficientemente cortas y se mantuvieron.

---

### 3. Ubicación de los `require`

Se revisaron todas las funciones del contrato y se garantizó que los `require` estén posicionados al principio de cada bloque funcional, justo después de la aplicación de modifiers.

No hay `require` que pueda moverse más arriba sin romper la lógica del contrato. Esto reduce consumo de gas en llamadas inválidas y sigue las mejores prácticas de Solidity.

---


### 4. Optimización de cálculo de longitud fuera del bucle (`for`)

**Corrección aplicada:**  
Se extrajo `bidHistory.length` a una variable `len` fuera de los bucles `for`, evitando múltiples lecturas en cada iteración. Esto mejora el rendimiento y reduce el consumo de gas.

| Función         | Antes                                          | Después                                                 |
|----------------|-------------------------------------------------|----------------------------------------------------------|
| `partialRefund` | `for (uint i = 0; i < bidHistory.length; i++)` | `uint256 len = bidHistory.length;`<br>`for (uint i = 0; i < len; i++)` |
| `refundAll`     | `for (uint i = 0; i < bidHistory.length; i++)` | `uint256 len = bidHistory.length;`<br>`for (uint i = 0; i < len; i++)` |

✅ Esta optimización fue implementada en ambas funciones, cumpliendo con la sugerencia sin alterar la lógica del contrato.

---

---

### 5. Optimización: Lectura y escritura única sobre variables de estado

Se revisaron todas las funciones que acceden a variables de estado para verificar que no haya múltiples lecturas o escrituras innecesarias. En cada caso se optimizó el uso mediante almacenamiento en variables locales cuando correspondía.

| Función           | Variable afectada     | Tipo de acceso     | Estado actual | Comentario |
|-------------------|------------------------|---------------------|----------------|------------|
| `bid()`           | `bids[msg.sender]`     | Escritura única     | ✅ Correcto    | Se incrementa solo una vez. |
| `partialRefund()` | `bids[msg.sender]`     | Escritura única     | ✅ Correcto    | Se acumula `refundAmount` localmente y se actualiza una vez. |
| `partialRefund()` | `bidHistory`           | Lectura en bucle    | ✅ Correcto    | `.refunded` se modifica una sola vez por entrada. |
| `refundAll()`     | `bidHistory`           | Lectura + escritura | ✅ Correcto    | `.refunded` y `bids[...]` se modifican una vez por entrada. |

Además, en funciones con bucles se introdujo la variable local `len` para evitar calcular la longitud del array `bidHistory` en cada iteración (ver sección anterior).

Conclusión: No se encontraron accesos redundantes a variables de estado. Todas las escrituras se hacen de manera única por ciclo o al final de la función, cumpliendo con la sugerencia del profesor.

---

### 6. Uso de Variables Sucias en lugar de Variables Limpias

Se revisaron las funciones con estructuras de bucle (`for`) y se aplicó la mejora sugerida de utilizar variables sucias.

#### 🔧 Aplicaciones realizadas
| Función           | Variable aplicada | Antes (limpia)                      | Después (sucia)                     |
|------------------|-------------------|-------------------------------------|-------------------------------------|
| `partialRefund()` | `len`             | `for (uint i = 0; i < bidHistory.length; i++)` | `uint len = bidHistory.length;`<br>`for (uint i = 0; i < len; i++)` |
| `refundAll()`     | `len`             | `for (uint i = 0; i < bidHistory.length; i++)` | `uint len = bidHistory.length;`<br>`for (uint i = 0; i < len; i++)` |
| `partialRefund()` | `refundAmount`    | `uint refundAmount = 0;`            | `uint refundAmount = 0;` (sin cambios) |
| `refundAll()`     | `refundAmount`    | `uint refundAmount = ...;` dentro del bucle | `uint refundAmount;` fuera del bucle |

---


---

## 7. Implementación de función de emergencia y control de pausa (`paused`)

Con el objetivo de mejorar la seguridad del contrato y prevenir que los fondos queden varados, se implementaron las siguientes mejoras:

- Se agregó la variable de estado `paused` para controlar si el contrato está activo o pausado.
- Se incorporaron dos modificadores:
  - `whenNotPaused`: restringe funciones para que solo se ejecuten si el contrato está activo.
  - `whenPaused`: habilita funciones únicamente cuando el contrato está pausado.
- Se creó la función `setPaused(bool _status)` accesible solo por el `owner`, que permite pausar o reactivar el contrato.
- Se agregó la función `emergencyWithdraw()` para que el `owner` pueda retirar todos los fondos del contrato si se encuentra pausado.
- Se reforzaron las funciones críticas con el modificador `whenNotPaused`.

### 📌 Aplicación del nuevo modificador `whenNotPaused`

| Función             | Modificadores originales                 | Modificadores actuales                              |
|---------------------|------------------------------------------|-----------------------------------------------------|
| `bid()`             | `auctionActive`                          | `auctionActive`, `whenNotPaused`                   |
| `partialRefund()`   | `auctionActive`                          | `auctionActive`, `whenNotPaused`                   |
| `refundAll()`       | `onlyOwner`, `auctionFinalized`          | `onlyOwner`, `auctionFinalized`, `whenNotPaused`   |
| `emergencyWithdraw()` | —                                      | `onlyOwner`, `whenPaused`                          |

Estas mejoras añaden una capa adicional de seguridad al contrato ante situaciones excepcionales.

---
## 8. Documentación del código: cada función debe incluir descripción, parámetros y retorno.
## 9. Documentación y código en inglés.

Se revisaron todos los comentarios dentro de las funciones y bloques de código del contrato. Se tradujeron al inglés y se optimizó su redacción para mejorar la claridad, concisión y coherencia con los estándares de documentación en Solidity.

| Bloque revisado       | Cambios realizados                                                                 |
|-----------------------|------------------------------------------------------------------------------------|
| Variables de estado   | Comentarios traducidos y reformulados para mayor claridad.                        |
| Struct `BidInfo`      | Traducción técnica precisa de los campos (`bidder`, `amount`, `time`, `refunded`).|
| Array `bidHistory`    | Comentario traducido, simplificado y reubicado para mayor claridad.               |
| Constructor           | Comentario añadido explicando el objetivo del bloque y la lógica de inicialización.|
| Eventos               | Comentarios enriquecidos con etiquetas `@notice` y `@param`.                      |
| Modificadores         | Comentarios traducidos con estilo técnico y coherente (`onlyOwner`, `whenPaused`, etc).|
| Función `bid()`       | Comentarios internos traducidos y mejorados con redacción más técnica.            |
| Función `partialRefund()` | Comentarios numerados reescritos en inglés técnico y conciso.                   |
| Función `refundAll()` | Comentarios reformulados para explicar claramente el flujo de reembolsos.         |
| Funciones auxiliares (`getTimeNow`, `emergencyWithdraw`) | Comentarios ajustados o eliminados según necesidad. |

✅ Todos los comentarios ahora están en inglés y mantienen un estilo profesional y técnico consistente con las mejores prácticas de desarrollo de contratos inteligentes.