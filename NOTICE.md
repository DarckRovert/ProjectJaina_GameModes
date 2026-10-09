# 📜 Aviso Legal y Atribución — Wanos_GameModes

Este repositorio forma parte del ecosistema oficial de **Project Jaina - Project Jaina**.
Contiene el selector cinematográfico de modos de juego (Normal, Hardcore, Ironman, Reto Andino) para World of Warcraft 3.3.5a (Build 12340).

---

## 1. Autoría y Desarrollo Oficial
* **Desarrollador Principal:** DarckRovert (Ingame: `Elnazzareno`) & Project Jaina Team
* **Ecosistema:** [Project Jaina — Project Jaina](https://projectjaina.com/)
* **Repositorio Oficial:** [DarckRovert/Wanos_GameModes](https://github.com/DarckRovert/Wanos_GameModes)

---

## 2. Arquitectura Cliente-Servidor
* **Prefijo de Red:** `WP_GAMEMODE` (Canales: `GUILD`, `PARTY`, `RAID`).
* **Backend Autoritativo:** Script Eluna `71_GameModesSystem.lua` y tabla MySQL `character_gamemodes`.
* **Seguridad de Reglas:** La asignación de reglas de permadeath (Hardcore) y restricciones de equipo (Ironman) son fiscalizadas en el servidor. La interfaz del cliente proporciona una experiencia cinematográfica inmersiva para la selección inicial.

---

## 3. Cumplimiento de Políticas de Interfaz
Distribuido bajo licencia MIT sin fines de lucro, conforme a las directivas de desarrollo de interfaces de Blizzard Entertainment.
