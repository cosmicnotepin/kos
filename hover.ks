run once science.
run once other.

set config:ipu to 2000.

function groundNormal {
    parameter geoPos.

    local northVec to ship:north:forevector:normalized.
    local eastVec to vcrs(north:forevector, body:position):normalized.  
    local center is geoPos:altitudePosition(geoPos:terrainHeight).
    local top to body:geopositionOf(center + 5 * northVec).
    local right to body:geopositionOf(center - 5 * ( - sin(30) * northVec - cos(30) * eastVec)).
    local left to body:geopositionOf(center - 5 * ( - sin(30) * northVec + cos(30) * eastVec)).
    local topVec to top:altitudeposition(top:terrainheight).
    local rightVec to right:altitudeposition(right:terrainheight).
    local leftVec to left:altitudeposition(left:terrainheight).
    //local shower to vecdraw({return geoPos:altitudeposition(geoPos:terrainheight).}, {return 30 * vcrs(topVec - rightVec, topVec - leftVec):normalized.}, red).
    //set shower:show to true.
    return vcrs(topVec - rightVec, topVec - leftVec):normalized.
}

//searches in a grid spiral about the supplied geopos
//for a spot with less than maxGroundAngle slope
//returns the first, not the best spot
function findLandingSpotAround {
    parameter geoPos.
    parameter maxGroundAngle.
    local gridPointDistance to 100.
    local maxPointsToCheck to 10000.
    local center to geoPos:altitudeposition(geoPos:terrainheight).
    local northVec to ship:north:forevector:normalized * gridPointDistance.
    local eastVec to vcrs(north:forevector, body:position):normalized * gridPointDistance.  
    local dx to 0.
    local dy to -1.
    local x to 0.
    local y to 0.
    local bestGeoPos to geoPos.
    local bestAngle to 90.
    for i in range(0, 10000) {
        local geoPosToCheck to body:geopositionof(-x * eastVec + y * northVec).
        local geoPosToCheckPos to geoPosToCheck:altitudeposition(geoPosToCheck:terrainheight).
        local toCheckAngle to vang(groundNormal(geoPosToCheck), geoPosToCheckPos - body:position).
        if toCheckAngle < bestAngle {
            set bestGeoPos to geoPosToCheck.
        }
        if toCheckAngle < maxGroundAngle {
            return geoPosToCheck.
        }
        //print "(" + x + "," + y + ")".
        if x = y or (x < 0 and -x = y) or (x > 0 and x = 1-y) {
            local dx_old to dx.
            set dx to -dy.
            set dy to dx_old.
        }
        set x to x + dx.
        set y to y + dy.
    }
    print "no such spot available returning best i found, good luck :(".
    return bestGeoPos.
}


