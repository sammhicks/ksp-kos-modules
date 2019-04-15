@lazyGlobal off.

// The name of the directory where modules are stored
local moduleDirectory is "os-modules".

// The name of the directory where configurations are stored
local configDirectory is "os-config".

local backgroundTasks is Queue().

local onReadyActions is Queue().

local exports is Lexicon("background", {
    parameter backgroundTask.

    backgroundTasks:push(backgroundTask).
}, "on-ready", {
    parameter action.

    onReadyActions:push(action).
}).

local function declareExport {
    parameter module, export.

    exports:add(module, export).
}

local function importModule {
    parameter isConfig.
    parameter srcDirectory, destDirectory.
    parameter module.
    
    if exports:haskey(module) {
        return exports[module].
    }

    local modulePath is Path(volume()):combine(destDirectory, module).
    
    if not(exists(modulePath)) {
        print "Copying: " + module.

        local sourcePath is Path(archive):combine(srcDirectory, module).
        
        copyPath(sourcePath, modulePath).
    }

    local importer is importModule@:bind(false, moduleDirectory, moduleDirectory).
    local exporter is declareExport@:bind(module).

    if isConfig {
        runOncePath(modulePath, importer).
    } else {
        runOncePath(modulePath, importer, exporter).
    }

    if exports:haskey(module) {
        return exports[module].
    }
}

if core:tag = "" {
    importModule(true, configDirectory, "", "default").
} else {
    importModule(true, configDirectory, "", core:tag).
}

for action in onReadyActions {
    action().
}

until false {
    if not backgroundTasks:empty {
        local currentTask is backgroundTasks:pop().

        if currentTask() {
            backgroundTasks:push(currentTask).
        }
    }
}
