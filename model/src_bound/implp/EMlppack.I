/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloop;

#include "EMS.h"
#include <stdio.h>
#include "EMSmsgdef.h"
#include "emsmacros.h"

#define EDGE_INITIAL_SIZE    10
#define LOOP_INCREMENT       10

from EMSedge import EMedgepack;

method EMrgpack(IGRlong *EMmsg;
                IGRboolean *on_off;
                IGRint *num_bdrys;
                struct IGRbsp_bdry_pts **bdrys;
                IGRint *size;
		struct EMSdataselect *surf_data;
		IGRshort *matrix_type;
		IGRmatrix matrix;
		IGRushort options;
                struct EMSpartolbasis *ptol)
/*
History

    17 Apr 1989 RC  If the loop does not have any edges, it should 
                    error out.
    21 Feb 1989 rlw Modified to check error code from edge pack.  In case
                    of error it was overwriting memory.
    12 Oct 1988 AIC Added ptol argument.
    27 Sep 1988 PP  Modified the loop pack to make the starting
                    point exactly equal to the ending point.
    ?? ??? 198? AIC Creation
*/
{
  IGRlong                   sts;
  IGRint                    index;
  IGRshort                  i;
  OM_S_CHANSELECT           to_edges, to_inner;
  struct IGRbsp_bdry_pts    *this_bdry;

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  to_edges.type = OM_e_addr;
  to_edges.u_sel.addr = &ME.EMSbd_owner->to_comps;
  to_inner.type = OM_e_addr;
  to_inner.u_sel.addr = &ME.EMSloop->to_inner;

  if (! (ME.EMSloop->lp_props & EMLP_NATURAL))
    {
    /*
     * Make sure there is enough space
     */
    index = *num_bdrys;
    *num_bdrys = index + 1;
    if(*num_bdrys > *size)
    {
      IGRint  num_bytes;
  
      *size = *size + LOOP_INCREMENT;
      num_bytes = *size * sizeof(struct IGRbsp_bdry_pts);
      *bdrys = (struct IGRbsp_bdry_pts *) om$realloc(ptr = (IGRchar *) *bdrys, 
                size = num_bytes);
    }
  
    /*
     * Allocate initial space for the edges
     */
    this_bdry = &((*bdrys)[index]);
    this_bdry->points = (IGRdouble *)om$malloc
                        (size = EDGE_INITIAL_SIZE * sizeof(IGRdouble));
    if(! this_bdry->points)
    {
      *EMmsg = EMS_E_NoDynamicMemory;
      goto wrapup;
    }

    /*
     * Pack in the edges
     */
    {
      IGRint  	edge_size;
      IGRint	fromi, toi;
      IGRdouble avg[2];
      IGRdouble *beginpt; 
      IGRdouble *endpt;

      edge_size = EDGE_INITIAL_SIZE;
      this_bdry->num_points = 0;
	  if(ME.EMSloop->lp_props & EMLP_REVERSED)
	  {
		fromi = OM_K_MAXINT;
		toi = 0;
	  }
	  else
	  {
		fromi = 0;
		toi = OM_K_MAXINT;
      }
      sts = om$send(msg = message EMSedge.EMedgepack(EMmsg,
                    (IGRint *)&this_bdry->num_points, &this_bdry->points,
                    &edge_size, surf_data, matrix_type, matrix, options, ptol),
                    p_chanselect = &to_edges, from = fromi, to = toi);
       if ((! (1 & sts)) || (! (1 & *EMmsg))) goto wrapup;
      
       /*
        * Inacse, the loop is screwed up such that it does not have
        * any edges, should error out.
        */

       if (!this_bdry->num_points)
       {
        *EMmsg = EMS_E_Fail;   goto wrapup;
       }
/*
 * Make the first point exactly equal to the last point because S.T's
 * facetting routine barfs otherwise.
 */
      beginpt = &this_bdry->points[0];
      endpt = &this_bdry->points[2*(this_bdry->num_points - 1)];

      for (i=0;i<2;i++)
      {
       avg[i] = (beginpt[i] + endpt[i])/2.0;
       beginpt[i] = avg[i];
       endpt[i] = avg[i];
      }
    }
  }
  else *on_off = TRUE;

  sts = om$send (msg = OPPmargs, p_chanselect = &to_inner);

wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSloop.EMrgpack")
  return(sts);
}

end implementation EMSloop;
