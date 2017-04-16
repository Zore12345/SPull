local MSG_PREFIX = "SIMPLEPULL"
RegisterAddonMessagePrefix(MSG_PREFIX)
if not RegisterAddonMessagePrefix(MSG_PREFIX) then
	print("error unable to register prefix")
end

local defaults = {}
defaults["DefaultPullTime"] = 5
defaults["UseServerTime"] = false			--currently unimplemented but put feild in here for easy implementation.
defaults["UseSyncPull"] = false				--currently unimplemented but put feild in here for easy implementation.
defaults["ManualSyncOnly"] = false			--currently unimplemented but put feild in here for easy implementation.
defaults["UseRaidWarning"] = false			--currently unimplemented but put feild in here for easy implementation.
defaults["UseVoice"] = false				--currently unimplemented but put feild in here for easy implementation.
defaults["VoiceProfile"] = "MALE"			--currently unimplemented but put feild in here for easy implementation.
defaults["Version"] = 0.15					--currently unimplemented but put feild in here for easy implementation.

local SimplePull = {}
SimplePull.panel = CreateFrame( "Frame", "SimplePull", UIParent )
SimplePull.panel.name = "|cFF5194ffSimple Pull|r"
InterfaceOptions_AddCategory(SimplePull.panel)
											--finish
											--interface
											--options
											--menu

if not type(SimplePullSettings) then
    SimplePullSettings = defaults			--should make a deep copy that adds new setting if they are not present and app was updated.
end

SLASH_SIMPLEPULL1, SLASH_SIMPLEPULL2 = '/simplepull', '/spull'
local function handler(msg, editbox)
	if msg ~= '' then
		local count = tonumber(msg)
		if count ~= nil then
			sendPull(count)
		else
			if string.lower(msg) == 'util' then
				InterfaceOptionsFrame_OpenToCategory(SimplePull.panel)
			end
		end
	else
		pull(SimplePullSettings["DefaultPullTime"])
	end
end
SlashCmdList["SIMPLEPULL"] = handler;

function SimplePull_ShowMessage()
	print("|cFF5194ffSimplePull:|r succesfully loaded.")
end

function pull(number)					--finish
	
end

function sendPull(number)
	SendAddonMessage(MSG_PREFIX, number, "RAID")
end

if not eventFrame then
	eventFrame = CreateFrame("Frame")
end

eventFrame:RegisterEvent("CHAT_MSG_ADDON")
function eventhandler(self, event, prefix, message, channel, sender)
	name, realm = UnitName("player")
	if realm==nil then
		realm = GetRealmName()
	end
	if sender~=(name.."-"..realm) then
		print("got " .. message .. " from " .. sender)
	end
end
eventFrame:SetScript("OnEvent", eventhandler)