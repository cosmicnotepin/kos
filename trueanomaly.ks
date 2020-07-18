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

//TODO make this not annoying
  until timeTillEta >= 0 {
    set timeTillEta to timeTillEta + tar:orbit:period.
  }

  return timeTillEta.
}

function radiusAtTrueAnomaly {
    parameter tar.
    parameter trueAnomaly.
    local ecc is tar:orbit:eccentricity.
    local sma is tar:orbit:semimajoraxis.
    local r is (sma*(1- ecc^2))/(1 + ecc*cos(trueAnomaly)).
    return r.
}


