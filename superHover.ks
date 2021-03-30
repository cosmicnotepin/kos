run once science.
run once other.

set config:ipu to 2000.

function horizStoppingDist {
    parameter maxHorizThrustNow.
    parameter speed.
    parameter posError.
    parameter tilt.
    parameter turnrate.
    local rotDelayDist to 0.

    if speed > 0 and tilt > 0 or speed <= 0 and tilt <= 0 {
        set rotDelayDist to abs((tilt/turnrate)*speed).//the distance it takes to turn so that the return value equation becomes more correct
    }

    return  (abs(speed)/speed) * rotDelayDist + (abs(speed)/speed) * (speed^2)/(2*max(0.001, maxHorizThrustNow/(ship:mass))).
}

function hover {
    parameter maxVertSpeed is 1.
    parameter maxHorizSpeed is 1.
    parameter height is alt:radar.
    parameter geoPos is ship:geoposition. //expects a waypoint
    clearscreen.

    local ewOffset is 0.
    local nsOffset is 0.
    local lock eastVec to vcrs(north:forevector, body:position):normalized.
    local lock northVec to ship:north:forevector:normalized.
    local lock posTar to geoPos:altitudeposition(geoPos:terrainheight + height).
    local lock geoPosOff to body:geopositionof(posTar + eastVec*ewOffset + northVec*nsOffset).
    local lock posTarOff to geoPosOff:altitudeposition(geoPosOff:terrainheight + height).
    local lock posError to posTarOff - ship:position.

    local vertPosPid to pidloop().
    set vertPosPid:setpoint to 0.
    set vertPosPid:minoutput to -maxVertSpeed.
    set vertPosPid:maxoutput to maxVertSpeed.

    local vertSpeedPid to pidloop().
    set vertSpeedPid:setpoint to 0.
    set vertSpeedPid:minoutput to -1.
    set vertSpeedPid:maxoutput to 1.

    local lock vertThrustRatio to vdot(ship:up:forevector, ship:facing:forevector).
    local tset to 0.
    local lock vertThrust to tset + fgh()/ship:availablethrust.
    lock throttle to vertThrust/vertThrustRatio.
    local lock maxHorizThrustHover to (1 - (fgh()/ship:availablethrust)^2)^(1/2).
    local lock maxHorizThrustNow to (1 - min(1, (tset + fgh()/ship:availablethrust)^2))^(1/2).

    local lock ewVel to vdot(ship:velocity:surface, eastVec).
    local lock nsVel to vdot(ship:velocity:surface, northVec).
    local lock vertVel to vdot(ship:velocity:surface, ship:up:forevector).

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

    local turnrate to 0.005.
    on AG6 {
        set turnrate to turnrate + 0.005.
        print turnrate at (0,15).
        return True.
    }

    on AG5 {
        set turnrate to turnrate - 0.005.
        print turnrate at (0,15).
        return True.
    }

    local stop to False.

    on AG10 {
        set stop to True.
        return True.
    }

    //local srfVel to vecdraw({return ship:position.}, {return ewVel*eastVec.}, red).
    //set srfVel:show to true.  
    //local srfVel2 to vecdraw({return ship:position.}, {return nsVel*northVec.}, yellow).
    //set srfVel2:show to true.  
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

    print "AG0 to stop superhover".
    until stop = True {
        set vertSpeedPid:setpoint to vertPosPid:update(time:seconds, -vdot(posError, ship:up:forevector)). 
        set tset to vertSpeedPid:update(time:seconds, vertVel).

        local nsError to vdot(posError, northVec).
        local ewError to vdot(posError, eastVec).
        set nsPidVal to nsError - horizStoppingDist(maxHorizThrustHover, nsVel, nsError, vdot(ship:facing:forevector:normalized, northVec), turnrate).
        set ewPidVal to ewError - horizStoppingDist(maxHorizThrustHover, ewVel, ewError, vdot(ship:facing:forevector:normalized, eastVec), turnrate).
        set nsPidVal to nsPidVal/100.
        set ewPidVal to ewPidVal/100.
        print vdot(ship:facing:forevector:normalized, eastVec) at (0,12).
        local requestedHorizThrust to (nsPidVal^2 + ewPidVal^2)^(1/2).
        if requestedHorizThrust > maxHorizThrustHover {
            local scaling is maxHorizThrustHover/requestedHorizThrust.
            set nsPidVal to nsPidVal * scaling.
            set ewPidVal to ewPidVal * scaling.  
        }

        set steerVec to unrotate(ship:up:forevector:normalized + eastVec*ewPidVal + northVec * nsPidVal).  
        set steering to steerVec.
        wait 0.
    }
    print "done with loop".

    lock throttle to 0.
    set ship:control:pilotmainthrottle to 0.
}

hover(5, 10, waypoint("flyhere"):agl, waypoint("flyhere"):geoposition).
