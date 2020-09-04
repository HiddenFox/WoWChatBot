WoWChatBot = LibStub("AceAddon-3.0"):NewAddon("WoWChatBot", "AceConsole-3.0", "AceEvent-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("WoWChatBot")

local options = {
    name = L["plugin_name"],
    handler = WoWChatBot,
    type = 'group',
    args = {
        autoInvite = {
            name = L["autoInvite"],
            type = "group", 
            order = 1,
            inline = false,
            args = {
                autoInvite_enable = {
                    type = "toggle",
                    order = 1,
                    width = "full",
                    name = L["autoInvite_enable"],
                    get = "GeneralGetter",
                    set = "GeneralSetter",
                },
                autoInvite_text = {
                    type = "input",
                    order = 2,
                    width = "full",
                    name = L["autoInvite_text"],
                    get = "GeneralGetter",
                    set = "GeneralSetter",
                },
            },
        },
        autoReply = {
            name = L["autoReply"],
            type = "group", 
            order = 2,
            args = {
                autoReply_enableWhisper = {
                    type = "toggle",
                    order = 2,
                    width = "full",
                    name = L["autoReply_enableWhisper"],
                    get = "GeneralGetter",
                    set = "GeneralSetter",
                },
                autoReply_partyOption = {
                    type = "select",
                    order = 3,
                    -- width = "full",
                    name = L["autoReply_partyOption"],
                    values = {
                        noReply = L["autoReply_partyOption_noReply"],
                        whisper = L["autoReply_partyOption_whisper"],
                        party = L["autoReply_partyOption_party"],
                    },
                    get = "GeneralGetter",
                    set = "GeneralSetter",
                },
                autoReply_raidOption = {
                    type = "select",
                    order = 4,
                    -- width = "full",
                    name = L["autoReply_raidOption"],
                    values = {
                        noReply = L["autoReply_raidOption_noReply"],
                        whisper = L["autoReply_raidOption_whisper"],
                        raid = L["autoReply_raidOption_party"],
                    },
                    get = "GeneralGetter",
                    set = "GeneralSetter",
                },
                autoReply_leaderOnly = {
                    type = "toggle",
                    order = 5,
                    name = L["autoReply_leaderOnly"],
                    get = "GeneralGetter",
                    set = "GeneralSetter",
                },
                autoReply_separator = {
                    type = "input",
                    order = 6,
                    width = "full",
                    name = L["autoReply_separator"],
                    get = "GeneralGetter",
                    set = "GeneralSetter",
                },
                autoReply_header = {
                    type = "input",
                    order = 7,
                    width = "full",
                    name = L["autoReply_header"],
                    get = "GeneralGetter",
                    set = "GeneralSetter",
                },
                autoReply_text = {
                    type = "input",
                    multiline = 15,
                    order = 8,
                    width = "full",
                    name = L["autoReply_text"],
                    desc = L["autoReply_text_desc"],
                    get = "GeneralGetter",
                    set = "GeneralSetter",
                },
            },
        },
    },
}

local defaults = {
    char = {
        autoInvite_enable = true,
        autoInvite_text = L["default_autoInvite_text"],

        autoReply_enableWhisper = true,
        autoReply_partyOption = "noReply",
        autoReply_raidOption = "noReply",
        autoReply_leaderOnly = false,
        autoReply_separator = '^',
        autoReply_header = L["default_autoReply_header"],
        autoReply_text = L["default_autoReply_text"],
    },
}

function WoWChatBot:GeneralGetter(info)
    return self.db.char[info[#info]]
end

function WoWChatBot:GeneralSetter(info, newValue)
    self.db.char[info[#info]] = newValue
    -- self:Debug("GeneralSetter", info[#info], self.db.char[info[#info]], type(self.db.char[info[#info]]))
end

function WoWChatBot:Debug(...)
    if self.debug then 
        self:Print(...)
    end
end

----------------------------------------

function WoWChatBot:ChatCommand(input)
    if not input or input:trim() == "" then
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    else
        LibStub("AceConfigCmd-3.0"):HandleCommand("hfp", "HFP", input)
    end
end

function WoWChatBot:OnInitialize()
    self.debug = false
    self.db = LibStub("AceDB-3.0"):New("WoWChatBot", defaults, true)
    
    LibStub("AceConfig-3.0"):RegisterOptionsTable("WoWChatBot", options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("WoWChatBot", L["plugin_name"])
end

function WoWChatBot:OnEnable()
    self:RegisterEvent("CHAT_MSG_WHISPER")
    self:RegisterEvent("CHAT_MSG_PARTY")
    self:RegisterEvent("CHAT_MSG_PARTY_LEADER")
    self:RegisterEvent("CHAT_MSG_RAID")
    self:RegisterEvent("CHAT_MSG_RAID_LEADER")
end

function WoWChatBot:CHAT_MSG_WHISPER(event, msg, sender)
    if (self.db.char.autoInvite_enable) then
        local tokenArray = {strsplit(",", self.db.char.autoInvite_text)}
        if #tokenArray > 1 then
            for idx, token in pairs(tokenArray) do
                if msg == token then
                    InviteUnit(sender)
                    break
                end
            end
        end
    end

    if (self.db.char.autoReply_enableWhisper) then
        self:HandleReplyMsg(event, msg, "whisper", sender)
    end
end

function WoWChatBot:IsPassLeaderCheck()
    -- self:Debug(self.db.char.autoReply_leaderOnly)
    -- self:Debug(UnitIsGroupLeader("player"))
    if (self.db.char.autoReply_leaderOnly and not UnitIsGroupLeader("player")) then
        return false
    end
    return true
end

function WoWChatBot:CHAT_MSG_PARTY(event, msg, sender)
    if (self.db.char.autoReply_partyOption ~= "noReply" and self:IsPassLeaderCheck()) then
        self:HandleReplyMsg(event, msg, self.db.char.autoReply_partyOption, sender)
    end
end

function WoWChatBot:CHAT_MSG_PARTY_LEADER(event, msg, sender)
    if (self.db.char.autoReply_partyOption ~= "noReply" and self:IsPassLeaderCheck()) then
        self:HandleReplyMsg(event, msg, self.db.char.autoReply_partyOption, sender)
    end
end

function WoWChatBot:CHAT_MSG_RAID(event, msg, sender)
    if (self.db.char.autoReply_raidOption ~= "noReply" and self:IsPassLeaderCheck()) then
        self:HandleReplyMsg(event, msg, self.db.char.autoReply_raidOption, sender)
    end
end

function WoWChatBot:CHAT_MSG_RAID_LEADER(event, msg, sender)
    if (self.db.char.autoReply_raidOption ~= "noReply" and self:IsPassLeaderCheck()) then
        self:HandleReplyMsg(event, msg, self.db.char.autoReply_raidOption, sender)
    end
end

function WoWChatBot:HandleReplyMsg(event, msg, chatType, sender)
    -- skip messages sent by the current player
    if sender == UnitName("player") == 1 then
        return
    end

    replyArray = self:GetAutoReplyText(msg)
    if replyArray ~= nil then
        for _, reply in pairs(replyArray) do
            SendChatMessage(reply, chatType, nil, sender);
            -- self:Debug(reply)
        end
    end
end

function WoWChatBot:GetAutoReplyText(msg)
    local found = false
    replyArray = {}

    if self.db.char.autoReply_header ~= nil then
        table.insert(replyArray, self.db.char.autoReply_header)
    end

    local lineArray = {strsplit("\n", self.db.char.autoReply_text)}
    for _, line in pairs(lineArray) do
        local tokenArray = {strsplit(self.db.char.autoReply_separator, line)}
        if #tokenArray > 1 then
            replyText = tokenArray[1]
            for idx, token in pairs(tokenArray) do
                if idx ~= 1 then
                    if token == "*" then
                        found = true
                        table.insert(replyArray, replyText)
                        break
                    elseif string.find(string.upper(msg), string.upper(token)) then
                        found = true
                        table.insert(replyArray, replyText)
                        break
                    end
                end
            end
        end
    end

    if found then
        return replyArray
    end
    return nil
end
