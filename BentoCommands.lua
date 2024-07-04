local function CommandsIntro()
    print("|cFFFFFF00Type /bentocmd for available commands.|r")
end

local IntroEvents = CreateFrame("Frame")
IntroEvents:RegisterEvent("PLAYER_LOGIN")
IntroEvents:SetScript("OnEvent", CommandsIntro)

SLASH_BENTOCMD1 = "/bentocmd"
SlashCmdList["BENTOCMD"] = function(msg, editBox)
    if msg == "" then
        print("|cFFFFFF00/f KEYWORD|r: Filters all active channels for KEYWORD and reposts matching messages.")
        print("|cFFFFFF00/f KEYWORD1+KEYWORD2|r: Filters all active channels for the combination of KEYWORD1 and KEYWORD2 and reposts matching messages.")
        print("|cFFFFFF00/f|r: Clears and stops the filtering.")

        print("|cFFFFFF00/bc MESSAGE|r: Broadcasts the MESSAGE across all joined channels.")
        print("|cFFFFFF00/bc N1-N2 MESSAGE|r: Broadcasts the MESSAGE across all specified channels, where N1 and N2 are indicating the inclusive range of channels to be targeted.")

        print("|cFFFFFF00/ww MESSAGE|r: Sends the MESSAGE to all players in a currently open /who instance.")
        print("|cFFFFFF00/ww N MESSAGE|r: Sends the MESSAGE to the first N count of players in a currently open /who instance.")
        print("|cFFFFFF00/ww -CLASS MESSAGE|r: Sends the MESSAGE to all players who are not of the specified CLASS in a currently open /who instance.")
        print("|cFFFFFF00/ww N -CLASS MESSAGE|r: Sends the MESSAGE to the first N count of players who are not of the specified CLASS in a currently open /who instance.")
        print("|cFFFFFF00/wl N MESSAGE|r: Sends the MESSAGE to the last N players who whispered you.")

        print("|cFFFFFF00/rc|r: Perform a ready check.")
        print("|cFFFFFF00/q|r: Leaves the current party or raid.")
        print("|cFFFFFF00/ui|r: Reloads the user interface.")
        print("|cFFFFFF00/gx|r: Restarts the graphics engine.")
        print("|cFFFFFF00/lua|r: Toggles the display of LUA errors.")
    end
end




local KeywordTable = {}

local function KeywordMatch(msg, playerName)
    local playerLink = "|Hplayer:" .. playerName .. "|h|cffFFFF00[" .. playerName .. "]: |r|h"
    print(playerLink .. msg)
    PlaySound(3175, "Master", true)
end

local function KeywordFilter(msg)
    for _, keywordSet in ipairs(KeywordTable) do
        if type(keywordSet) == "string" then
            local pattern = "%f[%a]" .. strlower(keywordSet) .. "%f[%A]"
            if strfind(strlower(msg), pattern) then
                return true
            end
        elseif type(keywordSet) == "table" then
            local allMatch = true
            for _, keyword in ipairs(keywordSet) do
                local pattern = "%f[%a]" .. strlower(keyword) .. "%f[%A]"
                if not strfind(strlower(msg), pattern) then
                    allMatch = false
                    break
                end
            end
            if allMatch then
                return true
            end
        end
    end
    return false
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
        if not FilterEvents:IsEventRegistered("CHAT_MSG_CHANNEL") then
            FilterEvents:RegisterEvent("CHAT_MSG_CHANNEL")
        end

        if strfind(msg, "+") then
            local keywordSets = {strsplit(" ", msg)}
            for _, set in ipairs(keywordSets) do
                if strfind(set, "+") then
                    local compoundSet = {}
                    for keyword in string.gmatch(set, "[^+]+") do
                        table.insert(compoundSet, keyword)
                    end
                    table.insert(KeywordTable, compoundSet)
                else
                    table.insert(KeywordTable, set)
                end
            end
        else
            table.insert(KeywordTable, msg)
        end

        local newKeywordsStr = ""
        for i, keywordSet in ipairs(KeywordTable) do
            if type(keywordSet) == "string" then
                newKeywordsStr = newKeywordsStr .. "|cffFFFDE7\"" .. keywordSet .. "\"|r"
            elseif type(keywordSet) == "table" then
                local compoundStr = table.concat(keywordSet, " + ")
                newKeywordsStr = newKeywordsStr .. "|cffFFFDE7\"" .. compoundStr .. "\"|r"
            end
            if i ~= #KeywordTable then
                newKeywordsStr = newKeywordsStr .. ", "
            end
        end
        print("|cFFFFFF00Filtering: " .. newKeywordsStr:gsub('"', '') .. ".|r")
    end
end




SLASH_BROADCAST1 = "/bc"
SlashCmdList["BROADCAST"] = function(msg)
    local startChannel, endChannel, message = msg:match("^(%d+)%-(%d+)%s+(.+)$")
    startChannel, endChannel = tonumber(startChannel), tonumber(endChannel)

    if startChannel and endChannel and message then
        for i = startChannel, endChannel do
            SendChatMessage(message, "CHANNEL", nil, i)
        end
    else
        message = msg
        for i = 1, 10 do
            SendChatMessage(message, "CHANNEL", nil, i)
        end
    end
end




SLASH_WHISPERWHO1 = "/ww"
SlashCmdList["WHISPERWHO"] = function(msg)
    local limit, classExclusion, message

    limit, classExclusion, message = msg:match("^(%d+)%s*-%s*(%w+)%s+(.+)$")
    if not limit then
        limit, message = msg:match("^(%d+)%s+(.+)$")
        if not limit then
            classExclusion, message = msg:match("^%-(%w+)%s+(.+)$")
            if not classExclusion then
                message = msg
            end
        end
    end

    local numWhos = C_FriendList.GetNumWhoResults()

    if limit then
        limit = tonumber(limit)
    else
        limit = numWhos
    end

    if classExclusion then
        classExclusion = classExclusion:lower()
    end

    if message and message ~= "" and numWhos and numWhos > 0 then
        local count = 0
        for i = 1, numWhos do
            if count >= limit then break end
            local info = C_FriendList.GetWhoInfo(i)
            if info and info.fullName then
                if classExclusion then
                    if info.classStr:lower() ~= classExclusion then
                        SendChatMessage(message, "WHISPER", nil, info.fullName)
                        count = count + 1
                    end
                else
                    SendChatMessage(message, "WHISPER", nil, info.fullName)
                    count = count + 1
                end
            end
        end
    end
end




local recentWhispers = {}

SLASH_WHISPERLASTN1 = "/wl"
SlashCmdList["WHISPERLASTN"] = function(msg)
    local num, message = msg:match("^(%d+) (.+)$")

    if not num then
        message = msg
        num = #recentWhispers
    else
        num = tonumber(num)
    end

    if num and message and message ~= "" then
        local whispered = {}
        for i = math.max(#recentWhispers - num + 1, 1), #recentWhispers do
            local playerName = recentWhispers[i]
            if playerName and not whispered[playerName] then
                SendChatMessage(message, "WHISPER", nil, playerName)
                whispered[playerName] = true
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
        print("|cFFFFFF00LUA Errors:|r Enabled")
    else
        SetCVar("scriptErrors", "0")
        print("|cFFFFFF00LUA Errors:|r Disabled")
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