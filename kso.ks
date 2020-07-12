run once execNd.

function dvKSOTrans {
    local y to obt:body:mu.
    local a to obt:semimajoraxis. // == radius because i assume circular starting orbit
    local as to 3463330. //sma synchronous
    local at to (a + as)/2. //sma transfer
    local va to sqrt(y/a). //velocity of starting orbit
    local vf to sqrt(y*(2/a - 1/at)). //velocity of transfer orbit at periapse
    return vf - va.
}

function dvKSOIns {
    local y to obt:body:mu.
    local at to obt:semimajoraxis. // assuming to be on transfer orbit during this calculation
    local as to 3463330. //sma synchronous
    local r to obt:apoapsis + obt:body:radius.
    local va to sqrt(y*(2/r - 1/at)). //velocity of transfer orbit at apoapse
    local vf to sqrt(y/as). // velocity of KSO
    return vf - va.
}

function KSOat {
    parameter lngt is 0.
    local wSS to 360/obt:body:rotationperiod.
    local a to obt:semimajoraxis.
    local as to 3463330. //sma synchronous
    local at to (as + a)/2. //sma transfer
    local pi to constant:pi.
    local y to obt:body:mu.
    local p to sqrt((4*pi^2*a^3)/y).
    local w to 360/p.
    local lng to geoposition:lng.
    local pt to sqrt((4*pi^2*at^3)/y).
    local ps to sqrt((4*pi^2*as^3)/y).
    local alpha to 180 - (wSS*pt)/2.
    local t to (lngt - lng - alpha)/(w - wSS).
    if t < 0 {
        set t to (lngt - lng - alpha + 360 )/(w - wSS).
    }
    set nd to node( time:seconds + t, 0, 0, dvKSOTrans() ).
    add nd.
    exNexNd().
    remove nd.
    set nd to node( time:seconds + eta:apoapsis, 0, 0, dvKSOIns() ).
    add nd.
    exNexNd().
    remove nd.
    set tset to 0.
    lock throttle to tset.
    if obt:semimajoraxis > as {
        lock steering to retrograde.
        wait until vang(retrograde:vector, ship:facing:vector) < 0.25.
        until obt:semimajoraxis < (as + 0.5) {
            set tset to min(abs(obt:semimajoraxis - as)/100000, 1).
        }
    } else {
        lock steering to prograde.
        wait until vang(prograde:vector, ship:facing:vector) < 0.25.
        until obt:semimajoraxis > (as - 0.5) {
            set tset to min(abs(obt:semimajoraxis - as)/100000, 1).
        }
    }
    print "at KSO at: " + geoposition:lng.
}

