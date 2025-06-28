require "ISUI/ISPanelJoypad"

local ZBYutils = require('ZBAY_Utils')
local getComputer = require('GetComputerInfo')

local ww, PriceNum;

Windows_ZBY_Item = ISPanelJoypad:derive("Windows_ZBY_Item");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)


function Windows_ZBY_Item:initialise()

  self.Home = ISButton:new(10, 33, (ww.width*0.25), 32, "", self, Windows_ZBY_Item.onClick);
  self.Home.internal = "Home";
  self.Home:initialise();
  self.Home.backgroundColor.a = 0;
  self.Home.borderColor.a = 0;
  self.Home.backgroundColorMouseOver.a = 100;
  self.Home:setImage(getTexture("media/textures/logo.png"));
  self.Home.textColor.a = 0;
  ww:addChild(self.Home)

  self.logolabel = ISLabel:new(self.Home:getRight()+10, 33, getTextManager():getFontHeight(UIFont.Large), "Z", 0, 0, 0, 1, UIFont.Large, true)
  ww:addChild(self.logolabel)
  self.logolabel2 = ISLabel:new(self.logolabel:getRight(), 33, getTextManager():getFontHeight(UIFont.Cred1), "B", 0, 0, 0, 1, UIFont.Cred1, true)
  ww:addChild(self.logolabel2)
  self.logolabel3 = ISLabel:new(self.logolabel2:getRight(), 33, getTextManager():getFontHeight(UIFont.Large), "AY", 0, 0, 0, 1, UIFont.Large, true)
  ww:addChild(self.logolabel3)

  self.searchBox = ISTextEntryBox:new("", self.logolabel3:getRight()+10, 33, ww.width-(self.logolabel3:getRight()+10)-80, 32)
  self.searchBox.font = UIFont.Medium
  self.searchBox.backgroundColor = {r=0.753, g=0.753, b=0.753, a=1};
  self.searchBox:initialise()
  self.searchBox:instantiate()
  self.searchBox.onCommandEntered = self.downEnter
  self.searchBox.target = self.searchBox
  ww:addChild(self.searchBox)

  self.search = ISButton:new(self.searchBox:getRight()+10, 33, 32, 32, "", self, Windows_ZBY_Item.onClick);
  self.search.internal = "Search";
  self.search:initialise();
  self.search.backgroundColor.a = 0;
  self.search.backgroundColorMouseOver.a = 1;
  self.search.borderColor.a = 0;
  self.search:setImage(getTexture("media/textures/search_web.png"));
  self.search.textColor.a = 0;
  ww:addChild(self.search)

  self.ItemButton = ISButton:new(30, (ww.height*0.25), (ww.width*0.4), (ww.width*0.4), "", self, Windows_ZBY_Item.onClick);
  self.ItemButton.internal = "Itembutton";
  self.ItemButton.sounds.activate = ""
  self.ItemButton:initialise();
  self.ItemButton.backgroundColor.a = 0;
  self.ItemButton.backgroundColorMouseOver.a = 0;
  local tex,inv;
  if not self.SellIndex then
    tex = ZBYutils.getItemIconTexture(self.item)
    inv = InventoryItemFactory.CreateItem(self.item:getFullName());
   else 
    tex = self.item:getTex()
    inv = self.item
  end
  self.ItemButton:setImage(tex);
  
  --print("color : " .. inv:getColorInfo():toString())
  print("rgb : " .. tostring(inv:getR()) .. "/" .. tostring(inv:getG()) .. "/" .. tostring(inv:getB()))
  self.ItemButton.textureColor = {r=inv:getR(), g=inv:getG(), b=inv:getB(), a=1};
  self.ItemButton.onMouseMove = self.addItemTooltip
  self.ItemButton.onMouseMoveOutside = self.removeItemTooltip
  self.ItemButton:forceImageSize((ww.width*0.35), (ww.width*0.35));
  self.ItemButton.textColor.a = 0;
  ww:addChild(self.ItemButton)

  local ScreenFontL = UIFont.Large;
  local ScreenFontM = UIFont.Medium;
  if getPlayerScreenHeight(getComputer.player) < 1000 then 
    ScreenFontL = UIFont.AutoNormSmall; 
    ScreenFontM = UIFont.AutoNormSmall
  end

  -- print("self.item:getFullType() 1 is: " .. tostring(self.item:getFullType()))
  print("self.item:getType() is: " .. tostring(self.item:getType()))

  PriceNum = ZBYutils.FindModDataItemSell(self.item)
  local intPriceNum = 145
  if self.SellIndex then 
    -- print("self.item:getFullType() is: " .. tostring(self.item:getFullType()))
    local findSell = string.split(ModData.get("ZBAY_PLAYERS").ItemSell[self.SellIndex], "/")
    PriceNum = findSell[3]
    if getGameTime():getDay() < 14 and tostring(self.item:getType()) == "Food" then
      intPriceNum = math.ceil(0 + tonumber(PriceNum))
      if intPriceNum < 70 then
        intPriceNum = math.ceil(intPriceNum * (30/100))
        PriceNum = tostring(intPriceNum)
      end
    end
  end

  if getGameTime():getDay() < 14 and math.ceil((0 + tonumber(PriceNum)) * 1) < 140 and tostring(self.item:getType()) == "Food" then
    self.itemPriceLabel = ISLabel:new(self.ItemButton:getRight() + 30, (ww.height*0.25), getTextManager():getFontHeight(ScreenFontL), "WAS $" .. tostring(ZBYutils.format_int(tostring(tonumber(PriceNum) * 1))) .. ", now ONLY $" .. tostring(ZBYutils.format_int(tostring(math.ceil(tonumber(PriceNum) * (30/100))))) .. "!", 1, 0, 0, 1, ScreenFontL, true)
  else
    self.itemPriceLabel = ISLabel:new(self.ItemButton:getRight() + 30, (ww.height*0.25), getTextManager():getFontHeight(ScreenFontL), "$" .. tostring(ZBYutils.format_int(PriceNum)), 1, 0, 0, 1, ScreenFontL, true)
  end
  ww:addChild(self.itemPriceLabel)

  self.edit = ISButton:new(self.itemPriceLabel:getRight() + 30, (ww.height*0.255), ww.width*0.1, self.itemPriceLabel.height, getText("IGUI_TextBox_Edit"), self, Windows_ZBY_Item.onClick);
  self.edit.internal = "Edit";
  self.edit:initialise();
  self.edit.backgroundColor = {r=0.753, g=0.753, b=0.753, a=1};
  self.edit.borderColor = {r=0, g=0, b=0, a=1};
  self.edit.backgroundColorMouseOver.a = 1;
  self.edit:setVisible(false)
  local checkEdit = getSandboxOptions():getOptionByName("ZBAY.editSell"):getValue();
  if checkEdit then 
    if isClient() then
     if isAdmin() then self.edit:setVisible(true) end
     else self.edit:setVisible(true) 
    end
  end
  local sellbool = false;
  if self.SellIndex then 
    self.edit:setVisible(false) 
    local findSeller = string.split(ModData.get("ZBAY_PLAYERS").ItemSell[self.SellIndex], "/")
    if findSeller[1] == getSpecificPlayer(getComputer.player):getDescriptor():getForename() then
      self.SellCancel = ISButton:new(ww.width - ww.width*0.1 - ww.width*0.05, (ww.height*0.255), ww.width*0.1, self.itemPriceLabel.height, getText("UI_Cancel"), self, Windows_ZBY_Item.onClick);
      self.SellCancel.internal = "SellCancel";
      self.SellCancel:initialise();
      self.SellCancel.backgroundColor = {r=0.753, g=0.753, b=0.753, a=1};
      self.SellCancel.borderColor = {r=0, g=0, b=0, a=1};
      self.SellCancel.backgroundColorMouseOver.a = 1;
      ww:addChild(self.SellCancel)
    end
    sellbool = true;
  end 
  --self.ok.textColor.a = 0;
  ww:addChild(self.edit)

  self.itemInfoLabel = ISLabel:new(self.ItemButton:getRight() + 30, self.itemPriceLabel:getBottom()+getTextManager():getFontHeight(ScreenFontL)+(ww.height*0.05), getTextManager():getFontHeight(ScreenFontM), ZBYutils.getItemInfo(self.item, sellbool), 0, 0, 0, 1, ScreenFontM, true)
  ww:addChild(self.itemInfoLabel)

  local line1 = ISPanel:new(self.ItemButton:getRight() + 30, self.itemInfoLabel:getBottom()+(ww.height*0.05), ww.width - (self.ItemButton:getRight() + 60) , 1)
  line1.backgroundColor = {r=0.753, g=0.753, b=0.753, a=1};
  line1.borderColor = {r=0.565, g=0.565, b=0.565, a=1};
  ww:addChild(line1)

  local itemDeliveryLabelText = getText("UI_ZBY_Delivery")
  if self.SellIndex then itemDeliveryLabelText = getText("UI_SELL_ME") end
  self.itemDeliveryLabel = ISLabel:new(self.ItemButton:getRight() + 30, self.itemInfoLabel:getBottom()+(ww.height*0.075), getTextManager():getFontHeight(ScreenFontM), itemDeliveryLabelText, 0, 0, 0, 1, ScreenFontM, true)
  ww:addChild(self.itemDeliveryLabel)
  local getDay = getSandboxOptions():getOptionByName("ZBAY.DeliveryDay"):getValue();
  local Day = getGameTime():getDay()+1 + getDay;
  local Month = getGameTime():getMonth()+1;
  local itemDeliveryDateText = tostring(Month) .. " / " .. tostring(Day)
  if self.SellIndex then 
    local findSeller = string.split(ModData.get("ZBAY_PLAYERS").ItemSell[self.SellIndex], "/")
    itemDeliveryDateText = tostring(findSeller[1])
  end
  self.itemDeliveryDateLabel = ISLabel:new(self.ItemButton:getRight() + 30, self.itemDeliveryLabel:getBottom()+(ww.height*0.01), getTextManager():getFontHeight(UIFont.Small), itemDeliveryDateText, 0, 0, 0, 1, UIFont.Small, true)
  ww:addChild(self.itemDeliveryDateLabel)

  local line2 = ISPanel:new(self.ItemButton:getRight() + 30, self.itemDeliveryDateLabel:getBottom()+(ww.height*0.025), ww.width - (self.ItemButton:getRight() + 60) , 1)
  line2.backgroundColor = {r=0.753, g=0.753, b=0.753, a=1};
  line2.borderColor = {r=0.565, g=0.565, b=0.565, a=1};
  ww:addChild(line2)

  self.itemQuantityLabel = ISLabel:new(self.ItemButton:getRight() + 30, self.itemDeliveryDateLabel:getBottom()+(ww.height*0.05), getTextManager():getFontHeight(ScreenFontM), getText("UI_ZBY_Quantity"), 0, 0, 0, 1, ScreenFontM, true)
  ww:addChild(self.itemQuantityLabel)
  local itemQuantityNum = 1
  if self.SellIndex then 
    local findQ = string.split(ModData.get("ZBAY_PLAYERS").ItemSell[self.SellIndex], "/")
    itemQuantityNum = findQ[4]
  end 
  self.itemQuantity = ISTextEntryBox:new(tostring(itemQuantityNum), self.ItemButton:getRight() + 30, self.itemQuantityLabel:getBottom()+(ww.height*0.01), 50, 20);
	self.itemQuantity:initialise();
	self.itemQuantity:instantiate();
  local color = ColorInfo.new(0, 0, 0, 1)
  self.itemQuantity.javaObject:setTextColor(color)
  if self.SellIndex then self.itemQuantity.javaObject:setEditable(false); end
  self.itemQuantity.backgroundColor = {r=0.753, g=0.753, b=0.753, a=1};
	self.itemQuantity:setOnlyNumbers(true);
	ww:addChild(self.itemQuantity);

  local cartText = getText("UI_ZBY_addCart")
  if self.SellIndex then cartText = getText("UI_ZBY_TradeSellItem") end
  self.ItemCartButton = ISButton:new(self.ItemButton:getRight() + 30, self.itemQuantityLabel:getBottom()+(ww.height*0.1), ww.width - self.ItemButton:getRight() - 60, (ww.height*0.1), cartText, self, Windows_ZBY_Item.onClick);
  self.ItemCartButton.internal = "addCart";
  self.ItemCartButton:initialise();
  self.ItemCartButton.backgroundColor = {r=0.992, g=0.22, b=0.31, a=1};
  self.ItemCartButton.backgroundColorMouseOver.a = 1;
  --self.ItemButton.textColor.a = 0;
  ww:addChild(self.ItemCartButton)

  --self.toolRender = DoItemToolTip:new(inv, self.ItemButton:getRight() + 30, self.itemInfoLabel:getBottom() + 10, 300, 200, ww)
  --print(tostring(ww:getX() + self.ItemButton:getRight() + 30))
  --self.toolRender:initialise();
  --self.toolRender:setCharacter(getPlayer());
  --self.toolRender:setOwner(ww);
  --ww:addChild(self.toolRender);

