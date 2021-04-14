
parameter targetWPName is "x".

function autopilot {
    parameter targetWPName.
    parameter maxPitchAngle is 10.
    parameter maxVertSpeed is 10.

    local lastQuickSaveTime to time:seconds.
    local save1 to "autpilot1".
    local save2 to "autpilot2".
    local save to save1.
    when time:seconds > lastQuickSaveTime + 60 then {
        if kuniverse:canquicksave {
            kuniverse:quicksaveto(save).
        }
        set save to choose save1 if save = save2 else save2.
        set lastQuickSaveTime to time:seconds.
        return true.
    }

    local selectedWP to "x".  
    local parameterWP to "x".  
    local targetWP to "x".
    for wp in allwaypoints() {
        if wp:isselected {
            set selectedWP to wp.
        }
        if wp:name = targetWPName {
            set parameterWP to wp.
        }
    }
    if not (parameterWP = "x") {
        lock noRollHoriz to lookdirup(vxcl(ship:body:position, parameterWP:position):normalized, -ship:body:position).
    } else if not (selectedWP = "x") {
        lock noRollHoriz to lookdirup(vxcl(ship:body:position, selectedWP:position):normalized, -ship:body:position).
    } else { 
        lock noRollHoriz to lookdirup(vcrs(ship:facing:starvector, -ship:body:position), -ship:body:position).
    }

    clearscreen.
    clearvecdraws().
    local vertPosPid to pidloop(0.05,0.001,1).//0.006, (0.012/30), ((0.006*30)/8)).
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

    local newdir is ship:facing.
    local lock steering to newDir.
    local vdd to vecdraw({return ship:position.}, {return newDir:forevector*20.}, red).
    local vd to vecdraw({return ship:position.}, {return noRollHoriz:forevector*20.}, white).
    set vd:show to true.
    set vdd:show to true.


    local stop to False.

    on AG10 {
        set stop to True.
        return True.
    }

    local lock vertVel to vdot(ship:velocity:surface, ship:up:forevector).
    print "autopilot running".
    until stop = True {
        set vertSpeedPid:setpoint to vertPosPid:update(time:seconds, altitude). 
        local pitchChangeDeg is -vertSpeedPid:update(time:seconds, vertVel). 
        local pitchChangeRot is angleaxis(pitchChangeDeg, noRollHoriz:starvector).
        set newDir to pitchChangeRot*noRollHoriz.  
        wait 0.
    }
    unlock steering.
    print "autopilot deactivated".
}

until false {
    print "Autopilot ready, AG0 to start/stop".
    local current to AG10.
    wait until AG10 <> current.
    autopilot(targetWPName, 5, 5).
    clearvecdraws().
}

