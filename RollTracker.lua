local RollTracker = CreateFrame("Frame")
if not rollTotal then rollTotal = 0 end
if not rollCount then rollCount = 0 end
if not rollAvg then rollAvg = 0 end
if not needRollTotal then needRollTotal = 0 end
if not needRollCount then needRollCount = 0 end
if not needRollAvg then needRollAvg = 0 end

local playerName = UnitName("player")

-- SavedVariables Initialization
RollTracker:RegisterEvent("ADDON_LOADED")
RollTracker:RegisterEvent("CHAT_MSG_SYSTEM")
RollTracker:RegisterEvent("CHAT_MSG_LOOT")

RollTracker:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "RollTracker" then
        print("|cff00C2A5[Roll Tracker]|r Loaded! Type /rt for stats.")
    elseif event == "CHAT_MSG_SYSTEM" then
        local roll, min, max = string.match(arg1, playerName .. " rolls (%d+) %((%d+)-(%d+)%)")
        if roll and tonumber(max) == 100 then
            roll = tonumber(roll)
            TrackRoll(roll)
        end
    elseif event == "CHAT_MSG_LOOT" then
        local roll = string.match(arg1, "(%d+) for .* by " .. playerName .. "$")
        local needRoll = string.match(arg1, "[Loot]: Need Roll - (%d+) for .* by " .. playerName .. "$")
        if roll and tonumber(roll) then
            roll = tonumber(roll)
            TrackRoll(roll)
        end
        if needRoll and tonumber(needRoll) then
            needRoll = tonumber(needRoll)
            TrackNeedRoll(needRoll)
        end
    end
end)

function TrackRoll(roll)
    rollTotal = rollTotal + roll
    rollCount = rollCount + 1
    rollAvg = rollTotal / rollCount
    print(string.format("|cff00C2A5Average: %.f|r (%d rolls)", rollAvg, rollCount))
end

function TrackNeedRoll(needRoll)
    -- Add to general roll stats
    TrackRoll(needRoll)  -- This will increment the general stats

    -- Increment Need Roll specific stats
    needRollTotal = needRollTotal + needRoll
    needRollCount = needRollCount + 1
    needRollAvg = needRollTotal / needRollCount
    print(string.format("|cff00C2A5Average (Need): %.f|r (%d rolls)", needRollAvg, needRollCount))
end

-- Slash Commands
SLASH_ROLLTRACKER1 = "/rt"
SlashCmdList["ROLLTRACKER"] = function(msg)
    if rollCount > 0 then
        local generalStats = string.format("General: %d rolls tracked. Average roll: %.f", rollCount, rollAvg)
        local needStats = needRollCount > 0 and string.format(", Need: %d rolls tracked. Average Need roll: %.f", needRollCount, needRollAvg) or ""
        print("|cff00C2A5Roll Tracker Stats:|r " .. generalStats .. needStats)
    else
        print("|cff00C2A5Roll Tracker Stats:|r No rolls tracked yet.")
    end
end

SLASH_ROLLTRACKERCHAT1 = "/rtc"
SlashCmdList["ROLLTRACKERCHAT"] = function(msg)
    if rollCount > 0 then
        local message = string.format("%s has rolled %d times with an average roll of %.f!", playerName, rollCount, rollAvg)
        if needRollCount > 0 then
            message = message .. string.format(" Need rolls average: %.f (%d rolls).", needRollAvg, needRollCount)
        end
        SendChatMessage(message, "SAY")
    else
        print("|cff00C2A5No rolls tracked yet.|r")
    end
end