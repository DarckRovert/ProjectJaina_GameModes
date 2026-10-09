--[[
    Project Jaina - Selector de Modos de Juego (Core.lua)
    Lógica de eventos, comprobación de primer ingreso y despacho de red.
]]

ProjectJaina_GameModes = ProjectJaina_GameModes or {}
local M = ProjectJaina_GameModes

-- Inicialización del marco de eventos
local eventFrame = CreateFrame("Frame", "ProjectJaina_GameModes_EventFrame", UIParent)
M.eventFrame = eventFrame

-- Registro de eventos clave y de seguridad
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("CHAT_MSG_ADDON")
eventFrame:RegisterEvent("UNIT_AURA")

-- Temporizador estático en eventFrame (cero creación de frames huérfanos)
local timerActive = false
local timerElapsed = 0
local timerTarget = 0
local timerCallback = nil

local function StartSingleTimer(delay, callback)
    timerElapsed = 0
    timerTarget = delay
    timerCallback = callback
    if not timerActive then
        timerActive = true
        eventFrame:SetScript("OnUpdate", function(self, dt)
            timerElapsed = timerElapsed + dt
            if timerElapsed >= timerTarget then
                self:SetScript("OnUpdate", nil)
                timerActive = false
                if timerCallback then
                    local cb = timerCallback
                    timerCallback = nil
                    cb()
                end
            end
        end)
    end
end

-- Escaneo de seguridad de auras del servidor (evita desincronización por WTF borrado en cabinas)
local function CheckServerAuras()
    for i = 1, 40 do
        local name = UnitAura("player", i)
        if not name then break end
        local lowerName = string.lower(name)
        if string.find(lowerName, "hardcore") then
            if ProjectJaina_GameModes_CharDB then
                ProjectJaina_GameModes_CharDB.hasSelectedMode = true
                ProjectJaina_GameModes_CharDB.selectedMode = "HARDCORE"
            end
            return true
        elseif string.find(lowerName, "ironman") then
            if ProjectJaina_GameModes_CharDB then
                ProjectJaina_GameModes_CharDB.hasSelectedMode = true
                ProjectJaina_GameModes_CharDB.selectedMode = "IRONMAN"
            end
            return true
        end
    end
    return false
end

-- Comprobación robusta de elegibilidad para nuevo personaje
local function IsEligibleForPrompt()
    if not M.Config.AutoOpenOnFirstLogin then return false end
    if ProjectJaina_GameModes_CharDB and ProjectJaina_GameModes_CharDB.hasSelectedMode then return false end
    if CheckServerAuras() then return false end

    local level = UnitLevel("player")
    if not level or level == 0 then return false end

    local _, class = UnitClass("player")
    -- Si es Caballero de la Muerte, su nivel de inicio nativo es 55
    if class == "DEATHKNIGHT" then
        return level == 55
    end

    -- Para todas las demás clases, debe ser nivel 1 (sin bloqueo por XP de descubrimiento)
    return level == 1
end

-- Despacho seguro de comandos hacia el core del servidor (3.3.5a)
local function ExecuteServerCommand(cmd)
    if not cmd or cmd == "" then return end
    
    -- En WoW 3.3.5a (Build 12340), el widget nativo de chat es ChatFrame1EditBox o LAST_ACTIVE_CHAT_EDIT_BOX
    local editBox = ChatFrame1EditBox or LAST_ACTIVE_CHAT_EDIT_BOX
    if editBox and ChatEdit_SendText then
        local prevText = editBox:GetText()
        local prevType = editBox:GetAttribute("chatType")
        
        editBox:SetText(cmd)
        ChatEdit_SendText(editBox)
        
        -- Restaurar el texto y tipo previo si el usuario tenía algo escrito
        if prevText and prevText ~= "" then
            editBox:SetText(prevText)
        end
        if prevType then
            editBox:SetAttribute("chatType", prevType)
        end
    else
        -- Salvaguarda: Jamás filtrar comandos como texto en /say
        if DEFAULT_CHAT_FRAME then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF4444[Project Jaina]|r No se pudo despachar el comando del modo: " .. tostring(cmd))
        end
    end
