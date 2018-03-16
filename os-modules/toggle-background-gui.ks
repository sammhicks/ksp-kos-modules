@lazyGlobal off.

parameter import, declareExport.

local toggleBackground is import("toggle-background").

local saveState is import ("save-state").

declareExport({
    parameter tick.
    parameter gui.
    parameter text is "Enabled".
    parameter startEnabled is false.
    parameter notifyEnableChanged is {parameter newEnabled.}.

    local name is gui:widgets[0]:text.

    local controlButton is gui:addCheckbox(text, false).

    local function onEnabledChanged {
        parameter enabled.

        set controlButton:pressed to enabled.

        saveState[1](name, enabled).

        notifyEnableChanged(enabled).
    }.

    local update is toggleBackground(tick@, onEnabledChanged@, saveState[0](name, startEnabled)).

    set controlButton:onToggle to update.

    return update.
}).
