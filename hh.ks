run once other.

// ship:facing:forevector : -ship:control:pilottop
// ship:facing:starvector : ship:control:pilotstarboard
// ship:facing:topvector : ship:control:pilottop

stage.
//control vertical speed to setpoint by setting throttle
local vertSpeedPid to pidloop(0.01, 0, 0, -fgh()/max(fgh(), ship:availablethrust), 1-fgh()/max(fgh(), ship:availablethrust)).
set vertSpeedPid:setpoint to 0.

local lock vertThrustRatio to vdot(ship:up:forevector, ship:facing:forevector).
local tset to 0.
local lock vertThrust to tset + fgh()/max(fgh(),ship:availablethrust).
lock throttle to vertThrust/vertThrustRatio.
local lock vertVel to vdot(ship:velocity:surface, ship:up:forevector).


//control fore speed to setpoint by setting fore angle
//output of 1 mean: maximum horizontal thrust possible without interfering with vertical speed control
local Ku to 0.25.
local Tu to 30/7.
local starP to 0.2 * Ku.
local starD to 0.0666 * Tu.
local starI to 0.4 * Ku/Tu.

local horiz_P to 0.01.

local starset to 0.
local starPid to pidloop(horiz_P, 0, 0, -1, 1).
set starPid:setpoint to 0.
//orthogonal to ship:up in direction of ship:facing:starvector
local lock starVec to vcrs(-1 * ship:facing:topvector, body:position):normalized.  
local lock starVel to vdot(ship:velocity:surface, starVec).


//control top speed to setpoint by setting top angle
//output of 1 mean: maximum horizontal thrust possible without interfering with vertical speed control
local topset to 0.
local topPid to pidloop(horiz_P, 0, 0, -1, 1).
set topPid:setpoint to 0.
//orthogonal to ship:up in direction of ship:facing:topvector
local lock topVec to vcrs(1 * ship:facing:starvector, body:position):normalized.  
local lock topVel to vdot(ship:velocity:surface, topVec).



//value [0,1] in "part of throttle"
local lock maxHorizThrot to (1 - (fgh()/max(fgh(), ship:availablethrust))^2)^(1/2).



local shower to vecdraw({return ship:position.}, {return ship:position + 30 * ship:facing:forevector.}, red).
set shower:show to true.
local shower1 to vecdraw({return ship:position.}, {return ship:position + 30 * ship:facing:starvector.}, blue).
set shower1:show to true.
local shower2 to vecdraw({return ship:position.}, {return ship:position + 30 * ship:facing:topvector.}, green).
set shower2:show to true.

local shower11 to vecdraw({return ship:position + V(0,0,1).}, {return ship:position + 30 * starVec.}, blue).
set shower11:show to true.
local shower22 to vecdraw({return ship:position + V(0,0,1).}, {return ship:position + 30 * topVec.}, green).
set shower22:show to true.

local shower111 to vecdraw({return ship:position + V(0,0,1).}, {return ship:position + 10 * starVel*starVec.}, blue).
set shower111:show to true.
local shower222 to vecdraw({return ship:position + V(0,0,1).}, {return ship:position + 10 * topVel*topVec.}, green).
set shower222:show to true.


set resetSetpoints to True.
set sensitivity to 1.

until False {

    set vertSpeedPid:setpoint to vertSpeedPid:setpoint - ship:control:pilottop * sensitivity. 
    set tset to vertSpeedPid:update(time:seconds, vertVel).

    set starPid:setpoint to starPid:setpoint + ship:control:pilotstarboard * sensitivity. 
    set starset to starPid:update(time:seconds, starVel).

    set topPid:setpoint to topPid:setpoint + ship:control:pilotfore* sensitivity. 
    set topset to topPid:update(time:seconds, topVel).


    local requestedHorizThrot to ((maxHorizThrot*starset)^2 + (maxHorizThrot*topset)^2)^(1/2).
    if requestedHorizThrot > maxHorizThrot {
        set starset to starset * maxHorizThrot/requestedHorizThrot.
        set topset to topset * maxHorizThrot/requestedHorizThrot.
    }

    set steerVec to unrotate(ship:up:forevector:normalized*max(vertThrust, 0.001)
            + starVec*starset
            + topVec*topset
            ).  
    set steering to steerVec.

    if ship:control:pilotyaw > 0 {
        set resetSetpoints to True.
    }
    if ship:control:pilotyaw < 0 {
        set resetSetpoints to False.
    }

    if resetSetpoints {
        if ship:control:pilottop = 0 {
            set vertSpeedPid:setpoint to 0.
        }
        if ship:control:pilotstarboard = 0 {
            set starPid:setpoint to 0.
        }
        if ship:control:pilotfore = 0 {
            set topPid:setpoint to 0.
        }
    }
    if not (ship:control:pilotpitch = 0) {
        break.
    }
    wait 0.
}
