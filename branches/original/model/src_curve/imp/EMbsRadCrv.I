class implementation GRbspline;

#include "EMS.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "gocmacros.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "bserr.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsdef.h" /* For MAXFLOAT */

%safe
#include <math.h>
#include "bsnorvec.h"
#include "bscvarrevc.h"
%endsafe

#define NO_CNTR_OF_CRVTR -1   /* Code returned by math routine
                                 to indicate undefined radius of
                                 curvature. e.g.: On a linear section. */


method EMcvradcrv(
  IGRlong *msg; 			/* Error return code */
  IGRshort *mattyp; 			/* My matrix type */
  IGRmatrix mat;			/* My matrix */
  struct GRvg_construct *const_args; 	/* Standard construction args */
  IGRlong numpars;			/* # of parameter values desired */
  struct GRparms *start_parm;		/* Starting parameter value */
  struct GRparms *mid_parm;		/* Middle parameter value iff closed */
  struct GRparms *end_parm;		/* Ending parameter value */
  IGRdouble maxrad; 			/* Maximum radius of curv allowable */
  IGRdouble *crvtr_val; 		/* Curvature values */
  IGRdouble *radii_val; 		/* Radius of Curvature values */
  IGRdouble *prop_poly; 		/* Property values */
  GRobjid *prop_obj;			/* Property objects */
  IGRdouble *crv_poly;			/* Property curve ls */
  GRobjid *crv_obj)			/* Property curve object */

