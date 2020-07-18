run once trueanomaly.
run once execNd.
run once other.
run once warp.

function matchApoapsis {
    Parameter tar.
  
    local perSEta is time:seconds + eta:periapsis.
    local perTEta is time:seconds + timeToTrueAnomaly(tar, 0).
  
    local vecS is positionat(ship, perSEta)-ship:body:position.
    //local vecd1 is vecdraw(ship:body:position, vec1 , red, "per1", 1.0, false, 0.2).
    //set vecd1:startupdater to {return ship:body:position.}.
  
    local vecT is positionat(target, perTEta)-ship:body:position.
    //local vecd2 is vecdraw(ship:body:position, vec2, red, "per2", 1.0, false, 0.2).
    //set vecd2:startupdater to {return body:position.}.
  
    local TrueAnomalyTargetPer is "x".
  
    if vdot(vcrs(vecs, vect), v(0,1,0)) > 0 {
        set trueAnomalyTargetPer to 360-vang(vecS,vecT).
        //HUDtext("POS", 30, 2, 30, white, true).
    } else {
        set trueAnomalyTargetPer to vang(vecS,vecT).
    }
  
    local timeTargetPeriapsis is timeToTrueAnomaly(ship, trueAnomalyTargetPer).
    local curRadTarPer is radiusAtTrueAnomaly(ship, trueAnomalyTargetPer).
    print "curRadTarPer: " + curRadTarPer .

    print "tar:orbit:apoapsis: " + tar:orbit:apoapsis.
    print "targetSMA: " + ((curRadTarPer + tar:orbit:apoapsis)/2 + body:radius).
    local dv is visViva(curRadTarPer, ((curRadTarPer + tar:orbit:apoapsis + body:radius)/2)).
    local nd is Node(time:seconds + timeTargetPeriapsis, 0, 0, dv).
    execNd(nd).
}

function warpToBetterAlignment {
    parameter tar.
    parameter maxWaitOrbits is 10.
    local theWait is 0.
    local theAngle is 180.
    from {local o is 0.} until o = maxWaitOrbits step {set o to o + 1.} do {
        local apoTime is  time:seconds + eta:apoapsis + o*obt:period.
        local vecS is positionat(ship, apoTime) - body:position.
        local vecT is positionat(tar, apoTime) - body:position.
        local vecSTCrs is vcrs(vecS, vecT).
        local vecSVCrs is vcrs(body:position, velocity:orbit).
        local cmp to 0.
        if obt:periapsis < tar:obt:periapsis {
            set cmp to vdot(vecSTCrs, vecSVCrs) < 0.
        } else {
            set cmp to vdot(vecSTCrs, vecSVCrs) > 0.
        }
        if vang(vecS,vecT) < theAngle and cmp {
            set theAngle to vang(vecS, vecT).
            set theWait to apoTime.
        }
    }
    warpWait(theWait - 600).
}

function rendezvousAtNextApoapsis {
    parameter tar.
    local p to timeToTrueAnomaly(tar,180).
    if p < 600 {
        set p to p + tar:obt:period.
    }
    local tarApoVec to positionat(tar, time:seconds + p) - body:position.
    local trueAnomTarApo to obt:trueanomaly + vang(tarApoVec, ship:position - body:position).
    local timeToTarApo to timeToTrueAnomaly(ship, trueAnomTarApo).
    set p to p - timeToTarApo.
    local y to body:mu.
    local pi to constant:pi.
    local sma to (((p^2)*y)/(4*(pi^2)))^(1/3).
    local radiusAtTarApo to radiusAtTrueAnomaly(ship, trueAnomTarApo).
    local dv to visViva(radiusAtTarApo, sma).
    execNd(node(time:seconds + timeToTarApo, 0, 0, dv+0.1)).
    local rendezvousApproachTime to eta:apoapsis.
    if eta:apoapsis < obt:period/2 {
        set rendezvousApproachTime to rendezvousApproachTime + obt:period.
    }
    local theWait to time:seconds + rendezvousApproachTime - 300.
    warpWait(theWait).
}

function matchVelocity {
    parameter tar.
    local vec is (tar:velocity:orbit - ship:velocity:orbit).
    local nd is nodeFromVector(vec).
    execNd(nd).  
}

function rendezvous {
    parameter tar.
    parameter maxWaitOrbits is 10.

    //matchInclination(tar).

    //matchApoapsis(tar).

    warpToBetterAlignment(tar, maxWaitOrbits).

    rendezvousAtNextApoapsis(tar).

    matchVelocity(tar).

}
