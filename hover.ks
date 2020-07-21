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

    set n to vecdraw(ship:position, ship:north:forevector*20, red, "north", 1.0, true, 0.2, true, true).
    set n:show to true.
    set t to vecdraw(ship:position, ship:north:topvector*20, blue, "top", 1.0, true, 0.2, true, true).
    set t:show to true.
    set e to vecdraw(ship:position, ship:north:starvector*20, green, "star", 1.0, true, 0.2, true, true).
    set e:show to true.
    set mysteer to heading(90,90).
    lock steering to mysteer.

    //local ewPid to pidloop(0.006, (0.012/30), ((0.006*30)/8)).
    local ewPid to pidloop().
    set ewPid:setpoint to 0.
    set ewPid:minoutput to -5.
    set ewPid:maxoutput to 5.
    //local topPid to pidloop(0.02, 0.05, 0.05).
    //local topPid to pidloop(0.01, 0.00, 0.00).
    local topPid to pidloop(0.006, (0.012/30), ((0.006*30)/8)).
    set topPid:setpoint to height.
    set topPid:minoutput to -1.
    set topPid:maxoutput to 1.
    lock throttle to tset + (fgh()/(ship:availablethrust)).
    local startTime to time:seconds.
    local ewVel to 0.

    when time:seconds > startTime + 10 then {
        set ewPid:setpoint to 5.
    }
    when time:seconds > startTime + 40 then {
        set ewPid:setpoint to 0.
    }
    when time:seconds > startTime + 50 then {
        set topPid:setpoint to 0.
    }
    until ship:status = "landed" and time:seconds > (startTime + 10){
        set tset to topPid:update(time:seconds, alt:radar).
        set ewVel to vdot(ship:velocity:surface, ship:north:starvector).
        print ewVel at (0,16).
        set mysteer to heading(90, 90 + ewPid:update(time:seconds, ewVel)).
        wait 0.
    }
    lock throttle to 0.
    set ship:control:pilotmainthrottle to 0.
    doScience(false).
}

hoverAt(5).

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
