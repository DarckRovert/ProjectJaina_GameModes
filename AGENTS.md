# 🤖 Reglas de Contexto y Memoria para Agentes de IA - Wanos_GameModes

> **Repositorio Oficial:** [DarckRovert/Wanos_GameModes](https://github.com/DarckRovert/Wanos_GameModes)  
> **Líder del Proyecto:** DarckRovert (Ingame: `Elnazzareno`)  
> **Servidor Destino:** [Project Jaina](https://worldofwanos.com/) - Project Jaina  
> **Entorno:** WotLK 3.3.5a (Build 12340) | Motor Eluna Lua Engine  

---

## 1. Directivas Inviolables para Agentes de IA

1. **Empirismo Estricto:** Antes de editar código, inspeccionar siempre los archivos reales con `view_file` o `grep_search`. Prohibido asumir APIs de Retail o Eluna inexistentes en 3.3.5a.

2. **Restricciones del Cliente 3.3.5a:**
   - **Sin `SetColorTexture()`:** Usar `SetTexture("Interface\\Buttons\\WHITE8X8")` + `SetVertexColor(r, g, b, a)`.
   - **Sin `C_Timer.After`:** Los temporizadores van en `OnUpdate` con variable `elapsed` acumuladora y **cancelación obligatoria** al finalizar: `frame:SetScript("OnUpdate", nil)`.
   - **Sin `RegisterAddonMessagePrefix`:** No existe en 3.3.5a. No incluirlo.

3. **Presupuesto de Red (255 Bytes):**
   - Prefijo oficial: `WP_GAMEMODE`.
   - Payloads: `SET_MODE:NORMAL`, `SET_MODE:HARDCORE`, `SET_MODE:IRONMAN`, `SET_MODE:X1`.
   - Ningún mensaje puede exceder 255 bytes.
   - Canal de despacho: `GUILD` → `RAID` → `PARTY` → `SAY` (orden de fallback dinámico).

4. **Inmutabilidad de la Selección:**
   - `Wanos_GameModes_CharDB.hasSelectedMode = true` es el candado local de la selección.
   - Solo el servidor (vía paquete `ACK:<modo>`) puede confirmar la selección de forma persistente.
   - Modificar el candado local solo con `Config.Debug = true` y únicamente para pruebas de QA.

5. **Seguridad de Base de Datos:**
   - El script de servidor (`71_GameModesSystem.lua`) debe purgar `character_gamemodes` en `PLAYER_EVENT_ON_CHARACTER_DELETE` (Evento 2 de Eluna) para prevenir colisiones de LowGUIDs reciclados.

6. **Rendimiento (Cabinas de Internet):**
   - No instanciar marcos dinámicamente en bucles. Las 4 tarjetas de modo se crean una sola vez al inicio.
   - Todo `OnUpdate` acoplado a cualquier frame debe cancelarse explícitamente antes de ocultar o destruir ese frame.

7. **Git:** Rama canónica exclusiva `main`. Prohibido crear o usar `master`.

---

## 2. Arquitectura de Archivos

| Archivo | Propósito |
| :--- | :--- |
| [Config.lua](Config.lua) | Catálogo de los 4 modos, comandos, payloads y parámetros de UX. **Fuente única de verdad** para el staff. |
| [Locales.lua](Locales.lua) | Strings localizados en español con fallback a inglés. |
| [Core.lua](Core.lua) | Motor de eventos: detección de primer login, timer seguro, despacho de red y slash commands. |
| [UI.lua](UI.lua) | Interfaz cinematográfica, tarjetas con hover, modal de confirmación con blocker. |
| [INTEGRACION_STAFF.md](INTEGRACION_STAFF.md) | Guía técnica de instalación en MPQ y conexión con backend Eluna/C++. |
