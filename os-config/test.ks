@lazyGlobal off.

parameter import.

deletePath("1:/os-modules").
clearGuis().
clearvecdraws().

// import("autobalance").

import("autohover").
import("autoland").

local gui is import("gui")("Reset").

local button is gui:addButton("Reset").

set button:onClick to {
    deletePath("1:/test").
    reboot.
}.
