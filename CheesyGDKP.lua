local LibCopyPaste = LibStub("LibCopyPaste-1.0")

local function CGAddonCommands(msg)
    DEFAULT_CHAT_FRAME:AddMessage("No commands")
end

local targetItem, targetMoney = nil, 0
local playerItem, playerMoney = nil, 0
local tradeTarget = ""
local tradeId = 1
local trades = {}

local f = CreateFrame("Frame")
f:RegisterEvent("TRADE_SHOW")
f:RegisterEvent("TRADE_MONEY_CHANGED")
f:RegisterEvent("TRADE_ACCEPT_UPDATE")
f:RegisterEvent("TRADE_REQUEST_CANCEL")
f:RegisterEvent("UI_INFO_MESSAGE")
f:RegisterEvent("UI_ERROR_MESSAGE")
f:SetScript("OnEvent", function(self, event, ...)
    if (event == "TRADE_SHOW") then
        tradeTarget = UnitName("npc")
    elseif (event == "TRADE_MONEY_CHANGED") then
        targetMoney = GetTargetTradeMoney()
        targetItem = getFirstTargetItem()
        playerMoney = GetPlayerTradeMoney()
        playerItem = getFirstPlayerItem()
    elseif (event == "TRADE_ACCEPT_UPDATE") then
        targetMoney = GetTargetTradeMoney()
        targetItem = getFirstTargetItem()
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

function getFirstTargetItem()
    for id = 1, 6 do
        item = GetTradeTargetItemLink(id)
        if item ~= nil and item ~= "" then
            return item
        end
    end

    return nil
end

function getFirstPlayerItem()
    for id = 1, 6 do
        item = GetTradePlayerItemLink(id)
        if item ~= nil and item ~= "" then
            return item
        end
    end

    return nil
end

function resetCurrentTradeData()
    targetItem, targetMoney = nil, 0
    playerItem, playerMoney = nil, 0
    tradeTarget = ""
end

function doTrade()
    if playerItem then
        DEFAULT_CHAT_FRAME:AddMessage("Gave " .. playerItem .. " to " .. tradeTarget)
    end
    if targetItem then
        DEFAULT_CHAT_FRAME:AddMessage("Received " .. targetItem .. " from " .. tradeTarget)
    end
    if playerMoney and playerMoney ~= 0 then
        DEFAULT_CHAT_FRAME:AddMessage("Gave " .. GetCoinText(playerMoney, " ") .. " to " .. tradeTarget)
    end
    if targetMoney and targetMoney ~= 0 then
        DEFAULT_CHAT_FRAME:AddMessage("|HCGLink:copytrade:" .. tradeId .. "|hReceived " .. GetCoinText(targetMoney, " ") .. " from " .. tradeTarget .. "|h")
    end

    trade = {}
    trade["target"] = tradeTarget
    trade["playerItem"] = playerItem
    trade["targetItem"] = targetItem
    trade["playerMoney"] = playerMoney
    trade["targetMoney"] = targetMoney
    trades[tradeId] = trade
    tradeId = tradeId+1
end

function extractItemNameFromChatItemLink(message)
    local _, _, name = string.find(message, "|h%[(.+)%]")
    return name
end

function extractItemIdFromChatItemLink(message)
    local _, _, id = string.find(message, "HItem:([0-9]+):")
    return id
end

function copyTrade(id)
    trade = trades[id]
    if trade ~= nil then
        local itemString = extractItemNameFromChatItemLink(trade["playerItem"])
        text = itemString .. "\t" .. tradeTarget .. "\t" .. string.sub(trade["targetMoney"], 0, -5)
        LibCopyPaste:Copy("Copy trade", text, {
            autoHide = 1,
            readOnly = 1
        })
    end
end

hooksecurefunc("ChatFrame_OnHyperlinkShow", function(...)
    local chatFrame, link, text, button = ...;
    if string.sub(link, 0, 16) == "CGLink:copytrade" then
        copyTrade(tonumber(string.sub(link, 18)));
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