if arg[2] == "debug" then
    require("lldebugger").start()
end
local maid64 = require "src/libs/maid64"
local anim8 = require 'src/libs/anim8'

local textInput = ""
local text = ""
local oldText = ""
-- recommended screen sizes
---+--------------+-------------+------+-----+-----+-----+-----+-----+-----+-----+
-- | scale factor | desktop res | 1    | 2   | 3   | 4   | 5   | 6   | 8   | 10  |
-- +--------------+-------------+------+-----+-----+-----+-----+-----+-----+-----+
-- | width        | 1920        | 1920 | 960 | 640 | 480 | 384 | 320 | 240 | 192 |
-- | height       | 1080        | 1080 | 540 | 360 | 270 | 216 | 180 | 135 | 108 |
-- +--------------+-------------+------+-----+-----+-----+-----+-----+-----+-----+
local settings = {
    fullscreen = false,
    scaleMuliplier = 8,
    sceenWidth = 64,
    screenHeight = 64
}

showHitBoxes = false

gardenItems = {}

enemies = {}

sounds = {}

player = {}

function love.load()
    math.randomseed( os.time() )
    gardenItems.flower1 = "src/sprites/flower_white_3x3.png"
    gardenItems.flower2 = "src/sprites/flower_yellow_3x3.png"
    gardenItems.flower3 = "src/sprites/sunflower_orange_4x4.png"
    gardenItems.flower4 = "src/sprites/sunflower_yellow_4x4.png"

    player.x = 32
    player.y = 32
    player.dir = "down"
    player.prevX = 0
    player.prevY = 0
    player.speed = 12
    player.animations = {}
    player.spritesheet = "src/sprites/mower_4x4-Sheet.png"
    player.sprite = maid64.newImage(player.spritesheet)
    player.width = 4
    player.height = 4
    player.grids = {}
    player.grids.mowerGrid = anim8.newGrid(4, 4, player.sprite:getWidth(), player.sprite:getHeight())
    player.animations.drive = anim8.newAnimation(player.grids.mowerGrid('1-6',1), 0.1)
    player.animations.idle = anim8.newAnimation(player.grids.mowerGrid('1-1',1), 0.1)
    player.animations.handleBar = anim8.newAnimation(player.grids.mowerGrid('1-1',2), 0.1)
    player.animationSelected = player.animations.idle
    player.originX = 2
    player.originY = 2
    player.degrees = nil

    sounds.splatter = {} -- add all sounds which are in src/sfx/splatter/

    sounds = {}
    sounds.splatter = {}  -- Initialize the table to store splatter sounds

    -- Get all files in the splatter directory
    local splatterFiles = love.filesystem.getDirectoryItems("src/sfx/splatter/")

    -- Loop through all the files and load them as sounds
    for _, file in ipairs(splatterFiles) do
        -- Get the file extension to ensure it's a valid audio file
        if file:match("%.mp3$") or file:match("%.ogg$") or file:match("%.wav$") then
            -- Load the sound file into the table
            local soundPath = "src/sfx/splatter/" .. file
            table.insert(sounds.splatter, love.audio.newSource(soundPath, "static"))
        end
    end
    
    -- Load the sound file
    mowerSound = love.audio.newSource("src/sfx/mower_driving_04.mp3", "static")
    mowerSound:setLooping(true) -- Set the sound to loop
    mowerStart = love.audio.newSource("src/sfx/mower_starting_00.mp3", "static")
    love.audio.play(mowerStart)

    love.graphics.setBackgroundColor( 0/255, 135/255, 81/255)
    love.window.setTitle( 'snailMower1700' )
    --optional settings for window
    love.window.setMode(settings.sceenWidth*settings.scaleMuliplier, settings.screenHeight*settings.scaleMuliplier, {resizable=true, vsync=false, minwidth=200, minheight=200})
    love.graphics.setDefaultFilter("nearest", "nearest")
    --initilizing maid64 for use and set to 64x64 mode 
    --can take 2 parameters x and y if needed for example maid64.setup(64,32)
    maid64.setup(settings.sceenWidth, settings.screenHeight)

    font = love.graphics.newFont('src/fonts/pico-8-mono.ttf', 4)
    -- font = love.graphics.newFont('src/fonts/PressStart2P-Regular.ttf', 8)
    --font:setFilter('nearest', 'nearest')

    love.graphics.setFont(font)
    
    -- create test sprite
    --maid = maid64.newImage("maid64.png")
    flower1 = maid64.newImage(gardenItems.flower1)
    flower2 = maid64.newImage(gardenItems.flower2)
    flower3 = maid64.newImage(gardenItems.flower3)
    flower4 = maid64.newImage(gardenItems.flower4)
    rotate = 0

    -- enable key repeat so backspace can be held down to trigger love.keypressed multiple times.
    -- love.keyboard.setKeyRepeat(true)
   
