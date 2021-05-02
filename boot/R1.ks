set config:ipu to 2000.
wait 0.1.
core:part:getmodule("kosprocessor"):doevent("open terminal").
clearscreen.
print "R1".
print "3".
wait 1.
print "2".
set ship:control:pilotmainthrottle to 1.
wait 1.
print "1".
wait 1.
stage.
//print "waiting for tinyTim1 burnout".
//wait 1.1.
//wait until stage:ready.
//print "staging tinyTim1".
//stage.  
//print "waiting for 0.1s before tinyTim2 burnout".
//wait 1.
//print "firing aerobee".
//stage.
//print "wait for tinyTim 2 Burnout".
//wait 0.1.
//wait until stage:ready.
//print "staging tinyTim2".
//stage.  
wait until alt:radar > 140000.
print "staging aerobee stage".
stage.
wait until alt:radar < 10000.
print "deploying parachute".
stage.
wait until alt:radar < 10.
kuniverse:timewarp:cancelwarp.
wait until false.
print "done.".

