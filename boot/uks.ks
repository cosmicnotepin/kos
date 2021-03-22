wait 0.1.
core:part:getmodule("kosprocessor"):doevent("open terminal").
clearscreen.
if status = "prelaunch" {
    run once fun.
}
run hover.ks.
