@lazyGlobal off.

parameter import, declareExport.

local function tick {
    if (not chutesSafe) {
        chutesSafe ON.
    }

    return (not chutes).
}

local gui is import("gui")("Auto-Chute").

local update is import("toggle-background-gui")(tick@, gui).

declareExport(update).
