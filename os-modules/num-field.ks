@lazyGlobal off.

parameter import, declareExport.

declareExport({
    parameter gui.
    parameter notify is {
        parameter newValue.
    }.
    parameter initialValue is 0.

    local textField is gui:addTextField("").

    local currentValue is initialValue.

    local function updateText {
        set textField:text to currentValue:toString().
        notify(currentValue).
    }

    local function updateValue {
        parameter newValue.

        if currentValue <> newValue {
            set currentValue to newValue.
            updateText().
        }
    }

    local function textChanged {
        parameter newText.

        updateValue(newText:toNumber(currentValue)).
    }

    set textField:onchange to textChanged@.

    updateText().

    return list(textField, updateValue@).
}).
