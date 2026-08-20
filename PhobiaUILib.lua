local PhobiaUI = {}

function PhobiaUI.CreateWindow(Opts)
	Opts = Opts or {}
	local Title = Opts.Title or "PHOBIA"
	local TabNames = Opts.Tabs or { "General" }
	local WindowSize = Opts.Size or Vector2.new(380, 370)
	local WindowPos = Opts.Position or Vector2.new(60, 60)
	local MenuKeyDefault = Opts.MenuKey or 0x2D

	setrobloxinput(true)
	local RunService = game:GetService("RunService")

	local PanelBg = Opts.PanelBg or Color3.new(0.055, 0.055, 0.075)
	local TitleBg = Opts.TitleBg or Color3.new(0.095, 0.088, 0.135)
	local TabBarBg = Opts.TabBarBg or Color3.new(0.075, 0.07, 0.105)
	local BorderColor = Opts.BorderColor or Color3.new(0.20, 0.19, 0.27)
	local Accent = Opts.Accent or Color3.new(0.58, 0.45, 0.98)
	local TextColor = Opts.TextColor or Color3.new(0.93, 0.93, 0.96)
	local MutedText = Opts.MutedText or Color3.new(0.55, 0.55, 0.62)
	local BindWhite = Color3.new(0.97, 0.97, 0.99)

	local TitleBarHeight = 36
	local TabBarHeight = 30

	local Widgets = {}

	local function TrackDraw(Obj, Kind)
		local Entry = { Obj = Obj, Kind = Kind }
		table.insert(Widgets, Entry)
		return Entry
	end

	local function AbsSquare(X, Y, W, H, Color, Filled, Corner, ZIndex, Thickness)
		local Obj = Drawing.new("Square")
		Obj.Position = Vector2.new(X, Y)
		Obj.Size = Vector2.new(W, H)
		Obj.Color = Color
		Obj.Filled = Filled
		Obj.Corner = Corner
		Obj.ZIndex = ZIndex
		Obj.Transparency = 1
		Obj.Visible = true
		if Thickness then Obj.Thickness = Thickness end
		return TrackDraw(Obj, "Square")
	end

	local function AbsText(X, Y, Text, Color, FontSize, ZIndex)
		local Obj = Drawing.new("Text")
		Obj.Position = Vector2.new(X, Y)
		Obj.Text = Text
		Obj.Color = Color
		Obj.FontSize = FontSize
		Obj.Center = false
		Obj.Outline = true
		Obj.ZIndex = ZIndex
		Obj.Visible = true
		return TrackDraw(Obj, "Text")
	end

	local function AbsLine(X1, Y1, X2, Y2, Color, Thickness, ZIndex)
		local Obj = Drawing.new("Line")
		Obj.From = Vector2.new(X1, Y1)
		Obj.To = Vector2.new(X2, Y2)
		Obj.Color = Color
		Obj.Thickness = Thickness
		Obj.ZIndex = ZIndex
		Obj.Visible = true
		return TrackDraw(Obj, "Line")
	end

	local function CenterTextInBox(Entry, Text, CenterX, CenterY, FontSize)
		Entry.Obj.Text = Text
		Entry.Obj.FontSize = FontSize
		local HalfWidth = (#Text * FontSize * 0.3)
		Entry.Obj.Position = Vector2.new(CenterX - HalfWidth, CenterY - FontSize * 0.55)
	end

	local Hitboxes = {}
	local function AddHitbox(X, Y, W, H, OnClick)
		local Box = { X = X, Y = Y, W = W, H = H, OnClick = OnClick }
		table.insert(Hitboxes, Box)
		table.insert(Widgets, { Kind = "Hitbox", Box = Box })
		return Box
	end

	local function MoveWindow(Dx, Dy)
		WindowPos = Vector2.new(WindowPos.X + Dx, WindowPos.Y + Dy)
		for _, E in ipairs(Widgets) do
			if E.Kind == "Line" then
				E.Obj.From = Vector2.new(E.Obj.From.X + Dx, E.Obj.From.Y + Dy)
				E.Obj.To = Vector2.new(E.Obj.To.X + Dx, E.Obj.To.Y + Dy)
			elseif E.Kind == "Hitbox" then
				E.Box.X = E.Box.X + Dx
				E.Box.Y = E.Box.Y + Dy
			else
				E.Obj.Position = Vector2.new(E.Obj.Position.X + Dx, E.Obj.Position.Y + Dy)
			end
		end
	end

	local function PointInBox(Px, Py, Box)
		return Px >= Box.X and Px <= Box.X + Box.W and Py >= Box.Y and Py <= Box.Y + Box.H
	end

	AbsSquare(WindowPos.X, WindowPos.Y, WindowSize.X, WindowSize.Y, BorderColor, true, 10, 1)
	AbsSquare(WindowPos.X + 1, WindowPos.Y + 1, WindowSize.X - 2, WindowSize.Y - 2, PanelBg, true, 9, 2)
	AbsSquare(WindowPos.X + 1, WindowPos.Y + 1, WindowSize.X - 2, TitleBarHeight, TitleBg, true, 9, 3)

	AbsSquare(WindowPos.X + 14, WindowPos.Y + TitleBarHeight / 2 - 4, 8, 8, Accent, true, 3, 5)
	AbsText(WindowPos.X + 30, WindowPos.Y + 11, Title, TextColor, 15, 5)

	local MenuBindSize = 24
	local MenuBindX = WindowPos.X + WindowSize.X - MenuBindSize - 12
	local MenuBindY = WindowPos.Y + (TitleBarHeight - MenuBindSize) / 2
	local MenuBindCenterX = MenuBindX + MenuBindSize / 2
	local MenuBindCenterY = MenuBindY + MenuBindSize / 2
	AbsSquare(MenuBindX, MenuBindY, MenuBindSize, MenuBindSize, BorderColor, false, 5, 6, 1)
	local MenuBindText = AbsText(0, 0, "", BindWhite, 10, 7)

	local ShortKeyNames = {
		[0x2D] = "Ins", [0x2E] = "Del", [0x24] = "Hom", [0x23] = "End",
		[0xA0] = "LSh", [0xA1] = "RSh", [0xA2] = "LCt", [0xA3] = "RCt",
		[0x70] = "F1", [0x71] = "F2", [0x72] = "F3", [0x73] = "F4",
		[0x74] = "F5", [0x75] = "F6", [0x76] = "F7", [0x77] = "F8",
		[0x20] = "Spc",
	}
	for I = 0x41, 0x5A do ShortKeyNames[I] = string.char(I) end

	CenterTextInBox(MenuBindText, ShortKeyNames[MenuKeyDefault] or "Ins", MenuBindCenterX, MenuBindCenterY, 10)

	local ListenVkList = {}
	for I = 0x41, 0x5A do table.insert(ListenVkList, I) end
	for _, V in ipairs({0x70,0x71,0x72,0x73,0x74,0x75,0x76,0x77,0x2D,0x2E,0x24,0x23,0x20,0xA0,0xA1,0xA2,0xA3}) do
		table.insert(ListenVkList, V)
	end

	local ListeningForMenuKey = false
	local WasKeyDown = {}
	local MenuKey = MenuKeyDefault
	local MenuVisible = true
	local MenuAnim = 1

	local MenuBindHitbox = AddHitbox(MenuBindX, MenuBindY, MenuBindSize, MenuBindSize, function()
		ListeningForMenuKey = true
		CenterTextInBox(MenuBindText, "...", MenuBindCenterX, MenuBindCenterY, 10)
	end)

	local TabBarY = WindowPos.Y + TitleBarHeight + 1
	AbsSquare(WindowPos.X + 1, TabBarY, WindowSize.X - 2, TabBarHeight, TabBarBg, true, 0, 3)
	AbsLine(WindowPos.X, TabBarY + TabBarHeight, WindowPos.X + WindowSize.X, TabBarY + TabBarHeight, BorderColor, 1, 5)

	local TabWidth = WindowSize.X / #TabNames
	local ActiveTab = TabNames[1]

	local TabButtons = {}
	local TabTargetX = {}
	local ContentByTab = {}
	local TabAnim = {}
	for _, N in ipairs(TabNames) do
		ContentByTab[N] = {}
		TabAnim[N] = (N == ActiveTab) and 1 or 0
	end

	local function AddToTab(TabName, Entry)
		Entry.Group = TabName
		table.insert(ContentByTab[TabName], Entry)
		return Entry
	end

	for Index, Name in ipairs(TabNames) do
		local Bx = WindowPos.X + (Index - 1) * TabWidth
		local Text = AbsText(Bx + TabWidth / 2 - (#Name * 3.3), TabBarY + 8, Name, Name == ActiveTab and TextColor or MutedText, 12, 6)
		TabButtons[Name] = Text
		TabTargetX[Name] = Bx + 8
		AddHitbox(Bx, TabBarY, TabWidth, TabBarHeight, function()
			ActiveTab = Name
			for _, N in ipairs(TabNames) do
				TabButtons[N].Obj.Color = (N == ActiveTab) and TextColor or MutedText
			end
		end)
	end

	local Underline = AbsSquare(TabTargetX[ActiveTab], TabBarY + TabBarHeight - 2, TabWidth - 16, 2, Accent, true, 1, 6)
	local UnderlineX = TabTargetX[ActiveTab]

	local ContentX = WindowPos.X + 16
	local ContentY = TabBarY + TabBarHeight + 18

	local CardPad = 12
	local CardHeaderH = 18
	local CardDividerGap = 8
	local CardRowH = 20
	local CardGap = 12
	local CardRowGap = 14
	local CardW = (WindowSize.X - 32 - CardGap) / 2
	local Col1X = ContentX
	local Col2X = ContentX + CardW + CardGap

	local TabCursor = {}
	local function GetCursor(TabName)
		if not TabCursor[TabName] then
			TabCursor[TabName] = { Col = 1, RowY = ContentY, RowMaxH = 0 }
		end
		return TabCursor[TabName]
	end

	local Toggles = {}
	local ToggleState = {}
	local ToggleAnim = {}
	local ToggleCallbacks = {}
	local SpecialAnim = { Picker = 0 }
	local NextToggleId = 0

	local function AddToggleRaw(TabName, X, Y, Size, LabelText, FontSize, Default, ParentKey, OnChange)
		NextToggleId = NextToggleId + 1
		local Key = "T" .. NextToggleId
		ToggleState[Key] = Default and true or false
		ToggleAnim[Key] = ToggleState[Key] and 1 or 0
		ToggleCallbacks[Key] = OnChange
		local CenterX, CenterY = X + Size / 2, Y + Size / 2
		local Corner = math.max(2, Size * 0.28)
		local Border = AbsSquare(X, Y, Size, Size, BorderColor, false, Corner, 6, 1.2)
		local Fill = AbsSquare(CenterX, CenterY, 0, 0, Accent, true, math.max(1, Corner - 1), 6)
		local Label = AbsText(X + Size + 8, Y + (Size - FontSize) / 2 - 1, LabelText, TextColor, FontSize, 6)
		Border.ParentKey = ParentKey
		Fill.ParentKey = ParentKey
		Label.ParentKey = ParentKey
		AddToTab(TabName, Border)
		AddToTab(TabName, Fill)
		AddToTab(TabName, Label)
		local Entry = { Key = Key, Fill = Fill, CenterX = CenterX, CenterY = CenterY, Size = Size }
		table.insert(Toggles, Entry)
		local Box = AddHitbox(X, Y, Size, Size, function()
			ToggleState[Key] = not ToggleState[Key]
			if ToggleCallbacks[Key] then ToggleCallbacks[Key](ToggleState[Key]) end
		end)
		Box.Group = TabName
		Box.ParentKey = ParentKey
		return Key
	end

	local CategoryColors = {}
	local CategoryColorRGB = {}
	local ColorCallbacks = {}
	local function SetCategoryColor(Key, R, G, B)
		CategoryColorRGB[Key] = { R, G, B }
		CategoryColors[Key] = Color3.new(R, G, B)
	end

	local Swatches = {}
	local ColorPickerOpen = false
	local ActivePickerKey = nil

	local PresetColors = {
		{0.58, 0.45, 0.98}, {0.95, 0.25, 0.3},
		{0.95, 0.65, 0.25}, {0.95, 0.9, 0.3},
		{0.35, 0.85, 0.55}, {0.35, 0.85, 0.95},
		{0.35, 0.55, 0.95}, {0.95, 0.95, 0.97},
	}

	local PickerCols, PickerRows = 4, 2
	local PickerSwatchSize = 20
	local PickerGap = 6
	local PickerPad = 10
	local PresetGridH = PickerRows * PickerSwatchSize + (PickerRows - 1) * PickerGap
	local SlidersAreaH = 3 * 34
	local CloseBtnH = 24
	local CloseBtnGap = 10
	local PickerW = math.max(PickerCols * PickerSwatchSize + (PickerCols - 1) * PickerGap, 140) + PickerPad * 2
	local PickerH = PickerPad + PresetGridH + 14 + SlidersAreaH + CloseBtnGap + CloseBtnH + PickerPad
	local PickerX = ContentX
	local PickerY = ContentY
	local PickerWidgetsList = {}
	local PickerHitboxList = {}

	local function AddPickerSquare(X, Y, W, H, Color, Filled, Corner, ZIndex, Thickness)
		local E = AbsSquare(X, Y, W, H, Color, Filled, Corner, ZIndex, Thickness)
		E.SpecialAnim = "Picker"
		table.insert(PickerWidgetsList, E)
		return E
	end
	local function AddPickerText(X, Y, Text, Color, FontSize, ZIndex)
		local E = AbsText(X, Y, Text, Color, FontSize, ZIndex)
		E.SpecialAnim = "Picker"
		table.insert(PickerWidgetsList, E)
		return E
	end

	AddPickerSquare(PickerX, PickerY, PickerW, PickerH, BorderColor, true, 8, 60, 1)
	AddPickerSquare(PickerX + 1, PickerY + 1, PickerW - 2, PickerH - 2, TitleBg, true, 7, 61)

	local Sliders = {}
	local SliderDraggingIndex = nil

	local function SyncSlidersToColor(R, G, B)
		local Comp = { R, G, B }
		for I, S in ipairs(Sliders) do
			S.Value = math.floor(Comp[I] * 255)
			local Rel = S.Value / 255
			S.Handle.Obj.Position = Vector2.new(S.TrackX + Rel * S.TrackW - 5, S.TrackY - 2)
			S.Label.Obj.Text = S.LabelPrefix .. " " .. S.Value
		end
	end

	local function RecomputeActiveColor()
		if not ActivePickerKey then return end
		local R = Sliders[1].Value / 255
		local G = Sliders[2].Value / 255
		local B = Sliders[3].Value / 255
		SetCategoryColor(ActivePickerKey, R, G, B)
		Swatches[ActivePickerKey].Obj.Color = CategoryColors[ActivePickerKey]
		if ColorCallbacks[ActivePickerKey] then ColorCallbacks[ActivePickerKey](CategoryColors[ActivePickerKey]) end
	end

	for I, P in ipairs(PresetColors) do
		local Row = math.floor((I - 1) / PickerCols)
		local ColI = (I - 1) % PickerCols
		local Sx = PickerX + PickerPad + ColI * (PickerSwatchSize + PickerGap)
		local Sy = PickerY + PickerPad + Row * (PickerSwatchSize + PickerGap)
		local Col3 = Color3.new(P[1], P[2], P[3])
		AddPickerSquare(Sx, Sy, PickerSwatchSize, PickerSwatchSize, Col3, true, 4, 62)
		local PBox = AddHitbox(Sx, Sy, PickerSwatchSize, PickerSwatchSize, function()
			if not ColorPickerOpen or not ActivePickerKey then return end
			SetCategoryColor(ActivePickerKey, P[1], P[2], P[3])
			Swatches[ActivePickerKey].Obj.Color = CategoryColors[ActivePickerKey]
			if ColorCallbacks[ActivePickerKey] then ColorCallbacks[ActivePickerKey](CategoryColors[ActivePickerKey]) end
			SyncSlidersToColor(P[1], P[2], P[3])
		end)
		PBox.Group = nil
		PBox.RequiresPicker = true
		table.insert(PickerHitboxList, PBox)
	end

	local function AddSlider(Label, Y, InitValue)
		local TrackX = PickerX + PickerPad
		local TrackW = PickerW - PickerPad * 2
		local LabelEntry = AddPickerText(TrackX, Y, Label .. " " .. math.floor(InitValue), MutedText, 11, 63)
		local TrackY = Y + 16
		AddPickerSquare(TrackX, TrackY, TrackW, 6, BorderColor, true, 3, 62)
		local Rel0 = InitValue / 255
		local Handle = AddPickerSquare(TrackX + Rel0 * TrackW - 5, TrackY - 2, 10, 10, BindWhite, true, 5, 64)
		local SliderEntry = { TrackX = TrackX, TrackW = TrackW, TrackY = TrackY, Handle = Handle, Label = LabelEntry, LabelPrefix = Label, Value = InitValue }
		table.insert(Sliders, SliderEntry)
		local ThisIndex = #Sliders
		local HitBoxEntry = AddHitbox(TrackX - 6, TrackY - 8, TrackW + 12, 20, function()
			if not ColorPickerOpen then return end
			SliderDraggingIndex = ThisIndex
		end)
		HitBoxEntry.Group = nil
		HitBoxEntry.RequiresPicker = true
		table.insert(PickerHitboxList, HitBoxEntry)
		return SliderEntry
	end

	local SliderStartY = PickerY + PickerPad + PresetGridH + 14
	AddSlider("R", SliderStartY, 150)
	AddSlider("G", SliderStartY + 34, 115)
	AddSlider("B", SliderStartY + 68, 250)

	local CloseBtnY = PickerY + PickerH - PickerPad - CloseBtnH
	local CloseBtnX = PickerX + PickerPad
	local CloseBtnW = PickerW - PickerPad * 2
	AddPickerSquare(CloseBtnX, CloseBtnY, CloseBtnW, CloseBtnH, BorderColor, false, 6, 62, 1)
	AddPickerText(CloseBtnX + CloseBtnW / 2 - 18, CloseBtnY + 6, "Close", MutedText, 12, 63)
	local CloseHitbox = AddHitbox(CloseBtnX, CloseBtnY, CloseBtnW, CloseBtnH, function()
		if not ColorPickerOpen then return end
		ColorPickerOpen = false
	end)
	CloseHitbox.Group = nil
	CloseHitbox.RequiresPicker = true
	table.insert(PickerHitboxList, CloseHitbox)

	local function MovePicker(Dx, Dy)
		for _, E in ipairs(PickerWidgetsList) do
			E.Obj.Position = Vector2.new(E.Obj.Position.X + Dx, E.Obj.Position.Y + Dy)
		end
		for _, Box in ipairs(PickerHitboxList) do
			Box.X = Box.X + Dx
			Box.Y = Box.Y + Dy
		end
		for _, S in ipairs(Sliders) do
			S.TrackX = S.TrackX + Dx
			S.TrackY = S.TrackY + Dy
		end
		PickerX = PickerX + Dx
		PickerY = PickerY + Dy
	end

	local function OpenPickerFor(Key, SwX, SwY, SwatchSizeLocal)
		if ActivePickerKey == Key and ColorPickerOpen then
			ColorPickerOpen = false
			return
		end
		ActivePickerKey = Key
		ColorPickerOpen = true
		local TargetX = SwX + SwatchSizeLocal - PickerW
		local TargetY = SwY + SwatchSizeLocal + 10
		MovePicker(TargetX - PickerX, TargetY - PickerY)
		local RGB = CategoryColorRGB[Key]
		SyncSlidersToColor(RGB[1], RGB[2], RGB[3])
	end

	local TabHandle = {}
	TabHandle.__index = TabHandle

	function TabHandle:AddCard(Title, Opts2)
		Opts2 = Opts2 or {}
		local TabName = self.Name
		local Cur = GetCursor(TabName)
		local X = (Cur.Col == 1) and Col1X or Col2X
		local Y = Cur.RowY

		local Items = Opts2.Items or {}
		local H = CardPad + CardHeaderH + CardDividerGap + 10 + CardRowH * math.max(#Items, 0) + CardPad
		if #Items == 0 then H = CardPad + CardHeaderH + CardPad end

		local Border = AbsSquare(X, Y, CardW, H, BorderColor, false, 9, 6, 1.2)
		local Bg = AbsSquare(X + 1, Y + 1, CardW - 2, H - 2, TitleBg, true, 8, 5)
		AddToTab(TabName, Border)
		AddToTab(TabName, Bg)

		local CardKey = AddToggleRaw(TabName, X + CardPad, Y + CardPad, 16, Title, 13, Opts2.Default, nil, Opts2.OnToggle)

		if Opts2.ColorPicker then
			local DefaultColor = Opts2.DefaultColor or {0.58, 0.45, 0.98}
			SetCategoryColor(CardKey, DefaultColor[1], DefaultColor[2], DefaultColor[3])
			ColorCallbacks[CardKey] = Opts2.OnColorChange
			local SwatchSizeLocal = 16
			local SwX = X + CardW - CardPad - SwatchSizeLocal
			local SwY = Y + CardPad
			local SwBorder = AbsSquare(SwX - 2, SwY - 2, SwatchSizeLocal + 4, SwatchSizeLocal + 4, BorderColor, false, 6, 6, 1)
			local SwFill = AbsSquare(SwX, SwY, SwatchSizeLocal, SwatchSizeLocal, CategoryColors[CardKey], true, 5, 7)
			AddToTab(TabName, SwBorder)
			AddToTab(TabName, SwFill)
			Swatches[CardKey] = SwFill
			local SwHitbox = AddHitbox(SwX - 2, SwY - 2, SwatchSizeLocal + 4, SwatchSizeLocal + 4, function()
				OpenPickerFor(CardKey, SwX, SwY, SwatchSizeLocal)
			end)
			SwHitbox.Group = TabName
		end

		if #Items > 0 then
			local DivY = Y + CardPad + CardHeaderH + CardDividerGap
			local Div = AbsLine(X + CardPad, DivY, X + CardW - CardPad, DivY, BorderColor, 1, 6)
			AddToTab(TabName, Div)

			local RowsStartY = DivY + 10
			for I, Item in ipairs(Items) do
				AddToggleRaw(TabName, X + CardPad, RowsStartY + (I - 1) * CardRowH, 12, Item.Label, 11, Item.Default, nil, Item.OnToggle)
			end
		end

		Cur.RowMaxH = math.max(Cur.RowMaxH, H)
		if Cur.Col == 1 then
			Cur.Col = 2
		else
			Cur.Col = 1
			Cur.RowY = Cur.RowY + Cur.RowMaxH + CardRowGap
			Cur.RowMaxH = 0
		end

		return {
			GetEnabled = function() return ToggleState[CardKey] end,
			SetEnabled = function(V) ToggleState[CardKey] = V and true or false end,
			GetColor = function() return CategoryColors[CardKey] end,
		}
	end

	function TabHandle:AddToggle(Label, Default, OnChange)
		local Cur = GetCursor(self.Name)
		local X = (Cur.Col == 1) and Col1X or Col2X
		local Key = AddToggleRaw(self.Name, X, Cur.RowY, 16, Label, 13, Default, nil, OnChange)
		Cur.RowMaxH = math.max(Cur.RowMaxH, 24)
		if Cur.Col == 1 then
			Cur.Col = 2
		else
			Cur.Col = 1
			Cur.RowY = Cur.RowY + Cur.RowMaxH + CardRowGap
			Cur.RowMaxH = 0
		end
		return {
			GetEnabled = function() return ToggleState[Key] end,
			SetEnabled = function(V) ToggleState[Key] = V and true or false end,
		}
	end

	local Window = {}
	local TabHandles = {}
	for _, N in ipairs(TabNames) do
		local H = setmetatable({ Name = N }, TabHandle)
		TabHandles[N] = H
	end

	function Window:GetTab(Name)
		return TabHandles[Name]
	end

	function Window:SetVisible(V)
		MenuVisible = V and true or false
	end

	function Window:IsVisible()
		return MenuVisible
	end

	Window.TitleBarHitbox = { X = WindowPos.X, Y = WindowPos.Y, W = WindowSize.X, H = TitleBarHeight }
	Window.WasMouseDown = false
	Window.Dragging = false
	Window.DragOffset = Vector2.new(0, 0)

	RunService.Heartbeat:Connect(function(DeltaTime)
		local Dt = DeltaTime or 0.016
		local FadeSpeed = math.min(1, Dt * 16)
		local SlideSpeed = math.min(1, Dt * 18)

		for _, Name in ipairs(TabNames) do
			local Target = (Name == ActiveTab) and 1 or 0
			TabAnim[Name] = TabAnim[Name] + (Target - TabAnim[Name]) * FadeSpeed
			if math.abs(TabAnim[Name] - Target) < 0.004 then TabAnim[Name] = Target end
		end

		local MenuTarget = MenuVisible and 1 or 0
		MenuAnim = MenuAnim + (MenuTarget - MenuAnim) * FadeSpeed
		if math.abs(MenuAnim - MenuTarget) < 0.004 then MenuAnim = MenuTarget end

		local PickerTarget = ColorPickerOpen and 1 or 0
		SpecialAnim.Picker = SpecialAnim.Picker + (PickerTarget - SpecialAnim.Picker) * FadeSpeed
		if math.abs(SpecialAnim.Picker - PickerTarget) < 0.004 then SpecialAnim.Picker = PickerTarget end

		UnderlineX = UnderlineX + (TabTargetX[ActiveTab] - UnderlineX) * SlideSpeed
		Underline.Obj.Position = Vector2.new(UnderlineX, Underline.Obj.Position.Y)

		for _, T in ipairs(Toggles) do
			local Target = ToggleState[T.Key] and 1 or 0
			ToggleAnim[T.Key] = ToggleAnim[T.Key] + (Target - ToggleAnim[T.Key]) * math.min(1, Dt * 14)
			if math.abs(ToggleAnim[T.Key] - Target) < 0.004 then ToggleAnim[T.Key] = Target end
			local Inner = math.max(0, (T.Size - 6) * ToggleAnim[T.Key])
			T.Fill.Obj.Size = Vector2.new(Inner, Inner)
			T.Fill.Obj.Position = Vector2.new(T.CenterX - Inner / 2, T.CenterY - Inner / 2)
			T.Fill.ExtraAlpha = ToggleAnim[T.Key]
		end

		for _, E in ipairs(Widgets) do
			if E.Kind == "Square" or E.Kind == "Text" or E.Kind == "Line" then
				local GroupAlpha = E.Group and (TabAnim[E.Group] or 1) or 1
				local ParentAlpha = E.ParentKey and (ToggleAnim[E.ParentKey] or 1) or 1
				local SpecialAlpha = E.SpecialAnim and (SpecialAnim[E.SpecialAnim] or 1) or 1
				local Extra = E.ExtraAlpha or 1
				local Final = GroupAlpha * ParentAlpha * SpecialAlpha * Extra * MenuAnim
				E.Obj.Transparency = Final
				E.Obj.Visible = Final > 0.02
			end
		end

		local MouseDown = ismouse1pressed()
		local MousePos = GetMouseLocation()

		if SliderDraggingIndex and MouseDown then
			local S = Sliders[SliderDraggingIndex]
			local Rel = (MousePos.X - S.TrackX) / S.TrackW
			if Rel < 0 then Rel = 0 elseif Rel > 1 then Rel = 1 end
			S.Value = math.floor(Rel * 255)
			S.Handle.Obj.Position = Vector2.new(S.TrackX + Rel * S.TrackW - 5, S.TrackY - 2)
			S.Label.Obj.Text = S.LabelPrefix .. " " .. S.Value
			RecomputeActiveColor()
		elseif not MouseDown then
			SliderDraggingIndex = nil
		end

		if MenuVisible and MouseDown and not Window.WasMouseDown then
			local Handled = false
			for _, Box in ipairs(Hitboxes) do
				local GroupOk = (not Box.Group) or (Box.Group == ActiveTab)
				local ParentOk = (not Box.ParentKey) or ToggleState[Box.ParentKey]
				local PickerOk = (not Box.RequiresPicker) or ColorPickerOpen
				if GroupOk and ParentOk and PickerOk and PointInBox(MousePos.X, MousePos.Y, Box) then
					if Box.OnClick then Box.OnClick() end
					Handled = true
					break
				end
			end
			if not Handled and PointInBox(MousePos.X, MousePos.Y, Window.TitleBarHitbox) then
				Window.Dragging = true
				Window.DragOffset = Vector2.new(MousePos.X - WindowPos.X, MousePos.Y - WindowPos.Y)
			end
		end
		if not MouseDown then
			Window.Dragging = false
		end
		if Window.Dragging then
			local NewX = MousePos.X - Window.DragOffset.X
			local NewY = MousePos.Y - Window.DragOffset.Y
			local Dx, Dy = NewX - WindowPos.X, NewY - WindowPos.Y
			MoveWindow(Dx, Dy)
			UnderlineX = UnderlineX + Dx
			MenuBindCenterX = MenuBindCenterX + Dx
			MenuBindCenterY = MenuBindCenterY + Dy
			PickerX = PickerX + Dx
			PickerY = PickerY + Dy
			for Name in pairs(TabTargetX) do
				TabTargetX[Name] = TabTargetX[Name] + Dx
			end
			for _, T in ipairs(Toggles) do
				T.CenterX = T.CenterX + Dx
				T.CenterY = T.CenterY + Dy
			end
			for _, S in ipairs(Sliders) do
				S.TrackX = S.TrackX + Dx
				S.TrackY = S.TrackY + Dy
			end
		end
		Window.WasMouseDown = MouseDown

		if ListeningForMenuKey then
			for _, Vk in ipairs(ListenVkList) do
				local Down = iskeypressed(Vk)
				if Down and not WasKeyDown[Vk] then
					MenuKey = Vk
					CenterTextInBox(MenuBindText, ShortKeyNames[Vk] or ("K" .. Vk), MenuBindCenterX, MenuBindCenterY, 10)
					ListeningForMenuKey = false
				end
				WasKeyDown[Vk] = Down
			end
		else
			local Down = iskeypressed(MenuKey)
			if Down and not WasKeyDown[MenuKey] then
				MenuVisible = not MenuVisible
			end
			WasKeyDown[MenuKey] = Down
		end

		if Window.OnHeartbeat then Window.OnHeartbeat(Dt) end
	end)

	return setmetatable(Window, { __index = function(_, K) return TabHandles[K] end })
end

return PhobiaUI
