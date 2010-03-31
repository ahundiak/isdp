class implementation EMScompsurf;

%safe
#include <math.h>
%endsafe

#include "emsdef.h"
#include "EMSxsection.h"
#include "OMmacros.h"

/*
   DESCRIPTION

     This file contains functions used in quering the model while
     updating a cross section.

   HISTORY

     RC     10/04/88     Creation Date
*/

extern OMuword OPP_EMSsubbs_class_id;

void EFdoes_sf_exists (EFmsg, chk_list, num_elems, cand_sf, rm_list_entry,
                       sf_exists)
      IGRlong         *EFmsg;
      struct  GRid    *chk_list;
      IGRint          *num_elems;
      GRobjid         cand_sf;
      IGRboolean      rm_list_entry;
      IGRboolean      *sf_exists;
  
{
  IGRint         i;

  *EFmsg = EMS_S_Success;
  *sf_exists = FALSE;

  for (i = 0; i < *num_elems; i++)
  {
    if (IF_EQ_OBJID(chk_list[i].objid, cand_sf))
    {
      *sf_exists = TRUE;
      if (rm_list_entry)
      {
        OM_BLOCK_MOVE ( &chk_list[i+1], &chk_list[i], 
                      sizeof(struct GRid) * (*num_elems-i-1) );
        (*num_elems)--;
      }
      break;
    } /* if (IF_EQ_OBJID(chk_list[i].objid, cand_sf)) */

  } /* for (i = 0; i < num_elems; i++) */

  return;
} /* void EFdoes_sf_exists () */


/*
 * Add geometrically modified surfaces.
 */

void EFadd_gm_md_sfs ( EFmsg, md_info, gm_md_sfs, num_gm_md_sfs, cur_os)
   IGRlong                   *EFmsg;
   struct   EMSsfs_md_info   *md_info;
   GRobjid                   *gm_md_sfs;
   IGRint                    num_gm_md_sfs;
   GRspacenum                cur_os;

 {
   IGRlong      i, rc;
   IGRint       INITIAL_SIZE, BUF_INC;
   IGRboolean   is_added_sf, is_tp_md_sf, is_gm_md_sf;
   extern void  EFmemory_allocation(), EFdoes_sf_exists();

   *EFmsg = EMS_S_Success;

   INITIAL_SIZE = BUF_INC = 5;  
   EFmemory_allocation (&rc, (IGRchar **) &md_info->sfs_gm_md,
                   md_info->num_sfs_gm_md+num_gm_md_sfs,
                   &md_info->sfs_gm_md_arrsz, sizeof(struct GRid), 
                   INITIAL_SIZE, BUF_INC);
   EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

   for (i = 0; i < num_gm_md_sfs; i++)
   {
     EFdoes_sf_exists (&rc, md_info->sfs_added, &md_info->num_sfs_added, 
                       gm_md_sfs[i], FALSE, &is_added_sf);
     EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);
     
     if (!is_added_sf)
     {
       EFdoes_sf_exists (&rc, md_info->sfs_tp_md, &md_info->num_sfs_tp_md,
                         gm_md_sfs[i], TRUE, &is_tp_md_sf);
       EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

       EFdoes_sf_exists (&rc, md_info->sfs_gm_md, &md_info->num_sfs_gm_md,
                         gm_md_sfs[i], FALSE, &is_gm_md_sf);
       EMerr_hndlr (!(1&rc),*EFmsg, EMS_E_Fail, wrapup);

       if (!is_gm_md_sf)
       {
         md_info->sfs_gm_md[md_info->num_sfs_gm_md].objid = gm_md_sfs[i];
         md_info->sfs_gm_md[md_info->num_sfs_gm_md++].osnum = cur_os;

       } /* if (!is_gm_md_sf) */

     } /* if (!is_added_sf) */

   } /* for (i = 0; i < num_gm_md_sfs; i++) */

  wrapup:

   return;

} /* void EFadd_gm_md_sfs () */


/*
 * Add removed surfaces.
 */

