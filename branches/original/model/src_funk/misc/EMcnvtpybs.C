/* ***************************************************************

   This function converts accepts a polyline as input and converts
   it into a bspline. If the caller nulls the knots and poles fields in
   outbs then the memory is allocated in this function or else it is assumed
   that the caller allocated the right amount of memory.


 History

  02/13/97  SCW   included emsmacros_c.h rather than emsmacros.h
  07/08/93  Sudha Modified for BSprototypes ansification
  08/24/88 : PP : Added a dimension field to take into account
                  a 2 or 3 dimension incoming polyline.
  06/01/87 : PP : 06/01/87 

   *************************************************************** */

# include "EMS.h"

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

#include "bserr.h"
#include "bsparameters.h"
#include "EMSerrordef.h"
#include "emserr.h"
#include <math.h>
#include "emsmacros_c.h"
#include "bsdistptpt.h"


 IGRboolean EMcnvtpybsn (EMmsg,dim,inpoly, outbs)

 IGRlong *EMmsg;
 IGRint dim;
 struct IGRpolyline   *inpoly;
 struct IGRbsp_curve  *outbs;

 {
   IGRshort		order;
   IGRshort		i;
   BSrc			rc;
   IGRlong		num_poles;
   IGRlong		num_knots;
   IGRlong		status;
   IGRboolean		memory_allocated = FALSE;
   IGRdouble		dist, dist_tol;

   *EMmsg = EMS_S_Success;

   if (!((dim == 2 ) || (dim == 3)))
   {
    *EMmsg = EMS_E_InvalidArg;
    goto wrapup;
   }
    
   status = BSEXTRACTPAR (&rc, BSTOLLENVEC, dist_tol);
   if (!status) goto wrapup;

   if (!outbs->poles)
   {
     memory_allocated = TRUE;
     outbs->poles  = (IGRdouble *) 
                        malloc (sizeof (IGRdouble) * 3 * inpoly->num_points);
     EMerr_hndlr (!outbs->poles, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
   }

   if (!outbs->knots)
   {
     outbs->knots = (IGRdouble *) malloc (sizeof (IGRdouble) *
                                        (inpoly->num_points + 2));
     EMerr_hndlr (!outbs->knots, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
   }
 
   num_poles = inpoly->num_points;
   num_knots = num_poles + 2;
   order = 2;

   for (i=0; i<inpoly->num_points; i++)
   {
    outbs->poles[3*i] = inpoly->points[dim*i];
    outbs->poles[3*i+1] = inpoly->points[dim*i + 1];
    if (dim == 3)
     outbs->poles[3*i+2] = inpoly->points[dim*i + 2];
    else if (dim == 2)
     outbs->poles[3*i+2] = 0.0;
   }

/*
 * Generate the knot vector which is going to be uniform
 */

 {

  IGRdouble knot_increment,
            knot;

  for (i=0 ; i < 2; i++)
   outbs->knots[i] = 0.0;

  knot_increment = 1.0 / (num_poles - 1);
  knot = 0.0;

  for (i = 2; i < num_poles; i++)
  {
    knot += knot_increment;
    outbs->knots[i] = knot;
  }

  for (i = num_poles ; i < num_knots; i++)
   outbs->knots[i] = 1.0;

 }


   outbs->order = 2;
   outbs->periodic = FALSE;
   outbs->non_uniform = FALSE;
   outbs->num_poles = inpoly->num_points;
   outbs->num_knots = num_knots;
   outbs->rational = FALSE;
   outbs->weights = NULL;
   outbs->planar = TRUE;

   dist = BSdistptpt (&rc, outbs->poles, 
                           &outbs->poles[(outbs->num_poles - 1)*3]);
   if (fabs  (dist) < dist_tol)
    outbs->phy_closed = TRUE;
   else
    outbs->phy_closed = FALSE;

   outbs->num_boundaries =0;

   return (TRUE);

   
wrapup:
   if (memory_allocated)
   {
    if (outbs->poles) free (outbs->poles);
    if (outbs->knots) free (outbs->knots);
   }
   return (FALSE);

}
