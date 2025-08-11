local _G = _G or {}
if not _G.planeconfig then _G.planeconfig = {
    superfarmer = false,
    autobuyspins = false,
    autospin = false,
    automachine = false,
    antiafk = true,
    performancemode = false,
    showoverlay = false,
    maxfps = 60,
    fpschanger = false,
    beforecash = 0,
    sessionstart = 0,
    farmingstarted = false
} end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "COMBO_WICK",
    SubTitle = "Di VateQ",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local MainTab = Window:AddTab({ Title = "Principale", Icon = "zap" })
local SettingsTab = Window:AddTab({ Title = "Impostazioni", Icon = "settings" })

local performanceGui = nil
local cashLabel = nil
local beforeLabel = nil
local timeLabel = nil
local toggleButton = nil

local function createPerformanceOverlay()
    if performanceGui then
        performanceGui:Destroy()
    end
    
    performanceGui = Instance.new("ScreenGui")
    performanceGui.Name = "PerformanceOverlay"
    performanceGui.IgnoreGuiInset = true
    performanceGui.ResetOnSpawn = false
    performanceGui.Parent = CoreGui
    
    local overlayFrame = Instance.new("Frame")
    overlayFrame.Name = "Overlay"
    overlayFrame.Size = UDim2.new(1, 0, 1, 0)
    overlayFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlayFrame.BorderSizePixel = 0
    overlayFrame.Visible = false
    overlayFrame.ZIndex = -1
    overlayFrame.Parent = performanceGui
    
    local infoFrame = Instance.new("Frame")
    infoFrame.Name = "InfoFrame"
    infoFrame.Size = UDim2.new(0, 320, 0, 140)
    infoFrame.Position = UDim2.new(0.5, -160, 0.5, -70)
    infoFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    infoFrame.ZIndex = 1
    infoFrame.Parent = overlayFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = infoFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 150, 255)
    stroke.Thickness = 2
    stroke.Parent = infoFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "TRACCIAMENTO DELLA SESSIONE"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.ZIndex = 2
    title.Parent = infoFrame
    
    beforeLabel = Instance.new("TextLabel")
    beforeLabel.Size = UDim2.new(1, 0, 0, 25)
    beforeLabel.Position = UDim2.new(0, 0, 0, 50)
    beforeLabel.BackgroundTransparency = 1
    beforeLabel.Text = "Before: $0"
    beforeLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    beforeLabel.TextSize = 14
    beforeLabel.Font = Enum.Font.Gotham
    beforeLabel.ZIndex = 2
    beforeLabel.Parent = infoFrame
    
    cashLabel = Instance.new("TextLabel")
    cashLabel.Size = UDim2.new(1, 0, 0, 25)
    cashLabel.Position = UDim2.new(0, 0, 0, 75)
    cashLabel.BackgroundTransparency = 1
    cashLabel.Text = "Current: $0"
    cashLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    cashLabel.TextSize = 14
    cashLabel.Font = Enum.Font.Gotham
    cashLabel.ZIndex = 2
    cashLabel.Parent = infoFrame
    
    timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(1, 0, 0, 25)
    timeLabel.Position = UDim2.new(0, 0, 0, 100)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = "Time: 0h 0m 0s"
    timeLabel.TextColor3 = Color3.fromRGB(150, 150, 255)
    timeLabel.TextSize = 14
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.ZIndex = 2
    timeLabel.Parent = infoFrame
    
    toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 120, 0, 40)
    toggleButton.Position = UDim2.new(0, 20, 0, 120)
    toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    toggleButton.Text = "Avviare sovrapposizione"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 14
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.ZIndex = 10
    toggleButton.Parent = performanceGui
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = toggleButton
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Color3.fromRGB(255, 100, 255)
    buttonStroke.Thickness = 2
    buttonStroke.Parent = toggleButton
    
    local function startRainbow()
        local colorSequence = {
            Color3.fromRGB(255, 0, 0),
            Color3.fromRGB(255, 127, 0),
            Color3.fromRGB(255, 255, 0),
            Color3.fromRGB(0, 255, 0),
            Color3.fromRGB(0, 0, 255),
            Color3.fromRGB(75, 0, 130),
            Color3.fromRGB(148, 0, 211),
        }
        
        local function animateColor(index)
            if not toggleButton.Parent then return end
            local nextIndex = index % #colorSequence + 1
            local tween = TweenService:Create(
                buttonStroke,
                TweenInfo.new(0.3, Enum.EasingStyle.Linear),
                {Color = colorSequence[nextIndex]}
            )
            tween:Play()
            tween.Completed:Connect(function()
                wait(0.1)
                animateColor(nextIndex)
            end)
        end
        animateColor(1)
    end
    
    startRainbow()
    
    local fluentToggleButton = Instance.new("TextButton")
    fluentToggleButton.Size = UDim2.new(0, 120, 0, 40)
    fluentToggleButton.Position = UDim2.new(0, 20, 0, 70)
    fluentToggleButton.BackgroundColor3 = Color3.fromRGB(40, 30, 50)
    fluentToggleButton.Text = "Nascondi Interfaccia"
    fluentToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    fluentToggleButton.TextSize = 14
    fluentToggleButton.Font = Enum.Font.GothamBold
    fluentToggleButton.ZIndex = 10
    fluentToggleButton.Parent = performanceGui
    
    local fluentButtonCorner = Instance.new("UICorner")
    fluentButtonCorner.CornerRadius = UDim.new(0, 8)
    fluentButtonCorner.Parent = fluentToggleButton
    
    local fluentButtonStroke = Instance.new("UIStroke")
    fluentButtonStroke.Color = Color3.fromRGB(100, 255, 100)
    fluentButtonStroke.Thickness = 2
    fluentButtonStroke.Parent = fluentToggleButton
    
    local fluentVisible = true
    fluentToggleButton.MouseButton1Click:Connect(function()
        fluentVisible = not fluentVisible
        Window.Root.Visible = fluentVisible
        fluentToggleButton.Text = fluentVisible and "Hide UI" or "Show UI"
    end)
    
    toggleButton.MouseButton1Click:Connect(function()
        overlayFrame.Visible = not overlayFrame.Visible
        _G.planeconfig.showoverlay = overlayFrame.Visible
    end)
    
    return overlayFrame, performanceGui
