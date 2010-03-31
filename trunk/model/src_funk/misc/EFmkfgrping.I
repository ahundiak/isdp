/* ###################   APOGEE COMPILED   ################## */
class implementation Root;

/*
Abstract

    This function is used to get user input while
    grouping ambiguous loops in make-face.

History

06 Oct 1991 AIC Changed arguments to EMget_ele_header.

22 May 1989 jBk Replaced invocations of GRgetevent with uses of
                co$getevent.

09 Sep 1988 jBk Changed name of message EMget_adjacent_loops to
                EMgetAdjacentLoops.  Added appropriate values for
                new mustHaveProps and mustNotHaveProps arguments
                of message EMgetAdjacentLoops.

17 Dec 1988 RC  Creation date.

 */
# include "igrtypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "OMminimum.h"
# include "igetypedef.h"
# include "igrtypedef.h"
# include "dp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
# include "gr.h"
#include "OMerrordef.h" /* OM message codes */
#include "exdef.h"      /* GRm_RJT_MOVEON   */

#include "OMmacros.h"   /* OM_BLOCK_MOVE*/
#include "EMSlmdef.h"
#include "OMlimits.h"   /* for ex.h     */
#include "ex.h"         /* for grio.h   */
#include "griodef.h"    /* for grio.h   */
#include "grio.h"       /* for lc.h     */
#include "lcdef.h"      /* for lc.h     */
#include "lc.h"         /* GRlc_stack   */
#include "dpdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpmacros.h"
#include "griomacros.h" /* co$getevent */
#include "bserr.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSprop.h"
#include "EMSerrordef.h"
#include "EMSerrnumdef.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

from EMSedge     import   EMdisplay;
from EMSsubbs    import   EMget_ele_header;
from EMSboundary import   EMtree_traverse;
from EMSloop     import   EMmkf_lp_display, EMgetAdjacentLoops;
from GRvg        import   GRgetsize, GRgetgeom;

IGRint  EFgrp_ambiguous_loops (
    EMmsg, 
    lps_id,
    num_lps,
    lps_grp,
    sf_GRid,
    md_env,
    accept_event,
    response, 
    response_data)

  IGRlong                 *EMmsg; 
  GRobjid                 *lps_id;
  IGRint                  num_lps;
  IGRlong                 *lps_grp;
  struct GRid             sf_GRid;
  struct GRmd_env         *md_env;
  struct GRevent          *accept_event;
  IGRint                  *response; 
  IGRchar                 *response_data; 

{
  GRobjid             *temp_lps, *adj_lps, cur_lp;
  IGRlong             OM_stat, mthd_stat, mask, sf_size, display_gr,
                      adj_lp_gr;
  IGRint              status, cur_entry, size = sizeof(struct GRevent);
  IGRint              *adj_lps_per_gr, num_lps_left, cur_gr, cur_inx;
  IGRint              i, j, num_gr, lps_id_inx, cur_ad_lp, num_adj_lps;
  IGRint              gr_lp_inx, last_input;
  IGRboolean          lp_found, any_lp_displayed;
  IGRshort            display_flag;
  IGRuchar    def_weight, p_lp_style, c_lp_style;
  enum GRdpmode       display_mode;

  GRrange             range;
  struct GRsymbology  symb;
  struct DPele_header sf_ele_header;
  struct IGRbsp_surface *sf_geom;
  union  IGRele_attr  ele_spec_att;
  struct IGResqbs     bsqsurf;
 
  
*EMmsg = EMS_S_Success;
OM_stat = OM_S_SUCCESS;
sf_geom = NULL;
temp_lps = NULL;
adj_lps = NULL;
adj_lps_per_gr = NULL;
display_flag = EMS_WHL_EDGE;
p_lp_style = 0;
c_lp_style = 2;

accept_event->response = EX_RJT_MOVEON;
last_input = EX_DATA;
cur_entry = 0;
mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;

/*
 * get the surface geometry
 */

OM_stat = om$send (msg = message GRvg.GRgetsize (&mthd_stat,
                    &md_env->md_env.matrix_type,
                     md_env->md_env.matrix,
                    &sf_size),
                  senderid = NULL_OBJID,
                  targetid = sf_GRid.objid,
                  targetos = sf_GRid.osnum);
EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

sf_geom = (struct IGRbsp_surface *) om$malloc (size = sf_size);
EMerr_hndlr (!sf_geom, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

OM_stat = om$send (msg = message GRvg.GRgetgeom (&mthd_stat,
                    &md_env->md_env.matrix_type,
                     md_env->md_env.matrix,
                     (IGRchar *) sf_geom),
                   senderid = NULL_OBJID,
                   targetid = sf_GRid.objid,
                   targetos = sf_GRid.osnum);
EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError, wrapup); 

/*
 * get the element header to be used in display
 */

ele_spec_att.bsqsurf = &bsqsurf;
OM_stat = om$send (msg = message EMSsubbs.EMget_ele_header (&mthd_stat,
                    sf_geom, &md_env->md_env, NULL, &sf_ele_header, range,
                    &symb.display_attr, ele_spec_att, NULL), 
                   senderid = NULL_OBJID,
                   targetid = sf_GRid.objid, targetos = sf_GRid.osnum);
EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_OMerror,wrapup);

