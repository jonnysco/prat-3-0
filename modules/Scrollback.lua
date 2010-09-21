---------------------------------------------------------------------------------
--
-- Prat - A framework for World of Warcraft chat mods
--
-- Copyright (C) 2006-2007  Prat Development Team
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to:
--
-- Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor,
-- Boston, MA  02110-1301, USA.
--
--
-------------------------------------------------------------------------------


Prat:AddModuleExtension(function() 
    local module = Prat.Addon:GetModule("History", true)
--local PRAT_MODULE = Prat:RequestModuleName("Scrollback")
--
--if PRAT_MODULE == nil then
--    return
--end
--
--local L = Prat:GetLocalizer({})

local L = module.L


module.pluginopts["GlobalPatterns"] = {  
    scrollback =  {
        type = "toggle",
        name = L["Scrollback"],
        desc = L["Store the chat lines between sessions"],
        order = 125
    }
}




local MAX_SCROLLBACK = 50


local orgOME = module.OnModuleEnable
function module:OnModuleEnable(...) 
	orgOME(self, ...)
	

	
    Prat3PerCharDB = Prat3PerCharDB or {}
    Prat3PerCharDB.scrollback = Prat3PerCharDB.scrollback or {}

    self.scrollback = Prat3PerCharDB.scrollback

    self.timestamps = Prat.Addon:GetModule("Timestamps")

	if self.db.profile.scrollback then 
        self:RestoreLastSession()
    end
    
    Prat.RegisterChatEvent(self, Prat.Events.POST_ADDMESSAGE)
end

function module:RestoreLastSession()
    local textadded
    Prat.loading = true
    for frame,scrollback in pairs(self.scrollback) do
        for _, line in ipairs(scrollback) do
            _G[frame]:AddMessage(unpack(line))
            textadded=true
        end
        
        if textadded then
             _G[frame]:AddMessage(L.divider)
        end
    end
    Prat.loading = nil
end

--function module:OnModuleDisable()
--	 Prat3PerCharDB.scrollback = nil
--end

function module:Prat_PostAddMessage(info, message, frame, event, text, r, g, b, id)
    if not self.db.profile.scrollback then return end
    
    self.scrollback[frame:GetName()] = self.scrollback[frame:GetName()] or {}
    local scrollback = self.scrollback[frame:GetName()]

    text = self.timestamps and self.timestamps:InsertTimeStamp(text, frame) or text

    table.insert(scrollback, { text, r, g, b, id } )
    if #scrollback > MAX_SCROLLBACK then
        table.remove(scrollback,1)
    end
end

end )