end

local function updateCashDisplay()
    if not cashLabel then return end
    
    local currentCash = LocalPlayer.leaderstats.Cash.Value
    local sessionTime = tick() - _G.planeconfig.sessionstart
    
    local hours = math.floor(sessionTime / 3600)
    local minutes = math.floor((sessionTime % 3600) / 60)
    local seconds = math.floor(sessionTime % 60)
    
    beforeLabel.Text = string.format("Before: $%s", tostring(_G.planeconfig.beforecash))
    cashLabel.Text = string.format("Current: $%s", tostring(currentCash))
    timeLabel.Text = string.format("Time: %dh %dm %ds", hours, minutes, seconds)
end

local SuperFarmerToggle = MainTab:AddToggle("SuperFarmer", {
    Title = "Infinite Cash",
    Default = _G.planeconfig.superfarmer
})

SuperFarmerToggle:OnChanged(function(Value)
    _G.planeconfig.superfarmer = Value
    CoreGui.PurchasePromptApp.Enabled = not Value
    
    if Value and not _G.planeconfig.farmingstarted then
        _G.planeconfig.beforecash = LocalPlayer.leaderstats.Cash.Value
        _G.planeconfig.sessionstart = tick()
        _G.planeconfig.farmingstarted = true
        
        _G.planeconfig.performancemode = true
        if performanceGui then
            performanceGui.Overlay.Visible = true
        end
    end
    
    if Value then
        for i = 1, 300 do
            task.spawn(function()
                while _G.planeconfig.superfarmer and task.wait() do
                    pcall(function()
                        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("EventEvents"):WaitForChild("SpawnEvilEye"):InvokeServer()
                        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("EventEvents"):WaitForChild("KillEvilEye"):InvokeServer()
                    end)
                end
            end)
        end
        
        for i = 1, 80 do
            task.spawn(function()
                while _G.planeconfig.superfarmer and task.wait() do
                    pcall(function()
                        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SpinEvents"):WaitForChild("PurchaseSpin"):InvokeServer()
                        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SpinEvents"):WaitForChild("PerformSpin"):InvokeServer()
                    end)
                end
            end)
        end
    end
end)

local AutoBuySpinsToggle = MainTab:AddToggle("AutoBuySpins", {
    Title = "Giri Acquisto automatico",
    Default = _G.planeconfig.autobuyspins
})

AutoBuySpinsToggle:OnChanged(function(Value)
    _G.planeconfig.autobuyspins = Value
    
    if Value then
        task.spawn(function()
            while _G.planeconfig.autobuyspins and task.wait(0.1) do
                pcall(function()
                    if LocalPlayer.Important.RedMoons.Value >= 10 then
                        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SpinEvents"):WaitForChild("PurchaseSpin"):InvokeServer()
                    end
                end)
            end
        end)
    end
end)

