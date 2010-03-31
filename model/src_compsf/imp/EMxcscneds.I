/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxscompsf;

%safe
#include <math.h>
%endsafe

# include "EMS.h"
# include "msdef.h" /* MS message codes */
# include "ma.h"
# include "EMSbnddef.h"
# include "EMSbnd.h"
# include "OMmacros.h"
# include "emsdef.h"
# include "emsmacros.h"
# include "bserr.h"
# include "bsparameters.h"
# include "EMcp.h"
# include "EMSprop.h"
# include "EMSopt.h"
# include "gocmacros.h"
# include "EMSxsection.h"
#include "bsdistptli.h"

#define EMSXS_ED_U0 0
#define EMSXS_ED_U1 2

/*
 DESCRIPTION
   This method connects edges of the cross section planes of the
   composite cross section surface. It is assumed that this method will
   be invoked only when this is the active state.
 
 HISTORY     

        RC     12/09/88      Creation Date
        Sudha  06/21/93      Modified to handle BSprototype ansification
*/

from EMSsubbs      import   EMget_edges;
from EMSboundary   import   EMget_objid, EMgetsurface_info;
from EMSedge       import   EMget_top_part_edges, EMstitch, EMset_props;

%safe
static void  EFupdate_xsection_assoc_info ();
%endsafe

%safe
static void  EFstitch_2_sets_of_edges ();
%endsafe


method EMconnect_edges(
  IGRlong             *EMmsg;
  struct GRmd_env     *md_env)

{
  OM_S_CHANSELECT           cm_ed_chan;
  struct  GRid              *sf_GRids = NULL, *ed_u0_GRids, *ed_u1_GRids,
                            *ed_GRids, *set1_eds, *set2_eds;
  struct  EMSxs_sfcn_info   *sfcn_info = NULL, *adsfcn_info, *nxtcn_info;
  struct  EMSxs_cn_info     xscn_info;
  struct  IGRbsp_surface    *sf_gm = NULL;
  struct  EMSfnmgr_info     del_info, put_info;
  IGRdouble                 *ed_pts, mid_pt[3], *aded_pts, dist, dist_tol;
  IGRlong                   OM_stat, mthd_stat, rc, sf_size;
  IGRint                    num_sfs, count, cur_sf, array_size, 
                            num_ed_u0s, num_ed_u1s, i, j, num_eds,
                            num_set1_eds, num_set2_eds, sf_gm_buf_size=0;
  GRobjid                   cmed_id, cmed_sfid;
  IGRshort                  sf_edtyp, adsf_edtyp;
  IGRboolean                ed_matched, eds_processed, status;

  /* **************************************************************** */

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  xscn_info.num_sfs = 0;
  xscn_info.sfcn_info = NULL;

  del_info.num_tips = del_info.num_fans = 0;
  del_info.tips_arrsz = del_info.fans_arrsz = 0;
  del_info.tips_p_fan_arrsz = 0;
  del_info.tips = NULL;
  del_info.fans = NULL;
  del_info.tips_p_fan = NULL;

  put_info.num_tips = put_info.num_fans = 0;
  put_info.tips_arrsz = put_info.fans_arrsz = 0;
  put_info.tips_p_fan_arrsz = 0;
  put_info.tips = NULL;
  put_info.fans = NULL;
  put_info.tips_p_fan = NULL;

  /*
   * o It is assumed that the order of connection of surfaces 
   *   along my to_components channel can be used in ordering
   *   edge combinations, which is as follows,
   *   
   *    o location_2_eds_of_sf0 can only be connected to 
   *      location_0_eds_of_sf1.
   *    o location_2_eds_of_sf1 can only be connected to 
   *      location_0_eds_of_sf2.
   *    o location_2_eds_of_sf2 can only be connected to 
   *      location_0_eds_of_sf3.
   *    o location_2_eds_of_sf3 can only be connected to 
   *      location_0_eds_of_sf4.
   *    o ........... and so on.
   */

  status = BSEXTRACTPAR (&rc, BSTOLLENVEC, dist_tol);

