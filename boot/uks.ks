set config:ipu to 2000.
wait 0.1.
core:part:getmodule("kosprocessor"):doevent("open terminal").
clearscreen.

if status = "prelaunch" {
    run once fun.
} else { 
    run once other.
    print "waiting for message".
    when not ship:messages:empty then {
          set received to ship:messages:pop.
          print "sent by " + received:sender:name + " at " + received:sentat.
          print "message: " + received:content.
          rcs off.
          sas off.
          //todo: ask user to set "control from here" on the desired docking port first
          lock steering to unrotate(received:sender:position).
          print "looking at you!".
    }
    wait until false.
}
