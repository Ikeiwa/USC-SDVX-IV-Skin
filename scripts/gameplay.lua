-- The following code slightly simplifies the render/update code, making it easier to explain in the comments
-- It replaces a few of the functions built into USC and changes behaviour slightly
-- Ideally, this should be in the common.lua file, but the rest of the skin does not support it
-- I'll be further refactoring and documenting the default skin and making it more easy to
--  modify for those who either don't know how to skin well or just want to change a few images
--  or behaviours of the default to better suit them.
-- Skinning should be easy and fun!

local RECT_FILL = "fill"
local RECT_STROKE = "stroke"
local RECT_FILL_STROKE = RECT_FILL .. RECT_STROKE

gfx._ImageAlpha = 1

gfx._FillColor = gfx.FillColor
gfx._StrokeColor = gfx.StrokeColor
gfx._SetImageTint = gfx.SetImageTint

local comboNumbers = {
gfx.CreateSkinImage("fonts/combo/combo_num0.png",0),
gfx.CreateSkinImage("fonts/combo/combo_num1.png",0),
gfx.CreateSkinImage("fonts/combo/combo_num2.png",0),
gfx.CreateSkinImage("fonts/combo/combo_num3.png",0),
gfx.CreateSkinImage("fonts/combo/combo_num4.png",0),
gfx.CreateSkinImage("fonts/combo/combo_num5.png",0),
gfx.CreateSkinImage("fonts/combo/combo_num6.png",0),
gfx.CreateSkinImage("fonts/combo/combo_num7.png",0),
gfx.CreateSkinImage("fonts/combo/combo_num8.png",0),
gfx.CreateSkinImage("fonts/combo/combo_num9.png",0)
}

local scoreNumbers = {
gfx.CreateSkinImage("fonts/score/score_b00.png",0),
gfx.CreateSkinImage("fonts/score/score_b01.png",0),
gfx.CreateSkinImage("fonts/score/score_b02.png",0),
gfx.CreateSkinImage("fonts/score/score_b03.png",0),
gfx.CreateSkinImage("fonts/score/score_b04.png",0),
gfx.CreateSkinImage("fonts/score/score_b05.png",0),
gfx.CreateSkinImage("fonts/score/score_b06.png",0),
gfx.CreateSkinImage("fonts/score/score_b07.png",0),
gfx.CreateSkinImage("fonts/score/score_b08.png",0),
gfx.CreateSkinImage("fonts/score/score_b09.png",0)
}

local smallNumbers = {
gfx.CreateSkinImage("fonts/small/h_hi_bpm_00.png",0),
gfx.CreateSkinImage("fonts/small/h_hi_bpm_01.png",0),
gfx.CreateSkinImage("fonts/small/h_hi_bpm_02.png",0),
gfx.CreateSkinImage("fonts/small/h_hi_bpm_03.png",0),
gfx.CreateSkinImage("fonts/small/h_hi_bpm_04.png",0),
gfx.CreateSkinImage("fonts/small/h_hi_bpm_05.png",0),
gfx.CreateSkinImage("fonts/small/h_hi_bpm_06.png",0),
gfx.CreateSkinImage("fonts/small/h_hi_bpm_07.png",0),
gfx.CreateSkinImage("fonts/small/h_hi_bpm_08.png",0),
gfx.CreateSkinImage("fonts/small/h_hi_bpm_09.png",0),
gfx.CreateSkinImage("fonts/small/h_hi_bpm_dot.png",0),
gfx.CreateSkinImage("fonts/small/h_hi_bpm_equal.png",0)
}

-- we aren't even gonna overwrite it here, it's just dead to us
gfx.SetImageTint = nil

function gfx.FillColor(r, g, b, a)
    r = math.floor(r or 255)
    g = math.floor(g or 255)
    b = math.floor(b or 255)
    a = math.floor(a or 255)

    gfx._ImageAlpha = a / 255
    gfx._FillColor(r, g, b, a)
    gfx._SetImageTint(r, g, b)
end

function gfx.StrokeColor(r, g, b)
    r = math.floor(r or 255)
    g = math.floor(g or 255)
    b = math.floor(b or 255)

    gfx._StrokeColor(r, g, b)
end

function gfx.DrawRect(kind, x, y, w, h)
    local doFill = kind == RECT_FILL or kind == RECT_FILL_STROKE
    local doStroke = kind == RECT_STROKE or kind == RECT_FILL_STROKE

    local doImage = not (doFill or doStroke)

    gfx.BeginPath()

    if doImage then
        gfx.ImageRect(x, y, w, h, kind, gfx._ImageAlpha, 0)
    else
        gfx.Rect(x, y, w, h)
        if doFill then gfx.Fill() end
        if doStroke then gfx.Stroke() end
    end
