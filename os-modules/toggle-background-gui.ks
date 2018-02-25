@lazyGlobal off.

parameter import, declareExport.

local toggleBackground is import("toggle-background").

declareExport({
    parameter tick.
    parameter gui.
    parameter text is "Enabled".
    parameter startEnabled is false.
    parameter notifyEnableChanged is {parameter newEnabled.}.

    local controlButton is gui:addCheckbox(text, false).

    local function onEnabledChanged {
        parameter enabled.

        set controlButton:pressed to enabled.

        notifyEnableChanged(enabled).
    }.

    local update is toggleBackground(tick@, onEnabledChanged@, startEnabled).

    set controlButton:onToggle to update.

    return update.
}).