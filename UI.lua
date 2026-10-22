--[[
    ========================================================================
    Project Jaina - Selector de Modos de Juego (UI.lua)
    Reino: Project Jaina | Motor: JainaCore WotLK 3.3.5a (Build 12340)
    ========================================================================
    Interfaz Cinematográfica AAA: Tarjetas de pergamino ilustradas (512x1024),
    badges luminosos, efectos hover dinámicos, auto-escalado responsive
    y modal de seguridad para modos con muerte permanente.
]]

ProjectJaina_GameModes = ProjectJaina_GameModes or {}
local M = ProjectJaina_GameModes

local TEXTURE_PATH = "Interface\\AddOns\\ProjectJaina_GameModes\\Textures\\"
local BASE_WIDTH, BASE_HEIGHT = 1120, 650
local CARD_W, CARD_H, CARD_GAP = 252, 504, 18

local mainFrame = nil
local confirmDialog = nil
local pendingMode = nil

-- Utilidad: Helper tipográfico de alta fidelidad
local function CreateStyledLabel(parent, fontObject, size, color, justifyH)
    local s = parent:CreateFontString(nil, "OVERLAY", fontObject or "GameFontNormal")
    if size then
        local fontPath = GameFontNormal:GetFont() or "Fonts\\FRIZQT__.TTF"
        s:SetFont(fontPath, size, "")
    end
    if color then
        s:SetTextColor(color[1], color[2], color[3], color[4] or 1.0)
    end
    s:SetJustifyH(justifyH or "CENTER")
    s:SetJustifyV("TOP")
    s:SetSpacing(2)
    return s
end

-- Utilidad: Registro seguro en UISpecialFrames respetando prioridad LIFO
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

-- Utilidad: Botón estilizado rojo / dorado tipo Dragonflight
local function CreateEpicButton(parent, name, text, width, height, isDanger)
    local btn = CreateFrame("Button", name, parent)
    btn:SetSize(width, height)
    btn:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
    btn:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
    btn:SetDisabledTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
    btn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight", "ADD")
    
    for _, tex in ipairs({btn:GetNormalTexture(), btn:GetPushedTexture(), btn:GetDisabledTexture(), btn:GetHighlightTexture()}) do
        if tex then
            tex:SetTexCoord(0, 0.625, 0, 0.6875)
        end
    end

    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("CENTER", btn, "CENTER", 0, 1)
    label:SetShadowColor(0, 0, 0, 1)
    label:SetShadowOffset(1, -1)
    btn:SetFontString(label)
    btn:SetText(text)

    btn:SetScript("OnMouseDown", function()
        label:SetPoint("CENTER", btn, "CENTER", 1, -1)
    end)
    btn:SetScript("OnMouseUp", function()
        label:SetPoint("CENTER", btn, "CENTER", 0, 1)
    end)

    return btn
end

-- Función de Auto-escalado responsive según la resolución de la pantalla
local function ScaleContainerToScreen(container)
    if not container then return end
    local screenW = UIParent:GetWidth() or 1024
    local screenH = UIParent:GetHeight() or 768
    if screenW <= 0 or screenH <= 0 then return end

    -- Factor de escala: máximo 96% de ancho y 92% de alto
    local scaleW = (screenW * 0.96) / BASE_WIDTH
    local scaleH = (screenH * 0.92) / BASE_HEIGHT
    local finalScale = math.min(1.0, scaleW, scaleH)

    -- Mínimo de 0.58 para pantallas ultra compactas (800x600)
    container:SetScale(math.max(0.58, finalScale))
end