end

local buttonStates = { }
local buttonsInOrder = {
    game.BUTTON_BTA,
    game.BUTTON_BTB,
    game.BUTTON_BTC,
    game.BUTTON_BTD,

    game.BUTTON_FXL,
    game.BUTTON_FXR,

    game.BUTTON_STA,
}

function UpdateButtonStatesAfterProcessed()
    for i = 1, 6 do
        local button = buttonsInOrder[i]
        buttonStates[button] = game.GetButton(button)
    end
end

function game.GetButtonPressed(button)
    return game.GetButton(button) and not buttonStates[button]
end
-- -------------------------------------------------------------------------- --
-- game.IsUserInputActive:                                                    --
-- Used to determine if (valid) controller input is happening.                --
-- Valid meaning that laser motion will not return true unless the laser is   --
--  active in gameplay as well.                                               --
-- This restriction is not applied to buttons.                                --
-- The player may press their buttons whenever and the function returns true. --
-- Lane starts at 1 and ends with 8.                                          --
function game.IsUserInputActive(lane)
    if lane < 7 then
        return game.GetButton(buttonsInOrder[lane])
    end
    return gameplay.IsLaserHeld(lane - 7)
end
-- -------------------------------------------------------------------------- --
-- gfx.FillLaserColor:                                                        --
-- Sets the current fill color to the laser color of the given index.         --
-- An optional alpha value may be given as well.                              --
-- Index may be 1 or 2.                                                       --
function gfx.FillLaserColor(index, alpha)
    alpha = math.floor(alpha or 255)
    local r, g, b = game.GetLaserColor(index - 1)
    gfx.FillColor(r, g, b, alpha)
end

drawSmallNumber = function(posx,posy,strNumber,scale)
	local offset = 0
	
	for i = 1, #strNumber do
		gfx.BeginPath()
		
		if strNumber:sub(i,i) == '.' then
			gfx.ImageRect(posx+offset,posy,8*scale,15*scale,smallNumbers[11],1,0)
			offset = offset + (8*scale)
		elseif strNumber:sub(i,i) == '=' then
			gfx.ImageRect(posx+offset,posy,16*scale,15*scale,smallNumbers[12],1,0)
			offset = offset + (16*scale)
		else
			gfx.ImageRect(posx+offset,posy,16*scale,15*scale,smallNumbers[strNumber:sub(i,i)+1],1,0)
			offset = offset + (16*scale)
		end
	end
end

drawImage = function(posx,posy,image,scalex,scaley,alpha,angle)
	gfx.BeginPath()
	local w,h = gfx.ImageSize(image)
	gfx.Save()
    gfx.Translate(posx,posy)
    gfx.Rotate(angle)
    gfx.Translate(-w*scalex/2,-h*scaley/2)
    gfx.ImageRect(0,0,w*scalex,h*scaley,image,alpha,0)
    gfx.Restore()
end

drawImageEx = function(posx,posy,image,pivotx,pivoty,absolute,scalex,scaley,alpha,angle)
	gfx.BeginPath()
	local w,h;
	
	if (absolute) then
		w = scalex
		h = scaley
	else
		w,h = gfx.ImageSize(image)
	end
	
	gfx.Save()
    gfx.Translate(posx,posy)
    gfx.Rotate(angle)
    
	if (absolute) then
		gfx.Translate(-w*pivotx,-h*pivoty)
		gfx.ImageRect(0,0,w,h,image,alpha,0)
	else
		gfx.Translate(-w*scalex*pivotx,-h*scaley*pivoty)
		gfx.ImageRect(0,0,w*scalex,h*scaley,image,alpha,0)
	end
    gfx.Restore()
end

-- -------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------- --
--                  The actual gameplay script starts here!                   --
-- -------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------- --
-- Global data used by many things:                                           --
local resx, resy -- The resolution of the window
local portrait -- whether the window is in portrait orientation
local desw, desh -- The resolution of the design
local scale -- the scale to get from design to actual units
-- -------------------------------------------------------------------------- --
-- All images used by the script:                                             --
local jacketFallback = gfx.CreateSkinImage("song_select/loading.png", 0)
local bottomFill = gfx.CreateSkinImage("console/console.png", 0)
local topFill = gfx.CreateSkinImage("fill_top.png", 0)
local critAnim = gfx.CreateSkinImage("crit_anim.png", 0)
local critCap = gfx.CreateSkinImage("crit_cap.png", 0)
local critCapBack = gfx.CreateSkinImage("crit_cap_back.png", 0)
local laserCursor = gfx.CreateSkinImage("pointer.png", 0)
local laserCursorOverlay = gfx.CreateSkinImage("pointer_overlay.png", 0)

