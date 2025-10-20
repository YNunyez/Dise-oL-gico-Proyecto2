1. Párrafo resumen de introducción
El propósito de este proyecto es diseñar, simular e implementar un sistema digital sincrónico en una FPGA mediante el uso de SystemVerilog. El objetivo es crear un circuito que pueda obtener dos números enteros positivos de tres cifras desde un teclado hexadecimal, realizar una suma aritmética y mostrar el resultado en cuatro displays de siete segmentos. El trabajo combina el uso de ideas como la sincronización, el diseño modular, la gestión del rebote en las entradas mecánicas y el control de salidas multiplexadas, todo ello basado en una arquitectura sincrónica con un reloj de al menos 27 MHz.

2. Definición general del problema, objetivos buscados y especificaciones planteadas
El problema a solucionar es la implementación de un sistema digital que, por medio de un teclado hexadecimal, reciba dos números positivos (cada uno con tres cifras), los procese y permita hacer una suma (sin signo), mostrando el resultado en cuatro pantallas de siete segmentos. 
El sistema tiene que asegurar la captura adecuada de datos, previniendo rebotes y garantizando la sincronización con el reloj principal de la FPGA. Además, tiene que dividir la funcionalidad principal en cuatro subsistemas:
1.	Subsistema de lectura del teclado hexadecimal: encargado de escanear, eliminar rebote y sincronizar las teclas presionadas, permitiendo ingresar los dos números de manera secuencial.
2.	Subsistema de almacenado: captura los datos ingresados de forma secuencial y los guarda de manera temporal.
3.	Subsistema de suma aritmética: realiza la operación de suma entre los dos valores guardados y entrega el resultado.
4.	Subsistema de despliegue: convierte el resultado y lo presenta en cuatro displays de siete segmentos mediante un mecanismo de refresco temporal.
Objetivos buscados:
•	Implementar un diseño completamente sincrónico en FPGA utilizando SystemVerilog.
•	Desarrollar una arquitectura modular con bloques claramente definidos de forma secuencial.
•	Verificar funcional y temporalmente el diseño.
Especificaciones principales:
•	Frecuencia de reloj: 27 MHz (única fuente de reloj del sistema).
•	Entradas: teclado hexadecimal tipo matriz (fila/columna).
•	Salidas: cuatro displays de 7 segmentos.
•	Lenguaje de descripción: SystemVerilog.
