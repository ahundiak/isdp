/*
  The following functions reside in this file:

void EMbnduvpts (numpts, pts)
IGRint numpts;
IGRdouble (*pts)[2];

IGRint EMcount_degen_spans (num_pts, pts, wts, dim, tol)
IGRint dim, num_pts;
IGRdouble *pts, tol, *wts;

IGRint EMremove_degen_spans (num_inpts, inpts, inwts, 
                             num_outpts, outpts, outwts,
                             dim, tol)
IGRint dim, num_inpts, num_outpts;
IGRdouble *inpts, *outpts, *inwts, *outwts, tol;

void EMget_iso_data (msg, srf, par, const_u, uv_iso, xyz_iso)
IGRlong *msg;
struct IGRbsp_surface *srf;
IGRdouble par;
IGRboolean const_u;
struct EMSdataselect *uv_iso, *xyz_iso;

void EFfind_the_closest_pt (EMmsg, dim, ref_pt, num_pts, pts,
			    index, closest_pt)
IGRlong	*EMmsg;
IGRint dim;
IGRpoint ref_pt; 
IGRint num_pts;
IGRpoint pts[];
IGRint *index;
IGRpoint closest_pt;

IGRboolean EMis_geomequal_2dpt (pt1, pt2, tol)
IGRdouble *pt1, *pt2, tol;

IGRboolean EMis_geomequal_3dpt (pt1, pt2, tol)
IGRdouble *pt1, *pt2, tol;

IGRboolean EMis_geomequal_ndpt (pt1, pt2, dim, tol)
IGRdouble *pt1, *pt2, tol;
IGRint dim;

IGRboolean EMis_circadj (num, inx1, inx2)
IGRint num, inx1, inx2;

void EM3dto2d (data, num)
IGRdouble *data;
IGRint num;

void EM2dto3d (indata, num, outdata)
IGRdouble *indata, *outdata;
IGRint num;

IGRdouble EMsubdivval (p, inx)
IGRdouble p;
IGRint inx;

IGRdouble EM2ddotp (v1, v2)
IGRdouble *v1, *v2;

IGRboolean EMwithin_sf_bounds (uvpt, sfdef, onbdry)
IGRdouble *uvpt;
struct IGRbsp_surface *sfdef;
IGRboolean *onbdry;

IGRboolean EFpts_degenerate (num_points, points, weights, dim, tol)
IGRint num_points;
IGRdouble *points;
IGRdouble *weights;
IGRshort dim;
IGRdouble tol;

IGRboolean EMrearrange_array (array, array_num, ele_size,
                              block_inx, block_num,
                              target_inx)
IGRchar *array;
IGRint array_num, ele_size, block_inx, block_num, target_inx;

void EMswapmem (mem1, mem2, size)
IGRchar *mem1, *mem2;
IGRint size;

void EMreverse_array (array, array_num, ele_size)
IGRchar *array;
IGRint array_num, ele_size;

void EMinsert_array (msg, array, num_in_array, array_elem_size,
                     block, num_in_block, insert_index)
IGRlong *msg;
IGRchar **array;
IGRint num_in_array, array_elem_size;
IGRchar *block;
IGRint num_in_block, insert_index;

void EMremove_array (msg, array, num_in_array, array_elem_size,
                     remove_index, num_in_block)
IGRlong *msg;
IGRchar *array;
IGRint num_in_array, array_elem_size;
IGRint remove_index, num_in_block;

void EMorthovec (invec, outvec)
IGRvector invec, outvec;

IGRboolean EMcopymem (slotsize, num_inslots, inslots, 
                      slotincr, num_memslots, num_slots, slots)
IGRint slotsize, num_inslots;
IGRchar slotincr, *inslots, *num_memslots, **slots;

IGRboolean EMget_bounded_line (range, line, better_line, msg)
IGRpoint range[2];
struct IGRline *line;
IGRpoint better_line[2];
IGRlong *msg;

IGRboolean EMisElementSame (grid1, grid2, mattyp1, mattyp2, mat1, mat2)
struct GRid *grid1, *grid2;
IGRshort mattyp1, mattyp2;
IGRdouble *mat1, *mat2;

IGRboolean EMisFirstDominant (grid1, grid2, mattyp1, mattyp2, mat1, mat2)
struct GRid *grid1, *grid2;
IGRshort mattyp1, mattyp2;
IGRdouble *mat1, *mat2;

IGRboolean EMis_planar (msg, opts, obj, point, normal, tangent)
IGRlong *msg;
IGRushort opts;
struct GRid *obj;
IGRdouble *point, *normal, *tangent;

void EMsortparms (num, parms, pts, obj, os)
IGRint num;
struct GRparms *parms;
IGRpoint *pts;
GRobjid obj;
GRspacenum os;

IGRboolean EMreflectmat (refline, zvec, mat, mattyp)
struct IGRline *refline;
IGRvector zvec;
IGRmatrix mat;
IGRshort *mattyp;
*/

#include <math.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "dpdef.h"
#include "dp.h"
#include "igrdp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "madef.h"
#include "maerr.h"
#include "exdef.h"
#ifndef NT
#include "exmacros.h"
#endif
#include "bserr.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "emsdattyp.h"
#include "bsgeom_cvsf.h"

#include "alloca.h"

#define STATIC_SCRATCH_BYTES 30

#define U 0
#define V 1
 
#define X 0
#define Y 1
#define Z 2

#define CONST_U  1
#define CONST_V  2

#define SQUARE(x) ((x) * (x))

extern GRclassid OPP_EMSsubbs_class_id, OPP_GRcurve_class_id;
extern GRclassid OPP_EMScomposite_class_id;

/*
  DESCRIPTION
 
    This function snaps the input uv-pts to the 0 or 1 boundary, if the
    u/v values are found to be out of this range.
*/