-- Diálogo de confirmación modal para modos Hardcore / Ironman
local function CreateConfirmDialog()
    if confirmDialog then return confirmDialog end

    local blocker = CreateFrame("Frame", "ProjectJaina_ConfirmBlocker", UIParent)
    blocker:SetAllPoints(UIParent)
    blocker:SetFrameStrata("FULLSCREEN_DIALOG")
    blocker:SetFrameLevel(130)
    blocker:EnableMouse(true)
    blocker:Hide()

    -- Atenuador de fondo negro semitransparente
    local scrim = blocker:CreateTexture(nil, "BACKGROUND")
    scrim:SetAllPoints(blocker)
    scrim:SetTexture("Interface\\Buttons\\WHITE8X8")
    scrim:SetVertexColor(0, 0, 0, 0.82)

    -- Cuadro modal centrado
    local dlg = CreateFrame("Frame", "ProjectJaina_ConfirmDialog", blocker)
    dlg:SetSize(520, 320)
    dlg:SetPoint("CENTER", blocker, "CENTER", 0, 0)
    dlg:EnableMouse(true)
    dlg:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    dlg:SetBackdropColor(0.06, 0.05, 0.04, 0.98)
    dlg:SetBackdropBorderColor(1.0, 0.25, 0.25, 1.0)

    -- Resplandor superior
    local glow = dlg:CreateTexture(nil, "BACKGROUND")
    glow:SetSize(480, 70)
    glow:SetPoint("TOP", dlg, "TOP", 0, -8)
    glow:SetTexture("Interface\\Buttons\\WHITE8X8")
    glow:SetVertexColor(0.5, 0.05, 0.05, 0.25)

    -- Logo oficial Jaina
    local logo = dlg:CreateTexture(nil, "ARTWORK")
    local logoW, logoH = 40, 40
    logo:SetSize(logoW, logoH)
    logo:SetPoint("TOP", dlg, "TOP", 0, -10)
    logo:SetTexture(TEXTURE_PATH .. "jaina_logo.tga")
    logo:SetBlendMode("BLEND")

    -- Título de Advertencia
    local title = CreateStyledLabel(dlg, "GameFontHighlightLarge", 18, {1.0, 0.25, 0.25})
    title:SetPoint("TOP", dlg, "TOP", 0, -48)
    title:SetWidth(460)
    dlg.title = title

    -- Calavera / Icono de Peligro
    local skull = dlg:CreateTexture(nil, "ARTWORK")
    skull:SetSize(46, 46)
    skull:SetPoint("TOP", title, "BOTTOM", 0, -6)
    skull:SetTexture("Interface\\Icons\\Spell_Shadow_DeathScream")
    dlg.skull = skull

    -- Texto Explicativo
    local text = CreateStyledLabel(dlg, "GameFontNormal", 13, {0.92, 0.88, 0.78})
    text:SetPoint("TOP", skull, "BOTTOM", 0, -10)
    text:SetPoint("LEFT", dlg, "LEFT", 30, 0)
    text:SetPoint("RIGHT", dlg, "RIGHT", -30, 0)
    text:SetSpacing(3)
    dlg.text = text

    -- Botón Aceptar Desafío
    local btnAccept = CreateEpicButton(dlg, "ProjectJaina_ConfirmAcceptBtn", "¡Acepto el Desafío!", 200, 34, true)
    btnAccept:SetPoint("BOTTOMLEFT", dlg, "BOTTOMLEFT", 38, 22)
    btnAccept:SetScript("OnClick", function()
        local modeToApply = pendingMode
        pendingMode = nil
        blocker:Hide()
        if modeToApply then
            M:ApplyMode(modeToApply.id)
        end
    end)
    dlg.btnAccept = btnAccept

    -- Botón Cancelar
    local btnCancel = CreateEpicButton(dlg, "ProjectJaina_ConfirmCancelBtn", "Volver Atrás", 160, 34, false)
    btnCancel:SetPoint("BOTTOMRIGHT", dlg, "BOTTOMRIGHT", -38, 22)
    btnCancel:SetScript("OnClick", function()
        pendingMode = nil
        blocker:Hide()
    end)
    dlg.btnCancel = btnCancel

    blocker:SetScript("OnHide", function()
        pendingMode = nil
    end)

    RegisterSpecialFrame("ProjectJaina_ConfirmBlocker", true)

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

