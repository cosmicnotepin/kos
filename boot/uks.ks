set config:ipu to 2000.
wait 0.1.
core:part:getmodule("kosprocessor"):doevent("open terminal").
clearscreen.
if status = "prelaunch" {
    run once fun.
}
//run superHover.ks.
//run hover.ks.
