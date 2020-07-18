
function warpWait {
    parameter tarTime.
    warpto(tarTime).
    wait until time:seconds > tarTime + 5.
}
