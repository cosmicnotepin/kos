//doScience(true, list("science.module")).
function doScience {
    parameter transmit is false.
    parameter blacklist is list().

    if transmit {
        print "transmitting science".
    } else {
        print "collecting science".
    }

    bays on.
    wait 2.
    set experimentTypes to list("sensorThermometer", "sensorBarometer", "probeCoreOcto.v2", "science.module", "GooExperiment", "sensorAtmosphere", "sensorGravimeter", "sensorAccelerometer", "landerCabinSmall").
    for type in experimentTypes {
        print type.
        if blacklist:contains(type) {
            print "here".
            break.
        }
        for part in ship:partsnamed(type) {
            set sm to part:getmodule("ModuleScienceExperiment").
            if sm:deployed or sm:inoperable {
                continue.
            }
            sm:deploy.
            local ct to time:seconds.
            wait until sm:hasdata or time:seconds > ct + 5.
            if transmit and sm:hasdata {
                sm:transmit.
            }
            break.
        } 
    }

    if not transmit {
        for sc in ship:modulesnamed("ModuleScienceContainer") {
            sc:doaction("collect all", true).
        }
    }
    bays off.
    wait 2.
    print "experiments done".
}.

function burnDuration {
    parameter dv.
}

function stageDv {
    parameter stageNo.
    local g0 to 9.80665.

    list engines in elist.
    local se to list().
    for e in elist {
        if e:stage = stageNo {
            se:add(e).
        }
    }

    list parts in plist.
    local stageParts to list().
    local stageWetMass to 0.
    local fuel to 0.
    for p in plist {
        if p:separatedin <= stageNo - 1 {
            set stageWetMass to stageWetMass + p:wetmass.
        }
        if p:separatedin = stageNo - 1 {
            stageParts:add(p).
            set fuel to fuel + p:wetmass - p:drymass.
        }
    }
    local stageDryMass to stageWetMass - fuel.
    print "Number: " + stageNo.
    print "wetMass: " + stageWetMass.
    print "dryMass: " + stageDrymass.
    print "fuelu: " + fuel.
    local ve to se[0]:visp*g0.
    print "ve: " + ve.
    local F to se[0]:possiblethrustat(0.0).
    print "F: " + F.
    local q to F/ve.
    print "q: " + q.
    local dv to ve*ln(stageWetMass/stageDryMass).
    print "dv: " + dv.
    print "t: " + ((stageWetMass - (stageWetMass/(constant:e^(dv/ve))))/q).
}

function exNexNd {
    print "executing Node".
    set nd to nextnode.
    set max_acc to maxthrust/ship:mass.
    set burn_duration to nd:deltav:mag/max_acc.
    set tw to kuniverse:timewarp.
    set warpmode to "rails".
    tw:warpto(time:seconds + nd:eta - (burn_duration/2 + 15)).
    wait until nd:eta <= (burn_duration/2 + 10).
    set np to nd:deltav.
    lock steering to nd:deltav.
    
    wait until vang(np, ship:facing:vector) < 0.25.
    
    wait until nd:eta <= (burn_duration/2).
    set tset to 0.
    lock throttle to tset.
    set done to False.
    set dv0 to nd:deltav.
    until nd:deltav:mag < 0.1
    {
        set max_acc to maxthrust/ship:mass.
        set tset to min(nd:deltav:mag/max_acc, 1).
    }
    print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
    lock throttle to 0.
    unlock steering.
    unlock throttle.
    wait 1.
    remove nd.
    set ship:control:pilotmainthrottle to 0.
}

function dvCirc {
    local y to obt:body:mu.
    local r to obt:apoapsis + obt:body:radius.
    local a to obt:semimajoraxis.
    local va to sqrt(y*(2/r - 1/a)).
    local vf to sqrt(y/r).
    return vf - va.
}

function logShip {
    FOR P IN SHIP:PARTS {
        LOG ("modules for part named " + P:name) TO MODLIST.
        LOG P:MODULES TO MODLIST.
    }.
}

function launchToCirc {
    parameter sma is 85000.
    wait 1.
    clearscreen.
    
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
    panels on.
    for f in ship:partsTagged("mainComm") { f:getModule("ModuleDeployableAntenna"):doaction("extend antenna", true). }

    set nd to node( time:seconds+eta:apoapsis, 0, 0, dvCirc() ).
    add nd.
    exNexNd().
    remove nd.
    
    set ship:control:pilotmainthrottle to 0.
}

function deorbit {
    parameter periapse is 30000.
    set y to obt:body:mu.
    set r to altitude + obt:body:radius.
    set a to (r + periapse + obt:body:radius)/2.
    set va to velocity:orbit:mag.
    set vf to sqrt(y*(2/r - 1/a)).
    set nd to node( time:seconds + 800, 0, 0, -(va - vf) ).
    add nd.
    exNexNd().
    remove nd.
}

function land {
    set warpmode to "rails".
    set warp to 4.
    wait until altitude < 70000.
    set warpmode to "physics".
    set warp to 4.

    lock steering to srfretrograde.
    stage.
    wait 2.
    when (not chutessafe) then {
        chutessafe on.
        return (not chutes).
    }
    wait until chutes.
    local randomChute to ship:modulesnamed("ModuleParachute")[0].
    wait until alt:radar < randomChute:getfield("altitude").
    wait 2.
    kuniverse:timewarp:cancelwarp.
    wait 2.
    stage.
    wait 2.
    legs on.
    wait until status = "splashed" or status = "landed".
    print status.
}

function goSomeWhereOnKerbin {
    launchToCirc().
    deorbit().
    land().
    doScience().
    print "waiting for AG1".
    set current to AG1.
    wait until AG1 <> current.
    print "welcome back".
}

function dvKSOTrans {
    local y to obt:body:mu.
    local a to obt:semimajoraxis. // == radius because i assume circular starting orbit
    local as to 346333000. //sma synchronous
    local at to (a + as)/2. //sma transfer
    local va to sqrt(y/a). //velocity of starting orbit
    local vf to sqrt(y*(2/a - 1/at)). //velocity of transfer orbit at periapse
    return vf - va.
}

function dvKSOIns {
    local y to obt:body:mu.
    local as to 346333000. //sma synchronous
    local at to (a + as)/2. //sma transfer
    local va to sqrt(y*(2/as - 1/at)). //velocity of transfer orbit at apoapse
    local vf to sqrt(y/as). // velocity of KSO
    return vf - va.
}

function KSOat {
    parameter longitude is 0.

}

function go {
    stageDv(0).
    stageDv(1).
    stageDv(2).
    //logShip().
    //launchToCirc().
    //if status = "prelaunch" {
    //    goSomeWhereOnKerbin().
    //    return.
    //}
    //print "not sure what you want me to do".
}

