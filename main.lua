io.stdout:setvbuf("no") -- live console for ST3

function newObject(name, parent, semiMajorAxis, eccentricity)
	object = {}
	object.body = love.physics.newBody(world, (10/2), (10/2), 'dynamic')
	object.shape = love.physics.newCircleShape(5)
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

	scale = 0.25

	objects.sun = {}
	-- x/2 because body anchors from centre so 5000 in each direction, total 1000
	objects.sun.body = love.physics.newBody(world, (1000/2), (1000/2), 'dynamic')
	objects.sun.shape = love.physics.newCircleShape(500)
	-- attach shape to body
	objects.sun.fixture = love.physics.newFixture(objects.sun.body, objects.sun.shape)
	objects.sun.fixture:setDensity(1408)
	objects.sun.body:setPosition(0, 0)

	newObject('planet', objects.sun, 800, 0)

	mu = G * objects.sun.body:getMass()
	v = math.sqrt(mu * ( (2/love.physics.getDistance(objects.planet.fixture, objects.sun.fixture))-(1/800) ))
	objects.planet.body:setLinearVelocity(35, 0)
end

function love.update(dt)
	world:update(dt)

	--gravity

	dist = love.physics.getDistance(objects.planet.fixture, objects.sun.fixture)
	angle = math.atan2( objects.sun.body:getY()-objects.planet.body:getY(), objects.sun.body:getX()-objects.planet.body:getX() )
	force = (G * objects.sun.body:getMass() * objects.planet.body:getMass()) / (dist^2)
	objects.planet.body:applyForce(force*math.cos(angle), force*math.sin(angle))



	print(objects.sun.body:getMass(), objects.sun.shape:getRadius())
	--print(objects.sun.body:getMass())
	--print(dist, objects.planet.body:getLinearVelocity())

	--tv = objects.planet.body:getAngularVelocity() * dist -- vel tangential to motion
	--print(tv)


	if love.keyboard.isDown('up') then
		world:translateOrigin(0, -10)
	elseif love.keyboard.isDown('down') then
		world:translateOrigin(0, 10)
	end
	if love.keyboard.isDown('right') then
		world:translateOrigin(10, 0)
	elseif love.keyboard.isDown('left') then
		world:translateOrigin(-10, 0)
	end
end

function love.draw()
	love.graphics.setColor(0.953, 0.51, 0.208)
	love.graphics.circle('fill', objects.sun.body:getX()*scale, objects.sun.body:getY()*scale, objects.sun.shape:getRadius()*scale)

	love.graphics.setColor(0.553, 0.81, 0.108)
	love.graphics.circle('fill', objects.planet.body:getX()*scale, objects.planet.body:getY()*scale, objects.planet.shape:getRadius()*scale)
end