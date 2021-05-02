local lock eastVec to vcrs(north:forevector, body:position):normalized.  
local lock moonNormal to vcrs(moon:position, moon:velocity:orbit):normalized.
local lock shipNormal to vcrs(-body:position, eastVec):normalized.
local lock blahNormal to vcrs(-body:position, heading(90 - vang(moonNormal, shipNormal),0):forevector):normalized.
until false {
    print vang(moonNormal, shipNormal) at (0,20).
    print vang(moonNormal, -body:position) at (0,21).
    print vang(blahNormal, moonNormal) at (0,22).

}

