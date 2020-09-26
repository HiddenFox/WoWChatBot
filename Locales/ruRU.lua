-- Author: Hubbotu (https://github.com/Hubbotu)

local L = LibStub("AceLocale-3.0"):NewLocale("WoWChatBot", "ruRU")

if not L then return end

L["plugin_name"] = "WoWChatBot"
L["autoInvite"] = "Автоматическое приглашение"
L["autoInvite_enable"] = "Включено"
L["autoInvite_text"] = "Ключевые слова-триггеры(разделены по ,)"
L["autoReply"] = "Автоответчик"
L["autoReply_enableWhisper"] = "Автоответчик в ЛС"
L["autoReply_partyOption"] = "Сообщения в группу"
L["autoReply_partyOption_noReply"] = "Не отвечать"
L["autoReply_partyOption_whisper"] = "Ответить в ЛС"
L["autoReply_partyOption_party"] = "Ответить в канал группы"
L["autoReply_raidOption"] = "Сообщения в рейд"
L["autoReply_raidOption_noReply"] = "Не отвечать"
L["autoReply_raidOption_whisper"] = "Ответить в ЛС"
L["autoReply_raidOption_party"] = "Ответить в канал рейда"
L["autoReply_leaderOnly"] = "Отвечаю, когда я лидер"
L["autoReply_separator"] = "Разделитель"
L["autoReply_header"] = "Заголовок сообщения"
L["autoReply_text"] = "Правила ответа"
L["autoReply_text_desc"] = "Одно правило разделяется на несколько маркеров разделителем. Первый маркер-это ответное сообщение, которое должно быть отправлено. Другие маркеры - это ключевые слова, которые могут вызвать это правило. При получении сообщения, содержащего одно из ключевых слов, будет отправлено ответное сообщение.\n Образец правила: Добро пожаловать!^Спасибо^Спасибо тебе^Спс\n Означает: Когда сообщение содержит 'Спасибо' или 'Спасибо тебе' или 'Спс', WoWChatBot будет автоматически посылать 'Добро пожаловать!' отправителю."
L["default_autoInvite_text"] = "1,11,111, пригласите меня"
L["default_autoReply_header"] = "Отправлено от WoWChatBot:"
L["default_autoReply_text"] = "Добро пожаловать!^Спасибо^спасибо тебе^спс\nЗдравствуй!^здравствуйте^привет"