local ioConsoleDetails = {
    gfx.CreateSkinImage("console/detail_left.png", 0),
    gfx.CreateSkinImage("console/detail_right.png", 0),
}

local consoleAnimImages = {
    gfx.CreateSkinImage("console/glow_bta.png", 0),
    gfx.CreateSkinImage("console/glow_btb.png", 0),
    gfx.CreateSkinImage("console/glow_btc.png", 0),
    gfx.CreateSkinImage("console/glow_btd.png", 0),
    
    gfx.CreateSkinImage("console/glow_fxl.png", 0),
    gfx.CreateSkinImage("console/glow_fxr.png", 0),

    gfx.CreateSkinImage("console/glow_voll.png", 0),
    gfx.CreateSkinImage("console/glow_volr.png", 0),
}

local earlyTxt = gfx.CreateSkinImage("hud_early.png",0)
local lateTxt = gfx.CreateSkinImage("hud_late.png",0)
local comboChain = gfx.CreateSkinImage("combo_chain.png",0)
local scoreBg = gfx.CreateSkinImage("score_bg.png",0)
local songBg = gfx.CreateSkinImage("song_bg.png",0)
local gaugeCursor = gfx.CreateSkinImage("gauge_cursor.png",0)
local progressBar = gfx.CreateSkinImage("progress_bar.png",0)
local alertLeftBG = gfx.CreateSkinImage("alert_left_bg.png",0)
local alertLeft = gfx.CreateSkinImage("alert_left.png",0)
local alertRightBG = gfx.CreateSkinImage("alert_right_bg.png",0)
local alertRight = gfx.CreateSkinImage("alert_right.png",0)
local trSide = gfx.CreateSkinImage("transition/tr_side.png",0)
local trTop = gfx.CreateSkinImage("transition/tr_top.png",0)
local trCenter = gfx.CreateSkinImage("transition/tr_center.png",0)

local diffImg = {
gfx.CreateSkinImage("lv_01.png",0),
gfx.CreateSkinImage("lv_02.png",0),
gfx.CreateSkinImage("lv_03.png",0),
gfx.CreateSkinImage("lv_04.png",0)
}

game.LoadSkinSample("failed")
game.LoadSkinSample("clear")
game.LoadSkinSample("perfect")
game.LoadSkinSample("fullcombo")
game.LoadSkinSample("boot_song")
-- -------------------------------------------------------------------------- --
-- Timers, used for animations:                                               --
local introTimer = 4
local outroTimer = 0

local alertTimers = {-2,-2}

local earlateTimer = 0
local critAnimTimer = 0

local consoleAnimSpeed = 10
local consoleAnimTimers = { 0, 0, 0, 0, 0, 0, 0, 0 }

local resultPlayed = false
local clearPlayed = false
local introPlayed = false
-- -------------------------------------------------------------------------- --
-- Miscelaneous, currently unsorted:                                          --
local score = 0
local combo = 0
local jacket = nil
local critLinePos = { 0.95, 0.75 };
local comboScale = 1.0
local late = false
local diffNames = {"NOV", "ADV", "EXH", "INF"}
local clearTexts = {"TRACK FAILED", "TRACK COMPLETE", "TRACK COMPLETE", "FULL COMBO", "PERFECT" }
-- -------------------------------------------------------------------------- --
-- ResetLayoutInformation:                                                    --
-- Resets the layout values used by the skin.                                 --
function ResetLayoutInformation()
    resx, resy = game.GetResolution()
    portrait = resy > resx
    desw = portrait and 720 or 1280 
    desh = desw * (resy / resx)
    scale = resx / desw
