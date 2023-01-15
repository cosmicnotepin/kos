run once other.

set dir to 90.
set mysteer to heading(dir,90).
lock steering to unrotate(mysteer:forevector).

set speed_pid to pidloop(1,0,0,0,1,0).
set speed_pid:setpoint to 145.

set mythrot to 0.
lock throttle to mythrot.
stage.
until altitude > 5000 {
    set mythrot to speed_pid:update(time:seconds, velocity:surface:mag).
}
lock throttle to 0.
stage.

set condition to { return status = "landed" or status = "splashed". }.

warp_until(condition@).

