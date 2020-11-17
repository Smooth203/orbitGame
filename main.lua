io.stdout:setvbuf("no") -- live console for ST3

function newObject(name, parent, semiMajorAxis, eccentricity)
	object = {}
	object.body = love.physics.newBody(world, (10000/2), (10000/2), 'dynamic')
	object.shape = love.physics.newCircleShape(5000)
	object.fixture = love.physics.newFixture(object.body, object.shape)
	object.fixture:setDensity(5514)
	object.body:setPosition(parent.body:getX(), parent.body:getY()+(semiMajorAxis-eccentricity))

	objects[name] = object
end


function love.load()
	world = love.physics.newWorld(0, 0, true)

	--gravity
	G = 500


	objects = {}

	scale = 0.005

	objects.sun = {}
	-- x/2 because body anchors from centre so 5000 in each direction, total 1000
	objects.sun.body = love.physics.newBody(world, (69634/2), (69634/2), 'dynamic')
	objects.sun.shape = love.physics.newCircleShape(69634)
	-- attach shape to body
	objects.sun.fixture = love.physics.newFixture(objects.sun.body, objects.sun.shape)
	objects.sun.fixture:setDensity(140.8)
	objects.sun.body:setPosition(0, 0)

	newObject('planet', objects.sun, 100000, 0)

	mu = G * objects.sun.body:getMass()
	--v = math.sqrt(mu * ( (2/love.physics.getDistance(objects.planet.fixture, objects.sun.fixture))-(1/800) ))
	
	--objects.planet.body:setLinearVelocity(35, 0)
	world:translateOrigin(-love.graphics.getWidth()/2, objects.planet.body:getY()/2 - love.graphics.getHeight()/2)
end

function love.update(dt)
	world:update(dt)

	--gravity

	dist = love.physics.getDistance(objects.planet.fixture, objects.sun.fixture)
	angle = math.atan2( objects.sun.body:getY()-objects.planet.body:getY(), objects.sun.body:getX()-objects.planet.body:getX() )
	force = (G * objects.sun.body:getMass() * objects.planet.body:getMass()) / (dist^2)
	--objects.planet.body:applyForce(force*math.cos(angle), force*math.sin(angle))



	print(objects.sun.body:getMass(), objects.sun.shape:getRadius())
	--print(objects.sun.body:getMass())
	--print(dist, objects.planet.body:getLinearVelocity())

	--tv = objects.planet.body:getAngularVelocity() * dist -- vel tangential to motion
	--print(tv)

	lastX, lastY = objects.planet.body:getPosition()
	print(lastX,lastY)
	world:translateOrigin(objects.planet.body:getX()-lastX, objects.planet.body:getY()-lastY )

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

function love.draw()
	love.graphics.setColor(0.953, 0.51, 0.208)
	love.graphics.circle('fill', objects.sun.body:getX()*scale, objects.sun.body:getY()*scale, objects.sun.shape:getRadius()*scale)

	love.graphics.setColor(0.553, 0.81, 0.108)
	love.graphics.circle('fill', objects.planet.body:getX()*scale, objects.planet.body:getY()*scale, objects.planet.shape:getRadius()*scale)

	love.graphics.setColor(1,1,1,1)
end