void EMbnduvpts (numpts, pts)
IGRint numpts;
IGRdouble (*pts)[2];
{
  IGRint i, j;

  for (i=0; i<numpts; i++)
    for (j=U; j<=V; j++)
      {
      if (pts[i][j] < 0.0)
        pts[i][j] = 0.0;
      else if (pts[i][j] > 1.0)
        pts[i][j] = 1.0;
      }
  return;
}

/*
  DESCRIPTION

    Given a pointer to an array of pointers, this function frees up
    memory pointed to by the pointers in the array and the array itself
*/

void EMfree_double_array (num, array)
IGRint num;
IGRchar **array;
{
  IGRint i;
  
  if (array)
    {
    for (i=0; i<num; i++)
      if (array[i])
        om$dealloc (ptr = array[i]);
    om$dealloc (ptr = array);
    }
  return;
}

/*
  DESCRIPTION

    Given a pointer to an array of BSgeom_bsp_curve structures,
    this function frees up memory pointed to by these structures and then
    frees up this array itself.
*/

void EMfree_bsgmcv_array (num, bsgmcvs)
IGRint num;
struct BSgeom_bsp_curve *bsgmcvs;
{
  IGRint i;
  IGRlong msg_loc;

  if (bsgmcvs)
    {
    for (i=0; i<num; i++)
      {
      if (bsgmcvs[i].bspcv)
        BSfreecv (&msg_loc, bsgmcvs[i].bspcv);
      if (bsgmcvs[i].array1)
        om$dealloc (ptr = bsgmcvs[i].array1);
      }
    om$dealloc (ptr = bsgmcvs);
    }
  return;
}   

/*
  DESCRIPTION
  
    Given a set of points (may or may not be weighted), this function counts
    the number of degenerate spans w.r.t the given tolerance
*/

IGRint EMcount_degen_spans (num_pts, pts, wts, dim, tol)
IGRint dim, num_pts;
IGRdouble *pts, tol, *wts;
{
  IGRint i, j, k, count;
  IGRdouble *pt1mem=NULL, *pt2mem=NULL, *pt1, *pt2, *ptr1, *ptr2;
  IGRdouble delta, seglen;
  IGRboolean EMis_geomequal_2dpt(), EMis_geomequal_3dpt();

  count = 0;

  /*
   * Initialize
   */

  ptr1 = pts;
  ptr2 = ptr1 + dim;
  if (wts)
    {
    pt1mem = (IGRdouble *) alloca (dim * sizeof (IGRdouble));
    pt2mem = (IGRdouble *) alloca (dim * sizeof (IGRdouble));
    }

  /*
   * Unweight the points if needed and check each span for
   * degeneracy. If found, add to the count
   */

  for (i=0, j=1; j<num_pts; i++, j++)
    {
    if (wts)
      {
      pt1 = pt1mem;
      pt2 = pt2mem;
      for (k=0; k<dim; k++)
        {
        pt1[k] = ptr1[k] / wts[i];
        pt2[k] = ptr2[k] / wts[j];
        }
      }
    else
      {
      pt1 = ptr1;
      pt2 = ptr2;
      }

    if (dim == 2)
      count += (IGRint) EMis_geomequal_2dpt (pt1, pt2, tol);
    else if (dim == 3)
      count += (IGRint) EMis_geomequal_3dpt (pt1, pt2, tol);
    else
      {
      seglen = 0.0;
      for (k=0; k<dim; k++)
        {
        delta = pt2[k] - pt1[k];
        seglen += delta * delta;
        }
      count += ((IGRint) (sqrt (seglen) <= tol));
      }

    ptr1 += dim;
    ptr2 += dim;
    }

  return (count);
}

/*
  DESCRIPTION
 
    Given an input set of points (may or may not be weighted), this function
    removes all degenerate spans (wrt the input tol) and returns the
    "cleaned" up set of points (and the corresponding weights) in the 
    output array. The memory for the output array is assumed to be sufficiently
    allocated by the caller. The first and the last points are always
    maintained, unless the entire array of points is degenerate. In this
    latter case, number of points returned is zero.
*/

IGRint EMremove_degen_spans (num_inpts, inpts, inwts, 
                             num_outpts, outpts, outwts,
                             dim, tol)
IGRint dim, num_inpts, *num_outpts;
IGRdouble *inpts, *outpts, *inwts, *outwts, tol;
{
  IGRboolean is_degen=FALSE;
  IGRint i, inx, degen_count;
  IGRdouble *pt1mem=NULL, *pt2mem=NULL, *pt1, *pt2;
  IGRdouble *wptr=NULL, *wptr1=NULL, *wptr2=NULL;
  IGRdouble *ptr, *ptr1, *ptr2;
  IGRboolean EMis_geomequal_ndpt();

  /*
   * Initialize
   */

  ptr1 = inpts;
  ptr2 = ptr1 + dim;
  ptr = outpts;

  if (inwts)
    {
    pt1mem = (IGRdouble *) alloca (dim * sizeof (IGRdouble));
    pt2mem = (IGRdouble *) alloca (dim * sizeof (IGRdouble));

    wptr1 = inwts;
    wptr2 = wptr1 + 1;
    wptr = outwts;
    }

  *num_outpts = 0;
  degen_count = 0;

  /*
   * Add the first point into the output array
   */

  OM_BLOCK_MOVE (ptr1, ptr, dim * sizeof (IGRdouble));
  ptr += dim;
  if (inwts && outwts)
    {
    *wptr = *wptr1;
    ++wptr;
    }
  (*num_outpts)++;

  /*
   * Unweight the points if needed and check each span for degeneracy. If
   * the span is not degenerate add the end-point of this span (pt2) to the 
   * output array. 
   */
  
  for (inx=0; inx<num_inpts-1; inx++)
    {
    if (inwts)
      {
      pt1 = pt1mem;
      pt2 = pt2mem;
      for (i=0; i<dim; i++)
        {
        pt1[i] = ptr1[i] / *wptr1;
        pt2[i] = ptr2[i] / *wptr2;
        }
      }
    else
      {
      pt1 = ptr1;
      pt2 = ptr2;
      }

    if (!(is_degen = EMis_geomequal_ndpt (pt1, pt2, dim, tol)))
      {
      OM_BLOCK_MOVE (ptr2, ptr, dim * sizeof (IGRdouble));
      ptr += dim;
      if (inwts && outwts)
        {
        *wptr = *wptr2;
        ++wptr;
        }
      (*num_outpts)++;
      }

    if (is_degen)
      degen_count++;

    ptr1 += dim;
    ptr2 += dim;
    if (inwts && outwts)
      {
      ++wptr1;
      ++wptr2;
      }
    }

  /*
   * If the last span was degenerate, change the last point in the output
   * array to the last point of the input array.
   */

  if (is_degen)
    {
    OM_BLOCK_MOVE (&inpts[dim*(num_inpts-1)], &outpts[dim*((*num_outpts)-1)],
     dim * sizeof (IGRdouble));
    if (inwts && outwts)
      outwts[(*num_outpts)-1] = inwts[num_inpts-1];
    }

  return (degen_count);
}

