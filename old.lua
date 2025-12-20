--[[
	MODIFIED VERSION: Smart AI Integrated
	Credits to original authors.
]]

repeat
	task.wait()
until game:IsLoaded()

if game.PlaceId ~= 8737602449 and game.PlaceId ~= 8943844393 then
	return
end

local identifyexecutor = identifyexecutor or function() return 'Unknown' end
local cloneref = (identifyexecutor() ~= "Synapse Z" and not identifyexecutor():find("Codex") and cloneref) or function(o) return o end
local CoreGui = cloneref(game:GetService("CoreGui"))
local Players = cloneref(game:GetService("Players"))
local HttpService = cloneref(game:GetService("HttpService"))
local TPService = cloneref(game:GetService("TeleportService"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

local Remotes
for i,v in next, ReplicatedStorage:GetChildren() do
   if v.Name:find('Remote') and v.IsA(v, 'ModuleScript') then
       local suc = pcall(function()
           require(v).Event('PromotionBlimpGiftbux'):FireServer()
       end)
       if suc then 
           Remotes = require(v)
           break
       end
   end
end

-- Settings setup
local sNames = {
    'autoPin', 'autoNearReply', 'autoBeg', 'autoThankYou', 'autoUnclaim', 
    'stableBooth', 'pS_Check', 'randomizeSpeed', 'showDonations', 
    'topDonatorType', 'rainbowText', 'autoReplyNoRespond', 'antiBotServers', 
    'robuxLap', 'smartAI' -- Added smartAI
}
local sValues = {
    true, false, true, true, true, 
    false, true, true, false, 
    'Donated', false, true, false, 
    false, false -- Default OFF
}

getgenv().settings = {}

local function saveSettings()
	local json = HttpService:JSONEncode(getgenv().settings)
	writefile('plsdonatesettings.txt', json)
end

if isfile('plsdonatesettings.txt') then
	local json = readfile('plsdonatesettings.txt')
	getgenv().settings = HttpService:JSONDecode(json)
	for i, v in pairs(sNames) do
		if getgenv().settings[v] == nil then
			getgenv().settings[v] = sValues[i]
		end
	end
else
	for i, v in pairs(sNames) do
		getgenv().settings[v] = sValues[i]
	end
	saveSettings()
end

-- Helper Functions
local function chat(msg)
    Remotes.Event("Chatted"):FireServer(msg, "All")
end

local function fetchAIResponse(userMsg)
    local prompt = "You are a friendly, human Roblox player in the game 'Pls Donate'. Keep replies very short (under 10 words). If someone asks for money, say you are saving for a dream item. Be natural."
    local encoded = HttpService:UrlEncode(userMsg .. " (Context: " .. prompt .. ")")
    local url = "https://text.pollinations.ai/" .. encoded
    
    local success, result = pcall(function()
        return httprequest({ Url = url, Method = "GET" })
    end)
    
    if success and result and result.Body then
        return result.Body
    end
    return nil
end

-- UI Setup (Shortened for brevity, focused on Tab 2)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
local Window = Library:CreateWindow({ Name = "PLS DONATE", LoadingTitle = "AI Edition", ConfigurationSaving = { Enabled = false } })
local mainTab = Window:CreateTab("Main")
local otherTab2 = Window:CreateTab("AR")

otherTab2:CreateSection("Auto Reply Settings")

otherTab2:CreateToggle({
	Name = "Standard Auto Reply",
	CurrentValue = getgenv().settings.autoNearReply,
	Callback = function(bool)
		getgenv().settings.autoNearReply = bool
		saveSettings()
	end
})

otherTab2:CreateToggle({
	Name = "Smart AI Chat [BETA]",
	CurrentValue = getgenv().settings.smartAI,
	Callback = function(bool)
		getgenv().settings.smartAI = bool
		saveSettings()
	end
})

-- Chat Logic Integration
Players.PlayerChatted:Connect(function(_, player, message)
	if player == Players.LocalPlayer then return end
    if player:GetAttribute('AI_CD') then return end

	local char = player.Character
	local myChar = Players.LocalPlayer.Character
	if char and myChar and char:FindFirstChild("HumanoidRootPart") then
		local dist = (char.HumanoidRootPart.Position - myChar.HumanoidRootPart.Position).Magnitude
		if dist < 15 then
			player:SetAttribute('AI_CD', true)
			
            -- Decision Engine
			if getgenv().settings.smartAI then
				task.wait(math.random(2, 4))
				local aiResp = fetchAIResponse(message)
				if aiResp then chat(aiResp) end
			elseif getgenv().settings.autoNearReply then
				task.wait(2)
                -- Your original table-based replies go here
                chat("Thanks for stopping by!") 
			end
            
			task.wait(15)
			player:SetAttribute('AI_CD', false)
		end
	end
end)

Library:Notify("AI Script Loaded", "Toggle Smart AI in the AR Tab!", 4483345998)