local AutoSpinToggle = MainTab:AddToggle("AutoSpin", {
    Title = "Auto Spin",
    Default = _G.planeconfig.autospin
})

AutoSpinToggle:OnChanged(function(Value)
    _G.planeconfig.autospin = Value
    
    if Value then
        task.spawn(function()
            while _G.planeconfig.autospin and task.wait(0.1) do
                pcall(function()
                    if LocalPlayer.replicated_data.available_spins.Value >= 1 then
                        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SpinEvents"):WaitForChild("PerformSpin"):InvokeServer()
                    end
                end)
            end
        end)
    end
end)

local AutoMachineToggle = MainTab:AddToggle("AutoMachine", {
    Title = "Sblocco automatico macchina",
    Default = _G.planeconfig.automachine
})

AutoMachineToggle:OnChanged(function(Value)
    _G.planeconfig.automachine = Value
    
    if Value then
        task.spawn(function()
            while _G.planeconfig.automachine and not LocalPlayer.Important.Eclipse.Value and task.wait(1) do
                pcall(function()
                    if LocalPlayer.Important.Eclipse.Value ~= false then
                        ReplicatedStorage.Remotes.SpectialEvents.MachineActivated:FireServer()
                    end
                end)
            end
        end)
    end
end)

local FillScreenToggle = SettingsTab:AddToggle("FillScreen", {
    Title = "Modalità Prestazioni",
    Default = _G.planeconfig.performancemode
})

FillScreenToggle:OnChanged(function(Value)
    _G.planeconfig.performancemode = Value
    
    if Value and not performanceGui then
        createPerformanceOverlay()
    elseif performanceGui then
        performanceGui.Overlay.Visible = Value
    end
end)

local FPSToggle = SettingsTab:AddToggle("FPSChanger", {
    Title = "Limitatore fps",
    Default = _G.planeconfig.fpschanger
})

local FPSSlider = SettingsTab:AddSlider("FPSLimit", {
    Title = "Limite FPS",
    Default = _G.planeconfig.maxfps,
    Min = 4,
    Max = 1024,
    Rounding = 0
})

FPSSlider:OnChanged(function(Value)
    _G.planeconfig.maxfps = Value
    if setfpscap and _G.planeconfig.fpschanger then
        if Value == 1024 then
            setfpscap(0)
        else
            setfpscap(Value)
        end
    end
end)

FPSToggle:OnChanged(function(Value)
    _G.planeconfig.fpschanger = Value
    if Value and setfpscap then
        if _G.planeconfig.maxfps == 1024 then
            setfpscap(0)
        else
            setfpscap(_G.planeconfig.maxfps)
        end
    end
end)

local AntiAFKToggle = SettingsTab:AddToggle("AntiAFK", {
    Title = "Anti AFK",
    Default = _G.planeconfig.antiafk
})

AntiAFKToggle:OnChanged(function(Value)
    _G.planeconfig.antiafk = Value
end)

SettingsTab:AddButton({
    Title = "Reimposta le statistiche de...",
    Callback = function()
        _G.planeconfig.beforecash = LocalPlayer.leaderstats.Cash.Value
        _G.planeconfig.sessionstart = tick()
        _G.planeconfig.farmingstarted = false
        
        Fluent:Notify({
            Title = "Reset della sessione",
            Content = "Il monitoraggio del contante è stato ripristinato!",
            Duration = 3
        })
    end
})

LocalPlayer.Idled:Connect(function()
    if _G.planeconfig.antiafk then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

if not performanceGui then
    createPerformanceOverlay()
end

if _G.planeconfig.beforecash == 0 then
    _G.planeconfig.beforecash = LocalPlayer.leaderstats.Cash.Value
    _G.planeconfig.sessionstart = tick()
end

task.spawn(function()
    while task.wait(0.5) do
        if cashLabel then
            updateCashDisplay()
        end
    end
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("PlaneScript")
SaveManager:SetFolder("PlaneScript/configs")

InterfaceManager:BuildInterfaceSection(SettingsTab)
SaveManager:BuildConfigSection(SettingsTab)

Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()

Fluent:Notify({
    Title = "Script caricato!",
    Content = "Tutte le funzionalità sono pronte per l'uso! Da W a VateQ",
    Duration = 5
})