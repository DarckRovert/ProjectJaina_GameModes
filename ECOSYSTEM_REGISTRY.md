# 🌐 Registro de Ecosistema — ProjectJaina_GameModes

Ficha técnica oficial de registro en la infraestructura multi-addon de **Project Jaina - Project Jaina**.

---

## 1. Identidad del Addon en el Ecosistema

| Campo | Valor |
|---|---|
| **Nombre Técnico** | `ProjectJaina_GameModes` |
| **Carpeta Local** | `ProjectJaina_GameModes` |
| **Versión Actual** | `1.0.0` |
| **Clasificación** | Cliente / Gameplay |
| **Licencia Formal** | MIT |
| **Repositorio GitHub** | [ProjectJaina_GameModes](https://github.com/DarckRovert/ProjectJaina_GameModes) |
| **Entorno de Juego** | World of Warcraft 3.3.5a (Build 12340) / AzerothCore |

---

## 2. Base de Datos MySQL

### Tabla: `character_gamemodes`

```sql
CREATE TABLE IF NOT EXISTS `character_gamemodes` (
    `guid`          INT UNSIGNED NOT NULL,
    `mode`          VARCHAR(20)  NOT NULL DEFAULT 'NORMAL',
    `lives_left`    TINYINT      NOT NULL DEFAULT 1,
    `activated_at`  INT UNSIGNED NOT NULL DEFAULT 0,
    `updated_at`    INT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

> **Nota de Seguridad:** La tabla debe purgarse en `PLAYER_EVENT_ON_CHARACTER_DELETE` (Evento 2 de Eluna) para evitar colisiones de datos con LowGUIDs reciclados por el emulador.

---

---

## 🏛️ Directorio Maestro del Ecosistema Project Jaina (18 Repositorios)

### A. Módulos Oficiales del Cliente (`Client\Interface\AddOns\`)

| # | Repositorio GitHub | Carpeta Local | Versión | Tipo / Licencia | Propósito en el Ecosistema |
|:---:|---|---|:---:|:---:|---|
| 01 | [ProjectJaina_AbbreviatedStatus](https://github.com/DarckRovert/ProjectJaina_AbbreviatedStatus) | `AbbreviatedStatus` | 1.2.1 | MIT / Fork | Abreviación compacta y formateo legible de salud y maná sin división por cero. |
| 02 | [Jaina_BattlePass](https://github.com/DarckRovert/Jaina_BattlePass) | `Jaina_BattlePass` | 2.0.0 | MIT | Pase de Batalla estacional de 50 niveles con backend Eluna y bitmask de progreso. |
| 03 | [ProjectJaina_Carbonite](https://github.com/DarckRovert/ProjectJaina_Carbonite) | `ProjectJaina_Carbonite` | 3.3.4-WP | Other / EULA | Suite satelital HD de cartografía, navegación multi-zona y misiones. |
| 04 | [ProjectJaina_Companion](https://github.com/DarckRovert/ProjectJaina_Companion) | `ProjectJaina_Companion` | 1.0.3 | MIT | Hub social ligero, cross-faction (/comerciar, /invitar) y telemetría de grupo. |
| 05 | [ProjectJaina_DragonflightUI](https://github.com/DarckRovert/ProjectJaina_DragonflightUI) | `cDF` | 1.0.0 | MIT / BSD | Re-implementación visual moderna estilo Dragonflight 10.x para cliente 3.3.5a. |
| 06 | [ProjectJaina_GameModes](https://github.com/DarckRovert/ProjectJaina_GameModes) | `ProjectJaina_GameModes` | 1.0.0 | MIT | Selector cinemático de modos (Normal, Hardcore, Ironman) con verificación Eluna. |
| 07 | [ProjectJaina_GMGenie](https://github.com/DarckRovert/ProjectJaina_GMGenie) | `GMGenie` | 1.3.1 | GPL-3.0 | Suite administrativa integral para Game Masters adaptada a AzerothCore. |
| 08 | [ProjectJaina_ProjectJaina_IntiObjGPS](https://github.com/DarckRovert/ProjectJaina_ProjectJaina_IntiObjGPS) | `ProjectJaina_IntiObjGPS` | 1.0.0 | MIT | Editor por lotes de coordenadas GPS de GameObjects para Staff y constructores. |
| 09 | [ProjectJaina_LoreHUD](https://github.com/DarckRovert/ProjectJaina_LoreHUD) | `LoreHUD` | 1.0.0 | MIT | Diálogos cinemáticos inmersivos y subtítulos estilizados para misiones y Lore. |
| 10 | [ProjectJaina_PrideTrace](https://github.com/DarckRovert/ProjectJaina_PrideTrace) | `WowPeruPrideTrace` | 1.0.0 | MIT | Rastreador de combate y telemetría de eventos de orgullo en tiempo real. |
| 11 | [ProjectJaina_RaidSuite](https://github.com/DarckRovert/ProjectJaina_RaidSuite) | `ProjectJaina_RaidSuite` | 1.0.0 | MIT | Suite modular de herramientas analíticas para líderes de banda y oficiales. |
| 12 | [ProjectJaina_Talented](https://github.com/DarckRovert/ProjectJaina_Talented) | `Talented` | 3.3.5-WP | GPL-2.0 | Árbol de talentos avanzado con soporte para plantillas y compartición. |
| 13 | [ProjectJaina_TBCBalance](https://github.com/DarckRovert/ProjectJaina_TBCBalance) | `ProjectJaina_TBCBalance` | 1.0.0 | MIT | Monitor privado de balance y composición de bandas TBC para Game Masters. |
| 14 | [ProjectJaina_Wardrobe](https://github.com/DarckRovert/ProjectJaina_Wardrobe) | `ProjectJaina_Wardrobe` | 1.0.0 | MIT | Guardarropa, catálogo cosmético y transfiguración con backend Eluna (60_WardrobeSystem.lua). |
| 15 | [ProjectJaina_VisualShop](https://github.com/DarckRovert/ProjectJaina_VisualShop) | `ProjectJaina_VisualShop` | 1.0.1 | MIT | Tienda oficial de efectos visuales, auras y alas con backend Eluna (59_SpellVisualCatalog.lua). |
| 16 | [ProjectJaina_Voice](https://github.com/DarckRovert/ProjectJaina_Voice) | `ProjectJaina_Voice` | 1.0.0 | MIT | Voz espacial 3D por proximidad y vinculación WebRTC con backend Eluna (65_VoiceProximitySync.lua). |

### B. Suites Comunitarias Monorepositorio Pre-instaladas (`WoW_Peru_Lab\AddOns\`)

| # | Repositorio GitHub | Carpeta Local | Versión | Tipo / Licencia | Propósito en el Ecosistema |
|:---:|---|---|:---:|:---:|---|
| 17 | [ProjectJaina_DBM](https://github.com/DarckRovert/ProjectJaina_DBM) | `ProjectJaina_DBM` | 4.52-WP | CC BY-NC-SA 3.0 | Suite unificada de 13 módulos Deadly Boss Mods para todas las raids y mazmorras WotLK. |
| 18 | [ProjectJaina_GearScore](https://github.com/DarckRovert/ProjectJaina_GearScore) | `ProjectJaina_GearScore` | 3.1.16-WP | MIT / Comm. | Monorepositorio unificado de GearScore (3.1.16) y BonusScanner (5.3) sin dependencias rotas. |

---

## 📜 Principios de Gobernanza y Convivencia Arquitectónica

1. **Inmunidad a Taint:** Prohibido modificar o enganchar `UnitPopupMenus` de Blizzard para garantizar la estabilidad de menús contextuales y addons de curación (`HealBot`, `Grid`).
2. **Empirismo y Cero Suposiciones:** Todo cambio de protocolo o base de datos debe ser validado con inspección en disco y pruebas de red activas.
3. **Codificación Canónica:** Todo archivo de texto debe persistirse en **UTF-8 sin BOM** con saltos de línea estrictos **LF**.
4. **Preservación de Binarios:** Todos los assets multimedia (`.tga`, `.blp`, `.mp3`, `.ogg`, `.wav`, `.ttf`, `.m2`) se encuentran blindados mediante `.gitattributes` para evitar corrupción en transferencias Git.
