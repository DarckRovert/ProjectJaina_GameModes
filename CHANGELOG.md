# 📋 Registro de Cambios — ProjectJaina_GameModes

Todos los cambios notables de este proyecto están documentados en este archivo siguiendo el estándar [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/).

---

## [1.1.0] — 2026-10-22
### Rediseño Cinematográfico AAA y Soberanía de Red (Project Jaina Soberano)
- **Rediseño Visual AAA:** Tarjetas de pergamino verticales en proporción áurea (252x504 px) con renderizado a pantalla completa de las 4 ilustraciones maestras (512x1024 RGBA) para *Aventurero*, *Hardcore*, *Ironman* y *Reto Andino x1*.
- **Inmunidad a Fallos de Rasterizado 3.3.5a:** Sustituidos emojis UTF-8 en badges por secuencias de escape nativas de texturas WoW 3.3.5a (`|TInterface\Icons\...:12:12|t`).
- **Despeje de Retrato y Badges Flotantes:** Badge superior posicionado en cabecera (`TOP 0, -14`), despejando 100% el rostro del personaje.
- **Auto-escalado Responsive:** Función `ScaleContainerToScreen` con ajuste dinámico continuo entre 0.58 y 1.0 según la resolución nativa de pantalla.
- **Efectos Hover e Interactividad:** Resplandor dinámico (`glowBorder`), botones tipo Dragonflight con respuesta de clics y modal de advertencia para muerte permanente con bloqueo anti-clickthrough (`FULLSCREEN_DIALOG`).
- **Erradicación de Deuda Técnica Legacy:**
  - Eliminado el comando legacy `/wpmodes` y la variable de Blizzard `SLASH_WOWPERU_MODES`.
  - Registrados los comandos soberanos `SLASH_JAINA_MODES` (`/modos`, `/jainamodes`, `/gamemodes`).
  - Preservado el puente de interoperabilidad pasiva `SlashCmdList["WOWPERU_MODES"] = SlashCmdList["JAINA_MODES"]`.
  - Migrado el protocolo de red de `WP_GAMEMODE` a `JAINA_GAMEMODE` en sincronización simétrica con el backend Eluna (`80_GameModesSystem.lua`).

---

## [1.0.1] — 2026-10-10
### Estabilización de Ecosistema y Gobernanza Oficial (Project Jaina)
- **Normalización de UI y Gráficos:** Aspect ratio 1:1 estricto en iconos circulares (36x36 y 55x55), integración de SetBlendMode('BLEND') en ParchmentUI y blindaje de auras autoritativas para clientes de cabina.
- **Homologación Documental:** Incorporación y actualización formal de `GOVERNANCE.md`, `LICENSE`, `NOTICE.md` y `SECURITY.md`.
- **Licencia Canónica:** Consolidación de licencia MIT 2026 bajo titularidad de DarckRovert & Project Jaina Team.
- **Validación de Runtime:** Verificado al 100% con compilador sintáctico `lua52_compiler.exe -p` con 0 errores y 0 warnings.

---

## [1.0.0] — 2026-10-04
### Lanzamiento Inicial — Ecosistema Project Jaina WotLK 3.3.5a
- Implementación de la arquitectura base para Project Jaina Game Modes.
- Registro de comandos slash: `/gamemode, /modos`.
- Persistencia de configuración en `ProjectJaina_GameModesDB`.
- Compatibilidad certificada con cliente WotLK 3.3.5a (Build 12340) y directiva `Interface: 30300`.
