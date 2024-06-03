local function CommandsIntro()
    print("Type /bentocommands for available commands.")
end

local IntroEvents = CreateFrame("Frame")
IntroEvents:RegisterEvent("PLAYER_LOGIN")
IntroEvents:SetScript("OnEvent", CommandsIntro)

SLASH_BENTOCOMMANDS1 = "/bentocommands"
SlashCmdList["BENTOCOMMANDS"] = function(msg, editBox)
    if msg == "" then
        print("|cffFFEB3B/f KEYWORD|r: Filters all active channels for KEYWORD and reposts matching messages.")
        print("|cffFFEB3B/f KEYWORD1+KEYWORD2|r: Filters all active channels for the combination of KEYWORD1 and KEYWORD2 and reposts matching messages.")
        print("|cffFFEB3B/f clear|r: Clears and stops the filtering.")

        print("|cffFFEB3B/bc N1-N2 MESSAGE|r: Broadcasts the message across all specified channels, where N1 and N2 are indicating the inclusive range of channels to be targeted.")

        print("|cffFFEB3B/ww MESSAGE|r: Sends the MESSAGE to all players in a currently open /who instance.")
        print("|cffFFEB3B/ww N MESSAGE|r: Sends the MESSAGE to the first N count of players in a currently open /who instance.")

        print("|cffFFEB3B/c|r: Closes all open whisper tabs.")

        print("|cffFFEB3B/rc|r: Perform a ready check.")
        print("|cffFFEB3B/q|r: Leaves the current party or raid.")

        print("|cffFFEB3B/ui|r: Reloads the user interface.")
        print("|cffFFEB3B/gx|r: Restarts the graphics engine.")
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
    if msg == "clear" then
        wipe(KeywordTable)
        print("|cffFFEB3BFilter:|r Cleared.")
        FilterEvents:UnregisterEvent("CHAT_MSG_CHANNEL")
    elseif msg ~= "" then
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
        print("|cffFFEB3BFiltering: " .. newKeywordsStr:gsub('"', '') .. " .|r")
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
    local num, message = msg:match("^(%d+) (.+)$")
    num = tonumber(num)
    local numWhos = visibleWhoCount or C_FriendList.GetNumWhoResults()

    if num then
        message = msg:match("%d+ (.+)$")
    else
        num = numWhos
        message = msg
    end

    if message ~= "" and numWhos and numWhos > 0 then
        for i = 1, math.min(numWhos, num) do
            local info = C_FriendList.GetWhoInfo(i)
            if info and info.fullName then
                SendChatMessage(message, "WHISPER", nil, info.fullName)
            end
        end
    end
end




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




SLASH_RELOADUI1 = "/ui"
SlashCmdList["RELOADUI"] = function()
    ReloadUI()
end




SLASH_RESTARTGX1 = "/gx"
SlashCmdList["RESTARTGX"] = function()
    RestartGx()
end