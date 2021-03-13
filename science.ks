function doScience {
    parameter transmit is false.
    parameter blacklist is list().

    if transmit {
        print "transmitting science".
    } else {
        print "collecting science".
    }

    bays on.
    //wait 2.
    set experimentTypes to list("sensorThermometer", "sensorBarometer", "science.module", "GooExperiment", "sensorAtmosphere", "sensorGravimeter", "sensorAccelerometer", "landerCabinSmall").
    for type in experimentTypes {
        print type.
        if blacklist:contains(type) {
            print "here".
            break.
        }
        for part in ship:partsnamed(type) {
            set sm to part:getmodule("ModuleScienceExperiment").
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
                break.
            }
        } 
    }

    if not transmit {
        for sc in ship:modulesnamed("ModuleScienceContainer") {
            sc:doaction("collect all", true).
        }
    }
    bays off.
    //wait 2.
    print "experiments done".
}.

set lastBiome to "".
set lastSituation to "".

function checkScience {
    parameter transmit is false.
    parameter blacklist is list().
    if lastBiome = addons:biome:current and lastSituation = addons:biome:situation {
        return.
    }
    set lastBiome to addons:biome:current.
    set lastSituation to addons:biome:situation.
    doScience(transmit, blacklist).
}
