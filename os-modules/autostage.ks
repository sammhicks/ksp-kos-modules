@lazyGlobal off.

parameter import, declareExport.

local decouplerEngines is Lexicon().

local stageDelay is 3.

for engine in ship:parts {
    if engine:isType("Engine") {
        from { local decoupler is engine. } until not decoupler:hasParent step { set decoupler to decoupler:parent. } do {
            if (engine:stage <> decoupler:stage) and (decoupler:modules:contains("ModuleDecouple") or decoupler:modules:contains("ModuleAnchoredDecoupler")) {
                if not decouplerEngines:hasKey(decoupler) {
                    set decouplerEngines[decoupler] to UniqueSet().
                }
                decouplerEngines[decoupler]:add(engine).
            }
        }
    }
}

local function tick {
    for decoupler in decouplerEngines:keys
    {
        if decoupler:ship = ship {
            for engine in decouplerEngines[decoupler]:copy()
            {
                if engine:ship = ship {
                    if engine:flameOut
                    {
                        decouplerEngines[decoupler]:remove(engine).
                    }
                } else {
                    decouplerEngines[decoupler]:remove(engine).
                }
            }
        } else {
            decouplerEngines:remove(decoupler).
        }
    }
    
    if stage:ready
    {
        for decoupler in decouplerEngines:keys
        {
            if decouplerEngines[decoupler]:length = 0
            {
                decouplerEngines:remove(decoupler).
                
                if stage:number > decoupler:stage
                {
                    if decoupler:hasParent and decoupler:parent:modules:contains("ModuleEngines") and (decoupler:parent:stage = decoupler:stage - 1)
                    {
                        local stageTime is time:seconds + stageDelay.
                        local targetStage is decoupler:parent:stage.
                        when time:seconds > stageTime then {
                            if stage:number > targetStage {
                                stage.
                            }
                        }
                    }
                    stage.
                    break.
                }
            }
        }
    }

    return stage:number > 0.
}.

import("toggle-background-gui")(tick@, "Auto-Stage", false, "", true).
