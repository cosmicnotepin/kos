function getStagingInfo {

    local colorList is list(RED, GREEN, BlUE, YELLOW, CYAN, MAGENTA, WHITE, BLACK).
    local g0 to 9.80665.
    local stagecount to stage:number.
    if status = "prelaunch" {
        set stagecount to stagecount - 1.
    }

    local stages to list().
    for s in range(0, stagecount + 1) {
        local thisStage to lexicon("engines", list(), 
                    "mass", 0, 
                    "fuel", 0,
                    "drymass", 0,
                    "ve", 0,
                    "FVac", 0,
                    "FSL", 0,
                    "q", 0, 
                    "dv", 0,
                    "t", 0).
        stages:add(thisStage).
    }

    list parts in plist.

    for sn in range(0, stagecount + 1) {
        local s to stages[sn].
        list engines in elist.
        for e in elist {
            //e:activate.
            if e:stage = sn {
                s:engines:add(e).
                for resource in e:consumedresources:values {
                    set s:fuel to s:fuel + resource:amount * resource:density.
                }
            }
        }

        if s:engines:length > 0 {
            for p in plist {
                //print p:name.
                //print p:separatedin.
                //print p:typename.
                local hl is highlight(p, colorList[p:stage + 1]).
                local sepsIn to p:separatedin.
                if p:istype("Decoupler") {
                    set sepsIn to sepsIn + 1.
                }
                if sepsIn <= sn - 1 and not p:istype("launchclamp") {
                    set s:mass to s:mass + p:mass.
                }
            }
            set s:ve to s:engines[0]:visp*g0.
            for e in s:engines {
                set s:FVac to s:FVac + e:possiblethrustat(0.0).
                set s:FSL to s:FSL + e:possiblethrustat(1.0).
            }
            set s:q to s:FVac/s:ve.

            set s:dryMass to s:mass - s:fuel.
            set s:dv to s:ve*ln(s:mass/s:dryMass).
            set s:t to ((s:mass - (s:mass/(constant:e^(s:dv/s:ve))))/s:q).
        } else {
            set s:ve to 0.
            set s:FVac to 0.
            set s:q to 0.
            set s:dv to 0.
            set s:t to 0.
        }
        if (s:dv > 0 or true) {
            print "Number: " + sn.
            print "mass: " + s:mass.
            print "dryMass: " + s:drymass.
            print "fuel: " + s:fuel.
            print "ve: " + s:ve.
            print "FVac: " + s:FVac.
            print "FSL: " + s:FSL.
            print "q: " + s:q.
            print "dv: " + s:dv.
            print "t: " + s:t.
            print "============".
        }
    }
    return "balh".
}

function craftInfoToOctave {
    parameter filename is "craftInfo.json".
}

getStagingInfo().
