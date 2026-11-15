# 🚢 BattleShip: Batalla Naval en MIPS

Proyecto Final - Organización del Computador  
Universidad Metropolitana 

## 📖 Descripción

Este es un clásico juego de Batalla Naval programado completamente en ensamblador MIPS R2000 y ejecutado en el simulador MARS 4.5. El juego utiliza la herramienta Bitmap Display para mostrar una interfaz gráfica dividida en dos tableros (ataque y defensa). Incluye lógica de turnos, una inteligencia artificial para la CPU, comodines aleatorios y un sistema de puntuación.

## ✨ Características principales

- 🌊 Interfaz gráfica con efecto de olas, bordes de arena y cursor parpadeante.
- 🤖 Dos modos de juego: Jugador contra Jugador (PvP) y Jugador contra CPU (PvCPU).
- 🧠 La CPU genera disparos aleatorios y utiliza una estrategia de caza: al impactar un barco, rastrea la dirección para hundirlo.
- 🃏 Comodines: Radar (5% de probabilidad de revelar un barco enemigo) y Ataque en Área (1 de 7 probabilidades de bombardear un cuadrado de 3x3).
- 🎯 Detección de hundimiento: cuando un barco entero es destruido, se pinta de color gris.
- 🏆 Sistema de puntuación: +1 punto por impacto, +5 puntos por barco hundido.
- 🛡️ Validación estricta: no se pueden colocar barcos sobre otros, fuera de los límites ni en las zonas de arena. Tampoco se puede disparar dos veces a la misma casilla.

## 🛠️ Requisitos y configuración en MARS

Para ejecutar el juego, necesitas tener instalado Java y MARS 4.5.

1. Abre el archivo main.asm en MARS.
2. Ve al menú Settings y asegúrate de tener desmarcada la opción "Assemble all files in directory".
3. Presiona F3 (Ensamblar). Si no hay errores, ve a Tools y abre Bitmap Display con esta configuración:
   - Unit Width in Pixels: 16
   - Unit Height in Pixels: 16
   - Display Width in Pixels: 256
   - Display Height in Pixels: 512
   - Base address for display: 0x10010000 (static data)
   - Haz clic en "Connect to MIPS".
4. Presiona F5 (Ejecutar).
5. Ve a la pestaña Run I/O en la parte inferior de MARS para ingresar las teclas y ver los mensajes.

## 🎮 Controles

- W / A / S / D: mover el cursor (arriba, izquierda, abajo, derecha).
- R: rotar el barco (horizontal / vertical) solo en la fase de colocación.
- E o Enter: confirmar la posición del barco o disparar.

## 👥 Autores

- Gianfranco Camporeale
- Juan Coll
- Grazia Di Cecilia
