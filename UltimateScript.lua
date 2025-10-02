--// UNIVERSAL HUB v666.6 😈🔥
-- Fusion Totale : HUB (Player/Combat/Visual/etc.) + Clavier Android Personnalisable
-- AdminMan Corp 2024

----------------------------------------------------
-- Services
----------------------------------------------------
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

----------------------------------------------------
-- GUI BASE
----------------------------------------------------
local ScreenGui = Instance.new("ScreenGui", gethui and gethui() or game.CoreGui)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 520, 0, 560)
MainFrame.Position = UDim2.new(0.28,0,0.15,0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,30)
MainFrame.Active, MainFrame.Draggable = true,true

local corner = Instance.new("UICorner", MainFrame) corner.CornerRadius = UDim.new(0,12)
local stroke = Instance.new("UIStroke", MainFrame) stroke.Color = Color3.fromRGB(90,110,255)

----------------------------------------------------
-- Onglets
----------------------------------------------------
local Tabs = Instance.new("Frame", MainFrame)
Tabs.Size = UDim2.new(0,110,1,0)
Tabs.BackgroundColor3 = Color3.fromRGB(20,20,25)

local Title = Instance.new("TextLabel", Tabs)
Title.Size = UDim2.new(1,0,0,40)
Title.Text = "🌌 HUB v666.6"
Title.TextColor3 = Color3.fromRGB(200,200,255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true

local tl = Instance.new("UIListLayout", Tabs) tl.Padding = UDim.new(0,5)

local Pages = Instance.new("Frame", MainFrame)
Pages.Size = UDim2.new(1,-110,1,0)
Pages.Position = UDim2.new(0,110,0,0)
Pages.BackgroundTransparency = 1

local currentPage
local function makeTab(name)
    local btn = Instance.new("TextButton", Tabs)
    btn.Size = UDim2.new(1,0,0,30)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(35,35,40)
    btn.TextColor3 = Color3.fromRGB(220,220,255)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    local page = Instance.new("ScrollingFrame", Pages)
    page.Size = UDim2.new(1,0,1,0) page.Visible = false page.CanvasSize = UDim2.new(0,0,35,0)
    Instance.new("UIListLayout", page).Padding = UDim.new(0,6)
    btn.MouseButton1Click:Connect(function() if currentPage then currentPage.Visible=false end currentPage=page page.Visible=true end)
    return page
end

----------------------------------------------------
-- Onglets : (Player / Combat / Visual / World / Utility / Fun / Farm / Keyboard)
----------------------------------------------------
local playerPage = makeTab("👤 Player")
local combatPage = makeTab("⚔️ Combat")
local visualPage = makeTab("👁️ Visuals")
local worldPage  = makeTab("🌍 World")
local utilPage   = makeTab("🛠️ Utility")
local funPage    = makeTab("🤡 Fun")
local farmPage   = makeTab("🌾 Farms")
local keyPage    = makeTab("⌨️ Keyboard")

----------------------------------------------------
-- Fonction pour les boutons
----------------------------------------------------
local function makeBtn(parent,text,callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.95,0,0,32)
    b.Text = text
    b.Font = Enum.Font.GothamBold b.TextScaled = true
    b.BackgroundColor3 = Color3.fromRGB(40,40,50)
    b.TextColor3 = Color3.fromRGB(230,230,255)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    b.MouseButton1Click:Connect(callback)
end

----------------------------------------------------
-- 👤 PLAYER TAB (fusion complète)
----------------------------------------------------
-- Toutes les features Player (Speed / Jump / Fly / TP / NoClip / Spin / Resizer etc.)
makeBtn(playerPage,"Toggle Speed 100",function()
    getgenv().SpeedHack = not getgenv().SpeedHack
    local hum = Player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = getgenv().SpeedHack and 100 or 16 end
end)

makeBtn(playerPage,"Super Jump 150",function()
    getgenv().HighJump = not getgenv().HighJump
    local hum = Player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = getgenv().HighJump and 150 or 50 end
end)

makeBtn(playerPage,"Infinite Jump",function()
    getgenv().InfJump = not getgenv().InfJump
    UIS.JumpRequest:Connect(function()
        if getgenv().InfJump and Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
            Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end)
end)

makeBtn(playerPage,"NoClip",function()
    getgenv().Noclip = not getgenv().Noclip
    RunService.Stepped:Connect(function()
        if getgenv().Noclip and Player.Character then
            for _,v in pairs(Player.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide=false end
            end
        end
    end)
end)

makeBtn(playerPage,"Fly [E]",function()
    local cam = workspace.CurrentCamera
    local hrp = Player.Character:WaitForChild("HumanoidRootPart")
    local flying=false
    UIS.InputBegan:Connect(function(i) if i.KeyCode==Enum.KeyCode.E then flying = not flying end end)
    RunService.RenderStepped:Connect(function()
        if flying then
            local dir = cam.CFrame.LookVector
            hrp.Velocity = dir*60 + Vector3.new(0,40,0)
        end
    end)
end)

makeBtn(playerPage,"Fake GodMode (Auto-Heal)",function()
    getgenv().AutoHeal = not getgenv().AutoHeal
    RunService.Heartbeat:Connect(function()
        if getgenv().AutoHeal and Player.Character:FindFirstChild("Humanoid") then
            local h = Player.Character.Humanoid
            if h.Health < h.MaxHealth then h.Health = h.MaxHealth end
        end
    end)
end)

makeBtn(playerPage,"Sit Anywhere",function()
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        Player.Character:FindFirstChildOfClass("Humanoid").Sit = not Player.Character.Humanoid.Sit
    end
end)

makeBtn(playerPage,"TP To Mouse",function()
    local mouse = Player:GetMouse()
    if mouse.Hit then Player.Character:MoveTo(mouse.Hit.p + Vector3.new(0,3,0)) end
end)

makeBtn(playerPage,"TP +20↑",function()
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.CFrame = Player.Character.HumanoidRootPart.CFrame + Vector3.new(0,20,0)
    end
end)

makeBtn(playerPage,"SpinBot",function()
    getgenv().spinbot = not getgenv().spinbot
    RunService.RenderStepped:Connect(function()
        if getgenv().spinbot and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0,math.rad(25),0)
        end
    end)
end)

makeBtn(playerPage,"Low Gravity (50)",function() workspace.Gravity = 50 end)
makeBtn(playerPage,"Reset Gravity (196)",function() workspace.Gravity = 196 end)

makeBtn(playerPage,"Walk On Water",function()
    local part = Instance.new("Part",workspace)
    part.Anchored=true part.Position=Vector3.new(0,1,0)
    part.Size=Vector3.new(900,1,900) part.Transparency=.7 part.Name="WaterWalk"
end)

makeBtn(playerPage,"Resize Small",function()
    local hum = Player.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum:FindFirstChild("BodyHeightScale") then
        hum.BodyHeightScale.Value = 0.5 hum.BodyWidthScale.Value=0.5 hum.BodyDepthScale.Value=0.5
    end
end)

makeBtn(playerPage,"Resize Giant",function()
    local hum = Player.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum:FindFirstChild("BodyHeightScale") then
        hum.BodyHeightScale.Value=2 hum.BodyWidthScale.Value=2 hum.BodyDepthScale.Value=2
    end
end)

makeBtn(playerPage,"Dance Spin",function()
    getgenv().dancespin = not getgenv().dancespin
    RunService.RenderStepped:Connect(function()
        if getgenv().dancespin and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0,math.rad(8),0)
        end
    end)
end)

