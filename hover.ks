run once science.
run once other.

function hover {
    parameter maxVertSpeed is 1.
    parameter height is alt:radar.
    //(travelHeight, travelTime, direction[0:N,1:E,2:S,3:W])
    parameter move is list().
    parameter target is waypoint("flyhere").
    parameter maxHorizSpeed is 1.
    clearscreen.

    local lock posAboveTarget to target:position.// + (target:position - ship:orbit:body:position):normalized * 50.
    local lock posError to posAboveTarget - ship:position.
    print posError.
    //lock height to vdot(posError, posError - ship:body:position).

    local ewPosPid to pidloop().//0.006, (0.012/30), ((0.006*30)/8)).
    set ewPosPid:setpoint to 0.
    print "target height: " + ewPosPid:setpoint at (0,10).
    set ewPosPid:minoutput to -maxHorizSpeed.
    set ewPosPid:maxoutput to maxHorizSpeed.
    print "target max abs ew speed: " + ewPosPid:maxoutput at (0,13).

    local ewPid to pidloop(2).
    set ewPid:setpoint to 0. //positive means go east
    print "target ew-speed: " + ewPid:setpoint at (0,11).
    set ewPid:minoutput to -80.//-45.
    set ewPid:maxoutput to 80.//45.

    local nsPosPid to pidloop().//0.006, (0.012/30), ((0.006*30)/8)).
    set nsPosPid:setpoint to 0.
    print "target height: " + nsPosPid:setpoint at (0,10).
    set nsPosPid:minoutput to -maxHorizSpeed.
    set nsPosPid:maxoutput to maxHorizSpeed.
    print "target max abs ew speed: " + nsPosPid:maxoutput at (0,13).

    local nsPid to pidloop(2).
    set nsPid:setpoint to 0. //positive means go north
    print "target ns-speed: " + nsPid:setpoint at (0,12).
    set nsPid:minoutput to -80.//-45.
    set nsPid:maxoutput to 80.//45.

    local vertPosPid to pidloop().//0.006, (0.012/30), ((0.006*30)/8)).
    set vertPosPid:setpoint to 0.
    print "target height: " + vertPosPid:setpoint at (0,10).
    set vertPosPid:minoutput to -maxVertSpeed.
    set vertPosPid:maxoutput to maxVertSpeed.
    print "target max abs vert speed: " + vertPosPid:maxoutput at (0,13).

    local vertSpeedPid to pidloop().//0.006, (0.012/30), ((0.006*30)/8)).
    set vertSpeedPid:setpoint to 0.
    set vertSpeedPid:minoutput to -1.
    set vertSpeedPid:maxoutput to 1.

    local lock eastVec to vcrs(north:forevector, body:position):normalized.
    local lock vertThrustRatio to vdot(ship:up:forevector, ship:facing:forevector).
    local tset to 0.
    lock throttle to tset + (fgh()/(ship:availablethrust))/vertThrustRatio.
    local startTime to time:seconds.

    local lock ewVel to vdot(ship:velocity:surface, eastVec).
    local lock nsVel to vdot(ship:velocity:surface, ship:north:forevector).
    local lock vertVel to vdot(ship:velocity:surface, ship:up:forevector).

    on AG1 {
        set target to waypoint("flyhere").
        print "going to flyhere" at (0,15).
        return True.
    }

    on AG2 {
        set target to waypoint("flyhere2").
        print "going to flyhere2" at (0,15).
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

    //when alt:radar > 500 then {
    //    set vertPosPid:setpoint to 50.
    //}

    if move:length > 0 {
        set vertPosPid:setpoint to move[0].
        if move[2] = 0 {
            set nsPid:setpoint to 50.
        }
        if move[2] = 2 {
            set nsPid:setpoint to -50.
        }
        if move[2] = 1 {
            set ewPid:setpoint to 50.
        }
        if move[2] = 3 {
            set ewPid:setpoint to -50.
        }
        local moveStartTime to time:seconds.
        when time:seconds > moveStartTime + move[1] then {
            set nsPid:setpoint to 0.
            set ewPid:setpoint to 0.
            when ship:velocity:surface:mag < 5 then {
                set vertPosPid:setpoint to 10.
                set vertSpeedPid:maxoutput to 5.
                set vertSpeedPid:minoutput to -5.
                when alt:radar <= 10 then {
                    when nsVel < 0.1 and ewVel < 0.1 then {
                        set vertPosPid:setpoint to -1.
                        set vertSpeedPid:maxoutput to 0.5.
                        set vertSpeedPid:minoutput to -0.5.
                    }
                }
            }
        }
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

    local srfVel to vecdraw({return ship:position.}, {return vdot(posError, ship:up:forevector)*ship:up:forevector:normalized.}, red).
    set srfVel:show to true.  
    local pose to vecdraw({return ship:position.}, {return posError.}, green).
    set pose:show to true.  

    print "AG0 to stop".
    until stop = True {
        set vertSpeedPid:setpoint to vertPosPid:update(time:seconds, -vdot(posError, ship:up:forevector)). 
        set tset to vertSpeedPid:update(time:seconds, vertVel).
        print vertVel at (0,5).
        print "target height: " + vertPosPid:setpoint at (0,10).
        print "height input; " + vdot(posError, ship:up:forevector) at (0,11).
        
        set nsPid:setpoint to nsPosPid:update(time:seconds, -vdot(posError, ship:north:forevector)).
        local nsPidVal to nsPid:update(time:seconds, nsVel).
        set ewPid:setpoint to ewPosPid:update(time:seconds, -vdot(posError, eastVec)).
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

hover().

    //local vd to vecdraw({return ship:position.}, {return steering:forevector*20.}).
    //set vd:show to true.
