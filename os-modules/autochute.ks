@lazyGlobal off.

parameter import, declareExport.

local function tick {
    if (not chutesSafe) {
        chutesSafe ON.
    }

    return (not chutes).
}

import("toggle-background-gui")(tick@, "Auto-Chute").
