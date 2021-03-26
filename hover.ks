run once science.
run once other.

set config:ipu to 2000.

function hover {
    parameter maxVertSpeed is 1.
    parameter maxHorizSpeed is 1.
    parameter height is alt:radar.
    parameter geoPos is ship:geoposition. //expects a waypoint
    clearscreen.

    local ewOffset is 0. //for diverting horizontally, keeping AGL
    local nsOffset is 0. //for diverting horizontally, keeping AGL
    local lock eastVec to vcrs(north:forevector, body:position):normalized.
    local lock northVec to ship:north:forevector:normalized.
    local lock posTar to geoPos:altitudeposition(geoPos:terrainheight + height).
    local lock geoPosOff to body:geopositionof(posTar + eastVec*ewOffset + northVec*nsOffset).
    local lock posTarOff to geoPosOff:altitudeposition(geoPosOff:terrainheight + height).
    local lock posError to posTarOff - ship:position.

    local ewPosPid to pidloop(0.1, 0, 0, -maxHorizSpeed, maxHorizSpeed).
    set ewPosPid:setpoint to 0.

    local ewPid to pidloop(0.2, 0, 0, -1, 1).
    set ewPid:setpoint to 0. //positive means go east

    local nsPosPid to pidloop(0.1, 0, 0, -maxHorizSpeed, maxHorizSpeed).
    set nsPosPid:setpoint to 0.

    local nsPid to pidloop(0.2, 0, 0, -1, 1).
    set nsPid:setpoint to 0. //positive means go north

    local vertPosPid to pidloop(1, 0, 0, -maxVertSpeed, maxVertSpeed).
    set vertPosPid:setpoint to 0.

    local vertSpeedPid to pidloop(1, 0, 0, -1, 1).
    set vertSpeedPid:setpoint to 0.

    local lock vertThrustRatio to vdot(ship:up:forevector, ship:facing:forevector).
    local tset to 0.
    local lock vertThrust to tset + fgh()/ship:availablethrust.
    lock throttle to vertThrust/vertThrustRatio.

    //max horizontal thrust that can be requested without interfering with altitude control's current
    //thrust request - assuming we just want to keep hovering at the current altitude
    local lock maxHorizThrustHover to (1 - (fgh()/ship:availablethrust)^2)^(1/2).
    //max horizontal thrust that can be requested without interfering with altitude control's current
    //thrust request
    local lock maxHorizThrustNow to (1 - min(1, (tset + fgh()/ship:availablethrust)^2))^(1/2).

    local lock ewVel to vdot(ship:velocity:surface, eastVec).
    local lock nsVel to vdot(ship:velocity:surface, ship:north:forevector).
    local lock vertVel to vdot(ship:velocity:surface, ship:up:forevector).

    //action groups mainly for testing
    on AG1 {
        set ewOffset to ewOffset - 10.
        return True.
    }

    on AG2 {
        set nsOffset to nsOffset + 10.
        return True.
    }

    on AG3 {
        set nsOffset to nsOffset - 10.
        return True.
    }

    on AG4 {
        set ewOffset to ewOffset + 10.
        return True.
    }

    on AG5 {
        set height to height + 10.
        return True.
    }


    on AG6 {
        set height to height - 10.
        return True.
    }

    on AG10 {
        set stop to True.
        return True.
    }


    //vecdraw for debugging
    local pose to vecdraw({return ship:position.}, {return vdot(posError, northVec)*northVec.}, green).
    set pose:show to true.  
    local pose2 to vecdraw({return ship:position.}, {return vdot(posError, eastVec)*eastVec.}, green).
    set pose2:show to true.  
    local ewPidVal is 10.
    local nsPidVal is 10.
    local ht1 to vecdraw({return ship:position.}, {return 100*nsPidVal*northVec.}, blue).
    set ht1:show to true.  
    local ht2 to vecdraw({return ship:position.}, {return 100*ewPidVal*eastVec.}, blue).
    set ht2:show to true.  
    local steerVec to lookdirup(ship:up:forevector:normalized, ship:facing:topvector).
    local sv to vecdraw({return ship:position.}, {return steerVec:forevector*10.}, magenta).
    set sv:show to true.  

    //main loop
    print "AG0 to stop".
    local stop to False.
    until stop = True {
        set vertSpeedPid:setpoint to vertPosPid:update(time:seconds, -vdot(posError, ship:up:forevector)). 
        set tset to vertSpeedPid:update(time:seconds, vertVel).

        set nsPid:setpoint to nsPosPid:update(time:seconds, -vdot(posError, northVec)).
        local nsPidVal to nsPid:update(time:seconds, nsVel) * maxHorizThrustHover. // scale to max horizThrust that still supports hovering
        set ewPid:setpoint to ewPosPid:update(time:seconds, -vdot(posError, eastVec)).
        local ewPidVal to ewPid:update(time:seconds, ewVel) * maxHorizThrustHover. // scale to max horizThrust that still supports hovering
        //maxHorizThrustHover ignores possible altitude changes (and the thrust they require,
        //and the fact that going both east and north at maxHorizThrustHover requires more than
        //maxHorizThrustHover in case we would want more we scale the horizontal thrust down so
        //that the vertical control is unaffected
        local requestedHorizThrust to (nsPidVal^2 + ewPidVal^2)^(1/2).
        if requestedHorizThrust > maxHorizThrustNow {
            local scaling is maxHorizThrustNow/requestedHorizThrust.
            set nsPidVal to nsPidVal * scaling.
            set ewPidVal to ewPidVal * scaling.  
        }

        set steerVec to lookdirup(ship:up:forevector:normalized + eastVec*ewPidVal + northVec * nsPidVal, ship:facing:topvector).  
        set steering to steerVec.
        wait 0.
    }
    print "done with loop".

    lock throttle to 0.
    set ship:control:pilotmainthrottle to 0.
}

hover(5, 10, waypoint("flyhere"):agl, waypoint("flyhere"):geoposition).
