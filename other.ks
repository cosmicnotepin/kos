function safely_deploy_chutes {
    when (not chutessafe) then {
        chutessafe on.
        return (not chutes).
    }
}

function warp_until {
    parameter condition.
    print "warp_until()".
    set tw to kuniverse:timewarp.
    set tw:mode to "RAILS".
    set w to 0.
    until not w = tw:warp {
        set w to w+1.
        set tw:warp to w.
    }
    if tw:warp = 0 {
        set tw:mode to "PHYSICS".
        set w to 0.
        until not w = tw:warp {
            set w to w+1.
            set tw:warp to w.
        }
    }
    wait until condition().
    set warp to 0.
    print "warp_until() done.".
}

function visViva {
    parameter burnRadius.
    parameter targetSma.
    local y to obt:body:mu.
    local r to burnRadius.
    local a to obt:semimajoraxis.
    local va to sqrt(y*(2/r - 1/a)).
    local vf to sqrt(y*(2/r - 1/targetSma)).
    return vf - va.
}

Function nodeFromVector {
  Parameter vec.
  Parameter nodeTime is time:seconds.
  Parameter localBody is ship:body.

  local vecNodePrograde is velocityat(ship,nodeTime):orbit.
  local vecNodeNormal is vcrs(vecNodePrograde,positionat(ship,nodeTime) - localBody:position).
  local vecNodeRadial is vcrs(vecNodeNormal,vecNodePrograde).

  local nodePrograde is vdot(vec,vecNodePrograde:normalized).
  local nodeNormal is vdot(vec,vecNodeNormal:normalized).
  local nodeRadial is vdot(vec,vecNodeRadial:normalized).

  return node(nodeTime,nodeRadial,nodeNormal,nodePrograde).
}

function gh {
    return constant:G *((ship:body:mass)/((ship:altitude + body:radius)^2)).
}

function fgh {
    return ship:mass*gh().
}

// direction looking at vec, not changing current "up"
function unrotate {
    parameter vec.
    return lookdirup(vec, ship:facing:topvector).
}

//to be used before capture burn
function tunePeriapsis {
    parameter targetOrbitHeight.
    print "tuning periapsis to: " + targetOrbitHeight.
    local lock normalUpVec to vcrs(ship:velocity:orbit, -body:position).
    local lock radialInVec to vcrs(ship:velocity:orbit, normalUpVec).
    if obt:periapsis < targetOrbitHeight - 1000 {
        lock steering to unrotate(-radialInVec).  
        wait until vang(-radialInVec, ship:facing:vector) < 0.25.
    }
    if obt:periapsis > targetOrbitHeight + 1000 {
        lock steering to unrotate(radialInVec).  
        wait until vang(radialInVec, ship:facing:vector) < 0.25.
    }
    //local maxAccel to ship:availableThrust/ship:mass.
    lock throttle to max(1, abs(obt:periapsis - targetOrbitHeight)/1000).
    wait until abs(obt:periapsis - targetOrbitHeight) < 500.
    lock throttle to 0.
    print "periapsis error: " + (obt:periapsis - targetOrbitHeight).
}

function circAtPeriapsis {
    print "circAtPeriapsis()".
    local y to obt:body:mu.
    local curSpeedPer to velocityat(ship, time:seconds + eta:periapsis):orbit:mag.
    local curRadiusPer to obt:periapsis + body:radius.
    local tarSpeedPer to sqrt(y*(2/curRadiusPer - 1/curRadiusPer)).
    local nd is Node(time:seconds + eta:periapsis, 0, 0, tarSpeedPer - curSpeedPer ).
    execNd(nd).
}

//untested
function circAtApoapsis {
    print "circAtApoapsis()".
    local y to obt:body:mu.
    local curSpeedApo to velocityat(ship, time:seconds + eta:apoapsis):orbit:mag.
    local curRadiusApo to obt:apoapsis + body:radius.
    local tarSpeedApo to sqrt(y*(2/curRadiusApo - 1/curRadiusApo)).
    local nd is Node(time:seconds + eta:apoapsis, 0, 0, tarSpeedApo - curSpeedApo ).
    execNd(nd).
}

function matchSMA {
    parameter tar.
    print "matchSMA()".
    local nodeTime to time:seconds + eta:apoapsis.
    local radiusAtNode to obt:apoapsis + body:radius.
    if tar:obt:semimajoraxis < ship:obt:semimajoraxis {
        set nodeTime to time:seconds + eta:periapsis.
        set radiusAtNode to obt:periapsis + body:radius.
    }
    local dv to visViva(radiusAtNode, tar:obt:semimajoraxis).
    local nd is Node(nodeTime, 0, 0, dv).
    execNd(nd).
}

function askForTarget {
    print "kindly set target".
    wait until hastarget.
}

function deorbit {
    parameter periapsis is 20000.
    parameter now is true.
    local nodeTime to time:seconds + 15.
    local dv to visViva(ship:altitude + body:radius, (ship:altitude + 2*body:radius + periapsis)/2).
    if now = false {
        set nodeTime to time:seconds + eta:apoapsis.
        set dv to visViva(body:radius + obt:apoapsis, (obt:apoapsis + 2*body:radius + periapsis)/2).
    }

    set nd to node( nodeTime, 0, 0, dv ).
    execNd(nd).
}

function land {
    //tries to stage the deorbit engine and a heatshield
    set warpmode to "rails".
    set warp to 4.
    wait until altitude < 70000.
    set warpmode to "physics".
    set warp to 4.
    wait until kuniverse:timewarp:issettled.

    lock steering to unrotate(srfretrograde:forevector).
    wait 2.
    stage.
    wait 2.
    stage.
    when (not chutessafe) then {
        chutessafe on.
        return (not chutes).
    }
    wait until chutes.
    local randomChute to ship:modulesnamed("ModuleParachute")[0].
    wait until alt:radar < randomChute:getfield("altitude").
    wait 2.
    kuniverse:timewarp:cancelwarp.
    wait 2.
    for dcm in ship:modulesnamed("ModuleDecouple") {
        for ev in dcm:alleventnames {
            if ev = "jettison heat shield" {
                dcm:doevent("jettison heat shield").
            }
        }
    }
    wait 2.
    legs on.
    set warpmode to "physics".
    set warp to 4.
    wait until alt:radar < 15.
    kuniverse:timewarp:cancelwarp.
    wait until status = "splashed" or status = "landed".
    print status.
}

function setCapsuleFree {
    //tries to stage the deorbit engine and a heatshield
    set warpmode to "rails".
    set warp to 4.
    wait until altitude < 70000.
    set warpmode to "physics".
    set warp to 4.

    lock steering to unrotate(srfretrograde).
    chutes on.
    wait 1.
    stage.
    wait until alt:radar < 15.
    kuniverse:timewarp:cancelwarp.
    wait until status = "splashed" or status = "landed".
    print status.
}
