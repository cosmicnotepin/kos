set config:ipu to 2000.

run once inclination.
run once launch.
run once kso.
run once science.
run once execNd.
run once rendezvous.
run once other.
run once kruscht.
run once warp.
run once hover.
run once land.
run once trueanomaly.


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

function lowOrbitScience {
    print "I HAVE CONTROL_".
    launchToCirc(85000, false, 90).
    doScience().
    deorbit().
    setCapsuleFree().
    print "MISSION".
    print "COMPL_".
}

function polarOrbitScience {
    print "I HAVE CONTROL_".
    launchToCirc(85000, false, 0).
    checkScience().
    local i to 0.
    until i > 183 {
        set i to i + 1.
        warpWait(time:seconds + 60).
        checkScience().
        print i at (0,20).
    }
    deorbit().
    land().
    print "MISSION".
    print "COMPL_".
}

function rendezvousFromLaunchpad {
    print "I HAVE CONTROL_".

    askForTarget().
    launchToCirc(80000).
    rendezvous(target, 10, "dock").
    print "MISSION".
    print "COMPL_".
}

function dockFromCirc {
    print "I HAVE CONTROL_".

    askForTarget().
    rendezvous(target, 10,  "dock").
    print "MISSION".
    print "COMPL_".
}

function toMunmus {
    parameter targetOrbitHeight is "x".
    print "1: mun".
    print "2: minmus".
    local defaultPeriapsis to "x".
    local c to terminal:input:getchar().
    if c = "1" {
        set target to mun.
        set defaultPeriapsis to 14000.
    }
    if c = "2" {
        set target to minmus.
        set defaultPeriapsis to 10000.
    }
    if targetOrbitHeight = "x" {
        set targetOrbitHeight to defaultPeriapsis.
    }
    set ship:control:pilotmainthrottle to 0.
    launchToCirc().
    matchInclination(target).
    print "set node for encounter, then AG1".
    local current to AG1.
    wait until AG1 <> current.
    execNd().
    print "changing to target SOI".
    warpWait(time:seconds + obt:nextpatcheta + 60). //drop off 1 minute after transition
    tunePeriapsis(targetOrbitHeight).
    //doScience().
    circAtPeriapsis().  
    print "at munmus circ orbit".
}


function positionRelay {
    print "this craft will lead target by 120 degrees".
    askForTarget().
    matchOrbitWithOffset(target, 120, 10). 
}

function rescue {
    askForTarget().
    launchToCirc(75000).
    rendezvous(target, 10, "approach").
    deorbit(20000).
    land().
}
