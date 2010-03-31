/*
  DESCRIPTION
    
    This method intersects a bspline object (myself) with another
    object sub-classed off GRcurve (composite curve included).

  NOTES

    First of all the identity of the object I am going to intersect
    is established. If the other object is a composite curve then
    control is transferred to the other object method. This ensures
    'I' intersect object that are atmost as complicated as 'I' am
    (relationwise).
	
    If the other object is as manageable then the method invokes the
    math module to intersect (after retrieving the data); later the
    intersections and overlaps are processed.

  ARGUMENTS

    msg			- Output: Return code
				
    cnst_list		- Input: Required to construct points or curves.
                           Can be NULL if pnt_ids and crv_ids are NULL.

    my_objenv		- Input: Required to get my get my geometry.

    other_curve		- Input: Caller can send the geometry of the curve
			   I am	intersecting. Obviously this can happen only
                           if the other curve is not compcurve. Caller should 
                           set this to NULL if other_obj is being sent.

    other_obj		- Input: id of the object I am intersecting.
                           Can be NULL if curve structure is being sent.

    other_objenv	_ Input: env info the the other object

    inter_options	- Input: NULL is the more common value assigned to this
                           argument. Special processing may optionally
			   be specified. The valid masks that can be applied 
			   here can be found in the file - emsinterdef.h. So 
                           far, we have i) EMS_CVINT_NOENDCOINC, which, if set,
			   indicates that end point coincidence of two
                           intersecting	curves is not to be considered as an
                           intersection (mainly useful in the implementation
			   of self-intersection in composites), 
                           ii) EMS_CVINT_ZEROZDEPTH, which, if set, indicates
			   the curve should be projected onto the Z=0 plane
			   before intersection and the intersection result
			   then transferred back to the original curve
			   (mainly useful when computing apparent 
                           intersections. This procedure of manually zeroing
			   out the Z has the effect of leaving the B-spline
			   represenation unchanged as opposed to the method
			   which has this projection built into the
                           transformation matrix. This latter process might
			   change a circle to an ellipse, for instance, and
			   thus change the parametrization and thus also an
			   inaccurate result).

    pnt_slots		- Input/Output: number of slots allocated so far for
                            storing intersection info. The total memory
			    allocated is different for different options. But
                            size is linked to number of intersections. If
                            caller wishes to allocate some memory for storing
                            the return variables, then this variable should
                            indicate the number of slots allocated.

    grand_num_pnt	- Output: number of intersections found = N
					
    pnt_ids		- Output: non-NULL only if the points of intersection
			   need to be constructed. #GRids = *grand_num_pnt

    my_pnt_inters	- Output: non-NULL only if the parametric info of
			   intersections wrt 'me' is needed:
			   where,
    			    struct[I].u = parameter on 'my' curve
		 	    struct[I].v = 0.0
		  	    struct[I].polygon_inx = FALSE
		   	    struct[I].leaf_id     = my_id
		    	   where,
			    0 <= I < N

    other_pnt_inters	- Output: non-NULL only if the parametric info of
			   intersections wrt other obj is needed:
			   where,
			    struct[I].u = parameter on other curve
			    struct[I].v = 0.0
			    struct[I].polygon_inx = FALSE
			    struct[I].leaf_id     = other_obj
			   where,
			    0 <= I < N

    inter_pnts_xyz	- Output: non-NULL only if xyz co-ordinates of the
			   intersection points are  needed. The returned double
			   array is 3 * (*grand_num_pnt) long.

    crv_slots 		- Output: number of slots allocated so far for storing
			   overlap info. The total memory allocated is
			   different for different options. But size is linked
			   to number of overlaps. If caller wishes to
			   allocate some memory for storing the return 
			   variables, then this variable should indicate the
    			   number of slots allocated.

    grand_num_crv 	- Output: number of overlaps found = M

    crv_ids		- Output: non-NULL only if the curves of overlap need
			   to be constructed. #GRids = *grand_num_crv

    my_crv_inters 	- Output: non-NULL only if the parametric info of
			   overlap wrt 'me' is needed. Each overlap has 2
			   structs associated with it. first one is starting
			   param and second one is stop param
			   where,
			    struct[I].u = start param on 'my' curve
			    struct[I].v = 0.0
			    struct[I].polygon_inx = FALSE
			    struct[I].leaf_id     = my_id

			    struct[I+1].u = stop param on 'my' curve
			    struct[I+1].v = 0.0
			    struct[I+1].polygon_inx = FALSE
			    struct[I+1].leaf_id     = my_id
			   where,
			    0 <= I < M

    other_crv_inters 	- Output: non-NULL only if the parametric info of
			   overlap wrt other curve is needed. 	Each overlap
 			   has 2 structs associated with it. first one is
			   starting param and second one is stop param
			   where,
			    struct[2I].u = start param on other curve
			    struct[2I].v = 0.0
			    struct[2I].polygon_inx = FALSE
			    struct[2I].leaf_id     = other_obj

			    struct[2I+1].u = stop param on otherr curve
			    struct[2I+1].v = 0.0
			    struct[2I+1].polygon_inx = FALSE
			    struct[2I+1].leaf_id     = other_obj
			   where,
			     0 <= I < m

  HISTORY

    gk	  11/28/86	creation date
    gk	  05/25/87	modified to recognize EMSinters
			and changed call to EMmkintlist
    rlw   09/24/87	Numerous problems were fixed.  Govinda was
                        freeing the abstract buffer and was not
                        outputting overlap sections correctly.
    gk	  12/2/87	arguments and philosophy changed
    SS    06/05/89	Changed the end_inter_valid (IGRboolean) to 
			inter_options (IGRshort) which provides more
			options. See emsinterdef.h. Also cleaned up
			somewhat.
    Sudha  06/16/93     Modified for BSprototype ansification
*/		