/*
  DESCRIPTION

    Given a surface (srf) and a u or a v parameter value (par), this 
    function extracts the iso-curve either in the const-u or const-v direction,
    specified by a Boolean flag (const_u). The output can be in either or
    both uv and xyz.
*/

void EMget_iso_data (msg, srf, par, const_u, uv_iso, xyz_iso)
IGRlong *msg;
struct IGRbsp_surface *srf;
IGRdouble par;
IGRboolean const_u;
struct EMSdataselect *uv_iso, *xyz_iso;
{
  IGRboolean tst_plan;
  IGRshort isodir, order; 
  IGRint num_poles;
  IGRlong msg_loc, stat;
  IGRdouble *pts;
  struct IGRpolyline *py;
  struct IGRbsp_curve *isocv;

  *msg = EMS_S_Success;
  
  isocv = NULL;

  if (uv_iso)
    {
    py = (struct IGRpolyline *) om$malloc (size = 
          sizeof (struct IGRpolyline));
    pts = (IGRdouble *) om$malloc (size = 4 * sizeof (IGRdouble));
    EMerr_hndlr (!py || !pts, *msg, EMS_E_NoDynamicMemory, ret_end);
    py->num_points = 2;
    py->points = pts;
    pts[const_u ? 1 : 0] = 0.0;
    pts[const_u ? 3 : 2] = 1.0;
    pts[const_u ? 0 : 1] = pts[const_u ? 2 : 3] = par;
    uv_iso->data.poly = py;
    uv_iso->datatype = EMSdata_poly2d;
    }

