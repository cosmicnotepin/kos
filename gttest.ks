run once other.

//local radii to readjson("r.json").
//local angles to readjson("a.json").
lock steering to up.
lock throttle to 1.
stage.
wait 6.
stage.
local firstStageStartTime to time:seconds.

local kick to heading(90, 90-3).
wait until velocity:surface:mag > 100.
lock steering to unrotate(kick:forevector).
wait until vang(ship:facing:forevector, kick:forevector) < 0.5.
wait until vang(ship:facing:forevector, velocity:surface) < 1.
local startTime to time:seconds.
print "mu: " + body:mu.
print "init vel: " + velocity:surface:mag.
print "init r: " + (body:radius + altitude).
print "init angle" + vang(ship:facing:forevector, vxcl(ship:up:forevector, ship:facing:forevector)).
print "init mass: " + ship:mass.
print "stage time used: " + (time:seconds - firstStageStartTime).
list engines in e.
print "mass flow: " + (e[0]:consumedresources:values[0]:massflow + e[0]:consumedresources:values[1]:massflow).
print "thrust: " + maxthrust.
lock steering to velocity:surface.
//unlock steering.
//until time:seconds - startTime > 208 {
//    local angle to 0.
//    for i in range(radii:length) {
//        if (radii[i] > altitude) {
//            set angle to angles[i].
//            break.
//        }
//    }
//    set steering to unrotate(heading(90, angle):forevector).
//    wait 0.  
//}
//lock throttle to 0.
wait until maxthrust = 0.
print "burnTime: " + (time:seconds - startTime).
print "apoapsis: " + (apoapsis + body:radius).
print "periapsis: " + (periapsis + body:radius).
//local angle to 0.
//local vd to vecdraw({return ship:position.}, {return heading(90,angle):forevector:normalized * 20.}).
//set vd:show to true.
//local vd2 to vecdraw({return ship:position.}, {return velocity:surface:normalized * 30.}).
//set vd2:show to true.
//until eta:apoapsis < 5{
//    for i in range(radii:length) {
//        if (radii[i] > altitude) {
//            set angle to angles[i].
//            break.
//        }
//    }
//    //set steering to unrotate(heading(90, angle):forevector).
//    wait 0.  
//}
////wait until periapsis > 20000.

