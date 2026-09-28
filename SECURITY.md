# 🛡️ Política de Seguridad - WoW Perú Game Modes

**Versión:** 1.0.0  
**Fecha de Vigencia:** 27 de Septiembre de 2026  
**Responsable de Seguridad:** DarckRovert (Elnazzareno)  

---

## 1. Modelo de Seguridad

**WoWPeru_GameModes** sigue el principio de **Autoridad Exclusiva del Servidor**:

- El cliente (`Core.lua`, `UI.lua`) actúa únicamente como **presentador de opciones y emisor de intención**.
- La selección de modo **no es válida hasta que el servidor la confirme** mediante el paquete `ACK:<modo>`.
- El guardado local en `WoWPeru_GameModes_CharDB.hasSelectedMode` es una optimización de UX para evitar mostrar el selector repetidamente, pero **no tiene valor de autoridad** sobre el estado real en la base de datos del servidor.

---

## 2. Mecanismos de Defensa Implementados

### 2.1. Candado Local de Inmutabilidad
- Una vez que el jugador selecciona un modo y el servidor responde con `ACK:`, el flag `hasSelectedMode = true` se fija localmente.
- El sistema rechaza cualquier intento adicional de selección con un mensaje de error informativo y cierra la UI.
- El único mecanismo de reset local es `/wpmodes reset` con `Config.Debug = true`, protegido por un guard condicional explícito en `Core.lua`.

### 2.2. Modal de Confirmación Anti-Missclick
- Los modos de riesgo extremo (`requireConfirmation = true`) activan un diálogo de confirmación con:
  - Un frame `FULLSCREEN_DIALOG` que bloquea todos los clicks de las tarjetas de fondo (`EnableMouse(true)`).
  - Un scrim oscuro semitransparente que visualmente desmarca la UI principal.
  - Dos botones explícitos: confirmación y cancelación.
- Esto hace matemáticamente imposible la activación accidental de Hardcore o Ironman.

### 2.3. Protección de Combate
- Si el personaje entra en combate (`PLAYER_REGEN_DISABLED`) mientras el selector está abierto, la UI se cierra automáticamente con un mensaje de advertencia.
- La UI se reabre automáticamente al salir del combate si el personaje aún no ha seleccionado su modo.

### 2.4. Validación Dual de Elegibilidad
- El sistema verifica doble condición antes de abrir el selector:
  1. `WoWPeru_GameModes_CharDB.hasSelectedMode == false` (bandera local).
  2. `CheckServerAuras()` escanea las auras activas en busca de `"hardcore"` o `"ironman"`, cubriendo el caso de que el jugador borre su carpeta `WTF/` (reseteo de SavedVariables) en una cabina de internet.

### 2.5. Integridad en el Ciclo de Vida de Personajes
- El script de servidor `71_GameModesSystem.lua` debe escuchar `PLAYER_EVENT_ON_CHARACTER_DELETE` (Evento 2 de Eluna) para purgar la fila del personaje en `character_gamemodes`.
- Esto previene que un nuevo personaje creado con el mismo LowGUID herede un modo de juego activo del personaje eliminado.

### 2.6. Sanitización de Comandos de Servidor
- Los comandos enviados al servidor (`.hardcore on`, `.desafio`, etc.) son strings estáticos definidos en `Config.lua`. No se interpola ningún input del usuario en ellos.
- No existe superficie de ataque de inyección de comandos en la versión actual.

---

## 3. Notificación Responsable de Vulnerabilidades

Si descubres un fallo que permita:
- Evadir la selección de modo sin restricciones del servidor.
- Duplicar o falsificar paquetes `ACK:`.
- Manipular `hasSelectedMode` sin autorización del servidor.

**NO abras un issue público en GitHub.** Contacta directamente:

- **Discord:** Busca a `DarckRovert` en el servidor oficial de WoW Perú.
- **In-game:** Personaje `Elnazzareno` en el Reino Andino.
- **Servidor web:** [https://wow-peru.lat/](https://wow-peru.lat/)

Proporciona:
1. Pasos detallados para reproducir el comportamiento.
2. Captura de pantalla o log de errores de Eluna/consola del emulador.
3. Impacto estimado sobre la integridad del servidor.
