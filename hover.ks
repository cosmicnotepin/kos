run once science.
run once other.

function hover {
    parameter maxVertSpeed is 10.
    parameter height is alt:radar.
    //parameter height.
    stage.
    clearscreen.

    local ewPid to pidloop().
    set ewPid:setpoint to 0. //positive means go east
    print "target ew-speed: " + ewPid:setpoint at (0,11).
    set ewPid:minoutput to -45.
    set ewPid:maxoutput to 45.


    local nsPid to pidloop().
    set nsPid:setpoint to 0. //positive means go north
    print "target ns-speed: " + nsPid:setpoint at (0,12).
    set nsPid:minoutput to -45.
    set nsPid:maxoutput to 45.

    local vertPosPid to pidloop().//0.006, (0.012/30), ((0.006*30)/8)).
    set vertPosPid:setpoint to height.
    print "target height: " + vertPosPid:setpoint at (0,10).
    set vertPosPid:minoutput to -maxVertSpeed.
    set vertPosPid:maxoutput to maxVertSpeed.
    print "target max abs vert speed: " + vertPosPid:maxoutput at (0,13).

    local vertSpeedPid to pidloop().//0.006, (0.012/30), ((0.006*30)/8)).
    set vertSpeedPid:setpoint to 0.
    set vertSpeedPid:minoutput to -1.
    set vertSpeedPid:maxoutput to 1.

    lock eastVec to vcrs(north:forevector, body:position):normalized.
    lock vertThrustRatio to vdot(ship:up:forevector, ship:facing:forevector).
    local tset to 0.
    lock throttle to tset + (fgh()/(ship:availablethrust))/vertThrustRatio.
    local startTime to time:seconds.

    local lock ewVel to vdot(ship:velocity:surface, eastVec).
    local lock nsVel to vdot(ship:velocity:surface, ship:north:forevector).
    local lock vertVel to vdot(ship:velocity:surface, ship:up:forevector).

    on AG1 {
        set ewPid:setpoint to 0.
        set nsPid:setpoint to 0.
        set vertPosPid:setpoint to alt:radar.
        print "target height: " + vertPosPid:setpoint at (0,10).
        return True.
    }

    on AG2 {
        set vertPosPid:setpoint to vertPosPid:setpoint + 1.
        print "target height: " + vertPosPid:setpoint at (0,10).
        return True.
    }

    on AG3 {
        set vertPosPid:setpoint to vertPosPid:setpoint - 1.
        print "target height: " + vertPosPid:setpoint at (0,10).
        return True.
    }


    on AG4 {
        set ewPid:setpoint to ewPid:setpoint + 1.
        print "target ew-speed: " + ewPid:setpoint at (0,11).
        return True.
    }

    on AG5 {
        set ewPid:setpoint to ewPid:setpoint - 1.
        print "target ew-speed: " + ewPid:setpoint at (0,11).
        return True.
    }

    on AG6 {
        set nsPid:setpoint to nsPid:setpoint + 1.
        print "target ns-speed: " + nsPid:setpoint at (0,12).
        return True.
    }

    on AG7 {
        set nsPid:setpoint to nsPid:setpoint - 1.
        print "target ns-speed: " + nsPid:setpoint at (0,13).
        return True.
    }

    on AG8 {
        set vertPosPid:maxoutput to vertPosPid:maxoutput - 1.
        set vertPosPid:minoutput to vertPosPid:minoutput + 1.
        print "target max abs vert speed: " + vertPosPid:maxoutput at (0,13).
        return True.
    }

    on AG9 {
        set vertPosPid:maxoutput to vertPosPid:maxoutput + 1.
        set vertPosPid:minoutput to vertPosPid:minoutput - 1.
        print "target max abs vert speed: " + vertPosPid:maxoutput at (0,13).
        return True.
    }

    local stop to False.

    on AG10 {
        set stop to True.
        return True.
    }

    when alt:radar > 500 then {
        set vertPosPid:setpoint to 50.
    }

    //when time:seconds > startTime + 10 then {
    //    set ewPid:setpoint to -45.
    //    print "t+10".
    //    when time:seconds > startTime + 25 then {
    //        print "t+40".
    //        set ewPid:setpoint to 0.
    //        set nsPid:setpoint to 45.
    //        when time:seconds > startTime + 40 then {
    //            print "t+70".
    //            set nsPid:setpoint to 0.
    //            when abs(ewVel) < 0.5 and abs(nsVel) < 0.5 then {
    //                print "landingi".
    //                set vertPosPid:setpoint to 0.  
    //            }
    //        }
    //    }
    //}

    print "running hover loop".
    print "AG0 to stop".
    until stop = True {
        set vertSpeedPid:setpoint to vertPosPid:update(time:seconds, alt:radar). 
        set tset to vertSpeedPid:update(time:seconds, vertVel).
        print vertVel at (0,5).
        
        local nsPidVal to nsPid:update(time:seconds, nsVel).
        local ewPidVal to -ewPid:update(time:seconds, ewVel).
        local ewPitch to angleaxis(ewPidVal, north:forevector).
        local nsPitch to angleaxis(nsPidVal, eastVec).
        set steering to nsPitch * ewPitch * ship:up.
        wait 0.
    }
    print "done with loop".
    lock throttle to 0.
    set ship:control:pilotmainthrottle to 0.
    //doScience(false).
}

    //local vd to vecdraw({return ship:position.}, {return steering:forevector*20.}).
    //set vd:show to true.
