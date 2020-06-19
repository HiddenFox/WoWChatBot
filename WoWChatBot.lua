WoWChatBot = LibStub("AceAddon-3.0"):NewAddon("WoWChatBot", "AceConsole-3.0", "AceEvent-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("WoWChatBot")

local options = {
    name = L["plugin_name"],
    handler = WoWChatBot,
    type = 'group',
    args = {
        autoInvite = {
            name = "自动邀请组队",
            type = "group", 
            order = 1,
            inline = false,
            args = {
                autoInvite_enable = {
                    type = "toggle",
                    order = 1,
                    width = "full",
                    name = "开启自动邀请组队",
                    get = "GeneralGetter",
                    set = "GeneralSetter",
                },
                autoInvite_text = {
                    type = "input",
                    order = 2,
                    width = "full",
                    name = "触发条件（可设置多个，用英文逗号分割）",
                    get = "GeneralGetter",
                    set = "GeneralSetter",
                },
            },
        },
        autoReply = {
            name = "自动回复",
            type = "group", 
            order = 2,
            args = {
                autoReply_enableWhisper = {
                    type = "toggle",
                    order = 2,
                    width = "full",
                    name = "自动回复密聊",
                    get = "GeneralGetter",
                    set = "GeneralSetter",
                },
                autoReply_partyOption = {
                    type = "select",
                    order = 3,
                    -- width = "full",
                    name = "小队聊天",
                    values = {
                        noReply = "不回复",
                        whisper = "密聊回复",
                        party = "小队回复",
                    },
                    get = "GeneralGetter",
                    set = "GeneralSetter",
                },
                -- autoReply_enableRaid = {
                --     type = "toggle",
                --     order = 4,

                --     name = "自动回复团队",
                --     get = "GeneralGetter",
                --     set = "GeneralSetter",
                -- },
                autoReply_raidOption = {
                    type = "select",
                    order = 5,
                    -- width = "full",
                    name = "团队聊天",
                    values = {
                        noReply = "不回复",
                        whisper = "密聊回复",
                        raid = "团队回复",
                    },
                    get = "GeneralGetter",
                    set = "GeneralSetter",
                },
                autoReply_separator = {
                    type = "input",
                    order = 6,
                    width = "full",
                    name = "分隔符",
                    get = "GeneralGetter",
                    set = "GeneralSetter",
                },
                autoReply_header = {
                    type = "input",
                    order = 7,
                    width = "full",
                    name = "固定文字",
                    get = "GeneralGetter",
                    set = "GeneralSetter",
                },
                autoReply_text = {
                    type = "input",
                    multiline = 20,
                    order = 8,
                    width = "full",
                    name = "自动回复规则（鼠标悬停查看详细用法）",
                    desc = '每行一条规则，每条规则以分隔符隔成多个字段，第一个字段为回复文字，后面的字段为触发条件。\n\n规则 "不客气~^谢^3q^3Q" \n表示：如果私聊中包含"谢"或者"3q"或者"3Q"，则发送"不客气~"给对方。',
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
        autoInvite_text = "1,11,111,组,组我,zu,zuwo",

        autoReply_enableWhisper = true,
        autoReply_partyOption = "noReply",
        autoReply_raidOption = "noReply",
        autoReply_separator = '^',
        autoReply_heade = "隐之狐自动回复插件：",
        autoReply_text = '不客气~^谢^3q^3Q',
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

function WoWChatBot:CHAT_MSG_PARTY(event, msg, sender)
    if (self.db.char.autoReply_partyOption ~= "noReply") then
        self:HandleReplyMsg(event, msg, self.db.char.autoReply_partyOption, sender)
    end
end

function WoWChatBot:CHAT_MSG_PARTY_LEADER(event, msg, sender)
    if (self.db.char.autoReply_partyOption ~= "noReply") then
        self:HandleReplyMsg(event, msg, self.db.char.autoReply_partyOption, sender)
    end
end

function WoWChatBot:CHAT_MSG_RAID(event, msg, sender)
    if (self.db.char.autoReply_raidOption ~= "noReply") then
        self:HandleReplyMsg(event, msg, self.db.char.autoReply_raidOption, sender)
    end
end

function WoWChatBot:CHAT_MSG_RAID_LEADER(event, msg, sender)
    if (self.db.char.autoReply_raidOption ~= "noReply") then
        self:HandleReplyMsg(event, msg, self.db.char.autoReply_raidOption, sender)
    end
end

function WoWChatBot:HandleReplyMsg(event, msg, chatType, sender)
    -- skip messages sent by the current player
    if string.find(sender, UnitName("player")) == 1 then
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
                        table.insert(replyArray, replyText)
                        break
                    elseif string.find(msg, token)then
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
