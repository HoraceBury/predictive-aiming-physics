-- firing solution

require("mathlib")
require("firingsolution")
require("physics")

physics.start()
physics.setGravity(0,0)

sWidth, sHeight = display.contentWidth, display.contentHeight

local towers, targets, bullets = display.newGroup(), display.newGroup(), display.newGroup()

local bulletSpeed = 35


-- fires bullet
function fire( tower, target )
	-- solution: "firing solution" - the collision point between the tower's bullet and the target
	-- success: true if the tower can successfully fire on the target, false if the target will escape
	local solution, success = intercept( tower, target, bulletSpeed )
	
	-- only fire if the firing solution is successful
	if (success) then
		-- calculate vx and vy
		local angle = angleOf( tower, solution )
		local pt = rotateTo( {x=bulletSpeed, y=0}, angle )
		
		-- create bullet
		local bullet = display.newCircle( bullets, 0, 0, 10 )
		bullet.x, bullet.y, bullet.solution = tower.x, tower.y, solution
		bullet:setFillColor(0,255,0)
		bullet.class = "bullet"
		
		-- fire bullet
		physics.addBody(bullet,{radius=10,isSensor=true})
		bullet:setLinearVelocity(pt.x, pt.y)
	end
end

-- add a tower
function createTower(x,y,r)
	local tower = display.newGroup()
	towers:insert( tower )
	tower.x, tower.y = x, y
	tower.class = "tower"
	
	local radar = display.newCircle(tower,0,0,r)
	radar:setFillColor(224,255,255)
	radar:setStrokeColor(0,255,255)
	radar.strokeWidth = 5
	
	local centre = display.newCircle( tower, 0, 0, r/10 )
	centre:setFillColor(255,0,0)
	
	physics.addBody(tower,"static",{radius=r,isSensor=true})
	
	-- detect a target entering the tower's area and fire at it
	function tower:collision(e)
		if (e.phase == "began" and e.other.class == "target") then
			timer.performWithDelay(1, function()
				fire( tower, e.other )
			end, 1)
		end
		return true
	end
	tower:addEventListener("collision", tower)
	
	return tower
end

-- generate random targets
function generateTargets()
	local target = display.newCircle( targets, 0, 0, 20 )
	target.x, target.y = 0, math.random(50,sHeight-50)
	target:setFillColor(0,0,255)
	target.class = "target"
	
	physics.addBody(target,{radius=20,isSensor=true})
	
	target:setLinearVelocity(math.random(40,70),0)
	
	-- handle collision with bullet
	function target:collision(e)
		if (e.phase == "began" and e.other.class == "bullet" and not target.isRemoved and not e.other.isRemoved) then
			target.isRemoved = true
			e.other.isRemoved = true
			timer.performWithDelay(1, function()
				target:removeSelf()
				e.other:removeSelf()
			end, 1)
		end
		return true
	end
	target:addEventListener("collision", target)
end

-- build some towers
createTower( 700,200,150 )
createTower( 600,600,150 )
createTower( 300,400,150 )

-- start throwing targets
timer.performWithDelay(4000, generateTargets, 0)
