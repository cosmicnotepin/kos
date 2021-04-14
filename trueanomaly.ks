//convert the requested trueAnomaly to meanAnomaly
//then calculate how long it would have taken to reach that mean anomaly from epoch(and the corresponding initial mean anomaly)
//if that time is in the past add full orbits till it is not.

//"epoch" in ksp is just some random timestamp ( think it is always in the past)
//it changes during play

function timeToTrueAnomaly {

  parameter tar.
  parameter taDeg. // true anomaly in degrees

  local ecc to tar:orbit:eccentricity.
  local maEpochRad to tar:orbit:meananomalyatepoch * (constant:pi/180).
  local sma to tar:orbit:semimajoraxis.
  local mu to tar:orbit:body:mu.
  local epoch to tar:orbit:epoch.

  //wikipedia Eccentric anomaly: tan(E) = (sqrt(1-ecc^2)*sin(taDeg))/(ecc + cos(taDeg))
  local eccanomdeg is arctan2(sqrt(1-ecc^2)*sin(taDeg), ecc + cos(taDeg)).
  local eccAnomRad is eccAnomDeg * (constant:pi/180).
  //wikipedia mean anomaly: M = E - ecc*sin(E)
  local meanAnomrad is eccAnomrad - ecc*sin(eccAnomDeg).

  local diffFromEpoch is meanAnomrad - maEpochRad.
  if diffFromEpoch < 0 {
    set diffFromEpoch to diffFromEpoch + 2 * constant:pi.
  }
  local meanmotion is sqrt(mu / sma^3).
  local timeFromepoch is diffFromEpoch/meanMotion.
  local timeTillFirstTaDeg is timeFromEpoch + epoch - time:seconds. //first time since epoch the requestedtrue anomaly is reached

  if timeTillFirstTaDeg < 0 {
      local extraOrbits to ceiling(abs(timeTillFirstTaDeg) / tar:orbit:period).
      return timeTillFirstTaDeg + extraOrbits * tar:orbit:period.
  } else {
      return timeTillFirstTaDeg.
  }
}

function radiusAtTrueAnomaly {
    parameter tar.
    parameter trueAnomaly.
    local ecc is tar:orbit:eccentricity.
    local sma is tar:orbit:semimajoraxis.
    local r is (sma*(1- ecc^2))/(1 + ecc*cos(trueAnomaly)).
    return r.
}

function trueAnomalyAtRadius {
    parameter tar.
    parameter r.
    local ecc is tar:orbit:eccentricity.
    local sma is tar:orbit:semimajoraxis.
    local ta is arccos((((sma*(1- ecc^2))/r) - 1)/ecc).
    return ta.
}


