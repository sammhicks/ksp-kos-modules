@lazyGlobal off.

parameter import, declareExport.

declareExport({
    parameter parent.
    parameter name.
    parameter initialValue, minValue, maxValue.
    parameter onUpdate.

    local box is parent:addHLayout().

    set box:addLabel(name):style:width to 100.

    local sliderBox is box:addVLayout().

    local slider is sliderBox:addHSlider(initialValue, minValue, maxValue).

    local label is sliderBox:addLabel().

    set label:style:align to "CENTER".

    local function updateLabelText {
        parameter value.
        set label:text to round(value, 2):toString.
    }

    updateLabelText(initialValue).

    set slider:onChange to {
        parameter newValue.

        updateLabelText(newValue).
        onUpdate(newValue).
    }.

    local button is box:addButton("Reset").

    set button:style:width to 64.

    set button:onClick to {
        set slider:value to initialValue.
    }.
}).