end
-- -------------------------------------------------------------------------- --
-- render:                                                                    --
-- The primary & final render call.                                           --
-- Use this to render basically anything that isn't the crit line or the      --
--  intro/outro transitions.                                                  --
function render(deltaTime)
    -- make sure that our transform is cleared, clean working space
    -- TODO: this shouldn't be necessary!!!
    gfx.ResetTransform()
    
    gfx.Scale(scale, scale)
    local yshift = 0

    -- In portrait, we draw a banner across the top
    -- The rest of the UI needs to be drawn below that banner
    -- TODO: this isn't how it'll work in the long run, I don't think
    if portrait then yshift = draw_banner(deltaTime) end

    gfx.Translate(0, yshift - 150 * math.max(introTimer - 1, 0))
    draw_song_info(deltaTime)
    draw_score(deltaTime)
    gfx.Translate(0, -yshift + 150 * math.max(introTimer - 1, 0))
    draw_gauge(deltaTime)
    draw_earlate(deltaTime)
    draw_combo(deltaTime)
    draw_alerts(deltaTime)
	
	gfx.Reset()
    gfx.ResetTransform()
    
	if introTimer > 0 then
	
		local percent = 1 - math.max(math.min((introTimer-2)/0.5,1),0)
	
		local slidePercent = -(percent*2-0.32)^2+1.1
		
		gfx.Translate(resx/2,resy/2)
		
		--function(posx,posy,image,pivotx,pivoty,absolute,scalex,scaley,alpha,angle)
		
		if (portrait) then
			drawImageEx(0,0,trCenter,0.5,0.5,true,(1-percent)*(resx/4.0) + (resx*0.75),(1-percent)*(resx/4.0) + (resx*0.75),1-percent,percent*2)
			
			gfx.Translate(0,-resx)
			drawImage(0,slidePercent*230,trSide,0.75,0.75,1,1.570796)
			
			gfx.Translate(0,resx*2.0)
			drawImage(0,-slidePercent*230,trSide,-0.75,0.75,1,1.570796)
		else
			drawImageEx(0,0,trCenter,0.5,0.5,true,(1-percent)*(resy/4.0) + (resy*0.75),(1-percent)*(resy/4.0) + (resy*0.75),1-percent,percent*2)
			
			gfx.Translate(-resy,0)
			drawImage(slidePercent*230,0,trSide,0.75,0.75,1,0)
			
			gfx.Translate(resy*2.0,0)
			drawImage(-slidePercent*230,0,trSide,-0.75,0.75,1,0)
		end
		
		gfx.ResetTransform()
		
		local jacketSize = (1-percent)*500
		gfx.BeginPath()
		gfx.Translate(resx/2,resy/2)
		gfx.Translate(-jacketSize/2,-250)
		gfx.ImageRect(0,0,jacketSize,500,jacket,1,0)
		gfx.ResetTransform()
    end
end
-- -------------------------------------------------------------------------- --
-- SetUpCritTransform:                                                        --
-- Utility function which aligns the graphics transform to the center of the  --
--  crit line on screen, rotation include.                                    --
-- This function resets the graphics transform, it's up to the caller to      --
--  save the transform if needed.                                             --
function SetUpCritTransform()
    -- start us with a clean empty transform
    gfx.ResetTransform()
    -- translate and rotate accordingly
    gfx.Translate(gameplay.critLine.x, gameplay.critLine.y)
    gfx.Rotate(-gameplay.critLine.rotation)
end
-- -------------------------------------------------------------------------- --
-- GetCritLineCenteringOffset:                                                --
-- Utility function which returns the magnitude of an offset to center the    --
--  crit line on the screen based on its position and rotation.               --
function GetCritLineCenteringOffset()
    local distFromCenter = resx / 2 - gameplay.critLine.x
    local dvx = math.cos(gameplay.critLine.rotation)
    local dvy = math.sin(gameplay.critLine.rotation)
    return math.sqrt(dvx * dvx + dvy * dvy) * distFromCenter
