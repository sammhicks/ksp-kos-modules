@lazyGlobal off.

// The name of the directory where modules are stored
local moduleDirectory is "os-modules".

// The name of the directory where configurations are stored
local configDirectory is "os-config".

local exports is Lexicon().

local function declareExport {
    parameter module, export.

    exports:add(module, export).
}

local function importModule {
    parameter srcDirectory, destDirectory.
    parameter module.
    
    local modulePath is Path(volume()):combine(destDirectory, module).
    
    if not(exists(modulePath)) {
        print "Copying: " + module.

        local sourcePath is Path(archive):combine(srcDirectory, module).
        
        copyPath(sourcePath, modulePath).
    }

    runOncePath(modulePath, importModule@:bind(moduleDirectory, moduleDirectory), declareExport@:bind(module)).

    if exports:haskey(module) {
        return exports[module].
    }
}

if core:tag = "" {
    importModule(configDirectory, "", "default").
} else {
    importModule(configDirectory, "", core:tag).
}

wait until false.