function hover {
    parameter maxVertSpeed is 1.
    parameter maxHorizSpeed is 1.
    parameter path is list(list(ship:geoposition, alt:radar)).
    parameter maxGroundAngle is 5.
    clearscreen.

    local pathIndex is 0.
    local lock geoPos to path[pathIndex][0].
    local lock height to path[pathIndex][1]. //AGL

    local ewOffset is 0. //for diverting horizontally, keeping AGL
    local nsOffset is 0. //for diverting horizontally, keeping AGL
    local lock eastVec to vcrs(north:forevector, body:position):normalized.
    local lock northVec to ship:north:forevector:normalized.
    local lock posTar to geoPos:altitudeposition(geoPos:terrainheight + height).
    local lock geoPosOff to body:geopositionof(posTar + eastVec*ewOffset + northVec*nsOffset).
    local lock posTarOff to geoPosOff:altitudeposition(geoPosOff:terrainheight + height).
    local lock posError to posTarOff - ship:position.

    local velP to 0.2. //fine for mun
    if obt:body = minmus {
        set velP to 0.6.
    }

    local ewPosPid to pidloop(0.2, 0, 0.4, -maxHorizSpeed, maxHorizSpeed).
    set ewPosPid:setpoint to 0.

    local ewPid to pidloop(velP, 0, 0, -1, 1).
    set ewPid:setpoint to 0. //positive means go east

    local nsPosPid to pidloop(0.2, 0, 0.4, -maxHorizSpeed, maxHorizSpeed).
    set nsPosPid:setpoint to 0.

    local nsPid to pidloop(velP, 0, 0, -1, 1).
    set nsPid:setpoint to 0. //positive means go north

    local vertPosPid to pidloop(1, 0, 1, -maxVertSpeed, maxVertSpeed).
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
    local lock maxHorizThrustNow to (1 - min(1, (tset + fgh()/(ship:availablethrust + 0.0000001))^2))^(1/2).

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
    local steerVec to lookdirup(ship:up:forevector:normalized, ship:facing:topvector). //initialize to up, gets updated in loop
    local sv to vecdraw({return ship:position.}, {return steerVec:forevector*10.}, magenta).
    set sv:show to true.  




    when posError:mag < 1 then {
        if pathIndex < path:length - 1 {
            set pathIndex to pathIndex + 1.
            return True.
        } else if pathIndex = path:length -1 {
            local diverted to false.
            if (not diverted) and vang(groundNormal(path[pathIndex][0]), ship:up:forevector) > maxGroundAngle {
                print "emergency divert".
                local currentSpot to path[pathIndex][0].
                local newLandingSpot to findLandingSpotAround(currentSpot, maxGroundAngle).
                if newLandingSpot:terrainheight > currentSpot:terrainHeight {
                    path:add(list(currentSpot, newLandingSpot:terrainheight - currentSpot:terrainheight + 20)).
                    path:add(list(newLandingSpot, 20)).
                } else {
                    path:add(list(newLandingSpot, currentSpot:terrainheight - newLandingSpot:terrainheight + 20)).
                    path:add(list(newLandingSpot, 20)).
                }
                set nsPosPid:maxoutput to 20.
                set nsPosPid:minoutput to -20.
                set ewPosPid:maxoutput to 20.
                set ewPosPid:minoutput to -20.
                set pathIndex to pathIndex + 1.
                set vertPosPid:maxoutput to 10.
                set vertPosPid:minoutput to -10.
                set diverted to true.
                return True.  
            }
            //wait for stuff to settle at last waypoint before descending
            //print nsPosPid:output at (0,2).
            //print ewPosPid:output at (0,3).
            //print nsPid:output at (0,4).
            //print ewPid:output at (0,5).
            if ship:velocity:surface:mag < 1 and abs(nsPosPid:output) < 0.01 and abs(nsPid:output) < 0.01 and abs(ewPosPid:output) < 0.01 and abs(ewPid:output) < 0.01 {
                //land
                print "blah".
                set nsPosPid:maxoutput to 1.
                set nsPosPid:minoutput to -1.
                set ewPosPid:maxoutput to 1.
                set ewPosPid:minoutput to -1.
                set vertPosPid:maxoutput to 1.
                set vertPosPid:minoutput to -1.
                set height to -1.
                when status = "landed" or status = "splashed" then {
                    set stop to True.
                    return False.
                }
                return False.
            }
            return True.
        } 
    }
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

        set steerVec to unrotate(ship:up:forevector:normalized + eastVec*ewPidVal + northVec * nsPidVal).  
        set steering to steerVec.
        wait 0.
    }
    print "done with loop".
    print "locking steering to groundNormal and waiting 10 seconds for things to settle".
    lock steering to unrotate(groundNormal(ship:geoposition)).
    lock throttle to 0.
    wait 10.
    print "did my best, good luck staying upright".
    unlock steering.  
    set ship:control:pilotmainthrottle to 0.
}

//hover(5, 10, list(list(waypoint("m1"):geoposition, waypoint("m1"):agl), list(waypoint("m2"):geoposition, waypoint("m2"):agl), list(waypoint("m3"):geoposition, waypoint("m3"):agl))).
//hover(5, 10, list(list(waypoint("1"):geoposition, waypoint("1"):agl), list(waypoint("2"):geoposition, waypoint("2"):agl), list(waypoint("3"):geoposition, waypoint("3"):agl), list(waypoint("4"):geoposition, waypoint("4"):agl), list(waypoint("5"):geoposition, waypoint("5"):agl))).
//hover(5, 10, list(list(waypoint("4"):geoposition, waypoint("4"):agl), list(waypoint("5"):geoposition, waypoint("5"):agl))).
