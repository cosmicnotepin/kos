set config:ipu to 2000.
wait 0.1.
core:part:getmodule("kosprocessor"):doevent("open terminal").
clearscreen.

if not (status = "prelaunch") {
    run once other.
    print "waiting for message".
    when not ship:messages:empty then {
          set received to ship:messages:pop.
          print "sent by " + received:sender:name + " at " + received:sentat.
          print "docking port received".
          local dpuid to received:content.
          local tdp to "x".
          for p in received:sender:parts {
              if p:uid = dpuid {
                  set tdp to p.
              }
          }
          list dockingports in dps.
          local selectedDP to "x".
          for dp in dps {
              if dp:state = "ready" and dp:nodetype = tdp:nodetype {
                  dp:controlfrom().
                  set selectedDP to dp.
                  set c to received:sender:connection.
                  if c:sendmessage(dp:uid) {
                        print "free dockingport uid sent".
                  }
                  break.
              }
          }

          rcs off.
          sas off.
          lock steering to unrotate(tdp:position - selectedDP:position).
          print "looking at you".
    }
    wait until false.
}
