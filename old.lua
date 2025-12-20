-- [[ PLS DONATE SMART AI + LOGGING + BEGGING ]] --
-- [[ Created by Gemini for User ]] --

getgenv().AISettings = {
    Enabled = true,                -- Master switch
    BeggingEnabled = true,         -- Auto beg switch
    BegDelay = 45,                 -- Seconds between begging
    AI_Cooldown = 15,              -- Seconds before replying to the SAME person again
    DiscordWebhook = "",           -- PASTE YOUR WEBHOOK URL BETWEEN THE QUOTES
    Personality = "I am a friendly Roblox player. I am saving for my dream item. I keep my answers short (under 10 words). I do not sound like a robot.",
    BegMessages = {
        "Goal is near! Any donations help!",
        "Saving up for my dream item, anything helps!",
        "Donations are highly appreciated!",
        "Raising robux for a gamepass, please donate!"
    }
}

-- [[ SERVICES ]] --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TextChatService = game:GetService("TextChatService")

-- [[ EXECUTOR CHECK ]] --
local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
if not request then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Error",
        Text = "Your executor does not support HTTP requests!",
        Duration = 10
    })
    return
end

-- [[ GUI LOG SETUP (Visual Logs) ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AILogger"
if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 400, 0, 250)
Frame.Position = UDim2.new(0.02, 0, 0.6, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "  AI Chat Logs"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

local Scroller = Instance.new("ScrollingFrame")
Scroller.Size = UDim2.new(1, -10, 1, -40)
Scroller.Position = UDim2.new(0, 5, 0, 35)
Scroller.BackgroundTransparency = 1
Scroller.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroller.Parent = Frame

local UIList = Instance.new("UIListLayout")
UIList.Parent = Scroller

local function AddLog(text, color)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    Label.Text = text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.Parent = Scroller
    Scroller.CanvasPosition = Vector2.new(0, 9999) -- Auto scroll
end

AddLog("Script Started...", Color3.fromRGB(0, 255, 0))

-- [[ FUNCTIONS ]] --

local function Chat(msg)
    -- Support for new TextChatService and Legacy Chat
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = TextChatService.TextChannels.RBXGeneral
        if channel then channel:SendAsync(msg) end
    else
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
    end
end

local function SendWebhook(player, message, reply)
    if getgenv().AISettings.DiscordWebhook == "https://discord.com/api/webhooks/1445033421721305221/_GVxZ15ejIR1F8C8DblYJl-LJMAeoQgD0vZt4AkP_s71zeR6mm69hzALnsrpuqO0sWT-" then return end
    
    local data = {
        ["embeds"] = {{
            ["title"] = "🤖 AI Chat Interaction",
            ["color"] = 65280,
            ["fields"] = {
                { ["name"] = "Player", ["value"] = player, ["inline"] = true },
                { ["name"] = "Said", ["value"] = message, ["inline"] = true },
                { ["name"] = "AI Replied", ["value"] = reply, ["inline"] = false }
            },
            ["footer"] = { ["text"] = "Pls Donate AI Logger" }
        }}
    }
    
    request({
        Url = getgenv().AISettings.DiscordWebhook,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(data)
    })
end

local function GetAIResponse(msg)
    local encodedMsg = HttpService:UrlEncode(msg .. " (Context: " .. getgenv().AISettings.Personality .. ")")
    local url = "https://text.pollinations.ai/" .. encodedMsg
    
    local success, response = pcall(function()
        return request({ Url = url, Method = "GET" })
    end)
    
    if success and response.Body then
        return response.Body
    end
    return nil
end

-- [[ AUTO BEG LOOP ]] --
task.spawn(function()
    while true do
        if getgenv().AISettings.BeggingEnabled then
            local msg = getgenv().AISettings.BegMessages[math.random(1, #getgenv().AISettings.BegMessages)]
            Chat(msg)
            AddLog("[BEG]: " .. msg, Color3.fromRGB(255, 255, 0))
        end
        task.wait(getgenv().AISettings.BegDelay)
    end
end)

-- [[ CHAT LISTENER ]] --
Players.PlayerChatted:Connect(function(type, player, message)
    if not getgenv().AISettings.Enabled then return end
    if player == Players.LocalPlayer then return end
    if player:GetAttribute("AICooldown") then return end

    local char = player.Character
    local myChar = Players.LocalPlayer.Character
    
    if char and myChar and char:FindFirstChild("HumanoidRootPart") and myChar:FindFirstChild("HumanoidRootPart") then
        local dist = (char.HumanoidRootPart.Position - myChar.HumanoidRootPart.Position).Magnitude
        
        -- Trigger AI if player is close (15 studs)
        if dist < 15 then
            player:SetAttribute("AICooldown", true)
            AddLog("[DETECT]: " .. player.Name .. " said: " .. message, Color3.fromRGB(0, 200, 255))
            
            task.wait(math.random(2, 4)) -- Fake think time
            
            local aiReply = GetAIResponse(message)
            
            if aiReply then
                Chat(aiReply)
                AddLog("[REPLY]: " .. aiReply, Color3.fromRGB(100, 255, 100))
                
                -- Send to Discord
                task.spawn(function()
                    SendWebhook(player.Name, message, aiReply)
                end)
            else
                AddLog("[FAIL]: AI API Error", Color3.fromRGB(255, 0, 0))
            end

            task.wait(getgenv().AISettings.AI_Cooldown)
            player:SetAttribute("AICooldown", false)
        end
    end
end)

AddLog("System Ready!", Color3.fromRGB(0, 255, 0))
