--[[
Idan Dayan (Idanqt-Discord)
personal like counter for players in WoW Classic, made for Catdog of Cinder-CrusaderStrike 
WIP
TODO:
only like players? 
like from other frames
I liked you whisper 
add note to a like
added liked dates? 


]]--

local addon, iLike = ... 
local iLike_TXT = "|cff69CCF0iLike|r: "
--local iLikeDB = {}
local targetUnit
local debugMode = false
--local iLikeDB = iLikeDB or {}

--debug 
SLASH_PRINTLIKES1 = "/printlikes"
SlashCmdList["PRINTLIKES"] = function(msg)
    for unitGUID, name in pairs(iLikeDB) do
        print("---------------------------------------------")
        print("UnitGUID: " .. unitGUID .. " - names: " .. name)
    end
end 

--debug 
SLASH_DEBUGLIKES1 = "/debuglikes"
SlashCmdList["DEBUGLIKES"] = function(msg)
	debugMode = true
	print("Debugging enabled")
end 

local function debugMsg(msg)
	if debugMode == true and msg ~= nil then
		print(iLike_TXT .. msg)
	else
		return
	end
end

local function LikeFunction()    
    local guid = UnitGUID(targetUnit)
    local name = UnitName(targetUnit)
	print(iLike_TXT .. "Added " .. name .. " to the like counter")
    --iLikeDB[guid] = {name = name, status = true}
	iLikeDB[guid] = name -- only guid and name? no need for status if we only add those we like? 
	debugMsg("GUID: " .. guid .. ", Name: " .. (name or "Unknown"))
	
end

local function UnLikeFunction()
    local guid = UnitGUID(targetUnit)
	local name = UnitName(targetUnit)
	print(iLike_TXT .. "Removed " .. name .. " from the like counter")
    if iLikeDB and iLikeDB[guid] then
        iLikeDB[guid] = nil 
        debugMsg("Debug: GUID: " .. guid .. " unliked.") -- debug
    else
		debugMsg("debug err")
    end
end


local function UpdateTooltip()
    if UnitExists("mouseover") then
        local guid = UnitGUID("mouseover")
        if iLikeDB and iLikeDB[guid] then
            local name = iLikeDB[guid] or "Unknown"
            --local likedLine = string.format("Liked by you! (Name: %s)", name)
			local likedLine = string.format("Liked by you!")
            -- stop duplications
            for i = 1, GameTooltip:NumLines() do
                local line = _G["GameTooltipTextLeft"..i]:GetText()
                if line and line == likedLine then
                    return -- return if line alrdy exists 
                end
            end
            -- add line if doesnt exist
            GameTooltip:AddLine(likedLine, 1, 1, 1)
            GameTooltip:Show()
        end
    end
end

local function AddMenuOptionLike(self, level)
    if not (UIDROPDOWNMENU_MENU_LEVEL or level) then return end
    if UIDROPDOWNMENU_MENU_LEVEL == 1 then
		debugMsg(UIDROPDOWNMENU_MENU_LEVEL)
		debugMsg(which)
        local info = UIDropDownMenu_CreateInfo()
        info.text = "Like"
        info.func = LikeFunction
        info.owner = which
        info.notCheckable = true
        UIDropDownMenu_AddButton(info, level)
    end
end


local function AddMenuOptionUnLike(self, level)
    if not (UIDROPDOWNMENU_MENU_LEVEL or level) then return end
    if UIDROPDOWNMENU_MENU_LEVEL == 1 then
        local info = UIDropDownMenu_CreateInfo()
        info.text = "UnLike"
        info.func = UnLikeFunction
        info.owner = which
        info.notCheckable = true
        UIDropDownMenu_AddButton(info, level)
    end
end


local function OnEvent(self, event, arg1) -- init
    if event == "ADDON_LOADED" and arg1 == addonName then 
		if iLikeDB == nil then	
			iLikeDB {}
        end
    elseif event == "PLAYER_LOGOUT" then 
		if not iLikeDB then
            iLikeDB = {}

		end
    end
end

-- Event handling
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", OnEvent)

GameTooltip:HookScript("OnTooltipSetUnit", UpdateTooltip)
GameTooltip:HookScript("OnUpdate", UpdateTooltip)

hooksecurefunc("UnitPopup_ShowMenu", function(dropdownMenu, which, unit, name, userData)
    if unit == "target" then
		debugMsg(which)
		debugMsg(dropdownmenu)
		debugMsg(unit)
		debugMsg(name)
		debugMsg(userData)
        targetUnit = unit
		local guid = UnitGUID(targetUnit)
        local liked = iLikeDB[guid] ~= nil -- Check if the unit is already liked
		
		if liked then
            AddMenuOptionUnLike(dropdownMenu, UIDROPDOWNMENU_MENU_LEVEL)
        else
            AddMenuOptionLike(dropdownMenu, UIDROPDOWNMENU_MENU_LEVEL)
        end
    end
end)
