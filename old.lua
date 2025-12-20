-- [[ REVISED BLOCK 1: HIGH-PERFORMANCE AR & BEGGER ]] --
repeat task.wait() until game:IsLoaded()

-- 1. SETTINGS
getgenv().Config = {
    WebhookURL = "https://discord.com/api/webhooks/1445033421721305221/_GVxZ15ejIR1F8C8DblYJl-LJMAeoQgD0vZt4AkP_s71zeR6mm69hzALnsrpuqO0sWT-",
    BoothText = "pls donate only 100 robux left",
    AI_Enabled = true,
    BegDelay = 15, -- Seconds between begging
}

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer

-- 2. SHARED WEBHOOK
getgenv().SendLog = function(title, desc, color)
    if getgenv().Config.WebhookURL == "" then return end
    task.spawn(function()
        pcall(function()
            local req = (syn and syn.request) or (http and http.request) or http_request or request
            req({
                Url = getgenv().Config.WebhookURL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({
                    ["embeds"] = {{
                        ["title"] = title,
                        ["description"] = desc,
                        ["color"] = color or 0x00FF00,
                        ["footer"] = { ["text"] = "User: " .. LocalPlayer.Name },
                        ["timestamp"] = DateTime.now():ToIsoDate()
                    }}
                })
            })
        end)
    end)
end

-- 3. SHARED CHAT (Uses different methods to prevent overlap)
local function InternalChat(msg)
    local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
    if channel then channel:SendAsync(msg) end
end

