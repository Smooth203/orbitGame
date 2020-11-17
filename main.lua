io.stdout:setvbuf("no") -- live console for ST3

function newObject(name, parent, semiMajorAxis, eccentricity)
	object = {}
	object.body = love.physics.newBody(world, 0, 0, 'dynamic')
	object.shape = love.physics.newCircleShape(100)
	object.fixture = love.physics.newFixture(object.body, object.shape)
	object.fixture:setDensity(1)
	_, _, mass, _ = object.shape:computeMass(1)
	object.body:setMass(mass)

	object.body:setPosition(parent.body:getX(), parent.body:getY()+(semiMajorAxis-eccentricity))

	objects[name] = object
end


function love.load()
	world = love.physics.newWorld(0, 0, true)

	--gravity
	G = 9.45


	objects = {}

	scale = 0.01
	timewarp = 1

	objects.sun = {}

	-- x/2 because body anchors from centre so 5000 in each direction, total 1000
	objects.sun.body = love.physics.newBody(world, 0, 0, 'dynamic')
	objects.sun.shape = love.physics.newCircleShape(10920)
	-- attach shape to body
	objects.sun.fixture = love.physics.newFixture(objects.sun.body, objects.sun.shape)
	objects.sun.fixture:setDensity(0.255)
	_, _, mass, _ = objects.sun.shape:computeMass(0.255)
	objects.sun.body:setMass(mass)
	objects.sun.body:setPosition(0, 0)

	xAp, yAp, xPe, yPe = 0,0,0,0
	ap, pe = 0, 0
	GG = (1000^2)/(25000 * objects.sun.body:getMass())
	print(GG)
	newObject('planet', objects.sun, 25000 , 0)



	objects.planet.body:setLinearVelocity(1000,0)
	--objects.planet.body:applyLinearImpulse(5000, 0)
	--world:translateOrigin(-(love.graphics.getWidth()/2)/scale, (objects.planet.body:getY())-(love.graphics.getHeight()/2)/scale)
	world:translateOrigin(-(love.graphics.getWidth()/2)/scale,-(love.graphics.getHeight()/2)/scale)
end

function love.update(dt)
	world:update(dt)

	--gravity

	dist = math.sqrt(((objects.planet.body:getX()-objects.sun.body:getX())^2)+((objects.planet.body:getY()-objects.sun.body:getY())^2))
	angle = math.atan2( objects.sun.body:getY()-objects.planet.body:getY(), objects.sun.body:getX()-objects.planet.body:getX() )
	force = (G * objects.sun.body:getMass() * objects.planet.body:getMass()) / (dist)
	objects.planet.body:applyForce(force*math.cos(angle), force*math.sin(angle))

	if dist > ap then
		ap = dist
		xAp, yAp = objects.planet.body:getPosition()

		pe = ap
	end
	if (dist < ap) then
		pe = dist
		xPe, yPe = objects.planet.body:getPosition()
	end
		print(ap, pe)

	vx, vy = objects.planet.body:getLinearVelocity()
	v = math.sqrt(vx^2 + vy^2)

	if love.keyboard.isDown('up') then
		world:translateOrigin(0, -10/scale)
	elseif love.keyboard.isDown('down') then
		world:translateOrigin(0, 10/scale)
	end
	if love.keyboard.isDown('right') then
		world:translateOrigin(10/scale, 0)
	elseif love.keyboard.isDown('left') then
		world:translateOrigin(-10/scale, 0)
	end
end

function love.wheelmoved(x,y)
	if y > 0 then
		scale = scale + 0.001
		--world:translateOrigin()
	elseif y < 0 then
		scale = scale - 0.001
		--world:translateOrigin()
	end
end

function love.draw()
	love.graphics.setColor(0.953, 0.51, 0.208)
	love.graphics.circle('fill', objects.sun.body:getX()*scale, objects.sun.body:getY()*scale, objects.sun.shape:getRadius()*scale)

	love.graphics.setColor(0.553, 0.81, 0.108)
	love.graphics.circle('fill', objects.planet.body:getX()*scale, objects.planet.body:getY()*scale, objects.planet.shape:getRadius()*scale)

	love.graphics.setColor(1,1,1,1)

	love.graphics.ellipse('line', objects.sun.body:getX()*scale, objects.sun.body:getY()*scale, 25000*scale, 25000*scale)
	love.graphics.line( objects.sun.body:getX()*scale, objects.sun.body:getY()*scale, objects.planet.body:getX()*scale, objects.planet.body:getY()*scale)

	--ap and pe mapping
	love.graphics.line(objects.sun.body:getX()*scale, objects.sun.body:getY()*scale, xAp*scale, yAp*scale)
	love.graphics.line(objects.sun.body:getX()*scale, objects.sun.body:getY()*scale, xPe*scale, yPe*scale)

	love.graphics.print( "Mass:"..objects.planet.body:getMass().. "kg,\nAltitude: "..math.floor(dist).."m,\n".."Velocity: "..math.floor(v)..'m/s,\n'.."Grav. Force: "..(force).."N", objects.planet.body:getX()*scale, objects.planet.body:getY()*scale)
	love.graphics.print( "Sun"..",\nMass:"..objects.sun.body:getMass(), objects.sun.body:getX()*scale, objects.sun.body:getY()*scale)
end