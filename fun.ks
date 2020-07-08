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

function burnTime {
    parameter burn.
    local g0 to 9.80665.
    local stagecount to stage:number.
    if status = "prelaunch" {
        set stagecount to stagecount - 1.
    }

    local engines to list().
    local mass to list().
    local fuel to list(). 
    local drymass to list().
    local ve to list().
    local F to list().
    local q to list().
    local dv to list().
    local t to list().
    for s in range(0, stagecount + 1) {
        engines:add(list()).
        mass:add(0).
        fuel:add(0). 
        drymass:add(0).
        ve:add(0).
        F:add(0).
        q:add(0).
        dv:add(0).
        t:add(0).
    }

    list parts in plist.
    for p in plist {
        for s in range(0, stagecount + 1){
            if p:separatedin <= s - 1 {
                set mass[s] to mass[s] + p:mass.
            }
            if p:separatedin = s - 1 {
                set fuel[s] to fuel[s] + p:mass - p:drymass.
            }
        }
    }

    for s in range(0, stagecount + 1) {
        list engines in elist.
        for e in elist {
            if e:stage = s {
                engines[s]:add(e).
            }
        }
        //TODO if engines[s]:length > 0
        // Ion engine circdv??

        set dryMass[s] to mass[s] - fuel[s].
        set ve[s] to engines[s][0]:visp*g0.
        set F[s] to engines[s][0]:possiblethrustat(0.0).
        set q[s] to F[s]/ve[s].
        set dv[s] to ve[s]*ln(mass[s]/dryMass[s]).
        set t[s] to ((mass[s] - (mass[s]/(constant:e^(dv[s]/ve[s]))))/q[s]).
        print "Number: " + s.
        print "mass: " + mass[s].
        print "dryMass: " + drymass[s].
        print "fuel: " + fuel[s].
        print "ve: " + ve[s].
        print "F: " + F[s].
        print "q: " + q[s].
        print "dv: " + dv[s].
        print "t: " + t[s].
    }

    local i to 0.
    local tBurn to 0.
    until burn - dv[i] < 0 {
        set burn to burn - dv[i].
        set tBurn to tBurn + t[s].
        set i to i + 1.
    }
    set tBurn to tBurn + ((mass[i] - (mass[i]/(constant:e^(burn/ve[i]))))/q[i]).
    print "calculatedBurnTime: " + tBurn.
    return tBurn.
}

function exNexNd {
    print "executing Node".
    set nd to nextnode.
    set max_acc to maxthrust/ship:mass.
    set burn_duration to burnTime(nd:deltav:mag).
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
    parameter stageBeforeCircBurn is false.
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
    if stageBeforeCircBurn {
        stage.
        wait 1.
    }
    panels on.
    for f in ship:partsTagged("mainComm") { f:getModule("ModuleDeployableAntenna"):doaction("extend antenna", true). }
    wait 1.

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
    local as to 3463330. //sma synchronous
    local at to (a + as)/2. //sma transfer
    local va to sqrt(y/a). //velocity of starting orbit
    local vf to sqrt(y*(2/a - 1/at)). //velocity of transfer orbit at periapse
    return vf - va.
}

function dvKSOIns {
    local y to obt:body:mu.
    local a to obt:semimajoraxis. // == radius because i assume circular starting orbit
    local as to 3463330. //sma synchronous
    local at to (a + as)/2. //sma transfer
    local va to sqrt(y*(2/as - 1/at)). //velocity of transfer orbit at apoapse
    local vf to sqrt(y/as). // velocity of KSO
    return vf - va.
}

function KSOat {
    parameter lngt is 0.
    print lngt.
    local wSS to 360/obt:body:rotationperiod.
    local a to obt:semimajoraxis.
    local as to 3463330. //sma synchronous
    local at to (as + a)/2. //sma transfer
    local pi to constant:pi.
    local y to obt:body:mu.
    local p to sqrt((4*pi^2*a^3)/y).
    local w to 360/p.
    local lng to geoposition:lng.
    local pt to sqrt((4*pi^2*at^3)/y).
    local ps to sqrt((4*pi^2*as^3)/y).
    //print ps.
    //print obt:body:rotationperiod.
    local alpha to 180 - (wSS*pt)/2.
    local t to (lngt - lng - alpha)/(w - wSS).
    print t.
    print alpha.
    if t < 0 {
        set t to (lngt - lng - alpha + 360 )/(w - wSS).
    }
    set nd to node( time:seconds + t, 0, 0, dvKSOTrans() ).
    add nd.
    exNexNd().
}

function go {
    KSOat(-74).
    //print burnTime(1000).
    //stageDv(0).
    //logShip().
    //launchToCirc(85000, true).
    //if status = "prelaunch" {
    //    goSomeWhereOnKerbin().
    //    return.
    //}
    //print "not sure what you want me to do".
}

KSOat(-74).

