function love.conf(game)
    game.window.title = "Little Boxes"
    -- game.window.icon = "gfx_icon.png"
    game.window.width = 800
    game.window.height = 600
    game.window.resizable = true
    
    game.modules.joystick = false
    game.modules.physics = false
end