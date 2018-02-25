@lazyGlobal off.

parameter import, declareExport.

local background is import("background").

declareExport({
    parameter action.
    parameter notifyEnabledChanged.
    parameter startsEnabled is false.

    local enabled is false.

    local function tick {
        if enabled {
            local stillAlive is action().

            if not stillAlive {
                disable().
            }

            return stillAlive.
        } else {
            return false.
        }
    }

    local function enable {
        set enabled to true.
        background(tick@).
        notifyEnabledChanged(true).
    }

    local function disable {
        set enabled to false.
        notifyEnabledChanged(false).
    }

    if startsEnabled {
        enable().
    } else {
        disable().
    }

    local function update {
        parameter newValue.

        if newValue {
            if not enabled {
                enable().
            }
        } else {
            if enabled {
                disable().
            }
        }
    }

    return update@.
}).