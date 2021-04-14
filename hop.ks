run once other.
run once trueanomaly.
run once land.

//todo: overshoot by stopping dist horiz? or something
//stopping dist horiz, respecting angle at target ground intersect?
//respecting speed at target ground intersect
function hop {
    parameter  geoPos.
    panels off.
    radiators off.  
    //launch straight
    lock steering to unrotate(ship:up:forevector).
    lock throttle to 1.
    wait 2.
    //pi: estimate traveltime and calculate where target will be when we get there (planet rotation)
    lock steering to unrotate(ship:up:forevector:normalized + geoPos:altitudePosition(geoPos:terrainheight):normalized).
    local targetHeight to geoPos:terrainheight.
    wait until apoapsis > targetHeight. //otherwise the next line may fail (because there is no such true anomaly)
    local lock ta to trueAnomalyAtRadius(ship, body:radius + targetHeight).
    local lock tta to timeToTrueAnomaly(ship, ta).
    local lock tta2 to timeToTrueAnomaly(ship, 360 - ta).
    local lock impactPos to positionat(ship, time:seconds + tta). 
    local lock impactPos2 to positionat(ship, time:seconds + tta2). 
    //vecdraws fail when apopapsis low enough
    //local impactVD to vecdraw({return ship:position.}, {return impactPos.}, red).
    //set impactVD:show to true.
    //local impactVD2 to vecdraw({return ship:position.}, {return impactPos2.}, white).
    //set impactVD2:show to true.
    local lock impactError to (impactPos2 - geoPos:altitudeposition(targetHeight)):mag.

    local lastImpactError to impactError.
    local lastErrors to list(1000,1000,1000).
    local errorIndex to 0.
    until lastErrors[2] > lastErrors[1] and lastErrors[1] > lastErrors[0] {
        print impactError at (0, 20).
        lastErrors:add(impactError).
        lastErrors:remove(0).
        wait 0.
    }

    //overshoot a bit, so that we pass target roughly at a height of vertical stopping dist
    //overshoot is just "something that somehow grows when TWR falls"
    print "overshooting".
    local velocityAtImpact to velocityat(ship, time:seconds + tta2).
    print velocityAtImpact:surface:mag.
    local stoppingDist to stoppingDistance(velocityAtImpact:surface:mag).
    print stoppingDist.
    set targetHeight to geoPos:terrainheight + (stoppingDist/2).
    print "waiting".
    wait until apoapsis > targetHeight. //otherwise the next line may fail (because there is no such true anomaly)
    print "done waiting".
    local lastImpactError to impactError.
    local lastErrors to list(1000,1000,1000).
    local errorIndex to 0.
    until lastErrors[2] > lastErrors[1] and lastErrors[1] > lastErrors[0] {
        print impactError at (0, 20).
        lastErrors:add(impactError).
        lastErrors:remove(0).
        wait 0.
    }

    lock throttle to 0.
    suicideBurn().
    hover(1,1).
    panels on.
    radiators on.
}