  OM_stat = om$send (msg = message GRowner.GRget_number_components (
                      &mthd_stat, &num_sfs),
                     targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

  if (!num_sfs) goto wrapup;

  sf_GRids = (struct GRid *) om$malloc(size = num_sfs *
                                       sizeof(struct GRid) );
  EMerr_hndlr (!sf_GRids,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

  OM_stat = om$send (msg = message GRowner.GRget_components (&mthd_stat,
                      md_env, sf_GRids, num_sfs, &count, 0, OM_K_MAXINT),
                     targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

  sfcn_info = (struct EMSxs_sfcn_info *) om$malloc (
                 size = sizeof(struct EMSxs_sfcn_info));
  EMerr_hndlr (!sfcn_info, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

  xscn_info.sfcn_info = sfcn_info;
  sfcn_info->ed_u0_GRids = sfcn_info->ed_u1_GRids = NULL;
  sfcn_info->num_ed_u0s = sfcn_info->num_ed_u1s = 0;
  sfcn_info->match_info = EMSXS_NO_MATCH;
  sfcn_info->next = sfcn_info->bkwrd = sfcn_info->fwrd = NULL;

  for (cur_sf = 0; cur_sf < num_sfs; cur_sf++)
  {
    array_size = 0;
    num_ed_u0s = num_ed_u1s = 0;
    ed_u0_GRids = ed_u1_GRids = NULL;
    OM_stat = om$send (msg = message EMSsubbs.EMget_edges (&mthd_stat,
                        MAXINT, EMS_OPT_NAT_LOC0, md_env, 
                        &ed_u0_GRids, &array_size, &num_ed_u0s),
                       targetid = sf_GRids[cur_sf].objid);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

    array_size = 0;
    OM_stat = om$send (msg = message EMSsubbs.EMget_edges (&mthd_stat,
                        MAXINT, EMS_OPT_NAT_LOC2, md_env, 
                        &ed_u1_GRids, &array_size, &num_ed_u1s),
                       targetid = sf_GRids[cur_sf].objid);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

    if (num_ed_u0s != 0 || num_ed_u1s != 0)
    {
      sfcn_info->sf_GRid = sf_GRids[cur_sf];
      sfcn_info->ed_u0_GRids = ed_u0_GRids;
      sfcn_info->ed_u1_GRids = ed_u1_GRids;
      sfcn_info->num_ed_u0s = num_ed_u0s;
      sfcn_info->num_ed_u1s = num_ed_u1s;
      xscn_info.num_sfs++;

      if (cur_sf < num_sfs-1)
      {
       sfcn_info->next = (struct EMSxs_sfcn_info *) om$malloc (
                   size = sizeof (struct EMSxs_sfcn_info));
       EMerr_hndlr(!sfcn_info->next, *EMmsg,EMS_E_NoDynamicMemory,wrapup);

       sfcn_info = sfcn_info->next;
       sfcn_info->ed_u0_GRids = sfcn_info->ed_u1_GRids = NULL;
       sfcn_info->num_ed_u0s = sfcn_info->num_ed_u1s = 0;
       sfcn_info->match_info = EMSXS_NO_MATCH;
       sfcn_info->next = sfcn_info->bkwrd = sfcn_info->fwrd = NULL;

      } /* if (cur_sf < num_sfs-1) */
      
    } /* if (num_ed_u0s != 0 || num_ed_u1s != 0) */

  } /* for (cur_sf = 0; cur_sf < num_sfs; cur_sf++) */

  /*
   * sort the xscn_info such that surfaces are in order of sf0, sf1
   * etc, as explained above.
   */

  OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
  EMerr_hndlr (!(1&OM_stat), *EMmsg,EMS_E_OMerror,wrapup);

  sfcn_info = xscn_info.sfcn_info;

  for (cur_sf = 0; cur_sf < xscn_info.num_sfs; cur_sf++)
  {
   for (j = 0; j < 2; j++)
   {
     ed_matched = TRUE;
     sf_edtyp = j ? EMSXS_ED_U1 : EMSXS_ED_U0;

     if (sf_edtyp == EMSXS_ED_U0 && sfcn_info->num_ed_u0s)
     {
       if (!(sfcn_info->match_info & EMSXS_ED_U0_MATCH))
       {
         ed_matched = FALSE;
         ed_GRids = sfcn_info->ed_u0_GRids;
         num_eds = sfcn_info->num_ed_u0s;
       }
     } /* if (sf_edtyp == EMSXS_ED_U0 && sfcn_info->num_ed_u0s) */

     else if (sf_edtyp == EMSXS_ED_U1 && sfcn_info->num_ed_u1s) 
     {
       if (!(sfcn_info->match_info & EMSXS_ED_U1_MATCH))
       {
         ed_matched = FALSE;
         ed_GRids = sfcn_info->ed_u1_GRids;
         num_eds = sfcn_info->num_ed_u1s;
       }  
     } /* else if (sf_edtyp == EMSXS_ED_U1 && sfcn_info->num_ed_u1s) */
      
     if (!ed_matched)
     {
      for (i = 0; i < num_eds; i++)
      {
       cmed_id = NULL_OBJID;
       OM_stat = om$send (msg = message EMSboundary.EMget_objid (
                           &mthd_stat, &cmed_id),
                          senderid = ed_GRids[i].objid,
                          p_chanselect = &cm_ed_chan);
       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

       if (!IF_NULL_OBJID(cmed_id))
       {
        cmed_sfid = NULL_OBJID;
        OM_stat = om$send (msg = message EMSboundary.EMgetsurface_info (
                            &mthd_stat, &cmed_sfid, NULL),
                           targetid = cmed_id);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

        if (IF_NULL_OBJID(cmed_sfid)) 
        {
         OM_stat = om$send (msg = message Root.wild_disconnect (
                             cm_ed_chan),
                            targetid = ed_GRids[i].objid,
                            targetos = ed_GRids[i].osnum);
         EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

         OM_stat = om$send (msg = message EMSedge.EMset_props (&mthd_stat,
                             EMED_SUBORDINATE, EMS_O_OFF),
                            targetid = ed_GRids[i].objid);
         EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

        } /* if (IF_NULL_OBJID(cmed_sfid)) */

        else ed_matched = TRUE;

       } /* if (!IF_NULL_OBJID(cmed_id)) */

      } /* for (i = 0; i < num_eds; i++) */

      if (ed_matched)
      {
       adsfcn_info = xscn_info.sfcn_info;

       while (adsfcn_info)
       {         
         if (IF_EQ_OBJID (adsfcn_info->sf_GRid.objid, cmed_sfid))
         {
           if (sf_edtyp == EMSXS_ED_U0)
           {
             sfcn_info->bkwrd = adsfcn_info;
             sfcn_info->match_info |= EMSXS_ED_U0_MATCH;
             adsfcn_info->fwrd = sfcn_info;
             adsfcn_info->match_info |= EMSXS_ED_U1_MATCH;
             ed_GRids = adsfcn_info->ed_u1_GRids;
             num_eds = adsfcn_info->num_ed_u1s;
           }
           else
           {
             sfcn_info->fwrd = adsfcn_info;
             sfcn_info->match_info |= EMSXS_ED_U1_MATCH;
             adsfcn_info->bkwrd = sfcn_info;
             adsfcn_info->match_info |= EMSXS_ED_U0_MATCH;
             ed_GRids = adsfcn_info->ed_u0_GRids;
             num_eds = adsfcn_info->num_ed_u0s;
           }

           /*
            * Make sure none of the edges of the adsf has an
            * inactive common edge.
            */

           for (i = 0; i < num_eds; i++)
           {
             cmed_id = NULL_OBJID;
             OM_stat = om$send (msg = message EMSboundary.EMget_objid (
                                 &mthd_stat, &cmed_id),
                                senderid = ed_GRids[i].objid,
                                p_chanselect = &cm_ed_chan);
             EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

             if (!IF_NULL_OBJID(cmed_id))
             {
               cmed_sfid = NULL_OBJID;
               OM_stat = om$send (
                         msg = message EMSboundary.EMgetsurface_info (
                          &mthd_stat, &cmed_sfid, NULL),
                         targetid = cmed_id);
               EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

               if (IF_NULL_OBJID(cmed_sfid)) 
               {
                 OM_stat = om$send (msg = message Root.wild_disconnect (
                                     cm_ed_chan),
                                    targetid = ed_GRids[i].objid,
                                    targetos = ed_GRids[i].osnum);
                 EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

                 OM_stat = om$send (msg = message EMSedge.EMset_props (
                                     &mthd_stat, EMED_SUBORDINATE, 
                                     EMS_O_OFF),
                                    targetid = ed_GRids[i].objid);
                 EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);
               } /* if (IF_NULL_OBJID(cmed_sfid)) */

             } /* if (!IF_NULL_OBJID(cmed_id)) */

           } /* for (i = 0; i < num_eds; i++) */

         } /* if(IF_EQ_OBJID(adsfcn_info->sf_GRid.objid, cmed_sfid)) */
         else
          adsfcn_info = adsfcn_info->next;

       } /* while (adsfcn_info) */

      } /* if (ed_matched) */

     } /* if (!ed_matched) */

   } /* for (j = 0; j < 2; j++) */
   
   if ( ( sfcn_info->num_ed_u0s && 
          !(sfcn_info->match_info & EMSXS_ED_U0_MATCH) )       ||
        ( sfcn_info->num_ed_u1s &&
          !(sfcn_info->match_info & EMSXS_ED_U1_MATCH) ) )
   {
     OM_stat = om$send (msg = message GRvg.GRgetsize (&mthd_stat,
                         &md_env->md_env.matrix_type,
                         md_env->md_env.matrix, &sf_size),
                        targetid = sfcn_info->sf_GRid.objid,
                        targetos = sfcn_info->sf_GRid.osnum);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

     if (sf_size > sf_gm_buf_size)
     {
      if (!sf_gm_buf_size)
         sf_gm = (struct IGRbsp_surface *) om$malloc (size = sf_size);
      else   
         sf_gm = (struct IGRbsp_surface *) om$realloc (ptr = 
                 (IGRchar *)sf_gm, size = sf_size);
      sf_gm_buf_size = sf_size;

      } /* if (sf_size > sf_gm_buf_size) */

      OM_stat = om$send (msg = message GRvg.GRgetgeom (&mthd_stat, 
                          &md_env->md_env.matrix_type,
                          md_env->md_env.matrix, (IGRchar *) sf_gm),
                         targetid = sfcn_info->sf_GRid.objid);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

      OM_BLOCK_MOVE (sf_gm->poles,sfcn_info->ed_u0_pts,sizeof(IGRpoint));
      OM_BLOCK_MOVE (&sf_gm->poles[6], &sfcn_info->ed_u0_pts[3],
                     sizeof(IGRpoint));
      OM_BLOCK_MOVE (&sf_gm->poles[3], sfcn_info->ed_u1_pts, 
                     sizeof(IGRpoint));
      OM_BLOCK_MOVE (&sf_gm->poles[9], &sfcn_info->ed_u1_pts[3], 
                     sizeof(IGRpoint));

   } /* if ( ( sfcn_info->num_ed_u0s &&  .... */

   sfcn_info = sfcn_info->next;

  } /* for (cur_sf = 0; cur_sf < xscn_info.num_sfs; cur_sf++) */

  sfcn_info = xscn_info.sfcn_info;
  for (cur_sf = 0; cur_sf < xscn_info.num_sfs; cur_sf++)
  {
   for (j = 0; j < 2; j++)
   {
     ed_matched = TRUE;
     sf_edtyp = j ? EMSXS_ED_U1 : EMSXS_ED_U0;

     if (sf_edtyp == EMSXS_ED_U0 && sfcn_info->num_ed_u0s)
     {
       if (!(sfcn_info->match_info & EMSXS_ED_U0_MATCH))
       {
         ed_matched = FALSE;
         ed_pts = sfcn_info->ed_u0_pts;
       }
     } /*   if (!(sfcn_info->match_info & EMSXS_ED_U0_MATCH)) */

     else if (sf_edtyp == EMSXS_ED_U1 && sfcn_info->num_ed_u1s)
     {
      if (!(sfcn_info->match_info & EMSXS_ED_U1_MATCH))
      {
        ed_matched = FALSE;
        ed_pts = sfcn_info->ed_u1_pts;
      }  
     } /* else if (sf_edtyp == EMSXS_ED_U1 && sfcn_info->num_ed_u1s) */
     
     if (!ed_matched)
     {
      for (i = 0; i < 3; i++) 
        mid_pt[i] = (ed_pts[i] + ed_pts[i+3])/2.; 

      adsfcn_info = xscn_info.sfcn_info;
      adsf_edtyp = (sf_edtyp == EMSXS_ED_U0) ? EMSXS_ED_U1 :
                                                 EMSXS_ED_U0;
      while (adsfcn_info)
      {
       if (!IF_EQ_OBJID (sfcn_info->sf_GRid.objid, 
                         adsfcn_info->sf_GRid.objid))
       {
        if (( adsf_edtyp == EMSXS_ED_U0 && adsfcn_info->num_ed_u0s &&
              !(adsfcn_info->match_info & EMSXS_ED_U0_MATCH) )
                             ||
            ( adsf_edtyp == EMSXS_ED_U1 && adsfcn_info->num_ed_u1s &&
              !(adsfcn_info->match_info & EMSXS_ED_U1_MATCH) ) )
        {
          aded_pts = (adsf_edtyp == EMSXS_ED_U0) ? 
                      adsfcn_info->ed_u0_pts : adsfcn_info->ed_u1_pts;
          status = BSdistptli (&rc, mid_pt, aded_pts, &aded_pts[3],
                               &dist );
          EMerr_hndlr(!status || rc!= BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
          if (dist <= dist_tol)
            ed_matched = TRUE;

        } /* if */

       } /* if (!IF_EQ_OBJID (sfcn_info->sf_GRid.objid, 
                              adsfcn_info->sf_GRid.objid)) */
       if (ed_matched)
       {
         if (sf_edtyp == EMSXS_ED_U0)
         {
           sfcn_info->bkwrd = adsfcn_info;
           sfcn_info->match_info |= EMSXS_ED_U0_MATCH;
           adsfcn_info->fwrd = sfcn_info;
           adsfcn_info->match_info |= EMSXS_ED_U1_MATCH;
         }
         else
         {
           sfcn_info->fwrd = adsfcn_info;
           sfcn_info->match_info |= EMSXS_ED_U1_MATCH;
           adsfcn_info->bkwrd = sfcn_info;
           adsfcn_info->match_info |= EMSXS_ED_U0_MATCH;
         }
         break;

        } /* if (ed_matched) */

        adsfcn_info = adsfcn_info->next;

      } /* while (adsfcn_info) */

     } /* if (!ed_matched) */

   } /* for (j = 0; j < 2; j++) */
   
   sfcn_info = sfcn_info->next;
 
  } /* for (cur_sf = 0; cur_sf < xscn_info.num_sfs; cur_sf++) */

  /*
   * Perform edge matching.
   */

  sfcn_info = xscn_info.sfcn_info;

  while (sfcn_info)
  {
   for (i = 0; i < 2; i++)
   {
     sf_edtyp = i ? EMSXS_ED_U1 : EMSXS_ED_U0;
     eds_processed = TRUE;
     if (sf_edtyp == EMSXS_ED_U0)
     {
       if ( (sfcn_info->match_info & EMSXS_ED_U0_MATCH) && 
            !(sfcn_info->match_info & EMSXS_ED_U0_PRC) )
       {
         eds_processed = FALSE;
         set1_eds = sfcn_info->ed_u0_GRids;
         num_set1_eds = sfcn_info->num_ed_u0s;
         adsfcn_info = sfcn_info->bkwrd;
         set2_eds = adsfcn_info->ed_u1_GRids;
         num_set2_eds = adsfcn_info->num_ed_u1s;
       }
     } /* if (sf_edtyp == EMSXS_ED_U0) */
     else
     {
       if ( (sfcn_info->match_info & EMSXS_ED_U1_MATCH) && 
            !(sfcn_info->match_info & EMSXS_ED_U1_PRC) )
       {
         eds_processed = FALSE;
         set1_eds = sfcn_info->ed_u1_GRids;
         num_set1_eds = sfcn_info->num_ed_u1s;
         adsfcn_info = sfcn_info->fwrd;
         set2_eds = adsfcn_info->ed_u0_GRids;
         num_set2_eds = adsfcn_info->num_ed_u0s;
       }
 
     } /* else for if (sf_edtyp == EMSXS_ED_U0) */
 
     if (!eds_processed)
     { 
       EFstitch_2_sets_of_edges ( &rc, set1_eds, set2_eds, num_set1_eds,
         num_set2_eds, sfcn_info->sf_GRid, adsfcn_info->sf_GRid,
         md_env);
       EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

       sfcn_info->match_info |= (sf_edtyp == EMSXS_ED_U0) ? 
                                EMSXS_ED_U0_PRC : EMSXS_ED_U1_PRC;
       adsfcn_info->match_info |= (sf_edtyp == EMSXS_ED_U0) ? 
                                EMSXS_ED_U1_PRC : EMSXS_ED_U0_PRC;

       /*
        * Update xsection fan manager instance data.
        */

       EFupdate_xsection_assoc_info (&rc, set1_eds, num_set1_eds,
            set2_eds, num_set2_eds, &del_info, &put_info, 
            OM_Gw_current_OS);
       EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);     

     } /* if (!eds_processed) */

   } /* for (i = 0; i < 2; i++) */

   sfcn_info = sfcn_info->next;

  } /* while (sfcn_info) */

wrapup:
 EMWRAPUP (*EMmsg, OM_stat, "In EMSxscompsf.EMconnect_edges");
 if (num_sfs)
 {
  sfcn_info = xscn_info.sfcn_info;
  while (sfcn_info)
  {
   nxtcn_info = sfcn_info->next;
   if (sfcn_info->ed_u0_GRids) om$dealloc (ptr = sfcn_info->ed_u0_GRids);
   if (sfcn_info->ed_u1_GRids) om$dealloc (ptr = sfcn_info->ed_u1_GRids);
   sfcn_info = nxtcn_info;

  } /* while (sfcn_info) */

  if (sf_GRids) om$dealloc (ptr = sf_GRids);
  if (del_info.tips) om$dealloc (ptr = del_info.tips);
  if (del_info.fans) om$dealloc (ptr = del_info.fans);
  if (del_info.tips_p_fan) om$dealloc (ptr = del_info.tips_p_fan);
  if (put_info.tips) om$dealloc (ptr = put_info.tips);
  if (put_info.fans) om$dealloc (ptr = put_info.fans);
  if (put_info.tips_p_fan) om$dealloc (ptr = put_info.tips_p_fan);
  if (sf_gm) om$dealloc (ptr = sf_gm);

 } /* if (num_sfs) */

 return (OM_stat);
}

static void EFstitch_2_sets_of_edges ( EFmsg, set1_eds, set2_eds, 
       num_set1_eds, num_set2_eds, set1_sf, set2_sf, md_env)
  IGRlong             *EFmsg;
  struct  GRid        *set1_eds, *set2_eds;
  IGRint              num_set1_eds, num_set2_eds;
  struct  GRid        set1_sf, set2_sf;
  struct  GRmd_env    *md_env;
{
  OM_S_CHANSELECT        cm_ed_chan;
  struct EMSstitch_info  stitch_pair;
  struct IGRbsp_surface  *sf_gm;
  struct GRid            *ed_GRids;
  IGRlong                mthd_stat, OM_stat, sf_size;
  GRobjid                *set1_tpeds = NULL, *set2_tpeds = NULL;
  GRspacenum             cur_os;
  OMuint                 num_cm_eds;
  IGRint                 *set2_eds_processed = NULL, i, j, inx1, inx2,
                         num_set1_tpeds, num_set2_tpeds, 
                         set1_tpeds_arrsz = 0, set2_tpeds_arrsz = 0,
                         num_cn_eds, num_eds, count;

  /* ***************************************************************** */

  *EFmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;
  cur_os = md_env->md_id.osnum;

  set2_eds_processed = (IGRint *) om$malloc (size = num_set2_eds *
                                             sizeof(IGRint));
  EMerr_hndlr (!set2_eds_processed,*EFmsg,EMS_E_NoDynamicMemory,wrapup);

  for (i = 0; i < num_set2_eds; i++)
    set2_eds_processed[i] = FALSE;

  OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
  EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

  stitch_pair.surf0 = set1_sf.objid;
  stitch_pair.surf1 = set2_sf.objid;
  stitch_pair.edge_geom0 = NULL;
  stitch_pair.edge_geom1 = NULL;
  stitch_pair.option = EMSstitch_NoMoveSurfs | EMSstitch_NoOrientSurfs;

  for (i = 0; i < 2; i++)
  {
    OM_stat = om$send (msg = message GRvg.GRgetsize (&mthd_stat,
                        &md_env->md_env.matrix_type,
                        md_env->md_env.matrix, &sf_size),
                       senderid = NULL_OBJID,
                       targetid = i ? set2_sf.objid : set1_sf.objid,
                       targetos = i ? set2_sf.osnum : set1_sf.osnum);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);

    sf_gm = NULL;
    sf_gm = (struct IGRbsp_surface *) om$malloc (size = sf_size);

    OM_stat = om$send (msg = message GRvg.GRgetgeom (&mthd_stat, 
                        &md_env->md_env.matrix_type,
                        md_env->md_env.matrix, (IGRchar *) sf_gm),
                       senderid = NULL_OBJID,
                       targetid = i ? set2_sf.objid : set1_sf.objid,
                       targetos = i ? set2_sf.osnum : set1_sf.osnum);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_SurfaceError,wrapup);

    if (i)  stitch_pair.surf_geom1 = sf_gm;
    else stitch_pair.surf_geom0 = sf_gm;
   
  } /* for (i = 0; i < 2; i++) */


  for (inx1 = 0; inx1 < num_set1_eds; inx1++)
  {
   for (inx2 = 0; inx2 < num_set2_eds; inx2++)
   {
    if (!set2_eds_processed[inx2])
    {
     num_set1_tpeds = 0;
     OM_stat = om$send (msg = message EMSedge.EMget_top_part_edges (
                         &mthd_stat, &set1_tpeds, &num_set1_tpeds,
                         &set1_tpeds_arrsz),
                        senderid = NULL_OBJID,
                        targetid = set1_eds[inx1].objid,
                        targetos = set1_eds[inx1].osnum);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

     num_cn_eds = 0;
     for (i = 0; i < num_set1_tpeds; i++)
     {
      OM_stat = om$get_channel_count (objid = set1_tpeds[i],
                   osnum = cur_os, p_chanselect = &cm_ed_chan,
                   count = &num_cm_eds);
      EMerr_hndlr (!(1&OM_stat),*EFmsg, EMS_E_OMerror, wrapup);

      if (num_cm_eds) num_cn_eds++;
         
     } /* for (i = 0; i < num_set1_tpeds; i++) */

     if (num_cn_eds == num_set1_tpeds) break;

     num_set2_tpeds = 0;
     OM_stat = om$send (msg = message EMSedge.EMget_top_part_edges (
                         &mthd_stat, &set2_tpeds, &num_set2_tpeds,
                         &set2_tpeds_arrsz),
                        senderid = NULL_OBJID,
                        targetid = set2_eds[inx2].objid,
                        targetos = set2_eds[inx2].osnum);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

     num_cn_eds = 0;
     for (i = 0; i < num_set2_tpeds; i++)
     {
      OM_stat = om$get_channel_count (objid = set2_tpeds[i],
                   osnum = cur_os, p_chanselect = &cm_ed_chan,
                   count = &num_cm_eds);
      EMerr_hndlr (!(1&OM_stat),*EFmsg, EMS_E_OMerror, wrapup);

      if (num_cm_eds) num_cn_eds++;
         
     } /* for (i = 0; i < num_set2_tpeds; i++) */

     if (num_cn_eds < num_set2_tpeds)
     {
      stitch_pair.edge0 = set1_eds[inx1].objid;
      stitch_pair.edge1 = set2_eds[inx2].objid;

      OM_stat = om$send (msg = message EMSedge.EMstitch (&mthd_stat,
                          &stitch_pair, md_env, NULL, NULL, NULL, NULL,
                          NULL),
                         senderid = NULL_OBJID,
                         targetid = set1_eds[inx1].objid,
                         targetos = set1_eds[inx1].osnum);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

     } /* if (num_cn_eds < num_set2_tpeds) */
     else
      set2_eds_processed[inx2] = TRUE;

    } /* if (!set2_eds_processed[inx2]) */

   } /* for (inx2 = 0; inx2 < num_set2_eds; inx2++) */

  } /* for (inx1 = 0; inx1 < num_set1_eds; inx1++) */

 wrapup:
  EMWRAPUP (*EFmsg, OM_stat, "In EFstitch_2_sets_of_edges");
  if (stitch_pair.surf_geom0) om$dealloc (ptr = stitch_pair.surf_geom0);
  if (stitch_pair.surf_geom1) om$dealloc (ptr = stitch_pair.surf_geom1);
  if (set2_eds_processed) om$dealloc (ptr = set2_eds_processed);
  if (set1_tpeds) om$dealloc (ptr = set1_tpeds);
  if (set2_tpeds) om$dealloc (ptr = set2_tpeds);
  return;

} /* EFstitch_2_sets_of_edges () */

static void EFupdate_xsection_assoc_info (EFmsg, set1_eds, num_set1_eds,
       set2_eds, num_set2_eds, del_info, put_info, cur_os)

