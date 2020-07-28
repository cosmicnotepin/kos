run once science.

function gh {
    return constant:G *((ship:body:mass)/((ship:altitude + body:radius)^2)).
}

function fgh {
    return ship:mass*gh().
}

function hoverAt {
    parameter height.
    stage.
    clearscreen.

    //local a to angleaxis(45, north:starvector) * angleaxis(15, north:forevector) * ship:up.
    //set te to vecdraw(ship:position, a:forevector*20, red, "north", 1.0, true, 0.2, true, true).
    //set te:show to true.
    //set n to vecdraw(ship:position, ship:north:forevector*20, red, "north", 1.0, true, 0.2, true, true).
    //set n:show to true.
    //set t to vecdraw(ship:position, ship:north:topvector*20, blue, "top", 1.0, true, 0.2, true, true).
    //set t:show to true.
    //set e to vecdraw(ship:position, ship:north:starvector*20, green, "star", 1.0, true, 0.2, true, true).
    //set e:show to true.
    //set e to vecdraw(ship:position, ship:up:forevector*20, green, "up", 1.0, true, 0.2, true, true).
    //set e:show to true.
    //set mysteer to heading(90,90).
    //lock steering to mysteer.

    local ewPid to pidloop().
    set ewPid:setpoint to 0.
    set ewPid:minoutput to -45.
    set ewPid:maxoutput to 45.


    local nsPid to pidloop().
    set nsPid:setpoint to 0.
    set nsPid:minoutput to -45.
    set nsPid:maxoutput to 45.

    local topPid to pidloop(0.006, (0.012/30), ((0.006*30)/8)).
    set topPid:setpoint to height.
    set topPid:minoutput to -1.
    set topPid:maxoutput to 1.

    lock vertThrustRatio to vdot(ship:up:forevector, ship:facing:forevector).
    lock throttle to tset + (fgh()/(ship:availablethrust))/vertThrustRatio.
    local startTime to time:seconds.

    local lock ewVel to vdot(ship:velocity:surface, vcrs(north:forevector, body:position):normalized).
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

    local sw to 1.
    local sw2 to 1.
    on ag1 {
        set sw to sw * -1.
        return true.
    }
    on ag2 {
        set sw2 to sw * -1.
        return true.
    }
    until ship:status = "landed" and time:seconds > (startTime + 10){
        set tset to topPid:update(time:seconds, alt:radar).
        print "nsvel: " + nsVel at (0,15).
        print "ewVel: " + ewVel at (0,16).
        print "vertThrustRatio : " + vertThrustRatio at(0,17).
        
        local nsPidVal to sw2 * nsPid:update(time:seconds, nsVel).
        print "nsPidVal : " + nsPidVal at (0,18).
        local ewPidVal to sw * -ewPid:update(time:seconds, ewVel).
        print "ewPidVal : " + ewPidVal at (0,19).
        print "ew p : " + ewPid:pterm at (0,20).
        print "ew i : " + ewPid:iterm at (0,21).
        print "ew t : " + ewPid:dterm at (0,22).
        print "ew e : " + ewPid:error at (0,23).
        local ewPitch to angleaxis(ewPidVal, north:forevector).
        local nsPitch to angleaxis(nsPidVal, vcrs(north:forevector, body:position)).
        local turnOnce to ewPitch * ship:up.
        local turnTwice to nsPitch * turnOnce.
        set steering to turnTwice.
        //set steering to angleaxis( nsPidVal, north:starvector) * angleaxis(ewPidVal, north:forevector) * ship:up.
        //set steering to ship:up + R(nsPidVal, ewPidVal, 0).
        wait 0.
        set e to vecdraw(ship:position,steering:forevector*20, green, "up", 1.0, true, 0.2, true, true).
        set e:show to true.
        set t to vecdraw(ship:position,steering:topvector*20, red, "up", 1.0, true, 0.2, true, true).
        set t:show to true.
        set nvd to vecdraw(ship:position,north:forevector*20, green, "fore", 1.0, true, 0.2, true, true).
        set nvd:show to true.
        set nsvd to vecdraw(ship:position,vcrs(north:forevector, body:position):normalized*20, green, "star", 1.0, true, 0.2, true, true).
        set nsvd:show to true.
        //set ntvd to vecdraw(ship:position,north:topvector*20, green, "top", 1.0, true, 0.2, true, true).
        //set ntvd:show to true.
    }
    lock throttle to 0.
    set ship:control:pilotmainthrottle to 0.
    doScience(false).
}

hoverAt(20).

    //on ag2 {
    //    set height to max(height - 1, 0).
    //    set topPid:setpoint to height.
    //    print "sp: " + height at (0,16).
    //    return true.
    //}
    //on ag3 {
    //    set height to max(height + 1, 0).
    //    set topPid:setpoint to height.
    //    print "sp: " + height at (0,16).
    //    return true.
    //}
    //set current to AG1.
    //until AG1 <> current {
    //    set tset to topPid:update(time:seconds, alt:radar).
    //    wait 0.
    //}
