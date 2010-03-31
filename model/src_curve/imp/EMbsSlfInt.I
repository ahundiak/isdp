/*
  ABSTRACT

    This method intersects a bspline curve with itself

  BUGS

    This method should call part of curve for overlaps and should
    not be placing stuff in the R-tree when it outputs parameteric data.
    In general, this method should be rewritten.  rlw

    taken care of on 12/3/87

  ARGUMENTS

    IGRlong *msg;
     Error return code
				
    struct GRvg_construct *cnst_list;
     Required to construct points or curves. 
     Can be NULL if pnt_ids and crv_ids are NULL

    struct GRmdenv_info *my_objenv;
     required to get my geometry
				        
    IGRlong *pnt_slots;
     number of slots allocated so far for storing
     intersection info. The total memory allocated is
     different for different options. But size is linked
     to number of intersections. If caller wishes to
     allocate some memory for storing the return variables,
     then this variable should indicate the number of slots
     allocated.

    IGRlong *grand_num_pnt;
     number of intersections found = N
					
    struct GRid **pnt_ids;
     non-NULL only if the points of intersection need to
     be constructed. #GRids = *grand_num_pnt

    struct GRparms **my_pnt_inters;
     non-NULL only if the parametric info of intersections
     wrt 'me' is needed.  

     struct[I].u = parameter on 'my' curve
     struct[I].v = 0.0
     struct[I].polygon_inx = FALSE
     struct[I].leaf_id = my_id
     and,
     struct[I+1].u = other parameter on 'my' curve
     where,
     0 <= I < 2*N

    IGRdouble **inter_pnts_xyz;
     non-NULL only if xyz co-ordinates of the intersection
     points are  needed. The returned double array is
     3 * (*grand_num_pnt) long.

    IGRlong *crv_slots;
     number of slots allocated so far for storing
     overlap info. The total memory allocated is
     different for different options. But size is linked
     to number of overlaps. If caller wishes to
     allocate some memory for storing the return variables,
     then this variable should indicate the number of slots
     allocated.

    IGRlong *grand_num_crv;
     number of overlaps found = M

    struct GRid **crv_ids;
     non-NULL only if the curves of overlap need to be
     constructed. #GRids = *grand_num_crv

    struct GRparms **my_crv_inters;
     non-NULL only if the parametric info of overlap wrt
     'me' is needed. Each overlap has 2 pairs of structs
     associated with it.

     struct[I].u = start param on 'my' curve
     struct[I].v = 0.0
     struct[I].polygon_inx = FALSE
     struct[I].leaf_id     = my_id
     and,
     struct[I+1].u = stop param on 'my' curve
     struct[I+2].u = other start param on 'my' curve
     struct[I+3].u = other stop param on 'my' curve
     where,
     0 <= I < 4*M

  HISTORY
    gk	11/26/86	creation date
    gk	5/27/87		modified to recognize EMSinters
			and changed call to EMmkintlist instead
				of EMmkintlist1
    rlw	09/24/87	Added argument to split curve call.
    gk	12/3/87		arguments changed
    SS	01/06/89	The parametric output now outputs pairs
			of intersection data - there are two
			distinct parametric sets for each intersection
			or overlap. Performed general cleanup.
    Sudha  06/16/93     Modified for BSprototype ansification
*/

class implementation GRbspline;

#include "EMS.h"
#include "OMmacros.h"
#include "emserr.h"
#include "emsdef.h"
#include "emsdattyp.h"
#include "EMSmsgdef.h"
#include "bserr.h"
#include "bscveval.h"
#include "bscv_slfint.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define GRAIN_SIZE 10

method EMcrvslfint( IGRlong		  *msg;
		    struct GRvg_construct *cnst_list;
		    struct GRmdenv_info   *my_objenv;

		    IGRlong		  *pnt_slots;
		    IGRlong		  *grand_num_pnt;
		    struct GRid		  **pnt_ids;
		    struct GRparms	  **my_pnt_inters;
		    IGRdouble		  **inter_pnts_xyz;

		    IGRlong		  *crv_slots;
		    IGRlong		  *grand_num_crv;
		    struct GRid		  **crv_ids;
		    struct GRparms	  **my_crv_inters)