end

-- Despacho seguro de paquetes hacia scripts C++/Eluna (WHISPER conforme a Ley III)
local function SendServerAddonMessage(prefix, payload)
    if not prefix or not payload then return end
    local playerName = UnitName("player")
    if not playerName or playerName == "" or playerName == UNKNOWNOBJECT then return end

    if RegisterAddonMessagePrefix then
        RegisterAddonMessagePrefix(prefix)
    end
    SendAddonMessage(prefix, payload, "WHISPER", playerName)
end

-- Manejador principal de eventos
eventFrame:SetScript("OnEvent", function(self, event, ...)
    local arg1, arg2, arg3, arg4 = ...
    if event == "ADDON_LOADED" and (arg1 == "Wanos_GameModes" or arg1 == "ProjectJaina_GameModes") then
        -- Inicialización de base de datos por personaje
        Wanos_GameModes_CharDB = Wanos_GameModes_CharDB or ProjectJaina_GameModes_CharDB or {
            hasSelectedMode = false,
            selectedMode = nil,
            timestamp = nil,
        }
        ProjectJaina_GameModes_CharDB = Wanos_GameModes_CharDB
            hasSelectedMode = false,
            selectedMode = nil,
            timestamp = nil,
        }
        
        -- Inicialización de base de datos global de cuenta
        Wanos_GameModes_GlobalDB = Wanos_GameModes_GlobalDB or ProjectJaina_GameModes_GlobalDB or {
            version = "1.0.0",
        }
        ProjectJaina_GameModes_GlobalDB = Wanos_GameModes_GlobalDB
            version = "1.0.0",
        }
        
    elseif event == "PLAYER_ENTERING_WORLD" then
        if RegisterAddonMessagePrefix then
            RegisterAddonMessagePrefix(M.Config.AddonMsgPrefix)
        end

        -- Solicitar estado autoritativo al servidor (Handshake inicial)
        SendServerAddonMessage(M.Config.AddonMsgPrefix, "REQ_STATUS")

        -- Timeout de seguridad (3.0s) únicamente como fallback si el servidor no responde
        StartSingleTimer(3.0, function()
            if IsEligibleForPrompt() and not InCombatLockdown() then
                M:OpenSelectionUI()
            end
        end)

    elseif event == "PLAYER_REGEN_DISABLED" then
        -- Protección de vida: cerrar modal inmediatamente si entra en combate
        if ProjectJaina_GameModes_MainFrame and ProjectJaina_GameModes_MainFrame:IsShown() then
            M:CloseSelectionUI()
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF2020[Project Jaina]|r Has entrado en combate. El selector se ha cerrado para protegerte.")
        end

    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Reabrir automáticamente tras salir de combate si aún no ha seleccionado modo
        if IsEligibleForPrompt() then
            StartSingleTimer(1.2, function()
                if IsEligibleForPrompt() and not InCombatLockdown() then
                    M:OpenSelectionUI()
                end
            end)
        end

    elseif event == "CHAT_MSG_ADDON" then
        local prefix, message, channel, sender = arg1, arg2, arg3, arg4
        if prefix == M.Config.AddonMsgPrefix and message then
            -- 1. Confirmación de activación exitosa desde el backend
            if string.find(message, "^ACK:") then
                local modeAck = string.sub(message, 5)
                if ProjectJaina_GameModes_CharDB then
                    ProjectJaina_GameModes_CharDB.hasSelectedMode = true
                    ProjectJaina_GameModes_CharDB.selectedMode = modeAck
                end
                if ProjectJaina_GameModes_MainFrame and ProjectJaina_GameModes_MainFrame:IsShown() then
                    M:CloseSelectionUI()
                end
            -- 2. Reporte de estado desde el servidor (re-sincronización)
            elseif string.find(message, "^STATUS:") then
                local serverMode = string.sub(message, 8)
                if serverMode ~= "NONE" then
                    if ProjectJaina_GameModes_CharDB then
                        ProjectJaina_GameModes_CharDB.hasSelectedMode = true
                        ProjectJaina_GameModes_CharDB.selectedMode = serverMode
                    end
                    -- Si el menú de selección estaba en pantalla, cerrarlo de inmediato
                    if ProjectJaina_GameModes_MainFrame and ProjectJaina_GameModes_MainFrame:IsShown() then
                        M:CloseSelectionUI()
                    end
                else
                    -- El servidor confirma que es un personaje virgen sin modo asignado
                    if ProjectJaina_GameModes_CharDB then
                        ProjectJaina_GameModes_CharDB.hasSelectedMode = false
                        ProjectJaina_GameModes_CharDB.selectedMode = nil
                    end
                    if IsEligibleForPrompt() and not InCombatLockdown() then
                        M:OpenSelectionUI()
                    end
                end
            -- 3. Error devuelto por el servidor
            elseif string.find(message, "^ERR:") then
                local errMsg = string.sub(message, 5)
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFF2020[Project Jaina] Error del Servidor:|r " .. errMsg)
                -- Desbloquear localmente para permitir reintento si fue rechazado
                if ProjectJaina_GameModes_CharDB then
                    ProjectJaina_GameModes_CharDB.hasSelectedMode = false
                    ProjectJaina_GameModes_CharDB.selectedMode = nil
                end
            end
        end

    elseif event == "UNIT_AURA" and arg1 == "player" then
        CheckServerAuras()
    end
