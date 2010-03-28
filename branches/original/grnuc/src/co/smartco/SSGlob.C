/*

Name
  SSGlob.C

Description
  Global memory used for Smart Sketch

Notes
  At some point it might be nice to make these static with get/put function
  interfaces.

 */

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dp.h"
#include "SSdef.h"
#include "SS.h"
#include "msdef.h"
#include "grmsg.h"

/*
 * The list of objects we are looking at.
 */
SSObject SSObjects [SS_MAX_OBJECTS];
int      SSnb_objects = 0;

/*
 * The last point and the last object(s) we recognized a constraint for
 */
int       SSLastAvailable = 0; 
int	  SSLastConstraintType = SSNONE;

double    SSLastConstraintPoint [6]; 
double    SSLastKeypoint [6];

SSObject *SSLastObject1 = NULL; 
SSObject *SSLastObject2 = NULL;

SSObject SSNewObject1;
SSObject SSNewObject2;

/*
 * The reference plane normal and origin
 */
int             SSRefLock = FALSE;
struct IGRplane SSRefPlane;
IGRvector       SSRefXaxis; 
IGRvector       SSRefYaxis;
IGRmatrix       SSRefMatrix;
IGRmatrix       SSInvRefMatrix;
short           SSRefMatTyp;

/*
 * To display dynamic text
 */
struct SSDisplayInfo SStext [SS_MAX_CONSTRAINT_TYPES];

/*
 *  UMS message keys associated with the various constraints.  This is an
 *  ordered list and must correspond to the order of the constraint types
 *  as defined in SSdef.h.
 *  Note: The 'SM' prefix is holdover from from when 'SM' was our name tag.
 */
int SSums_keys[SS_MAX_CONSTRAINT_TYPES] =
{
   GR_I_SMONELEMENT,
   GR_I_SMCENTER,
   GR_I_SMINTERSECT,
   GR_I_SMFIRSTPOINT,
   GR_I_SMFIRSTPOINT,
   GR_I_SMKEYPOINT,
   GR_I_SMHORIZONTAL,
   GR_I_SMVERTICAL,
   GR_I_SMPERPENDICULAR,
   GR_I_SMPARALLEL,
   GR_I_SMTANGENT,
   GR_I_SMMIDPOINT,
   GR_I_SMONXELEMENT,    /* collinear */
   GR_I_SMXINTERSECT,
   GR_I_Clear,           /* 14 - no message for SSHVERTICAL   */
   GR_I_Clear,           /* 15 - no message for SSVHORIZONTAL */
   GR_I_SMONHORIZONTAL,
   GR_I_SMONXVERTICAL,
   GR_I_SMONXHORIZONTAL,
   GR_I_SMONVERTICAL,
   GR_I_SMXTANGENT,
   GR_I_SMQUADPOINT,
   GR_I_SMQUADPOINT,
   GR_I_SMQUADPOINT
};

/*
 * To display icons
 */
IGRmatrix SSRotMat60;

/*
 * The new element is the element being constructed. SS will
 * attempt to recognize constraints between that element and
 * the list of element it is looking at. SS will also recognize
 * constraints on the object itself (horizontal, vertical, ...) 
 */
int       SSNewElementType = SSNONE;
IGRpoint  SSNewPoints [3];
int       SSNewFlag;                  /* additional element specific mask */

/*
 * Last window stuff to avoid recomputing tolerance, matrices, ...
 * everytime the cursor moves.
 */
struct GRid SSLastWindow;
double      SSLastTolerance;
double	    SSViewToWorld [16];
double	    SSWorldToView [16];

/*
 * Bore line for locate when the ref lock is off
 */
IGRpoint       SSFirstBoreLinePoint; 
IGRpoint       SSSecondBoreLinePoint; 
struct IGRline SSBoreLine;

/*
 * this mask determines what is displayed by Smart Sketch when a constraint
 * is found:
 */
int SSDisplayMode;
