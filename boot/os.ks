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
    parameter isConfig.
    parameter srcDirectory, destDirectory.
    parameter module.
    
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

wait until false.
