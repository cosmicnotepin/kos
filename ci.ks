
local colorList is list(RED, GREEN, BlUE, YELLOW, CYAN, MAGENTA, WHITE, BLACK).
local g0 to 9.80665.
//local g0 to 9.81.//0665.

//TODO:
//Ullage motors
//find correct g0
//different engine types in one decoupleStage
//why are the numbers so far off from what mechjeb is showing?
//kerbal engineer seems much closer, sometimes even agrees

function traverse {
    parameter p.
    parameter s.
    parameter dss.

    local hl is highlight(p, colorList[s]).
    local ds to dss[s].
    if not p:istype("launchclamp") {
        set ds:mass to ds:mass + p:mass.
    } else {
        print p:name.
    }

    if p:name = "snubotron" {
        //just ignore ullage Motors for now
    }

    if p:istype("engine") and not (p:stage = p:separatedin) and not (p:name = "snubotron") {
        //separation engines caught by abave condition
        //for now assuming only one type of engine per decoupleStage
        //all activate at the same time 
        ds:engines:add(p).
        set ds:visp to p:visp.
        set ds:ve to p:visp*g0. //simply setting and resetting every time
        set ds:FVac to ds:FVac + p:possiblethrustat(0.0).
        set ds:FSL to ds:FSL + p:possiblethrustat(1.0).
        //set ds:q to ds:q + p:maxfuelflow.
        set ds:q to ds:q + p:possiblethrustat(0.0)/ds:ve.  
        set ds:activatedIn to p:stage. //simply setting and resetting every time
    } 
    if p:resources:length > 0 {
        for res in p:resources {
            if ds:resources:haskey(res:name) {
                set ds:resources[res:name]:amount to ds:resources[res:name]:amount + res:amount.
            } else {
                local resLex to lexicon(
                "amount" , res:amount,
                "density", res:density).
                //print ds:resources[res:name].
                set ds["resources"][res:name] to resLex.
            } 
        }
    }
    for cp in p:children {
        if cp:istype("decoupler") {
            //this only works for very simple rockets
            //TODO 
            // - decouplable tanks without engines
            // - respect "separated in" of decouplers
            traverse(cp, s+1, dss).
        } else {
            traverse(cp,s,dss).
        }
    }

}

local stagecount to stage:number.
if status = "prelaunch" {
    set stagecount to stagecount - 1.
}

local decoupleStages to list().
for s in range(0, stagecount + 1) {
    local decoupleStage to lexicon("engines", list(), 
                "resources", lexicon(),
                "droppedMass", 0,
                "activatedIn", -1,
                "merged", false,
                "mass", 0, 
                "fuel", 0,
                "drymass", 0,
                "ve", 0,
                "visp", 0,
                "FVac", 0,
                "FSL", 0,
                "q", 0, 
                "dv", 0,
                "t", 0).
    decoupleStages:add(decoupleStage).
}

traverse(ship:rootpart, 0, decoupleStages).

for ds in decoupleStages {
    for e in ds:engines {
        for cr in e:consumedresources:values {
            set ds:fuel to ds:fuel + (ds["resources"][cr:name]:density * ds["resources"][cr:name]:amount).
        }
        set ds:t to ds:fuel/ds:q.
        set ds:droppedMass to ds:mass - ds:fuel.
        break. //assume all engines in one decouple stage are the same.
    }
}

local massAbove to 0.
local engineConstStages to list().
for dsn in range(decoupleStages:length) {
    set thisStage to decoupleStages[dsn].
    if not thisStage:merged and thisStage:engines:length > 0 {
        for dsin in range(dsn + 1, decoupleStages:length) {
            if thisStage:activatedIn = decoupleStages[dsin]:activatedIn {
                print "merging".
                local bothStage to decoupleStages[dsin].

                set thisStage:mass to thisStage:mass + massAbove - thisStage:q * bothStage:t.
                set thisStage:fuel to thisStage:fuel - thisStage:q * bothStage:t.
                set thisStage:t to thisStage:t - bothStage:t.
                set thisStage:dv to thisStage:ve * ln(thisStage:mass/(thisStage:mass - (thisStage:t * thisStage:q))).
                set thisStage:merged to true.
                engineConstStages:add(thisStage).

                set bothStage:mass to bothStage:mass + thisStage:mass + massAbove.
                set bothStage:q to bothStage:q + thisStage:q.
                set bothStage:visp to (thisStage:FVac + bothStage:FVac)/((thisStage:FVac/thisStage:visp) + (bothStage:FVac/bothStage:visp)).
                set bothStage:ve to bothStage:visp*g0.
                set bothStage:dv to bothStage:ve * ln(bothStage:mass/(bothStage:mass - (bothStage:t * bothStage:q))).
                set bothStage:FVac to bothStage:FVac + thisStage:FVac.
                set bothStage:FSL to bothStage:FSL + thisStage:FSL.
                set bothStage:merged to true.
                engineConstStages:add(bothStage).

                break.
            }
        } 
        if not thisStage:merged {
            print "unmerged".
            set thisStage:mass to thisStage:mass + massAbove.
            set massAbove to thisStage:mass.
            set thisStage:dv to thisStage:ve * ln(thisStage:mass/(thisStage:mass - (thisStage:t * thisStage:q))).
            engineConstStages:add(thisStage).
        }
    }
}

print "final:".
for ecs in engineConstStages {
    print "============================================".
    print "t: " + ecs:t.
    print "dv: " + ecs:dv.
    print "mass: " + ecs:mass.
    print "q: " + ecs:q.
    print "FVac: " + ecs:FVac.
    print "FSL: " + ecs:FSL.
    print "droppedMass: " + ecs:droppedMass.
}
//interstage sequencing (side-boosters etc.)
//if two decouple stages fire at the same time create two constEngineStages
// one for the time where both fire, one for the time where the longer firing one fires.


//in-stage sequencing (ullage motors, separation motors etc.).



