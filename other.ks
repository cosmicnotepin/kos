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
    local tarSpeedPer to sqrt(y*(2/curRadiusApo - 1/curRadiusApo)).
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


//local vd to vecdraw({return ship:position.}, {return steering:forevector*20.}).
//set vd:show to true.
