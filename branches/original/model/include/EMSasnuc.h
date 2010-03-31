/*
  DESCRIPTION

    This file contains all the general purpose structures used in the
    associative system in EMS.

    Dependency:
    igrtypedef.h
    igetypedef.h
    exdef.h
    ex.h
    DItypedef.h
    DIdef.h
    igrdp.h
    gr.h
    godef.h
    go.h
    griodef.h
    grio.h
*/

#ifndef EMSasnuc_h
#define EMSasnuc_h

#ifndef DI_PATH_MAX
#include "DIdef.h"
#endif

/*
 * The following defines data types of objects, points, infinite-line and
 * infinit-plane, values in a more "complete" way. This is specially useful
 * when points and values are available as names of objects, numeric values,
 * etc.
 */

enum EMSdata_info
  {
  EMSdatainfo_numeric,
  EMSdatainfo_object,
  EMSdatainfo_name,
  EMSdatainfo_event,
  EMSdatainfo_undefined
  };

struct EMSobject_info
  {
  struct GRid grid;
  struct GRmd_env env;
  };

struct EMSvalue_info
  {
  enum EMSdata_info type;
  IGRdouble val;		/* Numeric def */
  IGRchar valname[DI_PATH_MAX];	/* Name def */
  struct GRid valobj;		/* Object def */
  struct GRevent *valevent;	/* Event def */
  };

struct EMSpoint_info
  {
  enum EMSdata_info type;
  IGRpoint pt;			/* Numeric def */
  struct EMSobject_info ptobj;	/* Object def */
  struct GRevent *ptevent;	/* Event def */
  };

struct EMSvector_info
  {
  enum EMSdata_info type;
  IGRvector vec;		/* Numeric def */
  struct EMSobject_info vecobj;	/* Object def */
  struct GRevent *vecevent; 	/* Event def */
  };

struct EMSline_info
  {
  enum EMSdata_info type;
  IGRpoint lnpt1, lnpt2;	/* Numeric def */
  struct EMSobject_info lnobj;	/* Object def */
  struct GRevent *lnevent; 	/* Event def */
  };

struct EMSplane_info
  {
  enum EMSdata_info type;
  IGRpoint pt;			/* Numeric def */
  IGRvector normal;
  struct EMSobject_info plobj;	/* Object def */
  struct GRevent *plevent;	/* Event def */
  };

/*
 * The following structure also serves the purpose of geometry-abstraction.
 * There are times when geometry may be obtained as points, infinite-lines,
 * infinite-planes, B-spline curves, B-spline surfaces. The only memory
 * that may need to be allocated at run time would be the memory for
 * curves and the surface structures.
 */

struct EMSgeomdata
  {
#define GEOMDATA_NULL		0
#define GEOMDATA_POINT		1 /* point */
#define GEOMDATA_VECTOR	        2 /* vector */
#define GEOMDATA_LINE		3 /* line */
#define GEOMDATA_PLANE		4 /* plane */
#define GEOMDATA_CURVE		5 /* curve */
#define GEOMDATA_SURFACE	6 /* surface */
#define GEOMDATA_COORD		7 /* plane AND vector as X-axis */

  IGRint geomtype;

  IGRpoint point;
  IGRvector vector;
  struct
    {
    IGRpoint line_pt1;
    IGRpoint line_pt2;
    struct IGRline igr_line;
    } line;
  struct
    {
    IGRpoint plane_pt;
    IGRvector plane_vec;
    struct IGRplane igr_plane;
    } plane;
  struct IGRbsp_curve *curve;
  struct IGRbsp_surface *surface;
  };

/*
 * Structure that contains all the information about the parameters
 * that drive a given associative entity
 */

struct EMSassoc_params
  {
  IGRint obj_type;

  IGRchar *obj_info;
  IGRint obj_info_size;

  IGRint num_parents;
  struct GRid *parents;
  struct GRid *asparents;
  struct GRmd_env *md_envs;
  };


/* 
 * This structure has been defined to handle the different types of
 * information that one seeks from parents. 
 */

union EMSparent_info
 {
   IGRdouble value;         /* Value of an expression */
   IGRdouble point[3];      /* X, Y, Z coordinates of a point */
   IGRvector vector;	    /* Del-X, Del-Y and Del-Z for the 3D-direction */
   struct EMSobject_info grobj;
                            /* Graphic object id and the module environment */
   struct GRlc_info lc_info;/* Graphic object id and the module environment
                               packed in a locate structure */
 };

#endif
