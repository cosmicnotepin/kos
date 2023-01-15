//does every experiment type once
function doScience {
    parameter transmit is false.
    parameter dump is false.

    print " ".
    if transmit {
        print "transmitting science".
    } else {
        print "collecting science".
    }

    local doneBefore to list().
    local scienceBox to "x".
    bays on.
    for p in ship:parts {
        if p:hasmodule("ModuleScienceExperiment") {
            set sm to p:getmodule("ModuleScienceExperiment").
            if (doneBefore:find(p:name) = -1) and not sm:inoperable
               and not (sm:hasdata and not dump) {
                print "    " + p:name.
                sm:dump.
                sm:reset.
                wait until not sm:hasdata and not sm:deployed.
                sm:deploy.
                local ct to time:seconds.
                wait until sm:hasdata or time:seconds > ct + 5.
                if transmit and sm:hasdata {
                    sm:transmit.
                }
                doneBefore:add(p:name).
            }
        } 
        //remenmber science collector for later
        if p:hasmodule("ModuleScienceContainer") {
            set scienceBox to p.
        }
    }

    //TODO handle command module is science container correctly?
    if not transmit and not (scienceBox = "x") and Career():CANDOACTIONS {
        print "putting science in:" + scienceBox:name.
        scienceBox:getmodule("ModuleScienceContainer"):doaction("collect all", true).  
    }

    bays off.
    print "experiments done".
    print " ".
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
