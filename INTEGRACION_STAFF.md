# 📘 Guía de Integración Técnica para el Staff de Project Jaina

Este documento está dirigido al **administrador o desarrollador de backend/core de Project Jaina**. Explica cómo embeber el selector de modos de juego en el cliente oficial y cómo conectarlo con el emulador (AzerothCore o TrinityCore).

---

## 1. ¿Cómo embeber el Addon sin que el usuario descargue nada?

Para que el selector aparezca de forma nativa a todo jugador que descargue el cliente del servidor, existen dos métodos de distribución:

### Método A: Inyección en el Parche MPQ Oficial (Recomendado)
El cliente de Project Jaina ya utiliza el archivo `Data/patch-Z-Project Jaina.MPQ` para sobrescribir archivos del juego.

1. Descarga y abre **MPQEditor** (o herramienta similar de manipulación de MPQs de Blizzard).
2. Abre el archivo `Data/patch-Z-Project Jaina.MPQ`.
3. Navega a la estructura de carpetas:
   ```
   Interface\
     └── AddOns\
           └── ProjectJaina_GameModes\
   ```
4. Agrega los archivos del módulo:
   * `ProjectJaina_GameModes.toc`
   * `Config.lua`
   * `Locales.lua`
   * `Core.lua`
   * `UI.lua`
5. Guarda y compacta el MPQ.
6. Distribuye el archivo actualizado a través del launcher de Project Jaina. **Listo: ningún jugador podrá borrar el addon y se cargará automáticamente.**

### Método B: Distribución en la Carpeta Base del Cliente
Si distribuyes el cliente completo en archivo `.zip` o instalador, simplemente coloca la carpeta `ProjectJaina_GameModes` dentro de `World of Warcraft/Interface/AddOns/`.

---

## 2. Configuración de Comandos de Servidor (`Config.lua`)

El addon despacha la selección del jugador mediante los comandos que definas en [Config.lua](Config.lua).

Abre `Config.lua` y localiza la tabla `M.Config.Modes`:

```lua
{
    id = "HARDCORE",
    enabled = true,
    title = "Hardcore",
    command = ".hardcore on",         -- <-- Cambia aquí por el comando real de tu core
    addonPayload = "SET_MODE:HARDCORE",-- <-- Payload para scripts C++ o Eluna
    ...
}
```

* Si tu servidor usa **AzerothCore con `mod-hardcore`**, el comando por defecto suele ser:
  ```lua
  command = ".hardcore on"
  ```
* Si tu servidor usa un módulo propio o comando customizado:
  ```lua
  command = ".desafio hardcore"
  ```
* Para el modo normal (sin restricciones), si tu servidor no requiere ningún comando para jugar normal, puedes dejarlo vacío:
  ```lua
  command = ""
  ```

---

## 3. Integración Avanzada mediante `SendAddonMessage` (C++ / Eluna)

Si prefieres no usar comandos de chat visibles y quieres una comunicación silenciosa entre el cliente y el servidor, el addon está configurado para emitir automáticamente paquetes por canal oculto:

* **Prefix:** `WP_GAMEMODE` (configurable en `Config.AddonMsgPrefix`)
* **Payloads emitidos:**
  * `SET_MODE:NORMAL`
  * `SET_MODE:HARDCORE`
  * `SET_MODE:IRONMAN`
  * `SET_MODE:X1`

### Ejemplo de captura en Eluna (Protocolo Bidireccional con Handshake):
```lua
local PREFIX = "WP_GAMEMODE"

local function ProcessGameMode(player, mode)
    if mode == "SET_MODE:HARDCORE" then
        -- 1. Lógica del core: activar Hardcore en DB o añadir aura
        -- player:AddAura(80000, player) 
        player:SendBroadcastMessage("|cFFD4AF37[Project Jaina]|r ¡Modo Hardcore activado con éxito!")
        -- 2. Enviar confirmación ACK al cliente para sellar la UI
        player:SendAddonMessage(PREFIX, "ACK:HARDCORE", 0, player)

    elseif mode == "SET_MODE:NORMAL" then
        player:SendAddonMessage(PREFIX, "ACK:NORMAL", 0, player)
    elseif mode == "SET_MODE:IRONMAN" then
        player:SendAddonMessage(PREFIX, "ACK:IRONMAN", 0, player)
    elseif mode == "SET_MODE:X1" then
        player:SendAddonMessage(PREFIX, "ACK:X1", 0, player)
    end
end

-- Captura vía Addon Message (jugadores en hermandad o grupo)
local function OnAddonMessage(event, sender, type, prefix, text)
    if prefix == PREFIX then
        ProcessGameMode(sender, text)
    end
end
RegisterServerEvent(30, OnAddonMessage)

-- Captura vía comando transparente para personajes nivel 1 solitarios (.wp_gamemode)
local function OnPlayerCommand(event, player, command)
    local cmd, payload = command:match("^(%S+)%s+(%S+)$")
    if cmd and cmd:lower() == "wp_gamemode" then
        ProcessGameMode(player, payload)
        return false -- Silenciar el comando para que no arroje error en consola
    end
end
RegisterPlayerEvent(42, OnPlayerCommand)
```

---

## 4. ¿No tienen aún un Módulo Hardcore en el Backend?

Si el equipo de Project Jaina aún no ha implementado la lógica de muerte permanente en el emulador, la recomendación de ingeniería estándar es utilizar el módulo oficial de la comunidad:

* **Módulo Oficial AzerothCore:** [`azerothcore/mod-hardcore`](https://github.com/azerothcore/mod-hardcore)
* **Funcionalidades que incluye:**
  * Bloqueo de resurrección al morir.
  * Anuncio global en el reino cuando un jugador Hardcore muere.
  * Recompensas automáticas al alcanzar nivel 60/70/80.
  * Tabla dedicada en la base de datos `characters`.
