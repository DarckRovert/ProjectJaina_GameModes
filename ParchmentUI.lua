-- Inti parchment selector. Native WoW 3.3.5 frames, text and buttons.
-- Generated artwork is decorative; realm/preview guards remain in Core.lua.
local M = ProjectJaina_GameModes
local ART = "Interface\\AddOns\\Jaina_GameModes\\Textures\\"
local FONT = "Fonts\\FRIZQT__.TTF"
local WIDTH, HEIGHT = 1120, 656
local CARD_W, CARD_H, GAP = 252, 504, 18
local mainFrame, confirmDialog, pendingMode

local function Label(parent, size, color, justify)
    local label = parent:CreateFontString(nil, "OVERLAY")
    label:SetFont(FONT, size, "")
    label:SetTextColor(unpack(color or {0.12, 0.085, 0.04}))
    label:SetJustifyH(justify or "CENTER")
    label:SetJustifyV("TOP")
    label:SetSpacing(2)
    return label
end

local function DarkBackdrop(frame, border)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 32, edgeSize = 12,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
    frame:SetBackdropColor(0.055, 0.045, 0.04, 0.97)
    frame:SetBackdropBorderColor(unpack(border or {0.43, 0.32, 0.15, 0.65}))
end

local function ScaleToScreen(frame, width, height)
    -- No minimum scale: even small client windows must keep all controls visible.
    local w, h = UIParent:GetWidth(), UIParent:GetHeight()
    if not w or not h or w <= 0 or h <= 0 then return end
    frame:SetScale(math.min(1, w * 0.96 / width, h * 0.92 / height))
end

local function RedButton(parent, name, text, width, height)
    local button = CreateFrame("Button", name, parent)
    button:SetSize(width, height)
    button:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
    button:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
    button:SetDisabledTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
    button:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight", "ADD")
    for _, texture in ipairs({button:GetNormalTexture(), button:GetPushedTexture(), button:GetDisabledTexture(), button:GetHighlightTexture()}) do
        texture:SetTexCoord(0, 0.625, 0, 0.6875)
    end
    local label = Label(button, 13, {1, 0.87, 0.56})
    label:SetPoint("CENTER", button, "CENTER", 0, 1)
    label:SetShadowColor(0, 0, 0, 1)
    label:SetShadowOffset(1, -1)
    button:SetFontString(label)
    button:SetText(text)
    button:SetScript("OnMouseDown", function() label:SetPoint("CENTER", button, "CENTER", 1, 0) end)
    button:SetScript("OnMouseUp", function() label:SetPoint("CENTER", button, "CENTER", 0, 1) end)
    return button
end

local function HasSelection()
    return not M.Config.PreviewOnly and ProjectJaina_GameModes_CharDB and ProjectJaina_GameModes_CharDB.hasSelectedMode
end

local function RefreshCards()
    if not mainFrame then return end
    local current = HasSelection() and ProjectJaina_GameModes_CharDB.selectedMode
    for _, card in ipairs(mainFrame.container.cards) do
        if current then
            card.actionBtn:SetText(card.modeData.id == current and "SELECCIONADO" or "Elegir modo")
            card.actionBtn:Disable()
        else
            card.actionBtn:SetText(M.Config.PreviewOnly and "Probar selección" or "Elegir modo")
            card.actionBtn:Enable()
        end
        card.ApplyHoverState(false)
    end
end

local function CreateConfirmDialog()
    if confirmDialog then return confirmDialog end
    local blocker = CreateFrame("Frame", "ProjectJaina_ConfirmBlocker", UIParent)
    blocker:SetAllPoints(UIParent)
    blocker:SetFrameStrata("FULLSCREEN_DIALOG")
    blocker:SetFrameLevel(120)
    blocker:EnableMouse(true)
    blocker:Hide()
    local scrim = blocker:CreateTexture(nil, "BACKGROUND")
    scrim:SetAllPoints(blocker)
    scrim:SetTexture("Interface\\Buttons\\WHITE8X8")
    scrim:SetVertexColor(0, 0, 0, 0.8)

    local dlg = CreateFrame("Frame", "ProjectJaina_ConfirmDialog", blocker)
    dlg:SetSize(530, 330)
    dlg:SetPoint("CENTER", blocker, "CENTER", 0, 0)
    dlg:EnableMouse(true)
    DarkBackdrop(dlg, {0.68, 0.47, 0.19, 1})
    local dlgLogo = dlg:CreateTexture(nil, "ARTWORK")
    dlgLogo:SetSize(70, 35)
    dlgLogo:SetPoint("TOP", dlg, "TOP", 0, -10)
    dlgLogo:SetTexture("Interface\\AddOns\\Jaina_GameModes\\Textures\\jaina_logo.tga")
    dlg.logo = dlgLogo

    local title = Label(dlg, 21, {1, 0.79, 0.34})
    title:SetPoint("TOP", dlg, "TOP", 0, -46)
    title:SetWidth(470)
    local text = Label(dlg, 14, {0.91, 0.85, 0.71})
    text:SetPoint("TOP", title, "BOTTOM", 0, -14)
    text:SetWidth(450)
    text:SetHeight(170)
    local accept = RedButton(dlg, "ProjectJaina_ConfirmAcceptBtn", "Probar selección", 210, 36)
    accept:SetPoint("BOTTOMLEFT", dlg, "BOTTOMLEFT", 42, 28)
    accept:SetScript("OnClick", function()
        local mode = pendingMode
        pendingMode = nil
        blocker:Hide()
        if mode then M:ApplyMode(mode.id) end
    end)
    local cancel = RedButton(dlg, "ProjectJaina_ConfirmCancelBtn", "Volver", 180, 36)
    cancel:SetPoint("BOTTOMRIGHT", dlg, "BOTTOMRIGHT", -42, 28)
    cancel:SetScript("OnClick", function() pendingMode = nil; blocker:Hide() end)
    blocker:SetScript("OnHide", function() pendingMode = nil end)
    blocker:SetScript("OnSizeChanged", function() ScaleToScreen(dlg, 530, 330) end)
    dlg.title, dlg.text, dlg.btnAccept, dlg.btnCancel = title, text, accept, cancel
    blocker.dlg = dlg
    table.insert(UISpecialFrames, "ProjectJaina_ConfirmBlocker")
    confirmDialog = blocker
    return blocker