end


function love.update(dt)
    local isMoving = false
    -- loop this sound src\sfx\mower_driving_01.mp3 when wasd is pressed
    if love.keyboard.isDown("w") then
        player.y = player.y - player.speed * dt
        player.dir = "up"
        player.animationSelected = player.animations.drive
        isMoving = true
        player.degrees = math.rad(180) -- flip the sprite
    end
    if love.keyboard.isDown("s") then
        player.y = player.y + player.speed * dt
        player.dir = "down"
        player.animationSelected = player.animations.drive
        isMoving = true
        player.degrees = nil
    end
    if love.keyboard.isDown("a") then
        player.x = player.x - player.speed * dt
        player.dir = "left"
        player.animationSelected = player.animations.drive
        isMoving = true
        player.degrees = math.rad(90)  -- flip the sprite left
    end
    if love.keyboard.isDown("d") then
        player.x = player.x + player.speed * dt
        player.dir = "right"
        player.animationSelected = player.animations.drive
        isMoving = true
        player.degrees = math.rad(270) -- flip the sprite right
    end

    -- Play or stop the sound based on movement
    if isMoving then
        if not mowerSound:isPlaying() then
            love.audio.play(mowerSound)
        end
    else
        if mowerSound:isPlaying() then
            love.audio.stop(mowerSound)
        end
    end

    if isMoving == false then
        player.animationSelected = player.animations.idle
    end
    
    player.prevX = player.x
    player.prevY = player.y
 
    player.animationSelected:update(dt)
    

    for key, snail in pairs(enemies) do
        snail.y = snail.y - dt
        snail.timer = snail.timer + dt
        if snail.timer >= snail.addDotIncementer then
            snail.dots = snail.dots + 1
            snail.timer = 0
            

            local addIncementTime = math.random(1,5); math.random(1,5); math.random(1,5)
            snail.addDotIncementer = snail.addDotIncementer + addIncementTime
        end
    end

    for key, snail in pairs(enemies) do
        if checkCollision(player, snail, player.originX, player.originY) then
            print(key, "snail is colliding with player")
            table.remove(enemies, key)

            -- Play a random splatter sound
            if #sounds.splatter > 0 then
                local randomIndex = math.random(1, #sounds.splatter)
                randomIndex = math.random(1, #sounds.splatter)
                randomIndex = math.random(1, #sounds.splatter)
                randomIndex = math.random(1, #sounds.splatter)
                love.audio.play(sounds.splatter[randomIndex])
            end
        end
    end
end
function love.draw()
    
    maid64.start()--starts the maid64 process
    for key, snail in pairs(enemies) do
        -- set color brown
        love.graphics.setColor(171/255, 82/255, 54/255) 
        -- love.graphics.rectangle('fill', snail.x, snail.y, 1,1)
        -- reset color to default
        for i = 1, snail.dots, 1 do
            love.graphics.rectangle('fill', snail.x, snail.y+i, 1,1)
        end
       
        love.graphics.setColor(1,1,1) 
    end

    -- Draw the mower animation with the correct transformations
    player.animationSelected:draw(player.sprite, player.x, player.y, player.degrees, nil, nil, player.originX, player.originY)
    player.animations.handleBar:draw(player.sprite, player.x, player.y, player.degrees, nil, nil, 2, 6)
    -- mowerAnimationIdle:draw(sprMower1, player.x, player.y, degress, nil, nil, originX, originY)
    love.graphics.setLineStyle('rough')
    -- hit box mower
    if showHitBoxes == true then        
        love.graphics.rectangle('line', player.x-player.originX, player.y-player.originY, 4, 4)
    end
    
    --can also draw shapes and get mouse position
    love.graphics.rectangle("fill", maid64.mouse.getX(),  maid64.mouse.getY(), 1,1)
    love.graphics.print(maid64.mouse.getX() ..  "," ..  maid64.mouse.getY(), 44,58)
    love.graphics.print(math.floor(player.x-player.originX) ..  "," .. math.floor(player.y-player.originY), 1,58)
    
    love.graphics.draw(flower3, 1, 2)
    love.graphics.draw(flower1, 1, 7)
    love.graphics.draw(flower2, 6, 3)
    love.graphics.draw(flower4, 12, 4)
    love.graphics.draw(flower1, 17, 7)
    love.graphics.draw(flower2, 18, 3)
    love.graphics.draw(flower2, 22, 4)
    love.graphics.draw(flower2, 26, 7)
    love.graphics.draw(flower1, 28, 3)
    love.graphics.draw(flower3, 36, 3)
    love.graphics.draw(flower1, 41, 3)
    love.graphics.draw(flower1, 44, 5)
    love.graphics.draw(flower4, 48, 2)
    love.graphics.draw(flower3, 53, 5)
    love.graphics.draw(flower2, 56, 1)
    --love.graphics.draw(spr_inLove2d,sceenWidth/2,screenHeight/2,rotate,3,3,32,32)
    -- love.graphics.draw(spr_inLove2d, settings.sceenWidth/2, settings.screenHeight/2, rotate, 1, 1, spr_inLove2d:getWidth()/2, spr_inLove2d:getHeight()/2)

    maid64.finish()--finishes the maid64 process
end

function love.resize(w, h)
    -- this is used to resize the screen correctly
    maid64.resize(w, h)
end

function love.textinput(t)
    textInput = textInput .. t
end

function love.keypressed(key)
    if key == 'e' then
        add_snail()
    end

    if key == "escape" then
        if showHitBoxes == true then
            showHitBoxes = false
        elseif showHitBoxes == false then
            showHitBoxes = true
        end

    end

    -- toggle fullscreen
    if key == 'f11' then
        if settings.fullscreen == false then
            love.window.setFullscreen(true, "desktop")
            settings.fullscreen = true
        else
            love.window.setMode(settings.sceenWidth*settings.scaleMuliplier, settings.screenHeight*settings.scaleMuliplier, {resizable=true, vsync=false, minwidth=200, minheight=200})
            maid64.setup(settings.sceenWidth, settings.screenHeight)
            settings.fullscreen = false
        end 
    end
end

function add_snail()
    math.randomseed( os.time() )

    local x = math.random(1,64); 
    x = math.random(1,64)
    x = math.random(1,64)
    x = math.random(1,64)

    local y = math.random(50, settings.screenHeight - 3)
    y = math.random(50, settings.screenHeight - 3)
    y = math.random(50, settings.screenHeight - 3)
    y = math.random(50, settings.screenHeight - 3)

    print(x)
    snail = {}
    snail.x = x
    snail.y = y
    snail.speed = 10
    snail.timer = 0
    snail.addDotIncementer = 2
    snail.dots = 1
    snail.width = 1
    snail.height = snail.dots

    table.insert(enemies, snail)
end

function move_mower_with_mouse()
    -- Get the current mouse position
    local mouseX = maid64.mouse.getX()
    local mouseY = maid64.mouse.getY()

    -- Calculate the direction to the mouse position
    local dx = mouseX - player.x
    local dy = mouseY - player.y
    local distance = math.sqrt(dx * dx + dy * dy)  -- Calculate the distance to the mouse

    -- Determine the direction of movement
    if mouseY > player.prevY then
        player.dir = "down"
    elseif mouseY < player.prevY then
        player.dir = "up"
    elseif mouseX > player.prevX then
        player.dir = "right"
    elseif mouseX > player.prevY then
        player.dir = "left"
    end

    -- Move the player towards the mouse position with the specified speed
    if distance > 0 then
        -- Normalize the direction vector
        dx = dx / distance
        dy = dy / distance

        -- Move the player towards the mouse position
        player.x = player.x + dx * speed * dt
        player.y = player.y + dy * speed * dt
    end

    -- Update previous mouse position
    player.prevX = mouseX
    player.prevY = mouseY
    print(player.dir)
end

function checkCollision(a, b, originX_a, originY_a, originX_b, originY_b)
    -- Default origin values to 0 if not provided
    originX_a = originX_a or 0
    originY_a = originY_a or 0
    originX_b = originX_b or 0
    originY_b = originY_b or 0

    -- Adjusted edges of object a
    local a_left = a.x - originX_a
    local a_right = a.x + a.width - originX_a
    local a_top = a.y - originY_a
    local a_bottom = a.y + a.height - originY_a

    -- Adjusted edges of object b
    local b_left = b.x - originX_b
    local b_right = b.x + b.width - originX_b
    local b_top = b.y - originY_b
    local b_bottom = b.y + b.height - originY_b

    -- Check if the rectangles overlap
    local isColliding = a_right > b_left and
                        a_left < b_right and
                        a_bottom > b_top and
                        a_top < b_bottom

    return isColliding
end