end)

-- Función pública para aplicar el modo seleccionado (con protección de inmutabilidad)
function M:ApplyMode(modeId, force)
    -- Candado de seguridad: Evitar sobrescritura si ya está bloqueado
    if ProjectJaina_GameModes_CharDB and ProjectJaina_GameModes_CharDB.hasSelectedMode and not force then
        local current = ProjectJaina_GameModes_CharDB.selectedMode or "Desconocido"
        DEFAULT_CHAT_FRAME:AddMessage(string.format(M.L["ALREADY_SELECTED"], current))
        M:CloseSelectionUI()
        return
    end

    local selectedMode = nil
    for _, mode in ipairs(M.Config.Modes) do
        if mode.id == modeId then
            selectedMode = mode
            break
        end
    end

    if not selectedMode then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[Project Jaina] Error: Modo no encontrado: " .. tostring(modeId))
        return
    end

    -- Guardar estado localmente en el personaje
    ProjectJaina_GameModes_CharDB.hasSelectedMode = true
    ProjectJaina_GameModes_CharDB.selectedMode = selectedMode.id
    ProjectJaina_GameModes_CharDB.timestamp = time()

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
        local current = (ProjectJaina_GameModes_CharDB and ProjectJaina_GameModes_CharDB.selectedMode) or "Ninguno"
        local locked = (ProjectJaina_GameModes_CharDB and ProjectJaina_GameModes_CharDB.hasSelectedMode) and "Sí" or "No"
        DEFAULT_CHAT_FRAME:AddMessage(string.format(M.L["STATUS_COMMAND"], UnitName("player"), current, locked))
    elseif cmd == "reset" then
        -- Candado de seguridad para producción: solo permitido si Debug está activo
        if not M.Config.Debug then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF2020[Project Jaina]|r El reseteo de modo solo está disponible en modo depuración (Config.Debug = true).")
            return
        end

        if ProjectJaina_GameModes_CharDB then
            ProjectJaina_GameModes_CharDB.hasSelectedMode = false
            ProjectJaina_GameModes_CharDB.selectedMode = nil
            ProjectJaina_GameModes_CharDB.timestamp = nil
        end
        DEFAULT_CHAT_FRAME:AddMessage(M.L["RESET_SUCCESS"])
    else
        DEFAULT_CHAT_FRAME:AddMessage(M.L["CMD_HELP_HEADER"])
        DEFAULT_CHAT_FRAME:AddMessage(M.L["CMD_HELP_SHOW"])
        DEFAULT_CHAT_FRAME:AddMessage(M.L["CMD_HELP_STATUS"])
        DEFAULT_CHAT_FRAME:AddMessage(M.L["CMD_HELP_RESET"])
    end
end