  if (xyz_iso)
    {
    order = const_u ? srf->v_order : srf->u_order;
    num_poles =  const_u ? srf->v_num_poles : srf->u_num_poles;
    BSalloccv (order, num_poles, srf->rational, 0, &isocv, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

    tst_plan = TRUE;
    isodir = const_u ? CONST_U : CONST_V;
    BSconstprcv (&msg_loc, srf, &isodir, &par, &tst_plan, isocv);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

    xyz_iso->data.curve = isocv;
    xyz_iso->datatype = EMSdata_curve3d;
    isocv = NULL;
    }

ret_end:
  if (isocv)
    BSfreecv (&msg_loc, isocv);

  stat = TRUE;
  EMWRAPUP (*msg, stat, "EMget_iso_data");
  return;
}


/*
  DESCRIPTION:
 
    Given an array of points (pts), and a reference point (ref_pt), determine
    the closest point to the reference point, within the array of points.
    The closest point is output as an index (index) of the point in the
    input array. The closest point (closest_pt) is also returned.
*/

void EFfind_the_closest_pt (EMmsg, dim, ref_pt, num_pts, pts,
			    index, closest_pt)
IGRlong		*EMmsg;
IGRint		dim;
IGRpoint	ref_pt; 
IGRint		num_pts;
IGRpoint	pts[];
IGRint		*index;
IGRpoint	closest_pt;
{
  IGRint	ii,
		jj,
		loc_index;
  IGRdouble	mdist_sq,
		dist_sq;

  *EMmsg = EMS_S_Success;

  /*
   * First, check for any invalid arguments.
   */
      if( !num_pts || num_pts < 0 )
      {
	*EMmsg = EMS_E_InvalidArg;
	goto wrapup;
      }

  /*
   * Initialize the closest point to be the first in the array of points.
   */
      loc_index = 0;
      mdist_sq = 0.0;
      for( jj = 0; jj < dim; jj++ ) 
      {
         mdist_sq += SQUARE( ref_pt[jj] - pts[0][jj] );
      }

  /*
   * Now, check the remaining points in the array of pints.
   */
      for( ii = 1; ii < num_pts; ii++ )
      {
         dist_sq = 0;
         for( jj = 0; jj < dim; jj++ ) 
            dist_sq += SQUARE(ref_pt[jj] - pts[ii][jj]);

         if( dist_sq < mdist_sq )
         {
           loc_index = ii;
           mdist_sq = dist_sq;
         }
      }

  /*
   * Initialize the output.
   */
      if( closest_pt )
      for( jj = 0; jj < dim; jj++ ) closest_pt[jj] = pts[loc_index][jj];

      if( index ) *index = loc_index;

wrapup:
   return;
}


/*
 * This function, performs the test for two points being within tolerance. 
 * It will trivially reject points in a lot of cases (apparent from
 * the code below). There is a 2d, 3d and an n-dimension version of the
 * function.
 */

IGRboolean EMis_geomequal_2dpt (pt1, pt2, tol)
IGRdouble *pt1, *pt2, tol;
{
  IGRdouble delx, dely;

  if (fabs (delx = pt1[X] - pt2[X]) > tol)
    return (FALSE);
  if (fabs (dely = pt1[Y] - pt2[Y]) > tol)
    return (FALSE);
  if (delx*delx + dely*dely > tol*tol)
    return (FALSE);
  else
    return (TRUE);
}

IGRboolean EMis_geomequal_3dpt (pt1, pt2, tol)
IGRdouble *pt1, *pt2, tol;
{
  IGRdouble delx, dely, delz;

  if (fabs (delx = pt1[X] - pt2[X]) > tol)
    return (FALSE);
  if (fabs (dely = pt1[Y] - pt2[Y]) > tol)
    return (FALSE);
  if (fabs (delz = pt1[Z] - pt2[Z]) > tol)
    return (FALSE);
  if (delx*delx + dely*dely + delz*delz > tol*tol)
    return (FALSE);
  else
    return (TRUE);
}


IGRboolean EMis_geomequal_ndpt (pt1, pt2, dim, tol)
IGRdouble *pt1, *pt2;
IGRint dim;
IGRdouble tol;
{
  IGRboolean is_degen;
  IGRint i;
  IGRdouble delta, seglen;

  if (dim == 2)
    is_degen= EMis_geomequal_2dpt (pt1, pt2, tol);
  else if (dim == 3)
    is_degen = EMis_geomequal_3dpt (pt1, pt2, tol);
  else
    {
    seglen = 0.0;
    for (i=0; i<dim; i++)
      {
      delta = pt2[i] - pt1[i];
      seglen += delta * delta;
      }
    is_degen = sqrt (seglen) <= tol;
    }

  return (is_degen);
}

/*
 * This function return TRUE if the two element indices are adjacent in a 
 * circular array of "num" elements.
 */

IGRboolean EMis_circadj (num, inx1, inx2)
IGRint num, inx1, inx2;
{
  if ((inx1 + 1) % num == inx2 ||
      (inx2 + 1) % num == inx1)
    return (TRUE);
  else
    return (FALSE);
}

/*
 * This function takes in a buffer containing 3D-double data and converts
 * it into 2D-double data. The 3rd dimension is the one that is ignored.
 * The conversion is done in place.
 */

void EM3dto2d (data, num)
IGRdouble *data;
IGRint num;
{
  IGRint i, j, inxlim;
  IGRint blksize;

  blksize = 2 * sizeof (IGRdouble);
  inxlim = num * 3;
  for (i=3, j=2; i<inxlim; i+=3, j+=2)
    OM_BLOCK_MOVE (&data[i], &data[j], blksize);
}


/*
 * This function takes 2D-double data and converts it into 3D-double
 * data by adding in a 0.0 for the 3rd dimension. A user supplied
 * output buffer (different from the input) is expected.
 */

void EM2dto3d (indata, num, outdata)
IGRdouble *indata, *outdata;
IGRint num;
{
  IGRint i, j, inxlim;
  IGRint blksize;

  blksize = 2 * sizeof (IGRdouble);
  inxlim = num * 2;
  for (i=0, j=0; i<inxlim; i+=2, j+=3)
    {
    OM_BLOCK_MOVE (&indata[i], &outdata[j], blksize);
    outdata[j+2] = 0.0;
    }
}


/*
 * Given a mid-value: P, this function returns a value in the range
 * [0, 2*P]. The return value is computed using a calling index. An
 * index of zero returns P itself. Odd indices return values less than
 * P and even indices return values greater than P. The computation
 * is by binary subdivision and is repeatable (not random).
 */

IGRdouble EMsubdivval (p, inx)
IGRdouble p;
IGRint inx;
{
  if (inx == 0)
    return (p);
  else if (inx % 2)
    return (p - EMsubdivval (p / 2.0, inx / 2));
  else
    return (p + EMsubdivval (p / 2.0, (inx - 2) / 2));
}


IGRdouble EM2ddotp (v1, v2)
IGRdouble *v1, *v2;
{
  return (v1[X] * v2[X] + v1[Y] * v2[Y]);
}

/*
 * This function accepts a uv-point and a surface definition and
 * returns a T/F indicating whether it is within bounds of a given surface's 
 * uv-space. If it lies exactly on the boundary (zero-tolerance) then a T/F
 * argument is set.
 */

IGRboolean EMwithin_sf_bounds (uvpt, sfdef, onbdry)
IGRdouble *uvpt;
struct IGRbsp_surface *sfdef;
IGRboolean *onbdry;
{
  IGRdouble u, v, u_lb, v_lb, u_ub, v_ub;

  u_lb = sfdef->u_knots[sfdef->u_order-1];
  v_lb = sfdef->v_knots[sfdef->v_order-1];
  u_ub = sfdef->u_knots[sfdef->u_num_poles];
  v_ub = sfdef->v_knots[sfdef->v_num_poles];

  u = uvpt[0];
  v = uvpt[1];

  if (u < u_lb || v < v_lb || u > u_ub || v > v_ub)
    {
    *onbdry = FALSE;
    return (FALSE);
    }
  else
    {
    if (u < u_lb + MINDOUBLE ||
        v < v_lb + MINDOUBLE ||
        u > u_ub - MINDOUBLE ||
        v > v_lb - MINDOUBLE)
      *onbdry = TRUE;
    return (TRUE);
    }
}


/*
 * A general function that  checks if the incoming set of poles (points),
 * weighted or non-weighted (for the latter the weights argument is
 * set to NULL), represents a degenerate line-string w.r.t to the given
 * tolerance. The dimension of the points can be specified.
 */

IGRboolean EFpts_degenerate (num_points, points, weights, dim, tol)
IGRint num_points;
IGRdouble *points;
IGRdouble *weights;
IGRshort dim;
IGRdouble tol;
{
  IGRdouble delta, cumdist, seglen;
  IGRint inxlim, i, j, k, l;  
 
  cumdist = 0.0;
  inxlim = num_points-1;
  for (i=0, j=dim, k=0; k<inxlim; i+=dim, j+=dim, k++)
    {
    seglen = 0.0;
    for (l=0; l<dim; l++)
      {
      if (weights)
        delta = points[j+l]/weights[k+1] - points[i+l]/weights[k];
      else
        delta = points[j+l] - points[i+l];
      seglen += delta * delta;
      }
    seglen = sqrt (seglen);

    cumdist += seglen;
    if (fabs (cumdist) > tol)
      return (FALSE);
    }
  return (TRUE);
}


/*
  This function takes in a pointer to an array. The size of each element
  is input. The caller specifies where a certain contiguos set of
  array elements needs to be rearranged to. Also a simple function to
  swap contents of memory, is defined.
*/

IGRboolean EMrearrange_array (array, array_num, ele_size,
                              block_inx, block_num,
                              target_inx)
IGRchar *array;
IGRint array_num, ele_size, block_inx, block_num, target_inx;
{
  IGRchar *scratch, scratch_store[STATIC_SCRATCH_BYTES];
  IGRboolean stat_func;
  IGRint blksize;

  stat_func = TRUE;
  scratch = NULL;

  EMerr_hndlr (block_inx + block_num > array_num, stat_func, FALSE, ret_end);

  if ((blksize = block_num * ele_size) > STATIC_SCRATCH_BYTES)
    scratch = om$malloc (size = blksize);
  else
    scratch = scratch_store;
  EMerr_hndlr (!scratch, stat_func, FALSE, ret_end);

  blksize = block_num * ele_size;
  OM_BLOCK_MOVE (&array[block_inx], scratch, blksize);
  OM_BLOCK_MOVE (&array[target_inx], &array[target_inx + block_num], blksize);
  OM_BLOCK_MOVE (scratch, &array[target_inx], blksize);

ret_end:
  if (scratch && scratch != scratch_store)
    om$dealloc (ptr = scratch);
  return (stat_func);
}

void EMswapmem (mem1, mem2, size)
IGRchar *mem1, *mem2;
IGRint size;
{
  IGRchar *scratch;

  scratch = (IGRchar *) alloca (size);
  OM_BLOCK_MOVE (mem1, scratch, size);
  OM_BLOCK_MOVE (mem2, mem1, size);
  OM_BLOCK_MOVE (scratch, mem2, size);

  return;
}


/*
  DESCRIPTION

    The following function takes an array of elements whose size is
    "ele_size" (in bytes) and reverses the order in which the elements
    occur

  HISTORY

    SS  :  02/22/91  :  Creation
*/


void EMreverse_array (array, array_num, ele_size)
IGRchar *array;
IGRint array_num, ele_size;
{
  IGRint i, j, count;
  IGRchar *scratch, scratch_store[STATIC_SCRATCH_BYTES];

  if (ele_size > STATIC_SCRATCH_BYTES)
    scratch = om$malloc (size = ele_size);
  else
    scratch = scratch_store;

  count = array_num / 2;
  for (i=0, j=(array_num-1)*ele_size; i<count; i+=ele_size, j-=ele_size)
    {
    OM_BLOCK_MOVE (&array[i], scratch, ele_size);
    OM_BLOCK_MOVE (&array[j], &array[i], ele_size);
    OM_BLOCK_MOVE (scratch, &array[j], ele_size);
    }
 
  if (scratch != scratch_store)
    om$dealloc (ptr = scratch);

  return;
}

/*
  DESCRIPTION

    The following function takes an array of elements whose size is
    "array_elem_size" (in bytes) and another set of 'similar' elements that
    must be inserted into this array. The index of at which these elements
    must be inserted, "insert_index", is specified. The first element in the
    "block" which was inserted becomes the "insert_index"th element of
    the array. 
    
  NOTES

    EMS_E_OutOfBounds is returned if "insert_index" is out of bounds. An
    EMS_E_NoDynamicMemory is returned if the re-alloc failed.

  ASSUMPTIONS

    The input array is a malloced array (since a realloc is going to be
    performed).

  HISTORY

    SS  :  03/07/93  :  Creation
*/

void EMinsert_array (msg, array, num_in_array, array_elem_size,
                     block, num_in_block, insert_index)
IGRlong *msg;
IGRchar **array;
IGRint num_in_array, array_elem_size;
IGRchar *block;
IGRint num_in_block, insert_index;
{
  IGRint blksize, from_index, to_index;

  *msg = EMS_S_Success;

  EMerr_hndlr (insert_index < 0 || insert_index > num_in_array, *msg,
   EMS_E_InvalidArg, ret_end);

  *array = om$realloc (ptr = *array, 
            size = (num_in_array + num_in_block) * array_elem_size);
  EMerr_hndlr (!*array, *msg, EMS_E_NoDynamicMemory, ret_end);

  if (insert_index != num_in_array)
    {
    from_index = insert_index * array_elem_size;
    to_index = (insert_index + num_in_block) * array_elem_size;
    blksize = (num_in_array - insert_index) * array_elem_size;
    OM_BLOCK_MOVE (&array[from_index], &array[to_index], blksize);
    }
  OM_BLOCK_MOVE (block, &array[insert_index],
   num_in_block * array_elem_size);

ret_end:
  return;
}


/*
  DESCRIPTION

    The following function takes an array of elements whose size is
    "array_elem_size" (in bytes) and a description of the block of
    elements to be removed from the array. The description being the
    index of the first element in the block of elements to be removed
    ("remove_index") and the number of elements in the block ("num_in_block").

  NOTE

    The memory allocation of the input array is left untouched.
    An EMS_E_OutOfBounds is returned if the remove_index is out of bounds.

  HISTORY

    SS  :  03/07/93  :  Creation
*/


void EMremove_array (msg, array, num_in_array, array_elem_size,
                     remove_index, num_in_block)
IGRlong *msg;
IGRchar *array;
IGRint num_in_array, array_elem_size;
IGRint remove_index, num_in_block;
{
  IGRint blksize, from_index, to_index;

  *msg = EMS_S_Success;

  EMerr_hndlr (remove_index < 0 || remove_index >= num_in_array-1, *msg,
   EMS_E_InvalidArg, ret_end);

  from_index = (remove_index + num_in_block) * array_elem_size;
  to_index = remove_index * array_elem_size;
  blksize = (num_in_array - (num_in_block+remove_index)) * array_elem_size;
  OM_BLOCK_MOVE (&array[from_index], &array[to_index], blksize);

ret_end:
  return;
}


/*
  DESCRIPTION

    This function takes in a unit-vector and returns another unit-vector
    which is orthogonal to this one and also closest to one of the principle 
    axes. X-axis has precedence over Y-axis has precedence over Z-axis.

  HISTORY
    
    SS  :  03/27/91  :  Creation
*/

void EMorthovec (invec, outvec)
IGRvector invec, outvec;
{ 
  IGRshort maxcoord;
  IGRlong msg_loc;
  IGRdouble max;
  extern IGRboolean BSnorvec();

  max = invec[X]; maxcoord = X;
  if (invec[Y] > max)
    {max = invec[Y]; maxcoord = Y;}
  if (invec[Z] > max)
    {max = invec[Z]; maxcoord = Z;}

  if (maxcoord == X)
    {
    outvec[X] = -invec[Y];
    outvec[Y] = invec[X];
    outvec[Z] = 0.0;
    }
  else if (maxcoord == Y)
    {
    outvec[X] = invec[Y];
    outvec[Y] = -invec[X];
    outvec[Z] = 0.0;
    }
  else
    {
    outvec[X] = invec[Z];
    outvec[Y] = 0.0;
    outvec[Z] = -invec[X];
    }
  BSnorvec (&msg_loc, outvec);

  return;
}

 
/*
  DESCRIPTION

  This function appends a given number of contiguosly placed slots (a slot
  being a logical block of memory) to another array of contiguously
  placed slots, allocating (or reallocating) memory at this target
  location. 'num_memslots' is the total size (in slots) available at the
  target location - 'slots' - and 'num_slots' is the number of slots that
  are already filled up in 'slots'. If more slot memory had to be allocated
  'num_memslots' is updated to reflect the new slot-size in slots. The
  growth rate of the slot memory is specified as 'slotincr'. If more memory
  is needed the new size is the smallest multiple of 'slot_incr' that
  can accomodate the append operation. If the status returned is FALSE,
  insufficient memory was available for this op. If 'inslots' is NULL,
  no memory copy is done; if 'slots' is NULL, no new memory allocation
  is performed and no copy is done. eg: inslots = NULL, slots = NULL, would
  have the only useful output of the new memory size required if this copy
  were to take place.
*/

IGRboolean EMcopymem (slotsize, num_inslots, inslots, 
                      slotincr, num_memslots, num_slots, slots)
IGRint slotsize, num_inslots;
IGRchar slotincr, *inslots, *num_memslots, **slots;
{
  IGRboolean stat_func;
  IGRint numreq;

  stat_func = TRUE;

  numreq = num_slots + num_inslots;
  if (*num_memslots < numreq)
    {
    numreq = (numreq / slotincr) * slotincr +
              (numreq % slotincr ? slotincr : 0);
    if (slots)
      {
      if (*num_memslots)
        *slots = om$realloc (size = numreq * slotsize, ptr = *slots);
      else
        *slots = om$malloc (size = numreq * slotsize);
      EMerr_hndlr (!*slots, stat_func, FALSE, ret_end);
      }
    *num_memslots = numreq;
    }
  if (inslots && slots)
    OM_BLOCK_MOVE (inslots, &(*slots)[num_slots * slotsize],
     num_inslots * slotsize);

ret_end:
  return (stat_func);
}


/*
 * Given a line definition, this function returns a bounded line which 
 * is based on the input range box
 */

IGRboolean EMget_bounded_line (range, line, better_line, msg)
IGRpoint range[2];
struct IGRline *line;
IGRpoint better_line[2];
IGRlong *msg;
{
 IGRboolean     status;
 IGRlong        i;
 IGRdouble      t, min_t, max_t;
 IGRpoint       corners[8], line_pt;
 extern  IGRboolean  MAptlnproj();

/*
 * Build an array which consists of the eight corner points of
 * the input range box
 */
 corners[0][0] = range[0][0];
 corners[0][1] = range[0][1];
 corners[0][2] = range[0][2];
 corners[1][0] = range[1][0];
 corners[1][1] = range[0][1];
 corners[1][2] = range[0][2];
 corners[2][0] = range[1][0];
 corners[2][1] = range[1][1];
 corners[2][2] = range[0][2];
 corners[3][0] = range[0][0];
 corners[3][1] = range[1][1];
 corners[3][2] = range[0][2];
 corners[4][0] = range[0][0];
 corners[4][1] = range[0][1];
 corners[4][2] = range[1][2];
 corners[5][0] = range[1][0];
 corners[5][1] = range[0][1];
 corners[5][2] = range[1][2];
 corners[6][0] = range[1][0];
 corners[6][1] = range[1][1];
 corners[6][2] = range[1][2];
 corners[7][0] = range[0][0];
 corners[7][1] = range[1][1];
 corners[7][2] = range[1][2];

 min_t = MAXDOUBLE;
 max_t = -MAXDOUBLE;

 for (i = 0; i < 8; i++)
  {
   status = MAptlnproj(
     msg,
     corners[i],
     line,
     line_pt,
     &t);
    if (!status) return(FALSE);
   if (i)
    {
     if (t < min_t)
      {
       min_t = t;
       better_line[0][0] = line_pt[0];
       better_line[0][1] = line_pt[1];
       better_line[0][2] = line_pt[2];
      }
     if (t > max_t)
      {
       max_t = t;
       better_line[1][0] = line_pt[0];
       better_line[1][1] = line_pt[1];
       better_line[1][2] = line_pt[2];
      }
    }
   else
    {
     min_t = t;
     max_t = t;
     better_line[0][0] = line_pt[0];
     better_line[0][1] = line_pt[1];
     better_line[0][2] = line_pt[2];
     better_line[1][0] = line_pt[0];
     better_line[1][1] = line_pt[1];
     better_line[1][2] = line_pt[2];
    }
  }
 return(TRUE);
}


/*
 * Given two objid/osnum pairs and their respective transformation
 * matrices, this function checks whether they are the same graphically.
 * It checks for similarness even in the matrix.
 */

IGRboolean EMisElementSame (grid1, grid2, mattyp1, mattyp2, mat1, mat2)
struct GRid *grid1, *grid2;
IGRshort mattyp1, mattyp2;
IGRdouble *mat1, *mat2;
{
  IGRboolean same;
  IGRint i;
 
  same = TRUE;

  if (grid1->objid == grid2->objid && grid1->osnum == grid2->osnum)
    {
    if (mattyp1 != MAIDMX || mattyp2 != MAIDMX)
      {
      for (i=0; i<16; i++)
        if (fabs (mat1[i] - mat2[i]) > MINDOUBLE)
          {
          same = FALSE;
          break;
          }
      }
    }
  else
    same = FALSE;

  return (same);
}


/*
 * Given two objid/osnum pairs and their respective transformation
 * matrices, this function checks whether the first is "greater" than
 * the other, by gauging the numbers. One will always be greater than
 * the other. If they are the same, the first one is treated as the greater.
 */

IGRboolean EMisFirstDominant (grid1, grid2, mattyp1, mattyp2, mat1, mat2)
struct GRid *grid1, *grid2;
IGRshort mattyp1, mattyp2;
IGRdouble *mat1, *mat2;
{
  IGRboolean first_dominant;
  IGRint i;
 
  first_dominant = TRUE;

  if (grid1->osnum < grid2->osnum)
    first_dominant = FALSE;
  else if (grid1->osnum == grid2->osnum)
    {
    if (grid1->objid < grid2->objid)
      first_dominant = FALSE;
    else if (grid1->objid == grid2->objid)
      {
      if (mattyp1 != MAIDMX || mattyp2 != MAIDMX)
        {
        for (i=0; i<16; i++)
          if (mat1[i] < mat2[i])
            {
            first_dominant = FALSE;
            break;
            }
          else if (mat1[i] > mat2[i])
            break;
        }
      }
    }

  return (first_dominant);
}

/*
 * This function takes as input a surface/curve object and returns 
 * a Boolean flag indicating UNIQUELY planar or not.
 *   In the case where an unambiguous plane is determinable, a "normal"
 *     can be output (but no "tangent"). "normal" output if arg is non-NULL.
 *     The return code is EMS_S_Success.
 *   In the case of a curve being a straight line a unique "normal" is not
 *     determinable but a unique "tangent" is. "tangent" output is arg is
 *     non-NULL. The return code is EMS_I_Ambiguous.
 *   In the case of a curve degenerating to a point, neither a normal nor
 *     a tangent is uniquely determinable. None output. Return code is
 *     EMS_I_Degenerate..
 *   In all cases, a point is returned that lies on the element, if point
 *     is non-NULL.
 */


#if __STDC__
#argsused
#else
/* ARGSUSED */
#endif

IGRboolean EMis_planar (msg, opts, obj, point, normal, tangent)
IGRlong *msg;
IGRushort opts;
struct GRid *obj;
IGRdouble *point, *normal, *tangent;
{
  IGRboolean is_planar, is_collin, is_degen;
  IGRshort idmattyp;
  IGRlong i, msg_loc, stat_OM;
  IGRpoint endpts[2];
  IGRvector loc_normal;
  IGRmatrix idmat;
  GRclassid classid;
  struct IGRbsp_curve *crv;
  struct IGRbsp_surface *srf;
  extern void EMidmatrix(), BStst_plan(), BScollinmn2(), BStstcvdegn();
  extern IGRboolean MAbcendpts(), BSmkvec(), BSnorvec();
  extern IGRlong EMgetabsg();
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  is_planar = FALSE;

  EMidmatrix (&msg_loc, &idmattyp, idmat);

  om$get_classid (objid = obj->objid, osnum = obj->osnum,
   p_classid = &classid);

  if (om$is_ancestry_valid (subclassid = classid, 
       superclassid = OPP_EMSsubbs_class_id) != OM_S_SUCCESS)
    {
    if (om$is_ancestry_valid (subclassid = classid, 
         superclassid = OPP_GRcurve_class_id) == OM_S_SUCCESS)
      {
      stat_OM = EMgetabsg (&msg_loc, &idmattyp, idmat, obj->osnum, obj->objid,
                 &crv);
      EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);

      if (point)
        for (i=0; i<3; i++)
          point[i] = crv->poles[i] / (crv->rational ? crv->weights[0] : 1.0);

      BStstcvdegn (crv, &is_degen, &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

      if (is_degen)
        *msg = EMS_I_Degenerate;
      else
        {
        BScollinmn2 (crv->num_poles, crv->poles, crv->weights, &is_collin,
         &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_Fail, ret_end);
      
        if (is_collin)
          {
          *msg = EMS_I_Ambiguous;
          if (tangent)
            {
            MAbcendpts (&msg_loc, crv, endpts[0], endpts[1]);
            EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_MAerror, ret_end);

            BSmkvec (&msg_loc, tangent, endpts[0], endpts[1]);
            EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_Fail, ret_end);

            BSnorvec (&msg_loc, tangent);
            EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_Fail, ret_end);
            }
          }
        else
          {
          BStst_plan (crv->num_poles, crv->poles, crv->weights, &is_planar,
           loc_normal, &msg_loc);
          EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_Fail, ret_end);

          if (is_planar && normal)
            OM_BLOCK_MOVE (loc_normal, normal, sizeof (IGRvector));
          }
        }
      }
    }
  else
    {
    stat_OM = EMgetabsg (&msg_loc, &idmattyp, idmat, obj->osnum, obj->objid,
               &srf);
    EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);

    if (point)
      for (i=0; i<3; i++)
        point[i] = srf->poles[i] / (srf->rational ? srf->weights[0] : 1.0);

    BStst_plan (srf->u_num_poles * srf->u_num_poles, srf->poles,
     srf->weights, &is_planar, loc_normal, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_Fail, ret_end);

    if (is_planar && normal)
      OM_BLOCK_MOVE (loc_normal, normal, sizeof (IGRvector));
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMis_planar");
  return (is_planar);
}

