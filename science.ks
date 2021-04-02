function doScience {
    parameter transmit is false.

    if transmit {
        print "transmitting science".
    } else {
        print "collecting science".
    }

    bays on.
    //wait 2.
    for p in ship:parts {
        if p:hasmodule("ModuleScienceExperiment") {
            print p:name.
            set sm to p:getmodule("ModuleScienceExperiment").
            if not sm:inoperable {
                sm:dump.
                sm:reset.
                wait 0.1.
                sm:deploy.
                local ct to time:seconds.
                wait until sm:hasdata or time:seconds > ct + 5.
                if transmit and sm:hasdata {
                    sm:transmit.
                }
            }
        } 
    }

    if not transmit {
        local expStorUnit to ship:partsnamed("ScienceBox")[0].
        expStorUnit:getmodule("ModuleScienceContainer"):doaction("collect all", true).
    }
    bays off.
    //wait 2.
    print "experiments done".
}.

set lastBiome to "".
set lastSituation to "".

function checkScience {
    parameter transmit is false.
    if lastBiome = addons:biome:current and lastSituation = addons:biome:situation {
        return.
    }
    set lastBiome to addons:biome:current.
    set lastSituation to addons:biome:situation.
    doScience(transmit).
}