end

function Windows_ZBY_Item:downEnter()
  --onCommandEntered
  Windows_ZBY_Item.search:forceClick()
end

function Windows_ZBY_Item:addItemTooltip(dx, dy)
  local items = Windows_ZBY_Item.item;
  if not Windows_ZBY_Item.SellIndex then items = InventoryItemFactory.CreateItem(Windows_ZBY_Item.item:getModuleName() .. "." .. Windows_ZBY_Item.item:getName()); end
  Windows_ZBY_Item:removeItemTooltip(dx, dy);
  Windows_ZBY_Item.toolRender = ISToolTipInv:new(items);
  Windows_ZBY_Item.toolRender:initialise();
  Windows_ZBY_Item.toolRender:addToUIManager();
  Windows_ZBY_Item.toolRender:setVisible(true);
end

function Windows_ZBY_Item:removeItemTooltip(dx, dy)
  if Windows_ZBY_Item.toolRender then
    Windows_ZBY_Item.toolRender:removeFromUIManager();
    Windows_ZBY_Item.toolRender:setVisible(false);
  end
end



function Windows_ZBY_Item:onClick(button)

	if button.internal == "addCart" then 
	  if self.WindowType == "main" and not self.SellIndex then self.target.cart:setVisible(true) end
    if tonumber(self.itemQuantity:getText()) <= 0 then
      local color = ColorInfo.new(1, 0, 0, 1)
      self.itemQuantity.javaObject:setTextColor(color) 
     else
       if not self.SellIndex then
         ZBYutils.addCartList(self.item, tonumber(self.itemQuantity:getText()))
         ww:setVisible(false)
         ww:removeFromUIManager()
         ZBYutils.SetUI("Windows_ZBY_Item", nil)
       else
       local haveMoney = ZBYutils.getMoneys()
       if haveMoney < tonumber(PriceNum) then
         local ewidth = ww.width - (ww.width / 3)
         local ehegiht = 50
         local errorWindow = Windows_ZBY_Error:new("ZBAY:ERROR", (ww.width / 2) - (ewidth / 2), (ww.height / 2) - (ehegiht / 2), ewidth, ehegiht, ww, nil, self.player)
         errorWindow:initialise();
         ww:addChild(errorWindow)
         else
         ww:setVisible(false)
         ww:removeFromUIManager()
         ZBYutils.SetUI("Windows_ZBY_Item", nil)
         ZBYutils.removeMoneys(tonumber(PriceNum))
         --local inv = InventoryItemFactory.CreateItem(self.item:getFullName());
         local inv = self.item;
        -- getSpecificPlayer(getComputer.player):getInventory():AddItems(self.item, tonumber(self.itemQuantity:getText()))
         --ZBYutils.addItems(getComputer.player, self.item, tonumber(self.itemQuantity:getText()))
         for i=1,tonumber(self.itemQuantity:getText()) do
           print("additem : " .. tostring(i))
           local invitem = InventoryItemFactory.CreateItem(self.item:getFullType());
           ZBYutils.setSellItemInfo(invitem, self.SellIndex)
           getSpecificPlayer(getComputer.player):getInventory():DoAddItem(invitem)
         end
         if isClient() then
           local findseller = string.split(ModData.get("ZBAY_PLAYERS").ItemSell[self.SellIndex], "/")
           local seller = findseller[1]
           local findseller = false;
          
           for i=0,getOnlinePlayers():size()-1 do
             local pl = getOnlinePlayers():get(i);
             --print("playerName : " .. tostring(pl:getDisplayName()))
             if pl:getDisplayName() == seller then
               findseller = true;
               sendClientCommand(getSpecificPlayer(getComputer.player), "ZBAY", "giveMoney", { name = seller, price = tonumber(PriceNum), id = pl:getOnlineID() }) 
               break
             end
           end
           if not findseller then 
             if not ModData.get("ZBAY_PLAYERS").NONEPLAYER[seller] then 
               ModData.get("ZBAY_PLAYERS").NONEPLAYER[seller] = {};
             end
             table.insert(ModData.get("ZBAY_PLAYERS").NONEPLAYER[seller], tonumber(PriceNum)) 
           end
           else 
              ZBYutils.convertMoneys(tonumber(PriceNum), getSpecificPlayer(getComputer.player))
            --getSpecificPlayer(getComputer.player):getInventory():AddItems("Base.Money", tonumber(PriceNum))
         end
         --getSoundManager():PlayWorldSound("buying", getComputer.object:getSquare(), 0, 5, 1, true);
         ZBYutils.playSound(getComputer.object, "buying", 5)
         table.remove(ModData.get("ZBAY_PLAYERS").ItemSell, self.SellIndex)
         if ModData.get("ZBAY_PLAYERS").ItemSell_info and ModData.get("ZBAY_PLAYERS").ItemSell_info[self.SellIndex] then
           table.remove(ModData.get("ZBAY_PLAYERS").ItemSell_info, self.SellIndex)
         end
         ModData.transmit("ZBAY_PLAYERS")
         local refreshItem = {}
         self.target:getSellItems(refreshItem)
         self.target:drawItemList(#refreshItem, "select_Category", getText("UI_ZBY_UserSale"), refreshItem)
       end
     end
    end
    if self.WindowType == "subCart" then 
      self.target:setVisible(true) 
      --print(tostring(self.target.Windows_ZBY_Cart.list))
      self.target.Windows_ZBY_Cart.totalSell = 0;
      self.target.Windows_ZBY_Cart.list:clear()
      self.target.Windows_ZBY_Cart.list.itemheight = 40;
      --self.target.Windows_ZBY_Cart.list.tooltip = nil;
      self.target.Windows_ZBY_Cart:initList()
    end
  end

  if button.internal == "Search" then 
    if ZBYutils.GetUI("Windows_ZBY") then
      ZBYutils.GetUI("Windows_ZBY"):setVisible(false)
      ZBYutils.GetUI("Windows_ZBY"):removeFromUIManager()
    end
    ww:setVisible(false)
    ww:removeFromUIManager()
    local window = Windows_ZBY:new("ZBAY", ww:getX(), ww:getY(), ww.width, ww.height, self, self.searchBox:getText(), self.player)
    window:initialise();
    --window:addToUIManager();
    ZBYutils.GetUI("ComputerMainScreen"):addChild(window)
    ZBYutils.SetUI("Windows_ZBY", window)
  end

  if button.internal == "Home" then 
    ww:setVisible(false)
    ww:removeFromUIManager()
    ZBYutils.SetUI("Windows_ZBY_Item", nil)
  end

  if button.internal == "Edit" then
    local ewidth = ww.width - (ww.width / 3)
    local ehegiht = 180
    local editWindow = Windows_ZBY_Edit:new("ZBAY:EDIT", (ww.width / 2) - (ewidth / 2), (ww.height / 2) - (ehegiht / 2), ewidth, ehegiht, self, ww, self.player, self.item, "Item")
    editWindow:initialise();
    --itemWindow:addToUIManager();
    ww:addChild(editWindow)
  end

  if button.internal == "SellCancel" then
    ww:setVisible(false)
    ww:removeFromUIManager()
    ZBYutils.SetUI("Windows_ZBY_Item", nil)
    for i=1,tonumber(self.itemQuantity:getText()) do
      local invitem = InventoryItemFactory.CreateItem(self.item:getFullType());
      ZBYutils.setSellItemInfo(invitem, self.SellIndex)
      getSpecificPlayer(getComputer.player):getInventory():DoAddItem(invitem)
    end
    table.remove(ModData.get("ZBAY_PLAYERS").ItemSell, self.SellIndex)
    if ModData.get("ZBAY_PLAYERS").ItemSell_info and ModData.get("ZBAY_PLAYERS").ItemSell_info[self.SellIndex] then
      table.remove(ModData.get("ZBAY_PLAYERS").ItemSell_info, self.SellIndex)
    end
    ModData.transmit("ZBAY_PLAYERS")
    local refreshItem = {}
    self.target:getSellItems(refreshItem)
    self.target:drawItemList(#refreshItem, "select_Category", getText("UI_ZBY_UserSale"), refreshItem)
  end
	
	if self.onclick ~= nil then
		button.player = self.player;
		self.onclick(self.target, button, self.max);
	end
end

function Windows_ZBY_Item:new(text, x, y, width, height, target, index, player, item, WindowType)
local o = WindowsInterface:new(text, x, y, width, height, self, nil, player)
o.itemPriceLabel = self.itemPriceLabel;
self.WindowType = WindowType;
self.SellIndex = index;
self.item = item;
self.target = target;
ww = o;
self:initialise()
return o;
end