/* ************************************************************************** 
   Description
 
        This method outputs the curvature, radius of curvature, radius
      of curvature as a polyline-string and the radius of curvature as a
      second-order B-spline object. These quantities are computed, in 
      general, for an array of parameter values of this curve. The parameter
      values are determined by dividing the starting and ending
      parameter values into a array of equally space parameter values.  
      All or some of the above quantities will be output, depending on whether
      the user has allocated memory for them or not. If no output for
      a certain quantity is desired, the corresponding output pointer
      MUST be set to NULL.
 
        Certain important characteristics of this method are described
     in the notes. The memory allocations are also described.

  
Arguments
       *msg         IGRlong        return code.
                                    - MSSUCC if all was well.
                                    - MSINARG if the order of curve was 2.
                                    - MSNOMEM if memory allocation
                                         failed.   
                                    - MSFAIL on any other error.
 
       *crvtr_val   IGRdouble      The curvature values at the params.
                                    (=NULL if not required, else memory ptr)
                                   If this is NULL, then radii_val has to be
                                   not NULL.
 
       *radii_val   IGRdouble      The values of the radius of curvature.
                                    (=NULL if not required, else memory ptr)
                                   If this is NULL, then crvtr_val has to be
                                   not NULL.
 
       *prop_poly  IGRdouble      The property as polyline-strings.
                                   The buffer contains pairs of points
                                   placed in contiguous memory.
                                   (=NULL if not required, else memory ptr)

                                   If (radii_val) or (radii_val and crvtr_val)
                                   is requested this field shall contain 
                                   radius of curvature as polyline-strings.
                                      
                                   If (crvtr_val) is requested this field shall
                                   contain curvature as polyline strings.
  
       *prop_obj   GRobjid        The property as order-2 B-spline
                                    objects.
                                    (=NULL if not required, else memory ptr)
 
                                   If (radii_val) or (radii_val and crvtr_val)
                                   is requested this field shall contain 
                                   radius of curvature as object.
                                      
                                   If (crvtr_val) is requested this field shall
                                   contain curvature as objects.

       *crv_poly    IGRdouble      The property as a single
                                   polyline-string.
                                   (=NULL if not required, else memory
                                    ptr).

                                   If (radii_val) or (radii_val and crvtr_val)
                                   is requested this field shall contain 
                                   radius of curvature as object.
                                      
                                   If (crvtr_val) is requested this field shall
                                   contain curvature as objects.
 
       *crv_obj     GRobjid        The property as a single
                                   order-2 B-spline curve.
                                   (=NULL if not required, else memory
                                    ptr).

                                   If (radii_val) or (radii_val and crvtr_val)
                                   is requested this field shall contain 
                                   radius of curvature as object.
                                      
                                   If (crvtr_val) is requested this field shall
                                   contain curvature as objects.
 
 
Notes
        If polyline-strings are to be output the buffer to be allocated
      is: numpars * 2 * sizeof (IGRpoint). Each successive pair of 3-D
      points comprises the radius of curvature. The first point is the 
      point on the curve at the parameter value and the second point
      gives the center of curvature.
 
        If objects are to be output the buffer is allocated as: numpars *
      sizeof (GRobjid).
 
      Further,
 
        i) If value of radius of curvature is output, a value of -1
           in radii_val[i], indicates that at the ith. parameter value
           the curve was linear in geometry.
 
       ii) The above condition is reflected in the polyline-string output
           by the second point being insignificant. This can be only
           detected by looking at radii_val[i] == -1.
 
      iii) The above condition is reflected in the object-id output
           by the object being a point object at the point on the curve.
 
       If a single polyline-string is to be output, the buffer to be 
       allocated is: numpars * sizeof(IGRpoint).  Each point is at the 
       center of curvature.
 
       If a single order-2 bspline curve is to be output, the address of
       a GRobjid is passed in.
 
 
Bugs
      Closed curves are not supported properly.  The mid_parm is presently
      ignored.
 
History
 
 
  10/02/86 : ss  : The beginning
  01/27/87 : rlw : Modify argument list to accept start, middle, and
                   ending parameter values as opposed to a list of
                   parameter values
 
  03/??/87 : dhm : Modified to output a single order 2 curve as well as
                   many linestrings.  Added 2 new arguments -- crv_obj,
                   crv_poly.
 
  08/12/88 : dhm : Set last parameter value to the high parameter value.
 
  01/20/89 : dhm : Took out place where const_args->msg's address was 
                   being changed.  This can cause memory faults.

  09/28/89 : pp  : Added support for returning curvature too as
                   graphic objects. Also modified the code to
                   properly handle the "maximum" (Truncation) value
                   that is being passed in. This value was being used
                   to scale the property as opposed to truncation.

  Sudha  06/16/93     Modified for BSprototype ansification
********************************************************************** */
{
  IGRboolean in_class_attr;
  IGRchar errmsg[EMMAXERRMSG_LEN];
  IGRlong i, j;
  IGRlong stat_OM, msg_loc, dumdum;
  IGRdouble *pars, *kurv, *rad, (*pts)[2][3], temp_pts[6];
  IGRdouble *prop_ptr;
  IGRdouble maxdouble;
  IGRvector vec;
  struct IGRbsp_curve *crv;
  struct IGRpolyline temp_poly, temp_crvpoly;
  struct GRid temp_id;
  IGRint EMoutput_linestring(), EMoutput_point();

  *msg = MSSUCC;
  stat_OM = OM_S_SUCCESS;
  strcpy (errmsg, "GRbspline.EMcvradcrv");
  temp_crvpoly.points = NULL;
  pars = NULL;
  kurv = NULL;
  rad = NULL;
  pts = NULL;

  EMerr_hndlr((!radii_val && !crvtr_val),*msg, MSINARG,ret_end);
  /*
   * Get the abstract geometry of this
   * object. If the object is of order 2,
   * no further processing. Curvature is
   * meaningless then. Return error.
   */

  GRgetabsg (&msg_loc, mattyp, mat, (char **) &crv, dumdum);
  EMerr_hndlr (EMis_error (msg_loc), *msg, msg_loc, ret_end);
  EMerr_hndlr (crv->order == 2, *msg, MSINARG, ret_end);

  if (radii_val) prop_ptr = radii_val;
  else if (crvtr_val) prop_ptr = crvtr_val;

  /*
   * Generate the array of parameter values
   * so that they are all increasing monotonically.
   * (Math routine expects them this way).
   */
   {
    IGRdouble	u, delta_u, u_low, u_hig;

    pars = (IGRdouble *) om$malloc(size = sizeof(IGRdouble) * numpars);
    EMerr_hndlr (! pars, *msg, MSNOMEM, ret_end);

    if (numpars > 1)
     {
      if (start_parm->u < end_parm->u)
       {
        u_low = start_parm->u;
        u_hig = end_parm->u;
       }
      else
       {
        u_low = end_parm->u;
        u_hig = start_parm->u;
       }

      u = u_low;
      delta_u = (u_hig - u_low) / (numpars - 1.0);
      for (i = 0; i < numpars; i++)
       {
        pars[i] = u;
        u += delta_u;
       }

      pars[numpars-1] = u_hig;  /* to fix BSINARG from math. dhm 8/12/88 */
     }
    else
     pars[0] = start_parm->u;
   }
  /*
   * Allocate memory for the arguments on
   * math function's argument list. If
   * the method was invoked with NULL pointers
   * for the respective outputs, it is assumed
   * that that output is not requested.
   */

  if (! crvtr_val)
    {
    kurv = (IGRdouble *) om$malloc(size = numpars * sizeof (IGRdouble));
    EMerr_hndlr (! kurv, *msg, MSNOMEM, ret_end);
    }
  else
    kurv = crvtr_val;

  if (! radii_val)
    {
    rad = (IGRdouble *) om$malloc(size = numpars * sizeof (IGRdouble));
    EMerr_hndlr (! rad, *msg, MSNOMEM, ret_end);
    }
  else
    rad = radii_val;

  if (! prop_poly)
  {
    pts = (IGRdouble (*)[2][3]) om$malloc(size = numpars * 2 * sizeof (IGRpoint));
    EMerr_hndlr (! pts, *msg, MSNOMEM, ret_end);
  }
  else
    pts = (IGRdouble (*)[2][3]) prop_poly;

  /*
   * Call the math function to 
   * compute the radii of curvature.
   */

  maxdouble = MAXFLOAT;
  BScvarrevc (crv, (IGRint) numpars, pars, maxdouble, kurv, rad, pts, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

  /*
   * Make the output buffers, the
   * space for which is assumed 
   * allocated. Actually, the output
   * polyline-string, if requested
   * has been formatted in the math
   * call itself. So only the object
   * ids need to be made.
   */

  for (i=0;i<numpars;i++)
  {
   if ((prop_ptr[i] != -1) && (fabs(prop_ptr[i]) > maxrad))
   {
    prop_ptr[i] = ((prop_ptr[i] < 0) ? -maxrad : maxrad);
   }

   if (prop_ptr[i] != -1)
   {
    for (j=0;j<3;j++)
     vec[j] = pts[i][1][j] - pts[i][0][j];
     BSnorvec (&msg_loc, vec);
     if (msg_loc != BSSUCC)
       prop_ptr[i] = -1;
     else
     {
      for (j=0;j<3;j++)
       pts[i][1][j] = pts[i][0][j] + prop_ptr[i] * vec[j];
     }
   }
  }

  if (prop_obj)
   {
    const_args->newflag = FALSE;
    in_class_attr = const_args->class_attr ? TRUE : FALSE;
    temp_poly.num_points = 2;
    temp_poly.points = temp_pts;
    for (i=0; i<numpars; i++)
      {
      for (j=0; j<3; j++)
        temp_poly.points[j] = pts[i][0][j];
      if (! in_class_attr) const_args->class_attr = NULL;
      if (prop_ptr[i] == NO_CNTR_OF_CRVTR)
        {
        stat_OM = EMoutput_point (&msg_loc, my_id, const_args, 1,
                   temp_poly.points, &temp_id);
        }
      else
        {
        for (j=0; j<3; j++)
          temp_poly.points[3+j] = pts[i][1][j];

        stat_OM = EMoutput_linestring (&msg_loc, my_id, const_args, 1,
                   &temp_poly, &temp_id);
        }
      EMomerr_hndlr (stat_OM, ret_end, errmsg);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, MSFAIL, ret_end);
        
      prop_obj[i] = temp_id.objid;
      }
    }

  /*
   * Make output buffer, space assumed
   * already allocated, for points of
   * curve as a linestring.
   */

  if (crv_poly)
   {
	 for (i=0; i<numpars; i++)
      {
	     if (prop_ptr[i] == NO_CNTR_OF_CRVTR)
		  {
	     	for (j=0; j<3; j++)
			 crv_poly[(i*3)+j] = pts[i][0][j];
		  }
		 else
		  {
	     	for (j=0; j<3; j++)
			 crv_poly[(i*3)+j] = pts[i][1][j];
		  }

	  }
   }

  /*
   * Make output buffer, space assumed
   * already allocated, for the curve
   * object as a linestring.
   */

  if (crv_obj)
   {
     const_args->newflag = FALSE;
     in_class_attr = const_args->class_attr ? TRUE : FALSE;
     temp_crvpoly.num_points = numpars;
     temp_crvpoly.points = (IGRdouble *) om$malloc(size = numpars *
			 				sizeof(IGRpoint));
     EMerr_hndlr (! temp_crvpoly.points, *msg, MSNOMEM, ret_end);
     if (! in_class_attr) const_args->class_attr = NULL;

     for (i=0; i<numpars; i++)
      {
	     if (prop_ptr[i] == NO_CNTR_OF_CRVTR)
		  {
	     	for (j=0; j<3; j++)
			 temp_crvpoly.points[(i*3)+j] = pts[i][0][j];
		  }
		 else
		  {
	        for (j=0; j<3; j++)
             temp_crvpoly.points[(i*3)+j] = pts[i][1][j];
		  }
 	  }

     stat_OM = EMoutput_linestring (&msg_loc, my_id, const_args, 1,
				                    &temp_crvpoly, &temp_id);
     EMomerr_hndlr (stat_OM, ret_end, errmsg);
     EMerr_hndlr (msg_loc != BSSUCC, *msg, MSFAIL, ret_end);
        
     *crv_obj = temp_id.objid;
   }

  /*
   * Deallocate any locally allocated
   * memory in the reverse order.
   */

  if (temp_crvpoly.points)
    {
    om$dealloc(ptr = temp_crvpoly.points);
	temp_crvpoly.points = NULL;
    }
  if (! prop_poly)
    {
    om$dealloc(ptr = pts);
    pts = NULL;
    }
  if (! radii_val) 
    {
    om$dealloc(ptr = rad);
    rad = NULL;
    } 
  if ( ! crvtr_val)
    {
    om$dealloc(ptr = kurv);
    kurv = NULL;
    }

ret_end:
  if (temp_crvpoly.points) om$dealloc(ptr = temp_crvpoly.points);
  if (pars) om$dealloc(ptr = pars);
  if (! prop_poly && pts) om$dealloc(ptr = pts);
  if (! radii_val && rad) om$dealloc(ptr = rad);
  if (! crvtr_val && kurv) om$dealloc(ptr = kurv);
  return (stat_OM);
}

end implementation GRbspline;
