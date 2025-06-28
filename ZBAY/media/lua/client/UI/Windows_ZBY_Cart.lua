require "ISUI/ISPanelJoypad"

local ZBYutils = require('ZBAY_Utils')
local getComputer = require('GetComputerInfo')

local colorList;
local ww;

Windows_ZBY_Cart = ISPanelJoypad:derive("Windows_ZBY_Cart");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)


function Windows_ZBY_Cart:initialise()
  colorList = {};
  self.Home = ISButton:new(10, 33, (ww.width*0.25), 32, "", self, Windows_ZBY_Cart.onClick);
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

  self.search = ISButton:new(self.searchBox:getRight()+10, 33, 32, 32, "", self, Windows_ZBY_Cart.onClick);
  self.search.internal = "Search";
  self.search:initialise();
  self.search.backgroundColor.a = 0;
  self.search.backgroundColorMouseOver.a = 1;
  self.search.borderColor.a = 0;
  self.search:setImage(getTexture("media/textures/search_web.png"));
  self.search.textColor.a = 0;
  ww:addChild(self.search)

  self.backColor = ISPanel:new(0, self.search:getBottom()+5, ww.width, ww.height - self.search:getBottom());
  self.backColor.borderColor = ww.borderColor
  self.backColor.backgroundColor = {r=0.753, g=0.753, b=0.753, a=1};
  ww:addChild(self.backColor);

  local ScreenFontM = UIFont.Medium;
  local ScreenFontS = UIFont.Small;
  if getPlayerScreenHeight(getComputer.player) < 1000 then 
    ScreenFontM = UIFont.AutoNormSmall
    ScreenFontS = UIFont.AutoNormSmall
  end

  ---shipping---
  local sHeight =  (ww.height*0.06) + (getTextManager():getFontHeight(ScreenFontM)+(getTextManager():getFontHeight(ScreenFontS)*2))
  self.shipping = ISPanel:new((ww.width*0.3)+(ww.width*0.05), 85, ww.width - (ww.width*0.4), sHeight);
  self.shipping.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
  self.shipping.backgroundColor = {r=1, g=1, b=1, a=1};
  --self.shipping:addScrollBars();
  --self.shipping:setScrollChildren(true);
 
  self.shippingAddress = ISLabel:new(20, (ww.height*0.03), getTextManager():getFontHeight(ScreenFontM), getText("UI_ZBY_Address"), 0, 0, 0, 1, ScreenFontM, true)
  self.shippingUserName = ISLabel:new(20, self.shippingAddress:getBottom(), getTextManager():getFontHeight(ScreenFontS), tostring(getPlayer():getDescriptor():getForename()), 0, 0, 0, 1, ScreenFontS, true)
  self.shippingUserName.tooltip = getText("UI_ZBY_CartCheckMoney") .. "$" .. tostring(ZBYutils.format_int((ZBYutils.getMoneys()+ZBYutils.getCardMoneys(getComputer.player))))
  self.shippingDetailAddress = ISLabel:new(20, self.shippingUserName:getBottom(), getTextManager():getFontHeight(ScreenFontS), getText("UI_ZBY_baseAddress"), 0, 0, 0, 1, ScreenFontS, true)
  local findbox = ZBYutils.Findmailbox()
  if findbox then
    ZBYutils.setWorldItemSq(getSquare(findbox:getX(), findbox:getY(), findbox:getZ()))
    self.shippingDetailAddress:setName("x : " .. tostring(round(findbox:getX(), 0)) .. " / y : " .. tostring(round(findbox:getY(), 0)) .. " / z : " .. tostring(round(findbox:getZ(), 0)))
  end

  self.location = ISButton:new(self.shippingAddress:getRight()+5, (ww.height*0.01625), getTextManager():getFontHeight(ScreenFontM), getTextManager():getFontHeight(ScreenFontM)+5, "", self, Windows_ZBY_Cart.onClick);
  self.location.internal = "Location";
  self.location:initialise();
  self.location.backgroundColor.a = 0;
  self.location.backgroundColorMouseOver.a = 1;
  self.location.borderColor.a = 0;
  self.location:setImage(getTexture("media/textures/shipping_location.png"));
  self.location:forceImageSize(getTextManager():getFontHeight(ScreenFontM), getTextManager():getFontHeight(ScreenFontM)+5);
  self.location.textColor.a = 0;

  self.shipping:addChild(self.shippingAddress)
  self.shipping:addChild(self.shippingUserName)
  self.shipping:addChild(self.shippingDetailAddress)
  self.shipping:addChild(self.location)
  ww:addChild(self.shipping)
  ---Summary---
  self.summary = ISPanel:new((ww.width*0.3)+(ww.width*0.05), self.shipping:getBottom()+(ww.height*0.02), ww.width - (ww.width*0.4), 0);
  self.summary.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
  self.summary.backgroundColor = {r=1, g=1, b=1, a=1};
  --self.shipping:addScrollBars();
  --self.shipping:setScrollChildren(true);
 
  self.summarylabel = ISLabel:new(20, (ww.height*0.02), getTextManager():getFontHeight(ScreenFontM), getText("UI_ZBY_Summary"), 0, 0, 0, 1, ScreenFontM, true)
  self.totalitemcost = ISLabel:new(20, self.summarylabel:getBottom(), getTextManager():getFontHeight(ScreenFontS), "", 0, 0, 0, 1, ScreenFontS, true)
  self.totalshipping = ISLabel:new(20, self.totalitemcost:getBottom(), getTextManager():getFontHeight(ScreenFontS), getText("UI_ZBY_shipping"), 0, 0, 0, 1, ScreenFontS, true)

  self.cardPayment = ISButton:new(self.totalitemcost:getRight()+20, self.summarylabel:getBottom()-1, getTextManager():getFontHeight(ScreenFontM), getTextManager():getFontHeight(ScreenFontM), "", self, Windows_ZBY_Cart.onClick);
  self.cardPayment.internal = "cardPayment";
  self.cardPayment:initialise();
  self.cardPayment.backgroundColor.a = 0;
  self.cardPayment.backgroundColorMouseOver.a = 0;
  self.cardPayment.borderColor.a = 0;
  local inv = InventoryItemFactory.CreateItem("Base.CreditCard");
  self.cardPayment:setImage(inv:getTex());
  self.cardPayment:forceImageSize(getTextManager():getFontHeight(ScreenFontM), getTextManager():getFontHeight(ScreenFontM));
  self.cardPayment.textColor.a = 0;
  self.cardTickBox = ISTickBox:new(self.cardPayment:getRight()+5, self.summarylabel:getBottom()-2.5, 20, 20, "", self, self.onTickBox);
  self.cardTickBox.choicesColor = {r=1, g=1, b=1, a=1}
  self.cardTickBox.borderColor = {r=0, g=0, b=0, a=1};
  self.cardTickBox.tooltip = getText("UI_Card_tooltip")
  self.cardTickBox:addOption("")
  self.cardTickBox:initialise();

  local quickDeliveryPrice = getSandboxOptions():getOptionByName("ZBAY.quickDelivery"):getValue();
  local quickDeliveryText = getText("UI_ZBY_quickDelivery") .. "($" .. tostring(quickDeliveryPrice) .. ") : "
  self.quickDelivery = ISLabel:new(self.totalshipping:getRight()+20, self.totalitemcost:getBottom(), getTextManager():getFontHeight(ScreenFontS), quickDeliveryText, 0, 0, 0, 1, ScreenFontS, true)
  self.quickDelivery:setColor(0, 0.392, 0)
  self.TickBox = ISTickBox:new(self.quickDelivery:getRight()+5, self.totalitemcost:getBottom()-2.5, 20, 20, "", self, self.onTickBox);
  self.TickBox.choicesColor = {r=1, g=1, b=1, a=1}
  self.TickBox.borderColor = {r=0, g=0, b=0, a=1};
  self.TickBox:addOption("")
  self.TickBox:initialise();

  self.line = ISPanel:new(20, self.totalshipping:getBottom()+10, self.summary.width - 40, 1);
  self.line.borderColor = {r=0.4, g=0.4, b=0.4, a=0};
  self.line.backgroundColor = {r=0.753, g=0.753, b=0.753, a=1};

  self.total = ISLabel:new(20, self.line:getBottom()+10, getTextManager():getFontHeight(ScreenFontM), "", 0, 0, 0, 1, ScreenFontM, true)

  self.orderButton = ISButton:new(20, self.total:getBottom()+10, self.summary.width - 40, (ww.height*0.1), getText("UI_ZBY_order"), self, Windows_ZBY_Cart.onClick);
  self.orderButton.internal = "Order";
  self.orderButton:initialise();
  self.orderButton.backgroundColor = {r=0.992, g=0.22, b=0.31, a=1};
  self.orderButton.backgroundColorMouseOver.a = 1;
  self.summary.height = self.orderButton:getBottom() + (ww.height*0.02)

  self.summary:addChild(self.summarylabel)
  self.summary:addChild(self.totalitemcost)
  self.summary:addChild(self.totalshipping)
  self.summary:addChild(self.cardPayment)
  self.summary:addChild(self.cardTickBox)
  self.summary:addChild(self.quickDelivery)
  self.summary:addChild(self.TickBox)
  self.summary:addChild(self.line)
  self.summary:addChild(self.total)
  self.summary:addChild(self.orderButton)
  ww:addChild(self.summary)

  self.cartlabel = ISLabel:new(5, 80, getTextManager():getFontHeight(UIFont.NewLarge), getText("UI_ZBY_CartList") .. tostring(#ZBYutils.getCartItem()), 0, 0, 0, 1, UIFont.NewLarge, true)
  ww:addChild(self.cartlabel)

  local listHeight = ww.height - (85 + getTextManager():getFontHeight(UIFont.NewLarge))
  self.list = ISScrollingListBox:new(0, 85 + getTextManager():getFontHeight(UIFont.NewLarge), (ww.width*0.3), listHeight - 10);
  --self.list = ISScrollingListBox:new(0, 80, 160, ww:getBottom());
  self.list:initialise();
  self.list:instantiate();
  self.list:setFont(UIFont.Medium,10);
  self.list.selected = -1;
  self.list.backgroundColor = {r=1, g=1, b=1, a=1};
  self.list.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
  self:initList()
  --self.list.itemPadY = 20;
  self.list.itemheight = 20;
  self.list.drawBorder = true;
  --self.list:insertItem(1, "type", "type"); 
  --self.list.onMouseDown = self.onMouseDown2;
  self.list.onMouseDoubleClick = self.onMouseDoubleClick2;
  self.list.onRightMouseDown = self.onRightMouseDown2;
  self.list.doDrawItem = self.doDrawItemIcon;
  ww:addChild(self.list);
end

function Windows_ZBY_Cart:downEnter()
  --onCommandEntered
  Windows_ZBY_Cart.search:forceClick()
end

function Windows_ZBY_Cart:onTickBox(index, selected)
	if self.TickBox.selected[1] then
    local quickDeliveryPrice = getSandboxOptions():getOptionByName("ZBAY.quickDelivery"):getValue();
    local total = tonumber(self.totalSell) + tonumber(quickDeliveryPrice)
    self.total:setName(getText("UI_ZBY_totalPrice") .. tostring(ZBYutils.format_int(total)))
   else self.total:setName(getText("UI_ZBY_totalPrice") .. tostring(ZBYutils.format_int(self.totalSell)))
	end
end

function Windows_ZBY_Cart:initList()
  local getCartItemTable = ZBYutils.getCartItem();
  local getCartItemCount = ZBYutils.getCartItemCount();

  

  for i=1, #getCartItemTable do
      local item = getCartItemTable[i]
      local itemCount = getCartItemCount[i]
      local itemType1 = tostring(item:getType())
      --combo:addOption(displayCategoryName)
      if ZBYutils.FindModDataItemSell(item) < 70 and getGameTime():getDay() < 14 and itemType1 == "Food" then
        local player = getSpecificPlayer(0); player:Say("Website says: 'Hungry for great deals? Get 70 PERCENT OFF on all foods and ingredients and on all other items under $70! Offer ends in " .. tostring(14 - getGameTime():getDay()) .. " days! (some exceptions may apply)'"); player:Say("........................................................................................................................"); player:Say("........................................................................................................................"); player:Say("........................................................................................................................"); player:Say("........................................................................................................................"); player:Say("........................................................................................................................"); player:Say("........................................................................................................................")
        self.totalSell = self.totalSell + math.ceil(((ZBYutils.FindModDataItemSell(item) * itemCount) * (30/100)))
      else
        if getGameTime():getDay() < 14 then
          self.totalSell = self.totalSell + math.ceil(((ZBYutils.FindModDataItemSell(item) * itemCount) * (1)))
        end
        if getGameTime():getDay() >= 14 and getGameTime():getDay() < 21 then
          self.totalSell = self.totalSell + (ZBYutils.FindModDataItemSell(item) * itemCount)
        end
        if getGameTime():getDay() >= 21 then
          local player = getSpecificPlayer(0); player:Say("the website doesn't seem to be working-- I guess whoever used to be running it isn't around anymore...")
          getSpecificPlayer(0):getSecondaryHandItem():getInventory():FindAndReturn("Base.NoYouCannotBuyThingsAnymoreStopTrying"):getExtraItems()
        end
      end      
      if itemCount > 1 then
       self.list:insertItem(i, item:getDisplayName() .. " (" .. tostring(itemCount) .. ")", item); 
       else  self.list:insertItem(i, item:getDisplayName(), item); 
      end
  end
  self.totalitemcost:setName(getText("UI_ZBY_totalitemPrice") .. tostring(ZBYutils.format_int(self.totalSell)))
  self.total:setName(getText("UI_ZBY_totalPrice") .. tostring(ZBYutils.format_int(self.totalSell)))
  self.cardPayment:setX(self.totalitemcost:getRight()+20)
  self.cardTickBox:setX(self.cardPayment:getRight()+5)
end

function Windows_ZBY_Cart:onRightMouseDown2(x, y)

	if #self.items == 0 then return end
	local row = self:rowAt(x, y)

	if row > #self.items then
		row = #self.items;
	end
	if row < 1 then
		row = 1;
	end

	getSoundManager():playUISound("UISelectListItem")

  self.selected = row;

  local getItem = ZBYutils.getCartItem()[self.selected]
  local getItemSell = ZBYutils.FindModDataItemSell(getItem)
  local getItemCount = ZBYutils.getCartItemCount()[self.selected]
  Windows_ZBY_Cart.totalSell = Windows_ZBY_Cart.totalSell - (getItemSell * getItemCount)
  Windows_ZBY_Cart.totalitemcost:setName("Total item costs : $" .. tostring(Windows_ZBY_Cart.totalSell))
  Windows_ZBY_Cart.total:setName("Total : $" .. tostring(Windows_ZBY_Cart.totalSell))
  ZBYutils.removeCartList(self.selected)
  self:removeItemByIndex(self.selected)
  local num = tostring(#self.items)
  --print(tostring(#self.items) .. "/" .. tostring(#ZBYutils.getCartItem()))
  Windows_ZBY_Cart.cartlabel:setName("Cart List : " .. num)
  if self.tooltip and self.tooltip:isVisible() then
    self.tooltip:setVisible(false)
  end
end

function Windows_ZBY_Cart:onMouseDoubleClick2(x, y)

	if #self.items == 0 then return end
	local row = self:rowAt(x, y)

	if row > #self.items then
		row = #self.items;
	end
	if row < 1 then
		row = 1;
	end

	getSoundManager():playUISound("UISelectListItem")

  self.selected = row;

  ww:setVisible(false)
  local item = ZBYutils.getCartItem()[self.selected]
  local itemWindow = Windows_ZBY_Item:new("ZBAY_" .. tostring(item:getDisplayName()), ww:getX(), ww:getY(), ww.width, ww.height, ww, nil, self.player, item, "subCart")
  itemWindow:initialise();
  --itemWindow:addToUIManager();
  ZBYutils.GetUI("ComputerMainScreen"):addChild(itemWindow)
  ZBYutils.SetUI("Windows_ZBY_Item", itemWindow)
end

function Windows_ZBY_Cart:doDrawItemIcon(y, itemlist, alt)
	if not itemlist.height then itemlist.height = self.itemheight end -- compatibililtyW
  --print(tostring(itemlist.height))
    local r,g,b = 0,0,0;
    if not self.tooltip then
      --print("new tip")
     self.tooltip = ISToolTip:new()
     self.tooltip.borderColor = {r=0.4, g=0.4, b=0.4, a=0};
     self.tooltip.descriptionPanel.backgroundColor = {r=0, g=0, b=0, a=0};
     self.tooltip:setVisible(false)
     self.tooltip:initialise()
     self.tooltip.followMouse = false;
     self:addChild(self.tooltip)
     --self.tooltip:addToUIManager() 
    end
    if self.selected == itemlist.index then
      self:drawRect(0, (y), self:getWidth(), itemlist.height-1, 0.3, 0.7, 0.35, 0.15);
    end
   if self.tooltip then
     if self.mouseoverselected ~= -1 and self.items[self.mouseoverselected] then
       --print(tostring(self.mouseoverselected))
       self.tooltip:setX(getMouseX()-ww.width+(self.tooltip.width / 2)+16)
       self.tooltip:setY(getMouseY()-ww.height)
       self.tooltip:setVisible(true)
       --self.tooltip.description = itemlist.text 
       self.tooltip.description = self.items[self.mouseoverselected].text
     end
     if self.mouseoverselected == -1 then
      --print(tostring(self.mouseoverselected))
      self.tooltip:setVisible(false)
     end
   end
	self:drawRectBorder(0, (y), self:getWidth(), itemlist.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
	local itemPadY = self.itemPadY or (itemlist.height - self.fontHgt) / 2
	self:drawText(itemlist.text, (ww.width*0.09), (y)+itemPadY, r, g, b, 1, UIFont.Medium);
  local tex = ZBYutils.getItemIconTexture(itemlist.item)
  local inv = InventoryItemFactory.CreateItem(itemlist.item:getFullName());
  if not colorList[itemlist.item:getFullName()] then
    colorList[itemlist.item:getFullName()] = inv;
  end

  --if tex then self:drawTextureScaledAspect2(tex, -80, (y+5), self:getWidth(), itemlist.height-10,  1, inv:getR(), inv:getG(), inv:getB()); end
  if tex then 
    --print(itemlist.item:getFullName() .. " : " .. tostring(inv:getR()) .. "/" .. tostring(inv:getG()) .. "/" .. tostring(inv:getB()))
    --self:drawTextureScaledAspect2(tex, -80, (y+5), self:getWidth(), itemlist.height-10,  1, 1, 1, 1); 
    self:drawTextureScaledAspect(tex, -(ww.width*0.11), (y+5), self:getWidth(), itemlist.height-10,  colorList[itemlist.item:getFullName()]:getA(), colorList[itemlist.item:getFullName()]:getR(), colorList[itemlist.item:getFullName()]:getG(), colorList[itemlist.item:getFullName()]:getB()); 
  end
	y = y + itemlist.height;
	return y;

end



function Windows_ZBY_Cart:onClick(button)
  --print("button :: " .. tostring(button.internal))
  if button.internal == "Search" then 
    if ZBYutils.GetUI("Windows_ZBY") then
      ZBYutils.GetUI("Windows_ZBY"):setVisible(false)
      ZBYutils.GetUI("Windows_ZBY"):removeFromUIManager()
    end
    ww:setVisible(false)
    ww:removeFromUIManager()
    ZBYutils.SetUI("Windows_ZBY_Cart", nil)
    local window = Windows_ZBY:new("ZBAY", ww:getX(), ww:getY(), ww.width, ww.height, self, self.searchBox:getText(), self.player)
    window:initialise();
    ZBYutils.GetUI("ComputerMainScreen"):addChild(window)
    --window:addToUIManager();
    ZBYutils.SetUI("Windows_ZBY", window)
  end

  if button.internal == "Home" then 
    ww:setVisible(false)
    ww:removeFromUIManager()
    ZBYutils.SetUI("Windows_ZBY_Cart", nil)
  end

  if button.internal == "Location" then 
    ZBYutils.setAllUI(false, false)
    local playerObj = getSpecificPlayer(getComputer.player)
    local bo = FindAddress:new("", "", playerObj)
    getCell():setDrag(bo, getComputer.player)
  end

  if button.internal == "Order" then 
    local ewidth = ww.width - (ww.width / 3)
    local ehegiht = 50
    if not ZBYutils.getCartItem() or #ZBYutils.getCartItem() < 1 then
      local errorWindow = Windows_ZBY_Error:new("ZBAY:ERROR", (ww.width / 2) - (ewidth / 2), (ww.height / 2) - (ehegiht / 2), ewidth, ehegiht, ww, nil, self.player)
      errorWindow:initialise();
      errorWindow.Windows_ZBY_Error.text:setName(getText("UI_ZBY_nonCart"))
      ww:addChild(errorWindow)
      return
    end
    if ZBYutils.getWorldItemSq() then
      local haveMoney = ZBYutils.getMoneys()
      local haveCard = getSpecificPlayer(getComputer.player):getInventory():getCountTypeRecurse("Base.CreditCard");
      if self.cardTickBox.selected[1] then 
        if haveCard and haveCard > 0 then
         haveMoney = ZBYutils.getCardMoneys(getComputer.player) 
        end
        if not haveCard or haveCard < 1 then
          local errorWindow = Windows_ZBY_Error:new("ZBAY:ERROR", (ww.width / 2) - (ewidth / 2), (ww.height / 2) - (ehegiht / 2), ewidth, ehegiht, ww, nil, self.player)
          errorWindow:initialise();
          errorWindow.Windows_ZBY_Error.text:setName(getText("UI_Card_not"))
          ww:addChild(errorWindow)
          return
        end
      end
      local quickDeliveryPrice = getSandboxOptions():getOptionByName("ZBAY.quickDelivery"):getValue();
      if self.TickBox.selected[1] then self.totalSell = self.totalSell + tonumber(quickDeliveryPrice) end
      if self.totalSell <= haveMoney then
       if self.cardTickBox.selected[1] then
         local m = ModData.get("ZBAY_PLAYERS").PLAYER[getSpecificPlayer(getComputer.player):getDisplayName()].ATM_MONEY
         ModData.get("ZBAY_PLAYERS").PLAYER[getSpecificPlayer(getComputer.player):getDisplayName()].ATM_MONEY = tonumber(m)-self.totalSell
         ModData.transmit("ZBAY_PLAYERS")
         else ZBYutils.removeMoneys(self.totalSell)
       end
       ZBYutils.playSound(getComputer.object, "buying", 5)
       local quick = false;
       if self.TickBox.selected[1] then quick = true; end
       ZBYutils.addOrderItems(quick, self.totalSell) 
       self.target.cart:setVisible(false)
       ww:setVisible(false)
       ww:removeFromUIManager()
       ZBYutils.SetUI("Windows_ZBY_Cart", nil)
       else
        local errorWindow = Windows_ZBY_Error:new("ZBAY:ERROR", (ww.width / 2) - (ewidth / 2), (ww.height / 2) - (ehegiht / 2), ewidth, ehegiht, ww, nil, self.player)
        errorWindow:initialise();
        --itemWindow:addToUIManager();
        ww:addChild(errorWindow)
      end
     else self.location:forceClick()
    end
  end
	
	if self.onclick ~= nil then
		button.player = self.player;
		self.onclick(self.target, button, self.max);
	end
end


function Windows_ZBY_Cart:new(text, x, y, width, height, target, onclick, player)
local o = WindowsInterface:new(text, x, y, width, height, self, nil, player)
o.Windows_ZBY_Cart = self;
self.target = target;
self.totalSell = 0;
ww = o;
self:initialise()
o.shippingDetailAddress = self.shippingDetailAddress;
return o;
end

