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
run once missions.

function saveMissionProgress {
    kuniverse:quicksaveto("cmp").
}

function logShip {
    FOR P IN SHIP:PARTS {
        LOG ("modules for part named " + P:name) TO MODLIST.
        LOG P:MODULES TO MODLIST.
    }.
}

function go {
    //groundNormal(ship:geoposition).
    //warpToBetterAlignment(target, 10, 0).
    //print vang(groundNormal(body:geopositionOf(ship:position + north:forevector * 10)), ship:up:forevector).
    //findLandingSpotAround(ship:geoposition, 5).
    //print "AG1 to go()".
    //local current to AG1.
    //wait until AG1 <> current.
    //print "I HAVE CONTROL_".
    //wait 1.
    //dockFromLaunchpad().
    //warpWait(time:seconds + eta:periapsis  - 
    //local ta to trueAnomalyAtRadius(ship, body:radius). 
    //print ta.
    //print timeToTrueAnomaly(ship, ta).

    //local lock blah to 1.
    //print blah.
    //if true {
    //    local lock blah to 2.
    //    print blah.
    //}
    //print blah.

    //print obt:period.
    //rescue().
    //rendezvousFromLaunchpad().
    //rendezvousAtNextApoapsis(target).
    //launchToCirc(85000, true).
    //launchToCirc(100000, true).
    //launchToCirc(90000).
    //launchToCircVac(15000).//minmus
    //circAtApoapsis().
    //dockToStationVac().
    //rendezvous(target, 10, "dock").
    //finalApproach(target, "dock").
    //print burnTime(50).
    //set tar to target.
    hover(20,20, list(list(ship:geoposition, waypoint("wp1"):agl), list(waypoint("wp1"):geoposition, waypoint("wp1"):agl + 10))).
    //until false {
    //    print ship:control:pilotpitch.
    //    wait 0.
    //}


    //set objective to "grapple".
    //warpToBetterAlignment(tar, 10).
    //                                           
    //rendezvousAtNextApoapsis(tar, 0, 0).
    //                                           
    //approachMainEngine(tar).  
    //                                           
    //finalApproach(tar, objective).  





    //deorbit(20000, true).
    //land().
    //positionRelay().
    //circAtPeriapsis().
    //KSOat(240).
    //hover(40, 1, list(list(ship:geoposition, 500), list(ship:geoposition, 20))).
    //hover(10, 20, list(list(waypoint("l1"):geoposition, waypoint("l1"):agl), list(waypoint("l2"):geoposition, waypoint("l2"):agl), list(waypoint("l3"):geoposition, waypoint("l3"):agl), list(waypoint("l4"):geoposition, waypoint("l4"):agl))).
    //print "MISSION".
    //print "COMPL_".
}

go().
