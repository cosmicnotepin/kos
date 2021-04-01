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

function munFlyBy {
    print "I HAVE CONTROL_".

    print "set target and trigger AG1".
    set current to AG1.
    wait until AG1 <> current.
    launchToCirc(85000, true).
    flyBy(target).

    print "MISSION".
    print "COMPL_".
}


function rendezvousFromLaunchpad {
    print "I HAVE CONTROL_".

    print "set target and trigger AG1".
    set current to AG1.
    wait until AG1 <> current.
    launchToCirc(80000, true).
    rendezvous(target).
    print "MISSION".
    print "COMPL_".
}

function toMunmus {
    print "set target moon, then AG1".
    local current to AG1.
    wait until AG1 <> current.
    launchToCirc().
    matchInclination(target).
    print "set node for encounter, then AG1".
    local current to AG1.
    wait until AG1 <> current.
    execNd().
    print "changing to target SOI".
    warpWait(time:seconds + obt:nextpatcheta + 60). //drop off 1 minute after transition
    circAtPeriapsis().  
    print "at munmus circ orbit".
}


function positionRelay {
    print "set target to match with offset 120 (we will lead target)".
    local current to AG1.
    wait until AG1 <> current.
    matchOrbitWithOffset(target, 120, 10). 
}


function go {
    //print "I HAVE CONTROL_".
    //wait 1.
    //launchToCirc(85000, true).
    //launchToCirc().
    //toMunmus().
    //positionRelay().
    //circAtPeriapsis().
    //matchApoapsis(target).
    //launchToCircVac(15000).//minmus
    //aeroBrakeReturn().
    //KSOat(240).
    //landImmediately().
    //hover(5, 10, list(list(waypoint("ms"):geoposition, waypoint("ms"):agl))).
    //hover(10, 20, list(list(waypoint("l1"):geoposition, waypoint("l1"):agl), list(waypoint("l2"):geoposition, waypoint("l2"):agl), list(waypoint("l3"):geoposition, waypoint("l3"):agl), list(waypoint("l4"):geoposition, waypoint("l4"):agl))).
    //print "MISSION".
    //print "COMPL_".
}

go().
