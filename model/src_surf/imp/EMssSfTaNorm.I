/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION
       
    This method outputs the normals and tangents, computed in
    general, for a matrix of parameter values implied by rows of
    U and V parameters. The ouput may be returned as polyline-string
    and/or second-order B-spline objects. Two Boolean flags control
    the computation of tangents and/or normals. The correct amount and
    form of memory has to be allocated by the user. If an output of a
    certain type is not desired (polylines or objects), the corresponding
    output pointer MUST be set to NULL.

    An important side-effect of this method is the evaluation of the
    points on the surface itself. Setting both the Boolean flag to FALSE,
    would imply that only the surface needs to be evaluated and returned.
    If objects are to be output they are returned as point objects, if 
    they are to be returned as polyline-strings, they are returned as a
    buffer of points.

    The memory allocations for this call and interpretaion of the
    output are explained in the notes.
 
  ARGUMENTS

    mattyp 		- Input: Type of the matrix used to convert to
                           global coordinate system.
    mat			- Input: Matrix used for the conversion.
    const_args		- Input: Construction arguments structure.
    unumpars		- Input: Number of parameters in the U-direction
                           at which to compute.
    upars		- Input: The array of parameter values in the U-
                           direction.
    vnumpars		- Input: Number of parameters in the V-direction
                           at which to compute.
    vpars		- Input: The array of parameter values in the V-
                           direction.
    displen		- Input: The length of the tangents and normals
                           for output.
    dirpt		- Input: If normals requested, gives the direction
                           of normals output. NULL if natural normals
                           requested.
    comp_tangent	- Input: If TRUE, Tangent(s) are requested.
    comp_normal		- Input: If TRUE, Normal(s) are requested.
    tanorm_poly		- Output: The tangent(s) and/or normal(s) as
                           polyline-strings. See notes.
                           (=NULL if not required, else memory ptr)
    tanorm_obj		- Output: The tangent(s) and/or normal(s) as
                           objects.
                           (=NULL if not required, else memory ptr)


  RETURN VALUE

    EMS_S_Success - 
     if all was well.

    EMS_E_InvalidArg - 
     if an invalid combination was obtained on the argument list.
    EMS_E_NoDynamicMemory - 
     if dynamic memory allocation failed.   
    EMS_E_BSerror - 
     a call to BS-math failed.
    EMS_E_Fail - 
     any other error.

  NOTES

    If a polyline-string buffer is provided, the memory is allocated as:

           unumpars * vnumpars *
           ((comp_tangent && comp_normal ? 5 : 0) +
            (comp_tangent && !comp_normal ? 3 : 0) +
            (comp_normal && !comp_tangent ? 2 : 0) +
            (!comp_tangent && !comp_normal ? 1 : 0)) *
           sizeof (IGRpoint)

    The points are either 5 (tangents and normal) or 3 (tangents) or 
    2 (normal) or 1 (surface evals) point sets, that are output. These 
    sets are output in row major order. In case of

       i) Tangents and normals - 
            pt1 is the endpoint of tangent in U-direction.
            pt2 is the point on the surface.
            pt3 is the endpoint of tangent in V-direction.
            pt4 is the point on the surface.
            pt5 is the endpoint of the normal.

      ii) Tangents only -
            pt1 is the endpoint of tangent in U-direction.
            pt2 is the point on the surface.
            pt3 is the endpoint of tangent in V-direction.

     iii) Normal only -
            pt1 is the point on the surface.
            pt2 is the endpoint of the normal.

      iv) None of the above -
            pt1 is the point on the surface.
            


     If an object buffer is provided, the memory is allocated as:

           numpars * sizeof (GRobjid)


     Future implementation:


       i) An additional argument to be provided on the argument list to 
          accept pairs of (u, v) parameter values, at which the output is 
          to be computed.

      ii) The incoming array of parameters to be sorted only when a matrix
          of parametric points has been implied.

     iii) When the incoming array is sorted, it should be a local copy that
          is used. That is, the caller gets back what it passed in as
          read-only data.

  ALGORITHM
 
    Get the the abstract geometry buffer. Allocate space where needed,
    for the call to the math function. Call the math function. Fill in
    the requisite output memory areas.

  HISTORY

    SS : 10/03/86 : Design date.

    dhm : 1/20/89 : Took out place where const_args->msg's address was
                    being changed.  This can cause memory faults.
    NP  :08/26/92 : Modified for ANSI compliance. Added typecast in GRgetabsg.