-- Constructor de Tarjeta de Modo AAA
local function CreateModeCard(parent, mode, index, totalModes)
    local totalWidth = (totalModes * CARD_W) + ((totalModes - 1) * CARD_GAP)
    local startX = (BASE_WIDTH - totalWidth) / 2
    local posX = startX + ((index - 1) * (CARD_W + CARD_GAP))

    local card = CreateFrame("Button", "ProjectJaina_Card_" .. mode.id, parent)
    card:SetSize(CARD_W, CARD_H)
    card:SetPoint("TOPLEFT", parent, "TOPLEFT", posX, -112)
    card:EnableMouse(true)

    -- Fondo de Arte de Alta Fidelidad (512x1024 RGBA)
    local artTex = card:CreateTexture(nil, "BACKGROUND")
    artTex:SetAllPoints(card)
    local texFile = mode.artTexture and (TEXTURE_PATH .. mode.artTexture) or "Interface\\DialogFrame\\UI-DialogBox-Background-Dark"
    artTex:SetTexture(texFile)
    artTex:SetVertexColor(0.92, 0.92, 0.92, 1.0)
    card.artTex = artTex

    -- Marco exterior de resplandor / Hover glow
    local glowBorder = card:CreateTexture(nil, "BORDER")
    glowBorder:SetPoint("TOPLEFT", card, "TOPLEFT", -4, 4)
    glowBorder:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", 4, -4)
    glowBorder:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
    glowBorder:SetBlendMode("ADD")
    local accent = mode.accentColor or {0.85, 0.75, 0.35}
    glowBorder:SetVertexColor(accent[1], accent[2], accent[3], 0.0)
    card.glowBorder = glowBorder

    -- Badge Superior Flotante
    local badgeBg = card:CreateTexture(nil, "ARTWORK")
    badgeBg:SetSize(140, 22)
    badgeBg:SetPoint("TOP", card, "TOP", 0, -100)
    badgeBg:SetTexture("Interface\\Buttons\\WHITE8X8")
    local bColor = mode.badgeColor or {0.2, 0.7, 0.2}
    badgeBg:SetVertexColor(0.05, 0.05, 0.06, 0.88)

    local badgeBorder = card:CreateTexture(nil, "OVERLAY")
    badgeBorder:SetPoint("TOPLEFT", badgeBg, "TOPLEFT", -1, 1)
    badgeBorder:SetPoint("BOTTOMRIGHT", badgeBg, "BOTTOMRIGHT", 1, -1)
    badgeBorder:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
    badgeBorder:SetVertexColor(bColor[1], bColor[2], bColor[3], 0.9)

    local badgeLabel = CreateStyledLabel(card, "GameFontHighlightSmall", 11, bColor)
    badgeLabel:SetPoint("CENTER", badgeBg, "CENTER", 0, 0)
    badgeLabel:SetText(mode.badge or "")

    -- Título del Modo
    local title = CreateStyledLabel(card, "GameFontHighlightLarge", 23, mode.titleColor or {0.3, 0.2, 0.1})
    title:SetPoint("TOP", card, "TOP", 0, -128)
    title:SetWidth(216)
    title:SetText(mode.title or "Modo")
    title:SetShadowColor(0, 0, 0, 0.35)
    title:SetShadowOffset(1, -1)

    -- Tagline
    local tagline = CreateStyledLabel(card, "GameFontNormalSmall", 11, {0.18, 0.12, 0.06})
    tagline:SetPoint("TOP", title, "BOTTOM", 0, -4)
    tagline:SetWidth(218)
    tagline:SetHeight(28)
    tagline:SetText(mode.tagline or "")

    -- Separador ornamental
    local div = card:CreateTexture(nil, "ARTWORK")
    div:SetSize(190, 1)
    div:SetPoint("TOP", tagline, "BOTTOM", 0, -4)
    div:SetTexture("Interface\\Buttons\\WHITE8X8")
    div:SetVertexColor(0.45, 0.35, 0.20, 0.35)

    -- Lista de Perks / Reglas
    local perksAnchor = div
    if mode.perks and #mode.perks > 0 then
        for pIdx, perk in ipairs(mode.perks) do
            local bullet = card:CreateTexture(nil, "ARTWORK")
            bullet:SetSize(9, 9)
            bullet:SetPoint("TOPLEFT", perksAnchor, "BOTTOMLEFT", 4, -5)
            bullet:SetTexture("Interface\\COMMON\\Indicator-Yellow")
            bullet:SetVertexColor(math.min(1, accent[1] * 1.5), math.min(1, accent[2] * 1.5), math.min(1, accent[3] * 1.5), 0.9)

            local perkText = CreateStyledLabel(card, "GameFontNormalSmall", 11, {0.14, 0.09, 0.04}, "LEFT")
            perkText:SetPoint("TOPLEFT", bullet, "TOPRIGHT", 6, 1)
            perkText:SetPoint("RIGHT", card, "RIGHT", -18, 0)
            perkText:SetText(perk)
            perkText:SetSpacing(1)

            perksAnchor = perkText
        end
    end

    -- Botón de Acción
    local btn = CreateEpicButton(card, "ProjectJaina_Btn_" .. mode.id, "Elegir Modo", 184, 32, false)
    btn:SetPoint("BOTTOM", card, "BOTTOM", 0, 36)

    -- Gestión reactiva de estado Hover
    local function ApplyHoverState(isHovered)
        local isCurrent = (ProjectJaina_GameModes_CharDB and ProjectJaina_GameModes_CharDB.selectedMode == mode.id)
        if isHovered or isCurrent then
            artTex:SetVertexColor(1.0, 1.0, 1.0, 1.0)
            glowBorder:SetVertexColor(accent[1], accent[2], accent[3], 0.95)
            btn:GetFontString():SetTextColor(1.0, 0.95, 0.70)
        else
            artTex:SetVertexColor(0.92, 0.92, 0.92, 1.0)
            glowBorder:SetVertexColor(accent[1], accent[2], accent[3], 0.0)
            btn:GetFontString():SetTextColor(1.0, 0.82, 0.45)
        end
    end
    card.ApplyHoverState = ApplyHoverState

    card:SetScript("OnEnter", function()
        ApplyHoverState(true)
    end)
    card:SetScript("OnLeave", function()
        if not MouseIsOver(card) then
            ApplyHoverState(false)
        end
    end)
    btn:SetScript("OnEnter", function()
        ApplyHoverState(true)
    end)
    btn:SetScript("OnLeave", function()
        if not MouseIsOver(card) then
            ApplyHoverState(false)
        end
    end)

    local function HandleSelect()
        if ProjectJaina_GameModes_CharDB and ProjectJaina_GameModes_CharDB.hasSelectedMode then
            return
        end
        if mode.requireConfirmation then
            PromptConfirmation(mode)
        else
            M:ApplyMode(mode.id)
        end
    end

    btn:SetScript("OnClick", HandleSelect)
    card:SetScript("OnClick", HandleSelect)

    card.modeData = mode
    card.actionBtn = btn

    return card