{
  IGRboolean		stat_func;
  IGRlong		i, j, k, l, numb_ints, numb_crvs, loc_msg, omsts;
  IGRlong		numb_required, vect_bytes, grid_bytes, parm_bytes;
  IGRlong		numslots, gnum;
  IGRdouble		*para, *parb, *overc, *overd, *overe, *overf;
  IGRpoint		int_pts;
  struct GRparms	*temp_parm, my_parms, start_parm, mid_parm, end_parm;
  struct GRid		temp_crv_obj, my_GRid;
  struct IGRbsp_curve	*my_curve;
  enum EMSdatatype	dattyp;
extern IGRboolean EMoutput_point() ;
  extern IGRlong	EMgetvggeom();

  *msg = EMS_S_Success;
  omsts = OM_S_SUCCESS;

  para = NULL;
  parb = NULL;
  overc = NULL;
  overd = NULL;
  overe = NULL;
  overf = NULL;
  my_curve = NULL;

  /*
   * Obtain this curves geometry
   */

  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;
  omsts = EMgetvggeom (&loc_msg, &my_objenv->matrix_type, my_objenv->matrix, 
   &my_GRid, &my_curve, &dattyp);
  EMomerr_exit (omsts, wrapup);
  EMerr_hndlr (EMSerror (loc_msg), *msg, EMS_E_CurveError, wrapup);

  /*
   * No self intersection possible with line segment
   */

  if (my_curve->num_poles == 2)
    goto wrapup;

  /*
   * Call math to perform the self-intersection
   */

  stat_func = BScv_slfint (&loc_msg, my_curve, (IGRint *)&numb_ints, &para, &parb,
               (IGRint *)&numb_crvs, &overc, &overd, &overe, &overf);
  EMerr_hndlr (!stat_func || loc_msg != BSSUCC, *msg, EMS_E_BSerror, wrapup);

  /*
   * If no intersections goto
   * wrapup
   */

  if (!numb_ints && !numb_crvs)
    goto wrapup;

  /*
   * Format the output
   */

  if (my_pnt_inters || my_crv_inters)
    {
    my_parms.v = 0.0;
    my_parms.polygon_inx = 0;
    my_parms.leaf_id.objid = my_id;
    my_parms.leaf_id.osnum = OM_Gw_current_OS;
    }
  if (cnst_list && (pnt_ids || crv_ids))
    temp_crv_obj.osnum = cnst_list->env_info->md_id.osnum;

