
function autopilot {
    parameter maxPitchAngle is 10.
    parameter maxVertSpeed is 10.
    clearscreen.
    clearvecdraws().
    print "Autopilot engaged, holding altitude and heading".
    print "AG10 (0) to stop".
    local origDirection is ship:facing.
    local lock noRollHoriz to lookdirup(vcrs(ship:facing:starvector, -ship:body:position), -ship:body:position).
    local vertPosPid to pidloop(0.1,0,1).//0.006, (0.012/30), ((0.006*30)/8)).
    set vertPosPid:setpoint to altitude.
    print "target height: " + vertPosPid:setpoint at (0,10).
    set vertPosPid:minoutput to -maxVertSpeed.
    set vertPosPid:maxoutput to maxVertSpeed.
    print "target maxVertSpeed: " + vertPosPid:maxoutput at (0,13).

    local vertSpeedPid to pidloop().//0.006, (0.012/30), ((0.006*30)/8)).
    set vertSpeedPid:setpoint to 0.
    set vertSpeedPid:minoutput to -maxPitchAngle.
    set vertSpeedPid:maxoutput to maxPitchAngle.
    print "target maxPitchAngle: " + vertSpeedPid:maxoutput at (0,13).

    local stop to False.

    on AG10 {
        set stop to True.
        return True.
    }

    local newdir is ship:facing.
    local lock steering to newDir.
    local vdd to vecdraw({return ship:position.}, {return newDir:forevector*20.}, red).
    local vd to vecdraw({return ship:position.}, {return noRollHoriz:forevector*20.}, white).
    set vd:show to true.
    set vdd:show to true.

    local lock vertVel to vdot(ship:velocity:surface, ship:up:forevector).
    until stop = True {
        set vertSpeedPid:setpoint to vertPosPid:update(time:seconds, altitude). 
        local pitchChangeDeg is -vertSpeedPid:update(time:seconds, vertVel). 
        local pitchChangeRot is angleaxis(pitchChangeDeg, noRollHoriz:starvector).
        set newDir to pitchChangeRot*noRollHoriz.  
        wait 0.
    }
    unlock steering.
}

autopilot(5,5).

