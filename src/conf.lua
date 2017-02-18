function love.conf(t)
    t.modules.joystick = false
    t.modules.physics = false
    t.window.resizable = true
    t.window.height = 512
    t.window.width = t.window.height*3/2
    t.version = "0.10.2"
end
