-- starts driving the course
function courseplay:start(self)    
	
	self.numCollidingVehicles = 0;
	self.numToolsCollidingVehicles = {};
	self.drive  = false
	self.record = false
	
	-- add do working players if not already added
	if self.working_course_player_num == nil then
		self.working_course_player_num = courseplay:add_working_player(self)
	end	
	
	self.tippers = {}
	-- are there any tippers?	
	self.tipper_attached, self.tippers = courseplay:update_tools(self, self.tippers)
		
	if self.tipper_attached then
		-- tool (collision)triggers for tippers
		for k,object in pairs(self.tippers) do
		  AITractor.addToolTrigger(self, object)
		end
	end
	
	if self.lastrecordnumber ~= nil then
		self.recordnumber = self.lastrecordnumber
		self.lastrecordnumber = nil
	else
		-- TODO still needed?
		if self.back then
			self.recordnumber = self.maxnumber - 2
		else
			self.recordnumber = 1
		end
	end	
	
	-- show arrow
	self.dcheck = true
	-- current position
	local ctx,cty,ctz = getWorldTranslation(self.rootNode);
	-- positoin of next waypoint
	local cx ,cz = self.Waypoints[self.recordnumber].cx,self.Waypoints[self.recordnumber].cz
	-- distance
	dist = courseplay:distance(ctx ,ctz ,cx ,cz)	
	
	if dist < 15 then
		-- hire a helper
		self:hire()
		-- ok i am near the waypoint, let's go
		self.drive  = true
		if self.aiTrafficCollisionTrigger ~= nil then
		   addTrigger(self.aiTrafficCollisionTrigger, "onTrafficCollisionTrigger", self);
		end
		self.record = false
		self.dcheck = false
	else
	  -- try to find other waypoint in reach
	  for k,wp in pairs(self.Waypoints) do
		  local wpdist = courseplay:distance(ctx ,ctz ,wp.cx ,wp.cz)
		  if wpdist < 15 then
		    self.recordnumber = k
		    break
		  end		  
	  end
	end
end

-- stops driving the course
function courseplay:stop(self)
	self:dismiss()
	self.record = false
	-- removing collision trigger
	if self.aiTrafficCollisionTrigger ~= nil then
		removeTrigger(self.aiTrafficCollisionTrigger);
	end
	
	-- removing tippers
	if self.tipper_attached then
		for key,tipper in pairs(self.tippers) do
		  AITractor.removeToolTrigger(self, tipper)
		  tipper:aiTurnOff()
		end
	end
	
	-- reseting variables
	self.unloaded = false
	self.currentTipTrigger = nil
	self.drive  = false	
	self.play = true
	self.dcheck = false
	--self.motor:setSpeedLevel(0, false);
	--self.motor.maxRpmOverride = nil;
	WheelsUtil.updateWheelsPhysics(self, 0, 0, 0, false, self.requiredDriveMode)
	self.lastrecordnumber = self.recordnumber
	self.recordnumber = 1	
end