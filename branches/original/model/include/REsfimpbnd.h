#ifndef REsfimpbnd_include
#define REsfimpbnd_include 1

/*
  This include file contains the recomputation information and type 
  definition for the class EMSsfimpbnd. Please make sure when adding types
  to see that the same have not been defined at a parent level. 

  EMS_ASno_type           0
  EMS_ASimpbnd_w_track_pt 1

History:
 DLB: 06/29/92 : Added track pt support.
 PP : 11/4/91  : Trying to make some sense of the info spread out in 
                 different include files.
*/

/* Impose Surface Boundary recomputation info */

/* For EMS_ASno_type 0 & w_track_pt*/

#define EMS_ASsfimpbnd_w_track_pt 1

struct EMSimpbndinfo
{
    IGRboolean reverse;         /* reverse vector flag */
    IGRboolean point_in_area;   /* is point in area or hole? */
    IGRdouble uv_point[2];      /* point on surface */
    IGRdouble cht;              /* chord height tolerance */
    IGRdouble veclen;           /* length to move along vector */
    struct GRparms parms;       /* of first boundary at locate point */
};

/* Impose Surface Boundary info to pass back to the command object */

struct EMSimpbndcmd
{
    IGRlong *npoints;
    IGRpoint **points;
    IGRlong *nbadcurves;
    IGRlong *badcurves;
};
#endif
