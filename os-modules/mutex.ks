@lazyGlobal off.

parameter import, declareExport.

local mutexes is Lexicon().

local function registerMutex {
    parameter name.

    local storedRelease is {}.

    local function register {
        parameter release.

        set storedRelease to release.

        if mutexes:hasKey(name) {
            mutexes[name]:add(release).
        } else {
            mutexes:add(name, list(release)).
        }
    }

    local function claim {
        if mutexes:hasKey(name) {
            for release in mutexes[name] {
                if release <> storedRelease {
                    release().
                }
            }
        }
    }

    return lexicon("register", register@, "claim", claim@).
}

declareExport(registerMutex@).
