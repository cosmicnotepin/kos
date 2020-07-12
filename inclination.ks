run once execNd.

Function ascenDescenFinder {

  parameter tarShip.

  //normal vectors of the planes of the orbits in SOI-RAW
  local normalVector1 is vcrs(ship:position - body:position, ship:velocity:orbit).
  local normalVector2 is vcrs(tarShip:position - tarShip:body:position, TarShip:velocity:orbit).

  // DNvector is the cross product of both normal vectors (both are on the same plane)
  // automatically actually points to DN not AN
  // in SOI-RAW
  local DNvector is vcrs(normalVector2, normalVector1).
  local trueAnomDN is "x".
  local trueAnomAN is "x".

  // TA of DN
  // vang(x,y) is always smaller 180, the vdot checks if we are approaching the DN or not
  if vdot(dNvector + body:position, ship:velocity:orbit) > 0 {
    set trueAnomDN to obt:trueanomaly + vang(DNvector, ship:position - body:position).
  } else {
    set trueAnomDN to obt:trueanomaly - vang(DNvector, ship:position - body:position).
  }

  //there were some until loops here suggesting this could be more than 360 degrees off,
  //i do not believe it
  if trueAnomDN < 0 {
    set trueAnomDN to trueAnomDN + 360.
    //wait 0.
  }

  if trueAnomDN > 360 {
    set TrueAnomDN to trueAnomDN -360.
  }

  // TA of AN
  set trueAnomAN to trueAnomDN + 180.
  if trueAnomAN > 360 {
    set trueAnomAN to trueAnomAN -360.
  }

  local ANDNList is list(trueAnomAN, trueAnomDN).
  return ANDNList.
}

function timeToTrueAnomaly {

  parameter tar.
  parameter taDeg. // true anomaly in degrees

  local ecc to tar:orbit:eccentricity.
  local maEpoch to tar:orbit:meananomalyatepoch * (constant:pi/180).
  local sma to tar:orbit:semimajoraxis.
  local mu to tar:orbit:body:mu.
  local epoch to tar:orbit:epoch.

  //wikipedia Eccentric anomaly: tan(E) = (sqrt(1-ecc^2)*sin(taDeg))/(ecc + cos(taDeg))
  local eccanomdeg is arctan2(sqrt(1-ecc^2)*sin(taDeg), ecc + cos(taDeg)).
  local eccAnomRad is eccAnomDeg * (constant:pi/180).
  //wikipedia mean anomaly: M = E - ecc*sin(E)
  local meanAnomrad is eccAnomrad - ecc*sin(eccAnomDeg).

  local diffFromEpoch is meanAnomrad - maEpoch.
  until diffFromEpoch > 0 {
    set diffFromEpoch to diffFromEpoch + 2 * constant:pi.
  }
  local meanmotion is sqrt(mu / sma^3).
  local timeFromepoch is diffFromEpoch/meanMotion.
  local timeTillEta is timeFromEpoch + epoch - time:seconds.

  until timeTillEta >= 0 {
    set timeTillEta to timeTillEta + tar:orbit:period.
  }

  return timeTillEta.
}

function angleToTargetOrbit {
    parameter tar.
    local normShipObt to vcrs(ship:position - body:position, velocity:orbit).
    local normTarObt to vcrs(tar:position - body:position, tar:velocity:orbit).
    return vang(normShipObt, normTarObt).
}

function dvInclChange {
    parameter trueAnomaly.
    parameter theta.
    local ecc    is ship:orbit:eccentricity.
    local sma    is ship:orbit:semimajoraxis.
    local rad1   is (sma*(1- ecc^2))/(1 + ecc*cos(trueAnomaly)).
    local v   is sqrt(body:mu*((2/rad1)-(1/sma))).
    local dvInclCh is 2*v*sin(theta/2).
    return dvInclCh.
}

function matchInclination {
    parameter tar.
    local angle to angleToTargetOrbit(target).
    local andn to ascenDescenFinder(target).
    local an to andn[0].
    local dn to andn[1].
    local etaAn to timeToTrueAnomaly(ship, an).
    local etaDn to timeToTrueAnomaly(ship, dn).
    local dv to 0.
    local dvNormal to 0.
    local eta to 0.
    if etaAn < etaDn {
        set dv to dvInclChange(an, angle).
        set dvNormal to - cos(angle/2)*dv.
        set eta to time:seconds + etaAn.
    } else {
        set dv to dvInclChange(dn, angle).
        set dvNormal to cos(angle/2)*dv.
        set eta to time:seconds + etaDn.
    }
    local dvPrograde to - sin(angle/2)*dv.
    set nd to node(eta, 0, dvNormal, dvPrograde).
    add nd.
    exNexNd().
    remove nd.
}
