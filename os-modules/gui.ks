@lazyGlobal off.

parameter import, declareExport.

local window is GUI(480, 0).

declareExport({
    parameter name.

    local sectionBox is window:addVBox().

    local titleLayout is sectionBox:addHLayout().

    local toggle is titleLayout:addCheckBox("", true).

    local title is titleLayout:addLabel(name).
    set title:style:align to "CENTER".

    local mainLayout is sectionBox:addVLayout().

    set toggle:onToggle to {
        parameter on.

        set mainLayout:visible to on.
    }.

    window:show().

    return mainLayout.
}).
