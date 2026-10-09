--[[
    Project Jaina - Selector de Modos de Juego (Locales.lua)
]]

ProjectJaina_GameModes = ProjectJaina_GameModes or {}
local M = ProjectJaina_GameModes

local L = {
    ["APP_NAME"] = "Project Jaina - Modos de Juego",
    ["WELCOME_MSG"] = "¡Bienvenido al |cFFD4AF37Project Jaina|r! Selecciona tu modo de juego para comenzar tu aventura.",
    ["SELECT_BUTTON"] = "Elegir Modo",
    ["SELECTED_BADGE"] = "SELECCIONADO",
    ["CONFIRM_BUTTON"] = "¡Acepto el Desafío!",
    ["CANCEL_BUTTON"] = "Volver Atrás",
    ["CLOSE_BUTTON"] = "Cerrar",
    ["ALREADY_SELECTED"] = "Este personaje ya ha seleccionado el modo: |cFFD4AF37%s|r.",
    ["SELECTION_SUCCESS"] = "|cFFD4AF37[Project Jaina]|r Has elegido el |cFFFFD100%s|r. ¡Que la fortuna guíe tus pasos!",
    ["STATUS_COMMAND"] = "|cFFD4AF37[Project Jaina]|r Modo actual de %s: |cFFFFD100%s|r (Bloqueado: %s)",
    ["RESET_SUCCESS"] = "|cFFD4AF37[Project Jaina]|r El estado de modo de juego ha sido reseteado para pruebas locales.",
    ["CMD_HELP_HEADER"] = "|cFFD4AF37Comandos de Project Jaina - Modos de Juego:|r",
    ["CMD_HELP_SHOW"] = "  |cFFFFFFFF/wpmodes|r - Abre el menú de selección de modos",
    ["CMD_HELP_STATUS"] = "  |cFFFFFFFF/wpmodes status|r - Consulta el modo actual del personaje",
    ["CMD_HELP_RESET"] = "  |cFFFFFFFF/wpmodes reset|r - (Dev/GM) Resetea el bloqueo local para pruebas",
}

if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then
    -- English Fallback
    L["APP_NAME"] = "Project Jaina - Game Modes"
    L["WELCOME_MSG"] = "Welcome to |cFFD4AF37Project Jaina|r! Choose your game mode to begin your journey."
    L["SELECT_BUTTON"] = "Select Mode"
    L["SELECTED_BADGE"] = "SELECTED"
    L["CONFIRM_BUTTON"] = "Accept the Challenge!"
    L["CANCEL_BUTTON"] = "Go Back"
    L["CLOSE_BUTTON"] = "Close"
    L["ALREADY_SELECTED"] = "This character has already chosen mode: |cFFD4AF37%s|r."
    L["SELECTION_SUCCESS"] = "|cFFD4AF37[Project Jaina]|r You have chosen |cFFFFD100%s|r. May fortune guide your path!"
    L["STATUS_COMMAND"] = "|cFFD4AF37[Project Jaina]|r Current mode for %s: |cFFFFD100%s|r (Locked: %s)"
    L["RESET_SUCCESS"] = "|cFFD4AF37[Project Jaina]|r Local game mode state was reset for testing."
end

M.L = L
