/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#include "msdef.h"
#include "OMmacros.h"
#include "EMSopt.h"        /* For trim options */
#include "gocmacros.h"     /* GRgetabsg                    */
#include "emsedgedef.h"    /* EMlinestring */
#include "madef.h"         /* For PI */
#include <stdio.h>

method EMcreate_isophotes(IGRlong *EMmsg;
                           struct GRmd_env *md_env;
                           struct GRvg_construct *construct_list;
                           IGRushort options;
                           IGRvector vector;
                           IGRdouble start_angle;
                           IGRdouble stop_angle;
                           IGRint num_insert;
                           IGRint *num_crvs;
                           struct GRid **crv_ids)
/* ***********************************************************************

History
 pp : 09/01/89 : Creation
 pp : 10/02/89 : Fixed a problem which shows up when after trimming
                 there are no valid isophotes for a given angle.
 NP : 08/25/92 : Modified for ANSI compliance. Added typecast in realloc.

   ********************************************************************** */
{
 IGRlong status;
 IGRint i;
 struct IGRbsp_surface *surf = NULL;
 IGRint numgrps = 0;
 IGRint rc,ind;
 IGRint j;
 IGRchar *absg_ptr = NULL;
 IGRdouble angle,urange_buff[2],vrange_buff[2];
 IGRdouble incmnt;
 IGRboolean loc_stop = FALSE;
 extern void BSangpartrg();
 extern IGRboolean IGEstop();
 struct GRid *local_crv_ids = NULL;
 struct BSpartgrp  *partgrps = NULL;
 struct BSpartgrp      *grp;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 GRgetabsg(EMmsg, &md_env->md_env.matrix_type, md_env->md_env.matrix,
            &absg_ptr, i);
 if (! (1 & *EMmsg)) goto wrapup;

 surf = (struct IGRbsp_surface *) absg_ptr;

 urange_buff[0] = vrange_buff[0] = 0.0;
 urange_buff[1] = vrange_buff[1] = 1.0;

 ind = 1; /* To indicate that the surface has not been transformed */

 incmnt = (stop_angle - start_angle)/(num_insert+1);

 j = 0;
 do
 {
  IGRint local_numgrps = 0;
  struct BSpartgrp  *local_partgrps = NULL;

  angle = start_angle + j*incmnt;

  angle = angle * PI / 180.0; /* radians */

  BSangpartrg(surf,vector,angle,urange_buff,vrange_buff,ind,&local_numgrps,
              &local_partgrps,&rc);
  EMerr_hndlr((rc != 0), *EMmsg, EMS_E_BSerror, wrapup);


  if(local_numgrps)
  {
   struct BSpartgrp    *grp;

   if (!(options & EMSignoreBoundaries))
   {
     IGRushort loc_options;

     loc_options = EMStrimWorldData;

     EFtrimPartingLines(EMmsg, my_id, md_env, loc_options, &local_numgrps,
                      &local_partgrps);
     EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
   }
/*
 * After trimming the local_numgrps might be reduced to 0. Hence we need
 * to check the same again.
 * pp (10/02/89)
 */

   if (local_numgrps)
   {
    for(i=1, grp=local_partgrps; i < local_numgrps; i++, grp=grp->next);

    /*
     * Concatenate the lists
     */
    grp->next = partgrps;
    partgrps = local_partgrps;
    numgrps += local_numgrps;
   }
  }
  j++;
   loc_stop = IGEstop();
 }
 while (!loc_stop && (j < (num_insert + 2)) &&
        (start_angle != stop_angle));


 if (numgrps)
 {
 local_crv_ids = (struct GRid *)om$malloc
                    (size = numgrps * sizeof(struct GRid));
 if(! local_crv_ids) { *EMmsg = EMS_E_NoDynamicMemory; goto wrapup; }

 for(i = 0, grp = partgrps;
       i < numgrps;
       i ++, grp = grp->next)
 {
   IGRboolean status;

   local_crv_ids[i].osnum = construct_list->env_info->md_id.osnum;
   status = EFplace_line_string(my_id,
                                construct_list,
                                grp->num,
                                grp->pts,
                                &local_crv_ids[i].objid,
                                EMmsg); 
   if(! status) { *EMmsg = EMS_E_Fail; goto wrapup; }

  } /* for i < local_numgrps */

  if(crv_ids) /* Return the curve ids? */
  {
   if(*crv_ids) /* Are there already curves from a previous call? */
   {
      IGRint    size;

      /*
       * Concatenate the crv_ids array with local_crv_ids.
       */

        size = (*num_crvs + numgrps) * sizeof(*local_crv_ids);
        *crv_ids = (struct GRid *) om$realloc(ptr = (IGRchar *)*crv_ids,
                                                size = size);
        size = numgrps * sizeof(*local_crv_ids);
        OM_BLOCK_MOVE(local_crv_ids, &(*crv_ids)[*num_crvs], size);
        *num_crvs += numgrps;
        om$dealloc(ptr = local_crv_ids);
   }
  else /* First set of curves */
  {
    /*
     * Return the results.
     */
      *crv_ids = local_crv_ids;
      *num_crvs = numgrps;
  }
 } 
 else 
  if (num_crvs) *num_crvs += numgrps;
}



wrapup:
  /*
   * Clean up memory allocated for curve ids unless it being returned.
   */
  if((local_crv_ids) && (! crv_ids)) om$dealloc(ptr = local_crv_ids);

  if(partgrps)
  {
    IGRint              i;
    struct BSpartgrp    *grp, *nextgrp;

    for(i = 0, grp = partgrps; i < numgrps; i ++)
    {
      nextgrp = grp->next;
      if(grp->pts) om$dealloc(ptr = grp->pts);
      if(grp->par) om$dealloc(ptr = grp->par);
      om$dealloc(ptr = grp);
      grp = nextgrp;
    }
  }
 if (loc_stop) *EMmsg = EMS_I_Interrupt;
 return (status);
}
end implementation EMSsubbs;

