#eofifdef EMShorizon_include
#define EMShorizon_include

#include "EMSbnd.h"

struct EMShorizon_info
{
    OM_S_OBJID          edge_id;
    int                 classification;
    struct EMSedgebound edbdry[2];
};