end
-- -------------------------------------------------------------------------- --
-- render_crit_base:                                                          --
-- Called after rendering the highway and playable objects, but before        --
--  the built-in hit effects.                                                 --
-- This is the first render function to be called each frame.                 --
-- This call resets the graphics transform, it's up to the caller to          --
--  save the transform if needed.                                             --
function render_crit_base(deltaTime)
    -- Kind of a hack, but here (since this is the first render function
    --  that gets called per frame) we update the layout information.
    -- This means that the player can resize their window and
    --  not break everything
    ResetLayoutInformation()

    critAnimTimer = critAnimTimer + deltaTime
    SetUpCritTransform()
    
    -- Figure out how to offset the center of the crit line to remain
    --  centered on the players screen
    local xOffset = GetCritLineCenteringOffset()
    gfx.Translate(xOffset, 0)
    
    -- Draw a transparent black overlay below the crit line
    -- This darkens the play area as it passes
    --gfx.FillColor(0, 0, 0, 200)
    --gfx.DrawRect(RECT_FILL, -resx, 0, resx * 2, resy)

    -- The absolute width of the crit line itself
    -- we check to see if we're playing in portrait mode and
    --  change the width accordingly
    local critWidth = resx * (portrait and 1 or 0.8)
    
    -- get the scaled dimensions of the crit line pieces
    local clw, clh = gfx.ImageSize(critAnim)
    local critAnimHeight = 15 * scale
    local critAnimWidth = critAnimHeight * (clw / clh)

    local ccw, cch = gfx.ImageSize(critCap)
    local critCapHeight = critAnimHeight * (cch / clh)
    local critCapWidth = critCapHeight * (ccw / cch)

    -- draw the back half of the caps at each end
    do
        gfx.FillColor(255, 255, 255)
        -- left side
        gfx.DrawRect(critCapBack, -critWidth / 2 - critCapWidth / 2, -critCapHeight / 2, critCapWidth, critCapHeight)
        gfx.Scale(-1, 1) -- scale to flip horizontally
        -- right side
        gfx.DrawRect(critCapBack, -critWidth / 2 - critCapWidth / 2, -critCapHeight / 2, critCapWidth, critCapHeight)
        gfx.Scale(-1, 1) -- unflip horizontally
    end

    -- render the core of the crit line
    do
        -- The crit line is made up of many small pieces scrolling outward
        -- Calculate how many pieces, starting at what offset, are require to
        --  completely fill the space with no gaps from edge to center
        local numPieces = 1 + math.ceil(critWidth / (critAnimWidth * 2))
        local startOffset = critAnimWidth * ((critAnimTimer * 1.5) % 1)

        -- left side
        -- Use a scissor to limit the drawable area to only what should be visible
        gfx.Scissor(-critWidth / 2, -critAnimHeight / 2, critWidth / 2, critAnimHeight)
        for i = 1, numPieces do
            gfx.DrawRect(critAnim, -startOffset - critAnimWidth * (i - 1), -critAnimHeight / 2, critAnimWidth, critAnimHeight)
        end
        gfx.ResetScissor()

        -- right side
        -- exactly the same, but in reverse
        gfx.Scissor(0, -critAnimHeight / 2, critWidth / 2, critAnimHeight)
        for i = 1, numPieces do
            gfx.DrawRect(critAnim, -critAnimWidth + startOffset + critAnimWidth * (i - 1), -critAnimHeight / 2, critAnimWidth, critAnimHeight)
        end
        gfx.ResetScissor()
    end

    -- Draw the front half of the caps at each end
    do
        gfx.FillColor(255, 255, 255)
        -- left side
        gfx.DrawRect(critCap, -critWidth / 2 - critCapWidth / 2, -critCapHeight, critCapWidth*2, critCapHeight*2)
        gfx.Scale(-1, 1) -- scale to flip horizontally
        -- right side
        gfx.DrawRect(critCap, -critWidth / 2 - critCapWidth / 2, -critCapHeight, critCapWidth*2, critCapHeight*2)
        gfx.Scale(-1, 1) -- unflip horizontally
    end

    -- we're done, reset graphics stuffs
    gfx.FillColor(255, 255, 255)
    gfx.ResetTransform()
end
-- -------------------------------------------------------------------------- --
-- render_crit_overlay:                                                       --
-- Called after rendering built-int crit line effects.                        --
-- Use this to render laser cursors or an IO Console in portrait mode!        --
-- This call resets the graphics transform, it's up to the caller to          --
--  save the transform if needed.                                             --
function render_crit_overlay(deltaTime)
    SetUpCritTransform()

    -- Figure out how to offset the center of the crit line to remain
    --  centered on the players screen.
    local xOffset = GetCritLineCenteringOffset()

    -- When in portrait, we can draw the console at the bottom
    if portrait then
        -- We're going to make temporary modifications to the transform
        gfx.Save()
        gfx.Translate(xOffset * 0.5, 0)

        local bfw, bfh = gfx.ImageSize(bottomFill)

        local distBetweenKnobs = 0.446
        local distCritVertical = 0.098

        local ioFillTx = bfw / 2
        local ioFillTy = bfh * distCritVertical -- 0.098

        -- The total dimensions for the console image
        local io_x, io_y, io_w, io_h = -ioFillTx, -ioFillTy, bfw, bfh

        -- Adjust the transform accordingly first
        local consoleFillScale = (resx * 0.775) / (bfw * distBetweenKnobs)
        gfx.Scale(consoleFillScale, consoleFillScale);

        -- Actually draw the fill
        gfx.FillColor(255, 255, 255)
        gfx.DrawRect(bottomFill, io_x, io_y, io_w, io_h)

        -- Then draw the details which need to be colored to match the lasers
        for i = 1, 2 do
            gfx.FillLaserColor(i)
            gfx.DrawRect(ioConsoleDetails[i], io_x, io_y, io_w, io_h)
        end

        -- Draw the button press animations by overlaying transparent images
        gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER)
        for i = 1, 6 do
            -- While a button is held, increment a timer
            -- If not held, that timer is set back to 0
            if game.GetButton(buttonsInOrder[i]) then
                consoleAnimTimers[i] = consoleAnimTimers[i] + deltaTime * consoleAnimSpeed * 3.14 * 2
            else 
                consoleAnimTimers[i] = 0
            end

            -- If the timer is active, flash based on a sin wave
            local timer = consoleAnimTimers[i]
            if timer ~= 0 then
                local image = consoleAnimImages[i]
                local alpha = (math.sin(timer) * 0.5 + 0.5) * 0.5 + 0.25
                gfx.FillColor(255, 255, 255, alpha * 255);
                gfx.DrawRect(image, io_x, io_y, io_w, io_h)
            end
        end
        gfx.GlobalCompositeOperation(gfx.BLEND_OP_SOURCE_OVER)
        
        -- Undo those modifications
        gfx.Restore();
    end

    local cw, ch = gfx.ImageSize(laserCursor)
    local cursorWidth = 40 * scale
    local cursorHeight = cursorWidth * (ch / cw)

    -- draw each laser cursor
    for i = 1, 2 do
        local cursor = gameplay.critLine.cursors[i - 1]
        local pos, skew = cursor.pos, cursor.skew

        -- Add a kinda-perspective effect with a horizontal skew
        gfx.SkewX(skew)

        -- Draw the colored background with the appropriate laser color
        gfx.FillLaserColor(i, cursor.alpha * 255)
        gfx.DrawRect(laserCursor, pos - cursorWidth / 2, -cursorHeight / 2, cursorWidth, cursorHeight)
        -- Draw the uncolored overlay on top of the color
        gfx.FillColor(255, 255, 255, cursor.alpha * 255)
        gfx.DrawRect(laserCursorOverlay, pos - cursorWidth / 2, -cursorHeight / 2, cursorWidth, cursorHeight)
        -- Un-skew
        gfx.SkewX(-skew)
    end

    -- We're done, reset graphics stuffs
    gfx.FillColor(255, 255, 255)
    gfx.ResetTransform()
