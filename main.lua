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

gardenItems = {}

enemies = {}

player = {}

function love.load()
    gardenItems.flower1 = "src/sprites/flower_white_3x3.png"
    gardenItems.flower2 = "src/sprites/flower_yellow_3x3.png"
    gardenItems.flower3 = "src/sprites/sunflower_orange_4x4.png"
    gardenItems.flower4 = "src/sprites/sunflower_yellow_4x4.png"

    player.x = 32
    player.y = 32
    player.dir = "down"
    player.prevX = 0
    player.prevY = 0
    

    mower1 = "src/sprites/walk_behind_6x8-spritesheet.png"
    sprMower1 = maid64.newImage(mower1)
    mowerGrid = anim8.newGrid(6, 8, sprMower1:getWidth(), sprMower1:getHeight())
    mowerAnimation = anim8.newAnimation(mowerGrid('1-4',1), 0.1)

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
     -- Get the current mouse position
    local mouseX = maid64.mouse.getX()
    local mouseY = maid64.mouse.getY()
 
    player.x = mouseX
    player.y = mouseY
    -- Determine the direction of movement
    -- if mouseX > player.prevX then
    --     player.dir = "right"
    -- elseif mouseX < player.prevX then
    --     player.dir = "left"
    if mouseY > player.prevY then
        player.dir = "down"
    elseif mouseY < player.prevY then
        player.dir = "up"
    end

    -- Update previous mouse position
    player.prevX = mouseX
    player.prevY = mouseY
    print(player.dir)
    --player.dir = "down" default
    --if moving the mouse to the right dir = "right"
    --if moving the mouse to the left dir = "left"
    --if moving the mouse up dir = "up" 
    --if moving the mouse down dir = "down" 
    mowerAnimation:update(dt)
    rotate = rotate + 0.007

    for key, snail in pairs(enemies) do
        snail.y = snail.y - dt
        snail.lifeDuration = snail.lifeDuration + dt
    end
end
function love.draw()
    
    maid64.start()--starts the maid64 process
    -- my sprite is 6x8 and is a lawn mower facing down, so the part mowing the lawn is in the bottom of the sprite.
    -- the below sort of works, but the sprite easily fips
    local sy = 1
    local degress = 1
    if player.dir == "up" then
        sy = -1
        degress = nil
    -- else
    --     sy = 1
    -- elseif player.dir == "right" then
    --     degress = math.rad(270)
    --     sy = 1
    -- elseif player.dir == "left" then
    --     degress = math.rad(90)
    --     sy = 1
    elseif player.dir == "down" then
        degress = nil
        sy = 1
    end

    mowerAnimation:draw(sprMower1, player.x, player.y,  degress, sy)
    
    for key, snail in pairs(enemies) do
        -- set color brown
        love.graphics.setColor(171/255, 82/255, 54/255) 
        love.graphics.rectangle('fill', snail.x, snail.y, 1,1)
        -- reset color to default
        if snail.lifeDuration >= 2 then 
            love.graphics.rectangle('fill', snail.x, snail.y-1, 1,1)
        end 
        if snail.lifeDuration >= 5 then
            love.graphics.rectangle('fill', snail.x, snail.y-2, 1,1)
        end
        if snail.lifeDuration >= 10 then
            love.graphics.rectangle('fill', snail.x, snail.y-3, 1,1)
        end
        love.graphics.setColor(1,1,1) 
    end
    --draw images here
    
    --can also draw shapes and get mouse position
    love.graphics.circle("fill", maid64.mouse.getX(),  maid64.mouse.getY(), 1)
    -- love.graphics.print(maid64.mouse.getX() ..  "," ..  maid64.mouse.getY(), 1,1)
    
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

    local x = math.random(1,64); math.random(1,64); math.random(1,64)
    print(x)
    snail = {}
    snail.x = x
    snail.y = settings.screenHeight - 3
    snail.speed = 10
    snail.lifeDuration = 0

    table.insert(enemies, snail)
end