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

function logShip {
    FOR P IN SHIP:PARTS {
        LOG ("modules for part named " + P:name) TO MODLIST.
        LOG P:MODULES TO MODLIST.
    }.
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
    rendezvous(target).
    print "MISSION".
    print "COMPL_".
}

function toMunmus {
    print "asking for a minmus or mun here:".
    askForTarget().
    launchToCirc().
    matchInclination(target).
    print "set node for encounter, then AG1".
    local current to AG1.
    wait until AG1 <> current.
    execNd().
    print "changing to target SOI".
    warpWait(time:seconds + obt:nextpatcheta + 60). //drop off 1 minute after transition
    doScience().
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
    rendezvous(target).
    deorbit(20000).
    land().
}

function dockFromLaunchpad {
    askForTarget().
    launchToCirc(75000).
    rendezvous(target, 10, "dock").
    deorbit(20000).
    land().
}

function go {
    //print "AG1 to go()".
    //local current to AG1.
    //wait until AG1 <> current.
    //print "I HAVE CONTROL_".
    //wait 1.
    //dockFromLaunchpad().
    //finalApproach(target, "dock").
    deorbit(20000).
    land().
    //send(target, "blah").
    //rescue().
    //rendezvousFromLaunchpad().
    //rendezvousAtNextApoapsis(target).
    //approachMainEngine(target).  
    //finalApproach(target).  
    //launchToCirc(85000, true).
    //launchToCirc(100000, true).
    //launchToCirc().
    //circAtApoapsis().
    //toMunmus().
    //print burnTime(875).
    //positionRelay().
    //circAtPeriapsis().
    //launchToCircVac(15000).//minmus
    //KSOat(240).
    //hover(40, 1, list(list(ship:geoposition, 500), list(ship:geoposition, 20))).
    //hover(10, 20, list(list(waypoint("l1"):geoposition, waypoint("l1"):agl), list(waypoint("l2"):geoposition, waypoint("l2"):agl), list(waypoint("l3"):geoposition, waypoint("l3"):agl), list(waypoint("l4"):geoposition, waypoint("l4"):agl))).
    //print "MISSION".
    //print "COMPL_".
}

go().
