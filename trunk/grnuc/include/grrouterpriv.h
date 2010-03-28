/* This is a private include file for graphics objects support
 * library.
 *
 * The dependancies are:
 *
 * 	gr.h
 *	go.h
 * 	igr.h
 *	igrtypdef.h
 *	exdef.h
 */

/*
 * Structure for Big ID.
 */

#include "exdef.h"
#include "griodef.h"

struct GRbigid
{
    GRspacenum	   osnum;
    GRobjid	   objid;
    struct GRparms parms;
    IGRshort	   mat_type;
    IGRmatrix	   matrix;
};

#define GRREG GRst_REGULAR		/* regular data point         */
#define GRAT  GRst_ANGLE_TO		/* angle to data point	      */
#define GRAF  GRst_ANGLE_FROM		/* angle from data point      */
#define GRTT  GRst_TANGENT_TO		/* tangent to data point      */
#define GRTF  GRst_TANGENT_FROM		/* tangent from data point    */
#define GRPT  GRst_PERPEND_TO		/* perpendicular to data point*/
#define GRPF  GRst_PERPEND_FROM		/* perpendicular from data pt */
#define GRVL  8				/* keyin value                */

#define GRrt_TOTAL 10			/* total number of subtypes   */

#define GRCURVE 0			/* curve object flag	      */
#define GRSURFACE 1			/* surface object flag        */

					/* router label macros        */

#define LABEL2(a,b) (a * 2 * GRrt_TOTAL + b)
#define LABEL3(a,b,c) (2 * GRrt_TOTAL * LABEL2(a,b) + c)
#define CURVE(a) (a)
#define SURFACE(b) (b) + GRrt_TOTAL

#define GRMAX_ID 2				/* max objects per event      */
#define GRMAX_VAL 1				/* max values per event	      */
#define GRMAX_LS_EVENTS 2			/* max events for place ls    */
#define GRMAX_CR_EVENTS 3			/* max events for place cr    */
#define GRMAX_EL_EVENTS 3			/* max events for place el    */
#define GRMAX_AR_EVENTS 3			/* max events for place arc   */
#define GRMAX_CA_EVENTS 3			/* max events for place cirar */
#define GRMAX_EA_EVENTS 3			/* max events for place elarc */

#define GRMAX_EVENTS 3				/* max events for place *     */

#define GRMAX_IDS 6				/* GRMAX_ID * max(MAX*EVENTS) */

#define GRD_POINT DATA				/* type data point input      */
#define GRD_VALUE VALUE				/* type value input	      */

struct GRrtevent				/* point event		      */
{
  IGRshort       type;				/* D_POINT or D_VALUE	      */
  IGRshort       subtype;			/* event type (REG,TT,ect.    */
  IGRpoint       pt;				/* the point		      */
  IGRvector	 vc;				/* view vector 		      */
  IGRshort	 num_val;			/* number of values	      */
  IGRdouble      val[GRMAX_VAL];		/* value associated with point*/
  IGRshort       num_id;			/* number of objects for event*/
  struct GRbigid objs[GRMAX_ID];		/* objects associated with    */
						/* point if subtype != REG    */
  struct GRprops props[GRMAX_ID];		/* object geometry type	      */
  IGRchar	 *geoms[GRMAX_ID];		/* geometries of objects      */
  struct GRid    viewid;			/* vw id associated with point*/
};


struct router_args
{
  IGRlong *msg;
  struct GRrtevent *events[GRMAX_LS_EVENTS];
  IGRshort *num_events;
  struct IGRbsp_curve *geometry;
};
  
