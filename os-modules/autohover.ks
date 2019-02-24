@lazyGlobal off.

parameter import, declareExport.

local safeVelocity is -2.

local velocityOffset is 0.

local rcsSpeed is 2.

local function tick {
    if ship:status = "LANDED" OR ship:status = "SPLASHED" {
        set ship:control:mainthrottle to 0.
        return false.
    } else {
        if ship:availablethrust = 0 {
            return false.
        }
        local zeroThrottle is ship:sensors:grav:mag / (ship:availablethrust * (ship:facing:vector * ship:up:vector) / ship:mass).
        local targetSpeed is rcsSpeed * ship:control:pilotFore + velocityOffset.
        set ship:control:mainthrottle to (1 - zeroThrottle) * (verticalSpeed - targetSpeed) / safeVelocity + zeroThrottle.

        sas off.
        lock steering to lookDirUp(ship:up:vector, vectorExclude(ship:up:vector, ship:facing:upVector)).

        rcs on.
        set ship:control:top to ship:control:pilotTop - (ship:velocity:surface * ship:facing:topVector) / rcsSpeed.
        set ship:control:starboard to ship:control:pilotStarboard - (ship:velocity:surface * ship:facing:starVector) / rcsSpeed.
        
        return true.
    }
}

local mutex is import("mutex")("shipcontrol").

local function onEnabledChanged {
    parameter enabled.

    if enabled {
        mutex["claim"]().
    } else {
        unlock throttle.
        unlock steering.
        set ship:control:mainthrottle to 0.
        set ship:control:top to 0.
        set ship:control:starboard to 0.
        sas on.
    }
}

local gui is import("gui")("Auto-Hover").

local update is import("toggle-background-gui")(tick@, gui, "", false, onEnabledChanged@).

mutex["register"]({ update(false). }).

{
    local box is gui:addHBox().

    box:addLabel("Velocity Offset").

    local sliderBox is box:addVBox().

    local slider is sliderBox:addHSlider(velocityoffset, -5, 5).

    local label is sliderBox:addLabel().

    local function updateLabelText {
        set label:text to round(velocityOffset, 2):toString.
    }

    updateLabelText().

    set slider:onChange to {
        parameter newValue.

        set velocityOffset to newValue.
        updateLabelText().
    }.

    local button is box:addButton("Reset").

    local initialValue is slider:value.

    set button:onClick to {
        set slider:value to initialValue.
    }.
}

{
    local box is gui:addHBox().

    box:addLabel("RCS Speed").

    local sliderBox is box:addVBox().

    local slider is sliderBox:addHSlider(rcsSpeed, 0.1, 5).

    local label is sliderBox:addLabel().

    local function updateLabelText {
        set label:text to round(rcsSpeed, 2):toString.
    }

    updateLabelText().

    set slider:onChange to {
        parameter newValue.

        set rcsSpeed to newValue.
        updateLabelText().
    }.

    local button is box:addButton("Reset").

    local initialValue is slider:value.

    set button:onClick to {
        set slider:value to initialValue.
    }.
}

declareExport(update).
