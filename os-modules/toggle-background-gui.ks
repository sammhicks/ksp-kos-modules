@lazyGlobal off.

parameter import, declareExport.

local toggleBackground is import("toggle-background").

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

    local update is toggleBackground(tick@, onEnabledChanged@, saveState[0](name, startEnabled)).

    set controlButton:onToggle to update.

    return List(gui, update).
}).
