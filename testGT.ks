run once other.
run once warp.

local radii to readjson("r.json").
local angles to readjson("a.json").

lock steering to up.
lock throttle to 1.
stage.
wait 6.
stage.
local firstStageStartTime to time:seconds.

wait until velocity:surface:mag > 100.
print "mu: " + body:mu.
print "init vel: " + velocity:surface:mag.
print "init r: " + (body:radius + altitude).
print "init angle" + vang(ship:facing:forevector, vxcl(ship:up:forevector, ship:facing:forevector)).
print "init mass: " + ship:mass.
print "stage time used: " + (time:seconds - firstStageStartTime).
list engines in e.
print "mass flow: " + (e[0]:consumedresources:values[0]:massflow + e[0]:consumedresources:values[1]:massflow).
print "thrust: " + maxthrust.
unlock steering.
local angle to 0.
local vd to vecdraw({return ship:position.}, {return heading(90, angle):forevector * 20.}, red).
set vd:show to true.
local vd2 to vecdraw({return ship:position.}, {return velocity:surface:normalized * 30.}, white).
set vd2:show to true.
local vd3 to vecdraw({return ship:position.}, {return ship:facing:forevector:normalized * 25.}, green).
set vd3:show to true.
until maxthrust = 0 {
    for i in range(radii:length) {
        if (radii[i] > altitude) {
            set angle to angles[i].
            break.
        }
    }
    set steering to unrotate(heading(90, angle):forevector).
    wait 0.  
}
wait until maxthrust = 0.
set warpmode to "physics".
set warp to 4.
wait until altitude > 140000.
kuniverse:timewarp:cancelwarp.
wait until kuniverse:timewarp:issettled.
stage.
wait 5.
stage.
wait 5.

warpWait(time:seconds + eta:apoapsis - 90 - 30).
RCS on.
lock steering to prograde.

wait until eta:apoapsis < (90 - 1.2).
stage.
wait 1.2.
stage.
wait until maxthrust = 0.

print "apoapsis: " + (apoapsis + body:radius).
print "periapsis: " + (periapsis + body:radius).

