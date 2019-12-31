@lazyGlobal off.

parameter import, declareExport.

local function sign {
    parameter n.
    if n > 0 {
        return 1.
    }

    if n < 0 {
        return -1.
    }

    return 0.
}

local velocityProportion is 0.5.

local velocityOffset is 0.

local rollSpeed is 45.

local rcsHSpeed is 10.

local rcsVSpeed is 2.

local rcsLimit is 3.

local angleLimit is 1.

local homingAcc is 0.1.

local function calculateHomingVelocity {
    parameter axis.

    if not hasTarget {
        return 0.
    }

    local offset is target:position * axis.

    return sign(offset) * sqrt(2 * homingAcc * abs(offset)).
}

local function calculateVelocityOffset {
    parameter pilotInput.
    parameter axis.

    return pilotInput * rcsHSpeed + calculateHomingVelocity(axis) - ship:velocity:surface * axis.
}

local brakeTime is 5.

local function calculateAngle {
    parameter velocityOffset.

    if abs(velocityOffset) < angleLimit {
        return 0.
    }

    return arctan2(velocityOffset / brakeTime, ship:sensors:grav:mag).
}

local thrustDirection is import("thrust-direction").

local function totalThrust {
    local allEngines is list().

    local thrust is V(0, 0, 0).

    list engines in allEngines.

    for engine in allEngines {
        set thrust to thrust + engine:availableThrust * thrustDirection(engine).
    }

    return thrust.
}

local function tick {
    if ship:availablethrust = 0 {
        return false.
    } else if ship:status = "DOCKED" {
        return false.
    } else if (not hasTarget) and velocityOffset <= 0 and (ship:status = "LANDED" or ship:status = "SPLASHED") {
        return false.
    } else {
        local zeroThrottle is ship:sensors:grav:mag / ((totalThrust() * ship:up:vector) / ship:mass).
        local targetSpeed is rcsVSpeed * ship:control:pilotFore + velocityOffset.
        set ship:control:mainthrottle to zeroThrottle - velocityProportion * (1 - zeroThrottle) * (verticalSpeed - targetSpeed).

        sas off.
        rcs on.

        local starSpeedOffset is calculateVelocityOffset(ship:control:pilotYaw, ship:facing:starVector).
        local upSpeedOffset is calculateVelocityOffset(ship:control:pilotPitch, ship:facing:upVector).

        local starSpeedAngle is calculateAngle(starSpeedOffset).
        local upSpeedAngle is calculateAngle(upSpeedOffset).

        local rotVector is starSpeedAngle * ship:facing:upVector - upSpeedAngle * ship:facing:starVector.

        local targetDirection is angleAxis(rotVector:mag, rotVector) * ship:up:vector.

        lock steering to lookDirUp(targetDirection, angleAxis(ship:control:pilotRoll * rollSpeed, ship:facing:vector ) * ship:facing:upVector).

        if (abs(starSpeedOffset) < rcsLimit) {
            set ship:control:starboard to starSpeedOffset.
        } else {
            set ship:control:starboard to 0.
        }

        if (abs(upSpeedOffset) < rcsLimit) {
            set ship:control:top to upSpeedOffset.
        } else {
            set ship:control:top to 0.
        }
        
        return true.
    }
}

local mutex is import("mutex")("shipcontrol").

local function onEnabledChanged {
    parameter enabled.

    if enabled {
        mutex["claim"]().
        lock throttle to 0.
    } else {
        unlock throttle.
        unlock steering.
        set ship:control:mainthrottle to 0.
        set ship:control:top to 0.
        set ship:control:starboard to 0.
        sas on.

        SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
    }
}

local tbg is import("toggle-background-gui")(tick@, "Auto-Hover", true, "", false, onEnabledChanged@).

mutex["register"]({ tbg:update(false). }).

local createSlider is import("create-slider").

createSlider(tbg:gui, "Velocity Offset", velocityOffset, -5, 5, {parameter value. set velocityOffset to value.}).
createSlider(tbg:gui, "RCS H Speed", rcsHSpeed, 0.1, 20, {parameter value. set rcsHSpeed to value.}).
createSlider(tbg:gui, "RCS V Speed", rcsVSpeed, 0.1, 10, {parameter value. set rcsVSpeed to value.}).
