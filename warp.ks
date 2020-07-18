
function warpWait {
    parameter tarTime.
    set warp to 0.
    until kuniverse:timewarp:issettled = true {
      wait 1.
    }
    warpto(tarTime).
    wait until time:seconds > tarTime + 5.
}
