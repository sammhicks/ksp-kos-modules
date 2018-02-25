@lazyGlobal off.

parameter import, declareExport.

local radius is 0.

for part in ship:parts {
    set radius to max(radius, (part:position - ship:rootPart:position):mag).
}

print "Vessel Radius: " + radius.

declareExport(radius).