    IGRlong               *EFmsg;
    struct  GRid          *set1_eds, *set2_eds;
    IGRint                num_set1_eds, num_set2_eds;
    struct EMSfnmgr_info  *del_info, *put_info;
    GRspacenum            cur_os;
{
  OM_S_CHANSELECT  cm_ed_chan;
  struct  GRid     *ed_GRids;
  IGRlong          OM_stat, mthd_stat, rc;
  IGRint           i, j, num_eds, num_tpeds, tpeds_arrsz = 0, k; 
  OMuint           num_cm_eds;
  GRobjid          *tpeds = NULL;
  extern void      EFmemory_allocation(), EFfnmgr_manipulation();

  /* ****************************************************************** */

  *EFmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
  EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

  for (i = 0; i < 2; i++)
  {
    ed_GRids = i ? set2_eds : set1_eds;
    num_eds = i ? num_set2_eds : num_set1_eds;

    del_info->num_tips = 0;
    del_info->num_fans = 0;
    put_info->num_tips = 0;
    put_info->num_fans = 0;

    EFmemory_allocation (&rc, (IGRchar **) &del_info->tips, 
                         num_eds, &del_info->tips_arrsz, sizeof(GRobjid), 
                         num_eds, 0);
    EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);

    EFmemory_allocation (&rc, (IGRchar **) &del_info->fans, 
                         num_eds, &del_info->fans_arrsz, sizeof(GRobjid), 
                         num_eds, 0);
    EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);

