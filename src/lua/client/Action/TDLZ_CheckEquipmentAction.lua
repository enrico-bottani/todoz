require "ISBaseObject"
---@class TDLZ_CheckEquipmentAction:ISBaseTimedAction
---@field winCtx TDLZ_TodoListZWindow
---@field row number
---@field tdlz_actId number
---@field _isValid boolean
---@field action? any
TDLZ_CheckEquipmentAction = ISBaseTimedAction:derive("TDLZ_CheckEquipmentAction");

TDLZ_CheckEquipmentAction.IDMax = 1;


function TDLZ_CheckEquipmentAction:isValidStart()
	return true;
end

function TDLZ_CheckEquipmentAction:isValid()
	return self._isValid
end

-- This runs on every tick
function TDLZ_CheckEquipmentAction:update()
	self.winCtx.listbox:getItem(self.row):setJobDelta(self.action:getJobDelta())
end

function TDLZ_CheckEquipmentAction:forceComplete()
	
    self.action:forceComplete();
end

function TDLZ_CheckEquipmentAction:forceStop()
	
    self.action:forceStop();
end

function TDLZ_CheckEquipmentAction:getJobDelta()
	return self.action:getJobDelta();
end

function TDLZ_CheckEquipmentAction:resetJobDelta()
	
	return self.action:resetJobDelta();
end

function TDLZ_CheckEquipmentAction:waitToStart()
	return false
end

function TDLZ_CheckEquipmentAction:start()
	
end

function TDLZ_CheckEquipmentAction:stop()
    ISBaseTimedAction.stop(self)
	self.javaAction = nil;

	if self.onStopActionFunc and self.onStopActionArgs then
        local args = self.onStopActionArgs
        self.onStopActionFunc(args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8])
    end
	
end

function TDLZ_CheckEquipmentAction:perform()
	
	ISTimedActionQueue.getTimedActionQueue(self.character):onCompleted(self);
	ISLogSystem.logAction(self);
    if self.onCompleteFunc then
        local args = self.onCompleteArgs
        self.onCompleteFunc(args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8])
    end
end

function TDLZ_CheckEquipmentAction:create()
	self.maxTime = self:adjustMaxTime(self.maxTime);
	self.action = LuaTimedActionNew.new(self, self.character);
end

function TDLZ_CheckEquipmentAction:begin()
	self:create();
	
	self.character:StartAction(self.action);
	
end

function TDLZ_CheckEquipmentAction:setCurrentTime(time)
	self.action:setCurrentTime(time);
end

function TDLZ_CheckEquipmentAction:setTime(time)
	self.maxTime = time;
end

function TDLZ_CheckEquipmentAction:adjustMaxTime(maxTime)
	if maxTime ~= -1 then
		-- add a slight maxtime if the character is unhappy
		maxTime = maxTime + ((self.character:getMoodles():getMoodleLevel(MoodleType.Unhappy)) * 10)

		-- add more time if the character have his hands wounded
		if not self.ignoreHandsWounds then
			for i=BodyPartType.ToIndex(BodyPartType.Hand_L), BodyPartType.ToIndex(BodyPartType.ForeArm_R) do
				local part = self.character:getBodyDamage():getBodyPart(BodyPartType.FromIndex(i));
				maxTime = maxTime + part:getPain();
			end
		end

		-- Apply a multiplier based on body temperature.
		maxTime = maxTime * self.character:getTimedActionTimeModifier();
	end
	return maxTime;
end

function TDLZ_CheckEquipmentAction:setActionAnim(_action, _displayItemModels)
    if _displayItemModels~=nil then
        self.action:setActionAnim(_action, _displayItemModels);
    else
        self.action:setActionAnim(_action);
    end
end

function TDLZ_CheckEquipmentAction:setOverrideHandModels(_primaryHand, _secondaryHand, _resetModel)
	self.action:setOverrideHandModelsObject(_primaryHand, _secondaryHand, _resetModel or true)
end

function TDLZ_CheckEquipmentAction:setOverrideHandModelsString(_primaryHand, _secondaryHand, _resetModel)
	self.action:setOverrideHandModelsString(_primaryHand, _secondaryHand, _resetModel or true)
end

function TDLZ_CheckEquipmentAction:setAnimVariable(_key, _val)
    self.action:setAnimVariable(_key, _val);
end

function TDLZ_CheckEquipmentAction:addAfter(action)
	local queue,action1 = ISTimedActionQueue.addAfter(self, action)
	return action1
end
function TDLZ_CheckEquipmentAction:setOnComplete(func, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
	self.onCompleteFunc = func
	self.onCompleteArgs = { arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8 }
end
function TDLZ_CheckEquipmentAction:setOnStopAction(func, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
	self.onStopActionFunc = func
	self.onStopActionArgs = { arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8 }
end
---@param character userdata
---@return TDLZ_CheckEquipmentAction
function TDLZ_CheckEquipmentAction:new(character,row, time, winCtx)
	local o = ISBaseTimedAction.new(self, character);
    o.row = row
	o.stopOnWalk = false;
	o.stopOnRun = true;
	o.stopOnAim = true;
	o._isValid = true
    o.caloriesModifier = 1;
	o.maxTime = time
	o.winCtx = winCtx
	return o
end