/*
  DESCRIPTION
   
    This function takes in an array of GRparms and a corresponding array
    of IGRpoint generated on a given composite curve object and sorts
    the parms and the points into increasing order.
*/

void EMsortparms (num, parms, pts, obj, os)
IGRint num;
struct GRparms *parms;
IGRpoint *pts;
GRobjid obj;
GRspacenum os;
{
  IGRuint inx_i, inx_j;
  IGRint i, j;
  IGRdouble par_i, par_j;
  IGRpoint tmppt;
  struct GRparms tmpparms;
  OM_S_CHANSELECT chan_to_comps;

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  for (i=0; i<num-1; i++)
    for (j=0; j<num-i-1; j++)
      {
      inx_i = 0;
      om$get_index (objid_c = obj, osnum_c = os, p_chanselect = &chan_to_comps,
       objid = parms[i].leaf_id.objid, indexaddr = &inx_i);

      inx_j = 0;
      om$get_index (objid_c = obj, osnum_c = os, p_chanselect = &chan_to_comps,
       objid = parms[j].leaf_id.objid, indexaddr = &inx_j);

      par_i = parms[i].u;
      par_j = parms[j].u;
      if (inx_j > inx_i || (inx_j == inx_i && par_j > par_i))
        {
        tmpparms = parms[i];
        parms[i] = parms[j];
        parms[j] = tmpparms;

        OM_BLOCK_MOVE (pts[i], tmppt, sizeof (IGRpoint));
        OM_BLOCK_MOVE (pts[j], pts[i], sizeof (IGRpoint));
        OM_BLOCK_MOVE (tmppt, pts[j], sizeof (IGRpoint));
        }
      } 
}

