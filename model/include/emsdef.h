# ifndef emsdef_include
# define emsdef_include

#ifndef PPL
#include <alloca.h>
#endif

/* Note this file and EMSdef.h are mirrors (cause they were
 * merged. The ifndef "XXXX" should be the same in EMSdef.h
 * else people including these two files could end up with double
 * definitions - Shrirang A. Moghe (Oct 11, 1995)
 *
 * The mirrors were made because the NT file system is case 
 * insensitive
 * 
 */

/* The following brought over from emsdef.h (SAM Oct 11, 1995) */

/* Following to be removed if delivered in GRNUC/godef.h
*/
#define GRIS_POST220_OBJECT	0x8000  /* This object has been contructed in 
					   a post 2.2.0 version*/

/*
 * General constants 
 */

#ifndef TRUE
#define TRUE 1
#endif
#ifndef FALSE
#define FALSE 0
#endif
#ifndef NULL
#define NULL 0
#endif
#ifndef MATCH
#define MATCH 0
#endif 
#ifndef _NULL
#define _NULL -1
#endif
#ifndef UNDEFINED
#define UNDEFINED _NULL
#endif 

#define stackalloc(size) alloca(size)
#define stackfree(ptr) ;
#define allocf(ptr) ;

/*
 * These constants are watered down versions of
 * their definitions found in <values.h>.
 */

#ifndef MAXINT
#define MAXINT 0x7fffffff
#endif
#ifndef MAXFLOAT
#define MAXFLOAT 1e+30
#endif
#ifndef MAXDOUBLE
#define MAXDOUBLE 1e+300
#endif
#ifndef MINFLOAT
#define MINFLOAT 1e-30
#endif
#ifndef MINDOUBLE 
#define MINDOUBLE 1e-300
#endif

/*
 * These constants are used for matrix-type, to be understood by the
 * function MAoptsxform, which does the multiply in an optimized fashion
 * if the matrix is somewhat special. These constants were read from
 * MAoptsxform on 07/21/89. Other constants dealing with matrix information
 * are also defined below.
 */

#define MA_MATTYP_TWO_DIM		0
#define MA_MATTYP_TWO_DIM_TRANSLATION	1
#define MA_MATTYP_IDENTITY		2
#define MA_MATTYP_SCALED_IDENTITY	3
#define MA_MATTYP_GENERAL		4
#define MA_MATTYP_TRANSLATION		5
#define MA_MATTYP_SCALED_TRANSLATION	6
#define MA_MATTYP_THREE_DIM		7

#define XORIG_PLANEMAT_INX  3
#define YORIG_PLANEMAT_INX  7
#define ZORIG_PLANEMAT_INX  11

#define XAXIS_PLANEMAT_INX  0
#define YAXIS_PLANEMAT_INX  4
#define ZAXIS_PLANEMAT_INX  8

/*
 * The following constant defines the tolerance on an angle in degrees.
 * An angle with this value can be treated as equal to zero. 
 */

#define EMS_ZEROANGLE_DEG      0.001
#define EMS_ZEROANGLE_DEG_MAX  0.05

/*
 * These constants are used to characterize an EMSpypoint structure. This
 * set of constants classify each point by the type of intersection they
 * represent. The classification is based on the orientation of the element
 * (on which this point resides) w.r.t. another that bounds some area. 
 * Further, the element might intersect the boundary of the area at it's
 * start-point, stop-point or at some point in the middle. Understandably, 
 * within these two classifications there is some mutual exclusion. But it is
 * easier to read or set single bits than a combination.
 */

#define EMS_PYPT_HOLEAREA    0x01      /* The element proceeds from a hole
                                          region into area */
#define EMS_PYPT_AREAHOLE    0x02      /* The element proceeds from an area
                                          region into hole */
#define EMS_PYPT_HOLEHOLE    0x04      /* The element proceeds from a hole
                                          and remains in hole */
#define EMS_PYPT_AREAAREA    0x08      /* The element proceeds from an area
                                          and remains in area */
#define EMS_PYPT_RELUNKNOWN  0x10      /* When the orientation is 
                                          unknown */
#define EMS_PYPT_RELINFOMASK (EMS_PYPT_HOLEAREA | EMS_PYPT_AREAHOLE | \
                              EMS_PYPT_HOLEHOLE | EMS_PYPT_AREAAREA | \
                              EMS_PYPT_RELUNKNOWN)

#define EMS_PYPT_ATSTOP      0x20      /* The intersection with boundary is
                                          at the stop point */
#define EMS_PYPT_ATSTART     0x40      /* The intersection with boundary is
                                          at the start point */
#define EMS_PYPT_ATEND       0x80      /* The intersection with boundary is
        				  at an end point */