class implementation GRbspline;

#include "EMS.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsdattyp.h"
#include "emsinterdef.h"
#include "EMSmsgdef.h"
#include "bserr.h"
#include "bsparameters.h"

%safe
#include <math.h>
#include "bscvkttol2.h"
#include "bscveval.h"
#include "bscvcv_int.h"
%endsafe

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define X 0
#define Y 1
#define Z 2

#define GRAIN_SIZE 10

method EMcrvcrvint (IGRlong		  *msg;
		    struct GRvg_construct *cnst_list;
		    struct GRmdenv_info   *my_objenv;
		    struct IGRbsp_curve   *other_curve_in;
		    struct GRid		  *other_obj;
		    struct GRmdenv_info   *other_objenv;
		    IGRshort              inter_options;

		    IGRlong		  *pnt_slots;
		    IGRlong		  *grand_num_pnt;
		    struct GRid		  **pnt_ids;
		    struct GRparms	  **my_pnt_inters;
		    struct GRparms	  **other_pnt_inters;
		    IGRdouble		  **inter_pnts_xyz;

		    IGRlong		  *crv_slots;
		    IGRlong		  *grand_num_crv;
		    struct GRid		  **crv_ids;
		    struct GRparms	  **my_crv_inters;
		    struct GRparms	  **other_crv_inters)

{
  IGRboolean log_status;
  IGRlong status, numb_ints, numb_crvs, i, j, k, inx1, inx2;
  IGRlong loc_msg, numb_required, numslots;
  IGRlong grid_bytes, parm_bytes, vect_bytes;
  IGRdouble *pars, *par1 = NULL, *par2 = NULL;
  IGRdouble *over1 = NULL, *over2 = NULL;
  IGRdouble *end_pts = NULL, *int_pts = NULL;
  IGRdouble *zvals = NULL, zvalsmem[GRAIN_SIZE];
  IGRdouble mypartol, otpartol, mystart, mystop, otstart, otstop;
  struct GRprops geo_props;
  struct GRid my_GRid, temp_crv_obj, null_obj;
  struct IGRbsp_curve *other_curve = NULL, *my_curve = NULL, *datacurve;
  struct GRparms *temp_parm, my_parm, other_parm;
  struct GRparms start_parm, mid_parm, end_parm;
  enum EMSdatatype datatype;
extern IGRboolean GRabsg_del_all() , EMoutput_point() ;
  extern IGRlong EMgetvggeom(), EMgetabsg();
  
