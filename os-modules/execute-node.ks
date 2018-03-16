@lazyGlobal off.

parameter import, declareExport.

local gui is import("gui")("Execute-Node").

local function tick {
    if not hasNode {
        return false.
    }

    local nd is nextnode.

    local maxAcc is ship:maxthrust/ship:mass.

    local burnDuration to nd:deltav:mag/maxAcc.

    if nd:eta > burnDuration/2 + 60 {
        return true.
    }
    
    lock steering to nd:deltav.

    if (nd:eta > burnDuration/2) or (vang(nd:deltav, ship:facing:vector) > 0.25) {
        return true.
    }
    
    if nd:deltav:mag > 0.1 {
        
    }
}

local update is import("toggle-background-gui")(tick@, gui).

declareExport(update).
