local function CommandsIntro()
    print("|cFFFFFF00Type /bentocommands for available commands.|r")
end

local IntroEvents = CreateFrame("Frame")
IntroEvents:RegisterEvent("PLAYER_LOGIN")
IntroEvents:SetScript("OnEvent", CommandsIntro)

SLASH_BENTOCOMMANDS1 = "/bentocommands"
SlashCmdList["BENTOCOMMANDS"] = function(msg, editBox)
    if msg == "" then
        print("|cFFFFFF00/f KEYWORD|r: Filters all active channels for KEYWORD and reposts matching messages.")
        print("|cFFFFFF00/f KEYWORD1+KEYWORD2|r: Filters all active channels for the combination of KEYWORD1 and KEYWORD2 and reposts matching messages.")
        print("|cFFFFFF00/f clear|r: Clears and stops the filtering.")

        print("|cFFFFFF00/bc N1-N2 MESSAGE|r: Broadcasts the message across all specified channels, where N1 and N2 are indicating the inclusive range of channels to be targeted.")

        print("|cFFFFFF00/ww MESSAGE|r: Sends the MESSAGE to all players in a currently open /who instance.")
        print("|cFFFFFF00/ww N MESSAGE|r: Sends the MESSAGE to the first N count of players in a currently open /who instance.")

        print("|cFFFFFF00/wl N MESSAGE|r: Sends the MESSAGE to the last N players who whispered you.")

        print("|cFFFFFF00/c|r: Closes all open whisper tabs.")

        print("|cFFFFFF00/rc|r: Perform a ready check.")
        print("|cFFFFFF00/q|r: Leaves the current party or raid.")

        print("|cFFFFFF00/ui|r: Reloads the user interface.")
        print("|cFFFFFF00/gx|r: Restarts the graphics engine.")
    end
end




local KeywordTable = {}

local function KeywordMatch(msg, playerName)
    local playerLink = "|Hplayer:" .. playerName .. "|h|cffFFEB3B[" .. playerName .. "]: |r|h"
    print(playerLink .. msg)
    PlaySound(3175, "Master", true)
end

local function KeywordFilter(msg)
    for _, keyword in ipairs(KeywordTable) do
        if not strfind(strlower(msg), strlower(keyword)) then
            return false
        end
    end
    return true
end

local function KeywordValidation(self, event, msg, playerName, languageName, channelName, ...)
    if next(KeywordTable) and strmatch(channelName, "%d+") then
        local channelNumber = tonumber(strmatch(channelName, "%d+"))
        if channelNumber and channelNumber >= 1 and channelNumber <= 10 and KeywordFilter(msg) then
            KeywordMatch(msg, playerName)
        end
    end
end

local FilterEvents = CreateFrame("Frame")
FilterEvents:SetScript("OnEvent", KeywordValidation)

SLASH_FILTER1 = "/f"
SlashCmdList["FILTER"] = function(msg)
    if msg == "" then
        wipe(KeywordTable)
        print("|cFFFFFF00Filter:|r Cleared.")
        FilterEvents:UnregisterEvent("CHAT_MSG_CHANNEL")
    else
        wipe(KeywordTable)
        local newKeywords = {}
        for keyword in string.gmatch(msg, "[^+]+") do
            table.insert(newKeywords, keyword)
            table.insert(KeywordTable, keyword)
        end
        local newKeywordsStr = ""
        for i, keyword in ipairs(newKeywords) do
            newKeywordsStr = newKeywordsStr .. "|cffFFFDE7\"" .. keyword .. "\"|r"
            if i ~= #newKeywords then
                newKeywordsStr = newKeywordsStr .. ", "
            end
        end
        print("|cFFFFFF00Filtering: " .. newKeywordsStr:gsub('"', '') .. ".|r")
        FilterEvents:RegisterEvent("CHAT_MSG_CHANNEL")
    end
end




SLASH_BROADCAST1 = "/bc"
SlashCmdList["BROADCAST"] = function(msg)
    local startChannel, endChannel, message = msg:match("(%d+)%-(%d+)%s+(.+)")
    startChannel, endChannel = tonumber(startChannel), tonumber(endChannel)

    if startChannel and endChannel and message then
        for i = startChannel, endChannel do
            SendChatMessage(message, "CHANNEL", nil, i)
        end
    end
end




SLASH_WHISPERWHO1 = "/ww"
SlashCmdList["WHISPERWHO"] = function(msg)
    local classExclusion, message = msg:match("^%-(%w+) (.+)$")
    local numWhos = C_FriendList.GetNumWhoResults()

    if classExclusion then
        classExclusion = classExclusion:lower()
        message = msg:match("^%-%w+ (.+)$")
    else
        message = msg
    end

    if message ~= "" and numWhos and numWhos > 0 then
        for i = 1, numWhos do
            local info = C_FriendList.GetWhoInfo(i)
            if info and info.fullName then
                if classExclusion then
                    if info.classStr:lower() ~= classExclusion then
                        SendChatMessage(message, "WHISPER", nil, info.fullName)
                    end
                else
                    SendChatMessage(message, "WHISPER", nil, info.fullName)
                end
            end
        end
    end
end




local recentWhispers = {}

SLASH_WHISPERLASTN1 = "/wl"
SlashCmdList["WHISPERLASTN"] = function(msg)
    local num, message = msg:match("^(%d+) (.+)$")
    num = tonumber(num)

    if num and message then
        for i = #recentWhispers - num + 1, #recentWhispers do
            if recentWhispers[i] then
                SendChatMessage(message, "WHISPER", nil, recentWhispers[i])
            end
        end
    end
end

local function TrackWhispers(_, _, msg, playerName)
    table.insert(recentWhispers, playerName)
    if #recentWhispers > 100 then
        table.remove(recentWhispers, 1)
    end
end

local WhisperLastEvents = CreateFrame("Frame")
WhisperLastEvents:RegisterEvent("CHAT_MSG_WHISPER")
WhisperLastEvents:SetScript("OnEvent", TrackWhispers)




SLASH_CLOSETABS1 = "/c"
SlashCmdList["CLOSETABS"] = function()
    for _, chatFrameName in pairs(CHAT_FRAMES) do
        local chatFrame = _G[chatFrameName]
        if chatFrame and chatFrame.isTemporary then
            FCF_Close(chatFrame)
        end
    end
end




SLASH_READYCHECK1 = "/rc"
SlashCmdList["READYCHECK"] = function()
    DoReadyCheck()
end




SLASH_QUIT1 = "/q"
SlashCmdList["QUIT"] = function()
    LeaveParty()
end




SLASH_LUAERROR1 = "/lua"
SlashCmdList["LUAERROR"] = function()
    if GetCVar("scriptErrors") == "0" then
        SetCVar("scriptErrors", "1")
        print("LUA Errors Enabled")
    else
        SetCVar("scriptErrors", "0")
        print("LUA Errors Disabled")
    end
end




SLASH_RELOADUI1 = "/ui"
SlashCmdList["RELOADUI"] = function()
    ReloadUI()
end




SLASH_RESTARTGX1 = "/gx"
SlashCmdList["RESTARTGX"] = function()
    RestartGx()
end