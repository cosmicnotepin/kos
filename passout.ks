run once other.

stage.

wait until maxthrust = 0.

stage.

safely_deploy_chutes().

set condition to { return status = "landed" or status = "splashed". }.
warp_until(condition@).
