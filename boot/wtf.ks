run once other.

wait 0.1.
core:part:getmodule("kosprocessor"):doevent("open terminal").
clearscreen.
print "waiting for message".
when not ship:messages:empty then {
      set received to ship:messages:pop.
      print "sent by " + received:sender:name + " at " + received:sentat.
      print "message: " + received:content.
      rcs off.
      sas off.
      lock steering to unrotate(received:sender:position).
      print "looking at you!".
}
wait until 1<0.
