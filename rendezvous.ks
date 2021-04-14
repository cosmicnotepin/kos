run once trueanomaly.
run once execNd.
run once other.
run once warp.
run once inclination.

function matchApoapsis {
    Parameter tar.
    print "matchApoapsis()".
  
    local perSEta is time:seconds + eta:periapsis.
    local perTEta is time:seconds + timeToTrueAnomaly(tar, 0).
  
    local vecS is positionat(ship, perSEta)-ship:body:position.
    local vecT is positionat(target, perTEta)-ship:body:position.
    local TrueAnomalyTargetPer is "x".
  
    if obt:inclination < 90 {
        if vdot(vcrs(vecs, vect), v(0,1,0)) > 0 {
            set trueAnomalyTargetPer to 360-vang(vecS,vecT).
        } else {
            set trueAnomalyTargetPer to vang(vecS,vecT).
        }
    } else {
        if vdot(vcrs(vecs, vect), v(0,1,0)) > 0 {
            set trueAnomalyTargetPer to vang(vecS,vecT).
        } else {
            set trueAnomalyTargetPer to 360-vang(vecS,vecT).
        }
    }
  
    local timeTargetPeriapsis is timeToTrueAnomaly(ship, trueAnomalyTargetPer).
    local curRadTarPer is radiusAtTrueAnomaly(ship, trueAnomalyTargetPer).
    local dv is visViva(curRadTarPer, ((curRadTarPer + tar:orbit:apoapsis + body:radius)/2)).
    local nd is Node(time:seconds + timeTargetPeriapsis, 0, 0, dv).
    execNd(nd).
}

//Todo this can still fail if we do not make it into the leading position in the alloted orbits
function warpToBetterAlignment {
    parameter tar.
    parameter maxWaitOrbits is 10.
    parameter offsetDeg is 0.
    print "warpToBetterAlignment()".
    local theWait is 0.
    local curError is 180.
    from {local o is 0.} until o = maxWaitOrbits step {set o to o + 1.} do {
        local apoTime is  time:seconds + eta:apoapsis + o*obt:period.
        local vecS is positionat(ship, apoTime) - body:position.
        local vecT is positionat(tar, apoTime) - body:position.
        local vecSTCrs is vcrs(vecS, vecT).
        local vecSVCrs is vcrs(body:position, velocity:orbit).
        local cmp to vdot(vecSTCrs, vecSVCrs) > 0. //always lead, so that we never lower our periapse to get an encounter
        //always lead more than offset, get as close as possible, and always lead
        if vang(vecS,vecT) > offsetDeg and abs(vang(vecS,vecT) - offsetDeg) < curError and cmp {
            set curError to abs(vang(vecS,vecT) - offsetDeg). 
            set theWait to apoTime.
        }
    }
    warpWait(theWait - 600). //drop off 10 minutes before apoapsis (and thusly before next burn in rendezvousAtNextApoapsis)
}

function rendezvousAtNextApoapsis {
    parameter tar.
    parameter offsetDeg is 0.
    parameter dropOffBeforeRendezvous is 300.
    print "rendezvousAtNextApoapsis()".
    local p to timeToTrueAnomaly(tar,180).
    local timeToTargetAtOffset to timeToTrueAnomaly(tar, 180 - offsetDeg).
    set offsetTime to p - timeToTargetAtOffset.
    if timeToTargetAtOffset > p and offsetDeg > 0 {
        set offsetTime to p + tar:obt:period - timeToTargetAtOffset.
    }
    set p to p + tar:obt:period. //target is approaching apoapsis, we'll catch it on the next one
    local rendevousTime to time:seconds + p - offsetTime.
    local tarApoVec to positionat(tar, time:seconds + p) - body:position.
    local trueAnomTarApo to obt:trueanomaly + vang(tarApoVec, ship:position - body:position).
    local timeToTarApo to timeToTrueAnomaly(ship, trueAnomTarApo).
    set p to p - timeToTarApo. //time for target to reach apoapsis again, from the time when we reach it next
    local y to body:mu.
    local pi to constant:pi.
    local sma to ((((p-offsetTime)^2)*y)/(4*(pi^2)))^(1/3). //sma for orbit with just the right period
    local radiusAtTarApo to radiusAtTrueAnomaly(ship, trueAnomTarApo).
    local dv to visViva(radiusAtTarApo, sma).
    print "setting up rendevous".
    execNd(node(time:seconds + timeToTarApo, 0, 0, dv+0.1)). // + 0.1 because we assume low TWR engine that does not overshoot target dv
    warpWait(rendevousTime - dropOffBeforeRendezvous). //dropoff before rendezvous
    print "should be at rendevous - dropOffBeforeRendezvous".
}

