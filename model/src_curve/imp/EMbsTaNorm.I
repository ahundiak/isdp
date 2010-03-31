/* 
 * DESCRIPTION
 *        
 *        This method outputs the normals and tangents, computed in
 *     general, for an array of parameter values of this curve.  The parameter
 *     values are determined by dividing the starting and ending
 *     parameter values into a array of equally spaced parameter values.  These
 *     are returned as polyline-string and/or second-order B-spline objects.
 *     Two Boolean flags control the computation of tangents and/or normals.
 *     The correct amount and form of memory has to be allocated by the user.
 *     If an output of a certain type is not desired (polylines or objects),
 *     the corresponding output pointer MUST be set to NULL.
 *
 *        An important side-effect of this method is the evaluation of the
 *     points on the curve itself. Setting both the Boolean flag to FALSE,
 *     would imply that only the curve needs to be evaluated and returned.
 *     If objects are to be output they are returned as point objects, if 
 *     they are to be returned as polyline-strings, they are returned as a
 *     buffer of points.
 *
 *        The memory allocations for this call and interpretaion of the
 *     output is explained in the notes.
 *
 * RETURN VALUES
 * 
 *      *msg         IGRlong        return code.
 *                                   - MSSUCC if all was well.
 *                                   - MSINARG 
 *                                   - MSNOMEM if memory allocation
 *                                        failed.   
 *                                   - MSFAIL on any other error.
 *
 *      *tanorm_poly IGRdouble      The tangent(s) and/or normal(s) as
 *                                   polyline-strings. See notes.
 *                                   (=NULL if not required, else memory ptr)
 * 
 *      *tanorm_obj  GRobjid        The tangent(s) and/or normal(s) as
 *                                   objects.
 *                                   (=NULL if not required, else memory ptr)
 * NOTES
 *
 *       If a polyline-string buffer is provided, the memory is allocated as:
 *
 *           numpars *
 *           {(comp_normal ? 1 : 0) + (comp_tangent ? 1 : 0) + 1} * 
 *           sizeof (IGRpoint)
 * 
 *     The points are either 3 or 2 or 1 point sets, that are output. In
 *     a single point set it is the evaluated point on the curve. In 
 *     a 2 point set the first point is the point on the curve and the 
 *     second is the end-point of the tangent or the normal. In a 3 point set
 *     the first point is the tangent endpoint, second is the point on the
 *     curve and the third id the normal endpoint.
 *
 *       If an object buffer is provided, the memory is allocated as:
 *
 *           numpars * sizeof (GRobjid)
 *
 * BUGS
 *
 *     Closed curves are not supported properly.  The mid_parm is presently
 *     ignored.
 *
 * ALGORITHM
 *
 *     Get the the abstract geometry buffer. Allocate space where needed,
 *  for the call to the math function. Call the math function. Fill in
 *  the requisite output memory areas.
 *
 * HISTORY
 *
 * 10/02/86 : ss  : The beginning
 * 01/27/87 : rlw : Modify argument list to accept start, middle, and
 *                  ending parameter values as opposed to a list of
 *                  parameter values
 * 01/20/89 : dhm : Took out place where const_args->msg's address was 
 *                  being changed.  This can cause memory faults.
 *    Sudha  06/16/93     Modified for BSprototype ansification
 */

class implementation GRbspline;

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
#include "emsdef.h"
#include "emserr.h"
#include "bscvarrevt.h"
#include "bscvarrevnt.h"
#include "bscvarrevn.h"
#include "bscvarreval.h"

