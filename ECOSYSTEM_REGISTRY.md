# 🌐 Registro de Ecosistema - WoWPeru_GameModes

**Versión del Registro:** 1.0.0  
**Fecha de Actualización:** 27 de Septiembre de 2026  
**Líder Técnico / Arquitecto:** DarckRovert (Ingame: `Elnazzareno`)  
**Servidor Destino:** [WoW Perú](https://wow-peru.lat/) - Reino Andino  
**Entorno:** WotLK 3.3.5a (Build 12340) | TrinityCore / AzerothCore con Eluna Lua Engine  

---

## 1. Identidad de Red y Protocolo

| Campo | Valor |
| :--- | :--- |
| **Prefijo `SendAddonMessage`** | `WP_GAMEMODE` (reservado exclusivamente para este sistema) |
| **Canal de Transporte** | `GUILD` → `RAID` → `PARTY` → `SAY` (fallback dinámico) |
| **Tabla MySQL** | `character_gamemodes` (base de datos `characters`) |
| **Script Eluna** | `71_GameModesSystem.lua` (carga en orden lexicográfico después de `70_BattlePassSystem.lua`) |

### 1.1. OpCodes del Protocolo `WP_GAMEMODE`

| Dirección | OpCode | Descripción |
| :--- | :--- | :--- |
| Cliente → Servidor | `SET_MODE:NORMAL` | Jugador elige modo Aventurero estándar |
| Cliente → Servidor | `SET_MODE:HARDCORE` | Jugador elige modo Hardcore (1 vida) |
| Cliente → Servidor | `SET_MODE:IRONMAN` | Jugador elige modo Ironman |
| Cliente → Servidor | `SET_MODE:X1` | Jugador elige modo Reto Andino x1 |
| Servidor → Cliente | `ACK:<MODO>` | Servidor confirma activación exitosa del modo |
| Servidor → Cliente | `STATUS:<MODO>` | Servidor re-sincroniza el estado del personaje |
| Servidor → Cliente | `ERR:<mensaje>` | Servidor comunica un error al cliente |

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

## 3. Posición en el Ecosistema WoW Perú

Este módulo es parte del ecosistema de 4 sistemas. Ver el registro maestro completo en:
- [Auditoría Maestra del Ecosistema](../ECOSYSTEM_MASTER_AUDIT.md)

| Sistema | Prefijo | Propósito | Convive con GameModes |
| :--- | :--- | :--- | :--- |
| `WoWPeru_BattlePass` | `WP_BP` | Progresión estacional de 50 niveles | ✅ Sin conflicto |
| **`WoWPeru_GameModes`** | **`WP_GAMEMODE`** | **Este módulo** | — |
| `WowPeruVisualShop` | `WP_VISUAL` | Cosméticos y visuales | ✅ Sin conflicto |
| `WoWPeru_RaidSuite` | `SEQUITO` | Suite de combate y raids | ✅ Sin conflicto |

---

## 4. Flujo de Ejecución del Sistema

```
[Personaje Nivel 1 entra al mundo]
          │
          ▼
[PLAYER_ENTERING_WORLD]
    IsEligibleForPrompt()
          │
     ┌────┴──────────────────┐
  (Nivel != 1)          (Nivel == 1 y no tiene modo)
     │                       │
  No mostrar           Timer 1.0s (OnUpdate)
                             │
                    [Abrir UI Cinematográfica]
                             │
                    [Jugador elige modo]
                             │
                    [Modal de confirmación si es riesgo]
                             │
                    ApplyMode(modeId)
                    ├─ Guardar localmente (CharDB)
                    ├─ ExecuteServerCommand(cmd)
                    └─ SendServerAddonMessage(payload)
                             │
                    [Servidor recibe y valida]
                    ├─ INSERT INTO character_gamemodes
                    └─ SendAddonMessage("ACK:HARDCORE")
                             │
                    [Cliente recibe ACK → UI se sella]
```

---

## 5. Integración con el Parche MPQ

Este módulo está diseñado para ser embebido en `Data/patch-Z-WOWPERU.MPQ` de modo que ningún jugador pueda eliminarlo. La estructura MPQ debe replicar exactamente:

```
Interface\AddOns\WoWPeru_GameModes\
    ├── WoWPeru_GameModes.toc
    ├── Config.lua
    ├── Locales.lua
    ├── Core.lua
    └── UI.lua
```

Los archivos `.md` (documentación) no deben incluirse en el MPQ ya que no son necesarios en el cliente del jugador.