-- 4. INDEPENDENT AUTO-BEGGER (Fixed 15s - Never stops)
task.spawn(function()
    local msgs = {
        "Please donate! Only 100 robux left to my goal! :)",
        "Every 1 robux helps me a lot! <3",
        "Hi! Donations appreciated, trying to reach a goal!"
    }
    while true do
        task.wait(getgenv().Config.BegDelay)
        InternalChat(msgs[math.random(1, #msgs)])
    end
end)

-- 5. FAST AI AUTO-REPLY (AR)
local lastReply = {}
TextChatService.MessageReceived:Connect(function(msg)
    if not getgenv().Config.AI_Enabled then return end
    if not msg.TextSource or msg.TextSource.UserId == LocalPlayer.UserId then return end
    
    local speaker = Players:GetPlayerByUserId(msg.TextSource.UserId)
    if speaker and speaker.Character and LocalPlayer.Character then
        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - speaker.Character.HumanoidRootPart.Position).Magnitude
        
        if dist < 15 then
            if lastReply[speaker.UserId] and tick() - lastReply[speaker.UserId] < 5 then return end
            lastReply[speaker.UserId] = tick()
            
            task.spawn(function()
                -- Webhook the "Someone said something" immediately
                getgenv().SendLog("💬 Incoming Chat", "**"..speaker.Name.."**: "..msg.Text, 0x5865F2)
                
                -- Fast AI Fetch with Timeout
                local success, response = pcall(function()
                    return game:HttpGet("https://text.pollinations.ai/" .. HttpService:UrlEncode(msg.Text .. " (Reply short as a Roblox player)"), true)
                end)
                
                if success and response and #response > 1 then
                    task.wait(1) -- Small human delay
                    InternalChat(response)
                    getgenv().SendLog("🤖 AI Replied", "**Bot**: "..response, 0x00FF00)
                end
            end)
        end
    end
end)

print("✅ Block 1: Engine + Fast AR + Begger Loaded.")



-- [[ BLOCK 2: HARD-LOCKED PLAZA CLAIMER ]] --

local hasClaimedSuccessfully = false -- This is our Master Lock

local function UpdateBooth()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    for _, v in next, ReplicatedStorage:GetChildren() do
        if v.Name:find('Remote') and v.IsA(v, 'ModuleScript') then
            local s, res = pcall(function() return require(v) end)
            if s and res.Event then
                res.Event("SetCustomization"):FireServer({
                    ["text"] = getgenv().Config.BoothText,
                    ["richText"] = true
                }, "booth")
            end
        end
    end
end

task.spawn(function()
    local plazaCenter = Vector3.new(165, 3, 311)
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    -- INITIAL CHECK: Do you already have a booth?
    local MapUI = workspace:FindFirstChild("MapUI") or (LocalPlayer.PlayerGui:FindFirstChild("MapUIContainer") and LocalPlayer.PlayerGui.MapUIContainer:FindFirstChild("MapUI"))
    for _, boothUI in pairs(MapUI.BoothUI:GetChildren()) do
        if boothUI.Details.Owner.Text == LocalPlayer.Name or boothUI.Details.Owner.Text == LocalPlayer.DisplayName then
            hasClaimedSuccessfully = true
            UpdateBooth()
            return -- Exit immediately
        end
    end

    print("Searching for plaza booth...")
    
    while not hasClaimedSuccessfully do
        local target = nil
        local currentMapUI = workspace:FindFirstChild("MapUI") or (LocalPlayer.PlayerGui:FindFirstChild("MapUIContainer") and LocalPlayer.PlayerGui.MapUIContainer:FindFirstChild("MapUI"))
        
        -- 1. Find the Booth
        for _, boothUI in pairs(currentMapUI.BoothUI:GetChildren()) do
            if boothUI.Details.Owner.Text == "unclaimed" or boothUI.Details.Owner.Text == "" then
                local id = tonumber(string.match(boothUI.Name, "%d+"))
                for _, interact in pairs(workspace.BoothInteractions:GetChildren()) do
                    if interact:GetAttribute("BoothSlot") == id then
                        local dist = (interact.Position - plazaCenter).Magnitude
                        -- Ground level and Plaza center only
                        if dist < 85 and interact.Position.Y > 2 and interact.Position.Y < 12 then
                            target = {id = id, part = interact}
                            break
                        end
                    end
                end
            end
            if target then break end
        end

        -- 2. Teleport and Kill Loop
        if target then
            hasClaimedSuccessfully = true -- LOCK SET: The loop will never run again
            
            local root = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
            root.CFrame = target.part.CFrame * CFrame.new(0, 0, 4)
            task.wait(1)
            
            -- Claim Remote
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            for _, v in next, ReplicatedStorage:GetChildren() do
                if v.Name:find('Remote') and v.IsA(v, 'ModuleScript') then
                    local s, Rem = pcall(function() return require(v) end)
                    if s and Rem.Event then
                        Rem.Event("ClaimBooth"):InvokeServer(target.id)
                    end
                end
            end
            
            task.wait(2)
            UpdateBooth()
            getgenv().SendLog("✅ Booth Claimed", "Hard-locked to Plaza Booth #" .. target.id)
            print("✅ Successfully Claimed. Logic is now locked.")
        end
        task.wait(2)
    end
end)
-- [[ BLOCK 3: DONATION TRACKER & WEBHOOK NOTIFIER ]] --

task.spawn(function()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    -- 1. Wait for the game's donation stats to load
    local leaderstats = LocalPlayer:WaitForChild("leaderstats", 20)
    local raisedStat = leaderstats and leaderstats:WaitForChild("Raised", 20)

    if not raisedStat then 
        print("⚠️ Donation Tracker: Could not find 'Raised' stat. Retrying...") 
        return 
    end

    local lastTotal = raisedStat.Value

    -- 2. Watch for changes in the "Raised" value
    raisedStat.Changed:Connect(function(newTotal)
        local amountGained = newTotal - lastTotal
        
        if amountGained > 0 then
            -- Format the Discord Notification
            local donationTitle = "💰 ROBUX RECEIVED!"
            local donationDesc = "### You just received a donation!\n" ..
                "**💵 Amount:** `" .. amountGained .. " Robux`\n" ..
                "**📊 New Total:** `" .. newTotal .. " Robux`\n" ..
                "**🕒 Time:** <t:" .. math.floor(os.time()) .. ":R>"
            
            -- Send to Discord (using Block 1's function)
            getgenv().SendLog(donationTitle, donationDesc, 0xFFD700) -- Gold Color

            -- 3. Automatic "Thank You" messages
            task.spawn(function()
                local responses = {
                    "OMG!! Tysm for the " .. amountGained .. " Robux! <3",
                    "YOO! " .. amountGained .. " Robux?! You are a legend!",
                    "Thank you so much! That helps me get closer to my goal!",
                    "Wow, tysm! I really appreciate the support!",
                    "I just saw that! Thank you for the " .. amountGained .. "!!"
                }
                
                -- Wait 1-2 seconds so it looks like you reacted
                task.wait(math.random(1, 2))
                getgenv().SendChat(responses[math.random(1, #responses)])
                
                -- Optional: Do a dance after being donated
                getgenv().SendChat("/e dance")
            end)
        end
        
        -- Update the total for the next donation
        lastTotal = newTotal
    end)
end)

print("✅ BLOCK 3 LOADED: Donation Tracker & Webhook Alerts active.")
-- [[ BLOCK 4: ANTI-AFK & SMART SERVER HOPPER ]] --

-- 1. ANTI-AFK SYSTEM (Prevents 20-minute disconnect)
task.spawn(function()
    local VirtualUser = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        print("🛡️ Anti-AFK: Prevented kick.")
    end)
end)

-- 2. SMART SERVER HOPPER
-- It will wait 20 minutes, then find a new server to get fresh players.
task.spawn(function()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local HopDelay = 1200 -- 20 Minutes (in seconds)

    task.wait(HopDelay) 
    
    getgenv().SendLog("🚀 Server Hopping", "Been in this server for 20 mins. Looking for fresh donors!", 0x00FFFF)
    
    local function Hop()
        local PlaceID = game.PlaceId
        local Servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Desc&limit=100"))
        local targetServer = nil
        
        for _, server in pairs(Servers.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                targetServer = server.id
                break
            end
        end
        
        if targetServer then
            TeleportService:TeleportToPlaceInstance(PlaceID, targetServer, game:GetService("Players").LocalPlayer)
        else
            print("❌ No better servers found, retrying in 1 minute.")
            task.wait(60)
            Hop()
        end
    end

    Hop()
end)

print("✅ BLOCK 4 LOADED: Anti-AFK and 20-min Server Hopper active.")

