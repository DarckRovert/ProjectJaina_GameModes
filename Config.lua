--[[
    ========================================================================
    Project Jaina - Selector de Modos de Juego (Game Modes Suite)
    Reino: Project Jaina | Servidor: https://projectjaina.com/
    Cliente Compatible: World of Warcraft 3.3.5a (Build 12340)
    ========================================================================
    Archivo de Configuración para el Staff y Desarrolladores del Servidor.
    Aquí se pueden activar/desactivar modos, cambiar textos, recompensas
    y definir los comandos o paquetes que se enviarán al servidor.
]]

ProjectJaina_GameModes = ProjectJaina_GameModes or {}
local M = ProjectJaina_GameModes

M.Config = {
    -- Título y branding superior de la ventana
    ServerName = "Project Jaina",
    RealmName = "Project Jaina",
    HeaderTitle = "ELIGE TU DESTINO",
    HeaderSubtitle = "Selecciona el modo de juego para este personaje. Tu camino forjará tu leyenda.",

    -- Control de Apertura Automática y Modo de Depuración
    AutoOpenOnFirstLogin = true,      -- Se abre de inmediato al entrar al mundo con un personaje nuevo
    MaxLevelForPrompt = 1,            -- Solo se muestra si el nivel es menor o igual a este valor (55 para DK)
    RequireDecisionToPlay = true,     -- Oscurece la pantalla de fondo para forzar una decisión clara
    Debug = false,                    -- Activar únicamente para pruebas internas del staff (permite /wpmodes reset)

    -- Método de comunicación hacia el servidor:
    -- "COMMAND"   : Ejecuta comandos de chat como .hardcore on o .desafio
    -- "ADDON_MSG" : Envía mensaje oculto por SendAddonMessage (ideal para módulos C++ o Eluna)
    -- "BOTH"      : Envía ambos métodos simultáneamente para máxima compatibilidad
    DispatchMethod = "ADDON_MSG",
    AddonMsgPrefix = "WP_GAMEMODE",

    -- Efectos audiovisuales
    SoundOnOpen = "Sound\\Interface\\iQuestLogOpen.wav",
    SoundOnSelect = "Sound\\Interface\\iQuestLogClose.wav",
    SoundOnConfirm = "Sound\\Interface\\ReadyCheck.wav",

    -- Catálogo de Modos de Juego
    -- Puedes cambiar 'enabled = false' para ocultar cualquiera de ellos
    Modes = {
        {
            id = "NORMAL",
            enabled = true,
            title = "Aventurero",
            badge = "Estándar",
            badgeColor = {0.2, 0.8, 0.2}, -- Verde
            accentColor = {0.85, 0.75, 0.35}, -- Dorado
            icon = "Interface\\Icons\\INV_Sword_04",
            tagline = "La experiencia clásica de World of Warcraft",
            description = "Juega con las reglas tradicionales de WotLK 3.3.5a. Sin restricciones de muerte, comercio libre, subastas y grupos con cualquier aventurero del reino.",
            perks = {
                "Resurrección normal en ángel o cuerpo",
                "Comercio, correo y subastas habilitados",
                "Grupos y hermandades sin límites",
                "Ritmo de experiencia regular del reino",
            },
            command = "", -- Vacío: no requiere comando de servidor para jugar normal
            addonPayload = "SET_MODE:NORMAL",
            requireConfirmation = false,
        },
        {
            id = "HARDCORE",
            enabled = true,
            title = "Hardcore",
            badge = "1 Sola Vida",
            badgeColor = {0.9, 0.1, 0.1}, -- Rojo Sangre
            accentColor = {1.0, 0.2, 0.2}, -- Carmesí
            icon = "Interface\\Icons\\Spell_Shadow_DeathScream",
            tagline = "El desafío definitivo de supervivencia",
            description = "Tienes una única vida en todo tu viaje. Si mueres en cualquier rincón de Azeroth, tu personaje queda muerto de forma definitiva e irreversible.",
            perks = {
                "Muerte permanente (sin resurrección)",
                "Auras y distinciones visuales en el reino",
                "Títulos y monturas exclusivas al nivel 80",
                "Inclusión en el Salón de la Fama Hardcore",
            },
            command = ".hardcore on",
            addonPayload = "SET_MODE:HARDCORE",
            requireConfirmation = true,
            confirmTitle = "¡ADVERTENCIA DE MUERTE PERMANENTE!",
            confirmWarning = "Estás a punto de activar el MODO HARDCORE.\n\nSi tu personaje muere por cualquier motivo (caídas, criaturas, fatiga o PvP), NO PODRÁS RESUCITAR JAMÁS en el Project Jaina.\n\n¿Tienes el valor de aceptar este destino?",
        },
        {
            id = "IRONMAN",
            enabled = true,
            title = "Ironman",
            badge = "Autosuficiencia",
            badgeColor = {0.3, 0.6, 1.0}, -- Azul Acero
            accentColor = {0.4, 0.7, 1.0},
            icon = "Interface\\Icons\\Trade_BlackSmithing",
            tagline = "Una vida, sin comercio ni ayuda externa",
            description = "La prueba máxima de autosuficiencia individual: una sola vida combinada con la prohibición absoluta de usar la casa de subastas, comerciar o recibir correo.",
            perks = {
                "Muerte permanente activada",
                "Sin comercio ni Casa de Subastas",
                "Solo puedes equipar lo que tú mismo consigas",
                "Logro y título de 'El Solitario' al nivel 80",
            },
            command = ".desafio ironman",
            addonPayload = "SET_MODE:IRONMAN",
            requireConfirmation = true,
            confirmTitle = "CONFIRMAR MODO IRONMAN",
            confirmWarning = "El Modo Ironman prohíbe todo comercio, correo y subastas, además de aplicar muerte permanente.\n\n¿Deseas sellar este pacto solitario?",
        },
        {
            id = "SLOW_X1",
            enabled = true,
            title = "Reto Andino x1",
            badge = "Progresión Pura",
            badgeColor = {0.9, 0.6, 0.1}, -- Naranja
            accentColor = {0.95, 0.65, 0.15},
            icon = "Interface\\Icons\\INV_Misc_Map02",
            tagline = "Ratio de experiencia Blizzlike x1",
            description = "Para los amantes del lore y la exploración clásica. La experiencia se fija a x1 en todas las fuentes (misiones, monstruos y mazmorras).",
            perks = {
                "Ratio estricto de experiencia x1",
                "Comercio y resurrección normales",
                "Emblemas y recompensas adicionales al nivel 80",
                "Ideal para disfrutar de cada zona de Azeroth",
            },
            command = ".desafio x1",
            addonPayload = "SET_MODE:X1",
            requireConfirmation = false,
        },
    },
}
