/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"



/* igr.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */



/* gr.h replacement */

# ifndef OM_D_MINIMUM
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef dp_include
# include "dp.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef go_include
# include "go.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif


/* end of gr.h replacement */

#include "OMprimitives.h"
#include "EMSerrordef.h"
#include "emserr.h"

EMgetbsbnds (EMmsg, no_of_objects,object_info, incurves, plane, partol,
             outcurves)
IGRlong		*EMmsg;
IGRshort	no_of_objects;
struct GRlc_info *object_info;
struct IGRbsp_curve **incurves;
struct IGRbsp_surface *plane;
IGRdouble *partol;
struct IGRbsp_curve **outcurves;

/* *****************************************************************

   This function maps a series of xyz bspline curves on a plane into
   uv space. It expect either the xyz curve ids and locate information or
   the geometry of the xyz curves as input.  It returns the geometry of
   the uv curves. This function allocates memory for the poles, knots and
   weights for the bspline uv curves if the appropriate fields have been
   nulled.
 

   PP  : 04/12/87             Creation date


   ***************************************************************** */

{
  IGRshort		i;
  IGRlong 		msg_loc;
  IGRlong		num_bytes;
  struct		IGRbsp_curve *bnd_curve;
  struct		IGRbsp_curve *uvcurve;
  void			EMmapbstouv();

  *EMmsg = EMS_S_Success;
  bnd_curve = NULL;
  uvcurve = NULL;

  if (object_info)
  {
/* Get the geometries of the incurve objects */
  }
  else
  {
   bnd_curve = incurves[0];
   uvcurve = outcurves[0];
  }

  for (i=0 ; i < no_of_objects; i++)
  {
    if (!uvcurve->poles)
    {
      num_bytes = sizeof (IGRdouble) * 3 * bnd_curve->num_poles;
      uvcurve->poles =  (IGRdouble *) om$malloc (size = num_bytes);
      EMerr_hndlr (!uvcurve->poles, *EMmsg, EMS_E_DynamicMemoryAllocated,
                   wrapup);
    }

    if (!uvcurve->knots)
    {
      num_bytes = sizeof (IGRdouble) * bnd_curve->num_knots;
      uvcurve->knots = (IGRdouble *) om$malloc (size = num_bytes);
      EMerr_hndlr (!uvcurve->knots, *EMmsg, EMS_E_DynamicMemoryAllocated,
                   wrapup);
    }

    if (bnd_curve->rational)
    {
     if (!uvcurve->weights)
     {
      num_bytes = sizeof (IGRdouble) * bnd_curve->num_poles;
      uvcurve->weights = (IGRdouble *) om$malloc (size = num_bytes);
      EMerr_hndlr (!uvcurve->weights, *EMmsg, EMS_E_DynamicMemoryAllocated,
                   wrapup);
     }
    }
     else
      uvcurve->weights = NULL;
    
      
    EMerr_hndlr (uvcurve->bdrys, *EMmsg, EMS_E_InvalidCase,
                 wrapup);

/* I am not currently handling curves with boundaries */
    uvcurve->bdrys = NULL;

   EMmapbstouv (&msg_loc, bnd_curve, plane, partol, uvcurve);
   EMerr_hndlr (EMis_error (msg_loc), *EMmsg, msg_loc, wrapup);

   ++bnd_curve;
   ++uvcurve;
  }
  
wrapup:

   for (i=0 ; i < no_of_objects ; i++)
   {
   uvcurve = outcurves[0];
   bnd_curve = incurves[0];
   if (! (1 & msg_loc & *EMmsg))
   {
    if (uvcurve->poles) om$dealloc (ptr = uvcurve->poles);
    if (uvcurve->knots) om$dealloc (ptr = uvcurve->knots);
    if (uvcurve->weights) om$dealloc (ptr = uvcurve->weights);
    if (uvcurve->bdrys) om$dealloc (ptr = uvcurve->bdrys);
   }
/*
 * Potential bug here
 */

    if (object_info)
    {
     if (bnd_curve->poles) om$dealloc (ptr = bnd_curve->poles);
     if (bnd_curve->knots) om$dealloc (ptr = bnd_curve->knots);
     if (bnd_curve->weights) om$dealloc (ptr = bnd_curve->weights);
     if (bnd_curve->bdrys) om$dealloc (ptr = bnd_curve->bdrys);
    }
    ++uvcurve;
    ++bnd_curve;
    }
}

