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

Susistema 1: Lectura del teclado

Este es el primer módulo del circuito, se encarga de captar cual columna y fila han sido presionadas.Cada tecla es un botón que conecta una fila con una columna (para un teclado 4x4 son 16 combinaciones). Como cada vez que se presiona el botón quedan conectadas, se usa el módulo barrido para hacer un desplazamiento de un código one-hot a través de las columnas a la frecuencia de 27MHz que provee la FPGA, de esta manera se puede conocer la fila y columna del botón pues solo esa fila mostrará un 1 cada vez que el barrido de columnas pase por su columna. Se usa la variable vectorial col para estimular el barrido del one-hot através de las columnas y fil para representar el valor de las filas en cada momento.
El módulo de debounce soluciona un problema en la implementación del circuito, los 'rebotes' de los contactos metálicos del teclado al presionar un botón. El módulo actúa con un contador interno que requiere de un número mínimo de mediciones de 1 o 0 en la fila presionada hasta establecer el valor como 1 o 0, se usa porque una señal inestable puede generar problemas para identificar bien el valor a la hora de medirla.Las variable fil entra a este módulo para que se le aplique el debounce.
Cuando se detecta un valor de col y fil (ya pasado por debounce) se le asigna un valor a la variable integer numero, de manera que sea igual al número que representa ese botón.
![Lectura](/Imagenes/sistema_de_lectura_2.png)


Subsistema 2: Captura y almacenamiento de datos

El módulo “push_datos”, implementa un registro de desplazamiento controlado por una señal "push" desde el teclado. Cada flanco positivo del reloj con push = 1 (extraído de una señal del teclado) ingresa un nuevo dígito en el registro, empujando los valores anteriores a una posición más significativa. El módulo limita la entrada a tres dígitos y su número de salida representa los tres dígitos registrados junto con un cuarto dígito fijado en cero que se reserva para operaciones posteriores.

El módulo Guardado_datos recibe los datos del Push_datos y controla cuándo deben almacenarse permanentemente como un número válido dentro del sistema.
Además, permite distinguir entre el primer y segundo número ingresado, y genera las señales necesarias (guardar, suma, rst_sv) para coordinar el proceso con el módulo aritmético.


Subsistema 3: Suma aritmética

El módulo Suma_datos se encarga de realizar la suma decimal entre los dos números almacenados. Opera dígito por dígito utilizando un acarreo interno que se propaga entre los cuatro nibbles, ajustando el resultado para valores mayores o iguales a 10 (corrigiendo a formato BCD).

Al completarse la operación, activa la señal ent para indicar que el resultado está disponible y reinicia los registros de entrada mediante rst_sv en caso de que se desee comenzar una nueva captura.
Este bloque garantiza que la operación aritmética sea completamente sincrónica y libre de condiciones de carrera, ya que todas las operaciones se actualizan únicamente en los flancos positivos del reloj principal.


Subsistema 4: Despliegue de resultados

El módulo mux_info actúa como un multiplexor de selección de fuente.
Cuando ent = 0, el multiplexor envia los números que el usuario está ingresando. Cuando ent = 1, el multiplexor muestra el resultado de la suma contenido en resultado.

De esta manera, se realiza una transición automática y controlada entre las fases de entrada y salida del sistema. Posteriormente, el módulo mux_numeros toma los cuatro dígitos activos de s_mux y los barre secuencialmente a alta velocidad. Esto permite que los cuatro displays compartan las mismas líneas de segmentos, activándose uno a la vez mediante una rotación controlada por un contador de dos bits.
Finalmente, el módulo display7 convierte cada valor de 4 bits en su patrón correspondiente de siete segmentos.

4.  Diagramas de bloques de cada subsistema y su funcionamiento fundamental
![Conexiones del módulo](/Imagenes/Bloques_push.png)
![Conexiones del módulo](/Imagenes/Bloques_guardado.png)
![Conexiones del módulo](/Imagenes/Bloques_suma.png)
![Conexiones del módulo](/Imagenes/Bloques_lectordisplay7.png)
![Conexiones del módulo](/Imagenes/Bloque_total.png)


6. Ejemplo y análisis de una simulación funcional del sistema completo

![Conexiones del módulo](/Imagenes/Test.png)

Como se puede observar en un t=0 el sistema inicializa todas las variables en un valor 0, esperando un estimulo de salida desde el bloque de lectura, una vez obtenido el dato realiza el push del dato a la variable numero hasta tener 3 valores en este, una vez con los tres valores se recibe una señal de guardado. Con esa señal se hace una copia de la variable número en numero_sv, este una vez realizado el respaldo envía una señal rst_dat que realiza un reset en la variable número, para nuevamente esperar el ingreso de 3 números para realizar la suma, una vez se realiza un segundo guardado el sistema sabe que los datos están listos para la suma, una vez la suma esta lista se muestra su valor en los display.

Construcción de un cerrojo Set-Reset con compuertas NAND
El latch o cerrojo Set-Reset es un circuito secuencial que controla una variable Q en base a dos entradas S y R, se puede hacer con compuertas NOR o NAND, para este experimento se usaron compuertas NAND. Se armó el circuito de la figura para comprobar que funciona , o sea que sus entradas y salidas coincidan con la tabla de verdad. Con un analizador lógico se hacen las mediciones y se comprueba que el circuito de cerrojo SR funciona correctamente. En las figuras, D0, D1, D6 y D7 representan S, R, Q y Q' respectivamente. 
![Latch SR](/Imagenes/RS-with-NAND-gates-2.jpg)

![Latch SR](/Imagenes/SR00.jpg)

S=0 R=0 Q=1 QN=0 (estado anterior Q=1 QN=0) 

![Latch SR](/Imagenes/SR01.jpg)

S=0 R=1 Q=0 QN=1

![Latch SR](/Imagenes/SR10.jpg)

S=1 R=0 Q=1 QN=0

![Latch SR](/Imagenes/SR11.jpg)

S=1 R=1, Q y QN indefinidos

![Latch SR](/Imagenes/SR00_2.jpg)

S=0 R=0 Q=0 QN=1 (estado anterior Q=0 QN=1) 