end

local function SelectMode(mode)
    if not M:IsAllowedRealm() or InCombatLockdown() or HasSelection() then return end
    if not mode.requireConfirmation then M:ApplyMode(mode.id); return end
    local blocker = CreateConfirmDialog()
    pendingMode = mode
    if M.Config.PreviewOnly then
        blocker.dlg.title:SetText("PROBAR " .. string.upper(mode.title))
        blocker.dlg.text:SetText("Vas a probar la selección de " .. mode.title .. ".\n\nEsta vista previa no activa el modo ni cambia tu personaje.\n\nLas reglas definitivas y la activación se confirmarán con la integración de Inti.")
        blocker.dlg.btnAccept:SetText("Probar selección")
    else
        blocker.dlg.title:SetText(mode.confirmTitle or "CONFIRMAR TU DESTINO")
        blocker.dlg.text:SetText(mode.confirmWarning or "Lee las reglas antes de aceptar este camino.")
        blocker.dlg.btnAccept:SetText("Acepto el desafío")
    end
    ScaleToScreen(blocker.dlg, 530, 330)
    blocker:Show()
end

local function CreateCard(parent, mode, index, count)
    local card = CreateFrame("Button", "ProjectJaina_Card_" .. mode.id, parent)
    card:SetSize(CARD_W, CARD_H)
    local totalWidth = count * CARD_W + (count - 1) * GAP
    card:SetPoint("TOPLEFT", parent, "TOPLEFT", (WIDTH - totalWidth) / 2 + (index - 1) * (CARD_W + GAP), -110)
    card:EnableMouse(true)
    local art = card:CreateTexture(nil, "BACKGROUND")
    art:SetAllPoints(card)
    art:SetTexture(ART .. mode.artTexture)
    local title = Label(card, 25, mode.titleColor)
    title:SetPoint("TOP", card, "TOP", 0, -132)
    title:SetWidth(214)
    title:SetText(mode.title)
    local tagline = Label(card, 11, {0.13, 0.085, 0.04})
    tagline:SetPoint("TOP", card, "TOP", 0, -163)
    tagline:SetWidth(218)
    tagline:SetHeight(27)
    tagline:SetText(mode.tagline)

    local offset = 193
    local perkLabels = {}
    for i, text in ipairs(mode.perks or {}) do
        local bullet = card:CreateTexture(nil, "ARTWORK")
        bullet:SetSize(10, 10)
        bullet:SetPoint("TOPLEFT", card, "TOPLEFT", 29, -offset - 2)
        bullet:SetTexture("Interface\\COMMON\\Indicator-Yellow")
        local color = mode.titleColor or {0.4, 0.25, 0.05}
        bullet:SetVertexColor(math.min(1, color[1] * 2 + 0.1), math.min(1, color[2] * 2 + 0.1), math.min(1, color[3] * 2 + 0.1), 1)
        local label = Label(card, 11, {0.105, 0.065, 0.025}, "LEFT")
        label:SetPoint("TOPLEFT", card, "TOPLEFT", 44, -offset)
        label:SetWidth(180)
        label:SetText(text)
        perkLabels[i] = label
        offset = offset + math.max(14, label:GetStringHeight()) + 4
    end

    local button = RedButton(card, nil, "Probar selección", 190, 32)
    button:SetPoint("BOTTOM", card, "BOTTOM", 0, 37)
    local function Hover(hovered)
        local isCurrent = HasSelection() and ProjectJaina_GameModes_CharDB.selectedMode == mode.id
        local bright = hovered or isCurrent
        art:SetVertexColor(bright and 1 or 0.93, bright and 1 or 0.93, bright and 1 or 0.93, 1)
        local color = mode.titleColor or {0.3, 0.2, 0.1}
        title:SetTextColor(unpack(color))
        button:GetFontString():SetTextColor(1, bright and 0.94 or 0.84, bright and 0.73 or 0.53)
    end
    card:SetScript("OnEnter", function() Hover(true) end)
    card:SetScript("OnLeave", function() if not MouseIsOver(card) then Hover(false) end end)
    button:SetScript("OnEnter", function() Hover(true) end)
    button:SetScript("OnLeave", function() if not MouseIsOver(card) then Hover(false) end end)
    button:SetScript("OnClick", function() SelectMode(mode) end)
    card:SetScript("OnClick", function() SelectMode(mode) end)
    card.ApplyHoverState, card.modeData, card.actionBtn = Hover, mode, button
    card.perkLabels, card.textBottom = perkLabels, offset
    return card
