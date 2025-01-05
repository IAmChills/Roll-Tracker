local RollTrackerStats = CreateFrame("Frame")
if not rollTotal then rollTotal = 0 end
if not rollCount then rollCount = 0 end
if not rollAvg then rollAvg = 0 end
if not needRollTotal then needRollTotal = 0 end
if not needRollCount then needRollCount = 0 end
if not needRollAvg then needRollAvg = 0 end

local playerName = UnitName("player")

-- SavedVariables Initialization
RollTrackerStats:RegisterEvent("ADDON_LOADED")
RollTrackerStats:RegisterEvent("CHAT_MSG_SYSTEM")
RollTrackerStats:RegisterEvent("CHAT_MSG_LOOT")

RollTrackerStats:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "RollTrackerStats" then
        print("|cff00C2A5[Roll Tracker Stats]|r Loaded! Type /rts for stats.")
    elseif event == "CHAT_MSG_SYSTEM" then
        local roll, min, max = string.match(arg1, playerName .. " rolls (%d+) %((%d+)-(%d+)%)")
        if roll and tonumber(max) == 100 then
            roll = tonumber(roll)
            TrackRoll(roll)
        end
    elseif event == "CHAT_MSG_LOOT" then
        local roll = tonumber(string.match(arg1, "Roll%s*-%s*(%d+)%s*for.*by%s*" .. playerName))
        local needRoll = tonumber(string.match(arg1, "Need%sRoll%s*-%s*(%d+)%s*for.*by%s*" .. playerName))
        if roll then
            TrackRoll(roll)
        end
        if needRoll then
            TrackNeedRoll(needRoll)
        end
    end
end)

function TrackRoll(roll)
    rollTotal = rollTotal + roll
    rollCount = rollCount + 1
    rollAvg = rollTotal / rollCount
    --print(string.format("|cff00C2A5Average: %.f|r (%d rolls)", rollAvg, rollCount))
end

function TrackNeedRoll(needRoll)
    -- Add to general roll stats
    TrackRoll(needRoll)  -- This will increment the general stats

    -- Increment Need Roll specific stats
    needRollTotal = needRollTotal + needRoll
    needRollCount = needRollCount + 1
    needRollAvg = needRollTotal / needRollCount
    --print(string.format("|cff00C2A5Average (Need): %.f|r (%d rolls)", needRollAvg, needRollCount))
end

-- Slash Commands
SLASH_ROLLTRACKERSTATS1 = "/rts"
SlashCmdList["ROLLTRACKERSTATS"] = function(msg)
    if rollCount > 0 or needRollCount > 0 then
        local generalStats = string.format("General: %d rolls tracked. Average roll: %.f", rollCount, rollAvg)
        local needStats = string.format("Need: %d rolls tracked. Average Need roll: %.f", needRollCount, needRollAvg)
        print("|cff00C2A5Roll Tracker Stats:|r " .. generalStats)
        print("|cff00C2A5Roll Tracker Stats:|r " .. needStats)
    else
        print("|cff00C2A5Roll Tracker Stats:|r No rolls tracked yet.")
    end
    print("|cff00C2A5Roll Tracker Stats:|r type /rtsc to share your stats in chat!")
end

SLASH_ROLLTRACKERSTATSCHAT1 = "/rtsc"
SlashCmdList["ROLLTRACKERSTATSCHAT"] = function(msg)
    if rollCount > 0 or needRollCount > 0 then
        local generalStats = string.format(" has rolled %d times with an average roll of %.f!", rollCount, rollAvg)
        local needStats = string.format(" has Need rolled %d times with an average roll of %.f!", needRollCount, needRollAvg)
        SendChatMessage(generalStats, "EMOTE")
        SendChatMessage(needStats, "EMOTE")
    else
        print("Roll Tracker Stats: No rolls tracked yet.")
    end
end
