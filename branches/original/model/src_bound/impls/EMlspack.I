/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMS.h"
#include <stdio.h>
#include "EMSmsgdef.h"
#include "emsmacros.h"

#define INITIAL_SIZE 10

from EMSloop import EMrgpack;

/*
   History

     RC   04/17/89     If an error occurs, free an allocated bdrys.
     AIC  ??????       Creation Date
*/

method EMpack(IGRlong *EMmsg;
              IGRboolean *on_off;
              IGRint *num_bdrys;
              struct IGRbsp_bdry_pts **bdrys;
              struct EMSdataselect *surf_data;
              IGRshort *matrix_type;
              IGRmatrix matrix;
              IGRushort options;
              struct EMSpartolbasis *ptol)
{
  IGRlong           sts;
  OM_S_CHANSELECT   to_loops;

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  to_loops.type = OM_e_addr;
  to_loops.u_sel.addr = &ME.EMSloopset->to_loops;
  *num_bdrys = 0;
  *bdrys = NULL;

  /*
   * Perform initial allocation of memory for packing
   */
  if (ME.EMSloopset->ls_props & EMLS_NATURAL)
    {
    *on_off = TRUE;
    goto wrapup;
    }
  else
    *on_off = FALSE;

  *bdrys = (struct IGRbsp_bdry_pts *) om$malloc
           (size = INITIAL_SIZE * sizeof(struct IGRbsp_bdry_pts));
  if(! *bdrys)
  {
    *EMmsg = EMS_E_NoDynamicMemory;
    goto wrapup;
  }

  /*
   * Pack
   */
  {
    IGRint  size;

    size = INITIAL_SIZE;

    sts = om$send(msg = message EMSloop.EMrgpack(EMmsg, on_off, num_bdrys,
                  bdrys, &size, surf_data, matrix_type, matrix, options, ptol),
		 p_chanselect = &to_loops);
  }

wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSloopset.EMpack")
  /* 
   * If an error occurs, free the bdrys. 
   */

  if (!(1 & sts & *EMmsg))
  {
   IGRint     i;

   if (*bdrys) 
   { 
    for (i = 0; i < (*num_bdrys); i++) 
     if ((*bdrys)[i].points) om$dealloc (ptr = (*bdrys)[i].points); 

    om$dealloc  (ptr = *bdrys); 
    *bdrys = NULL; 
    *num_bdrys = 0; 

   } /* if (*bdrys) */

  } /* if (!(1 & sts & *EMmsg)) */

  return(sts);
}

end implementation EMSloopset;
