#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"

   struct GRid                          /* object identifier structure  */
   {
        GRspacenum osnum;               /* space number of object       */
        GRobjid    objid;               /* object id of object          */
   };

struct GRparms                          /*geometric parameters          */
{
        IGRdouble u;                    /* B-spline u parameter         */
        IGRdouble v;                    /* B-spline v parameter         */
        IGRboolean polygon_inx;         /* polygon / curve (surf) flag  *
                                         * 0 - parameter on smooth curve
                                               or surface
                                           1 - parameter on polygon
                                           2 - parameter not on curve
                                                or polygon i.e.,
                                               center of circle
                                           3 - invalid, not set
                                           4 - special parameter on
                                                extension of curve.
                                               parameter is stored in v */
        struct GRid leaf_id;            /* leaf node id if nested geom  */
};


struct EMSimpbndinfo
{
    IGRboolean reverse;         /* reverse vector flag */
    IGRboolean point_in_area;   /* is point in area or hole? */
    IGRdouble uv_point[2];      /* point on surface */
    IGRdouble cht;              /* chord height tolerance */
    IGRdouble veclen;           /* length to move along vector */
    struct GRparms parms;       /* of first boundary at locate point */
};

#template  struct EMSimpbndinfo  EMSimpbndinfo_T