makeBtn(playerPage,"Fake Lag",function()
    getgenv().fakelag = not getgenv().fakelag
    RunService.Heartbeat:Connect(function()
        if getgenv().fakelag and Player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = Player.Character.HumanoidRootPart
            hrp.Anchored = not hrp.Anchored
            task.wait(0.2)
        end
    end)
end)

makeBtn(playerPage,"Rejoin Server",function()
    game:GetService("TeleportService"):Teleport(game.PlaceId,Player)
end)

makeBtn(playerPage,"Server Hop",function()
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    for _,s in pairs(servers.data) do
        if s.playing < s.maxPlayers then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id, Player)
            break
        end
    end
end)

----------------------------------------------------
-- 🎹 KEYBOARD (fusionné avec auto-save config)
----------------------------------------------------
local SaveName = "MobileKeyboard_Config_v666"
local config = getgenv()[SaveName] or {}
local defaults = {
    ["Btn1"]=Enum.KeyCode.W, ["Btn2"]=Enum.KeyCode.A, ["Btn3"]=Enum.KeyCode.S,
    ["Btn4"]=Enum.KeyCode.D, ["Btn5"]=Enum.KeyCode.Space,
    ["Btn6"]=Enum.KeyCode.Q, ["Btn7"]=Enum.KeyCode.E, ["Btn8"]=Enum.KeyCode.LeftShift,
    ["Btn9"]=Enum.KeyCode.LeftControl, ["Btn10"]=Enum.KeyCode.F
} for i,v in pairs(defaults) do if not config[i] then config[i]=v end end

