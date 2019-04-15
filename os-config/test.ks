@lazyGlobal off.

parameter import.

deletePath("1:/os-modules").
clearGuis().
clearvecdraws().

import("simple-balance").

import("autohover").
import("autoland").

local gui is import("gui")("Reset", false).

local button is gui:addButton("Reset").

set button:onClick to {
    deletePath("1:/test").
    reboot.
}.
