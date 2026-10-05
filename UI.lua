--[[
    WoW Perú - Selector de Modos de Juego (UI.lua)
    Interfaz de usuario cinematográfica, tarjetas interactivas y modal de confirmación.
]]

WoWPeru_GameModes = WoWPeru_GameModes or {}
local M = WoWPeru_GameModes

local mainFrame = nil
local confirmDialog = nil
local pendingMode = nil

-- Utilidad: Crear bordes y fondos estilizados
local function ApplyCardBackdrop(frame, borderColor, bgColor)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    local bg = bgColor or {0.05, 0.05, 0.07, 0.94}
    local border = borderColor or {0.35, 0.35, 0.40, 0.8}
    frame:SetBackdropColor(bg[1], bg[2], bg[3], bg[4])
    frame:SetBackdropBorderColor(border[1], border[2], border[3], border[4])
end

-- Utilidad: Registro seguro e idempotente en UISpecialFrames respetando prioridad LIFO
local function RegisterSpecialFrame(frameName, atFront)
    if not frameName then return end
    for i = #UISpecialFrames, 1, -1 do
        if UISpecialFrames[i] == frameName then
            table.remove(UISpecialFrames, i)
        end
    end
    if atFront then
        table.insert(UISpecialFrames, 1, frameName)
    else
        table.insert(UISpecialFrames, frameName)
    end
end

-- Diálogo de confirmación con bloqueo modal total (cero click-through)
local function CreateConfirmDialog()
    if confirmDialog then return confirmDialog end

    -- Frame raíz modal a pantalla completa (bloquea clics en las tarjetas traseras)
    local blocker = CreateFrame("Frame", "WoWPeru_ConfirmBlocker", UIParent)
    blocker:SetAllPoints(UIParent)
    blocker:SetFrameStrata("FULLSCREEN_DIALOG")
    blocker:SetFrameLevel(110)
    blocker:EnableMouse(true)
    blocker:Hide()

    -- Fondo semitransparente atenuador sobre las tarjetas
    local blockerScrim = blocker:CreateTexture(nil, "BACKGROUND")
    blockerScrim:SetAllPoints(blocker)
    blockerScrim:SetTexture("Interface\\Buttons\\WHITE8X8")
    blockerScrim:SetVertexColor(0, 0, 0, 0.65)

    -- Cuadro centrado de advertencia
    local dlg = CreateFrame("Frame", "WoWPeru_ConfirmDialog", blocker)
    dlg:SetSize(480, 290)
    dlg:SetPoint("CENTER", blocker, "CENTER", 0, 0)
    dlg:EnableMouse(true)

    dlg:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Destruction-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 11, top = 12, bottom = 11 }
    })

    -- Logo Oficial de WoW Perú
    local dlgLogo = dlg:CreateTexture(nil, "ARTWORK")
    dlgLogo:SetSize(60, 30)
    dlgLogo:SetPoint("TOP", dlg, "TOP", 0, -8)
    dlgLogo:SetTexture("Interface\\AddOns\\WoWPeru_GameModes\\Textures\\wowperu_logo.tga")
    dlg.logo = dlgLogo

    -- Título de Advertencia
    local title = dlg:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", dlg, "TOP", 0, -40)
    title:SetTextColor(1.0, 0.2, 0.2)
    dlg.title = title

    -- Calavera / Icono de peligro
    local skull = dlg:CreateTexture(nil, "ARTWORK")
    skull:SetSize(40, 40)
    skull:SetPoint("TOP", title, "BOTTOM", 0, -8)
    skull:SetTexture("Interface\\Icons\\Spell_Shadow_DeathScream")
    dlg.skull = skull

    -- Texto explicativo
    local text = dlg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("TOP", skull, "BOTTOM", 0, -12)
    text:SetPoint("LEFT", dlg, "LEFT", 28, 0)
    text:SetPoint("RIGHT", dlg, "RIGHT", -28, 0)
    text:SetJustifyH("CENTER")
    text:SetSpacing(3)
    dlg.text = text

    -- Botón de Confirmación Definitiva (con captura atómica previa a Hide)
    local btnAccept = CreateFrame("Button", "WoWPeru_ConfirmAcceptBtn", dlg, "UIPanelButtonTemplate")
    btnAccept:SetSize(190, 32)
    btnAccept:SetPoint("BOTTOMLEFT", dlg, "BOTTOMLEFT", 35, 24)
    btnAccept:SetText(M.L["CONFIRM_BUTTON"] or "¡Acepto el Desafío!")
    btnAccept:SetScript("OnClick", function()
        local modeToApply = pendingMode
        blocker:Hide()
        if modeToApply then
            M:ApplyMode(modeToApply.id)
        end
    end)
    dlg.btnAccept = btnAccept

    -- Botón de Cancelar / Volver
    local btnCancel = CreateFrame("Button", "WoWPeru_ConfirmCancelBtn", dlg, "UIPanelButtonTemplate")
    btnCancel:SetSize(150, 32)
    btnCancel:SetPoint("BOTTOMRIGHT", dlg, "BOTTOMRIGHT", -35, 24)
    btnCancel:SetText(M.L["CANCEL_BUTTON"] or "Volver Atrás")
    btnCancel:SetScript("OnClick", function()
        blocker:Hide()
    end)
    dlg.btnCancel = btnCancel

    -- Limpieza garantizada del estado al ocultarse (sea por ESC, cancelar o aceptar)
    blocker:SetScript("OnHide", function()
        pendingMode = nil
    end)

    -- Registro prioritario en la posición 1 de UISpecialFrames:
    -- Garantiza que CloseWindows() cierre el diálogo de confirmación ANTES que la ventana base
    RegisterSpecialFrame("WoWPeru_ConfirmBlocker", true)

    confirmDialog = blocker
    confirmDialog.dlg = dlg
    return confirmDialog
