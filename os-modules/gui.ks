@lazyGlobal off.

parameter import, declareExport.

local gui is GUI(320, 0).

declareExport({
    parameter name.

    local box is gui:addVBox().

    local label is box:addLabel(name).

    set label:style:align to "CENTER".

    gui:show().

    return box.
}).