  if (numb_ints)
    {
    /*
     * Check and allocate enough memory if necessary
     */

    numb_required = (*grand_num_pnt) + numb_ints;
    numslots = *pnt_slots;
    if (numb_required > numslots)
      {
      numslots = (numb_required / GRAIN_SIZE) * GRAIN_SIZE +
                  (numb_required % GRAIN_SIZE ? GRAIN_SIZE : 0);
      grid_bytes = numslots * sizeof (struct GRid);
      vect_bytes = 3 * numslots * sizeof (IGRdouble);
      parm_bytes = 2 * numslots * sizeof (struct GRparms);
	
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

        if (inter_pnts_xyz)
          {
          *inter_pnts_xyz = (IGRdouble *) om$malloc(size = vect_bytes);
          EMerr_hndlr (!*inter_pnts_xyz, *msg, EMS_E_NoDynamicMemory, wrapup);
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

        if (inter_pnts_xyz)
          {
          *inter_pnts_xyz = (IGRdouble *) om$realloc (size = vect_bytes,
                             ptr = (char *) *inter_pnts_xyz);
          EMerr_hndlr (!*inter_pnts_xyz, *msg, EMS_E_NoDynamicMemory, wrapup);
          }
        }
      *pnt_slots = numslots;
      }

    /*
     * Fill the output memory
     */

    gnum = *grand_num_pnt;
    for (i=0, j=gnum, k=gnum*3, l=gnum*2; i<numb_ints; i++, j++, k+=3, l+=2)
      {
      if (pnt_ids || inter_pnts_xyz)
        {
        BScveval (my_curve, para[i], 0, (IGRpoint *)int_pts, &loc_msg);
        EMerr_hndlr (loc_msg != BSSUCC, *msg, EMS_E_BSerror, wrapup);

	if (pnt_ids)
          {
	  stat_func = EMoutput_point (&loc_msg, my_id, cnst_list, 1,
                       int_pts, &(*pnt_ids)[j]);
          EMerr_hndlr (!stat_func || loc_msg != BSSUCC, *msg, EMS_E_Fail,
           wrapup);
          }

	if (inter_pnts_xyz)
          {
          (*inter_pnts_xyz)[k]   = int_pts[0];
          (*inter_pnts_xyz)[k+1] = int_pts[1];
          (*inter_pnts_xyz)[k+2] = int_pts[2];
          }
        }

      if (my_pnt_inters)
        {
        temp_parm = &(*my_pnt_inters)[l];
     
        *temp_parm = my_parms;
        temp_parm->u = para[i];
        temp_parm++;
        *temp_parm = my_parms;
        temp_parm->u = parb[i];
        }
      }
    *grand_num_pnt += numb_ints;
    }


  if (numb_crvs)
    {
    /*
     * Check and allocate enough memory if necessary
     */

    numb_required = (*grand_num_crv) + numb_crvs;
    numslots = *crv_slots;
    if (numb_required > numslots)
      {
      numslots = (numb_required / GRAIN_SIZE) * GRAIN_SIZE +
                  (numb_required % GRAIN_SIZE ? GRAIN_SIZE : 0);
      grid_bytes = numslots * sizeof (struct GRid);
      parm_bytes = 4 * numslots * sizeof (struct GRparms);
	
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
        }
      *crv_slots = numslots;
      }

    /*
     * Fill the output memory
     */

    gnum = *grand_num_pnt;
    for (i=0, j=gnum, k=gnum*4; i<numb_ints; i++, j++, k+=4)
      {
      if (crv_ids)
        {
        start_parm.u = overc[i];
        end_parm.u = overd[i];
        mid_parm.u = (end_parm.u + start_parm.u) / 2.0;

        omsts = om$send (msg = message GRbspline.EMpartofcv(&loc_msg,
                 &my_objenv->matrix_type, my_objenv->matrix, cnst_list,
                 &start_parm, &mid_parm, &end_parm,
                 &temp_crv_obj.objid), targetid = my_id);
        EMerr_hndlr (EMSerror (omsts & loc_msg), *msg, EMS_E_CurveError,
         wrapup);

        (*crv_ids)[j] = temp_crv_obj;
        }

      if (my_crv_inters)
        {
        temp_parm = &(*my_crv_inters)[k];
     
        *temp_parm = my_parms;
        temp_parm->u = overc[i];
        temp_parm++;
        *temp_parm = my_parms;
        temp_parm->u = overd[i];
        temp_parm++;
        *temp_parm = my_parms;
        temp_parm->u = overe[i];
        temp_parm++;
        *temp_parm = my_parms;
        temp_parm->u = overf[i];
        }
      }
    *grand_num_crv += numb_crvs;
    }

wrapup:
 if (my_curve)
   om$dealloc (ptr = my_curve);
 if (para)
   om$dealloc (ptr = para);
 if (parb)
   om$dealloc (ptr = parb);
 if (overc)
   om$dealloc (ptr = overc);
 if (overd)
   om$dealloc (ptr = overd);
 if (overe)
   om$dealloc (ptr = overe);
 if (overf)
   om$dealloc (ptr = overf);

  EMWRAPUP (*msg, omsts, "GRbspline.EMcrvslfint");
  return(omsts);
}

end implementation GRbspline;
