@lazyGlobal off.

parameter import, declareExport.

local decouplerEngines is Lexicon().
local stageDelays is Queue().
local stageDelayTargetStages is Queue().

local theEngines is List().

list engines in theEngines.

for currentEngine in theEngines {
    from { local currentPart is currentEngine. } until not currentPart:hasParent step { set currentPart TO currentPart:parent. } do {
        if (currentEngine:stage <> currentPart:stage) and (currentPart:modules:contains("ModuleDecouple") or currentPart:modules:contains("ModuleAnchoredDecoupler")) {
            if not decouplerEngines:hasKey(currentPart) {
                set decouplerEngines[currentPart] to lexicon().
            }
            
            decouplerEngines[currentPart]:add(currentEngine, 0).
        }
    }
}

local function tick {
    for decoupler in decouplerEngines:keys
    {
        for engine in decouplerEngines[decoupler]:keys
        {
            if engine:flameOut
            {
                decouplerEngines[decoupler]:remove(engine).
            }
        }
    }
    
    if stage:ready
    {
        for decoupler in decouplerEngines:keys
        {
            if decouplerEngines[decoupler]:length = 0
            {
                decouplerEngines:remove(decoupler).
                
                if decoupler:stage < stage:number
                {
                    if decoupler:hasParent and decoupler:parent:modules:contains("ModuleEngines") and (decoupler:parent:stage = decoupler:stage - 1)
                    {
                        stageDelays:push(time:seconds + 3).
                        stageDelayTargetStages:push(decoupler:parent:stage).
                    }
                    stage.
                    break.
                }
            }
        }
    }
    
    if stage:ready and not stageDelays:empty
    {
        if time:seconds > stageDelays:peek()
        {
            stageDelays:pop().
            if stage:number > stageDelayTargetStages:pop()
            {
                stage.
            }
        }
    }

    return stage:number > 0.
}.

local gui is import("gui")("Auto-Stage").

local update is import("toggle-background-gui")(tick@, gui, "Enabled", true).

declareExport(update).