end
-- -------------------------------------------------------------------------- --
-- draw_banner:                                                               --
-- Renders the banner across the top of the screen in portrait.               --
-- This function expects no graphics transform except the design scale.       --
function draw_banner(deltaTime)
    local bannerWidth, bannerHeight = gfx.ImageSize(topFill)
    local actualHeight = desw * (bannerHeight / bannerWidth)

    gfx.FillColor(255, 255, 255)
    gfx.DrawRect(topFill, 0, 0, desw, actualHeight)

    return (actualHeight/2.0)-20;
end
-- -------------------------------------------------------------------------- --
-- draw_stat:                                                                 --
-- Draws a formatted name + value combination at x, y over w, h area.         --
draw_stat = function(x,y,w,h, name, value, format,r,g,b)
  gfx.Save()
  gfx.Translate(x,y)
  gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)
  gfx.FontSize(h)
  gfx.Text(name .. ":",0, 0)
  gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_TOP)
  gfx.Text(string.format(format, value),w, 0)
  gfx.BeginPath()
  gfx.MoveTo(0,h)
  gfx.LineTo(w,h)
  if r then gfx.StrokeColor(r,g,b) 
  else gfx.StrokeColor(200,200,200) end
  gfx.StrokeWidth(1)
  gfx.Stroke()
  gfx.Restore()
  return y + h + 5
end
-- -------------------------------------------------------------------------- --
-- draw_song_info:                                                            --
-- Draws current song information at the top left of the screen.              --
-- This function expects no graphics transform except the design scale.       --
function draw_song_info(deltaTime)

	gfx.BeginPath()
	gfx.ImageRect(0,0,300,144,songBg,1,0)
	
	gfx.BeginPath()
	gfx.ImageRect(110,74,gameplay.progress*140+1,10,progressBar,1,0)
	

    if jacket == nil or jacket == jacketFallback then
        jacket = gfx.LoadImageJob(gameplay.jacketPath, jacketFallback)
    end
	
	gfx.BeginPath()
    gfx.ImageRect(28,29,71,71,jacket,1,0)
	
	gfx.BeginPath()
	gfx.ImageRect(27,108,50,10,diffImg[gameplay.difficulty + 1],1,0)
	
	drawSmallNumber(75,107,tostring(gameplay.level),0.8)
	
	drawSmallNumber(223,87,tostring(math.floor(gameplay.bpm)),1.0)
	
	if game.GetButton(game.BUTTON_STA) then
		drawSmallNumber(223,104,tostring(math.floor(gameplay.hispeed*100)/100).."="..tostring(math.floor(gameplay.bpm * gameplay.hispeed)),1.0)
	else
		drawSmallNumber(223,104,tostring(math.floor(gameplay.hispeed*100)/100),1.0)
	end
	
	gfx.Save()
	
	gfx.BeginPath()
    gfx.LoadSkinFont("NovaMono.ttf")
	gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)
	gfx.FontSize(15)
	gfx.Translate(113,26)
	gfx.Text(gameplay.title, 0, 0)
	gfx.Translate(0,15)
	gfx.Text(gameplay.artist, 0, 0)
	
	gfx.Restore()
