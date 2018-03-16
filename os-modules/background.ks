@lazyGlobal off.

parameter import, declareExport.

local backgroundTasks is Queue().

local function backgroundTick {
    if not backgroundTasks:empty {
        local currentTask is backgroundTasks:pop().

        if currentTask() {
            backgroundTasks:push(currentTask).
        }
    }
    
    return true.
}.

declareExport({
    parameter backgroundTask.

    backgroundTasks:push(backgroundTask).
}).

when true then {
    backgroundTick().
    return true.
}.
