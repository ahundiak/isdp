/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;   

#include "EMS.h"
#include "EMSopt.h"
#include "OMmacros.h"
#if DEBUG
#include "stdio.h"
#endif

from EMSloop import EMtreemod,EMgivenestinfo;
from EMSsubbs import EMpartolbasis, EMpassloop;
from EMSboundary import EMget_objid;
from EMSloopset import EMnesting,EMtreemod;
from EMSloop import EMset_props;

method EMfix_SSI(IGRlong *EMmsg; union EMSssi_table *ssi;
                 struct GRmd_env *env)
/*
Description

    This method will fix the ssi by reconnecting removed regions from
    surfaces that were also removed.  The arrays are adjusted
    accordingly.

Return values

    EMS_S_Success if all is well.

    EMS_E_Fail if surfaces are removed and their regions are not
    removed.

History
    DLB  2/21/90  Added check for in loop on removed surface.  This indicates
                  a cleanup failure so delete the in loop and adjust the SSI.
                  Also return an EMS_I_InvalidCase to the sender.
    DLB  1/27/88  Removed toglpactive call. This code will be executed
                  AFTER the EMboolean method erases the removed surfaces.
    04-Dec-1987 jBk If input ssi is NULL, return success immediately.
    02-Nov-1987 DLB Changed structure name for version 1.1.0
    30-Apr-1987 DLB Creation.
*/
{
 IGRlong             OM_stat;
 IGRint              i, surfout_index, numcomp_index, numsfout_index;
 IGRint              numrgout_index, num_out, total_rgout,sfout_index;
 IGRint              sf_index, rgout_index;
 IGRboolean          got_id, world, loop_in_error;
 GRobjid             out_id, lpset, loopid;
 struct EMSnest_info nesting;
 struct EMSpartolbasis partolbasis;
 OM_S_CHANSELECT     to_loopset, to_outter;
 struct EMSboolssi_table *my_info; 
 

 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 loop_in_error = FALSE;

 if (NOT ssi)
 {
   return EMS_S_Success;
 }

 EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
 EMmake_chanselect (EMSloop_to_outter, &to_outter);

 my_info = &ssi->bool_info;
 surfout_index = 0;

 for (
      numcomp_index = 0;
      numcomp_index < my_info->num_composites;
      numcomp_index ++
 )
 {

   for (numsfout_index = 0; 
        numsfout_index < my_info->num_surfaces_out[numcomp_index]; 
        numsfout_index ++, surfout_index ++)
   {

     /*Got the surface out id now find the id in the surf mod array*/
     got_id = FALSE;
     out_id = my_info->surface_out_ids[surfout_index];
     for (sf_index = 0; sf_index < my_info->num_surfaces; sf_index ++)
     {

       if (out_id == my_info->surface_ids[sf_index])
       {

         /*Got the matching id in the mod array now get its regions index*/
         rgout_index = 0;

         if (sf_index)           
         {
           for (numrgout_index = 0;
                numrgout_index < sf_index;
                numrgout_index ++)
           {
             rgout_index += my_info->num_regions_out[numrgout_index];
           }           
         }
        
         got_id = TRUE;
         break;
       }

     }  /*end for sf_index*/

     /*If I got here and didn't have an id then error*/
     if (! got_id) {*EMmsg = EMS_E_Fail;goto wrapup;}
     
     world = TRUE;
     OM_stat = om$send(msg = message EMSsubbs.EMpartolbasis(EMmsg,
                             &env->md_env.matrix_type,
                             env->md_env.matrix,&world,
                             FALSE,&partolbasis.tol),
                       targetid = out_id);
     if (! (1 & OM_stat & *EMmsg)) goto wrapup;

     partolbasis.mattyp = &env->md_env.matrix_type;
     partolbasis.mat = env->md_env.matrix;
     partolbasis.in_world = TRUE;
     partolbasis.is_valid = TRUE;

     OM_stat = om$send(msg = message EMSboundary.EMget_objid(EMmsg,&lpset),
                       senderid = out_id,
                       p_chanselect = &to_loopset);
     if (! (1 & OM_stat & *EMmsg)) goto wrapup;

     /*Re-nest the removed regions in the loopset*/
     num_out = my_info->num_regions_out[sf_index];
     for (i = rgout_index; i < (rgout_index + num_out); i++)
     {
       loopid = my_info->region_out_ids[i];

       {
           IGRshort prop_option = EMS_O_ON;       /*DECL*/
           IGRushort props = EMLP_ACTIVE;

           /*Set the loop to active in order to nest.*/
           OM_stat = om$send(msg = message EMSloop.EMset_props(EMmsg, 
                                   props, prop_option),
                             targetid = loopid);
           if (! (1 & OM_stat & *EMmsg)) goto wrapup;
       }

       OM_stat = om$send(msg = message EMSloop.EMgivenestinfo(EMmsg,
                               &nesting),
                         targetid = loopid);
       if (! (1 & OM_stat & *EMmsg)) goto wrapup;

       OM_stat = om$send(msg = message EMSloopset.EMnesting(EMmsg,&nesting,
                               &partolbasis),
                         targetid = lpset);
       if (! (1 & OM_stat & *EMmsg)) goto wrapup;

       if(IF_EQ_OBJID(lpset,nesting.parent))
         OM_stat = om$send(msg = message EMSloopset.EMtreemod(EMmsg,
                                 &nesting, ADD_CHILD,&partolbasis),
                           targetid = lpset);
       else
         OM_stat = om$send(msg = message EMSloop.EMtreemod(EMmsg,&nesting,
                                 ADD_CHILD,&partolbasis),
                           targetid = nesting.parent);
       if (! (1 & OM_stat & *EMmsg)) goto wrapup;
     }
 
     /*Get the total num regions removed*/
     total_rgout = 0;
     for (i = 0; i < my_info->num_surfaces; i++)
     {
       total_rgout += my_info->num_regions_out[i];
     }
    
     /*Collapse the region out ids array*/
     for (i = rgout_index; i < (total_rgout - num_out); i++)
     {
       my_info->region_out_ids[i] = my_info->region_out_ids[i + num_out];
     }

     if (my_info->num_regions_in[sf_index])
     {
       /*IMPORTANT- Got an invalid boolean case of in loop and surface removed.
        *           This indicates a topology cleanup problem.  So assume the
        *           in loop is bad and delete it.  Also adjust the SSI
        *           structure to take this into account.
        */
       IGRint numrgin_index, rgin_index, total_rgin, num_in, tmp_index;
       GRobjid sid;

       /*Compute the location of the in loops for this surface.*/
       rgin_index = 0;
       if (sf_index)           
       {
         for (numrgin_index = 0;
              numrgin_index < sf_index;
              numrgin_index ++)
         {
           rgin_index += my_info->num_regions_in[numrgin_index];
         }           
       }

       num_in = my_info->num_regions_in[sf_index];

       /*Delete the in loops since they are invalid.*/
       tmp_index = rgin_index;
       for (i = 0; i < num_in; i++, tmp_index++)
       {
         sid = NULL_OBJID;
         OM_stat = om$send(msg = message EMSboundary.EMget_objid(EMmsg, &sid),
                           senderid = my_info->region_in_ids[tmp_index],
                           p_chanselect = &to_outter);
         if (!(1 & OM_stat & *EMmsg)) goto wrapup;                           

         if (sid == NULL_OBJID) {*EMmsg = EMS_E_InvalidCase; goto wrapup;}

         OM_stat = om$send(msg = message Root.delete(NULL),
                           senderid = sid,
                           targetid = my_info->region_in_ids[tmp_index]);
         if (!(1 & OM_stat & *EMmsg)) goto wrapup;                           
       }         

       /*Get the total num regions added*/
       total_rgin = 0;
       for (i = 0; i < my_info->num_surfaces; i++)
       {
         total_rgin += my_info->num_regions_in[i];
       }

       /*Collapse the region in ids array*/

       for (i = rgin_index; i < (total_rgin - num_in); i++)
       {
         my_info->region_in_ids[i] = my_info->region_in_ids[i + num_in];
       }

       loop_in_error = TRUE;    
     }
        
     /*Collapse the surface, num_region_out, and num_region_in arrays*/
     my_info->num_surfaces -= 1;

     for (i = sf_index; i < my_info->num_surfaces; i++)
     {
       my_info->surface_ids[i] = my_info->surface_ids[i+1];
       my_info->num_regions_out[i] = my_info->num_regions_out[i+1];
       my_info->num_regions_in[i] = my_info->num_regions_in[i+1];
     }

     /*Removed send to EMtoglpactive from here 01/27/88 DLB*/

   } /*end for numsfout_index*/

 } /*end for numcomp*/
  
 wrapup:
  if ((1 & OM_stat & *EMmsg) && loop_in_error)
  {
    *EMmsg = EMS_I_InvalidCase;
#   if DEBUG
      fprintf(stderr,"Got in loop for surface removed.\n");
#   endif       
  }

  EMWRAPUP(*EMmsg, OM_stat, "In EMSsfboolean.EFfixSSI")
  return (OM_stat);
}
end implementation EMSsfboolean;