void EFadd_rmvd_sfs ( EFmsg, md_info, rmvd_sfs, num_rmvd_sfs, cur_os)
   IGRlong                   *EFmsg;
   struct   EMSsfs_md_info   *md_info;
   GRobjid                   *rmvd_sfs;
   IGRint                    num_rmvd_sfs;
   GRspacenum                cur_os;

 {
   IGRlong      i, rc;
   IGRint       INITIAL_SIZE, BUF_INC;
   IGRboolean   is_added_sf, is_tp_md_sf, is_gm_md_sf;
   extern void  EFmemory_allocation(), EFdoes_sf_exists();

   *EFmsg = EMS_S_Success;
  
   INITIAL_SIZE = BUF_INC = 5;
   EFmemory_allocation (&rc, (IGRchar **) &md_info->sfs_rmvd,
                        md_info->num_sfs_rmvd + num_rmvd_sfs,
                        &md_info->sfs_rmvd_arrsz, sizeof(struct GRid), 
                        INITIAL_SIZE, BUF_INC);
   EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

   for (i = 0; i < num_rmvd_sfs; i++)
   {
     EFdoes_sf_exists (&rc, md_info->sfs_added, &md_info->num_sfs_added,
                       rmvd_sfs[i], TRUE, &is_added_sf);
     EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

     if (!is_added_sf)
     {
       EFdoes_sf_exists (&rc, md_info->sfs_gm_md, &md_info->num_sfs_gm_md,
                         rmvd_sfs[i], TRUE, &is_gm_md_sf);
       EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

       if (!is_gm_md_sf)
       {
         EFdoes_sf_exists (&rc, md_info->sfs_tp_md, 
                           &md_info->num_sfs_tp_md, rmvd_sfs[i], 
                           TRUE, &is_tp_md_sf);
         EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

       } /* if (!is_gm_md_sf) */
 
       md_info->sfs_rmvd[md_info->num_sfs_rmvd].objid = rmvd_sfs[i]; 
       md_info->sfs_rmvd[md_info->num_sfs_rmvd++].osnum = cur_os;

     } /* if (!is_added_sf) */
     
   } /* for (i = 0; i < num_sfs_rmvd; i++) */

   wrapup:
   return;

} /* void EFadd_rmvd_sfs () */

/*
 * Add topologically modified surfaces.
 */

void EFadd_tp_md_sfs ( EFmsg, md_info, tp_md_sfs, num_tp_md_sfs, cur_os)
   IGRlong                   *EFmsg;
   struct   EMSsfs_md_info   *md_info;
   GRobjid                   *tp_md_sfs;
   IGRint                    num_tp_md_sfs;
   GRspacenum                cur_os;

 {
   IGRlong      i, rc;
   IGRint       INITIAL_SIZE, BUF_INC;
   IGRboolean   is_added_sf, is_tp_md_sf, is_gm_md_sf;
   extern void  EFmemory_allocation(), EFdoes_sf_exists();

   *EFmsg = EMS_S_Success;
  
   INITIAL_SIZE = BUF_INC = 5;
   EFmemory_allocation (&rc, (IGRchar **) &md_info->sfs_tp_md,
                        md_info->num_sfs_tp_md + num_tp_md_sfs,
                        &md_info->sfs_tp_md_arrsz, sizeof(struct GRid), 
                        INITIAL_SIZE, BUF_INC);
   EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

   for (i = 0; i < num_tp_md_sfs; i++)
   {
      EFdoes_sf_exists (&rc, md_info->sfs_added, &md_info->num_sfs_added,
                        tp_md_sfs[i], FALSE, &is_added_sf);
      EMerr_hndlr (!(1&rc) ,*EFmsg, EMS_E_Fail, wrapup);

      if (!is_added_sf)
      {
        EFdoes_sf_exists (&rc, md_info->sfs_gm_md, 
            &md_info->num_sfs_gm_md, tp_md_sfs[i], FALSE, &is_gm_md_sf);
        EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

        if (!is_gm_md_sf)
        {
          EFdoes_sf_exists (&rc, md_info->sfs_tp_md, 
             &md_info->num_sfs_tp_md, tp_md_sfs[i], FALSE, &is_tp_md_sf);
          EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);
      
          if (!is_tp_md_sf)
          {
            md_info->sfs_tp_md[md_info->num_sfs_tp_md].objid = 
                     tp_md_sfs[i];
            md_info->sfs_tp_md[md_info->num_sfs_tp_md++].osnum = cur_os;

          } /* if (!is_tp_md_sf) */
    
        } /* if (!is_gm_md_sf) */

      } /* if (!is_added_sf) */
     
   } /* for (i = 0; i < num_tp_md_sfs; i++) */
   
   wrapup:
     return;

} /* void EFadd_tp_md_sfs () */


void EFadd_new_sfs ( EFmsg, md_info, md_env, owner_GRid, reject_GRid)
     IGRlong                  *EFmsg;
     struct  EMSsfs_md_info   *md_info;
     struct  GRmd_env         *md_env;
     struct  GRid             owner_GRid, reject_GRid;
{