end
-- -------------------------------------------------------------------------- --
-- draw_best_diff:                                                            --
-- If there are other saved scores, this displays the difference between      --
--  the current play and your best.                                           --
drawBestDiff = function(deltaTime,x,y)
    if not gameplay.scoreReplays[1] then return end
    gfx.BeginPath()
    gfx.FontSize(40)
    difference = score - gameplay.scoreReplays[1].currentScore
    local prefix = ""
    gfx.FillColor(255,255,255)
    if difference < 0 then 
        gfx.FillColor(255,50,50)
        difference = math.abs(difference)
        prefix = "-"
    end
    gfx.Text(string.format("%s%08d", prefix, difference), x, y)
end
-- -------------------------------------------------------------------------- --
-- draw_score:
function draw_score(deltaTime)
    gfx.BeginPath()
    
	gfx.ImageRect(desw-288,0,288,144,scoreBg,1,0)
	
	local strScore = string.format("%08d", score);
	
	for i = 1, #strScore do
		gfx.BeginPath()
		if i > 5 then
			gfx.ImageRect(desw + 27*i - 260,90,27,30,scoreNumbers[strScore:sub(i,i)+1],1,0)
		else
			gfx.ImageRect(desw + 36*i - 313,80,36,40,scoreNumbers[strScore:sub(i,i)+1],1,0)
		end
	end
	
    drawBestDiff(deltaTime, desw, 66)
end
-- -------------------------------------------------------------------------- --
-- draw_gauge:                                                                --
function draw_gauge(deltaTime)
	gfx.Save()
	gfx.ResetTransform()

    local height = 366 * scale
    local width = 72 * scale
    local posy = resy / 2 - height / 2
    local posx = resx - width*2 * (1 - math.max(introTimer - 1, 0))
    if portrait then
        width = width * 0.8
        height = height * 0.8
        posy = posy - 10
        posx = resx - (resx/8.0) * (1 - math.max(introTimer - 1, 0))
    end
    gfx.DrawGauge(gameplay.gauge, posx, posy, width, height, deltaTime)
	
	local gaugeFillHeight = height*0.911603
	
	---gaugeFillHeight/2
	
	local cursorY = posy + gaugeFillHeight;
	
	gfx.BeginPath()
	gfx.FillColor(255,255,255,255)
	gfx.ImageRect(posx - (30*scale),cursorY-(gameplay.gauge * gaugeFillHeight)+(10*scale),40.5*scale,18.75*scale,gaugeCursor,1,0)
	drawSmallNumber(posx - (30*scale),cursorY-(gameplay.gauge * gaugeFillHeight)+(10*scale)+(6*scale),tostring(math.floor(gameplay.gauge*100)),0.675*scale)
	
	gfx.Restore()
end
-- -------------------------------------------------------------------------- --
-- draw_combo:                                                                --
function draw_combo(deltaTime)
    local posx = desw / 2-132
    local posy = desh * critLinePos[1] - 100
    if portrait then posy = desh * critLinePos[2] - 100 end
    if gameplay.comboState == 1 or gameplay.comboState == 2 then
		gfx.BeginPath();
		gfx.ImageRect(posx+80,posy-25,104,16,comboChain,1,0)
	end
	
	local strCombo = string.format("%04d", combo);
	
	for i = 1, #strCombo do
		gfx.BeginPath()
		
		if gameplay.comboState == 2 then
			gfx.FillColor(247, 241, 153,255) --puc
		elseif gameplay.comboState == 1 then
			gfx.FillColor(247, 241, 153,255) --uc
		else
			gfx.FillColor(255,255,255,255) --regular
		end
		
		gfx.ImageRect(posx+44*i,posy,44,42,comboNumbers[strCombo:sub(i,i)+1],1,0)
		gfx.FillColor(255,255,255,255)
	end
end
-- -------------------------------------------------------------------------- --
-- draw_earlate:                                                              --
function draw_earlate(deltaTime)
	gfx.BeginPath()
    earlateTimer = math.max(earlateTimer - deltaTime,0)
    if earlateTimer == 0 then return nil end
    local elAlpha = math.floor(earlateTimer * 20) % 2
    local ypos = desh * critLinePos[1] - 150
    if portrait then ypos = desh * critLinePos[2] - 150 end
    if late then
		gfx.ImageRect(desw / 2 - 42, ypos - 8, 84, 16, lateTxt, elAlpha,0)
    else
        gfx.ImageRect(desw / 2 - 42, ypos - 8, 84, 16, earlyTxt, elAlpha,0)
    end
