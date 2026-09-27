-- ======================================================
-- YAT | by pivble50
-- 6 Abas | 10 Funções
-- Fluent UI + Troca para Orion
-- ======================================================

if _G.YatRunning then pcall(function() _G.YatDestroy() end) end
_G.YatRunning = true

local CurrentLibrary = nil
local CurrentLibraryName = "Fluent"
local IsBuilding = false

local function DestroyCurrentUI()
    if CurrentLibrary then
        pcall(function()
            if CurrentLibraryName == "Fluent" then
                if CurrentLibrary.Window then
                    CurrentLibrary.Unloaded = true
                    if CurrentLibrary.GUI then CurrentLibrary.GUI:Destroy() end
                end
            elseif CurrentLibraryName == "Orion" then
                if CurrentLibrary.Destroy then CurrentLibrary:Destroy() end
            end
        end)
        CurrentLibrary = nil
    end
end
_G.YatDestroy = function() DestroyCurrentUI(); _G.YatRunning = false end

-- ========== DETECÇÃO DE PAPEL ==========
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function GetPlayerRole(player)
    if not player or not player.Character then return "Desconhecido" end
    local tool = player.Character:FindFirstChildOfClass("Tool")
    if tool then
        local n = tool.Name:lower()
        if n:find("knife") then return "Assassino" end
        if n:find("gun") or n:find("revolver") then return "Xerife" end
    end
    if player.Backpack then
        for _, item in pairs(player.Backpack:GetChildren()) do
            if item:IsA("Tool") then
                local n = item.Name:lower()
                if n:find("knife") then return "Assassino" end
                if n:find("gun") or n:find("revolver") then return "Xerife" end
            end
        end
    end
    for _, pasta in pairs({player.Character, player}) do
        if pasta then
            local extra = pasta:FindFirstChild("Extra")
            if extra then
                for _, item in pairs(extra:GetChildren()) do
                    local n = item.Name:lower()
                    if n:find("knife") then return "Assassino" end
                    if n:find("gun") or n:find("revolver") then return "Xerife" end
                end
            end
        end
    end
    return "Inocente"
end

-- ========== ESP ==========
local ESP_Highlights = {}
local ESP_Ativo = false

local function GetRoleColor(role)
    if role == "Assassino" then return Color3.fromRGB(255, 0, 0)
    elseif role == "Xerife" then return Color3.fromRGB(0, 100, 255)
    elseif role == "Inocente" then return Color3.fromRGB(0, 255, 0) end
    return Color3.fromRGB(255, 255, 255)
end

local function CreateESP(player)
    if player == LocalPlayer or not player.Character then return end
    local old = ESP_Highlights[player]
    if old and old.Parent then old:Destroy() end
    local color = GetRoleColor(GetPlayerRole(player))
    local h = Instance.new("Highlight")
    h.Name = "Yat_ESP"
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = 0.7
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Adornee = player.Character
    h.Parent = player.Character
    ESP_Highlights[player] = h
end

local function RemoveESP(player)
    local h = ESP_Highlights[player]
    if h then h:Destroy(); ESP_Highlights[player] = nil end
end

local function AtivarESP()
    ESP_Ativo = true
    for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
end

local function DesativarESP()
    ESP_Ativo = false
    for p, _ in pairs(ESP_Highlights) do RemoveESP(p) end
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if ESP_Ativo then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local ex = ESP_Highlights[p]
                    if not ex or ex.Parent ~= p.Character then
                        CreateESP(p)
                    else
                        local c = GetRoleColor(GetPlayerRole(p))
                        if ex.FillColor ~= c then ex.FillColor = c; ex.OutlineColor = c end
                    end
                end
            end
        end
    end
end)

-- ========== VARIÁVEIS DE ESTADO ==========
local AutoPickGun_Ativo = false
local AutoPickGun_Processando = false
local ArmaJaPega = {}
local SpeedHack_Ativo, SpeedValor = false, 16
local JumpHack_Ativo, JumpValor = false, 50
local Fullbright_Ativo = false
local NoClip_Ativo = false
local Invisivel_Ativo = false

local function PertenceAJogadorVivo(obj)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            if obj:IsDescendantOf(plr.Character) then return true end
            if plr.Backpack and obj:IsDescendantOf(plr.Backpack) then return true end
        end
    end
    return false
end

