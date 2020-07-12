run once inclination.
run once launch.
run once kso.
run once science.
run once execNd.

function logShip {
    FOR P IN SHIP:PARTS {
        LOG ("modules for part named " + P:name) TO MODLIST.
        LOG P:MODULES TO MODLIST.
    }.
}

function go {
    print "I HAVE CONTROL_".

    matchInclination(target).
    //launchToCirc(85000, true).
    //if status = "prelaunch" {
    //    goSomeWhereOnKerbin().
    //    return.
    //}
    print "MISSION".
    print "COMPL_".
}

go().