  *msg = EMS_S_Success;
  status = OM_S_SUCCESS;

  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;
  if (cnst_list)
    temp_crv_obj.osnum = cnst_list->env_info->md_id.osnum;
  null_obj.objid = NULL_OBJID;
  my_parm.v = 0.0;
  my_parm.polygon_inx = 0;
  my_parm.leaf_id = my_GRid;
  other_parm = my_parm;
  other_parm.leaf_id.objid = other_obj ? other_obj->objid : NULL_OBJID;

  /*
   * See whom do I need to intersect
   */

  if (other_obj)
    {
    status = om$send(msg = message GRvg.GRgeomprops(&loc_msg,
              &other_objenv->matrix_type, other_objenv->matrix, &geo_props),
              targetid = other_obj->objid, targetos = other_obj->osnum);
    EMomerr_exit (status, wrapup);
    EMerr_hndlr (EMSerror (loc_msg), *msg, EMS_E_CurveError, wrapup);
    }
  else
    geo_props.subtype = GRSC;

  if (geo_props.subtype == GRCC)
    {
    /*
     * Invoke same message with pointers reversed
     * swap my objenv and other objenv
     * swap my pnt inters and other pnt inters
     * swap my crv inters and other crv inters
     */

    status = om$send (msg = message GRcurve.EMcrvcrvint (&loc_msg, cnst_list,
              other_objenv, NULL, &my_GRid, my_objenv, inter_options,
              pnt_slots, grand_num_pnt, pnt_ids, other_pnt_inters,
              my_pnt_inters, inter_pnts_xyz, crv_slots, grand_num_crv,
              crv_ids, other_crv_inters, my_crv_inters),
              targetid = other_obj->objid, targetos = other_obj->osnum);
    EMomerr_exit (status, wrapup);
    EMerr_hndlr (EMSerror (loc_msg), *msg, EMS_E_CurveError, wrapup);
    }
  else
    {
    /*
     * The other object is a simple curve.
     * Get other object's geometry if not passed in and
     * my geometry.
     */

    if (!other_curve_in)
      {
      status = EMgetvggeom (&loc_msg, &other_objenv->matrix_type,
                other_objenv->matrix, other_obj, &other_curve, &datatype);
      EMomerr_exit (status, wrapup);
      EMerr_hndlr (EMSerror (loc_msg) || datatype != EMSdata_curve3d, *msg,
       EMS_E_CurveError, wrapup);
      }
    else
      other_curve = (struct IGRbsp_curve *)other_curve_in;

    status = EMgetabsg (&loc_msg, &my_objenv->matrix_type, my_objenv->matrix,
              OM_Gw_current_OS, my_id, &my_curve);
    EMomerr_exit (status, wrapup);
    EMerr_hndlr (EMSerror (loc_msg), *msg, EMS_E_CurveError, wrapup);

    /*
     * If end-point coincidence has to be rejected, obtain the parametric
     * tolerances for both the curves. Also, the start ans the stop,
     * parametric values of the two curves.
     *
     * If the options call for projection onto the Z=0 plane,
     * zero out the Z's in place, and invalidate the abstract geometry buffer
     * so that subsequent call to get abstract geometry does not reuse
     * the same. Also, if model-space data has been asked for, store away
     * the Z-values of the poles of my_curve so that the intersection points
     * can be evaluated on the orignal curve. 
     */

    if (inter_options & EMS_CVINT_NOENDCOINC)
      {
      BScvkttol2 (my_curve->order, my_curve->knots, my_curve->num_poles, 
       my_curve->poles, my_curve->weights, &mypartol, &loc_msg);
      EMerr_hndlr (loc_msg != BSSUCC, *msg, EMS_E_BSerror, wrapup);

      BScvkttol2 (other_curve->order, other_curve->knots,
       other_curve->num_poles, other_curve->poles, other_curve->weights,
       &otpartol, &loc_msg);
      EMerr_hndlr (loc_msg != BSSUCC, *msg, EMS_E_BSerror, wrapup);

      mystart = my_curve->knots[my_curve->order-1];
      mystop = my_curve->knots[my_curve->num_poles];
      otstart = other_curve->knots[other_curve->order-1];
      otstop = other_curve->knots[other_curve->num_poles];
      }

    if (inter_options & EMS_CVINT_ZEROZDEPTH)
      {
      for (i=0, j=Z; i<other_curve->num_poles; i++, j+=3)
        other_curve->poles[j] = 0.0;

      if (pnt_ids || inter_pnts_xyz)
        {
        datacurve = my_curve->num_poles < other_curve->num_poles ?
                     my_curve : other_curve;
        if (datacurve->num_poles > GRAIN_SIZE)
          zvals = (IGRdouble *) om$malloc (size = datacurve->num_poles *
                   sizeof (IGRdouble));
        else
          zvals = zvalsmem;
        EMerr_hndlr (!zvals, *msg, EMS_E_NoDynamicMemory, wrapup);

        for (i=0, j=Z; i<datacurve->num_poles; i++, j+=3)
          zvals[i] = datacurve->poles[j];
        }

      for (i=0, j=Z; i<my_curve->num_poles; i++, j+=3)
        my_curve->poles[j] = 0.0;
      GRabsg_del_all();     
      }

    /*
     * We now have both curves; intersect them 
     */

    log_status = BScvcv_int (&loc_msg, my_curve, other_curve,
	          (IGRint *)&numb_ints, &int_pts, &par1, &par2,
	          &numb_crvs, &end_pts, &over1, &over2);
    EMerr_hndlr (!log_status || loc_msg != BSSUCC, *msg, EMS_E_BSerror,
     wrapup);

    /*
     * If the options were to zero out the Z's and also to return the
     * model-space data, then the raw model-space data has to be converted
     * back to the original curve's.
     */

    if (numb_ints &&
        inter_options & EMS_CVINT_ZEROZDEPTH &&
        (pnt_ids || inter_pnts_xyz))
      {
      pars = datacurve == my_curve ? par1 : par2;
      for (i=0, j=Z; i<datacurve->num_poles; i++, j+=3)
        datacurve->poles[j] = zvals[i];

      for (i=0, j=0; i<numb_ints; i++, j+=3)
        {
        BScveval (datacurve, pars[i], 0, (IGRpoint *)&int_pts[j], &loc_msg);
        EMerr_hndlr (loc_msg != BSSUCC, *msg, EMS_E_BSerror, wrapup);
        }
      }

    /*
     * Format the intersections points if these are
     * required, allocating memory when necessary.
     */

    if (numb_ints)
      {
      numb_required = (*grand_num_pnt) + numb_ints;
      numslots = *pnt_slots;
      if (numb_required > numslots)
        {
        numslots = (numb_required / GRAIN_SIZE) * GRAIN_SIZE +
                    (numb_required % GRAIN_SIZE ? GRAIN_SIZE : 0);
        grid_bytes = numslots * sizeof (struct GRid);
	vect_bytes = 3 * numslots * sizeof (IGRdouble);
	parm_bytes = numslots * sizeof (struct GRparms);
	
	if (!*pnt_slots)
	  {
          if (pnt_ids)
            {
  	    *pnt_ids = (struct GRid *) om$malloc (size = grid_bytes);
            EMerr_hndlr (!*pnt_ids, *msg, EMS_E_NoDynamicMemory, wrapup);
            }

          if (my_pnt_inters)
            {
            *my_pnt_inters = (struct GRparms *) om$malloc(size = parm_bytes);
            EMerr_hndlr (!*my_pnt_inters, *msg, EMS_E_NoDynamicMemory, wrapup);
            }

          if (other_pnt_inters)
            {
            *other_pnt_inters = (struct GRparms *) om$malloc (size = 
                                 parm_bytes);
            EMerr_hndlr (!*other_pnt_inters, *msg, EMS_E_NoDynamicMemory, 
             wrapup);
            }

          if (inter_pnts_xyz)
            {
            *inter_pnts_xyz = (IGRdouble *) om$malloc(size = vect_bytes);
            EMerr_hndlr (!*inter_pnts_xyz, *msg, EMS_E_NoDynamicMemory, 
             wrapup);
            }
          }
        else
          {
          if (pnt_ids)
            {
   	    *pnt_ids = (struct GRid *) om$realloc (size = grid_bytes,
                        ptr = (char *) *pnt_ids);
            EMerr_hndlr (!*pnt_ids, *msg, EMS_E_NoDynamicMemory, wrapup);
            }

          if (my_pnt_inters)
            {
            *my_pnt_inters = (struct GRparms *) om$realloc (size = parm_bytes,
                              ptr = (char *) *my_pnt_inters);
            EMerr_hndlr (!*my_pnt_inters, *msg, EMS_E_NoDynamicMemory, wrapup);
            }

          if (other_pnt_inters)
            {
            *other_pnt_inters = (struct GRparms *) om$realloc (size = 
                                 parm_bytes, ptr = (char *) *other_pnt_inters);
            EMerr_hndlr (!*other_pnt_inters, *msg, EMS_E_NoDynamicMemory, 
             wrapup);
            }

          if (inter_pnts_xyz)
            {
            *inter_pnts_xyz = (IGRdouble *) om$realloc (size = vect_bytes,
                               ptr = (char *) *inter_pnts_xyz);
            EMerr_hndlr (!*inter_pnts_xyz, *msg, EMS_E_NoDynamicMemory, 
             wrapup);
            }
          }
        *pnt_slots = numslots;
        }

      inx1 = *grand_num_pnt;
      inx2 = inx1 * 3;
      for (i=0, j=0; i<numb_ints; i++, j+=3)
        {
        /*
         * In case, the option is to disregard intersection points denoting
         * coincident end-points, do not process them.
         */

        if (inter_options & EMS_CVINT_NOENDCOINC &&
            (fabs (par1[i] - mystart) < mypartol ||
             fabs (par1[i] - mystop) < mypartol) &&
            (fabs (par2[i] - otstart) < otpartol ||
             fabs (par2[i] - otstop) < otpartol))
          continue;
	
        if (pnt_ids)
	  {
	  status = EMoutput_point (&loc_msg, my_id, cnst_list, 1,
		    &int_pts[j], &(*pnt_ids)[inx1]);
          EMerr_hndlr (!status || loc_msg != BSSUCC, *msg, EMS_E_Fail,
           wrapup);
          }

        if (inter_pnts_xyz)
          {
	  (*inter_pnts_xyz)[inx2]   = int_pts[j];
	  (*inter_pnts_xyz)[inx2+1] = int_pts[j+1];
	  (*inter_pnts_xyz)[inx2+2] = int_pts[j+2];
          }

        if (my_pnt_inters)
          {
	  temp_parm = &(*my_pnt_inters)[inx1];
          *temp_parm = my_parm;
	  temp_parm->u = par1[i];
          }

        if (other_pnt_inters)
	  {
          temp_parm = &(*other_pnt_inters)[inx1];
          *temp_parm = other_parm;
	  temp_parm->u = par2[i];
          }

        inx1++;
        inx2 += 3;
	}
      *grand_num_pnt = inx1;
      }

    /*
     * Output the overlap sections.  I rewrote most of this section
     * such that the part of curve method is used instead of calling
     * active split directly.  I think this makes the code more intelligent
     * and certainly much simpler. 
     * rlw : 09/24/87
     *
     * This code has suffered another re-write.
     * SS : 05/06/89
     */

    if (numb_crvs)
      {
      numb_required = (*grand_num_crv) + numb_crvs;
      numslots = *crv_slots;
      if (numb_required > numslots)
        {
        numslots = (numb_required / GRAIN_SIZE) * GRAIN_SIZE +
                    (numb_required % GRAIN_SIZE ? GRAIN_SIZE : 0);
        grid_bytes = numslots * sizeof (struct GRid);
	parm_bytes = 2 * numslots * sizeof (struct GRparms);
	
	if (!*crv_slots)
	  {
          if (crv_ids)
            {
  	    *crv_ids = (struct GRid *) om$malloc (size = grid_bytes);
            EMerr_hndlr (!*crv_ids, *msg, EMS_E_NoDynamicMemory, wrapup);
            }

          if (my_crv_inters)
            {
            *my_crv_inters = (struct GRparms *) om$malloc(size = parm_bytes);
            EMerr_hndlr (!*my_crv_inters, *msg, EMS_E_NoDynamicMemory, wrapup);
            }

          if (other_crv_inters)
            {
            *other_crv_inters = (struct GRparms *) om$malloc (size = 
                                 parm_bytes);
            EMerr_hndlr (!*other_crv_inters, *msg, EMS_E_NoDynamicMemory, 
             wrapup);
            }
          }
        else
          {
          if (crv_ids)
            {
   	    *crv_ids = (struct GRid *) om$realloc (size = grid_bytes,
                        ptr = (char *) *crv_ids);
            EMerr_hndlr (!*crv_ids, *msg, EMS_E_NoDynamicMemory, wrapup);
            }

          if (my_crv_inters)
            {
            *my_crv_inters = (struct GRparms *) om$realloc (size = parm_bytes,
                              ptr = (char *) *my_crv_inters);
            EMerr_hndlr (!*my_crv_inters, *msg, EMS_E_NoDynamicMemory, wrapup);
            }

          if (other_crv_inters)
            {
            *other_crv_inters = (struct GRparms *) om$realloc (size = 
                                 parm_bytes, ptr = (char *) *other_crv_inters);
            EMerr_hndlr (!*other_crv_inters, *msg, EMS_E_NoDynamicMemory, 
             wrapup);
            }
          }
        *crv_slots = numslots;
        }

      inx1 = *grand_num_crv;
      inx2 = inx1 * 2;
      for (i=0, j=0; i<numb_crvs; i++, j+=2)
        {
        if (crv_ids)
          {
          start_parm.u = over1[j];
          end_parm.u = over1[j+1];
          mid_parm.u = (end_parm.u + start_parm.u) / 2.0;
          status = om$send (msg = message GRbspline.EMpartofcv (&loc_msg,
                    &my_objenv->matrix_type, my_objenv->matrix,
                    cnst_list, &start_parm, &mid_parm, &end_parm,
              	    &temp_crv_obj.objid), targetid = my_id);
          EMomerr_exit (status, wrapup);
          EMerr_hndlr (EMSerror (loc_msg), *msg, EMS_E_CurveError, wrapup);

          (*crv_ids)[inx1] = temp_crv_obj;
          }

        if (my_crv_inters)
	  {
	  temp_parm = &(*my_crv_inters)[inx2];
          for (k=0; k<2; k++)
            {
            *temp_parm = my_parm;
            temp_parm->u = over1[j+k];
            temp_parm++;
            }
          }

        if (other_crv_inters)
          {
	  temp_parm = &(*other_crv_inters)[inx2];
          for (k=0; k<2; k++)
            {
            *temp_parm = other_parm;
            temp_parm->u = over2[j+k];
            temp_parm++;
            }
          }
        
        inx1++;
        inx2 += 2;
        }
      *grand_num_crv = inx1;
      }
    }

wrapup:
  if (!other_curve_in && other_curve)
    om$dealloc (ptr = other_curve);
  if (zvals && zvals != zvalsmem)
    om$dealloc (ptr = zvals);  
  if (par1)
    om$dealloc (ptr = par1);
  if (par2)
    om$dealloc (ptr = par2);
  if (over1)
    om$dealloc (ptr = over1);
  if (over2)
    om$dealloc (ptr = over2);
  if (int_pts)
    om$dealloc (ptr = int_pts);
  if (end_pts)
    om$dealloc (ptr = end_pts);

  EMWRAPUP (*msg, status, "GRbspline.EMcrvcrvint");
  return(status);
}

end implementation GRbspline;
