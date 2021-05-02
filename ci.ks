function traverse {
    parameter p.
    parameter s.
    parameter sll.

    sll[s]:add(p).
    for cp in p:children {
        if cp:istype("decoupler") {
            traverse(cp, s+1, sll).
        } else {
            traverse(cp,s,sll).
        }
    }

}

local stagecount to stage:number.
if status = "prelaunch" {
    set stagecount to stagecount - 1.
}

local stageListsList to list().
local stages to list().
for s in range(0, stagecount + 1) {
    stageListsList:add(list()).
    //local thisStage to lexicon("engines", list(), 
    //            "mass", 0, 
    //            "fuel", 0,
    //            "drymass", 0,
    //            "ve", 0,
    //            "FVac", 0,
    //            "FSL", 0,
    //            "q", 0, 
    //            "dv", 0,
    //            "t", 0).
    //stages:add(thisStage).
}

traverse(ship:rootpart, 0, stageListsList).

//print stageListsList.
local colorList is list(RED, GREEN, BlUE, YELLOW, CYAN, MAGENTA, WHITE, BLACK).
for sn in range(stageListsList:length) {
    for p in stageListsList[sn] {
        local hl is highlight(p, colorList[sn]).
    }
}

//in-stage sequencing (ullage motors, separation motors etc.).
for sn in range(stageListsList:length) {
    local elist to list().
    for sn in range(stageListsList:length) {
        elist:add(list()).
    }
    for p in stageListsList[sn] {
        for sni in range(stageListsList:length) {
            if p:istype("engine") and (not (p:stage = p:separatedin) and (p:stage = sni)) { 
                elist[sni]:add(p).
            }
        } 
    }
    for sni in range(stageListsList:length) {
        if(elist[sni]:length > 0) {
            local thisStage to lexicon("engines", elist[sni], 
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
    }
}

for s in stages {
    print s:engines.
}
//interstage sequencing (side-boosters etc.)