-- Auto Pick Gun
task.spawn(function()
    while true do
        task.wait(0.2)
        if AutoPickGun_Ativo and not AutoPickGun_Processando and LocalPlayer.Character then
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Tool") then
                        local n = obj.Name:lower()
                        if (n:find("gun") or n:find("revolver") or n:find("pistol")) and obj:FindFirstChild("Handle") then
                            if not PertenceAJogadorVivo(obj) and not ArmaJaPega[obj] then
                                AutoPickGun_Processando = true
                                ArmaJaPega[obj] = true
                                local pos = root.CFrame
                                pcall(function() root.CFrame = obj.Handle.CFrame * CFrame.new(0, 2, 0) end)
                                task.wait(0.4)
                                pcall(function() if root and root.Parent then root.CFrame = pos end end)
                                AutoPickGun_Processando = false
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Speed / Jump / Fullbright / NoClip / Invisível
task.spawn(function()
    while true do
        task.wait(0.1)
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                if SpeedHack_Ativo then hum.WalkSpeed = SpeedValor end
                if JumpHack_Ativo then hum.UseJumpPower = true; hum.JumpPower = JumpValor end
            end
            if NoClip_Ativo then
                for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
            if Invisivel_Ativo then
                for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.Transparency = 1; p.CanCollide = false end
                end
            end
        end
        if Fullbright_Ativo then
            game:GetService("Lighting").Ambient = Color3.fromRGB(255, 255, 255)
            game:GetService("Lighting").Brightness = 3
            game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        end
    end
end)

-- ========== FLUENT UI ==========
local BuildFluentUI

BuildFluentUI = function()
    if IsBuilding then return end
    IsBuilding = true
    DestroyCurrentUI()
    task.wait(0.3)

    local ok, Library = pcall(function()
        return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    end)
    if not ok or not Library then IsBuilding = false; return end

    CurrentLibrary = Library
    CurrentLibraryName = "Fluent"

    local Window = Library:CreateWindow({
        Title = "Yat",
        SubTitle = "by pivble50",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = false,
        Theme = "Light",
        MinimizeKey = Enum.KeyCode.LeftControl
    })

    local Tabs = {
        Main = Window:AddTab({ Title = "Main", Icon = "home" }),
        ESP = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
        Actions = Window:AddTab({ Title = "Ações", Icon = "zap" }),
        Player = Window:AddTab({ Title = "Player", Icon = "user" }),
        Extras = Window:AddTab({ Title = "Extras", Icon = "star" }),
        Config = Window:AddTab({ Title = "Config", Icon = "settings" })
    }

    -- ===== ABA MAIN =====
    Tabs.Main:AddParagraph({ Title = "Bem-vindo ao Yat!", Content = "Script feito por pivble50." })
    Tabs.Main:AddButton({
        Title = "Sobre o Yat",
        Callback = function() Library:Notify({ Title = "Yat", Content = "by pivble50 | Versão 1.0", Duration = 5 }) end
    })

    -- ===== ABA VISUALS =====
    Tabs.ESP:AddToggle("ESP_Toggle", { Title = "Ativar ESP", Default = false }):OnChanged(function(v)
        if v then AtivarESP() else DesativarESP() end
    end)
    Tabs.ESP:AddParagraph({ Title = "Legenda", Content = "🔴 Assassino | 🔵 Xerife | 🟢 Inocente" })

    -- ===== ABA AÇÕES =====
    Tabs.Actions:AddParagraph({ Title = "⚡ Ações Rápidas", Content = "Funções principais do script." })
    Tabs.Actions:AddButton({
        Title = "⚡ Mostrar Papéis no Chat",
        Callback = function()
            for _, p in pairs(Players:GetPlayers()) do
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(
                    p.Name .. " é: " .. GetPlayerRole(p), "All")
                task.wait(0.1)
            end
        end
    })
    Tabs.Actions:AddButton({
        Title = "🎯 Teleportar para o Xerife",
        Callback = function()
            for _, p in pairs(Players:GetPlayers()) do
                if GetPlayerRole(p) == "Xerife" and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, 2) end
                    break
                end
            end
        end
    })
    Tabs.Actions:AddToggle("AutoPickGun_Toggle", {
        Title = "🔫 Auto Pick Gun (Beta)",
        Description = "Pega a arma quando o Xerife morre.",
        Default = false
    }):OnChanged(function(v) AutoPickGun_Ativo = v end)

    -- ===== ABA PLAYER =====
    Tabs.Player:AddToggle("SpeedHack_Toggle", { Title = "Speed Hack", Default = false }):OnChanged(function(v) SpeedHack_Ativo = v end)
    Tabs.Player:AddSlider("SpeedSlider", { Title = "Velocidade", Default = 16, Min = 16, Max = 200, Rounding = 1 }):OnChanged(function(v) SpeedValor = v end)
    Tabs.Player:AddToggle("JumpHack_Toggle", { Title = "Jump Hack", Default = false }):OnChanged(function(v) JumpHack_Ativo = v end)
    Tabs.Player:AddSlider("JumpSlider", { Title = "Força do Pulo", Default = 50, Min = 50, Max = 300, Rounding = 1 }):OnChanged(function(v) JumpValor = v end)
    Tabs.Player:AddToggle("NoClip_Toggle", { Title = "No Clip", Default = false }):OnChanged(function(v) NoClip_Ativo = v end)
    Tabs.Player:AddToggle("Invisivel_Toggle", { Title = "Invisível", Default = false }):OnChanged(function(v) Invisivel_Ativo = v end)

    -- ===== ABA EXTRAS =====
    Tabs.Extras:AddButton({
        Title = "💀 Kill All",
        Description = "Mata todos os jogadores do servidor.",
        Callback = function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Health = 0 end
                end
            end
            Library:Notify({ Title = "💀 Kill All", Content = "Todos os jogadores foram eliminados.", Duration = 3 })
        end
    })
    Tabs.Extras:AddToggle("Fullbright_Toggle", { Title = "Fullbright", Default = false }):OnChanged(function(v)
        Fullbright_Ativo = v
        if not v then
            game:GetService("Lighting").Ambient = Color3.fromRGB(70, 70, 70)
            game:GetService("Lighting").Brightness = 2
            game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end
    end)
    Tabs.Extras:AddButton({
        Title = "Resetar Personagem",
        Callback = function() if LocalPlayer.Character then LocalPlayer.Character:BreakJoints() end end
    })
    Tabs.Extras:AddButton({
        Title = "Rejoin no Servidor",
        Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end
    })
    Tabs.Extras:AddButton({
        Title = "Listar Jogadores",
        Callback = function()
            local lista = ""
            for _, p in pairs(Players:GetPlayers()) do
                lista = lista .. p.Name .. " (" .. GetPlayerRole(p) .. ")\n"
            end
            Library:Notify({ Title = "Jogadores", Content = lista, Duration = 8 })
        end
    })

    -- ===== ABA CONFIG =====
    Tabs.Config:AddParagraph({ Title = "Biblioteca de UI", Content = "Troque entre Fluent e Orion." })
    local LibDropdown = Tabs.Config:AddDropdown("LibDropdown", {
        Title = "Library",
        Values = {"Fluent", "Orion"},
        Default = "Fluent"
    })
    LibDropdown:OnChanged(function(v)
        if IsBuilding or v == CurrentLibraryName then return end
        if v == "Orion" then task.wait(0.3); BuildOrionUI() end
    end)

    local Themes = {"Light", "Dark", "Darker", "Aqua", "Amethyst", "Rose"}
    Tabs.Config:AddDropdown("ThemeDropdown", { Title = "Tema", Values = Themes, Default = "Light" }):OnChanged(function(v)
        Library:SetTheme(v)
    end)

    Library:Notify({ Title = "Yat Carregado!", Content = "by pivble50 | 6 abas | 10 funções.", Duration = 5 })
    task.wait(0.3)
    IsBuilding = false
