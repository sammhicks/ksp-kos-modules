@lazyGlobal off.

parameter import, declareExport.

local getVesselRadius is import("vessel-radius").

local safeVelocityStartHeight is 500.

local safeVelocityMaxThrustHeight is 100.

local finalDescentHeight is 150.

local lock minSpeedHeight to getVesselRadius().

local maxSpeedHeight is finalDescentHeight.

local minLandSpeed is 0.1.

local maxLandSpeed is 10.

local initialLandSpeed is 0.5.

local rcsCorrectionVelocity is 10.

local function radarAltitude {
    return altitude - max(0, ship:geoPosition:terrainHeight).
}

local thrustDirection is import("thrust-direction").

local function totalThrust {
    local allEngines is list().

    local thrust is V(0, 0, 0).

    list engines in allEngines.

    for engine in allEngines {
        set thrust to thrust + engine:availableThrustAt(body:atm:seaLevelPressure) * thrustDirection(engine).
    }

    return thrust.
}

local function upAcc {
    return (totalThrust() * ship:up:foreVector) / ship:mass.
}

local function suicideBurnDistance {
    return (verticalSpeed ^ 2) / (2 * (upAcc() - ship:sensors:grav:mag )).
}

local function suicideBurnAltitude {
    return radarAltitude() - suicideBurnDistance().
}

local function clamp {
    parameter t.
    parameter a is 0.
    parameter b is 1.

    if t < a {
        return a.
    }

    if t > b {
        return b.
    }

    return t.
}

local function tick {
    if ship:status = "LANDED" OR ship:status = "SPLASHED" {
        return false.
    } else {
        sas off.
        lock steering to lookDirUp(rcsCorrectionVelocity * ship:up:foreVector - ship:velocity:surface, ship:facing:topVector).
        if ship:facing:foreVector * ship:up:foreVector < 0 {
            rcs on.
            set ship:control:mainThrottle to 0.
        } else if upAcc() < ship:sensors:grav:mag {
            rcs off.
            set ship:control:mainThrottle to 1.
        } else if (verticalSpeed > 0) or (suicideBurnAltitude() > safeVelocityStartHeight) {
            rcs off.
            set ship:control:mainThrottle to 0.
        } else {
            rcs on.
            set ship:control:top to - (ship:velocity:surface * ship:facing:topVector).
            set ship:control:starboard to - (ship:velocity:surface * ship:facing:starVector).
            if radarAltitude() > finalDescentHeight {
                local targetAcc is (verticalSpeed ^ 2 - maxLandSpeed ^ 2) / (2 * (radarAltitude() - finalDescentHeight)).

                set ship:control:mainThrottle to (targetAcc + ship:sensors:grav:mag) / upAcc().
            } else {
                set gear to true.
                local zeroThrottle is ship:sensors:grav:mag / ((totalThrust() * ship:up:vector) / ship:mass).
                local targetDownSpeed is (maxLandSpeed - minLandSpeed) * clamp((radarAltitude() - minSpeedHeight) / (maxSpeedHeight - minSpeedHeight)) + minLandSpeed.
                set ship:control:mainThrottle to zeroThrottle - (1 - zeroThrottle) * (verticalSpeed + targetDownSpeed) / 2.
            }
        }
        return true.
    }
}

local mutex is import("mutex")("shipcontrol").

local function onEnabledChanged {
    parameter enabled.

    if enabled {
        mutex["claim"]().
    } else {
        set ship:control:mainThrottle to 0.
        set ship:control:top to 0.
        set ship:control:starboard to 0.
        SET SHIP:CONTROL:NEUTRALIZE to TRUE.
        sas on.
        rcs off.
        unlock steering.
    }
}

local guiAndUpdate is import("toggle-background-gui")(tick@, "Auto-Land", true, "", false, onEnabledChanged@).

local gui is guiAndUpdate[0].
local update is guiAndUpdate[1].

mutex["register"]({ update(false). }).

local createSlider is import("create-slider").

createSlider(gui, "Land Speed", initialLandSpeed, minLandSpeed, maxLandSpeed, {parameter value. set minLandSpeed to value.}).

declareExport(update).