local function SaveConfig() getgenv()[SaveName] = config end

local KeyFrame = Instance.new("Frame", keyPage)
KeyFrame.Size = UDim2.new(1,-20,0,250) KeyFrame.Position = UDim2.new(0,10,0,10)
KeyFrame.BackgroundColor3 = Color3.fromRGB(15,15,20)
Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0,10)
local layout = Instance.new("UIGridLayout", KeyFrame)
layout.CellSize = UDim2.new(0,55,0,45) layout.FillDirectionMaxCells = 5
layout.CellPadding = UDim2.new(0,5,0,5)

local function makeCustomButton(name)
    local btn = Instance.new("TextButton", KeyFrame)
    btn.Name = name btn.Text = tostring(config[name].Name)
    btn.Font = Enum.Font.GothamBold btn.TextScaled = true
    btn.BackgroundColor3=Color3.fromRGB(40,40,50) btn.TextColor3=Color3.fromRGB(220,220,255)
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
    btn.MouseButton1Click:Connect(function()
        local bind = config[name] if bind then VIM:SendKeyEvent(true, bind, false, game) task.wait(0.12) VIM:SendKeyEvent(false, bind, false, game) end
    end)
    -- Rebind (PC: clic droit / Mobile: long press)
    btn.MouseButton2Click:Connect(function()
        btn.Text="..." local conn; conn=UIS.InputBegan:Connect(function(input,p)
            if not p and input.UserInputType==Enum.UserInputType.Keyboard then config[name]=input.KeyCode btn.Text=tostring(input.KeyCode.Name) SaveConfig() conn:Disconnect() end end)
    end)
end
for i=1,10 do makeCustomButton("Btn"..i) end
----------------------------------------------------
-- ⚔️ COMBAT TAB
----------------------------------------------------

-- Highlight ESP simple ennemi
local function highlightEnemy(plr)
    if plr.Character and not plr.Character:FindFirstChild("ESP_Highlight") then
        local hl = Instance.new("Highlight", plr.Character)
        hl.Name = "ESP_Highlight"
        hl.FillColor = Color3.fromRGB(255,0,0)
        hl.OutlineColor = Color3.fromRGB(255,255,0)
        hl.FillTransparency = 0.5
    end
end

makeBtn(combatPage,"ESP Enemies",function()
    for _,p in pairs(Players:GetPlayers()) do
        if p~=Player then highlightEnemy(p) end
    end
    Players.PlayerAdded:Connect(function(p) if p~=Player then highlightEnemy(p) end end)
end)

-- KillAura
makeBtn(combatPage,"KillAura (Loop)",function()
    getgenv().killaura = not getgenv().killaura
    RunService.Heartbeat:Connect(function()
        if getgenv().killaura and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            for _,p in pairs(Players:GetPlayers()) do
                if p~=Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (p.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).magnitude
                    if dist < 15 then
                        local tool = Player.Character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                    end
                end
            end
        end
    end)
end)

