run once execNd.
run once other.

function launchToCirc {
    parameter height is 85000.
    parameter stageBeforeCircBurn is false.
    parameter dir is 90. //direction to launch, 0 for north, 90 for std-east
    wait 1.
    lock throttle to 1.
    stage.
    
    when maxthrust = 0 then {
        stage.
        when maxthrust = 0 then {
            wait 1.
            stage.
            when maxthrust = 0 then {
                for f in ship:modulesnamed("moduleproceduralfairing") { 
                    if f:hasevent("deploy") {
                        f:doevent("deploy"). 
                    }
                }
                stage.
            }
        }
    }
    
    set mysteer to heading(dir,90).
    lock steering to mysteer.
    
    until apoapsis > height {
      set vel to velocity:surface:mag.
      if vel < 1350 {
        set pitch to 90 - vel/15.
        set mysteer to heading(dir, pitch).
      } else if vel >= 1350 {
        set mysteer to heading(dir,0).
      }
    }
    
    lock throttle to 0.
    
    set warpmode to "physics".
    set warp to 4.
    wait until altitude > 70000.
    set tw to kuniverse:timewarp.
    tw:cancelwarp.
    wait 1.
    for f in ship:modulesnamed("moduleproceduralfairing") { 
        if f:hasevent("deploy") {
            f:doevent("deploy"). 
        }
    }
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

//weak engine -> very uneven orbit
function launchToCircVac {
    parameter height is 20000.
    parameter dir is 90.
    local stagingTriggerActive is True.

    when stagingTriggerActive and maxthrust = 0 then {
        stage.
        preserve.
    }
    set mysteer to heading(dir,90).
    lock steering to mysteer.
    lock throttle to 1.
    wait until alt:radar > 100.
    set mysteer to heading(dir,45).
    wait until apoapsis > height.
    lock throttle to 0.
    set stagingTriggerActive to False.
    set nd to node( time:seconds+eta:apoapsis, 0, 0, visViva(obt:apoapsis + obt:body:radius, obt:apoapsis + obt:body:radius)).
    execNd(nd).
}

