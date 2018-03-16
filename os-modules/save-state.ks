@lazyGlobal off.

parameter import, declareExport.

local fileName is "state.json".

local state is Lexicon().

if exists(fileName) {
    set state to readJSON(fileName).
}

local function loadState {
    parameter name, defaultValue.

    if state:hasKey(name) {
        print "loading state of " + name + ": " + state[name].

        return state[name].
    } else {
        return defaultValue.
    }
}

local function saveState {
    parameter name, value.

    set state[name] to value.

    print "Saving state of " + name + ": " + value.

    writeJSON(state, fileName).
}

declareExport(list(loadState@, saveState@)).
