require "TimedActions/ISBaseTimedAction"


StartUpComputer = ISBaseTimedAction:derive("StartUpComputer")

local ZBYutils = require('ZBAY_Utils')
local getComputer = require('GetComputerInfo')
local com_switch = false;

function StartUpComputer:changeCom()
	local changeCom = ZBYutils.GetChangeComputer(getComputer.name);
	getComputer.object:setSpriteFromName("appliances_com_01_" .. tostring(changeCom))
	if isClient() then getComputer.object:transmitUpdatedSpriteToServer() end
	getComputer.name = changeCom
end

function StartUpComputer:isValid()
	return true
end

function StartUpComputer:update()
	if self.onofftype == "on" then
		if (getTimestampMs() - self.t > 1500) and not com_switch then
			self:changeCom()
	        ZBYutils.AddLight(getComputer.object) 
			self.sound = getSoundManager():PlayWorldSound("computer_on", self.computer:getSquare(), 0, 5, 1, true);
			self.sound:setVolume(0.3)
			com_switch = true;
		end
		if (getTimestampMs() - self.t > 3500) then
		 ISBaseTimedAction.forceComplete(self)
		end
	end
	if self.onofftype == "off" and (getTimestampMs() - self.t > 2000) then
		ISBaseTimedAction.forceComplete(self)
	end
end

function StartUpComputer:start()
	if getGameTime():getDay() < 14 then
		local player = getSpecificPlayer(0); player:Say("I saw that ZBAY was doing a 70 percent off sale on all items under 70 bucks.... wonder if it still applies. I think the end date for the sale was supposed to be something like " .. tostring(14 - getGameTime():getDay()) .. " days from now.")
	end

	self.t = getTimestampMs()
	if self.onofftype == "on" then
	 getSoundManager():PlayWorldSound("computer_switch", self.computer:getSquare(), 0, 5, 1, true);
	end
	if self.onofftype == "off" then
	 self.sound = getSoundManager():PlayWorldSound("computer_off", self.computer:getSquare(), 0, 5, 1, true);
	end
	if self.sound then self.sound:setVolume(0.3) end
end

function StartUpComputer:stop()
	--print "stop"
	self.sound:stop();
    ISBaseTimedAction.stop(self)
end

function StartUpComputer:perform()
	--print "perform"
	if self.sound then self.sound:stop(); end
	com_switch = false;
	if self.onofftype == "on" then
	 local x = getPlayerScreenWidth(self.player) / 2 - getPlayerScreenWidth(self.player) / 4
	 local y = getPlayerScreenHeight(self.player) / 2 - getPlayerScreenHeight(self.player) / 4
	 local CMS = ComputerMainScreen:new(self.computer, "", x, y, getPlayerScreenWidth(self.player) / 2, getPlayerScreenHeight(self.player) / 2, self, nil, self.player)
	 CMS:initialise();
	 CMS:addToUIManager();
	 ZBYutils.SetUI("ComputerMainScreen", CMS)
	 Events.OnTick.Add(ComputerMainScreen_updateTime)
	end
	if self.onofftype == "off" then
	 self:changeCom()
	 ZBYutils.RemoveLight(getComputer.object)
	end
	ISBaseTimedAction.perform(self)
end

function StartUpComputer:new(player, computer, onofftype)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.player = player
	self.onofftype = onofftype;
	o.computer = computer
	o.character = getSpecificPlayer(player)
	o.stopOnAim = false;
	o.stopOnWalk = false;
	o.stopOnRun = false;
	o.maxTime = -1
	o.t = getTimestampMs()
	return o
end

