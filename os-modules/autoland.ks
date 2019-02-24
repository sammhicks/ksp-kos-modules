@lazyGlobal off.

parameter import, declareExport.

local vesselRadius is import("vessel-radius").

local safeVelocityStartHeight is 200 + vesselRadius.

local safeVelocityMaxThrustHeight is 10 + vesselRadius.

local finalDescentHeight is 50 + vesselRadius.

local minSpeedHeight is vesselRadius.

local maxSpeedHeight is finalDescentHeight.

local minSpeed is -0.2.

local maxSpeed is -5.

local rcsCorrectionVelocity is 10.

local function radarAltitude {
    return altitude - max(0, ship:geoPosition:terrainHeight).
}

local function upAcc {
    return (ship:availablethrust * (ship:facing:forevector * ship:up:forevector) / ship:mass) - ship:sensors:grav:mag.
}

local function suicideBurnDistance {
    return (verticalspeed * verticalspeed) / (2 * upAcc()).
}

local function suicideBurnAltitude {
    return radarAltitude() - suicideBurnDistance().
}

local function clamp {
    parameter t, a, b.
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
        lock steering to lookDirUp(rcsCorrectionVelocity * ship:up:forevector - ship:velocity:surface, ship:facing:topVector).
        if (verticalspeed > 0) or (suicideBurnAltitude() > safeVelocityStartHeight) {
            rcs off.
            set ship:control:mainthrottle to 0.
        } else {
            rcs on.
            set ship:control:top to - (ship:velocity:surface * ship:facing:topVector).
            set ship:control:starboard to - (ship:velocity:surface * ship:facing:starVector).
            if radarAltitude() > finalDescentHeight {
                set ship:control:mainthrottle to (suicideBurnAltitude() - safeVelocityStartHeight) / (safeVelocityMaxThrustHeight - safeVelocityStartHeight).
            } else {
                set gear to true.
                local zeroThrottle is ship:sensors:grav:mag / (ship:availablethrust * (ship:facing:vector * ship:up:vector) / ship:mass).
                local targetVerticalSpeed is (maxSpeed - minSpeed) * clamp((radarAltitude() - minSpeedHeight) / (maxSpeedHeight - minSpeedHeight), 0, 1) + minspeed.
                set ship:control:mainthrottle to zeroThrottle - (1 - zeroThrottle) * (verticalSpeed - targetVerticalSpeed) / 2.
            }
        }
        return true.
    }
}

local function onEnabledChanged {
    parameter enabled.

    if not enabled  {
        unlock throttle.
        set ship:control:mainthrottle to 0.
        unlock steering.
        set ship:control:top to 0.
        set ship:control:starboard to 0.
    }
}

local gui is import("gui")("Auto-Land").

local update is import("toggle-background-gui")(tick@, gui, "", false, onEnabledChanged@).

declareExport(update).
