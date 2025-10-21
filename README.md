1. Párrafo resumen de introducción

El propósito de este proyecto es diseñar, simular e implementar un sistema digital sincrónico en una FPGA mediante el uso de SystemVerilog. El objetivo es crear un circuito que pueda obtener dos números enteros positivos de tres cifras desde un teclado hexadecimal, realizar una suma aritmética y mostrar el resultado en cuatro displays de siete segmentos. El trabajo combina el uso de ideas como la sincronización, el diseño modular, la gestión del rebote en las entradas mecánicas y el control de salidas multiplexadas, todo ello basado en una arquitectura sincrónica con un reloj de al menos 27 MHz.

2. Definición general del problema, objetivos buscados y especificaciones planteadas

El problema a solucionar es la implementación de un sistema digital que, por medio de un teclado hexadecimal, reciba dos números positivos (cada uno con tres cifras), los procese y permita hacer una suma (sin signo), mostrando el resultado en cuatro pantallas de siete segmentos. El sistema tiene que asegurar la captura adecuada de datos, previniendo rebotes y garantizando la sincronización con el reloj principal de la FPGA. Además, tiene que dividir la funcionalidad principal en cuatro subsistemas:

   A.	Subsistema de lectura del teclado hexadecimal: encargado de escanear, eliminar rebote y sincronizar las teclas presionadas, permitiendo ingresar los dos números de manera secuencial.

   B.	Subsistema de almacenado: captura los datos ingresados de forma secuencial y los guarda de manera temporal.

   C.	Subsistema de suma aritmética: realiza la operación de suma entre los dos valores guardados y entrega el resultado.

   D.	Subsistema de despliegue: convierte el resultado y lo presenta en cuatro displays de siete segmentos mediante un mecanismo de refresco temporal.

Objetivos buscados:

   •	Implementar un diseño completamente sincrónico en FPGA utilizando SystemVerilog.

   •	Desarrollar una arquitectura modular con bloques claramente definidos de forma secuencial.

   •	Verificar funcional y temporalmente el diseño.

Especificaciones principales:

   •	Frecuencia de reloj: 27 MHz (única fuente de reloj del sistema).

   •	Entradas: teclado hexadecimal tipo matriz (fila/columna).

   •	Salidas: cuatro displays de 7 segmentos.

   •	Lenguaje de descripción: SystemVerilog.


3. Descripción general del funcionamiento del circuito completo y de cada subsistema

Descripción general

El circuito consta de módulos que operan de forma secuencial bajo control sincrónico. Primero, los dígitos ingresados por (explicación del módulo Yair), que luego pasa al módulo de almacenamiento temporal (Push_datos). Estos valores luego se almacenan en registros internos controlados por el módulo de guardado (Guardado_datos). Una vez almacenados los dos operandos, el módulo Suma_datos realiza la operación de suma decimal y genera una salida de cuatro dígitos en formato BCD. Luego, el resultado se envía al módulo mux_info, que elige si los datos a mostrar corresponden al número ingresado actualmente o al resultado final de la operación. A su vez, los datos fluyen hacia el módulo mux_numeros, que se encarga de multiplexar secuencialmente cada uno de los cuatro dígitos disponibles para finalmente ser decodificados por display7, que convierte el valor binario en la combinación adecuada de segmentos para visualizaciones de ánodos comunes.


Subsistema 1: Captura y almacenamiento de datos

El módulo “push_datos”, implementa un registro de desplazamiento controlado por una señal "push" desde el teclado. Cada flanco positivo del reloj con push = 1 (extraído de una señal del teclado) ingresa un nuevo dígito en el registro, empujando los valores anteriores a una posición más significativa. El módulo limita la entrada a tres dígitos y su número de salida representa los tres dígitos registrados junto con un cuarto dígito fijado en cero que se reserva para operaciones posteriores.

El módulo Guardado_datos recibe los datos del Push_datos y controla cuándo deben almacenarse permanentemente como un número válido dentro del sistema.
Además, permite distinguir entre el primer y segundo número ingresado, y genera las señales necesarias (guardar, suma, rst_sv) para coordinar el proceso con el módulo aritmético.


Subsistema 2: Suma aritmética

El módulo Suma_datos se encarga de realizar la suma decimal entre los dos números almacenados. Opera dígito por dígito utilizando un acarreo interno que se propaga entre los cuatro nibbles, ajustando el resultado para valores mayores o iguales a 10 (corrigiendo a formato BCD).

Al completarse la operación, activa la señal ent para indicar que el resultado está disponible y reinicia los registros de entrada mediante rst_sv en caso de que se desee comenzar una nueva captura.
Este bloque garantiza que la operación aritmética sea completamente sincrónica y libre de condiciones de carrera, ya que todas las operaciones se actualizan únicamente en los flancos positivos del reloj principal.


Subsistema 3: Despliegue de resultados

El módulo mux_info actúa como un multiplexor de selección de fuente.
Cuando ent = 0, el multiplexor envia los números que el usuario está ingresando. Cuando ent = 1, el multiplexor muestra el resultado de la suma contenido en resultado.

De esta manera, se realiza una transición automática y controlada entre las fases de entrada y salida del sistema. Posteriormente, el módulo mux_numeros toma los cuatro dígitos activos de s_mux y los barre secuencialmente a alta velocidad. Esto permite que los cuatro displays compartan las mismas líneas de segmentos, activándose uno a la vez mediante una rotación controlada por un contador de dos bits.
Finalmente, el módulo display7 convierte cada valor de 4 bits en su patrón correspondiente de siete segmentos.