function matchSMAAtTargetApoapsis {
    Parameter tar.
    print "matchApoapsis()".
  
    local perSEta is time:seconds + eta:periapsis.
    local apoTEta is time:seconds + timeToTrueAnomaly(tar, 180).
  
    local vecS is positionat(ship, perSEta)-ship:body:position.
    local vecT is positionat(target, apoTEta)-ship:body:position.
    local TrueAnomalyTargetPer is "x".
  
    if obt:inclination < 90 {
        if vdot(vcrs(vecs, vect), v(0,1,0)) > 0 {
            set trueAnomalyTargetApo to 360-vang(vecS,vecT).
        } else {
            set trueAnomalyTargetApo to vang(vecS,vecT).
        }
    } else {
        if vdot(vcrs(vecs, vect), v(0,1,0)) > 0 {
            set trueAnomalyTargetApo to vang(vecS,vecT).
        } else {
            set trueAnomalyTargetApo to 360-vang(vecS,vecT).
        }
    }
  
    local timeTargetApoapsis is timeToTrueAnomaly(ship, trueAnomalyTargetApo).
    local curRadTarApo is radiusAtTrueAnomaly(ship, trueAnomalyTargetApo).
    local dv is visViva(curRadTarApo, tar:obt:semimajoraxis).
    local nd is Node(time:seconds + timeTargetApoapsis, 0, 0, dv).
    execNd(nd).
}

function toTargetAtSpeed {
    parameter tar.
    parameter speed.
    print "toTargetAtSpeed()".
    local tarTarVelVec is (tar:position - ship:position):normalized * speed.
    local curTarVelVec is (ship:velocity:orbit - tar:velocity:orbit).
    local nd to nodeFromVector(tarTarVelVec - curTarVelVec).
    execNd(nd).
}

function approachMainEngine {
    parameter tar.
    print "approach()".
    //unless we totally cancel velocity first the code below can break for encounters with high
    //relative velocities it seems
    toTargetAtSpeed(tar, 0).

    local lock dist to (tar:position - ship:position):mag.
    local speed to 50.
    local waitDist to 3000.
    local wf to 2.
    until dist < 500 { //safety distance, overridden by break.
        if dist < 3000 {
            set speed to 30.
            set waitDist to 1500.
            set wf to 2.
        }
        if dist < 1500  {
            set speed to 20.
            set waitDist to 1000.
            set wf to 1.
        }
        if dist < 1000 {
            set speed to 10.
            set waitDist to 1000.
            set wf to 0.
        }
        toTargetAtSpeed(tar, speed).
        set warp to wf.
        wait until dist < waitDist.
        set warp to 0.
        wait until kuniverse:timewarp:rate = 1.
        if speed = 10 {
            break.
        }
    }
}

function armGrapplingDevice {
    print"armGrapplingDevice()".
    local ps to ship:partsnamed("GrapplingDevice").
    for p in ship:partsnamed("smallClaw") {
        ps:add(p).
    }
    local p to ps[0].
    local m to p:getmodule("ModuleAnimateGeneric").
    if m:hasevent("arm") {
        m:doevent("arm").
    } else {
        print "arming GrapplingDevice failed".
    }
    return p.
}

function receiveDockingPort { 
    wait until not ship:messages:empty.
    set received to ship:messages:pop.
    print "docking port received".
    local dpuid to received:content.
    for p in target:parts {
        if p:uid = dpuid {
            return p.
        }
    }
}
    
function send {
    parameter tar.
    parameter m.
    print "send()".
    set c to tar:connection.
    if c:sendmessage(m) {
          print "message: " + m + " sent".
    }
}

