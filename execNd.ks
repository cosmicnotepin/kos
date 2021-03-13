run once warp.

function burnTime {
    parameter burn.
    local g0 to 9.80665.
    local stagecount to stage:number.
    if status = "prelaunch" {
        set stagecount to stagecount - 1.
    }

    local engines to list().
    local mass to list().
    local fuel to list(). 
    local drymass to list().
    local ve to list().
    local F to list().
    local q to list().
    local dv to list().
    local t to list().
    for s in range(0, stagecount + 1) {
        engines:add(list()).
        mass:add(0).
        fuel:add(0). 
        drymass:add(0).
        ve:add(0).
        F:add(0).
        q:add(0).
        dv:add(0).
        t:add(0).
    }

    list parts in plist.
    for p in plist {
        for s in range(0, stagecount + 1){
            if p:separatedin <= s - 1 {
                set mass[s] to mass[s] + p:mass.
            }
            if p:separatedin = s - 1 or ( s = 1 and p:separatedin = -1) {
                set fuel[s] to fuel[s] + p:mass - p:drymass.
            }
        }
    }

    for s in range(0, stagecount + 1) {
        list engines in elist.
        for e in elist {
            if e:stage = s {
                engines[s]:add(e).
            }
        }
        //TODO if engines[s]:length > 0
        // Ion engine circdv??

        set dryMass[s] to mass[s] - fuel[s].
        if engines[s]:length > 0 {
            set ve[s] to engines[s][0]:visp*g0.
            set F[s] to engines[s][0]:possiblethrustat(0.0).
            set q[s] to F[s]/ve[s].
            set dv[s] to ve[s]*ln(mass[s]/dryMass[s]).
            set t[s] to ((mass[s] - (mass[s]/(constant:e^(dv[s]/ve[s]))))/q[s]).
        } else {
            set ve[s] to 0.
            set F[s] to 0.
            set q[s] to 0.
            set dv[s] to 0.
            set t[s] to 0.
        }
        //print "Number: " + s.
        //print "mass: " + mass[s].
        //print "dryMass: " + drymass[s].
        //print "fuel: " + fuel[s].
        //print "ve: " + ve[s].
        //print "F: " + F[s].
        //print "q: " + q[s].
        //print "dv: " + dv[s].
        //print "t: " + t[s].
    }

    local i to 0.
    local tBurn to 0.
    until burn - dv[i] < 0 {
        set burn to burn - dv[i].
        set tBurn to tBurn + t[i].
        set i to i + 1.
    }
    set tBurn to tBurn + ((mass[i] - (mass[i]/(constant:e^(burn/ve[i]))))/q[i]).
    return tBurn.
}

function execNd {
    parameter nd is 0.
    if nd = 0 {
        set nd to nextnode.
    } else {
        add nd.
    }
    local max_acc to maxthrust/ship:mass.
    local burn_duration to burnTime(nd:deltav:mag).
    lock steering to nd:deltav.  
    wait until vang(nd:deltav, ship:facing:vector) < 0.25 or nd:eta <= (burn_duration/2).
    warpWait(time:seconds + nd:eta - (burn_duration/2 + 15)).
    
    wait until vang(nd:deltav, ship:facing:vector) < 0.25 or nd:eta <= (burn_duration/2).
    
    wait until nd:eta <= (burn_duration/2).
    local tset to 0.
    lock throttle to tset.
    until nd:deltav:mag < 0.1
    {
        set max_acc to maxthrust/ship:mass.  
        if max_acc = 0 {
            break.
        }
        set tset to min(nd:deltav:mag/max_acc, 1).
    }
    lock throttle to 0.
    unlock steering.
    unlock throttle.
    set ship:control:pilotmainthrottle to 0.
    remove nd.
    wait 1.
}
