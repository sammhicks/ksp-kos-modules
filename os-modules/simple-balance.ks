@lazyGlobal off.

parameter import, declareExport.

local thrustDirection is import("thrust-direction").

local function engineTorque {
    parameter engine.

    return vectorCrossProduct(engine:position(), engine:maxThrust * thrustDirection(engine)).
}

local function tick {
    local allEngines is list().

    local totalTorque is V(0, 0, 0).

    list engines in allEngines.

    for engine in allEngines {
        set totalTorque to totalTorque + engineTorque(engine).
    }

    local forwardsEngines is list().
    local forwardsTorque is V(0, 0, 0).
    local backwardsEngines is list().
    local backwardsTorque is V(0, 0, 0).

    for engine in allEngines {
        local torque is engineTorque(engine).
        if vectordotproduct(torque, totalTorque) > 0 {
            forwardsEngines:add(engine).
            set forwardsTorque to forwardsTorque + torque.
        } else {
            backwardsEngines:add(engine).
            set backwardsTorque to backwardsTorque + torque.
        }
    }

    if (forwardsTorque:mag <> 0) {
        local thrustLimit is 100 * (backwardsTorque:mag) / (forwardsTorque:mag).

        for engine in forwardsEngines {
            set engine:thrustLimit to thrustLimit.
        }

        for engine in backwardsEngines {
            set engine:thrustLimit to 100.
        }
    } else {
        for engine in allEngines {
            set engine:thrustLimit to 100.
        }
    }

    return true.
}

import("toggle-background-gui")(tick@, "Simple-Balance").
