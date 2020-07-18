run once inclination.
run once launch.
run once kso.
run once science.
run once execNd.
run once rendezvous.
run once other.

function logShip {
    FOR P IN SHIP:PARTS {
        LOG ("modules for part named " + P:name) TO MODLIST.
        LOG P:MODULES TO MODLIST.
    }.
}

function go {
    print "I HAVE CONTROL_".

    launchToCirc(85000, true).
    print "set target and trigger AG1".
    set current to AG1.
    wait until AG1 <> current.
    //matchInclination(target).
    //KSOat(120-14).
    //if status = "prelaunch" {
    //    goSomeWhereOnKerbin().
    //    return.
    //}
    print "MISSION".
    print "COMPL_".
}

//rendezvousSetup(target).
//matchInclination(target).
rendezvous(target).

