@lazyGlobal off.

parameter import, declareExport.

local function apocenter {
    parameter theOrbit.
    
    return (1 + theOrbit:eccentricity) * theOrbit:semiMajorAxis.
}

local function pericenter {
    parameter theOrbit.
    
    return (1 - theOrbit:eccentricity) * theOrbit:semiMajorAxis.
}

local function orbitalSpeed {
    parameter orbitalBody.
    // The extremity of the orbit (apoapsis or periapsis) which you want to know the speed at
    parameter thisExtremity.
    // The other extremity
    parameter otherExtremity.
    
    return sqrt(2 * orbitalBody:mu * (1/thisExtremity - 1/(thisExtremity+otherExtremity))).
}

local function addNode {
    parameter nodeTime.
    parameter nodeSpeed.

    if career():canMakeNodes {
        add node(nodeTime, 0, 0, nodeSpeed).
    } else {
        hudText("Cannot add Node!", 3, 2, 32, red, false).
    }
}

local function setApocenter {
    parameter newApocenter.
    
    local targetSpeed is orbitalSpeed(body, pericenter(obt), newApocenter).
    local pericenterSpeed is orbitalSpeed(body, pericenter(obt), apocenter(obt)).
    
    addNode(time:seconds + eta:periapsis, targetSpeed - pericenterSpeed).
}

local function setPericenter {
    parameter newPericenter.
    
    local targetSpeed is orbitalSpeed(body, apocenter(obt), newPericenter).
    local apocenterSpeed is orbitalSpeed(body, apocenter(obt), pericenter(obt)).
    
    addNode(time:seconds + eta:apoapsis, targetSpeed - apocenterSpeed).
}

local function circularizeAtApo {
    setPericenter(apocenter(obt)).
}

local function circularizeAtPeri {
    setApocenter(pericenter(obt)).
}

local function setPeriod {
    parameter ratio.
    
    if eta:periapsis > eta:apoapsis {
        setPericenter((ratio^(2/3)) * (2 * obt:semiMajorAxis) - apocenter(obt)).
    } else {
        setApocenter((ratio^(2/3)) * (2 * obt:semiMajorAxis) - pericenter(obt)).
    }
}

local gui is import("gui")("Orbit", false).

local newNumField is import("num-field").

local background is import("background").

{
    local box is gui:addHLayout().

    local currentApocenterLabel is box:addLabel("").

    background({
        set currentApocenterLabel:text to floor(apocenter(obt)):toString().

        return true.
    }).

    local newApocenter is 0.

    local newApocenterField is newNumField(box, {
        parameter newValue.

        set newApocenter to newValue.
    }, newApocenter)[0].

    local setApocenterButton is box:addButton("Set Apocenter").

    set setApocenterButton:onClick to {
        setApocenter(newApocenter).
    }.
}

{
    local box is gui:addHLayout().

    local currentPericenterLabel is box:addLabel("").

    background({
        set currentPericenterLabel:text to floor(pericenter(obt)):toString().

        return true.
    }).

    local newPericenter is 0.

    local newPericenterField is newNumField(box, {
        parameter newValue.

        set newPericenter to newValue.
    }, newPericenter)[0].

    local setPericenterButton is box:addButton("Set Pericenter").

    set setPericenterButton:onClick to {
        setPericenter(newPericenter).
    }.
}

{
    local box is gui:addHLayout().

    set box:addButton("Circularize at Apocenter"):onClick to circularizeAtApo@.

    set box:addButton("Circularize at Pericenter"):onClick to circularizeAtPeri@.
}

{
    local newPeriod is 0.

    local box is gui:addHLayout().

    local newPeriodField is newNumField(box, {
        parameter newValue.

        set newPeriod to newValue.
    }, newPeriod)[0].

    local setPeriodButton is box:addButton("Set Period").

    set setPeriodButton:onClick to {
        setPeriod(newPeriod).
    }.
}
