@lazyGlobal off.

parameter import, declareExport.

local spaceSituations is list("SUB_ORBITAL", "ORBITING", "ESCAPING", "DOCKED").

local function inSpace {
    parameter situation.

    return spaceSituations:contains(situation).
}

local currentStatus is "".

local function tick {
    local newStatus is status.

    if inSpace(newStatus) and not inSpace(currentStatus) {
        TOGGLE AG9.
    }

    if not inSpace(newStatus) and inSpace(currentStatus) {
        TOGGLE AG10.
    }

    set currentStatus to newStatus.

    return true.
}

local function notifyEnableChanged {
    parameter enabled.

    if enabled {
        local newStatus is status.

        if inSpace(newStatus) {
            TOGGLE AG9.
        } else {
            TOGGLE AG10.
        }

        set currentStatus to newStatus.
    }
}

local gui is import("gui")("Auto-Deploy").

local update is import("toggle-background-gui")(tick@, gui, "", true, notifyEnableChanged@).

declareExport(update).
