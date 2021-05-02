run once other.
run once warp.

local radii to readjson("r.json").
local angles to readjson("a.json").

local secondStageBurntime to 2*60 + 48.
local fuelStableTime to 15.
local turnTime to 30.
local headingIncl to 70.

lock steering to up.
lock throttle to 1.
stage.
wait 6.
stage.
local firstStageStartTime to time:seconds.

set warpmode to "physics".
set warp to 4.
unlock steering.
local angle to 0.
local vd to vecdraw({return ship:position.}, {return heading(headingIncl, angle):forevector * 20.}, red).
set vd:show to true.
local vd2 to vecdraw({return ship:position.}, {return velocity:surface:normalized * 30.}, white).
set vd2:show to true.
local vd3 to vecdraw({return ship:position.}, {return ship:facing:forevector:normalized * 25.}, green).
set vd3:show to true.
when maxthrust = 0 then {
    stage.
    wait until stage:ready.
    wait 1.
    stage.
    wait until stage:ready.
    stage.
    wait until stage:ready.
    stage.
}
until false {
    for i in range(radii:length) {
        if (radii[i] > altitude) {
            set angle to angles[i].
            break.
        }
    }
    set steering to unrotate(heading(headingIncl, angle):forevector).
    wait 0.  
}
wait until ((altitude > 140000) or (eta:apoapsis < (secondStageBurntime/2 + fuelStableTime + turnTime + secondStageBurntime/10))).
kuniverse:timewarp:cancelwarp.
wait until kuniverse:timewarp:issettled.
stage.
wait 3.
stage.
wait 3.
stage.
wait 3.
print "free".

warpWait(time:seconds + (eta:apoapsis - (secondStageBurntime/2 + fuelStableTime + turnTime + secondStageBurntime/10))).
print "to prograde".
lock throttle to 0.
RCS on.
lock steering to unrotate(vxcl(ship:up:forevector, prograde:forevector)).

wait until eta:apoapsis < secondStageBurntime/2 + fuelStableTime + secondStageBurntime/10.
print "waiting for fuel stable with engine lit".
lock throttle to 1.
stage.
wait 1.
stage.
print "stage".
wait until maxthrust = 0.
wait until abs(apoapsis - periapsis) < 5000 or (apoapsis > 300000 and periapsis > 300000).
//RCS off.
list engines in es.
es[0]:shutdown().
lock throttle to 0.

print "apoapsis: " + (apoapsis + body:radius).
print "periapsis: " + (periapsis + body:radius).

