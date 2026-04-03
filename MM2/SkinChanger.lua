local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local Mouse = localPlayer:GetMouse()

-- ============================================================
-- WEAPON DATABASE
-- ============================================================
local Weapons = {
	["Candy"]        = { Type = "Knife", Category = "Christmas Event",  MeshId = "rbxassetid://19040337",        TextureId = "rbxassetid://19040326" },
	["Blue Candy"]   = { Type = "Knife", Category = "Christmas Event",  MeshId = "rbxassetid://19040337",        TextureId = "rbxassetid://3241832047" },
	["Icewing"]      = { Type = "Knife", Category = "Event",            MeshId = "rbxassetid://2291777189",      TextureId = "rbxassetid://2625514442" },
	["Battle Axe"]   = { Type = "Knife", Category = "Halloween Event",  MeshId = "rbxassetid://1084767698",      TextureId = "rbxassetid://1084767901" },
	["Battle Axe II"]= { Type = "Knife", Category = "Halloween Event",  MeshId = "rbxassetid://2397016406",      TextureId = "rbxassetid://2521633652" },
	["Nightblade"]   = { Type = "Knife", Category = "Gamepass",         MeshId = "rbxassetid://103838505",       TextureId = "rbxassetid://103838996" },
	["Steer"]        = { Type = "Knife", Category = "Standard",         MeshId = "rbxassetid://156092238",       TextureId = "rbxassetid://156092253" },
	["Sugar"]        = { Type = "Gun",   Category = "Christmas Event",  MeshId = "rbxassetid://120092819659076", TextureId = "rbxassetid://101086650" },
	["Gold Sugar"]   = { Type = "Gun",   Category = "Christmas Event",  MeshId = "rbxassetid://120092819659076", TextureId = "rbxassetid://3241872587" },
	["Blue Sugar"]   = { Type = "Gun",   Category = "Christmas Event",  MeshId = "rbxassetid://120092819659076", TextureId = "rbxassetid://3241860913" },
	["Luger"]        = { Type = "Gun",   Category = "Standard",         MeshId = "rbxassetid://102418954118265", TextureId = "rbxassetid://120325652696299" },
	["Laser"]        = { Type = "Gun",   Category = "Standard",         MeshId = "rbxassetid://112269525536231", TextureId = "rbxassetid://75218909825044" },
	["Phaser"]       = { Type = "Gun",   Category = "Standard",         MeshId = "rbxassetid://136855923368407", TextureId = "rbxassetid://69486519" },
}

-- ============================================================
-- MEMORY / APPLY LOGIC
-- ============================================================
local MESH_ID_OFFSET    = 0x108
local MESH_CACHE_OFFSET = 0x100
local TEX_ID_OFFSET     = 0x130
local TEX_CACHE_OFFSET  = 0x128
local VER_OFFSET        = 0x2C0

