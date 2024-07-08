--[[
Idan Dayan (Idanqt-Discord)

like counter 
WIP

]]--

local addon, iLike = ... 
local iLike_TXT = "|cff69CCF0iLike|r: "
--local iLikeDB = {}
local targetUnit
--local iLikeDB = iLikeDB or {}

--debug 
SLASH_PRINTLIKES1 = "/printlikes"
SlashCmdList["PRINTLIKES"] = function(msg)
    for unitGUID, name in pairs(iLikeDB) do
        print("---------------------------------------------")
        print("UnitGUID: " .. unitGUID .. " - names: " .. name)
    end
end 

local function LikeFunction()
    print(iLike_TXT .. "Added to like counter")
    local guid = UnitGUID(targetUnit)
    local name = UnitName(targetUnit)
    --iLikeDB[guid] = {name = name, status = true}
	iLikeDB[guid] = name -- only guid and name? no need for status if we only add those we like? 
    print("GUID: " .. guid .. ", Name: " .. (name or "Unknown")) -- debug
end

local function UnLikeFunction()
    print(iLike_TXT .. "Removed from like counter")
    local guid = UnitGUID(targetUnit)
    if iLikeDB[guid] then
        iLikeDB[guid] = nil 
        print("Debug: GUID: " .. guid .. " unliked.") -- debug
    else
        print("debug err")
    end
end


local function UpdateTooltip()
    if UnitExists("mouseover") then
        local guid = UnitGUID("mouseover")
        if iLikeDB[guid] then
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