def_weight = sf_ele_header.dis_att->weight;

/*
 * Sort the ambiguous loops (lps_id) in the following order:
 * lp1, lp1_ad_lp1, lp1_ad_lp2, ...........,
 * lp2, lp2_ad_lp1, lp2_ad_lp2, ...........,
 * ........
 * .......
 */

temp_lps = (GRobjid *) om$malloc (size = num_lps * sizeof(GRobjid));
EMerr_hndlr (!temp_lps, *EMmsg,EMS_E_NoDynamicMemory, wrapup);

adj_lps_per_gr = (IGRint *) om$malloc (size = num_lps * sizeof(IGRint));
EMerr_hndlr (!adj_lps_per_gr, *EMmsg,EMS_E_NoDynamicMemory, wrapup);

adj_lps = (GRobjid *) om$malloc (size = num_lps * sizeof(GRobjid));
EMerr_hndlr (!adj_lps, *EMmsg,EMS_E_NoDynamicMemory, wrapup);

for (i = 0; i < num_lps -1 ; i++)
 temp_lps[i] = lps_id[i+1];

for (i = 0; i < num_lps; i++)
  adj_lps_per_gr[i] = 0;

num_lps_left = num_lps - 1;
cur_lp = lps_id[0];
lps_grp[0] = EMS_MKFACE_GROUP1;
adj_lp_gr = EMS_MKFACE_GROUP2;
num_gr = 0;
lps_id_inx = 1;
gr_lp_inx = 0;
cur_ad_lp = 0;

while (num_lps_left)
{

  OM_stat = om$send (msg = message EMSloop.EMgetAdjacentLoops (
                        &mthd_stat, temp_lps, &num_lps_left, adj_lps,
                        &num_adj_lps, EMLP_PLOOP, NULL),
                       senderid = NULL_OBJID,
                       targetid = cur_lp,
                       targetos = sf_GRid.osnum);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

  if (num_adj_lps)
  {
    
    for (i = 0; i < num_adj_lps; i++)
    {
     lps_id[lps_id_inx] = adj_lps[i];
     lps_grp[lps_id_inx++] = adj_lp_gr;   

     lp_found = FALSE;
     cur_entry = 0;
     do
     {
      if (IF_EQ_OBJID (temp_lps[cur_entry], adj_lps[i])) lp_found = TRUE;
      else cur_entry++;

     } while (cur_entry < num_lps_left && !lp_found);

     for (j = cur_entry; j < num_lps_left - 1; j++)     
      temp_lps[j] = temp_lps[j+1];
    
     num_lps_left--;

    } /* for (i = 0; i < num_adj_lps; i++) */

    adj_lps_per_gr[num_gr] += num_adj_lps;
    cur_ad_lp++;
    cur_lp = lps_id[gr_lp_inx + cur_ad_lp];
    adj_lp_gr = (lps_grp[gr_lp_inx + cur_ad_lp] == EMS_MKFACE_GROUP1) ?
                 EMS_MKFACE_GROUP2 : EMS_MKFACE_GROUP1;
    if (!num_lps_left) num_gr++;

  } /* if (num_adj_lps) */
  else
  { 
    if (cur_ad_lp + 1 <= adj_lps_per_gr[num_gr])
    {
      cur_ad_lp++;
      cur_lp = lps_id[gr_lp_inx + cur_ad_lp];
    }
    else
    {
      gr_lp_inx += adj_lps_per_gr[num_gr++] + 1;
      lps_id[gr_lp_inx] = cur_lp = temp_lps[0];
      lps_grp[gr_lp_inx] = EMS_MKFACE_GROUP1;
      adj_lp_gr = EMS_MKFACE_GROUP2;
      cur_ad_lp = 0;
      lps_id_inx++;
      num_lps_left--;
      if (num_lps_left)
        for (i = 0; i < num_lps_left; i++)
           temp_lps[i] = temp_lps[i+1];
      else num_gr++;
                  
    }
    
   } /* else for if (num_adj_lps) */

} /* while (num_lps_left) */