end

-- Constructor de la Ventana Principal
local function CreateMainUI()
    if mainFrame then
        ScaleContainerToScreen(mainFrame.container)
        return mainFrame
    end

    local root = CreateFrame("Frame", "ProjectJaina_GameModes_MainFrame", UIParent)
    root:SetAllPoints(UIParent)
    root:SetFrameStrata("FULLSCREEN_DIALOG")
    root:SetFrameLevel(90)
    root:EnableMouse(true)
    root:Hide()

    RegisterSpecialFrame("ProjectJaina_GameModes_MainFrame", false)

    -- Viñeta cinemática / Oscurecimiento radial del mundo 3D
    local scrim = root:CreateTexture(nil, "BACKGROUND")
    scrim:SetAllPoints(root)
    scrim:SetTexture("Interface\\Buttons\\WHITE8X8")
    scrim:SetVertexColor(0.02, 0.02, 0.03, 0.85)

    -- Contenedor Central con marco dorado ornamental
    local container = CreateFrame("Frame", nil, root)
    container:SetSize(BASE_WIDTH, BASE_HEIGHT)
    container:SetPoint("CENTER", root, "CENTER", 0, 0)
    container:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 9, right = 9, top = 9, bottom = 9 }
    })
    container:SetBackdropColor(0.04, 0.04, 0.05, 0.97)
    container:SetBackdropBorderColor(0.85, 0.70, 0.25, 0.95)
    root.container = container

    ScaleContainerToScreen(container)

    -- Logo oficial de Project Jaina
    local logo = container:CreateTexture(nil, "ARTWORK")
    logo:SetSize(62, 62)
    logo:SetPoint("TOPLEFT", container, "TOPLEFT", 24, -14)
    logo:SetTexture(TEXTURE_PATH .. "jaina_logo.tga")
    logo:SetBlendMode("BLEND")
    container.logo = logo

    -- Encabezado: Marca y Reino
    local headerLogo = CreateStyledLabel(container, "GameFontNormal", 13, {0.85, 0.75, 0.45})
    headerLogo:SetPoint("TOP", container, "TOP", 0, -18)
    headerLogo:SetText(string.format("|cFFD4AF37%s|r  —  |cFFFFFFFF%s|r", M.Config.ServerName or "Project Jaina", M.Config.RealmName or "Project Jaina"))

    -- Título Principal Épico
    local headerTitle = CreateStyledLabel(container, "GameFontHighlightLarge", 30, {1.0, 0.85, 0.25})
    headerTitle:SetPoint("TOP", headerLogo, "BOTTOM", 0, -4)
    headerTitle:SetText(M.Config.HeaderTitle or "ELIGE TU DESTINO")
    headerTitle:SetShadowColor(0, 0, 0, 1)
    headerTitle:SetShadowOffset(1, -2)

    -- Subtítulo Inmersivo
    local headerSubtitle = CreateStyledLabel(container, "GameFontNormalSmall", 12, {0.82, 0.80, 0.72})
    headerSubtitle:SetPoint("TOP", headerTitle, "BOTTOM", 0, -4)
    headerSubtitle:SetWidth(980)
    headerSubtitle:SetText(M.Config.HeaderSubtitle or "Selecciona el modo de juego para este personaje. Tu camino forjará tu leyenda.")

    -- Línea divisoria superior dorada
    local topDiv = container:CreateTexture(nil, "ARTWORK")
    local topDivW, topDivH = 1040, 2
    topDiv:SetSize(topDivW, topDivH)
    topDiv:SetPoint("TOP", headerSubtitle, "BOTTOM", 0, -10)
    topDiv:SetTexture("Interface\\Buttons\\WHITE8X8")
    topDiv:SetVertexColor(0.83, 0.69, 0.22, 0.45)

    -- Generar Tarjetas
    local enabledModes = {}
    for _, mode in ipairs(M.Config.Modes) do
        if mode.enabled then
            table.insert(enabledModes, mode)
        end
    end

    container.cards = {}
    for idx, mode in ipairs(enabledModes) do
        local card = CreateModeCard(container, mode, idx, #enabledModes)
        table.insert(container.cards, card)
    end

    -- Botón de Cierre (solo disponible para inspección o si no es forzado)
    local closeBtn = CreateFrame("Button", nil, container, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", container, "TOPRIGHT", -8, -8)
    closeBtn:SetScript("OnClick", function()
        M:CloseSelectionUI()
    end)
    container.closeBtn = closeBtn

    -- Cierre en cascada
    root:SetScript("OnHide", function()
        if confirmDialog and confirmDialog:IsShown() then
            confirmDialog:Hide()
        end
        pendingMode = nil
    end)

    root:SetScript("OnSizeChanged", function()
        ScaleContainerToScreen(container)
    end)

    CreateConfirmDialog()

    mainFrame = root
    return root
end

-- Actualización reactiva de estado de las tarjetas
local function UpdateCardsState()
    if not mainFrame or not mainFrame.container or not mainFrame.container.cards then return end

    local isLocked = (ProjectJaina_GameModes_CharDB and ProjectJaina_GameModes_CharDB.hasSelectedMode)
    local currentMode = (ProjectJaina_GameModes_CharDB and ProjectJaina_GameModes_CharDB.selectedMode)

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

-- API Pública de Apertura
function M:OpenSelectionUI()
    local ui = CreateMainUI()
    if ui and ui.container then
        ScaleContainerToScreen(ui.container)
    end

    UpdateCardsState()

    if ProjectJaina_GameModes_CharDB and ProjectJaina_GameModes_CharDB.hasSelectedMode then
        DEFAULT_CHAT_FRAME:AddMessage(string.format(M.L["ALREADY_SELECTED"], ProjectJaina_GameModes_CharDB.selectedMode or "Desconocido"))
    end

    if M.Config.SoundOnOpen then
        PlaySoundFile(M.Config.SoundOnOpen)
    end

    ui:Show()
end

-- API Pública de Cierre
function M:CloseSelectionUI()
    if mainFrame then
        mainFrame:Hide()
    end
    if confirmDialog then
        confirmDialog:Hide()
    end
    pendingMode = nil
end
