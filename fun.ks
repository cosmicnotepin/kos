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

    print "set target and trigger AG1".
    set current to AG1.
    wait until AG1 <> current.
    launchToCirc(85000, true).
    rendezvous(target).
    print "MISSION".
    print "COMPL_".
}
