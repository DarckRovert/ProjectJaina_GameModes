--[[
    WoW Perú - Selector de Modos de Juego (Core.lua)
    Lógica de eventos, comprobación de primer ingreso y despacho de red.
]]

WoWPeru_GameModes = WoWPeru_GameModes or {}
local M = WoWPeru_GameModes

-- Inicialización del marco de eventos
local eventFrame = CreateFrame("Frame", "WoWPeru_GameModes_EventFrame", UIParent)
M.eventFrame = eventFrame

-- Registro de eventos clave
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Temporizador seguro para retrasar la apertura tras la pantalla de carga
local function ScheduleTimer(delay, callback)
    local elapsed = 0
    local timerFrame = CreateFrame("Frame")
    timerFrame:SetScript("OnUpdate", function(self, dt)
        elapsed = elapsed + dt
        if elapsed >= delay then
            self:SetScript("OnUpdate", nil)
            callback()
        end
    end)
end

-- Despacho seguro de comandos hacia el core del servidor
local function ExecuteServerCommand(cmd)
    if not cmd or cmd == "" then return end
    
    -- Método 1: Simulación de caja de chat nativa (mayor compatibilidad con comandos de consola)
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.editBox then
        local prevText = DEFAULT_CHAT_FRAME.editBox:GetText()
        DEFAULT_CHAT_FRAME.editBox:SetText(cmd)
        ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox)
        DEFAULT_CHAT_FRAME.editBox:SetText(prevText or "")
    else
        -- Método 2: Fallback directo por SendChatMessage
        SendChatMessage(cmd, "SAY")
    end
end

-- Despacho de paquetes de Addon Message hacia scripts C++/Eluna
local function SendServerAddonMessage(prefix, payload)
    if not prefix or not payload then return end
    -- Se envía por canal de hermandad si existe, o whisper al propio jugador como loopback
    if IsInGuild() then
        SendAddonMessage(prefix, payload, "GUILD")
    else
        SendAddonMessage(prefix, payload, "WHISPER", UnitName("player"))
    end
end

-- Manejador principal de eventos
eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "WoWPeru_GameModes" then
        -- Inicialización de base de datos por personaje
        WoWPeru_GameModes_CharDB = WoWPeru_GameModes_CharDB or {
            hasSelectedMode = false,
            selectedMode = nil,
            timestamp = nil,
        }
        
        -- Inicialización de base de datos global de cuenta
        WoWPeru_GameModes_GlobalDB = WoWPeru_GameModes_GlobalDB or {
            version = "1.0.0",
        }
        
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Comprobación empírica de primer ingreso
        if M.Config.AutoOpenOnFirstLogin then
            ScheduleTimer(0.8, function()
                local level = UnitLevel("player")
                local xp = UnitXP("player")
                local hasSelected = WoWPeru_GameModes_CharDB and WoWPeru_GameModes_CharDB.hasSelectedMode

                -- Solo abrir automáticamente si es nivel 1, tiene 0 XP y no ha elegido aún
                if level <= (M.Config.MaxLevelForPrompt or 1) and xp <= (M.Config.MaxXPForPrompt or 0) and not hasSelected then
                    M:OpenSelectionUI()
                end
            end)
        end
    end
end)

-- Función pública para aplicar el modo seleccionado
function M:ApplyMode(modeId)
    local selectedMode = nil
    for _, mode in ipairs(M.Config.Modes) do
        if mode.id == modeId then
            selectedMode = mode
            break
        end
    end

    if not selectedMode then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[WoW Perú] Error: Modo no encontrado: " .. tostring(modeId))
        return
    end

    -- Guardar estado localmente en el personaje
    WoWPeru_GameModes_CharDB.hasSelectedMode = true
    WoWPeru_GameModes_CharDB.selectedMode = selectedMode.id
    WoWPeru_GameModes_CharDB.timestamp = time()

    -- Ejecutar despacho según configuración
    local method = M.Config.DispatchMethod or "BOTH"
    
    if method == "COMMAND" or method == "BOTH" then
        if selectedMode.command and selectedMode.command ~= "" then
            ExecuteServerCommand(selectedMode.command)
        end
    end

    if method == "ADDON_MSG" or method == "BOTH" then
        if selectedMode.addonPayload and selectedMode.addonPayload ~= "" then
            SendServerAddonMessage(M.Config.AddonMsgPrefix, selectedMode.addonPayload)
        end
    end

    -- Reproducir sonido de confirmación
    if M.Config.SoundOnConfirm then
        PlaySoundFile(M.Config.SoundOnConfirm)
    end

    -- Mensaje de bienvenida y confirmación en el chat
    local msg = string.format(M.L["SELECTION_SUCCESS"], selectedMode.title)
    DEFAULT_CHAT_FRAME:AddMessage(msg)

    -- Cerrar la interfaz
    M:CloseSelectionUI()
end

-- Comandos Slash (/wpmodes, /modos)
SLASH_WOWPERU_MODES1 = "/wpmodes"
SLASH_WOWPERU_MODES2 = "/modos"
SlashCmdList["WOWPERU_MODES"] = function(msg)
    local cmd = string.lower(string.trim(msg or ""))
    
    if cmd == "" or cmd == "show" or cmd == "menu" then
        M:OpenSelectionUI()
    elseif cmd == "status" then
        local current = (WoWPeru_GameModes_CharDB and WoWPeru_GameModes_CharDB.selectedMode) or "Ninguno"
        local locked = (WoWPeru_GameModes_CharDB and WoWPeru_GameModes_CharDB.hasSelectedMode) and "Sí" or "No"
        DEFAULT_CHAT_FRAME:AddMessage(string.format(M.L["STATUS_COMMAND"], UnitName("player"), current, locked))
    elseif cmd == "reset" then
        if WoWPeru_GameModes_CharDB then
            WoWPeru_GameModes_CharDB.hasSelectedMode = false
            WoWPeru_GameModes_CharDB.selectedMode = nil
            WoWPeru_GameModes_CharDB.timestamp = nil
        end
        DEFAULT_CHAT_FRAME:AddMessage(M.L["RESET_SUCCESS"])
    else
        DEFAULT_CHAT_FRAME:AddMessage(M.L["CMD_HELP_HEADER"])
        DEFAULT_CHAT_FRAME:AddMessage(M.L["CMD_HELP_SHOW"])
        DEFAULT_CHAT_FRAME:AddMessage(M.L["CMD_HELP_STATUS"])
        DEFAULT_CHAT_FRAME:AddMessage(M.L["CMD_HELP_RESET"])
    end
end
