@lazyGlobal off.

parameter import, declareExport.

local radius is 0.

local currentStage is stage:number.

local function updateRadius {
    set radius to 0.

    for part in ship:parts {
        set radius to max(radius, (part:position - ship:rootPart:position):mag).
    }

    set currentStage to stage:number.

    print "Vessel Radius: " + radius.
}

updateRadius().

declareExport({
    if currentStage <> stage:number {
        updateRadius().
    }

    return radius.
}).
