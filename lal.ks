run once science.
run once other.

set dir to 90.
set mysteer to heading(dir,90).
lock steering to unrotate(mysteer:forevector).

lock throttle to 1.
stage.

print "waiting for apoapsis".
until apoapsis > 82000 {
    wait 5.
    set vel to velocity:surface:mag.
    if vel < 1350 {
        set pitch to 90 - vel/15.
        set mysteer to heading(dir, pitch).
    } else if vel >= 1350 {
        set mysteer to heading(dir,0).
    }
}

lock throttle to 0.

set condition to { return altitude > 80000. }.

warp_until(condition@).

checkScience().

wait 1.

stage.

wait until maxthrust = 0.

stage.

lock steering to unrotate(srfRetrograde:forevector).

safely_deploy_chutes().
wait until chutes.

set condition to { return status = "landed" or status = "splashed". }.
warp_until(condition@).
checkScience().


