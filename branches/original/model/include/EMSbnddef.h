/*
 * This file will contain the various definitions for the EMS methods
 *
 * ALL OPTIONS SHOULD GO IN THE FILE 'EMSopt.h'.
 * ALL PROPERTIES SHOULD GO IN THE FILE 'EMSprop.h'
 * 
 *
 */

#ifndef EMSbnddef_include
#define EMSbnddef_include 1


/* The point loop will display its point edge with the following weight.
   If the point edge is part of a non degenerate loop, it will display itself
   with the default weight like any other edge. The need to increase the
   weight for point loop display is felt since it exists by
   itself and is difficult to visualize unless prominently displayed. For
   a point edge in a regular loop, there are 2 non degenerate edges meeting
   at the point edge, so this need is not so acute.
*/

#define PointLoopDisplayWeight	3

#define Ulow	0.0
#define Uhigh	1.0
#define Vlow	0.0
#define Vhigh	1.0

/*
 * This factor is used to obtain the basis tolerance in the
 * parametric space (W-space) of a curve described in the UV-space
 * of a surface. The uv-parametric space tolerance is multiplied
 * by this factor to obtain a reasonable approximation of this
 * value.
 */

#define UVPAR_TO_WPAR_FACTOR 100

/*
 * The paramteric space tolerance for any surface should never exceed
 * this limit. That is, parametric tolerance is never coarser than
 * this.
 */

#define EMS_HIGH_UVLENTOL  1e-07
#define EMS_HIGH_UVPLANAR_LENTOL 1e-04


/* Following is a complete set of locations used in part by various
   pt_location methods(loopset/loop/edge).
*/
#define EMS_L_ONEDGE       0
#define EMS_L_ONVRTX       1
#define EMS_L_INAREA       2
#define EMS_L_INHOLE       3
#define EMS_L_INSIDE       4
#define EMS_L_OUTSIDE      5
#define EMS_L_RIGHT        6
#define EMS_L_LEFT         7
#define EMS_L_COLLINEAR    8
#define EMS_L_UNKNWN       9


/* The different types of split locations on an edge
*/
#define BEGIN              0
#define END                1
#define MIDDLE             2
#define UNKNOWN            -3

/* The direction of the splitting edge wrt the the edge being
   split.
*/
#define INCOMING           0
#define OUTGOING           1

/* turning bits on/off
*/
#define ON                 1
#define OFF                0
#define TOGGLE             2


/*
 * The following information is used in clipping
 */

#define EMS_O_Planar		0
#define EMS_O_NonPlanar		1
#define EMS_O_Unknown		2


/* The maximum number of edges that can be located. At a vertex this number
   will be 3 (with a point edge present)
*/

#define MAX_LOCATED_EDGES	3

/* A linear edge will be considered as a candidate for iso check by the
   method 'EMleinit' if it has number of points greater than the follwoing
   water mark.
*/

#define LinearToIsoWaterMark	4

/* The following overlap types are used in stitching.  */

#define EMS_O_begin		0
#define EMS_O_end		1
#define EMS_O_middle		2
#define EMS_O_adjacent		3
#define EMS_O_unknown		-1


#define EMSedge_Split		0x001
#define EMSedge_BeginSplit	0x002
#define EMSedge_EndSplit	0x004

/*
 * Options that drive EMmapcvxyz_to_uv
 */

#define  EMS_RMED_ALNG_NATBDRY    0x0001 /* Option to remove edges along
                                            natural boundary */
#define  EMS_TRIM_AGAINST_NATBDRY 0x0002 /* Option will check and truncate
                                            uv-output at natural boundary */

#endif
