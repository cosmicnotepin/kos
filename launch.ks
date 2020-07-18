run once execNd.
run once other.

function launchToCirc {
    parameter sma is 85000.
    parameter stageBeforeCircBurn is false.
    wait 1.
    lock throttle to 1.
    stage.
    
    when maxthrust = 0 then {
      stage.
    }
    
    set mysteer to heading(90,90).
    lock steering to mysteer.
    
    until apoapsis > 85000 {
      set vel to velocity:surface:mag.
      if vel < 1350 {
        set pitch to 90 - vel/15.
        set mysteer to heading(90, pitch).
      } else if vel >= 1350 {
        set mysteer to heading(90,0).
      }
    }
    
    lock throttle to 0.
    
    set warpmode to "physics".
    set warp to 4.
    wait until altitude > 70000.
    set tw to kuniverse:timewarp.
    tw:cancelwarp.
    wait 1.
    for f in ship:modulesnamed("moduleproceduralfairing") { f:doevent("deploy"). }
    wait 1.
    if stageBeforeCircBurn {
        stage.
        wait 1.
    }
    panels on.
    for f in ship:partsTagged("mainComm") { f:getModule("ModuleDeployableAntenna"):doaction("extend antenna", true). }
    wait 1.

    unlock steering.
    unlock throttle.
    set nd to node( time:seconds+eta:apoapsis, 0, 0, visViva(obt:apoapsis + obt:body:radius, obt:apoapsis + obt:body:radius)).
    execNd(nd).
}
