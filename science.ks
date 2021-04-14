//does every experiment type once
function doScience {
    parameter transmit is false.

    if transmit {
        print "transmitting science".
    } else {
        print "collecting science".
    }

    local doneBefore to list().
    local scienceBox to "x".
    bays on.
    //wait 2.
    for p in ship:parts {
        if p:hasmodule("ModuleScienceExperiment") {
            if not (doneBefore:find(p:name) = -1) {
                break.
            }
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
            doneBefore:add(p:name).
        } 
        //remenmber science collector for later
        if p:hasmodule("ModuleScienceContainer") {
            set scienceBox to p.
        }
    }

    if not transmit {
        scienceBox:getmodule("ModuleScienceContainer"):doaction("collect all", true).  
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
