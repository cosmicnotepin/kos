run once science.
run once other.

function hoverAt {
    parameter height.
    stage.
    clearscreen.

    local ewPid to pidloop().
    set ewPid:setpoint to 0. //positive means go east
    set ewPid:minoutput to -45.
    set ewPid:maxoutput to 45.


    local nsPid to pidloop().
    set nsPid:setpoint to 0. //positive means go north
    set nsPid:minoutput to -45.
    set nsPid:maxoutput to 45.

    local topPid to pidloop(0.006, (0.012/30), ((0.006*30)/8)).
    set topPid:setpoint to height.
    set topPid:minoutput to -1.
    set topPid:maxoutput to 1.

    lock eastVec to vcrs(north:forevector, body:position):normalized.
    lock vertThrustRatio to vdot(ship:up:forevector, ship:facing:forevector).
    lock throttle to tset + (fgh()/(ship:availablethrust))/vertThrustRatio.
    local startTime to time:seconds.

    local lock ewVel to vdot(ship:velocity:surface, eastVec).
    local lock nsVel to vdot(ship:velocity:surface, ship:north:forevector).
    when time:seconds > startTime + 10 then {
        set ewPid:setpoint to -45.
        print "t+10".
        when time:seconds > startTime + 25 then {
            print "t+40".
            set ewPid:setpoint to 0.
            set nsPid:setpoint to 45.
            when time:seconds > startTime + 40 then {
                print "t+70".
                set nsPid:setpoint to 0.
                when abs(ewVel) < 0.5 and abs(nsVel) < 0.5 then {
                    print "landingi".
                    set topPid:setpoint to 0.  
                }
            }
        }
    }

    until ship:status = "landed" and time:seconds > (startTime + 10){
        set tset to topPid:update(time:seconds, alt:radar).
        
        local nsPidVal to nsPid:update(time:seconds, nsVel).
        local ewPidVal to -ewPid:update(time:seconds, ewVel).
        local ewPitch to angleaxis(ewPidVal, north:forevector).
        local nsPitch to angleaxis(nsPidVal, eastVec).
        set steering to nsPitch * ewPitch * ship:up.
        wait 0.
    }
    lock throttle to 0.
    set ship:control:pilotmainthrottle to 0.
    doScience(false).
}

hoverAt(20).

    //local vd to vecdraw({return ship:position.}, {return steering:forevector*20.}).
    //set vd:show to true.