  OM_S_CHANSELECT         to_comps_chan;
  struct          GRid    *cmpnt_sf_list; 
  IGRint                  count = 0, rej_count = 0, 
                          i, j, fr_inx, 
                          to_inx, INITIAL_SIZE, BUF_INC;
  OMuint                  num_comps, reject_inx;
  IGRlong                 OM_stat, mthd_stat, rc;
  GRobjid                 cmpnt_id;
  GRspacenum              cmpnt_os;
  extern void             EFgetobjids(), EFmemory_allocation();
  

  *EFmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;
  cmpnt_sf_list = NULL;

  OM_stat = EMmake_chanselect (GRcmpowner_to_components, &to_comps_chan);
  EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

  OM_stat = om$send (msg = message GRowner.GRget_number_components(
                      &mthd_stat, &count), senderid = NULL_OBJID,
                      targetid = owner_GRid.objid, 
                      targetos = owner_GRid.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_Fail, wrapup);

  OM_stat = om$send (msg = message GRowner.GRget_number_components(
                      &mthd_stat, &rej_count), senderid = NULL_OBJID,
                      targetid = reject_GRid.objid, 
                      targetos = reject_GRid.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EFmsg, EMS_E_Fail, wrapup);

  count -= rej_count;
  
  INITIAL_SIZE = BUF_INC = 5;  
  EFmemory_allocation (&rc, (IGRchar **) &md_info->sfs_added,
                       md_info->num_sfs_added+count, 
                       &md_info->sfs_added_arrsz,
                       sizeof(struct GRid), INITIAL_SIZE, BUF_INC);
  EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

  OM_stat = om$get_channel_count (objid = owner_GRid.objid,
                 osnum = owner_GRid.osnum, p_chanselect = &to_comps_chan,
                 count = &num_comps);
  EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

  OM_stat = om$get_index (objid_c = owner_GRid.objid, 
             osnum_c = owner_GRid.osnum, p_chanselect = &to_comps_chan,
             objid = reject_GRid.objid, osnum2 = owner_GRid.osnum,
             indexaddr = &reject_inx);
  EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

  for (i = 0; i < 2; i++)
  {
    fr_inx = i ? reject_inx+1 : 0;
    to_inx = i ? num_comps : reject_inx;

    for (j = fr_inx; j < to_inx; j++)
    {
      OM_stat = om$get_objid_at_index (osnum = owner_GRid.osnum,
                 objid = owner_GRid.objid, p_chanselect = &to_comps_chan,
                 index = j, objidaddr = &cmpnt_id, osnumaddr = &cmpnt_os);
      EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

      count = 0;
      OM_stat = om$send(msg = message GRowner.GRget_components(
                 &mthd_stat, md_env, 
                 &md_info->sfs_added[md_info->num_sfs_added], 
                 md_info->sfs_added_arrsz - md_info->num_sfs_added,
                 &count, 0, MAXINT), 
                senderid = NULL_OBJID,
                targetid = cmpnt_id, targetos = cmpnt_os);
      EMerr_hndlr (!(1&OM_stat&mthd_stat) && OM_stat !=OM_W_UNKNOWN_MSG,
          *EFmsg, EMS_E_Fail, wrapup);

      if (OM_stat != OM_W_UNKNOWN_MSG)
      {
        md_info->num_sfs_added += count;
      }
      else 
       OM_stat = OM_S_SUCCESS;

    } /* for (j = fr_inx; j < to_inx; j++) */

  } /* for (i = 0; i < 2; i++) */

  count = 0;
  EFgetobjids(&rc, &owner_GRid, &to_comps_chan, &cmpnt_sf_list, 
              &count, OPP_EMSsubbs_class_id, &reject_GRid, 1);
  EMerr_hndlr (!(1&rc), *EFmsg, EMS_E_Fail, wrapup);
 
  if (count)
  {
   OM_BLOCK_MOVE(cmpnt_sf_list, 
                 &md_info->sfs_added[md_info->num_sfs_added], 
                 count * sizeof(struct GRid));

   md_info->num_sfs_added += count;
  }

 wrapup:

  if (cmpnt_sf_list) om$dealloc(ptr = cmpnt_sf_list);
  EMWRAPUP (OM_stat, *EFmsg, "In EFadd_new_sfs");
  return;

} /* void EFadd_new_sfs() */ 
                     
end implementation EMScompsurf;
