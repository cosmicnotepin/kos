run once hover.
run once other.
run once launch.
global boundingBox is ship:bounds.

function distanceToGround {
  return boundingbox:bottomaltradar.
}

function stoppingDistance {
    //assuming thrusting straight down
    //assuming constant gravity
    // s = -(1/2)*a*t^2 + v_0*t
    // t = v_0/a
    // s = (v_0^2)/(2*a)
  local grav is constant:g * (body:mass / body:radius^2). // gravity at 0 meters
  local maxDeceleration is (ship:availableThrust / ship:mass) - grav.
  return ship:verticalSpeed^2 / (2 * maxDeceleration).
}

function suicideBurn {
    parameter targetHeight is 10.
    print "suicide burning".
    set warpmode to "physics".
    set warp to 4.
    lock steering to unrotate(srfRetrograde:forevector).
    when stoppingDistance() - ship:verticalSpeed * 2 > distanceToGround() then {
        kuniverse:timewarp:cancelwarp.
        return false.
    }
    until distanceToGround() < targetHeight {
        if stoppingDistance() - ship:verticalSpeed * 2 > distanceToGround() {
            set throttle to 1.
        } else {
            set throttle to 0.
        }
        wait 0.
    }
}

function testSuicideHover { 
    wait 1.
    set steering to unrotate(heading(90,90)).
    lock throttle to 1.
    stage.
    wait until alt:radar > 500.
    lock throttle to 0.
    local lock vertVel to vdot(ship:velocity:surface, ship:up:forevector).
    wait until vertVel < 0.
    suicideBurn(10).
    hover(1,1).
}

function stopInOrbit {
    //assuming circular orbit 
    print "stopping in orbit".
    local lock HorVelVec to vxcl(up:vector, -velocity:surface).
    lock steering to unrotate(HorVelVec).
    wait until vang(HorVelVec, ship:facing:vector) < 0.25.
    lock throttle to 1.
    local tset to 0.
    lock throttle to tset.
    until HorVelVec:mag < 1
    {
        set max_acc to maxthrust/ship:mass.  
        if max_acc = 0 {
            break.
        }
        set tset to min(HorVelVec:mag/max_acc, 1).
    }
    lock throttle to 0.  
    unlock steering.
}

function landImmediately {
    local stagingTriggerActive is True.

    when stagingTriggerActive and maxthrust = 0 then {
        stage.
        preserve.
    }
    stopInOrbit().
    suicideBurn(10).
    gear on.
    hover(1,1).
    set stagingTriggerActive to false.
}

function aeroBrakeReturn {
    launchToCircVac().
    print "set node for aerobrake return, then AG1".
    local current to AG1.
    wait until AG1 <> current.
    execNd().
    stage. 
    wait 1.
    stage.
    wait 1.
    stage.
    wait 1.
    lock steering to unrotate(retrograde:forevector).
    warpWait(time:seconds + obt:nextpatcheta + 60).
    //find safe space outside atmosphere to warp to
    local t to 15.
    until (positionat(ship, time:seconds + eta:periapsis-t) - body:position):mag > 70000 + body:radius {
        set t to t + 15.
    }

    warpWait(time:seconds + eta:periapsis - t).
    set warpmode to "physics".
    set warp to 4.
    wait until status = "landed" or status = "splashed".
}
