@lazyGlobal off.

parameter import, declareExport.

local window is GUI(480, 0).

declareExport({
    parameter name.
    parameter hasShowHide.
    parameter onHeader is { parameter layout. }.

    local sectionBox is window:addVBox().

    local headerLayout is sectionBox:addHLayout().

    local toggle is headerLayout:addCheckBox("Hide", true).

    local title is headerLayout:addLabel(name).
    set title:style:align to "CENTER".

    onHeader(headerLayout).

    local mainLayout is sectionBox:addVLayout().

    set toggle:onToggle to {
        parameter on.

        set mainLayout:visible to on.

        if on {
            set toggle:text to "Hide".
        } else {
            set toggle:text to "Show".
        }
    }.

    window:show().

    if not hasShowHide {
        set toggle:visible to false.
    }

    return mainLayout.
}).
