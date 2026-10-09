# ⚔️ Project Jaina - Selector de Modos de Juego (Game Modes Suite)

[![GitHub](https://img.shields.io/badge/GitHub-DarckRovert%2FProjectJaina_GameModes-black?logo=github)](https://github.com/DarckRovert/ProjectJaina_GameModes)

[![WoW Client](https://img.shields.io/badge/WoW%20Client-3.3.5a%20(Build%2012340)-blue.svg)](https://darckrovert.github.io/ProjectJaina_Web/)
[![Server](https://img.shields.io/badge/Servidor-Project%20Jaina-00ccff.svg)](https://darckrovert.github.io/ProjectJaina_Web/)
[![Realm](https://img.shields.io/badge/Reino-Reino%20Andino-red.svg)](https://darckrovert.github.io/ProjectJaina_Web/)
[![License](https://img.shields.io/badge/Licencia-MIT-green.svg)](LICENSE)

**Módulo nativo y cinematográfico de selección de modos de juego para nuevos personajes en el servidor privado Project Jaina (Project Jaina).**

Desarrollado en colaboración para [Project Jaina](https://darckrovert.github.io/ProjectJaina_Web/).

---

## 🌟 ¿Qué es este proyecto?

En World of Warcraft 3.3.5a nativo no existe un selector de modos de juego en la creación de personajes. Este proyecto resuelve la fricción de experiencia de usuario (UX) ofreciendo una **pantalla cinematográfica de bienvenida y elección de destino** en el primer ingreso al mundo (Nivel 1, 0 XP).

El jugador no necesita descargar ningún addon externo de internet si el staff del servidor empaqueta este módulo dentro de su parche oficial `patch-Z-Project Jaina.MPQ` o en el cliente de distribución.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        ELIGE TU DESTINO EN AZEROTH                     │
├─────────────────┬──────────────────┬──────────────────┬────────────────┤
│ 🗡️ AVENTURERO   │ 💀 HARDCORE      │ 🛡️ IRONMAN       │ 🗺️ RETO X1     │
│ Modo Estándar   │ 1 Sola Vida      │ Autosuficiencia  │ Progresión     │
│ Reglas clásicas │ Muerte definitiva│ Sin comercio     │ Blizzlike pura │
│ Comercio libre  │ Recompensas 80   │ Sin subastas     │ Vanilla 1 a 60 │
└─────────────────┴──────────────────┴──────────────────┴────────────────┘
```

---

## ✨ Características Principales

1. **Apertura Cinematográfica Automática**:
   * Detecta automáticamente personajes recién creados (`Nivel == 1` y `XP == 0`).
   * Oscurece la pantalla de juego con un efecto de viñeta inmersivo que centra la atención del usuario en su decisión.
2. **Catálogo de 4 Modos Configurables**:
   * **Modo Aventurero (Normal):** Experiencia Blizzlike clásica sin restricciones.
   * **Modo Hardcore (1 Vida):** Muerte permanente con advertencia de confirmación irreversible.
   * **Modo Ironman:** Desafío solitario sin comercio, correo ni subastas.
   * **Reto Andino x1:** Ritmo de experiencia pausado para la fase de progresión.
3. **Modal de Confirmación Anti-Missclick**:
   * Los modos de riesgo extremo requieren una doble confirmación explícita con un diálogo de seguridad.
4. **Arquitectura Desacoplada (Cliente ➔ Servidor)**:
   * Compatible de fábrica con comandos de consola estándar de AzerothCore/TrinityCore (ej: `.hardcore on`, `.desafio`).
   * Soporta comunicación por mensajes de addon (`SendAddonMessage`) para scripts C++ o Eluna.
5. **Configuración Amigable para el Staff**:
   * Archivo `Config.lua` limpio y comentado para activar, desactivar o modificar cualquier modo en segundos sin tocar código complejo.

---

## 📂 Estructura del Addon

```
Interface/AddOns/ProjectJaina_GameModes/
├── ProjectJaina_GameModes.toc       # Metadatos del addon para cliente 3.3.5a
├── Config.lua                  # Catálogo de modos, comandos y parámetros
├── Locales.lua                 # Textos en español (con fallback a inglés)
├── Core.lua                    # Detección de login, guardado y despacho de red
├── UI.lua                      # Interfaz visual, tarjetas con hover y modales
├── INTEGRACION_STAFF.md        # Guía técnica para desarrolladores del servidor
└── README.md                   # Documentación general del repositorio
```

---

## ⌨️ Comandos Disponibles

| Comando | Alias | Descripción |
| :--- | :--- | :--- |
| `/wpmodes` | `/modos` | Abre el menú de selección de modos. |
| `/wpmodes status` | `/modos status` | Muestra el modo actual seleccionado por el personaje. |
| `/wpmodes reset` | `/modos reset` | *(Uso Dev/GM)* Resetea el bloqueo local para pruebas. |

---

## 🛠️ Instalación Rápida para Pruebas

1. Clona o copia la carpeta `ProjectJaina_GameModes` dentro de tu directorio `World of Warcraft/Interface/AddOns/`.
2. Inicia el juego con el cliente 3.3.5a.
3. Entra con un personaje nuevo de nivel 1 o escribe `/wpmodes` en el chat.

---

## 📄 Licencia

Este proyecto está licenciado bajo los términos de la **Licencia MIT**. Consulta el archivo [LICENSE](LICENSE) para más detalles.

---

## 📚 Documentación del Ecosistema

* [Ficha Técnica Oficial del Ecosistema](ECOSYSTEM_REGISTRY.md)
* [Historial de Cambios](CHANGELOG.md)
* [Guía Técnica de Integración para el Staff](INTEGRACION_STAFF.md)
* [Licencia MIT](LICENSE)

---

## 📜 Créditos y Reconocimientos

* **Diseño y Arquitectura:** [DarckRovert](https://github.com/DarckRovert)
* **Comunidad y Servidor Destino:** [Project Jaina](https://darckrovert.github.io/ProjectJaina_Web/) - Project Jaina