method EMcvtanorm(
  IGRlong *msg; 			/* Error return code */
  IGRshort *mattyp; 			/* My matrix type */
  IGRmatrix mat;			/* My matrix */
  struct GRvg_construct *const_args; 	/* Standard construction args */
  IGRlong numpars;			/* # of parameter values desired */
  struct GRparms *start_parm;		/* Starting parameter value */
  struct GRparms *mid_parm;		/* Middle parm value, iff closed */
  struct GRparms *end_parm;		/* Ending parmater value */
  IGRdouble displen; 			/* Length of lines for output */
  IGRdouble *dirpt;			/* Direction side for normals, */
                                        /* NULL for natural normals */
  IGRboolean comp_tangent; 		/* Tangents desired? */	
  IGRboolean comp_normal;		/* Normals desired? */
  IGRdouble *outpoly; 			/* Output as polylines else NULL */
  GRobjid *outobj)			/* Output as objects else NULL */
{
  IGRboolean in_class_attr;
  IGRchar errmsg[EMMAXERRMSG_LEN];
  IGRlong i, j;
  IGRlong stat_OM, msg_loc, dumdum;
  IGRdouble (*pts1)[3], (*pts2)[2][3], (*pts3)[3][3], tempval, *pars;
  struct IGRbsp_curve *crv;
  struct IGRpolyline temp_poly;
  struct GRid temp_id;
  IGRint EMoutput_linestring(), EMoutput_point();

  *msg = MSSUCC;
  stat_OM = OM_S_SUCCESS;
  strcpy (errmsg, "GRbspline.EMcvtanorm");
  pars = NULL;
  pts1 = NULL;
  pts2 = NULL;
  pts3 = NULL;

  /*
   * Get the abstract geometry of this
   * object. 
   */

  GRgetabsg (&msg_loc, mattyp, mat, (char **) &crv, dumdum);
  EMerr_hndlr (EMis_error (msg_loc), *msg, msg_loc, ret_end);

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
     }
    else
     pars[0] = start_parm->u;
   }

  /*
   * Allocate memory if necessary.
   */

  if (comp_tangent && comp_normal)
    {
    if (!outpoly)
      {
      pts3 = (IGRdouble (*)[3][3]) om$malloc(size = numpars * 3 * sizeof (IGRpoint));
      EMerr_hndlr (! pts3, *msg, MSNOMEM, ret_end);
      }
    else
      pts3 = (IGRdouble (*)[3][3]) outpoly;
    }
  else if (comp_tangent || comp_normal)
    {
    if (!outpoly)
      {
      pts2 = (IGRdouble (*)[2][3]) om$malloc(size = numpars * 2 * sizeof (IGRpoint));
      EMerr_hndlr (! pts2, *msg, MSNOMEM, ret_end);
      }
    else
      pts2 = (IGRdouble (*)[2][3]) outpoly;
    }
  else
    {
    if (!outpoly)
      {
      pts1 = (IGRdouble (*)[3]) om$malloc(size = numpars * sizeof (IGRpoint));
      EMerr_hndlr (! pts1, *msg, MSNOMEM, ret_end);
      }
    else
      pts1 = (IGRdouble (*)[3]) outpoly;
    }

  /* 
   * Call the appropriate math
   * functions.  
   */

  if (comp_tangent && comp_normal)
    {
    if (! crv->planar) dirpt = NULL;
    BScvarrevnt (crv, pars, (IGRint) numpars, displen, dirpt, pts3, &msg_loc);
    }
  else if (comp_tangent)
    {
    BScvarrevt (crv, pars, (IGRint) numpars, displen, pts2, &msg_loc);
    }
  else if (comp_normal)
    {
    if (! crv->planar) dirpt = NULL;
    BScvarrevn (crv, pars, (IGRint) numpars, displen, dirpt, pts2, &msg_loc);
    }
  else
    {
    BScvarreval (&msg_loc, crv, pars, numpars, 0, pts1[0]);
    }
  EMerr_hndlr (msg_loc != BSSUCC, *msg, MSFAIL, ret_end);
   
  /*
   * Make the output buffers, the
   * space for which is assumed 
   * allocated.
   */

  if (comp_tangent && comp_normal)
    {
    /*
     * Only in this case is some processing
     * needed. The values in pts3[i][0][0-2] 
     * should be switched with pts3[i][1][0-2].
     */

    for (i=0; i<numpars; i++)
      for (j=0; j<3; j++)
        {
        tempval = pts3[i][0][j];
        pts3[i][0][j] = pts3[i][1][j];
        pts3[i][1][j] = tempval;
        }
    }

  if (outobj)
    {
    const_args->newflag = FALSE;
    in_class_attr = const_args->class_attr ? TRUE : FALSE;
    if (comp_tangent || comp_normal)
      {
      temp_poly.num_points = (comp_tangent && comp_normal ? 3 : 2);
      for (i=0; i<numpars; i++)
        {
        temp_poly.points = (comp_tangent && comp_normal ? &pts3[i][0][0] :
                                                        &pts2[i][0][0]);
        if (! in_class_attr) const_args->class_attr = NULL;
        stat_OM = EMoutput_linestring (&msg_loc, my_id, const_args, 1,
                   &temp_poly, &temp_id);
        EMomerr_hndlr (stat_OM, ret_end, errmsg);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, MSFAIL, ret_end);
        
        outobj[i] = temp_id.objid;
        }
      }
    else
      {
      for (i=0; i<numpars; i++)
        {
        stat_OM = EMoutput_point (&msg_loc, my_id, const_args, 1,
                   &pts1[i][0], &temp_id);
        EMomerr_hndlr (stat_OM, ret_end, errmsg);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, MSFAIL, ret_end);
        
        outobj[i] = temp_id.objid;
        }
      }
    }

  /*
   * Deallocate any locally allocated
   * memory.
   */

  if (! outpoly)
    {
    if (comp_tangent && comp_normal)
      {
      om$dealloc(ptr = pts3);
      pts3 = NULL;
      }
    else if (comp_tangent || comp_normal)
      {
      om$dealloc(ptr = pts2);
      pts2 = NULL;
      }
    else
      {
      om$dealloc(ptr = pts1);
      pts1 = NULL;
      }
    }

ret_end:
  if (pars) om$dealloc(ptr = pars);
  if (! outpoly)
    {
    if (pts3) om$dealloc(ptr = pts3);
    else if (pts2) om$dealloc(ptr = pts2);
    else if (pts1) om$dealloc(ptr = pts1);
    }
  return (stat_OM);
}

end implementation GRbspline;