#define EMS_PYPT_ATMIDDLE    0x100     /* The intersection with boundary is
                                          at some middle point */
#define EMS_PYPT_POSUNKNOWN  0x200     /* The intersection with boundary is
                                          at some unknown position */
#define EMS_PYPT_POSINFOMASK (EMS_PYPT_ATSTOP | EMS_PYPT_ATSTART | \
                              EMS_PYPT_ATEND  | EMS_PYPT_ATMIDDLE | \
                              EMS_PYPT_POSUNKNOWN)

           
#define EMS_PYPT_START_OVERLAP 0x400    /* This point marks the beginning of
                                           an overlap region */

#define EMS_PYPT_STOP_OVERLAP  0x800    /* This point marks the end of
                                           an overlap region */
                                         
/*
 * These bits are considered special and are independent of the
 * rest. They are used to indicate the status of the node as a whole
 */

#define EMS_PYPT_EMPTY	     0x1000    /* Indicates that this node is logically
                                          empty */
#define EMS_PYPT_MALLOCED    0x2000    /* Indicates that this node has been
                                          malloced independently */
#define EMS_PYPT_NXTCOINC    0x4000    /* The next node in the list is
                                          coincident with this one */
#define EMS_PYPT_ENDMARKER   0x8000    /* This node marks the logical end of
					  some sequence */

/* This define is used by the DPR selective display code to determine 
 * when to realloc the display ids buffer.
 */

#define DPR_DISPLAY_BUFF_INCR 15
 

/*
 * The following is a list of options in the form of ascii-numbers
 * that is used as the second argument to the call to the "plot"
 * executable. This decides the type of processing required. Typically,
 * "plot" is forked off using ex$fork, with the first real argument to
 * the function being the file-name to read to get the data for
 * plotting.
 */

#define EMS_RADCRV_PLOT	"-radcv"
#define EMS_LAWCV_PLOT	"-lawcv"
#define EMS_LAWCVT_PLOT	"-lawcvt"
#define EMS_UV_PLOT	"-uv"

/*
 * This defined constant is intended for the griodef.h file in GRNUC.
 * It is temporarily placed here.
 */

#define GRm_PLNDATA	0x00010000

/*
 * The following defined constant is used to indicate that no graphics
 * level is being indicated, that is, tkae the default level.
 */

#define DEFAULT_GR_LEVEL  9999
#define HIGHEST_GR_LEVEL  1023

/*
 * The following constants are the labels that have a one-to-one
 * correspondence with the various channels used within EMS. These are
 * "labels" to be used when making a channel via the call to the 
 * function - EMmake_chanselect. When adding a new channel label, be sure
 * to update the NUM_TOTAL_EMS_CHANNELS constant and the function -
 * EMinit_chanselect.
 */

#define GRconnector_to_owners		0
#define GRcmpowner_to_components	1
#define GRnotify_notification		2
#define EMSrequester_to_helpers		3
#define EMShelper_to_requesters		4
#define EMSsubbs_to_loopset		5
#define EMSloopset_to_surface		6
#define EMSloopset_to_loops		7
#define EMSloop_to_outter		8
#define EMSloop_to_inner		9
#define EMSbd_owner_to_comps		10
#define EMSedge_to_owner		11
#define EMSedge_to_common_edge		12
#define EMSfeaturelp_to_surface		13
#define EMScleaner_to_objmgr		14
#define EMSobjmgr_to_cleaner		15
#define EMSshovflow_to_shobjmgr		16
#define EMSshobjmgr_to_overflow		17
#define EMSxsection_to_model		18
#define EMSsfspltwsf_to_mirror_image	19
#define module_primary			20
#define GRgrset_to_owners		21
#define ci_executor_to_graphic		22
#define NDfather_father			23
#define NDchildren_children		24
#define SKconstraint_to_mgr		25
#define SKconstraint_to_variables	26
#define SKconstraint_to_super_constrs	27
#define SKgeometry_to_defpts		28
#define SKinterface_to_member_constrs	29
#define SKmgr_to_vars			30
#define SKmgr_to_constrs		31
#define SKvariable_to_constraints	32
#define SKvariable_to_geometries	33
#define SKvariable_to_mgr		34

#define NUM_TOTAL_EMS_CHANNELS		35

/* The following brought over from EMSdef.h (SAM Oct 11, 1995) */

/* ************************************************************************

 This structure was designed to return the u, v and the normal information
 of a point on the surface

  ************************************************************************ */

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"

struct EMparms
{
 IGRdouble u;
 IGRdouble v;
 IGRvector normal;
 struct GRid leaf_id;
};

# endif /* emsdef_include */