end

-- ========== ORION UI ==========
function BuildOrionUI()
    if IsBuilding then return end
    IsBuilding = true
    DestroyCurrentUI()
    task.wait(0.5)

    local ok, OrionLib = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Qanuir/orion-ui/refs/heads/main/source.lua"))()
    end)
    if not ok or not OrionLib then IsBuilding = false; BuildFluentUI(); return end

    CurrentLibrary = OrionLib
    CurrentLibraryName = "Orion"

    local Window = OrionLib:MakeWindow({ Name = "Yat | by pivble50", HidePremium = false, SaveConfig = false, ConfigFolder = "YatOrion" })

    local MainTab = Window:MakeTab({ Name = "Main", Icon = "rbxassetid://4483345998" })
    local ESPTab = Window:MakeTab({ Name = "Visuals", Icon = "rbxassetid://4483345998" })
    local ActionsTab = Window:MakeTab({ Name = "Ações", Icon = "rbxassetid://4483345998" })
    local PlayerTab = Window:MakeTab({ Name = "Player", Icon = "rbxassetid://4483345998" })
    local ExtrasTab = Window:MakeTab({ Name = "Extras", Icon = "rbxassetid://4483345998" })
    local ConfigTab = Window:MakeTab({ Name = "Config", Icon = "rbxassetid://4483345998" })

    -- MAIN
    MainTab:AddParagraph("Bem-vindo ao Yat!", "Script feito por pivble50.")
    MainTab:AddButton({ Name = "Sobre o Yat", Callback = function() OrionLib:MakeNotification({ Name = "Yat", Content = "by pivble50 | Versão 1.0", Time = 5 }) end })

    -- VISUALS
    ESPTab:AddToggle({ Name = "Ativar ESP", Default = false, Callback = function(v) if v then AtivarESP() else DesativarESP() end end })
    ESPTab:AddParagraph("Legenda", "🔴 Assassino | 🔵 Xerife | 🟢 Inocente")

    -- AÇÕES
    ActionsTab:AddParagraph("⚡ Ações Rápidas", "Funções principais do script.")
    ActionsTab:AddButton({ Name = "⚡ Mostrar Papéis no Chat", Callback = function() for _, p in pairs(Players:GetPlayers()) do game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(p.Name .. " é: " .. GetPlayerRole(p), "All"); task.wait(0.1) end end })
    ActionsTab:AddButton({ Name = "🎯 Teleportar para o Xerife", Callback = function() for _, p in pairs(Players:GetPlayers()) do if GetPlayerRole(p) == "Xerife" and p.Character then local hrp = p.Character:FindFirstChild("HumanoidRootPart"); if hrp then LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, 2) end break end end end })
    ActionsTab:AddToggle({ Name = "🔫 Auto Pick Gun (Beta)", Description = "Pega arma quando Xerife morre.", Default = false, Callback = function(v) AutoPickGun_Ativo = v end })

    -- PLAYER
    PlayerTab:AddToggle({ Name = "Speed Hack", Default = false, Callback = function(v) SpeedHack_Ativo = v end })
    PlayerTab:AddSlider({ Name = "Velocidade", Min = 16, Max = 200, Default = 16, Increment = 1, Callback = function(v) SpeedValor = v end })
    PlayerTab:AddToggle({ Name = "Jump Hack", Default = false, Callback = function(v) JumpHack_Ativo = v end })
    PlayerTab:AddSlider({ Name = "Força do Pulo", Min = 50, Max = 300, Default = 50, Increment = 1, Callback = function(v) JumpValor = v end })
    PlayerTab:AddToggle({ Name = "No Clip", Default = false, Callback = function(v) NoClip_Ativo = v end })
    PlayerTab:AddToggle({ Name = "Invisível", Default = false, Callback = function(v) Invisivel_Ativo = v end })

    -- EXTRAS
    ExtrasTab:AddButton({
        Name = "💀 Kill All",
        Description = "Mata todos os jogadores do servidor.",
        Callback = function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Health = 0 end
                end
            end
            OrionLib:MakeNotification({ Name = "💀 Kill All", Content = "Todos eliminados.", Time = 3 })
        end
    })
    ExtrasTab:AddToggle({ Name = "Fullbright", Default = false, Callback = function(v) Fullbright_Ativo = v; if not v then game:GetService("Lighting").Ambient = Color3.fromRGB(70, 70, 70); game:GetService("Lighting").Brightness = 2; game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128) end end })
    ExtrasTab:AddButton({ Name = "Resetar Personagem", Callback = function() if LocalPlayer.Character then LocalPlayer.Character:BreakJoints() end end })
    ExtrasTab:AddButton({ Name = "Rejoin no Servidor", Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end })
    ExtrasTab:AddButton({ Name = "Listar Jogadores", Callback = function() local lista = ""; for _, p in pairs(Players:GetPlayers()) do lista = lista .. p.Name .. " (" .. GetPlayerRole(p) .. ")\n" end; OrionLib:MakeNotification({ Name = "Jogadores", Content = lista, Time = 8 }) end })

    -- CONFIG
    ConfigTab:AddParagraph("Biblioteca de UI", "Troque entre Fluent e Orion.")
    ConfigTab:AddDropdown({ Name = "Library", Options = {"Fluent", "Orion"}, Default = "Orion", Callback = function(v) if IsBuilding or v == CurrentLibraryName then return end; if v == "Fluent" then task.wait(0.3); BuildFluentUI() end end })

    OrionLib:Init()
    OrionLib:MakeNotification({ Name = "Yat Carregado!", Content = "by pivble50 | 6 abas | 10 funções.", Time = 5 })
    task.wait(0.3)
    IsBuilding = false
end

BuildFluentUI()
