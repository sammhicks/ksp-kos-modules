@lazyGlobal off.

parameter import, declareExport.

declareExport({
    parameter engine.

    if engine:name = "KKAOSS.engine.g" {
        return engine:facing:upVector.
    }

    return engine:facing:vector.
}).
