@lazyGlobal off.

parameter import, declareExport.

local background is import("background").

local saveState is import("save-state").

local defaultText is "Enabled".

declareExport({
    parameter tick.
    parameter name.
    parameter hasShowHide is false.
    parameter text is "".
    parameter startEnabled is false.
    parameter notifyEnableChanged is {parameter newEnabled.}.

    if text = "" {
        set text to defaultText.
    }

    local controlButton is false.

    local gui is import("gui")(name, hasShowHide, {
        parameter header.

        set controlButton to header:addCheckbox(text, false).
    }).

    local function onEnabledChanged {
        parameter enabled.

        set controlButton:pressed to enabled.

        saveState[1](name, enabled).

        notifyEnableChanged(enabled).
    }.

    local isEnabled is saveState[0](name, startEnabled).
    set controlButton:pressed to isEnabled.

    background({
        if controlButton:pressed <> isEnabled {
            set isEnabled to controlButton:pressed.
            saveState[1](name, isEnabled).

            notifyEnableChanged(isEnabled).
        }

        if isEnabled {
            local isStillEnabled is tick().
            if not isStillEnabled {
                set controlButton:pressed to false.
            }
        }

        return true.
    }).

    return Lexicon(
        "gui", gui,
        "update", {
            parameter newEnabled.
            set controlButton:pressed to newEnabled.
        }
    ).
}).