end
-- -------------------------------------------------------------------------- --
-- draw_alerts:                                                               --
function draw_alerts(deltaTime)
    alertTimers[1] = math.max(alertTimers[1] - deltaTime,-2)
    alertTimers[2] = math.max(alertTimers[2] - deltaTime,-2)
    if alertTimers[1] > 0 then --draw left alert
        local posx = desw / 2 - 350
        local posy = desh * critLinePos[1] - 135
        if portrait then 
            posy = desh * critLinePos[2] - 135 
            posx = 65
        end
        local alertScale = (-(alertTimers[1] ^ 2.0) + (1.5 * alertTimers[1])) * 5.0
        alertScale = math.min(alertScale, 1)
        gfx.BeginPath()
		gfx.ImageRect(posx-56*alertScale,posy-56*alertScale,112*alertScale,112*alertScale,alertLeftBG,1,0)
		gfx.BeginPath()
		gfx.ImageRect(posx-26*alertScale,posy-23*alertScale,52*alertScale,46*alertScale,alertLeft,alertTimers[1]*4%0.75 + 0.25,0)
		
		
    end
    if alertTimers[2] > 0 then --draw right alert
        gfx.Save()
        local posx = desw / 2 + 350
        local posy = desh * critLinePos[1] - 135
        if portrait then 
            posy = desh * critLinePos[2] - 135 
            posx = desw - 65
        end
        local alertScale = (-(alertTimers[2] ^ 2.0) + (1.5 * alertTimers[2])) * 5.0
        alertScale = math.min(alertScale, 1)
        gfx.BeginPath()
		gfx.ImageRect(posx-56*alertScale,posy-56*alertScale,112*alertScale,112*alertScale,alertRightBG,1,0)
		gfx.BeginPath()
		gfx.ImageRect(posx-26*alertScale,posy-23*alertScale,52*alertScale,46*alertScale,alertRight,alertTimers[2]*4%0.75 + 0.25,0)
    end
end
-- -------------------------------------------------------------------------- --
-- render_intro:                                                              --
function render_intro(deltaTime)
	if not introPlayed then
		introPlayed = true
		game.PlaySample("boot_song");
	end

    if introTimer > 0.5 or not game.GetButton(game.BUTTON_STA) then
        introTimer = introTimer - deltaTime
    end
    introTimer = math.max(introTimer, 0)
    return introTimer <= 0
end
-- -------------------------------------------------------------------------- --
-- render_outro:                                                              --
function render_outro(deltaTime, clearState)
    if clearState == 0 then return true end
    gfx.ResetTransform()
    gfx.BeginPath()
    gfx.Rect(0,0,resx,resy)
    --gfx.FillColor(0,0,0, math.floor(127 * math.min(outroTimer, 1)))
    --gfx.Fill()
    gfx.Scale(scale,scale)
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE)
    gfx.FillColor(255,255,255, math.floor(255 * math.min(outroTimer, 1)))
    gfx.LoadSkinFont("NovaMono.ttf")
    gfx.FontSize(70)
	
	if outroTimer < 4 then
		gfx.Text(clearTexts[clearState], desw / 2, desh / 2)
	elseif clearState == 4 or clearState == 5 then
		gfx.Text(clearTexts[2], desw / 2, desh / 2)
	end
	
	if not resultPlayed then
		resultPlayed = true
		if clearState == 1 then
			game.PlaySample("failed")
		elseif clearState == 2 then
			game.PlaySample("clear")
		elseif clearState == 3 then
			game.PlaySample("clear")
		elseif clearState == 4 then
			game.PlaySample("fullcombo")
		else
			game.PlaySample("perfect")
		end
	end
	
	if resultPlayed and not clearPlayed and outroTimer > 4 then
		if clearState == 4 or clearState == 5 then
			clearPlayed = true
			game.PlaySample("clear")
		end
	end
	
    outroTimer = outroTimer + deltaTime
	
	
	if clearState < 4 then
		return outroTimer > 4, 1 - outroTimer
	else
		return outroTimer > 8, 1 - outroTimer
	end
end
-- -------------------------------------------------------------------------- --
-- update_score:                                                              --
function update_score(newScore)
    score = newScore
end
-- -------------------------------------------------------------------------- --
-- update_combo:                                                              --
function update_combo(newCombo)
    combo = newCombo
    comboScale = 1.5
end
-- -------------------------------------------------------------------------- --
-- near_hit:                                                                  --
function near_hit(wasLate) --for updating early/late display
    late = wasLate
    earlateTimer = 0.75
end
-- -------------------------------------------------------------------------- --
-- laser_alert:                                                               --
function laser_alert(isRight) --for starting laser alert animations
    if isRight and alertTimers[2] < -1.5 then
        alertTimers[2] = 1.5
    elseif alertTimers[1] < -1.5 then
        alertTimers[1] = 1.5
    end
end