-- Silent Aim
makeBtn(combatPage,"Silent Aim",function()
    getgenv().silentaim = not getgenv().silentaim
    local mt = getrawmetatable(game)
    setreadonly(mt,false)
    local old = mt.__namecall
    mt.__namecall = function(self,...)
        local args = {...}
        if getgenv().silentaim and tostring(self)=="HitPart" or tostring(self)=="Ray" then
            local closestTarget
            local cam = workspace.CurrentCamera
            local shortestDist = 9999
            for _,p in pairs(Players:GetPlayers()) do
                if p~=Player and p.Character and p.Character:FindFirstChild("Head") then
                    local Pos = cam:WorldToViewportPoint(p.Character.Head.Position)
                    local dist = (Vector2.new(Pos.X,Pos.Y)-UIS:GetMouseLocation()).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist; closestTarget=p
                    end
                end
            end
            if closestTarget then
                args[2]=closestTarget.Character.Head
            end
        end
        return old(self,unpack(args))
    end
end)

-- Aimbot Lock
makeBtn(combatPage,"Aimbot Lock [Q]",function()
    getgenv().aimLock = false
    UIS.InputBegan:Connect(function(i) if i.KeyCode==Enum.KeyCode.Q then getgenv().aimLock = not getgenv().aimLock end end)
    RunService.RenderStepped:Connect(function()
        if getgenv().aimLock then
            local closest
            local shortestDist = 9999
            local cam = workspace.CurrentCamera
            for _,p in pairs(Players:GetPlayers()) do
                if p~=Player and p.Character and p.Character:FindFirstChild("Head") then
                    local Pos = cam:WorldToViewportPoint(p.Character.Head.Position)
                    local dist=(Vector2.new(Pos.X,Pos.Y)-UIS:GetMouseLocation()).Magnitude
                    if dist < shortestDist then
                        shortestDist=dist; closest=p
                    end
                end
            end
            if closest then
                cam.CFrame = CFrame.new(cam.CFrame.Position, closest.Character.Head.Position)
            end
        end
    end)
end)

-- TriggerBot
makeBtn(combatPage,"TriggerBot",function()
    getgenv().triggerbot=not getgenv().triggerbot
    local mouse=Player:GetMouse()
    RunService.RenderStepped:Connect(function()
        if getgenv().triggerbot and mouse.Target and mouse.Target.Parent:FindFirstChildOfClass("Humanoid") then
            local tool=Player.Character:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end
    end)
end)

-- Auto Parry / Auto Block
makeBtn(combatPage,"Auto-Block",function()
    getgenv().autoblock = not getgenv().autoblock
    RunService.Heartbeat:Connect(function()
        if getgenv().autoblock then
            local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Blocking) end
        end
    end)
end)

-- Extend Reach
makeBtn(combatPage,"Reach Extender",function()
    local tool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Handle") then
        tool.Handle.Size = Vector3.new(15,15,15)
        tool.Handle.Massless=true
    end
end)

-- Fast Punch
makeBtn(combatPage,"Fast Punch",function()
    getgenv().fastpunch = not getgenv().fastpunch
    local tool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
    if tool then
        RunService.Heartbeat:Connect(function()
            if getgenv().fastpunch and Player.Character:FindFirstChildOfClass("Tool") then
                tool:Activate()
            end
        end)
    end
end)

-- One Tap (force damage multiplier)
makeBtn(combatPage,"One Tap",function()
    getgenv().onetap = not getgenv().onetap
    local mt=getrawmetatable(game)
    setreadonly(mt,false)
    local old=mt.__namecall
    mt.__namecall=function(self,...)
        local args={...}
        if getgenv().onetap and tostring(self)=="TakeDamage" then
            args[1]=9999
        end
        return old(self,unpack(args))
    end
end)