local function writeString(address, str)
	for i = 1, #str do
		memory_write("byte", address + i - 1, string.byte(str, i))
	end
	memory_write("byte", address + #str, 0)
end

local function getToolByName(name)
	local character = localPlayer.Character
	if character then
		local tool = character:FindFirstChildOfClass("Tool")
		if tool and tool.Name == name then return tool end
	end
	local backpack = localPlayer:FindFirstChild("Backpack")
	if backpack then
		local tool = backpack:FindFirstChildOfClass("Tool")
		if tool and tool.Name == name then return tool end
	end
	return nil
end

local function waitForSpecialMesh(tool, timeout)
	timeout = timeout or 5
	local elapsed = 0
	while elapsed < timeout do
		local handle = tool:FindFirstChild("Handle")
		if handle then
			local mesh = handle:FindFirstChildWhichIsA("SpecialMesh", true)
			if mesh then return mesh end
		end
		task.wait(0.1)
		elapsed = elapsed + 0.1
	end
	return nil
end

local function applyToMesh(mesh, weaponName)
	local w = Weapons[weaponName]
	if not w then return end
	local meshStrObj = memory_read("uintptr_t", mesh.Address + MESH_ID_OFFSET)
	writeString(meshStrObj, w.MeshId)
	memory_write("uintptr_t", mesh.Address + MESH_CACHE_OFFSET, 0)
	local texStrObj = memory_read("uintptr_t", mesh.Address + TEX_ID_OFFSET)
	writeString(texStrObj, w.TextureId)
	memory_write("uintptr_t", mesh.Address + TEX_CACHE_OFFSET, 0)
	local ver = memory_read("int", mesh.Address + VER_OFFSET)
	memory_write("int", mesh.Address + VER_OFFSET, ver + 1)
end

local function applyWeapon(toolName, weaponName)
	local tool = getToolByName(toolName)
	if not tool then return end
	local mesh = waitForSpecialMesh(tool)
	if not mesh then return end
	applyToMesh(mesh, weaponName)
end

-- ============================================================
-- HELPERS
-- ============================================================
local Categories = { "Standard", "Christmas Event", "Halloween Event", "Gamepass" }

local function getWeaponsByTypeAndCategory(wType, category)
	local result = {}
	for name, data in pairs(Weapons) do
		if data.Type == wType and data.Category == category then
			table.insert(result, name)
		end
	end
	table.sort(result)
	return result
end

local function isInRect(mx, my, rx, ry, rw, rh)
	return mx >= rx and mx <= rx + rw and my >= ry and my <= ry + rh
end

local function isMouse(rx, ry, rw, rh)
	return isInRect(Mouse.X, Mouse.Y, rx, ry, rw, rh)
end

-- ============================================================
-- UI COLORS
-- ============================================================
local C = {
	bg          = Color3.fromRGB(13, 15, 17),
	titlebar    = Color3.fromRGB(28, 72, 120),
	tab         = Color3.fromRGB(20, 23, 25),
	tabActive   = Color3.fromRGB(28, 72, 120),
	catBtn      = Color3.fromRGB(22, 28, 34),
	catActive   = Color3.fromRGB(28, 72, 120),
	catHover    = Color3.fromRGB(35, 50, 70),
	item        = Color3.fromRGB(18, 22, 27),
	itemHover   = Color3.fromRGB(30, 45, 65),
	itemSelect  = Color3.fromRGB(28, 72, 120),
	scrollBtn   = Color3.fromRGB(22, 28, 34),
	scrollHover = Color3.fromRGB(40, 60, 90),
	applyBtn    = Color3.fromRGB(18, 100, 50),
	applyHover  = Color3.fromRGB(25, 140, 70),
	closeBtn    = Color3.fromRGB(120, 25, 25),
	closeHover  = Color3.fromRGB(180, 40, 40),
	divider     = Color3.fromRGB(30, 36, 44),
	text        = Color3.fromRGB(240, 240, 240),
	textDim     = Color3.fromRGB(130, 140, 150),
	textSelect  = Color3.fromRGB(255, 255, 255),
	statusOk    = Color3.fromRGB(80, 210, 100),
}

-- ============================================================
-- UI LAYOUT CONSTANTS
-- ============================================================
local WW, WH     = 340, 460
local TITLE_H    = 30
local TAB_H      = 30
local CAT_H      = 26
local ITEM_H     = 26
local APPLY_H    = 36
local PAD        = 6
local MAX_ITEMS  = 8
local SCROLL_W   = 22

-- ============================================================
-- UI STATE
-- ============================================================
local S = {
	open     = true,
	wx = 160, wy = 80,
	dragging = false,
	dragOffX = 0, dragOffY = 0,
	tab      = "Knife",
	knife    = { category = "Standard", skin = nil, scroll = 0 },
	gun      = { category = "Standard", skin = nil, scroll = 0 },
	status   = "",
	statusT  = 0,
}

local function tabState()
	return S.tab == "Knife" and S.knife or S.gun
end

-- ============================================================
-- CREATE DRAWING OBJECTS
-- ============================================================
local function sq(z)
	local d = Drawing.new("Square")
	d.Filled = true
	d.ZIndex = z or 0
	d.Visible = false
	return d
end

local function tx(size, z)
	local d = Drawing.new("Text")
	d.Size = size or 13
	d.Outline = true
	d.ZIndex = z or 1
	d.Visible = false
	return d
end

local function ln(thick, z)
	local d = Drawing.new("Line")
	d.Thickness = thick or 1
	d.ZIndex = z or 1
	d.Visible = false
	return d
end

-- Window
local dWinBg      = sq(-10)
local dTitleBg    = sq(-9)
local dTitleTxt   = tx(15, -8)
local dCloseBox   = sq(-9)
local dCloseTxt   = tx(13, -8)

-- Dividers
local dDiv1       = ln(1, -9)
local dDiv2       = ln(1, -9)
local dDiv3       = ln(1, -9)

-- Tabs
local dKnifeTab   = sq(-9)
local dKnifeTxt   = tx(13, -8)
local dGunTab     = sq(-9)
local dGunTxt     = tx(13, -8)
local dTabLine    = sq(-8) -- active tab underline

-- Category buttons
local dCatBoxes   = {}
local dCatTexts   = {}
for i = 1, 4 do
	dCatBoxes[i] = sq(-9)
	dCatTexts[i] = tx(11, -8)
end

-- Section label
local dSkinsLabel = tx(11, -8)
local dCountLabel = tx(11, -8)

-- Skin list items
local dItemBoxes  = {}
local dItemTexts  = {}
local dItemDots   = {}
for i = 1, MAX_ITEMS do
	dItemBoxes[i] = sq(-9)
	dItemTexts[i] = tx(12, -8)
	dItemDots[i]  = sq(-7)
end

-- Scroll
local dScrollUpBox   = sq(-9)
local dScrollUpTxt   = tx(14, -8)
local dScrollDnBox   = sq(-9)
local dScrollDnTxt   = tx(14, -8)

-- Apply
local dApplyBox   = sq(-9)
local dApplyTxt   = tx(14, -8)

-- Status
local dStatusTxt  = tx(12, -8)

-- ============================================================
-- HIDE ALL
-- ============================================================
local allDrawings = {
	dWinBg, dTitleBg, dTitleTxt, dCloseBox, dCloseTxt,
	dDiv1, dDiv2, dDiv3,
	dKnifeTab, dKnifeTxt, dGunTab, dGunTxt, dTabLine,
	dSkinsLabel, dCountLabel,
	dScrollUpBox, dScrollUpTxt, dScrollDnBox, dScrollDnTxt,
	dApplyBox, dApplyTxt, dStatusTxt,
}
for i = 1, 4 do
	table.insert(allDrawings, dCatBoxes[i])
	table.insert(allDrawings, dCatTexts[i])
end
for i = 1, MAX_ITEMS do
	table.insert(allDrawings, dItemBoxes[i])
	table.insert(allDrawings, dItemTexts[i])
	table.insert(allDrawings, dItemDots[i])
end

local function hideAll()
	for _, d in ipairs(allDrawings) do
		d.Visible = false
	end
end

-- ============================================================
-- UPDATE / RENDER
-- ============================================================
local function update()
	if not S.open then
		hideAll()
		return
	end

	local mx, my = Mouse.X, Mouse.Y
	local wx, wy = S.wx, S.wy

	if S.dragging then
		wx = mx - S.dragOffX
		wy = my - S.dragOffY
		S.wx = wx
		S.wy = wy
	end

	local ts = tabState()
	local skins = getWeaponsByTypeAndCategory(S.tab, ts.category)
	local maxScroll = math.max(0, #skins - MAX_ITEMS)
	ts.scroll = math.max(0, math.min(ts.scroll, maxScroll))

	-- ---- WINDOW ----
	dWinBg.Position = Vector2.new(wx, wy)
	dWinBg.Size     = Vector2.new(WW, WH)
	dWinBg.Color    = C.bg
	dWinBg.Corner   = 7
	dWinBg.Transparency = 0.9
	dWinBg.Visible  = true

	-- ---- TITLE BAR ----
	dTitleBg.Position = Vector2.new(wx, wy)
	dTitleBg.Size     = Vector2.new(WW, TITLE_H)
	dTitleBg.Color    = C.titlebar
	dTitleBg.Corner   = 7
	dTitleBg.Visible  = true

	dTitleTxt.Text     = "Kidz Hub"
	dTitleTxt.Position = Vector2.new(wx + PAD + 4, wy + 7)
	dTitleTxt.Color    = C.text
	dTitleTxt.Visible  = true

	-- Close button
	local cx = wx + WW - 26
	local cy = wy + 6
	local closeHov = isMouse(cx, cy, 18, 18)
	dCloseBox.Position = Vector2.new(cx, cy)
	dCloseBox.Size     = Vector2.new(18, 18)
	dCloseBox.Color    = closeHov and C.closeHover or C.closeBtn
	dCloseBox.Corner   = 4
	dCloseBox.Visible  = true
	dCloseTxt.Text     = "x"
	dCloseTxt.Position = Vector2.new(cx + 4, cy + 2)
	dCloseTxt.Color    = C.text
	dCloseTxt.Visible  = true

	local y = wy + TITLE_H

	-- ---- DIVIDER 1 ----
	dDiv1.From    = Vector2.new(wx, y)
	dDiv1.To      = Vector2.new(wx + WW, y)
	dDiv1.Color   = C.divider
	dDiv1.Visible = true

	-- ---- TABS ----
	local tabW = WW / 2
	local knifeActive = S.tab == "Knife"

	dKnifeTab.Position = Vector2.new(wx, y)
	dKnifeTab.Size     = Vector2.new(tabW, TAB_H)
	dKnifeTab.Color    = knifeActive and C.tabActive or C.tab
	dKnifeTab.Visible  = true
	dKnifeTxt.Text     = "🔪  Knife"
	dKnifeTxt.Position = Vector2.new(wx + tabW/2 - 26, y + 8)
	dKnifeTxt.Color    = C.text
	dKnifeTxt.Visible  = true

	dGunTab.Position = Vector2.new(wx + tabW, y)
	dGunTab.Size     = Vector2.new(tabW, TAB_H)
	dGunTab.Color    = not knifeActive and C.tabActive or C.tab
	dGunTab.Visible  = true
	dGunTxt.Text     = "🔫  Gun"
	dGunTxt.Position = Vector2.new(wx + tabW + tabW/2 - 22, y + 8)
	dGunTxt.Color    = C.text
	dGunTxt.Visible  = true

	-- Active tab underline
	local ulX = knifeActive and wx or wx + tabW
	dTabLine.Position = Vector2.new(ulX + 4, y + TAB_H - 3)
	dTabLine.Size     = Vector2.new(tabW - 8, 3)
	dTabLine.Color    = Color3.fromRGB(100, 160, 220)
	dTabLine.Visible  = true

	y = y + TAB_H

	-- ---- DIVIDER 2 ----
	dDiv2.From    = Vector2.new(wx, y)
	dDiv2.To      = Vector2.new(wx + WW, y)
	dDiv2.Color   = C.divider
	dDiv2.Visible = true

	y = y + PAD

	-- ---- CATEGORY BUTTONS ----
	local catNames = { "Std", "Xmas", "Hween", "GP" }
	local catW = math.floor((WW - PAD * 2 - 3) / 4)
	for i = 1, 4 do
		local bx = wx + PAD + (catW + 1) * (i - 1)
		local isAct = ts.category == Categories[i]
		local isHov = isMouse(bx, y, catW, CAT_H)
		dCatBoxes[i].Position = Vector2.new(bx, y)
		dCatBoxes[i].Size     = Vector2.new(catW, CAT_H)
		dCatBoxes[i].Color    = isAct and C.catActive or (isHov and C.catHover or C.catBtn)
		dCatBoxes[i].Corner   = 4
		dCatBoxes[i].Visible  = true
		dCatTexts[i].Text     = catNames[i]
		dCatTexts[i].Position = Vector2.new(bx + 4, y + 7)
		dCatTexts[i].Color    = isAct and C.textSelect or C.textDim
		dCatTexts[i].Visible  = true
	end

	y = y + CAT_H + PAD

	-- ---- SKIN LIST HEADER ----
	dSkinsLabel.Text     = "SKINS"
	dSkinsLabel.Position = Vector2.new(wx + PAD, y)
	dSkinsLabel.Color    = C.textDim
	dSkinsLabel.Visible  = true

	dCountLabel.Text     = #skins .. " available"
	dCountLabel.Position = Vector2.new(wx + WW - PAD - 60, y)
	dCountLabel.Color    = C.textDim
	dCountLabel.Visible  = true

	y = y + 16

	-- ---- SKIN LIST ----
	local listW = WW - PAD * 2 - SCROLL_W - 4

	for i = 1, MAX_ITEMS do
		local skinIdx = ts.scroll + i
		local skin = skins[skinIdx]
		local iy = y + (i - 1) * ITEM_H

		if skin then
			local isSelect = ts.skin == skin
			local isHov    = isMouse(wx + PAD, iy, listW, ITEM_H - 2)
			dItemBoxes[i].Position = Vector2.new(wx + PAD, iy)
			dItemBoxes[i].Size     = Vector2.new(listW, ITEM_H - 2)
			dItemBoxes[i].Color    = isSelect and C.itemSelect or (isHov and C.itemHover or C.item)
			dItemBoxes[i].Corner   = 3
			dItemBoxes[i].Visible  = true
			dItemTexts[i].Text     = skin
			dItemTexts[i].Position = Vector2.new(wx + PAD + 20, iy + 6)
			dItemTexts[i].Color    = isSelect and C.textSelect or (isHov and C.text or C.textDim)
			dItemTexts[i].Visible  = true
			-- dot indicator
			dItemDots[i].Position = Vector2.new(wx + PAD + 6, iy + 8)
			dItemDots[i].Size     = Vector2.new(7, 7)
			dItemDots[i].Color    = isSelect and Color3.fromRGB(100, 200, 255) or C.textDim
			dItemDots[i].Corner   = 4
			dItemDots[i].Visible  = true
		else
			dItemBoxes[i].Visible = false
			dItemTexts[i].Visible = false
			dItemDots[i].Visible  = false
		end
	end

	-- ---- SCROLL BUTTONS ----
	local sx = wx + WW - PAD - SCROLL_W
	local halfH = math.floor(MAX_ITEMS * ITEM_H / 2) - 1
	local upHov = isMouse(sx, y, SCROLL_W, halfH)
	dScrollUpBox.Position = Vector2.new(sx, y)
	dScrollUpBox.Size     = Vector2.new(SCROLL_W, halfH)
	dScrollUpBox.Color    = upHov and C.scrollHover or C.scrollBtn
	dScrollUpBox.Corner   = 3
	dScrollUpBox.Visible  = true
	dScrollUpTxt.Text     = "^"
	dScrollUpTxt.Position = Vector2.new(sx + 6, y + halfH/2 - 7)
	dScrollUpTxt.Color    = C.text
	dScrollUpTxt.Visible  = true

	local dnY = y + halfH + 2
	local dnHov = isMouse(sx, dnY, SCROLL_W, halfH)
	dScrollDnBox.Position = Vector2.new(sx, dnY)
	dScrollDnBox.Size     = Vector2.new(SCROLL_W, halfH)
	dScrollDnBox.Color    = dnHov and C.scrollHover or C.scrollBtn
	dScrollDnBox.Corner   = 3
	dScrollDnBox.Visible  = true
	dScrollDnTxt.Text     = "v"
	dScrollDnTxt.Position = Vector2.new(sx + 6, dnY + halfH/2 - 7)
	dScrollDnTxt.Color    = C.text
	dScrollDnTxt.Visible  = true

	-- ---- DIVIDER 3 ----
	local divY = wy + WH - APPLY_H - PAD * 2 - 16
	dDiv3.From    = Vector2.new(wx, divY)
	dDiv3.To      = Vector2.new(wx + WW, divY)
	dDiv3.Color   = C.divider
	dDiv3.Visible = true

	-- ---- APPLY BUTTON ----
	local abX = wx + PAD
	local abY = wy + WH - APPLY_H - PAD - 12
	local abW = WW - PAD * 2
	local apHov = isMouse(abX, abY, abW, APPLY_H)
	dApplyBox.Position = Vector2.new(abX, abY)
	dApplyBox.Size     = Vector2.new(abW, APPLY_H)
	dApplyBox.Color    = apHov and C.applyHover or C.applyBtn
	dApplyBox.Corner   = 5
	dApplyBox.Visible  = true

	local apLabel = ts.skin and ("Apply  " .. ts.skin) or "Select a skin first"
	dApplyTxt.Text     = apLabel
	dApplyTxt.Position = Vector2.new(abX + abW/2 - #apLabel * 4, abY + 11)
	dApplyTxt.Color    = C.text
	dApplyTxt.Visible  = true

	-- ---- STATUS ----
	if S.status ~= "" then
		dStatusTxt.Text     = S.status
		dStatusTxt.Position = Vector2.new(wx + WW/2 - #S.status * 3, wy + WH - 12)
		dStatusTxt.Color    = C.statusOk
		dStatusTxt.Visible  = true
	else
		dStatusTxt.Visible = false
	end
end

-- ============================================================
-- INPUT
-- ============================================================
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.G then
		S.open = not S.open
		return
	end

	if input.KeyCode ~= Enum.KeyCode.MouseButton1 then return end
	if not S.open then return end

	local mx, my = Mouse.X, Mouse.Y
	local wx, wy = S.wx, S.wy
	local ts = tabState()

	-- Close
	if isInRect(mx, my, wx + WW - 26, wy + 6, 18, 18) then
		S.open = false
		return
	end

	-- Drag start
	if isInRect(mx, my, wx, wy, WW - 30, TITLE_H) then
		S.dragging = true
		S.dragOffX = mx - wx
		S.dragOffY = my - wy
		return
	end

	local y = wy + TITLE_H

	-- Tabs
	local tabW = WW / 2
	if isInRect(mx, my, wx, y, tabW, TAB_H) then
		S.tab = "Knife"
		return
	end
	if isInRect(mx, my, wx + tabW, y, tabW, TAB_H) then
		S.tab = "Gun"
		return
	end

	y = y + TAB_H + PAD

	-- Categories
	local catW = math.floor((WW - PAD * 2 - 3) / 4)
	for i = 1, 4 do
		local bx = wx + PAD + (catW + 1) * (i - 1)
		if isInRect(mx, my, bx, y, catW, CAT_H) then
			ts.category = Categories[i]
			ts.scroll   = 0
			ts.skin     = nil
			return
		end
	end

	y = y + CAT_H + PAD + 16

	local skins  = getWeaponsByTypeAndCategory(S.tab, ts.category)
	local listW  = WW - PAD * 2 - SCROLL_W - 4
	local halfH  = math.floor(MAX_ITEMS * ITEM_H / 2) - 1
	local sx     = wx + WW - PAD - SCROLL_W

	-- Scroll up
	if isInRect(mx, my, sx, y, SCROLL_W, halfH) then
		ts.scroll = math.max(0, ts.scroll - 1)
		return
	end

	-- Scroll down
	local dnY = y + halfH + 2
	if isInRect(mx, my, sx, dnY, SCROLL_W, halfH) then
		local maxS = math.max(0, #skins - MAX_ITEMS)
		ts.scroll = math.min(maxS, ts.scroll + 1)
		return
	end

	-- Skin items
	for i = 1, MAX_ITEMS do
		local skin = skins[ts.scroll + i]
		local iy   = y + (i - 1) * ITEM_H
		if skin and isInRect(mx, my, wx + PAD, iy, listW, ITEM_H - 2) then
			ts.skin = skin
			return
		end
	end

	-- Apply button
	local abX = wx + PAD
	local abY = wy + WH - APPLY_H - PAD - 12
	local abW = WW - PAD * 2
	if isInRect(mx, my, abX, abY, abW, APPLY_H) then
		if ts.skin then
			applyWeapon(S.tab, ts.skin)
			S.status  = "✓ Applied: " .. ts.skin
			S.statusT = 3
			notify(S.tab .. " skin applied!", "Kidz Hub", 3)
		end
		return
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.MouseButton1 then
		S.dragging = false
	end
end)

-- ============================================================
-- INIT DEFAULT SELECTIONS
-- ============================================================
local ks = getWeaponsByTypeAndCategory("Knife", "Standard")
local gs = getWeaponsByTypeAndCategory("Gun", "Standard")
S.knife.skin = ks[1] or nil
S.gun.skin   = gs[1] or nil

-- ============================================================
-- MAIN LOOP
-- ============================================================
local lastCharacter = nil
while true do
	task.wait()

	-- Status timer
	if S.statusT > 0 then
		S.statusT = S.statusT - (1/60)
		if S.statusT <= 0 then
			S.status  = ""
			S.statusT = 0
		end
	end

	-- Auto apply on respawn
	local character = localPlayer.Character
	if character and character ~= lastCharacter then
		lastCharacter = character
		if S.knife.skin then applyWeapon("Knife", S.knife.skin) end
		if S.gun.skin   then applyWeapon("Gun",   S.gun.skin)   end
	end

	update()
end
