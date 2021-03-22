run once hover.
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
    print "suicide burning".
    parameter targetHeight is 10.
    lock steering to srfRetrograde.
    until distanceToGround() < targetHeight {
        if stoppingDistance() - ship:verticalSpeed * 2 > distanceToGround() {
            lock throttle to 1.
        } else {
            lock throttle to 0.
        }
    }
}

function testSuicideHover { 
    wait 1.
    set steering to heading(90,90).
    lock throttle to 1.
    stage.
    wait until alt:radar > 500.
    lock throttle to 0.
    local lock vertVel to vdot(ship:velocity:surface, ship:up:forevector).
    wait until vertVel < 0.
    suicideBurn(10).
    hover(1,-1).
}

function stopInOrbit {
    //assuming circular orbit 
    print "stopping in orbit".
    local lock HorVelVec to vxcl(up:vector, -velocity:surface).
    lock steering to HorVelVec.
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
    stopInOrbit().
    suicideBurn(10).
    gear on.
    hover(1,-1).
}

function aeroBrakeReturn {
    execNd().
    lock steering to retrograde.
    stage.
}
