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

function go {
    //print "I HAVE CONTROL_".
    //wait 1.
    //munFlyBy().
    //hover(10, 50, list(50,60,2)). // move south with 50m/s for 60s, then attempt to land again
    //hover(10, 50, list(50,60,0)). // move north with 50m/s for 60s, then attempt to land again
    //hover(1,-1).
    //launchToCirc(85000, true).
    //launchToCirc().
    //rendezvous(target).
    //launchToCircVac().//mun
    //launchToCircVac(15000).//minmus
    aeroBrakeReturn().
    //print burnTime(1000).
    //KSOat(240).
    //landImmediately().
    //hover(5, 10, list(list(waypoint("ms"):geoposition, waypoint("ms"):agl))).
    //testSuicideHover().
    //lowOrbitScience().
    //print "MISSION".
    //print "COMPL_".
}

go().
