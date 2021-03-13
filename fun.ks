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
    warpWait(time:seconds + (60*60*4) + 60).
    deorbit().
    land().
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


function rendezvous {
    print "I HAVE CONTROL_".

    print "set target and trigger AG1".
    set current to AG1.
    wait until AG1 <> current.
    launchToCirc(85000, true).
    rendezvous(target).
    print "MISSION".
    print "COMPL_".
}

function go {
    //print "I HAVE CONTROL_".
    //wait 1.
    //munFlyBy().
    //hover().
    //launchToCirc().
    landImmediately().
    //testSuicideHover().
    ////deorbit().
    //land().
    //print "MISSION".
    //print "COMPL_".
}

go().