/*
  DESCRIPTION

    This function takes in an array of GRparms (curve_int) on a NON-composite 
    curve and corresponding arrays of: 
    - GRparms on a surface/solid/curve, (other_int)
    - XYZ points and  (xyz_pts)
    - intersection properties  (inter_props)

    It sorts the parms and corresponding other params/xyz points/properties into
    increasing order along the curve.  An additional flexibility provided is 
    that any of the following may be NULL:
      other_int, xyz_pts, inter_props

    The sorting is based on "curve_int" array.

    HISTORY:

    01/03/94: NP  : Moved this here from its earlier resting place in 
                    EMslptloc.I.
*/

void EMsort_by_parameter (other_int, curve_int, xyz_pts, inter_props, total_int)
struct GRparms *other_int;
struct GRparms *curve_int;
IGRdouble *xyz_pts;
IGRlong *inter_props;
IGRint total_int;
{
 IGRint i, j, m, n, point_size, grparms_size,ulong_size;
 extern  void EMswapmem();

 point_size = sizeof(IGRpoint);
 grparms_size = sizeof(struct GRparms);
 ulong_size   = sizeof (IGRulong);

for (i=0,m=0; i<total_int-1; i++,m+=3)
  {
    for (j=i+1,n=m+3; j<total_int; j++,n+=3)
    {
      if (curve_int[j].u < curve_int[i].u)
      {  
         EMswapmem (&(curve_int[i]), &(curve_int[j]), grparms_size);

         if (other_int)
         { EMswapmem (&(other_int[i]), &(other_int[j]), grparms_size);
         }

         if (xyz_pts)
         { EMswapmem (&(xyz_pts[m]),&(xyz_pts[n]), point_size);
         }

         if (inter_props)
         { EMswapmem (&(inter_props[i]),&(inter_props[j]), ulong_size);
         }
      }
    }
  }


 return;
}
/*
  DESCRIPTION

    This function computes the reflection matrix to transform geometry
    about a given line when viewed along a Z-direction
*/

