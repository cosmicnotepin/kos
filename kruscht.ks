
function deorbit {
    parameter periapse is 30000.
    set y to obt:body:mu.
    set r to altitude + obt:body:radius.
    set a to (r + periapse + obt:body:radius)/2.
    set va to velocity:orbit:mag.
    set vf to sqrt(y*(2/r - 1/a)).
    set nd to node( time:seconds + 800, 0, 0, -(va - vf) ).
    execNd(nd).
}

function land {
    //tries to stage the deorbit engine and a heatshield
    set warpmode to "rails".
    set warp to 4.
    wait until altitude < 70000.
    set warpmode to "physics".
    set warp to 4.

    lock steering to srfretrograde.
    stage.
    wait 2.
    when (not chutessafe) then {
        chutessafe on.
        return (not chutes).
    }
    wait until chutes.
    local randomChute to ship:modulesnamed("ModuleParachute")[0].
    wait until alt:radar < randomChute:getfield("altitude").
    wait 2.
    kuniverse:timewarp:cancelwarp.
    wait 2.
    for dcm in ship:modulesnamed("ModuleDecouple") {
        for ev in dcm:alleventnames {
            if ev = "jettison heat shield" {
                dcm:doevent("jettison heat shield").
            }
        }
    }
    wait 2.
    legs on.
    set warpmode to "physics".
    set warp to 4.
    wait until alt:radar < 15.
    kuniverse:timewarp:cancelwarp.
    wait until status = "splashed" or status = "landed".
    print status.
}
