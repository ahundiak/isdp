/* ###################   APOGEE COMPILED   ################## */

class implementation EMSsubbs;

#if DEBUG
#include <stdio.h>
#endif

#ifndef OMmacros_include
#include "OMmacros.h"
#endif

#ifndef igrtypedef_include
#include "igrtypedef.h"
#endif

#ifndef igr_include
#include "igr.h"
#endif

#ifndef EMSmsgdef_include
#include "EMSmsgdef.h"
#endif

#ifndef emserr_include
#include "emserr.h"
#endif

#include "bserr.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"

# define OUT_SOLID	0
# define OFF_SURFACE	2
# define ERR	0

#define WBC_USE_NEW_MATH 1

#if DEBUG
#define ERROR(sts, msg, error_message)\
{\
    if(!(1 & sts & msg))\
    {\
	printf("\nIn EMget_unit_norm: %s\n", error_message); \
	goto wrapup;\
    }\
}
#else
#define ERROR(sts, msg, error_message)\
{\
    if(!(1 & sts & msg))  goto wrapup;\
}
#endif



method EMget_unit_norm(IGRlong *EMmsg; IGRboolean out_solid;
		struct IGRbsp_surface  *surface;
		struct GRmdenv_info *mdenv; 
		IGRdouble *pt, *unit_norm)
/*

DESCRIPTION:

This method gets a given point, direction and/or the surface geometry and
return a unit normal vector.

IGRlong		*EMmsg		Output	return status.
IGRboolean	out_solid	Input	indicate the normal direction is 
					ouside or inside solid.
struct IGRbsp_surface  *surface Input	the surface geometry, it can be NULL.
struct GRmdenv_info  *mdenv	Input	surface's module environment inform.
IGRdouble	*pt		Input	the given point on the surface.
IGRdouble	*unit_norm	Output	the unit normal vector.

History:

BL  07/28/89	Creation date.
BL  10/17/89	Added out_solid and surface arguments to this method.
BL  01/22/90	Added code to handle if point not on the surface.
WBC 01/13/93    Replaced the call to BSmdistptsf with a call to BSprptarrsf.

*/
{
  IGRint rc,
         one_point = 1;
  IGRlong  sts, msg_loc, buf_size;
  struct IGRbsp_surface  *surf_geom;
  struct BSgeom_bsp_surf geom_surface;
  IGRboolean  on_surf;
#if !WBC_USE_NEW_MATH
  IGRboolean bssts;
  IGRdouble  xyzpt[3], mindist;
#endif
  IGRdouble  uv[2], pts[6], *normal, dist_tol;
  extern void  BSsfarrevnd(),
               BSprptarrsf(),
               EFinit_geom_surface();
  extern   IGRboolean  BSmdistptsf(),
                       BSfreecv();

  *EMmsg = EMS_S_Success;
  surf_geom = NULL;
  normal = unit_norm;
  geom_surface.sfgen_cv = NULL;

  if(!surface)
  {
    /*
     * Get the surface geometry 
     */

    sts = om$send(msg = message EMSsubbs.GRgetsize(EMmsg, 
		&mdenv->matrix_type, mdenv->matrix, &buf_size),
		targetid = my_id);
    ERROR(sts, *EMmsg, "GRgetsize error");

    surf_geom = (struct IGRbsp_surface *) om$malloc(size = buf_size);

    sts = om$send(msg = message EMSsubbs.GRgetgeom(EMmsg, 
		&mdenv->matrix_type, mdenv->matrix, (IGRchar *) surf_geom),
		targetid = my_id);
    ERROR(sts, *EMmsg, "GRgetgeom error");

  }
  else  surf_geom = surface;
/*
 * Modified the routine to call BSmdistptsf instead of BSprptonsf
 * pp 10/29/92
 */

  /* get the unit normal vector on the located surface */

#if WBC_USE_NEW_MATH
  EFinit_geom_surface(&msg_loc, surf_geom, my_id, OM_Gw_current_OS,
                      &geom_surface);
  ERROR(msg_loc, *EMmsg, "EFinit_geom_surface error");

  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, dist_tol);

  BSprptarrsf(&geom_surface, dist_tol, 0, 2, &one_point, pt, uv,
              NULL, &on_surf, NULL, &rc);
  if (rc != BSSUCC) 
  {
   *EMmsg = EMS_E_BSerror;
   goto wrapup;
  }
#else
  bssts = BSmdistptsf (&rc, surf_geom, pt, &uv[0], &uv[1],
            xyzpt, &mindist);
  if (rc!=0) 
  {
   *EMmsg = EMS_E_BSerror;
   goto wrapup;
  }
#endif

  BSsfarrevnd(surf_geom, 1, &uv[0], 1, &uv[1], 1.0, NULL, pts, &rc);
  if(rc != 0)
  {
#if DEBUG
     printf("\nIn EMget_unit_norm: BSsfarrevnd error\n");
#endif
   *EMmsg = EMS_E_BSerror;
   goto wrapup;
  } /* if */

  if(out_solid)
  {
    if(surf_geom->pos_orient == OUT_SOLID)
    {
     	*normal++ = pts[3] - pts[0];
     	*normal++ = pts[4] - pts[1];
     	*normal = pts[5] - pts[2];
    } /* if */
    else
    {
     	*normal++ = pts[0] - pts[3];
     	*normal++ = pts[1] - pts[4];
     	*normal = pts[2] - pts[5];
    } /* else */

  } /* if out_solid */
  else
  {
    if(surf_geom->pos_orient == OUT_SOLID)
    {
     	*normal++ = pts[0] - pts[3];
     	*normal++ = pts[1] - pts[4];
     	*normal = pts[2] - pts[5];
    } /* if */
    else
    {
      	*normal++ = pts[3] - pts[0];
      	*normal++ = pts[4] - pts[1];
      	*normal = pts[5] - pts[2];
    } /* else */
  } /* else in_solid */

wrapup:
  if(!surface && surf_geom)  om$dealloc(ptr = surf_geom);

  if (geom_surface.sfgen_cv)
    BSfreecv(&msg_loc, geom_surface.sfgen_cv);

  return(sts);
	
} /* EMget_unit_norm */


end implementation EMSsubbs;

