/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#include <stdio.h>

# ifndef OM_D_MINIMUM
# include "OMminimum.h"     /* for gocmacros.h  */
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"     /* for gocmacros.h  */
# endif

# ifndef gocmacros_include
# include "gocmacros.h"     /* GRgetabsg macro  */
# endif

#include "OMerrordef.h"
#include "msdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsdef.h"
%safe
#include <math.h>
%endsafe
#include "OMstackalloc.h"
#include "OMmacros.h" /* For OM_BLOCK_MOVE */

#define MATH_READY 1

#define UNDEFINED_CURVATURE -123.321     /* Code returned by math routine
                                            to indicate undefined curvature */
#define NO_CNTR_OF_CRVTR -1       

#define RADIUS_OF_CURVATURE 0
#define GAUSSIAN_CURVATURE 1
#define MEAN_CURVATURE 2
#define PRINCIPAL_MAX_CURVATURE 3
#define PRINCIPAL_MIN_CURVATURE 4
#define ABSOLUTE 5

method EMsfradcrv (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
                   struct GRvg_construct *const_args; 
                   IGRuint prop_type; IGRlong unumpars;
                   IGRdouble upars[]; IGRlong vnumpars; IGRdouble vpars[];
                   IGRdouble cutoff_value; 
                   IGRdouble *prop_val; IGRdouble *prop_poly;
                   GRobjid *prop_obj)