    EFmemory_allocation (&rc, (IGRchar **) &put_info->fans, 
                         num_eds, &put_info->fans_arrsz, sizeof(GRobjid), 
                         num_eds, 0);
    EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);

    EFmemory_allocation (&rc, (IGRchar **) &put_info->tips_p_fan, 
                         num_eds, &put_info->tips_p_fan_arrsz, 
                         sizeof(IGRint), num_eds, 0);
    EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);

    for (j = 0; j < num_eds; j++)
    {
      num_tpeds = 0;
      OM_stat = om$send (msg = message EMSedge.EMget_top_part_edges (
                          &mthd_stat, &tpeds, &num_tpeds,
                          &tpeds_arrsz),
                         senderid = NULL_OBJID,
                         targetid = ed_GRids[j].objid,
                         targetos = ed_GRids[j].osnum);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);

      /*
       * The edges with common edge connections should have their 
       * EMED_SUBORDINATE property shoud be turned on.
       */

      for (k = 0; k < num_tpeds; k++)
      {
        OM_stat = om$get_channel_count (objid = tpeds[k], osnum = cur_os,
                     p_chanselect = &cm_ed_chan, count = &num_cm_eds);
        EMerr_hndlr (!(1&OM_stat),*EFmsg,EMS_E_OMerror,wrapup);

        if (num_cm_eds)
        {
         OM_stat = om$send (msg = message EMSedge.EMset_props (&mthd_stat,
                             EMED_SUBORDINATE, EMS_O_ON),
                            senderid = NULL_OBJID,
                            targetid = tpeds[k], targetos = cur_os);
         EMerr_hndlr(!(1&OM_stat&mthd_stat),*EFmsg,EMS_E_EdgeError,wrapup);
        } /* if (num_cm_eds) */

      } /* for (k = 0; k < num_tpeds; k++) */

      if (num_tpeds > 1)
      {
        del_info->tips[del_info->num_tips++] = ed_GRids[j].objid;

        EFmemory_allocation (&rc, (IGRchar **) &put_info->tips,
          put_info->num_tips+num_tpeds, &put_info->tips_arrsz,
          sizeof(GRobjid), 10, 5);
        EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup);

        OM_BLOCK_MOVE (tpeds, &put_info->tips[put_info->num_tips],
                       sizeof(GRobjid) * num_tpeds);
        put_info->num_tips += num_tpeds;
   
        put_info->tips_p_fan[j] = num_tpeds;

      } /* if (num_tpeds > 1) */

    } /* for (j = 0; j < num_eds; j++) */

    if (del_info->num_tips)
    {
     EFfnmgr_manipulation (&rc, cur_os, EMSlabel_xsection, 
                           EMSFM_MANIP_GET, EMSFM_KEY_TIP, del_info,NULL);
     EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);

     for (j = 0; j < del_info->num_tips; j++)
       put_info->fans[j] = del_info->fans[j];

     put_info->num_fans = del_info->num_tips;

     EFfnmgr_manipulation (&rc,cur_os, EMSlabel_xsection, EMSFM_MANIP_DEL,
                           EMSFM_KEY_TIP, del_info, NULL);
     EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);

     EFfnmgr_manipulation (&rc,cur_os, EMSlabel_xsection, EMSFM_MANIP_PUT,
                           EMSFM_KEY_TIP, put_info, NULL);
     EMerr_hndlr (!(1&rc),*EFmsg,EMS_E_Fail,wrapup);

    } /* if (del_info->num_tips) */

  } /* for (i = 0; i < 2; i++) */

  wrapup:
   EMWRAPUP (*EFmsg, OM_stat, "In EFupdate_xsection_assoc_info");
   if (tpeds) om$dealloc (ptr = tpeds);
   return;

} /* EFupdate_xsection_assoc_info() */

end implementation EMSxscompsf;