IGRboolean EMreflectmat (refline, zvec, mat, mattyp)
struct IGRline *refline;
IGRvector zvec;
IGRmatrix mat;
IGRshort *mattyp;
{
  IGRboolean stat_func;
  IGRshort four=4;
  IGRint i;
  IGRlong msg_loc;
  IGRdouble *pt1, *pt2;
  IGRvector line_vec, refpln_vec;
  IGRmatrix xorigin_tmat, refpln_tmat, temp_mat;
  extern IGRboolean BSnorvec(), BScrossp(), MAidmx(), MArefmx(), MAmulmx();

  stat_func = TRUE;

  MAidmx (&msg_loc, xorigin_tmat);
  pt1 = refline->point1;
  xorigin_tmat[3] = -pt1[X];
  xorigin_tmat[7] = -pt1[Y];
  xorigin_tmat[11] = -pt1[Z];

  pt2 = refline->point2;
  for (i=0; i<3; i++)
    line_vec[i] = pt2[i] - pt1[i];
  BScrossp (&msg_loc, zvec, line_vec, refpln_vec);
  BSnorvec (&msg_loc, refpln_vec);
  MArefmx (&msg_loc, refpln_vec, refpln_tmat);

  MAmulmx (&msg_loc, &four, &four, &four, refpln_tmat, xorigin_tmat, temp_mat);
 
  MAidmx (&msg_loc, xorigin_tmat);
  xorigin_tmat[3] = pt1[X];
  xorigin_tmat[7] = pt1[Y];
  xorigin_tmat[11] = pt1[Z];

  MAmulmx (&msg_loc, &four, &four, &four, xorigin_tmat, temp_mat, mat);
  MAtypemx (&msg_loc, mat, mattyp);

  return (stat_func);
}