/* **************************************************************************
Description
     This method outputs the following properties depending on the prop_type
     being sent in:
      0 - Radius of curvature (Inverse of principal max curvature)
      1 - Gaussian curvature
      2 - Mean
      3 - Principal max
      4 - Principal min
      5 - Absolute
      It also outputs the property as a polyline-string and/or as a second
      order B-spline object.
     These quantities are computed, in general, for a matrix of parameter
     values of this surface. 

Arguments
      *mattyp    Type of the matrix used to convert to
                 global coordinate system.
      mat        Matrix used for the conversion.
      const_args Construction arguments structure.
      prop_type  The type of property desired.
                     0 - Radius of curvature. This is the
                         inverse of principal maximum
                         curvature.
                     1 - Gaussian
                     2 - Mean
                     3 - Principal Max.
                     4 - Principal Min.
                     5 - Absolute
      unumpars     Number of parameters in the U-direction
                   at which to compute.
      upars[]      The array of parameter values in the 
                   U-direction.
      vnumpars     Number of parameters in the V-direction
                   at which to compute.
      vpars[]      The array of parameter values in the 
                   V-direction.
      cutoffvalue  All property values greater than cutoffvalue are truncated
                   to the maximum value.
      *msg         return code.

      *prop_val    Pointer to the interested properties.
                  (=NULL if not required, else memory ptr)

      *prop_poly  The properties as polyline-strings.
                  The buffer contains pairs of points
                  placed in contiguous memory.
                  (=NULL if not required, else memory ptr)
 
      *prop_obj   The properties as order-2 B-spline
                   objects.

        
Notes
      Upon exit the completion code will be one of the following:
              - MSSUCC if all was well.
              - MSINARG if the order of the surface
                        was 2 in both directions.
                        or if invalid property_type is passed.
              - MSNOMEM if memory allocation
                        failed.   
              - MSFAIL on any other error.
 
     The interpretation of the output is as follows:
       i) If value of curvature is output, a value of -123.321
          in crvtr_val[u][v], indicates that at the [u][v]th. parameter value
          the curve did not have a curvature defined.

      ii) If value of radius of curvature is output, a value of -1234.4321
          in prop_val[u][v], indicates that at the [u][v]th. parameter value
          the curve was linear in geometry.

     iii) The above condition is reflected in the polyline-string output
          by only the first point being signifiacnt. This condition can
          only be detected by looking at prop_val[u][v].

      iv) The above condition is reflected in the object-id output
          by a point object at the point on the surface.

History
        ss      10/02/86 : Design date.
        dhm     01/20/89 : Took out place where const_args->msg's address
                           was being changed.  This can cause memory
                           faults.
        pp      09/26/89 : Added support for returning various types of
                           curvatures.
*********************************************************************** */
{
  IGRboolean stat_func, in_class_attr;
  IGRchar errmsg[EMMAXERRMSG_LEN];
  IGRshort numpts_per_pt = 2;
  IGRlong i, j, k, l;
  IGRlong totalpts, frominx, toinx;
  IGRlong stat_OM, msg_loc, dumdum;
  IGRdouble *pts, temp_pts[6];
  struct IGRbsp_surface *srf;
  struct IGRpolyline temp_poly;
  struct GRid temp_id;
  IGRboolean gflag = FALSE, mflag=FALSE, pflag=FALSE, 
             aflag = FALSE, dflag=FALSE, cflag=FALSE;
  IGRdouble zero_tol;
  IGRdouble *crvtr_ptr = NULL,*cm = NULL,*cg = NULL,*c1 = NULL, *c2 = NULL;
  IGRdouble *ca = NULL, *dir1 = NULL, *dir2 = NULL;
  IGRint *clss = NULL;
  IGRvector natnorm;
  struct GRid my_GRid;
  enum EMSdatatype data_type;
#if MATH_READY
  extern   void BSsfarrevmc();
#endif
  extern   IGRboolean BSquicksort();
  IGRint EMoutput_linestring(), EMoutput_point();

  *msg = MSSUCC;
  stat_OM = OM_S_SUCCESS;
  strcpy (errmsg, "EMSsubbs.EMsfradcrv");
  pts = NULL;
  srf = NULL;
  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;


  totalpts = unumpars * vnumpars;
  if (prop_obj)
  {
   for (i=0;i<totalpts;i++)
    prop_obj[i] = NULL_OBJID;
  }

  BSEXTRACTPAR(&msg_loc, BSTOLCLOSETOZERO, zero_tol );

  /*
   * Get the abstract geometry of this
   * object. If the object is of order 2
   * in both directions, no further
   * processing. Curvature is
   * meaningless then. Return invalid
   * argument message.
   */

  EMgetvggeom(&msg_loc,mattyp,mat,&my_GRid,&srf,&data_type);
  EMerr_hndlr (EMis_error (msg_loc), *msg, msg_loc, ret_end);
  EMerr_hndlr (srf->u_order == 2 && srf->v_order == 2, *msg, MSINARG, ret_end);
  srf->num_boundaries = 0;

  /*
   * Sort the array of incoming parameters
   * so that they are all increasing monotonically.
   * (Math routine expects them this way).
   */

  frominx = 0;
  toinx = unumpars-1;
  stat_func = BSquicksort (&msg_loc, &frominx, &toinx, (IGRint *) &unumpars,
                           upars);
  EMerr_hndlr (!stat_func || msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

  toinx = vnumpars-1;
  stat_func = BSquicksort (&msg_loc, &frominx, &toinx, (IGRint *) &vnumpars,
                           vpars);
  EMerr_hndlr (!stat_func || msg_loc != BSSUCC, *msg, MSFAIL, ret_end);
 
  /*
   * Allocate memory for the arguments on
   * math function's argument list. If
   * the method was invoked with NULL pointers
   * for the respective outputs, it is assumed
   * that that output is not requested.
   */


/*
 * We could use the same memory for prop_val being passed in for storing
 * the curvature values.
 */

  if (!prop_val)
  {
   crvtr_ptr = (IGRdouble *) om$malloc(size = totalpts * sizeof
                        (IGRdouble));
   EMerr_hndlr (!crvtr_ptr, *msg, MSNOMEM, ret_end);
  }
  else
   crvtr_ptr = prop_val;

  pts = (IGRdouble *) om$malloc(size = totalpts * sizeof
                       (IGRpoint));
  EMerr_hndlr (! pts, *msg, MSNOMEM, ret_end);

  switch (prop_type)
  {
   case GAUSSIAN_CURVATURE:
    cg = crvtr_ptr;
    gflag = TRUE;
   break;

   case MEAN_CURVATURE:
    cm = crvtr_ptr;
    mflag = TRUE;
   break;

   case RADIUS_OF_CURVATURE:
   case PRINCIPAL_MAX_CURVATURE:
   case PRINCIPAL_MIN_CURVATURE:
   {
    c1 = crvtr_ptr;
    c2 = (IGRdouble *) om$malloc (size = totalpts * sizeof
                       (IGRdouble));
    EMerr_hndlr (!c2, *msg, MSNOMEM, ret_end);
    pflag = TRUE;
   }
   break;

   case ABSOLUTE:
   {
    ca = crvtr_ptr;
    aflag = TRUE;
   }
   break;

   default:
   {
    *msg = MSINARG;
    goto ret_end;
   }
  }

  /*
   * Call the math function to 
   * compute the curvature.
   */

#if MATH_READY
  BSsfarrevmc(srf,(IGRint)unumpars,upars,(IGRint) vnumpars,vpars,
              gflag,mflag,pflag,aflag,dflag,cflag,pts,cg,cm,c1,c2,ca,dir1,
              dir2,clss,&msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, MSFAIL, ret_end);
#else
  return (OM_E_ABORT);
#endif

  if (c1 && c2)
  {
   IGRdouble temp;

   for (i=0;i<totalpts;i++)
   {
    if ((c1[i] != UNDEFINED_CURVATURE) &&
        (fabs(c1[i]) < fabs(c2[i])))
    {
     temp = c1[i];
     c1[i] = c2[i];
     c2[i] = temp;
    }
   }
  }

  if (prop_type == RADIUS_OF_CURVATURE)
  {
   for (i=0;i<totalpts;i++)
   {
    if (fabs(c1[i]) < zero_tol) /* If the curvature is 0 then radius of
                                   curvature is infinite, if so truncate
                                   the same to maximum value. */
     crvtr_ptr[i] = cutoff_value;
    else if (crvtr_ptr[i] != UNDEFINED_CURVATURE)
     crvtr_ptr[i] = 1/c1[i];
   }
  }
  else if (prop_type == PRINCIPAL_MAX_CURVATURE)
  {
   if (c2) om$dealloc(ptr = c2);
   c2 = NULL;
   crvtr_ptr = c1;
  }
  else if (prop_type == PRINCIPAL_MIN_CURVATURE)
  {
   OM_BLOCK_MOVE(c2,crvtr_ptr,totalpts*sizeof(IGRdouble));
   if (c2) om$dealloc(ptr = c2);
   c2 = NULL;
  }

  for (i=0;i<totalpts;i++)
  {
   if ((crvtr_ptr[i] != UNDEFINED_CURVATURE) && 
        (fabs(crvtr_ptr[i]) > cutoff_value))
     crvtr_ptr[i] = ((crvtr_ptr[i] < 0) ? -cutoff_value : cutoff_value);
  }

  if (prop_obj)
    const_args->newflag = FALSE;

  if (prop_poly || prop_obj)
  {
   temp_poly.num_points = numpts_per_pt;
   temp_poly.points = temp_pts;

   for (i=0,l=0;i<vnumpars;i++)
    for (j=0;j<unumpars;j++)
    {
     frominx = i*unumpars + j;
     toinx = l*numpts_per_pt*3;

     if (crvtr_ptr[frominx] != UNDEFINED_CURVATURE)
     {
      EMavgsfnorm(&msg_loc,srf,upars[j],vpars[i],
                  &pts[3*frominx],natnorm);
      if ((msg_loc == EMS_I_NoSolution) || (!(1&msg_loc)))
       crvtr_ptr[frominx] = UNDEFINED_CURVATURE;
     }
      
     if (crvtr_ptr[frominx] == UNDEFINED_CURVATURE)
     {
      if (prop_poly)
      {
       for (k=0; k<3; k++)
         prop_poly[toinx + 0 + k] = pts[3*frominx + k];
      }

      if (prop_obj)
      {
         stat_OM = EMoutput_point (&msg_loc, my_id, const_args, 1,
                    pts[3*frominx], &temp_id);
         EMomerr_hndlr (stat_OM, ret_end, errmsg);
         EMerr_hndlr (msg_loc != BSSUCC, *msg, MSFAIL, ret_end);
      }
     }
     else
     {
      if (prop_poly)
      {
       for (k=0; k<3; k++)
       {
         prop_poly[toinx + 0 + k] = pts[3*frominx + k];
/*
 * If the principal (max) curvature is positive then its direction is 
 * opposite to the direction of the natural normal.
 */
         prop_poly[toinx + 3 + k] = pts[3*frominx + k] - 
                                    crvtr_ptr[frominx]*natnorm[k]; 
       }
      }
     
      if (prop_obj)
      {
          for (k=0;k<3;k++)
          {
           temp_pts[k] = pts[3*frominx + k];
           temp_pts[3+k] = temp_pts[k] + crvtr_ptr[frominx] * natnorm[k];
          }
          stat_OM = EMoutput_linestring (&msg_loc, my_id, const_args, 1,
                     &temp_poly, &temp_id);
          EMomerr_hndlr (stat_OM, ret_end, errmsg);
          EMerr_hndlr (msg_loc != BSSUCC, *msg, MSFAIL, ret_end);
      }
     }
     if (prop_obj)
      prop_obj[l] = temp_id.objid;
     l++;
    }
  }
        

 if (prop_val)
 {
  for (i=0;i<totalpts;i++)
  {
   if (crvtr_ptr[i] == -123.321)
    crvtr_ptr[i] = -1;
   else
   {
    if (prop_type != GAUSSIAN_CURVATURE)
     crvtr_ptr[i] = fabs(crvtr_ptr[i]);
   }
   if (fabs(crvtr_ptr[i]) < zero_tol) crvtr_ptr[i] = 0.0;
  }
 }

ret_end:
  if (srf) om$dealloc(ptr = srf);
  if (pts) om$dealloc(ptr = pts);
  if (crvtr_ptr && (crvtr_ptr != prop_val)) om$dealloc(ptr = prop_val);
  return (stat_OM);
}

end implementation EMSsubbs;
