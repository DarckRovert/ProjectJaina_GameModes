# 📜 Aviso Legal y Atribución — WoWPeru_GameModes

Este repositorio forma parte del ecosistema oficial de **WoW Perú - Reino Andino**.
Contiene el selector cinematográfico de modos de juego (Normal, Hardcore, Ironman, Reto Andino) para World of Warcraft 3.3.5a (Build 12340).

---

## 1. Autoría y Desarrollo Oficial
* **Desarrollador Principal:** DarckRovert (Ingame: `Elnazzareno`) & WoW Perú Team
* **Ecosistema:** [WoW Perú — Reino Andino](https://wow-peru.lat/)
* **Repositorio Oficial:** [DarckRovert/WoWPeru_GameModes](https://github.com/DarckRovert/WoWPeru_GameModes)

---

## 2. Arquitectura Cliente-Servidor
* **Prefijo de Red:** `WP_GAMEMODE` (Canales: `GUILD`, `PARTY`, `RAID`).
* **Backend Autoritativo:** Script Eluna `71_GameModesSystem.lua` y tabla MySQL `character_gamemodes`.
* **Seguridad de Reglas:** La asignación de reglas de permadeath (Hardcore) y restricciones de equipo (Ironman) son fiscalizadas en el servidor. La interfaz del cliente proporciona una experiencia cinematográfica inmersiva para la selección inicial.

---

## 3. Cumplimiento de Políticas de Interfaz
Distribuido bajo licencia MIT sin fines de lucro, conforme a las directivas de desarrollo de interfaces de Blizzard Entertainment.
