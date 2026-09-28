# 📋 Registro de Cambios (Changelog) - WoW Perú Game Modes

Todos los cambios notables en este proyecto se documentarán en este archivo.  
El formato se basa en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/) y este proyecto se adhiere a [Semantic Versioning](https://semver.org/lang/es/).

---

## [1.0.0] - 2026-09-27

### 🎉 Lanzamiento Oficial - WoW Perú Game Modes Suite

Primera versión de producción del selector cinematográfico de modos de juego de WoW Perú, diseñada para clientes WotLK 3.3.5a (Build 12340) y servidores TrinityCore/AzerothCore con motor Eluna.

### ✨ Nuevas Funcionalidades

- **Selector Cinematográfico de Modos:** Pantalla de bienvenida con oscurecimiento del mundo y 4 tarjetas interactivas para personajes de Nivel 1 en su primer ingreso al mundo.
- **4 Modos de Juego Configurables:** Aventurero (Normal), Hardcore (1 Vida), Ironman (Autosuficiencia) y Reto Andino x1. Todos activables/desactivables desde [Config.lua](Config.lua) sin tocar lógica de motor.
- **Modal de Confirmación Anti-Missclick:** Frame `FULLSCREEN_DIALOG` con scrim oscuro y bloqueo total de clicks traseros para modos de riesgo extremo (`requireConfirmation = true`).
- **Temporizador Seguro de Primer Login:** Timer de `1.0s` implementado con `OnUpdate` y cancelación explícita (`SetScript("OnUpdate", nil)`). Cero frames huérfanos.
- **Detección Dual de Elegibilidad:** Verificación combinada de flag local (`hasSelectedMode`) + escaneo de auras del servidor (`CheckServerAuras()`), resistente al reseteo de `WTF/` en cabinas de internet.
- **Protección de Combate:** Cierre automático de la UI al entrar en combate (`PLAYER_REGEN_DISABLED`) y reapertura automática al salir si aún no se ha seleccionado modo.
- **Despacho Flexible de Red:** Método `"BOTH"` por defecto: envía simultáneamente el comando de chat del servidor (`.hardcore on`) y el paquete `SendAddonMessage` (`SET_MODE:HARDCORE`). Canal de fallback dinámico: `GUILD` → `RAID` → `PARTY` → `SAY`.
- **Handshake de Confirmación del Servidor:** El addon espera el paquete `ACK:<modo>` del servidor para sellar definitivamente el flag `hasSelectedMode`. Soporta `STATUS:<modo>` para re-sincronización y `ERR:<mensaje>` para errores del backend.
- **Slash Commands:** `/wpmodes` y `/modos` para abrir el menú, consultar estado y resetear en modo debug.
- **Localización Bilingüe:** Strings en español (esES/esMX) con fallback automático a inglés para cualquier otra locale.

### 🛡️ Endurecimiento de Arquitectura

- **`SetTexture("Interface\\Buttons\\WHITE8X8")` + `SetVertexColor()`:** Toda textura de color sólido cumple la restricción de WotLK 3.3.5a. Cero llamadas a `SetColorTexture()` ni `SetTexture(r, g, b, a)`.
- **Candado de Producción en `/reset`:** El comando reset requiere `Config.Debug = true`. En producción con `Debug = false`, el comando muestra un mensaje de error informativo y no modifica nada.
- **Compatibilidad Eluna Polimórfica:** La estructura del handler Eluna de servidor soporta firmas de 5 y 6 argumentos en `OnAddonMessage` para compatibilidad con TrinityCore y AzerothCore.
- **Rama canónica `main`:** El repositorio usa exclusivamente la rama `main`. La rama `master` no existe ni puede recrearse.
