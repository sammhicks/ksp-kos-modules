@lazyGlobal off.

parameter import, declareExport.

local getVesselRadius is import("vessel-radius").

local lock safeVelocityStartHeight to 200 + getVesselRadius().

local lock safeVelocityMaxThrustHeight to 10 + getVesselRadius().

local lock finalDescentHeight to 50 + getVesselRadius().

local lock minSpeedHeight to getVesselRadius().

local lock maxSpeedHeight to finalDescentHeight.

local minLandSpeed is 0.1.

local maxLandSpeed is 5.

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
    return ((totalThrust() * ship:up:foreVector) / ship:mass) - ship:sensors:grav:mag.
}

local function suicideBurnDistance {
    return (verticalSpeed * verticalSpeed) / (2 * upAcc()).
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
        if upAcc() < 0 {
            rcs off.
            set ship:control:mainThrottle to 1.
        } else if (verticalSpeed > 0) or (suicideBurnAltitude() > safeVelocityStartHeight) {
            rcs off.
            set ship:control:mainthrottle to 0.
        } else {
            rcs on.
            set ship:control:top to - (ship:velocity:surface * ship:facing:topVector).
            set ship:control:starboard to - (ship:velocity:surface * ship:facing:starVector).
            if radarAltitude() > finalDescentHeight {
                local throttleScale is clamp(-verticalSpeed / maxLandSpeed).
                set ship:control:mainthrottle to throttleScale * (suicideBurnAltitude() - safeVelocityStartHeight) / (safeVelocityMaxThrustHeight - safeVelocityStartHeight).
            } else {
                set gear to true.
                local zeroThrottle is ship:sensors:grav:mag / ((totalThrust() * ship:up:vector) / ship:mass).
                local targetDownSpeed is (maxLandSpeed - minLandSpeed) * clamp((radarAltitude() - minSpeedHeight) / (maxSpeedHeight - minSpeedHeight)) + minLandSpeed.
                set ship:control:mainthrottle to zeroThrottle - (1 - zeroThrottle) * (verticalSpeed + targetDownSpeed) / 2.
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
        unlock throttle.
        set ship:control:mainthrottle to 0.
        unlock steering.
        set ship:control:top to 0.
        set ship:control:starboard to 0.
        sas on.
    }
}

local guiAndUpdate is import("toggle-background-gui")(tick@, "Auto-Land", true, "", false, onEnabledChanged@).

local gui is guiAndUpdate[0].
local update is guiAndUpdate[1].

mutex["register"]({ update(false). }).

local createSlider is import("create-slider").

createSlider(gui, "Land Speed", initialLandSpeed, minLandSpeed, maxLandSpeed, {parameter value. set minLandSpeed to value.}).

declareExport(update).
