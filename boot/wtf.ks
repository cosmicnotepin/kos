wait 0.1.
core:part:getmodule("kosprocessor"):doevent("open terminal").
//run once fun.
clearscreen.
//go().
print "waiting for message".
when not ship:messages:empty then {
      set received to ship:messages:pop.
      print "sent by " + received:sender:name + " at " + received:sentat.
      print received:content.
      rcs off.
      sas off.
      lock steering to received:sender:position.
      print "looking at you!".
}
wait until 1<0.
