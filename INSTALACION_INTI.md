# Wanos_GameModes en Inti

Instalación local para revisar la interfaz del repositorio, exclusiva del reino `Inti (Pruebas)`.

- Origen: https://github.com/DarckRovert/Wanos_GameModes
- Revisión: `3dc0bcb18f22499161f3b021d088304652418124`
- Cliente: WoW 3.3.5a, compilación 12340.
- Carpeta: `C:\Users\vcarv\OneDrive\Desktop\WoW-Pe\Interface\AddOns\Wanos_GameModes`.

## Uso

Cierra completamente el cliente si estaba abierto y vuelve a abrirlo. En la selección de personajes, comprueba que el addon esté habilitado. Entra a Inti y escribe `/modos` o `/wpmodes`. Un personaje nuevo también recibe la bienvenida automáticamente. Escape o la X cierran el menú.

Esta instalación está en **vista previa**. Presenta cuatro pergaminos ilustrados y una confirmación adicional para Hardcore e Ironman, pero no envía comandos, no activa modos, no cambia personajes y no guarda una activación ficticia. Los textos de características de las tarjetas son una propuesta visual; no describen necesariamente las reglas actuales de Inti.

No se ejecuta fuera de `Inti (Pruebas)`. No se han modificado MPQ, configuración del cliente, otras instalaciones ni servicios del servidor.

## Revisión de compatibilidad

El repositorio solo incluye el addon cliente y una guía de integración. Sus comandos `.hardcore on`, `.desafio ironman`, `.desafio x1` y `.wp_gamemode` no tienen manejadores en las fuentes y scripts de Inti revisados.

Inti utiliza `mod-challenge-modes`: Hardcore y Semihardcore se activan mediante su altar, requieren nivel 2 exacto y el servidor valida historial y elegibilidad. IronMan y SlowXpGain están desactivados en la configuración revisada. Hardcore usa un multiplicador de experiencia propio. No se deben sustituir estas reglas por los ejemplos de la guía del addon.

El ejemplo de servidor de `INTEGRACION_STAFF.md` emite confirmaciones sin implementar las reglas de los modos. El cliente original también guarda y anuncia éxito antes de recibir confirmación del servidor. Por eso no se habilitó ese despacho en esta instalación.

Para activación real hace falta una integración separada con las funciones del servidor, validación de nivel e historial, catálogo fiel a los modos habilitados y respuesta autoritativa antes de marcar una selección como aceptada. Cambiar solamente `PreviewOnly` no realiza esa integración.

## Ajustes locales

- Diseño de pergaminos `1.0.0-inti-parchment.2`: cuatro ilustraciones originales, medallones, texto nativo legible y botones rojos interactivos.
- Subtítulo: «Cada camino tiene sus propias reglas. Conócelas antes de elegir». No afirma que sea posible cambiar de modo libremente.
- El archivo cargado por el TOC es `ParchmentUI.lua`. `UI.lua` se conserva como referencia, pero no se carga.
- Cuatro texturas TGA de 512 × 1024, 32 bits y transparencia. No se requieren parches MPQ.
- Escalado del panel completo para conservar los controles visibles en ventanas pequeñas.
- Restricción exacta al reino Inti y nombre visible actualizado.
- Vista previa explícita en pie de ventana, botones, confirmación, estado y mensajes.
- Cero despacho de comandos o mensajes de addon desde la vista previa.
- La prueba no bloquea localmente un modo ni procesa ACK externos como activación.
- Bloqueo de apertura durante combate; cierre del menú y modal al entrar en combate.
- Bienvenida automática una vez por sesión, evitando reaperturas en cada cambio de zona.
- Argumentos de eventos de addon recibidos explícitamente, en lugar de usar globales `arg2`/`arg3`/`arg4`.

Los archivos `README.md` e `INTEGRACION_STAFF.md` se conservan como documentación original. Para esta instalación prevalece la descripción técnica anterior.

## Verificación del diseño

27 comprobaciones automatizadas superadas con Lua 5.1 y una API de WoW simulada: carga y sintaxis, restricción de reino, vista previa sin envíos, confirmación, cierre en combate, frase actualizada, espacio estimado de texto y ajuste a 800 × 600.

Las cuatro texturas fueron verificadas byte a byte después de exportarlas a TGA, incluyendo alfa y orientación. La composición visual se revisó a 1280 × 760 y 800 × 600 fuera del juego. Esta composición utiliza fuentes y controles aproximados; no sustituye una prueba del renderizado en el cliente real.

El cliente estaba abierto durante la instalación; no se cerró por la fuerza. Cierra y vuelve a abrir WoW-Pe para cargar el TOC y las texturas nuevas. Después entra a Inti y usa `/modos` para comprobar el aspecto dentro del juego.

El respaldo previo a este rediseño está documentado internamente en la bitácora de versiones de Modos de Juego. Con el cliente cerrado se puede restaurar ese respaldo sobre este addon; su TOC vuelve a cargar la interfaz anterior.

## Desinstalación

Con el cliente cerrado, mover esta carpeta de addon fuera de `Interface\AddOns` revierte la instalación. No se reemplazó ningún addon previo ni se modificaron parches MPQ.