display_gr = EMS_MKFACE_GROUP1;

cur_gr = 0;
cur_inx = 0;

while ( cur_gr < num_gr &&  
        accept_event->response != GR_UNKNOWN_TYPE)
{
    if (!cur_gr)
     ex$message(msgnumb = EMS_P_AccTheGrpReject)
    else
     ex$message(msgnumb = EMS_P_AccAsAddToGrpReject)
  
    /*
     * Hilite the lps corresponding to EMS_MKFACE_GROUP1
     * of cur_gr.
     */
    
    display_mode = GRhd;
    sf_ele_header.dis_att->weight = 2;
    any_lp_displayed = FALSE;

    for (i = cur_inx; i < cur_inx + adj_lps_per_gr[cur_gr]+1; i++)
    {
      OM_stat = om$send (msg = message EMSloop.EMmkf_lp_display (
                        &mthd_stat, &sf_ele_header,
                        &md_env->md_env.matrix_type, 
                        md_env->md_env.matrix, &display_mode,
                        NULL, display_flag, EMLP_PLOOP,
                        lps_grp[i], lps_grp[i],
                        display_gr, p_lp_style, c_lp_style,
                        &any_lp_displayed), 
                      senderid = NULL_OBJID,
                      targetid = lps_id[i],
                      targetos = sf_GRid.osnum);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

    } /*for (i = cur_inx; i < cur_inx + adj_lps_per_gr[cur_gr]+1; i++)*/

    if (any_lp_displayed )
    {
/*
        status = GRgetevent (&mthd_stat, &mask, &size, accept_event, 
                           response, response_data);
*/
        status = co$getevent (
            msg = &mthd_stat,
            event_mask = mask,
            response = response,
            response_data = response_data,
            event = accept_event
        );

        EMerr_hndlr(!(1&mthd_stat&status),*EMmsg,EMS_E_Fail,wrapup);

        display_mode = GRhe;
        for (i = cur_inx; i < cur_inx + adj_lps_per_gr[cur_gr]+1; i++)
        {

          OM_stat = om$send (msg = message EMSloop.EMmkf_lp_display (
                        &mthd_stat, &sf_ele_header,
                        &md_env->md_env.matrix_type, 
                        md_env->md_env.matrix, &display_mode,
                        NULL, display_flag, EMLP_PLOOP,
                        lps_grp[i], lps_grp[i], display_gr,
                        p_lp_style, c_lp_style, &any_lp_displayed),
                      senderid = NULL_OBJID,
                      targetid = lps_id[i],
                      targetos = sf_GRid.osnum);
          EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

        } /*for (i=cur_inx; i < cur_inx + adj_lps_per_gr[cur_gr]+1; i++)*/

        switch (accept_event->response)
        {
          /*
           * If a data point is input, the caller has accepted
           * the highlighted portion of lps_GRid[cur_entry] to
           * be a part of EMS_MKFACE_GROUP1. Change the lps
           * weighted highlighted to normal highlight.
           */

          case EX_DATA:

            last_input = EX_DATA;
            display_mode = GRhd;
            sf_ele_header.dis_att->weight = def_weight;

            for (i = cur_inx; i < cur_inx + adj_lps_per_gr[cur_gr]+1; i++)
            {
              OM_stat = om$send (msg = message EMSloop.EMmkf_lp_display (
                        &mthd_stat, &sf_ele_header,
                        &md_env->md_env.matrix_type, 
                        md_env->md_env.matrix, &display_mode,
                        NULL, display_flag, EMLP_PLOOP,
                        lps_grp[i], lps_grp[i], display_gr,
                        p_lp_style, c_lp_style, &any_lp_displayed),
                      senderid = NULL_OBJID,
                      targetid = lps_id[i],
                      targetos = sf_GRid.osnum);
             EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

            }/*for(i=cur_inx;i < cur_inx + adj_lps_per_gr[cur_gr]+1;i++)*/

            cur_inx += adj_lps_per_gr[cur_gr++] + 1;
            break;

          /*
           * If a EX_RJT_MOVEON is input, the caller wants the
           * the complement of the highlighted portiion of 
           * lps_id[cur_entry] to be a part of EMS_MKFACE_GROUP1.
           */

          case EX_RJT_MOVEON:

           last_input = EX_RJT_MOVEON;
           for (i = cur_inx; i < cur_inx + adj_lps_per_gr[cur_gr]+1; i++)
           {
             lps_grp[i] = (lps_grp[i] == EMS_MKFACE_GROUP1) ?
                            EMS_MKFACE_GROUP2 : EMS_MKFACE_GROUP1;
           } /* for (i = cur_inx; i < cur_inx + adj_lps_per_gr[cur_gr]+1; 
                 i++ ) */

           break;

         /*
          * If the input is EX_BACK_UP, dehilite the current loop
          * under consideration, dehilite the last group and
          * decrement the num of loops that have been processed.
          */

         case EX_BACK_UP:

           last_input = EX_BACK_UP;
           if (cur_gr)
           {
             cur_gr--;
             cur_inx -= adj_lps_per_gr[cur_gr] + 1;
       
             display_mode = GRhe;
             sf_ele_header.dis_att->weight = def_weight;

             for (i=cur_inx; i < cur_inx + adj_lps_per_gr[cur_gr]+1; i++)
             {

               OM_stat = om$send (msg = message EMSloop.EMmkf_lp_display (
                        &mthd_stat, &sf_ele_header,
                        &md_env->md_env.matrix_type, 
                        md_env->md_env.matrix, &display_mode,
                        NULL, display_flag, EMLP_PLOOP,
                        lps_grp[i], lps_grp[i],
                        display_gr,
                        p_lp_style, c_lp_style, &any_lp_displayed),
                      senderid = NULL_OBJID,
                      targetid = lps_id[i],
                      targetos = sf_GRid.osnum);
               EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
             } /*for(i=cur_inx;i< cur_inx+ adj_lps_per_gr[cur_gr]+1;i++)*/

           } /* if (cur_gr) */
           else
           {
             goto wrapup;    /* user wants to one state back */
           }

           break;               

         case GR_UNKNOWN_TYPE:

            last_input = GR_UNKNOWN_TYPE;
            break;
    
        } /* switch (accept_event->response) */

    } /* if (any_lp_displayed ) */

    else
    {
      if (last_input == EX_RJT_MOVEON)
        cur_inx += adj_lps_per_gr[cur_gr++] + 1;

      else
      {
         for (i = cur_inx; i < cur_inx + adj_lps_per_gr[cur_gr]+1; i++)
         {
           lps_grp[i] = (lps_grp[i] == EMS_MKFACE_GROUP1) ?
                            EMS_MKFACE_GROUP2 : EMS_MKFACE_GROUP1;
         } /* for (i = cur_inx; i < cur_inx + adj_lps_per_gr[cur_gr]+1; 
                 i++ ) */

      } /* else for if (last_input == EX_RJT_MOVEON) */

    } /* else for if (any_lp_displayed ) */

} /* while ( cur_gr < num_gr &&  
             accept_event->response != GR_UNKNOWN_TYPE) */
    
wrapup:

 
/*
 * dehilite the loops
 */

display_mode = GRhe;
for (i = 0; i < cur_inx; i++)
{

   OM_stat = om$send (msg = message EMSloop.EMmkf_lp_display (
                        &mthd_stat, &sf_ele_header,
                        &md_env->md_env.matrix_type, 
                        md_env->md_env.matrix, &display_mode,
                        NULL, display_flag, EMLP_PLOOP,
                        lps_grp[i], lps_grp[i],
                        display_gr,
                        p_lp_style, p_lp_style, &any_lp_displayed),
                      senderid = NULL_OBJID,
                      targetid = lps_id[i],
                      targetos = sf_GRid.osnum);
   if (!(1&OM_stat&mthd_stat)) *EMmsg = EMS_E_LoopError;

} /* for (i = 0; i < cur_inx; i++) */

EMWRAPUP (*EMmsg, OM_stat, "In EFgrp_ambiguous_loops");

if (sf_geom) om$dealloc (ptr = sf_geom);
if (temp_lps) om$dealloc (ptr = temp_lps);
if (adj_lps) om$dealloc (ptr = adj_lps);
if (adj_lps_per_gr) om$dealloc (ptr = adj_lps_per_gr);

return( OM_stat );

}

end implementation Root;