function finalApproach {
    parameter tar.
    parameter objective is "approach". //one of "approach", "dock", todo: "grapple"


    if objective = "approach" {
        toTargetAtSpeed(tar, 0).
        print "AG1 to continue mission after finalApproach()".
        local current to AG1.
        wait until AG1 <> current.
        return.
    }

    local lock dist to (tar:position - ship:position):mag.
    local selectedDP to "x".
    lock refPos to ship:position. //used for grappling
    local grapplingDevMod to "x".

    if objective = "dock" {
        list dockingports in dp.  
        set selectedDP to dp[0].
        lock refPos to selectedDP:position. //Todo test this
        send(tar, selectedDP:uid).
        set tar to receiveDockingPort().
        local lock dist to (tar:position - selectedDP:position):mag.
    } else if objective = "grapple" { 
        set grapplingDevMod to armGrapplingDevice():getmodule("ModuleGrappleNode").
    }
    lock steering to unrotate(tar:position).
    lock steering to tar:position.

    wait until vang(tar:position, ship:facing:vector) < 0.25.
    RCS on.
    local velBetwDockPorts to v(0,0,0).
    local tarVelVec to v(0,0,0).

    local forePid to pidloop().
    set forePid:setpoint to 10.
    set forePid:minoutput to -1.
    set forePid:maxoutput to 1.
    local lock foreVel to vdot(tarVelVec, ship:facing * v(0,0,1)).

    local starPid to pidloop().
    set starPid:setpoint to 0.
    set starPid:minoutput to -1.
    set starPid:maxoutput to 1.
    local lock starVel to vdot(tarVelVec, ship:facing * v(1,0,0)).

    local topPid to pidloop().
    set topPid:setpoint to 0.
    set topPid:minoutput to -1.
    set topPid:maxoutput to 1.
    local lock topVel to vdot(tarVelVec, ship:facing * v(0,1,0)).

    local current to AG1.
    local lastSampleTime to time:seconds.
    local lastPosError to tar:position - refPos.

    lock cond to true.
    if objective = "grapple" {
        lock cond to grapplingDevMod:hasevent("release").
    } else if objective = "dock" {
        lock cond to selectedDP:state = "PreAttached" or not (selectedDP:state = "ready").
    }
    print cond.

    until cond {
        if (lastSampleTime < time:seconds) {
            set tarVelVec to (lastPosError - (tar:position - refPos))/(time:seconds - lastSampleTime).
        }
        set lastSampleTime to time:seconds.
        set lastPosError to tar:position - refPos.
        set forePid:setpoint to min(dist/30 + 0.1, 10).
        set ship:control:fore to forePid:update(time:seconds, foreVel).
        set ship:control:starboard to starPid:update(time:seconds, starVel).
        set ship:control:top to topPid:update(time:seconds, topVel).
        wait 0.
    }

    set ship:control:neutralize to true.
    unlock steering.
    rcs off.
    sas off.
    wait 1.
}


function rendezvous {
    parameter tar.
    parameter maxWaitOrbits is 10.
    parameter objective is "approach".
    print "rendezvous()".

    matchInclination(tar).

    matchApoapsis(tar).

    warpToBetterAlignment(tar, maxWaitOrbits).

    rendezvousAtNextApoapsis(tar, 0, 0).

    approachMainEngine(tar).  

    finalApproach(tar, objective).  
}

function matchOrbitWithOffset {
    parameter tar.
    parameter offsetDeg.
    parameter maxWaitOrbits is 0.
    print "matchOrbitWithOffset".
    matchInclination(tar).

    matchApoapsis(tar).

    warpToBetterAlignment(tar, maxWaitOrbits, offsetDeg).

    rendezvousAtNextApoapsis(tar, offsetDeg).

    matchSMAAtTargetApoapsis(tar).
}

//wtf is this?
function circularToCircular {
    parameter tar.
    set so to ship:orbit.
    set mo to tar:orbit.
    set targetShipAngle to mod( mod( mo:lan + mo:argumentofperiapsis + mo:trueanomaly, 360) - mod(so:lan + so:argumentofperiapsis + so:trueanomaly, 360) + 360, 360).
    print targetShipAngle.
    set vStart to sqrt(ship:orbit:body:mu*(2/(ship:altitude + ship:orbit:body:radius) - 1/ship:orbit:semimajoraxis)).
    print vStart.
    set vTarget to sqrt(ship:orbit:body:mu*(2/(ship:altitude + ship:orbit:body:radius) - 1/((ship:orbit:semimajoraxis + tar:orbit:semimajoraxis)/2))).
    print vTarget.
    set deltaVForTransfer to vTarget - vStart.
    print deltaVForTransfer.
    set timeForTransfer to (1/2) * sqrt((4*constant:pi^2*((ship:orbit:semimajoraxis + tar:orbit:semimajoraxis)/2)^3)/ship:orbit:body:mu).
    print timeForTransfer.
    set angleTravelledByTargetDuringTransfer to (360/tar:orbit:period)*timeForTransfer.
    print angleTravelledByTargetDuringTransfer.
    set angleForTransfer to 180 - angleTravelledByTargetDuringTransfer.
    print angleForTransfer.
    set deltaAngularSpeed to (360/ship:orbit:period) - (360/tar:orbit:period).
    print deltaAngularSpeed.
    set timeToNextAngleForTransfer to 0.
    if targetShipAngle > angleForTransfer {
        set timeToNextAngleForTransfer to (targetShipAngle - angleForTransfer )/deltaAngularSpeed.
    } else {
        set timeToNextAngleForTransfer to (360 + targetShipAngle - angleForTransfer )/deltaAngularSpeed.
    }
    print timeToNextAngleForTransfer.
    SET myNode to NODE( TIME:SECONDS+timeToNextAngleForTransfer, 0, 0, deltaVForTransfer ).
    add myNode.
}