*/

class implementation EMSsubbs;

#include "EMS.h"
#include "msdef.h"
#include <stdio.h>
#include "OMmacros.h"
#include "gocmacros.h"
#include "bserr.h"
#include "emsdef.h"
#include "EMSmsgdef.h"

/*
 * Constant defining the number of points for which static space is already
 * allocated for use as temporary buffer.
 */

#define LOCAL_NUM_POINTS  20

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMsftanorm (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
                   struct GRvg_construct *const_args; IGRlong unumpars;
                   IGRdouble upars[]; IGRlong vnumpars; IGRdouble vpars[];
                   IGRdouble displen; IGRdouble *dirpt;
                   IGRboolean comp_tangent; IGRboolean comp_normal;
                   IGRdouble *outpoly; GRobjid *outobj)
{
  IGRboolean stat_func, in_class_attr, localpts_malloced;
  IGRshort numpts_per_pt;
  IGRlong i, j, k, l, totalpts;
  IGRlong stat_OM, msg_loc, dumdum;
  IGRlong frominx, toinx;
  IGRdouble *pts, tempval, temp_pts[15], ptsmem[3*LOCAL_NUM_POINTS];
  struct IGRbsp_surface *srf;
  struct IGRpolyline temp_poly;
  struct GRid temp_id;
  extern   void BSsfarrevt();
 extern  void  BSsfarrevnt();
  extern void   BSsfarrevnd();
  extern void   BSsfarrev0();
  extern   IGRboolean BSquicksort();
  IGRint EMoutput_linestring();


  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  pts = NULL;
  localpts_malloced = FALSE;

  /*
   * Get the abstract geometry of this
   * object. 
   */

  GRgetabsg (&msg_loc, mattyp, mat, (IGRchar **)&srf, dumdum);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
  srf->num_boundaries = 0;

  /*
   * Sort the array of incoming parameters
   * so that they are all increasing monotonically.
   * (Math routine expects them this way).
   */

  frominx = 0;
  if (toinx = unumpars-1)
    {
    stat_func = BSquicksort (&msg_loc, &frominx, &toinx, (IGRint *) &unumpars,
                 upars);
    EMerr_hndlr (!stat_func || msg_loc != BSSUCC, *msg, EMS_E_BSerror,
     ret_end);
    }

  if (toinx = vnumpars-1)
    {
    stat_func = BSquicksort (&msg_loc, &frominx, &toinx, (IGRint *) &vnumpars,
                 vpars);
    EMerr_hndlr (!stat_func || msg_loc != BSSUCC, *msg, EMS_E_BSerror,
     ret_end);
    }

  /*
   * Allocate memory. All memory has to be locally allocated for returning
   * normal or tangents, regardless. This, because the math-function returns
   * these in a manner not directly suitable for output. If the total
   * number of points is less than the static array availble, use this.
   */

  totalpts = unumpars * vnumpars;
  if (comp_tangent || comp_normal)
    {
    numpts_per_pt = (comp_tangent && comp_normal ? 4 :
                     (comp_tangent && !comp_normal ? 3 : 
                      /* comp_normal && !comp_tangent */ 2));
    if (totalpts * numpts_per_pt > LOCAL_NUM_POINTS)
      {
      pts = (IGRdouble *) om$malloc (size = totalpts * numpts_per_pt *
             sizeof (IGRpoint));
      EMerr_hndlr (! pts, *msg, EMS_E_NoDynamicMemory, ret_end);
      localpts_malloced = TRUE;
      }
    else
      pts = ptsmem;
    }
  else
    {
    if (!outpoly)
      {
      pts = (IGRdouble *) om$malloc (size = totalpts * sizeof (IGRpoint));
      EMerr_hndlr (! pts, *msg, EMS_E_NoDynamicMemory, ret_end);
      localpts_malloced = TRUE;
      }
    else
      pts = outpoly;
    }

  /* 
   * Call the appropriate math
   * functions.  
   */

  if (comp_tangent && comp_normal)
    {
    BSsfarrevnt (srf, (IGRint) unumpars, upars, (IGRint) vnumpars, vpars,
     displen, dirpt, pts, &msg_loc);
    }
  else if (comp_tangent)
    {
    BSsfarrevt (srf, (IGRint) unumpars, upars, (IGRint) vnumpars, vpars,
     displen, pts, &msg_loc);
    }
  else if (comp_normal)
    {
    BSsfarrevnd (srf, (IGRint) unumpars, upars, (IGRint) vnumpars, vpars,
     displen, dirpt, pts, &msg_loc);
    }
  else
    {
    BSsfarrev0 (&msg_loc, srf, (IGRint) unumpars, upars, (IGRint) vnumpars, 
     vpars, pts);
    }
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

   
  /*
   * Make the output buffers, the
   * space for which is assumed 
   * allocated.
   */

  if (outpoly)
    {
    numpts_per_pt = (comp_tangent && comp_normal ? 5 :
                     (comp_tangent && !comp_normal ? 3 : 
                      /* comp_normal && !comp_tangent */ 2));
    for (i=0, l=0; i<vnumpars; i++)
      for (j=0; j<unumpars; j++)
        {
        frominx = (i*unumpars + j)*3;
        toinx = (l++)*numpts_per_pt*3;
        for (k=0; k<3; k++)
          {
          if (comp_tangent && comp_normal)
            {
            outpoly[toinx + 0 + k] = pts[totalpts*3 + frominx + k];
            outpoly[toinx + 3 + k] = pts[0          + frominx + k];
            outpoly[toinx + 6 + k] = pts[totalpts*6 + frominx + k];
            outpoly[toinx + 9 + k] = pts[0          + frominx + k];
            outpoly[toinx + 12+ k] = pts[totalpts*9 + frominx + k];
            }
          else if (comp_tangent && !comp_normal)
            {
            outpoly[toinx + 0 + k] = pts[totalpts*3 + frominx + k];
            outpoly[toinx + 3 + k] = pts[0          + frominx + k];
            outpoly[toinx + 6 + k] = pts[totalpts*6 + frominx + k];
            }
          else if (comp_normal && !comp_tangent)
            {
            outpoly[toinx + 0 + k] = pts[0          + frominx + k];
            outpoly[toinx + 3 + k] = pts[totalpts*3 + frominx + k];
            }
          /* 
           * else !comp_tangent && !comp_normal 
           * in which case nothing needs to be 
           * done
           */
          }
        }
    }

  if (outobj)
    {
    const_args->newflag = FALSE;
    in_class_attr = const_args->class_attr ? TRUE : FALSE;
    temp_poly.num_points = (comp_tangent && comp_normal ? 5 : 
                            (comp_tangent && !comp_normal ? 3 :
                             (comp_normal && !comp_tangent ? 2 : 
                              /* !comp_normal && !comp_tangent */ 1)));
    temp_poly.points = temp_pts;
    for (i=0, l=0; i<vnumpars; i++)
      for (j=0; j<unumpars; j++)
        {
        frominx = (i*unumpars + j)*3;
        for (k=0; k<3; k++)
          {
          if (comp_tangent && comp_normal)
            {
            temp_pts[0 + k] = pts[totalpts*3 + frominx + k];
            temp_pts[3 + k] = pts[0          + frominx + k];
            temp_pts[6 + k] = pts[totalpts*6 + frominx + k];
            temp_pts[9 + k] = pts[0          + frominx + k];
            temp_pts[12+ k] = pts[totalpts*9 + frominx + k];
            }
          else if (comp_tangent && !comp_normal)
            {
            temp_pts[0 + k] = pts[totalpts*3 + frominx + k];
            temp_pts[3 + k] = pts[0          + frominx + k];
            temp_pts[6 + k] = pts[totalpts*6 + frominx + k];
            }
          else if (comp_normal && !comp_tangent)
            {
            temp_pts[0 + k] = pts[0          + frominx + k];
            temp_pts[3 + k] = pts[totalpts*3 + frominx + k];
            }
          else /* !comp_tangent && !comp_normal */
            temp_pts[0 + k] = pts[0          + frominx + k];
          }

        if (! in_class_attr) const_args->class_attr = NULL;
        if (temp_poly.num_points > 1)
          stat_OM = EMoutput_linestring (&msg_loc, my_id, const_args, 1,
                     &temp_poly, &temp_id);
        else
          stat_OM = EMoutput_point (&msg_loc, my_id, const_args, 1,
                     temp_poly.points, &temp_id);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_Fail, ret_end);
        
        outobj[l++] = temp_id.objid;
        }
    }

ret_end:
  if (pts && localpts_malloced)
    om$dealloc (ptr = pts);

  EMWRAPUP (*msg, stat_OM, "EMSsubbs.EMsftanorm");
  return (stat_OM);
}

end implementation EMSsubbs;
