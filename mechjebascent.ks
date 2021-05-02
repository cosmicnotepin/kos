run once other.

function clamp {
    parameter val.
    parameter lower.
    parameter upper.
    return min(max(val,lower),upper).
}

function flightPathAngle {
    parameter turnStart.
    parameter turnShapeExponent is 0.5.
    parameter turnEnd is 119000.
    parameter turnEndAngle is 0.
    parameter altitudeASL is altitude.
    parameter surfaceVelVec is ship:velocity:surface.
    return clamp(90 - (((altitudeASL - turnStart) / (turnEnd - turnStart))^turnShapeExponent) * (90 - turnEndAngle), 0.01, 89.99).
}

function driveAscent {
    parameter actualTurnStart.
    parameter tarApoapsis.
    local correctiveSteeringGain to 0.6.
    lock actualFlightPathAngle to ship:facing:pitch.
    lock desiredFlightPathAngle to flightPathAngle(actualTurnStart).
    local vd to vecdraw({return ship:position.}, {return heading(90, desiredFlightPathAngle):forevector * 20.}, red).
    set vd:show to true.
    local vd2 to vecdraw({return ship:position.}, {return velocity:surface:normalized * 30.}, white).
    set vd2:show to true.
    local vd3 to vecdraw({return ship:position.}, {return ship:facing:forevector:normalized * 25.}, green).
    set vd3:show to true.
    //lock velError to 2 * sin((desiredFlightPathAngle - actualTurnStart)/2).
    //lock difficulty to clamp(ship:velocity:surface:mag * 0.02 / maxthrust, 0.1, 1.0).
    //lock steerOffset to correctiveSteeringGain * difficulty * velError.
    //lock steerAngle to clamp(arcsin(steerOffset), -30, 30).
    //lock desPitch to clamp(desiredFlightPathAngle + steerAngle, -90, 90).
    //lock steering to unrotate(heading(22, desPitch):forevector).
    lock steering to unrotate(heading(90, desiredFlightPathAngle):forevector).
    wait until apoapsis > tarApoapsis.
    lock throttle to 0.
    return.
}


RCS off.
SAS off.
lock steering to up.
lock throttle to 1.
stage.
wait 5.
stage.
wait until ship:velocity:surface:mag > 100.
driveAscent(altitude, 350000).
print "so?".


