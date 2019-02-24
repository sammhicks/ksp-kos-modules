@lazyGlobal off.

parameter import, declareExport.

local window is GUI(480, 0).

declareExport({
    parameter name.

    local box is window:addVBox().

    local label is box:addLabel(name).

    set label:style:align to "CENTER".

    window:show().

    return box.
}).
