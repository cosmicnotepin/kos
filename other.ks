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

//local vd to vecdraw({return ship:position.}, {return steering:forevector*20.}).
//set vd:show to true.
