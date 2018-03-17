@lazyGlobal off.

parameter import, declareExport.

local vesselRadius is import("vessel-radius").

local safeVelocityStartHeight is 200 + vesselRadius.

local safeVelocityMaxThrustHeight is 10 + vesselRadius.

local finalDescentHeight is 50 + vesselRadius.

local safeVelocity is 4.

local freefallVelocity is 2.

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
                set ship:control:mainthrottle to (freefallVelocity + verticalspeed) / (freefallVelocity - safeVelocity).
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
