io.stdout:setvbuf("no") -- live console for ST3

function newObject(name, parent, semiMajorAxis, eccentricity)
	object = {}
	object.body = love.physics.newBody(world, (0.63781/2), (0.63781/2), 'dynamic')
	object.shape = love.physics.newCircleShape(0.63781)
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
	G = 1000


	objects = {}

	scale = 0.01
	timewarp = 1

	objects.sun = {}

	-- x/2 because body anchors from centre so 5000 in each direction, total 1000
	objects.sun.body = love.physics.newBody(world, (69.634/2), (69.634/2), 'dynamic')
	objects.sun.shape = love.physics.newCircleShape(69.634)
	-- attach shape to body
	objects.sun.fixture = love.physics.newFixture(objects.sun.body, objects.sun.shape)
	objects.sun.fixture:setDensity(0.255)
	_, _, mass, _ = objects.sun.shape:computeMass(0.255)
	objects.sun.body:setMass(mass)
	objects.sun.body:setPosition(0, 0)

	newObject('planet', objects.sun, 15210 , 0)

	mu = G * objects.sun.body:getMass()
	
	vv = math.sqrt(mu * ( (2/love.physics.getDistance(objects.planet.fixture, objects.sun.fixture))-(1/love.physics.getDistance(objects.planet.fixture, objects.sun.fixture)) ))
	print(vv)

	objects.planet.body:setLinearVelocity(vv, 0)
	--objects.planet.body:applyLinearImpulse(5000, 0)
	--world:translateOrigin(-(love.graphics.getWidth()/2)/scale, (objects.planet.body:getY())-(love.graphics.getHeight()/2)/scale)
	world:translateOrigin(-(love.graphics.getWidth()/2)/scale,-(love.graphics.getHeight()/2)/scale)
end

function love.update(dt)
	world:update(dt)

	--gravity

	dist = love.physics.getDistance(objects.planet.fixture, objects.sun.fixture)
	angle = math.atan2( objects.sun.body:getY()-objects.planet.body:getY(), objects.sun.body:getX()-objects.planet.body:getX() )
	force = (G * objects.sun.body:getMass() * objects.planet.body:getMass()) / (dist)
	objects.planet.body:applyForce(force*math.cos(angle), force*math.sin(angle))



	--print(objects.sun.body:getMass(), objects.sun.shape:getRadius())
	--print(objects.sun.body:getMass())
	--print(dist, objects.planet.body:getLinearVelocity())

	--tv = objects.planet.body:getAngularVelocity() * dist -- vel tangential to motion
	--print(tv)

	vx, vy = objects.planet.body:getLinearVelocity()
	v = math.sqrt(vx^2 + vy^2)
	--print(vx, vy)
	--world:translateOrigin(vx*dt, vy*dt)

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
	print(scale, objects.planet.body:getWorldPoint(objects.planet.body:getX(),objects.planet.body:getY()))
end

function love.draw()
	love.graphics.setColor(0.953, 0.51, 0.208)
	love.graphics.circle('fill', objects.sun.body:getX()*scale, objects.sun.body:getY()*scale, objects.sun.shape:getRadius()*scale)

	love.graphics.setColor(0.553, 0.81, 0.108)
	love.graphics.circle('fill', objects.planet.body:getX()*scale, objects.planet.body:getY()*scale, objects.planet.shape:getRadius()*scale)

	love.graphics.setColor(1,1,1,1)

	love.graphics.ellipse('line', (love.graphics.getWidth()/2),(love.graphics.getHeight()/2), 15210*scale, 15210*scale)
	love.graphics.line((love.graphics.getWidth()/2),(love.graphics.getHeight()/2), objects.planet.body:getX()*scale, objects.planet.body:getY()*scale)

	love.graphics.print( "Mass:"..objects.planet.body:getMass().. "kg,\nAltitude: "..math.floor(dist).."m,\n".."Velocity: "..math.floor(v)..'m/s,\n'.."Grav. Force: "..(force).."N", objects.planet.body:getX()*scale, objects.planet.body:getY()*scale)
	love.graphics.print( "Sun"..",\nMass:"..objects.sun.body:getMass(), objects.sun.body:getX()*scale, objects.sun.body:getY()*scale)
end