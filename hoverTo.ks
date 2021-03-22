run once other.

function hoverTo {
    parameter target is waypoint("flyhere").
    parameter maxSpeed is 50.
    clearscreen.
    //print target.
    //lock steering to ship:up.
    //lock throttle to .
    //wait 1.
    //lock throttle to 0.

    lock posAboveTarget to target:position.// + (target:position - ship:orbit:body:position):normalized * 50.
    //local posAboveTarget is ship:position + (target:position - ship:orbit:body:position):normalized * 50.
    lock posError to posAboveTarget - ship:position.
    local tarVel is posError:normalized. //gets updated in loop
    lock tarVelDir to posError:normalized.
    lock trueErrorVel to tarVel - ship:velocity:surface.
    local errorVel to trueErrorVel.
    lock max_acc to maxthrust/ship:mass.
    lock antiGravityThrustVel to ship:up:forevector:normalized * (fgh()/max_acc).
    print "(fgh()/max_acc)" + (fgh()/max_acc) at (0,9).
    lock a to antiGravityThrustVel:x.
    lock b to antiGravityThrustVel:y.
    lock c to antiGravityThrustVel:z.
    lock d to errorVel:normalized:x.
    lock e to errorVel:normalized:y.
    lock f to errorVel:normalized:z.
    //wolfram alpha: 
    //solve Power[a + d x, 2] + Power[b + e x, 2] + Power[c + f x, 2] -1 = 0

    lock maxErrorMag1 to  ( (-1/2)  * ( (2*a*d + 2*b*e + 2*c*f)^2 - 4*(a^2 + b^2 + c^2 - 1)*(d^2 + e^2 + f^2) )^(1/2) - a*d - b*e - c*f )/ (d^2 + e^2 + f^2).
    lock maxErrorMag2 to  ( (1/2)  * ( (2*a*d + 2*b*e + 2*c*f)^2 - 4*(a^2 + b^2 + c^2 - 1)*(d^2 + e^2 + f^2) )^(1/2) - a*d - b*e - c*f )/ (d^2 + e^2 + f^2).
    lock maxErrorMag to max(maxErrorMag1, maxErrorMag2).

    print "maxErrorMag: " + maxErrorMag at (0,7).
    print "maxErrorMag2: " + maxErrorMag2 at (0,8).
    local posPid to pidloop(1.9, 0.001, 1).
    set posPid:setpoint to 0.
    set posPid:minoutput to 0.//speed mag
    set posPid:maxoutput to 1.

    local speedPid to pidloop(0.1, 0.001, 1).
    set speedPid:setpoint to 0.
    set speedPid:minoutput to 0.//thrust mag
    set speedPid:maxoutput to 1.

    clearvecdraws().
    local errorThrust to speedPid:update(time:seconds, -errorVel:mag/max_acc).
    local totalThrustVel to antiGravityThrustVel + errorVel:normalized * min(errorThrust, maxErrorMag).
    lock steering to lookdirup(totalThrustVel, ship:facing:topvector).
    //lock steering to ship:up.//lookdirup(errorVel, -ship:body:position).
    lock throttle to totalThrustVel:mag.

    local srfVel to vecdraw({return ship:position.}, {return ship:velocity:surface.}, red).
    set srfVel:show to true.  
    local vdPosError to vecdraw({return ship:position.}, {return totalThrustVel*10.}, white).
    set vdPosError:show to true.  
    //local vdTarVel to vecdraw({return ship:position.}, {return tarVel.}, white).
    //set vdTarVel:show to true.  
    local vdErrorVel to vecdraw({return ship:position.}, {return errorVel.}, green).
    set vdErrorVel:show to true.  
    local vdTrueErrorVel to vecdraw({return ship:position.}, {return trueErrorVel.}, yellow).
    set vdTrueErrorVel:show to true.  

    until False {
        if vdot(trueErrorVel, -ship:orbit:body:position) < 0 {
            set errorVel to vxcl(ship:orbit:body:position, trueErrorVel).
        } else {
            set errorVel to trueErrorVel.
        }
        set tarVelMag to posPid:update(time:seconds, -posError:mag).
        print "tarVelMag: " + tarVelMag at (0,5).
        print "trueErrovelmag: " + errorVel:mag at (0,6).
        set tarVel to tarVelDir * tarVelMag.
        set errorThrust to speedPid:update(time:seconds, -errorVel:mag).
        set totalThrustVel to antiGravityThrustVel + errorVel:normalized * min(errorThrust, maxErrorMag).
        print "maxErrorMag: " + maxErrorMag at (0,7).
        print "maxErrorMag2: " + maxErrorMag2 at (0,8).
        print "errorThrust: " + errorThrust at (0,8).

        wait 0.
    }
}

hoverTo().
