@lazyGlobal off.

parameter import, declareExport.

local gui is import("gui")("Execute Node").

local directionTolerance is 2.

local completionTolerance is 0.1.

local windDownTime is 1.
local minimumAcceleration is 1.

local warpTolerance is 5.
local alreadyWarped is false.

local function tick {
    if not hasNode {
        return false.
    }

    local node is nextnode.

    local maximumAcceleration is ship:availableThrust/ship:mass.

    if maximumAcceleration = 0 {
        HUDTEXT("All engines are off!", 3, 2, 30, red, false).

        return false.
    }

    local burnDuration to node:deltav:mag/maximumAcceleration.
    
    lock steering to node:deltav.

    if node:deltav:mag < completionTolerance {
        unlock steering.
        set ship:control:mainThrottle to 0.
        remove node.

        set alreadyWarped to false.

        return true.
    }

    if node:eta > burnDuration/2 {
        if (not alreadyWarped) and (kuniverse:timewarp:rate = 1) and vang(node:deltav, ship:facing:vector) < directionTolerance {
            set alreadyWarped to true.
            kuniverse:timewarp:warpto(time:seconds + node:eta - burnDuration/2 - warpTolerance).
        }

        set ship:control:mainThrottle to 0.
        return true.
    }

    if vang(node:deltav, ship:facing:vector) > directionTolerance {
        set ship:control:mainThrottle to 0.
        return true.
    }

    if burnDuration > windDownTime {
        set ship:control:mainThrottle to 1.
        return true.
    }

    set ship:control:mainThrottle to minimumAcceleration/maximumAcceleration + (burnDuration / windDownTime).

    return true.
}

local function notifyEnableChanged {
    parameter enabled.

    set alreadyWarped to false.
}

local update is import("toggle-background-gui")(tick@, gui, "", false, notifyEnableChanged@).

declareExport(update).