end

local function CreateMainUI()
    if mainFrame then return mainFrame end
    local root = CreateFrame("Frame", "ProjectJaina_GameModes_MainFrame", UIParent)
    root:SetAllPoints(UIParent)
    root:SetFrameStrata("FULLSCREEN_DIALOG")
    root:SetFrameLevel(80)
    root:EnableMouse(true)
    root:Hide()
    local scrim = root:CreateTexture(nil, "BACKGROUND")
    scrim:SetAllPoints(root)
    scrim:SetTexture("Interface\\Buttons\\WHITE8X8")
    scrim:SetVertexColor(0, 0, 0, 0.78)
    local container = CreateFrame("Frame", nil, root)
    container:SetSize(WIDTH, HEIGHT)
    container:SetPoint("CENTER", root, "CENTER", 0, 0)
    DarkBackdrop(container, {0.26, 0.23, 0.17, 0.5})
    root.container = container

    local logo = container:CreateTexture(nil, "ARTWORK")
    logo:SetSize(120, 60)
    logo:SetPoint("TOPLEFT", container, "TOPLEFT", 28, -14)
    logo:SetTexture("Interface\\AddOns\\Jaina_GameModes\\Textures\\jaina_logo.tga")
    container.logo = logo

    local brand = Label(container, 13, {0.78, 0.70, 0.47})
    brand:SetPoint("TOP", container, "TOP", 0, -21)
    brand:SetText("|cffe7c568" .. M.Config.ServerName .. "|r  —  " .. M.Config.RealmName)
    local title = Label(container, 32, {1, 0.80, 0.32})
    title:SetPoint("TOP", container, "TOP", 0, -40)
    title:SetText(M.Config.HeaderTitle)
    title:SetShadowColor(0, 0, 0, 1)
    title:SetShadowOffset(1, -2)
    local subtitle = Label(container, 13, {0.86, 0.82, 0.70})
    subtitle:SetPoint("TOP", container, "TOP", 0, -80)
    subtitle:SetWidth(970)
    subtitle:SetText(M.Config.HeaderSubtitle)
    local footer = Label(container, 11, {0.69, 0.65, 0.54})
    footer:SetPoint("BOTTOM", container, "BOTTOM", 0, 18)
    footer:SetWidth(1010)
    footer:SetText(M.Config.PreviewOnly and M.Config.PreviewFooter or "Conoce las reglas de tu camino antes de confirmar.")
    container.headerSubtitle, container.footer = subtitle, footer

    local enabledModes = {}
    for _, mode in ipairs(M.Config.Modes) do
        if mode.enabled then table.insert(enabledModes, mode) end
    end
    container.cards = {}
    for i, mode in ipairs(enabledModes) do
        table.insert(container.cards, CreateCard(container, mode, i, #enabledModes))
    end
    local close = CreateFrame("Button", nil, container, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", container, "TOPRIGHT", -6, -6)
    close:SetScript("OnClick", function() M:CloseSelectionUI() end)
    container.closeBtn = close
    root:SetScript("OnHide", function()
        if confirmDialog then confirmDialog:Hide() end
        pendingMode = nil
    end)
    root:SetScript("OnSizeChanged", function() ScaleToScreen(container, WIDTH, HEIGHT) end)
    table.insert(UISpecialFrames, "ProjectJaina_GameModes_MainFrame")
    mainFrame = root
    return root
end

function M:OpenSelectionUI()
    if not M:IsAllowedRealm() then return end
    if InCombatLockdown() then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd36a[Project Jaina]|r El selector estará disponible al salir de combate.")
        return
    end
    local ui = CreateMainUI()
    ScaleToScreen(ui.container, WIDTH, HEIGHT)
    RefreshCards()
    if M.Config.SoundOnOpen then PlaySoundFile(M.Config.SoundOnOpen) end
    ui:Show()
end

function M:CloseSelectionUI()
    if mainFrame then mainFrame:Hide() end
    if confirmDialog then confirmDialog:Hide() end
    pendingMode = nil
end
