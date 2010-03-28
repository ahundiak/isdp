/*
Name
        trans_ele.h

Description
        This file refers to IPtype5.h, a header file "borrowed" from
        InterPlot.  It used to directly contain the type 5 structure now
        defined in IPtype5.h, but to keep the lines of division cleaner, the
        file is now delivered unchanged from the way InterPlot delivers it to
        GRNUC.

History
        mrm     02/17/92    incorporated latest version from InterPlot
*/

#ifndef trans_ele_include
#include "IPtypes.h"
#include "IPtype5.h"
typedef IPPlotT5 Trans_ele;
#endif
