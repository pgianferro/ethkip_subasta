🧾 Subasta Solidity – Trabajo Final Módulo 2

Este proyecto implementa un contrato inteligente para una subasta simple en Solidity, con las siguientes funcionalidades:
	•	Ofertas válidas solo si superan la mejor oferta en al menos un 5%.
	•	Extensión automática del tiempo si se recibe una oferta cerca del final.
	•	Reembolsos parciales disponibles para los oferentes no ganadores durante la subasta con comisión del 2%.
	•	Reembolsos con comisión del 2% aplicados a todas las ofertas no ganadoras (parciales o finales).
	•	El contrato mantiene un historial de todas las ofertas registradas.
	•	Solo el owner puede ejecutar la devolución final (refundAll).

⸻

🚀 Contrato Desplegado
	•	Red: Sepolia
	•	Dirección del contrato:
0xXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
(Reemplazar con la dirección real)
	•	Código verificado en:
Sepolia Etherscan

⸻

📁 Repositorio
	•	GitHub:
https://github.com/pgianferro/ethkip_subasta

⸻

🧪 Test Manual Realizado
	1.	✅ Se realizaron múltiples ofertas entre dos cuentas.
	2.	✅ Se probaron reembolsos parciales de cuentas con múltiples ofertas.
	3.	✅ Se ejecutó refundAll al finalizar la subasta.
	4.	✅ Se verificó que solo se conserva la última oferta ganadora y que se devuelven las anteriores con la comisión del 2%.

⸻

🔒 Notas de Seguridad
	•	El contrato restringe las funciones refundAll y bid según el tiempo y el rol.
	•	Los reembolsos usan .call para mayor seguridad frente a transfer.
	•	No se almacena saldo individual, sino acumulado, y se descuenta luego del reembolso.