end

local function PromptConfirmation(mode)
    local blocker = CreateConfirmDialog()
    pendingMode = mode
    blocker.dlg.title:SetText(mode.confirmTitle or "ADVERTENCIA DE SEGURIDAD")
    blocker.dlg.text:SetText(mode.confirmWarning or "¿Estás seguro de elegir este modo?")
    blocker.dlg.skull:SetTexture(mode.icon or "Interface\\Icons\\Spell_Shadow_DeathScream")
    blocker:Show()
end

-- Constructor de cada tarjeta de modo
local function CreateModeCard(parent, mode, index, totalModes)
    local cardWidth = 220
    local cardHeight = 400
    local spacing = 16
    local totalWidth = (totalModes * cardWidth) + ((totalModes - 1) * spacing)
    local startX = -(totalWidth / 2) + (cardWidth / 2)
    local posX = startX + ((index - 1) * (cardWidth + spacing))

    local card = CreateFrame("Button", "WoWPeru_Card_" .. mode.id, parent)
    card:SetSize(cardWidth, cardHeight)
    card:SetPoint("CENTER", parent, "CENTER", posX, -25)
    card:EnableMouse(true)

    local accent = mode.accentColor or {0.85, 0.75, 0.35}
    ApplyCardBackdrop(card, {0.3, 0.3, 0.35, 0.7}, {0.06, 0.06, 0.08, 0.94})

    -- Efecto Hover Anti-Flicker y preservación de modo activo
    local function ApplyHoverState(isHovered)
        local isCurrent = (WoWPeru_GameModes_CharDB and WoWPeru_GameModes_CharDB.selectedMode == mode.id)
        if isHovered or isCurrent then
            card:SetBackdropBorderColor(accent[1], accent[2], accent[3], 1.0)
            card:SetBackdropColor(0.10, 0.10, 0.13, 0.98)
        else
            card:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.7)
            card:SetBackdropColor(0.06, 0.06, 0.08, 0.94)
        end
    end
    card.ApplyHoverState = ApplyHoverState

    card:SetScript("OnEnter", function() ApplyHoverState(true) end)
    card:SetScript("OnLeave", function()
        if not MouseIsOver(card) then
            ApplyHoverState(false)
        end
    end)

    -- Contenedor del Icono
    local iconFrame = CreateFrame("Frame", nil, card)
    iconFrame:SetSize(54, 54)
    iconFrame:SetPoint("TOP", card, "TOP", 0, -20)
    iconFrame:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    iconFrame:SetBackdropBorderColor(accent[1], accent[2], accent[3], 0.9)

    local icon = iconFrame:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints(iconFrame)
    icon:SetTexture(mode.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    -- Badge / Distintivo (Ej. "1 Sola Vida", "Estándar")
    local badgeBg = card:CreateTexture(nil, "BACKGROUND")
    badgeBg:SetSize(120, 18)
    badgeBg:SetPoint("TOP", iconFrame, "BOTTOM", 0, -8)
    badgeBg:SetTexture("Interface\\Buttons\\WHITE8X8")
    local bColor = mode.badgeColor or {0.4, 0.4, 0.4}
    badgeBg:SetVertexColor(bColor[1] * 0.3, bColor[2] * 0.3, bColor[3] * 0.3, 0.8)

    local badgeText = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    badgeText:SetPoint("CENTER", badgeBg, "CENTER", 0, 0)
    badgeText:SetText(mode.badge or "")
    badgeText:SetTextColor(bColor[1], bColor[2], bColor[3])

    -- Título del Modo
    local title = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", badgeBg, "BOTTOM", 0, -8)
    title:SetText(mode.title or "Modo")
    title:SetTextColor(accent[1], accent[2], accent[3])

    -- Subtítulo / Tagline
    local tagline = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    tagline:SetPoint("TOP", title, "BOTTOM", 0, -4)
    tagline:SetPoint("LEFT", card, "LEFT", 12, 0)
    tagline:SetPoint("RIGHT", card, "RIGHT", -12, 0)
    tagline:SetText(mode.tagline or "")
    tagline:SetTextColor(0.75, 0.75, 0.75)
    tagline:SetJustifyH("CENTER")

    -- Línea divisoria
    local div = card:CreateTexture(nil, "ARTWORK")
    div:SetSize(cardWidth - 30, 1)
    div:SetPoint("TOP", tagline, "BOTTOM", 0, -8)
    div:SetTexture("Interface\\Buttons\\WHITE8X8")
    div:SetVertexColor(accent[1], accent[2], accent[3], 0.3)

    -- Lista de Características (Perks)
    local lastAnchor = div
    if mode.perks and #mode.perks > 0 then
        for pIdx, perk in ipairs(mode.perks) do
            local bullet = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            bullet:SetPoint("TOPLEFT", lastAnchor, "BOTTOMLEFT", 8, -6)
            bullet:SetPoint("RIGHT", card, "RIGHT", -10, 0)
            bullet:SetText("|cFFFFD100•|r " .. perk)
            bullet:SetJustifyH("LEFT")
            bullet:SetSpacing(1)
            lastAnchor = bullet
        end
    end

    -- Botón de Acción con validación de estado
    local btn = CreateFrame("Button", nil, card, "UIPanelButtonTemplate")
    btn:SetSize(160, 30)
    btn:SetPoint("BOTTOM", card, "BOTTOM", 0, 18)

    local isCurrentMode = (WoWPeru_GameModes_CharDB and WoWPeru_GameModes_CharDB.selectedMode == mode.id)
    local hasAlreadyLocked = (WoWPeru_GameModes_CharDB and WoWPeru_GameModes_CharDB.hasSelectedMode)

    if isCurrentMode then
        btn:SetText(M.L["SELECTED_BADGE"] or "SELECCIONADO")
        btn:Disable()
    elseif hasAlreadyLocked then
        btn:SetText(M.L["SELECT_BUTTON"] or "Elegir Modo")
        btn:Disable()
    else
        btn:SetText(M.L["SELECT_BUTTON"] or "Elegir Modo")
        btn:Enable()
    end
    
    local function HandleSelect()
        if WoWPeru_GameModes_CharDB and WoWPeru_GameModes_CharDB.hasSelectedMode then
            return
        end
        if mode.requireConfirmation then
            PromptConfirmation(mode)
        else
            M:ApplyMode(mode.id)
        end
    end

    btn:SetScript("OnClick", HandleSelect)
    btn:SetScript("OnEnter", function() ApplyHoverState(true) end)
    btn:SetScript("OnLeave", function()
        if not MouseIsOver(card) then
            ApplyHoverState(false)
        end
    end)

    card:SetScript("OnClick", function()
        if not isCurrentMode and not hasAlreadyLocked then
            HandleSelect()
        end
    end)

    card.modeData = mode
    card.actionBtn = btn

    return card
end

-- Función para calcular auto-escalado según la resolución de pantalla
local function UpdateContainerScale(container)
    if not container then return end
    local screenW = UIParent:GetWidth() or 1024
    local screenH = UIParent:GetHeight() or 768
    local baseW = 1040
    local baseH = 580

    -- Factor de escala para que no supere el 92% de ancho ni el 90% de alto
    local scaleW = (screenW * 0.92) / baseW
    local scaleH = (screenH * 0.90) / baseH
    local finalScale = math.min(1.0, scaleW, scaleH)

    -- Mínimo de 0.60 para pantallas muy reducidas (800x600)
    container:SetScale(math.max(0.60, finalScale))
end

-- Constructor de la ventana principal
local function CreateMainUI()
    if mainFrame then
        UpdateContainerScale(mainFrame.container)
        return mainFrame
    end

    -- Frame raíz modal a pantalla completa
    local root = CreateFrame("Frame", "WoWPeru_GameModes_MainFrame", UIParent)
    root:SetAllPoints(UIParent)
    root:SetFrameStrata("FULLSCREEN_DIALOG")
    root:EnableMouse(true)
    root:Hide()

    -- Registro seguro del marco base en UISpecialFrames
    RegisterSpecialFrame("WoWPeru_GameModes_MainFrame", false)

    -- Capa de viñeta / Fondo oscuro que oscurece el mundo 3D
    local scrim = root:CreateTexture(nil, "BACKGROUND")
    scrim:SetAllPoints(root)
    scrim:SetTexture("Interface\\Buttons\\WHITE8X8")
    scrim:SetVertexColor(0.02, 0.02, 0.03, 0.88)

    -- Contenedor Central con marco dorado
    local container = CreateFrame("Frame", nil, root)
    container:SetSize(1020, 560)
    container:SetPoint("CENTER", root, "CENTER", 0, 0)
    container:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 9, right = 9, top = 9, bottom = 9 }
    })
    root.container = container
    UpdateContainerScale(container)

    -- Logo Oficial de WoW Perú
    local logo = container:CreateTexture(nil, "ARTWORK")
    logo:SetSize(110, 55)
    logo:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -12)
    logo:SetTexture("Interface\\AddOns\\WoWPeru_GameModes\\Textures\\wowperu_logo.tga")
    container.logo = logo

    -- Encabezado: Servidor y Reino
    local headerLogo = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    headerLogo:SetPoint("TOP", container, "TOP", 0, -20)
    headerLogo:SetText(string.format("|cFFD4AF37%s|r  —  |cFFFFFFFF%s|r", M.Config.ServerName or "WoW Perú", M.Config.RealmName or "Reino Andino"))

    -- Título Principal
    local headerTitle = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    headerTitle:SetPoint("TOP", headerLogo, "BOTTOM", 0, -6)
    headerTitle:SetText(M.Config.HeaderTitle or "ELIGE TU DESTINO")
    headerTitle:SetTextColor(1.0, 0.85, 0.2)

    -- Subtítulo explicativo
    local headerSubtitle = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    headerSubtitle:SetPoint("TOP", headerTitle, "BOTTOM", 0, -4)
    headerSubtitle:SetText(M.Config.HeaderSubtitle or "Selecciona el modo de juego para este personaje.")
    headerSubtitle:SetTextColor(0.8, 0.8, 0.8)

    -- Línea divisoria superior dorada
    local topDiv = container:CreateTexture(nil, "ARTWORK")
    topDiv:SetSize(900, 2)
    topDiv:SetPoint("TOP", headerSubtitle, "BOTTOM", 0, -12)
    topDiv:SetTexture("Interface\\Buttons\\WHITE8X8")
    topDiv:SetVertexColor(0.83, 0.69, 0.22, 0.4)

    -- Contar modos habilitados
    local enabledModes = {}
    for _, mode in ipairs(M.Config.Modes) do
        if mode.enabled then
            table.insert(enabledModes, mode)
        end
    end

    -- Generar las tarjetas
    container.cards = {}
    for idx, mode in ipairs(enabledModes) do
        local card = CreateModeCard(container, mode, idx, #enabledModes)
        table.insert(container.cards, card)
    end

    -- Botón discreto de cerrar (solo disponible si no es decisión obligatoria o para testing)
    local closeBtn = CreateFrame("Button", nil, container, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", container, "TOPRIGHT", -8, -8)
    closeBtn:SetScript("OnClick", function()
        M:CloseSelectionUI()
    end)
    container.closeBtn = closeBtn

    -- Cierre en cascada: ocultar confirmDialog si root se oculta
    root:SetScript("OnHide", function()
        if confirmDialog and confirmDialog:IsShown() then
            confirmDialog:Hide()
        end
        pendingMode = nil
    end)

    root:SetScript("OnSizeChanged", function()
        UpdateContainerScale(container)
    end)

    -- Pre-inicializar el diálogo modal para asegurar la jerarquía en UISpecialFrames
    CreateConfirmDialog()

    mainFrame = root
    return root
end

-- Actualizar estado visual de las tarjetas según DB del personaje
local function UpdateCardsState()
    if not mainFrame or not mainFrame.container or not mainFrame.container.cards then return end
    
    local isLocked = (WoWPeru_GameModes_CharDB and WoWPeru_GameModes_CharDB.hasSelectedMode)
    local currentMode = (WoWPeru_GameModes_CharDB and WoWPeru_GameModes_CharDB.selectedMode)

    for _, card in ipairs(mainFrame.container.cards) do
        if card.modeData and card.actionBtn then
            if currentMode and card.modeData.id == currentMode then
                card.actionBtn:SetText(M.L["SELECTED_BADGE"] or "SELECCIONADO")
                card.actionBtn:Disable()
            elseif isLocked then
                card.actionBtn:SetText(M.L["SELECT_BUTTON"] or "Elegir Modo")
                card.actionBtn:Disable()
            else
                card.actionBtn:SetText(M.L["SELECT_BUTTON"] or "Elegir Modo")
                card.actionBtn:Enable()
            end
            if card.ApplyHoverState then
                card.ApplyHoverState(false)
            end
        end
    end
end

-- Abrir la ventana
function M:OpenSelectionUI()
    local ui = CreateMainUI()
    if ui and ui.container then
        UpdateContainerScale(ui.container)
    end
    
    UpdateCardsState()
    
    -- Si ya seleccionó anteriormente, mostrar aviso informativo pero permitir ver las opciones
    if WoWPeru_GameModes_CharDB and WoWPeru_GameModes_CharDB.hasSelectedMode then
        DEFAULT_CHAT_FRAME:AddMessage(string.format(M.L["ALREADY_SELECTED"], WoWPeru_GameModes_CharDB.selectedMode or "Desconocido"))
    end

    if M.Config.SoundOnOpen then
        PlaySoundFile(M.Config.SoundOnOpen)
    end

    ui:Show()
end

-- Cerrar la ventana
function M:CloseSelectionUI()
    if mainFrame then
        mainFrame:Hide()
    end
    if confirmDialog then
        confirmDialog:Hide()
    end
    pendingMode = nil
end
