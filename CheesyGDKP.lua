local LibCopyPaste = LibStub("LibCopyPaste-1.0")

local function CGAddonCommands(msg)
    DEFAULT_CHAT_FRAME:AddMessage("No commands")
end

local f = CreateFrame("Frame")
f:RegisterEvent("TRADE_SHOW")
--f:RegisterEvent("TRADE_CLOSED")
--f:RegisterEvent("PLAYER_TRADE_MONEY")
f:RegisterEvent("TRADE_MONEY_CHANGED")
f:RegisterEvent("TRADE_ACCEPT_UPDATE")
f:RegisterEvent("TRADE_REQUEST_CANCEL")
f:RegisterEvent("UI_INFO_MESSAGE")
f:RegisterEvent("UI_ERROR_MESSAGE")
local tradeItem, tradeMoney, tradeWho, tradeWhoClass = nil, 0, "", ""
f:SetScript("OnEvent", function(self, event, ...)
    if (event == "TRADE_SHOW") then
        tradeWho = UnitName("npc")
        _, tradeWhoClass = UnitClass("npc")
    elseif (event == "TRADE_MONEY_CHANGED") then
        tradeMoney = GetTargetTradeMoney()
        tradeItem = getFirstTradeItem()
    elseif (event == "TRADE_ACCEPT_UPDATE") then
        tradeMoney = GetTargetTradeMoney()
        tradeItem = getFirstTradeItem()
    elseif (event == "TRADE_REQUEST_CANCEL") then
        resetCurrentTradeData()
    elseif (event == "UI_INFO_MESSAGE" or event == "UI_ERROR_MESSAGE") then
        local type, msg = ...
        if (msg == ERR_TRADE_BAG_FULL or msg == ERR_TRADE_TARGET_BAG_FULL or msg == ERR_TRADE_CANCELLED
                or msg == ERR_TRADE_TARGET_MAX_LIMIT_CATEGORY_COUNT_EXCEEDED_IS) then
            resetCurrentTradeData()
        elseif (msg == ERR_TRADE_COMPLETE) then
            doTrade()
        end
    end
end)

function getFirstTradeItem()
    for id = 1, 6 do
        item = GetTradePlayerItemLink(id)
        if item ~= nil and item ~= "" then
            return item
        end
    end

    return nil
end

function resetCurrentTradeData()
    tradeItem, tradeMoney, tradeWho, tradeWhoClass = nil, 0, "", ""
end

function doTrade()
    if tradeItem then
        DEFAULT_CHAT_FRAME:AddMessage("Gave " .. tradeItem .. " |HCGLink:copytrade|hto " .. tradeWho .. "|h")
    end
    if tradeMoney and tradeMoney ~= "0" then
        DEFAULT_CHAT_FRAME:AddMessage("|HCGLink:copytrade|hReceived " .. GetCoinText(tradeMoney, " ") .. " from " .. tradeWho .. "|h")
    end
end

function extractItemNameFromChatItemLink(message)
    local _, _, name = string.find(message, "|h%[(.+)%]")
    return name
end

function copyTrade()
    local itemString = extractItemNameFromChatItemLink(tradeItem)
    text = itemString .. "\t" .. tradeWho .. "\t" .. string.sub(tradeMoney, 0, -5)
    LibCopyPaste:Copy("Copy trade", text, {
        autoHide = 1,
        readOnly = 1
    })
end

hooksecurefunc("ChatFrame_OnHyperlinkShow", function(...)
    local chatFrame, link, text, button = ...;
    if link == "CGLink:copytrade" then
        copyTrade();
    end
end)

local OriginalSetHyperlink = ItemRefTooltip.SetHyperlink
function ItemRefTooltip:SetHyperlink(link, ...)
    if (link and link:sub(0, 6) == "CGLink") then
        return;
    end
    return OriginalSetHyperlink(self, link, ...);
end

SLASH_TEST1 = "/cg"
SlashCmdList["TEST"] = CGAddonCommands