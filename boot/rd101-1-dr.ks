run once other.
set config:ipu to 2000.
wait 0.1.
core:part:getmodule("kosprocessor"):doevent("open terminal").
clearscreen.
print "rd101-1-dr".
print "3".
wait 1.
print "2".
set ship:control:pilotmainthrottle to 1.
lock steering to unrotate(ship:up:forevector).
wait 1.
print "1".
wait 1.
stage.
print "waiting for engine spuleup".
wait 3.
stage.  
wait 7.

set mysteer to heading(90,90):forevector.
lock steering to unrotate(mysteer).
local lock vel to velocity:surface:mag.
wait until vel > 50.
print "pitching over".
set mysteer to heading(90, 70):forevector.
print "waiting for rocket to turn".
wait 10.
print "waiting for alignment".
wait until vang(ship:velocity:surface, ship:facing:forevector) < 2.
print "gravity turn".

lock mysteer to ship:velocity:surface. 
wait until maxthrust = 0.
print "spin".
stage.
wait 2.
print "sep to and ullage motors".
stage.
wait 1.
print "aerobee".
stage.
wait 0.2.
wait until stage:ready.
print "sep ullage".
stage.

until false {
}

//wait 5.
//set warpmode to "physics".
//set warp to 4.
////print "staging tinyTim1".
////stage.  
////print "waiting for 0.1s before tinyTim2 burnout".
////wait 1.
////print "firing aerobee".
////stage.
////print "wait for tinyTim 2 Burnout".
////wait 0.1.
////wait until stage:ready.
////print "staging tinyTim2".
////stage.  
//wait until alt:radar > 140000.
//kuniverse:timewarp:cancelwarp.
//wait until kuniverse:timewarp:issettled.
//print "staging aerobee stage".
//stage.
//wait 5.
//set warp to 1.
//set warpmode to "rails".
//set warp to 1.
//wait until alt:radar < 140000.
//set warpmode to "physics".
//set warp to 4.
//wait until alt:radar < 100000.
//kuniverse:timewarp:cancelwarp.
//wait until kuniverse:timewarp:issettled.
//local rc to ship:partsnamed("RC.stack")[0].
//local rcm to rc:getmodule("RealChuteModule").
//rcm:doaction("arm parachute", true).
//set warpmode to "physics".
//set warp to 4.
//wait until alt:radar < 20.
//kuniverse:timewarp:cancelwarp.
//print "done.".
