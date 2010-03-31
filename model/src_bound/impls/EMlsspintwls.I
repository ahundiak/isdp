/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMS.h"
#include <stdio.h>
#include "EMSopt.h"
#include "EMSbnddef.h"
#include "EMSlmdef.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "emsimpdef.h"  /* options for EMsplityourself */

from EMSloop    import  EMgetAdjacentLoops, EMgroup_loops;
from EMSloop    import  EMget_props, EMgivenestinfo, EMtreemod, 
                        EMtoggle_type;
from EMSedge    import  EMendpts, EMptatpr, EMget_props;

extern OMuword OPP_EMSloopset_class_id,
               OPP_EMSgraloop_class_id;



/*
 * The following function is only for internal use of 
 * this file
 */

static IGRboolean loop_in_area_or_hole(
                EMmsg,
                adj_table,
                num_in_lps,
                lp_id,
                ls_id,
                partolbasis,
                lp_ed_chan,
                com_ed_chan,
                lp_loc_decided,
                lp_location)

IGRlong                 *EMmsg;
GRobjid                 *adj_table;
IGRint                  num_in_lps;
GRobjid                 lp_id, ls_id;
struct EMSpartolbasis   *partolbasis;
OM_S_CHANSELECT         lp_ed_chan, com_ed_chan;
IGRboolean              *lp_loc_decided;
IGRshort                *lp_location;
{
  struct  EMSedgebound  ed_beg_param, ed_end_param, ed_pr_to_test;

  struct  EMSptloc_info ptloc_info;  

  IGRlong               OM_stat, mthd_stat;

  IGRint                cur_lp, sts, j;

  OMuint                num_edges;

  GRobjid               ed_id, com_ed_id, com_ed_lp_id;

  IGRdouble             ed_pr, pt_to_test[2];

  IGRushort     ed_props;

  IGRboolean            same_srf_lp;

  *EMmsg = EMS_S_Success;
  *lp_loc_decided = FALSE;

  OM_stat = om$get_channel_count (osnum = OM_Gw_current_OS,
                    objid = lp_id, p_chanselect = &lp_ed_chan,
                    count = &num_edges);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  j = 0;
  do
  {

     OM_stat = om$send (msg = message EMSedge.EMget_props(
                         &mthd_stat, &ed_props),
                        senderid = lp_id, p_chanselect = &lp_ed_chan,
                        from = j, to = j);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

     if (!(ed_props & EMED_NATURAL))
     {
        OM_stat = om$send (msg=message EMSboundary.EMget_objid(
                            &mthd_stat, &ed_id),
                           senderid = lp_id, p_chanselect = &lp_ed_chan,
                           from = j, to = j);
       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError, wrapup);

       com_ed_id = NULL_OBJID;
       OM_stat = om$send (msg=message EMSboundary.EMget_objid(
                           &mthd_stat, &com_ed_id),
                          senderid = ed_id, p_chanselect = &com_ed_chan);
       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError, wrapup);

       if (com_ed_id != NULL_OBJID)
       {
         sts = EMsend_loops(&mthd_stat, message EMSboundary.EMget_objid(
                              &mthd_stat, &com_ed_lp_id),
                            com_ed_id, NULL, OM_K_MAXINT, EMLP_ACTIVE,
                            NULL, NULL);
         EMerr_hndlr(!(1&sts&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
       }
 
       /*
        * find out if the com edge loop is part of the
        * same surface, do not consider this edge as this
        * edge may be generated due to the imposed boundaries.
        */

       cur_lp = 0;
       same_srf_lp = FALSE;
       do
       {
          if (com_ed_lp_id == adj_table[cur_lp * num_in_lps])
             same_srf_lp = TRUE;
          cur_lp++;
       } while (cur_lp < num_in_lps && !same_srf_lp);

       if (!same_srf_lp)
       {
          OM_stat = om$send (msg = message EMSedge.EMendpts(
                              &mthd_stat, NULL, NULL,
                              &ed_beg_param, &ed_end_param, NULL),
                             senderid = NULL_OBJID, targetid = ed_id);
          EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

          ed_pr  = (ed_beg_param.param + ed_beg_param.span_inx +
                     ed_end_param.param + ed_end_param.span_inx);

          ed_pr_to_test.span_inx = ed_pr / 2;
          ed_pr_to_test.param = ed_pr/2 - ed_pr_to_test.span_inx;

          OM_stat = om$send (msg = message EMSedge.EMptatpr( &mthd_stat, 
                              1, &ed_pr_to_test, NULL, pt_to_test),
                             senderid = NULL_OBJID, targetid = ed_id);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

          ptloc_info.options=EMS_PTLOC_BOXCHECK | EMS_PTLOC_ACTLOOP;

          OM_stat = om$send (msg = message EMSloopset.EMpt_location( 
                              &mthd_stat, pt_to_test, &ptloc_info, 
                              partolbasis),
                             senderid = NULL_OBJID, targetid = ls_id);
          EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_LoopsetError,wrapup);

          if ( (ptloc_info.location == EMS_L_INHOLE)||
                           (ptloc_info.location == EMS_L_INAREA))
          {
             *lp_location = ptloc_info.location;
             *lp_loc_decided = TRUE;
          }

       } /* if (!same_srf_lp) */

     } /* if (!(ed_props & EMED_NATURAL)) */

     j++;

   } while (j < num_edges && !(*lp_loc_decided));

wrapup:

   return(1);

} /* end loop_in_area_or_hole */

/*
 * The following function is only for internal use of this
 * file
 */

static IGRboolean sort_loops (
     EMmsg,
     adj_table,
     adj_lps_per_lp,
     num_in_lps,
     entry_used,
     num_entries_used,
     temp_gr1,
     temp_gr1_entries,
     temp_gr2,
     temp_gr2_entries,
     out_gr1_lps,
     num_out_gr1_lps,
     out_gr2_lps,
     num_out_gr2_lps)

  IGRlong       *EMmsg;
  GRobjid       *adj_table;
  IGRint        *adj_lps_per_lp;
  IGRint        num_in_lps;
  IGRboolean    *entry_used;
  IGRint        *num_entries_used;
  GRobjid       *temp_gr1;
  IGRint        temp_gr1_entries;
  GRobjid       *temp_gr2;
  IGRint        temp_gr2_entries;
  GRobjid       *out_gr1_lps;
  IGRint        *num_out_gr1_lps;
  GRobjid       *out_gr2_lps;
  IGRint        *num_out_gr2_lps;

 {

  GRobjid       gr1_lp, gr2_lp;

  IGRint        cur_entry, gr1_adj_table_entry, gr2_adj_table_entry, i,
                temp_gr1_ptr, temp_gr2_ptr;
  
  IGRboolean    entry_exists, entry_found; 

  *EMmsg = EMS_S_Success;

  do
  {
      if (temp_gr2_entries && (*num_entries_used < num_in_lps))
      {

       do
       {
          /*
           * find out the entry in the adjacent table
           * that matches the temp_gr2 entry.
           */

          cur_entry = 0;
          entry_found = FALSE;   
          temp_gr2_ptr = 0;

          do
          {
            if (temp_gr2[temp_gr2_ptr] == 
                         adj_table[cur_entry * num_in_lps])
               entry_found = TRUE;

            cur_entry++;

           } while ((cur_entry < num_in_lps) && !entry_found);

           if (!entry_found)
           {
              *EMmsg = EMS_E_Fail;
              goto wrapup;
           }

           gr2_adj_table_entry = cur_entry - 1;

           /*
            * this entry is not yet used. check if its
            * adjacent loops are already in out_gr1_lps array.
            * If not put them in the out_gr1_lps and increment
            * num_out_gr1_lps appropriately. Also, if the 
            * adjacent loop is not in the out_gr1_lps, add it 
            * to temp_gr1 array and increment temp_gr1_entries
            * appropriately.
            */

          for (i = 1; i <= adj_lps_per_lp[gr2_adj_table_entry]; i++)
          {
             gr1_lp = adj_table[gr2_adj_table_entry * num_in_lps + i];

             cur_entry = 0;
             entry_found = FALSE;   

             do
             {
                 if (gr1_lp == adj_table[cur_entry * num_in_lps])
                     entry_found = TRUE;
                 cur_entry++;

             } while ((cur_entry < num_in_lps) && !entry_found);

            if (!entry_found)
            {
                *EMmsg = EMS_E_Fail;
                goto wrapup;
            }

            gr1_adj_table_entry = cur_entry - 1;

            if (!entry_used[gr1_adj_table_entry])
            {
              cur_entry = 0;
              entry_exists = FALSE;

              do
              {
                if (out_gr1_lps[cur_entry] == gr1_lp) entry_exists = TRUE;
                cur_entry++;

              } while ((cur_entry < *num_out_gr1_lps) && !entry_exists);

              if (!entry_exists)
              {
                 out_gr1_lps[(*num_out_gr1_lps)++] = gr1_lp;
                 temp_gr1[temp_gr1_entries++] = gr1_lp;
              }

            } /* if (!entry_used[gr1_adj_table_entry]) */

              } /* for (i = 0; i < adj_lps_per_lp[gr2_adj_table_entry];
                   i++) */

             temp_gr2_ptr++;
             entry_used[gr2_adj_table_entry] = TRUE;
             (*num_entries_used)++;

        } while (temp_gr2_ptr < temp_gr2_entries && 
                 (*num_entries_used < num_in_lps) );

      } /* if (temp_gr2_entries && (*num_entries_used < num_in_lps) */

      temp_gr2_entries = 0;

      if (temp_gr1_entries && (*num_entries_used < num_in_lps))
      {
       do
       {
           /*
            * find out the entry in the adjacent table
            * that matches the temp_gr1 entry.
            */

           temp_gr1_ptr = 0;
           cur_entry = 0;
           entry_found = FALSE;   
           do
           {
             if (temp_gr1[temp_gr1_ptr] == 
                        adj_table[cur_entry * num_in_lps])
                 entry_found = TRUE;

             cur_entry++;

           } while ((cur_entry < num_in_lps) && !entry_found);

           if (!entry_found)
           {
                *EMmsg = EMS_E_Fail;
                goto wrapup;
           }

           gr1_adj_table_entry = cur_entry - 1;

           /*
            * this entry is not yet used. check if its
            * adjacent loops are already in out_gr2_lps array.
            * If not put them in the out_gr2_lps and increment
            * num_out_gr2_lps appropriately. Also, if the 
            * adjacent loop is not in the out_gr2_lps, add it 
            * to temp_gr2 array and increment temp_gr2_entries
            * appropriately.
            * 
            */

            for (i = 1; i <= adj_lps_per_lp[gr1_adj_table_entry]; i++)
            {
                gr2_lp = adj_table[gr1_adj_table_entry * num_in_lps + i];

                cur_entry = 0;
                entry_found = FALSE;   
               do
               {
                 if (gr2_lp == adj_table[cur_entry * num_in_lps])
                    entry_found = TRUE;
                 cur_entry++;

               } while ((cur_entry < num_in_lps) && !entry_found);

               if (!entry_found)
               {
                  *EMmsg = EMS_E_Fail;
                  goto wrapup;
               }

               gr2_adj_table_entry = cur_entry - 1;
        
               if (!entry_used[gr2_adj_table_entry])
               {

                cur_entry = 0;
                entry_exists = FALSE;

                do
                {
                   if (out_gr2_lps[cur_entry] == gr2_lp)
                        entry_exists = TRUE;
                   cur_entry++;

                }while ((cur_entry < *num_out_gr2_lps) && !entry_exists);
                
                if (!entry_exists)
                {
                   out_gr2_lps[(*num_out_gr2_lps)++] = gr2_lp;
                   temp_gr2[temp_gr2_entries++] = gr2_lp;
                }

               } /* if (!entry_used[gr2_adj_table_entry]) */

          } /*for (i =1; i <= adj_lps_per_lp[gr2_adj_table_entry]; i++) */

          temp_gr1_ptr++;
          entry_used[gr1_adj_table_entry] = TRUE;
          (*num_entries_used)++;

        } while (temp_gr1_ptr < temp_gr1_entries && 
                (*num_entries_used < num_in_lps) );

      } /* if (temp_gr1_entries && (*num_entries_used < num_in_lps)) */

      temp_gr1_entries = 0;

} while ((temp_gr1_entries || temp_gr2_entries) && 
         (*num_entries_used < num_in_lps) );

wrapup:
   
      return(1);

}  /* end sort_loops function */


/*
 * This function is only for internal use of this file
 */

static IGRboolean group_loops (
    EMmsg,
    num_imp_lps,
    imp_lp_ids,
    adj_table,
    num_in_lps,
    adj_lps_per_lp,
    partolbasis,
    env,
    out_gr1_lps,
    num_out_gr1_lps,
    out_gr2_lps,
    num_out_gr2_lps,
    amb_lps,
    num_amb_lps)

IGRlong                 *EMmsg;
IGRint                  num_imp_lps;
GRobjid                 *imp_lp_ids;
GRobjid                 *adj_table;
IGRint                  num_in_lps;
IGRint                  *adj_lps_per_lp;
struct EMSpartolbasis   *partolbasis;
struct GRmd_env         *env;
GRobjid                 **out_gr1_lps;
IGRint                  *num_out_gr1_lps;
GRobjid                 **out_gr2_lps;
IGRint                  *num_out_gr2_lps;
GRobjid                 **amb_lps;
IGRint                  *num_amb_lps;
{
GRobjid         *temp_gr1, *temp_gr2, nat_ls, *open_lps, *closed_lps;

IGRlong         mthd_stat, OM_stat;

IGRint          adj_table_ptr, cur_entry, i, j, num_entries_used,
                temp_gr1_entries = 0, temp_gr2_entries = 0;
IGRboolean      *entry_used, status, 
                start_pt_found = FALSE;
IGRushort togtype_options = NULL;

*EMmsg = EMS_S_Success;

*num_out_gr1_lps = 0;
*num_out_gr2_lps = 0;
*num_amb_lps = 0;

*amb_lps = NULL;
open_lps = NULL;
closed_lps = NULL;
nat_ls = NULL_OBJID;
*out_gr1_lps = NULL;
*out_gr2_lps = NULL;
temp_gr1 = NULL;
temp_gr2 = NULL;
entry_used = NULL;


/*
 * Use the incoming adj_table to divide the lps ino two grpups.
 */

/*
 * allocate memory for group1 (out_gr1_lps) and 
 * group2 (out_gr2_lps). The maximum number of
 * loops either of these groups can hold is 
 * num_in_lps.
 */

*out_gr1_lps = (GRobjid *) om$malloc (size = ( num_in_lps *
                                             sizeof (GRobjid)));
EMerr_hndlr (!(*out_gr1_lps),*EMmsg,EMS_E_NoDynamicMemory,wrapup);

*out_gr2_lps = (GRobjid *) om$malloc (size = ( num_in_lps *
                                               sizeof (GRobjid)));
EMerr_hndlr (!(*out_gr2_lps),*EMmsg,EMS_E_NoDynamicMemory,wrapup);

/*
 * performing sort 
 */

temp_gr1 = (GRobjid *) om$malloc (size = (num_in_lps *
                                          sizeof(GRobjid)));
EMerr_hndlr (!temp_gr1,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
  
temp_gr2 = (GRobjid *) om$malloc (size = (num_in_lps *
                                          sizeof(GRobjid)));
EMerr_hndlr (!temp_gr2,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

entry_used = (IGRboolean *) om$malloc (size = (num_in_lps *
                                       sizeof (IGRboolean)));
EMerr_hndlr (!entry_used,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

for (i = 0; i < num_in_lps; i++)
      entry_used[i] = FALSE;
 
num_entries_used = 0;
i = 0;

do
{
    adj_table_ptr = i * num_in_lps;

    if ( adj_lps_per_lp[i] )
    {

       (*out_gr1_lps)[0] = adj_table[adj_table_ptr++];
       (*num_out_gr1_lps)++;

       for (j = 0; j < adj_lps_per_lp[i]; j++)
       {
           temp_gr2[j] = adj_table[adj_table_ptr];
           (*out_gr2_lps)[j] = adj_table[adj_table_ptr++];
       }

       (*num_out_gr2_lps) = adj_lps_per_lp[i];
       temp_gr2_entries = adj_lps_per_lp[i];
       start_pt_found = TRUE;
       entry_used[i] = TRUE;
       num_entries_used++;

    } /* if ( adj_lps_per_lp[i] ) */

    i++;
  
} while ( (i < num_in_lps) && (!start_pt_found) );

if (start_pt_found)
{
 status =  sort_loops (EMmsg, adj_table, adj_lps_per_lp, num_in_lps,
             entry_used, &num_entries_used, temp_gr1, temp_gr1_entries,
             temp_gr2, temp_gr2_entries, *out_gr1_lps, num_out_gr1_lps,
             *out_gr2_lps, num_out_gr2_lps);

 EMerr_hndlr ((!status || !(1&*EMmsg)),*EMmsg,EMS_E_Fail,wrapup);
}

/*
 * if the num_entries_used is less than num_in_lps,
 * there are some ambigous loops. Extract these
 * ambiguous loops and return them.
 */

if (num_entries_used < num_in_lps)
{
    /*
     * If there are any ambiguous loops, 
     * The following geomtric testing
     * has to be performed:
     *
     * 1. construct a natural loopset.
     * 2. split the natural loopset  with the loops
     *    used for imposition.
     * 3. Toggle the split regions into areas/holes.
     *
     * 4. Pick a loop in group1 and decide whether it is in
     *    the solid area or hole. Based on this result,
     *    label gr1 and gr2 as solid/hole regions.
     *
     * 5. Pick an ambiguous loop and perform a pt location
     *    on it using the loopset just split. Based on the
     *    results of whether it is in the solid or hole,
     *    put it in the appropriate group.
     * 6. Repeat step 5 for all of the ambiguous loops.
     */

     struct EMSnest_info        nesting;

     OM_S_CHANSELECT            com_ed_chan, lp_ed_chan, ls_lp_chan;

     GRobjid                    amb_lp_id, *gr_lps, nat_ls_lp;
     OMuword                    dum_os;
     
     IGRint                     adj_table_ptr, cur_gr, num_gr_lps, 
                                num_open_lps, num_closed_lps;
     
     IGRshort                   lp_location, GROUP1_LOC = 0, GROUP2_LOC;

     IGRushort          amb_lp_gr = 0, lp_props, split_options;

     IGRboolean 		gr_type_decided,
                                lp_loc_decided, amb_lp_found;


     OM_stat = om$construct (classid = OPP_EMSloopset_class_id,
                             p_objid = &nat_ls);
     EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

     OM_stat = om$send(msg = message EMSloopset.EMmake_natural_loopset(
                        &mthd_stat, NULL, NULL, NULL),
                       senderid = NULL_OBJID, targetid = nat_ls);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

     /*
      * If a loopset splityourself method is invoked
      * with  closed loops as boundaries, it will
      * create dummy c-loops enclosing these closed
      * loops. Since, in this case these split areas have
      * to be toggled, the creation of these dummy c-loops will
      * have to deleted and thus creation and deletion
      * of these dummy c-loops is unnecessary overhead.
      *
      * On the other hand, if a loopset impose boundary
      * method is invoked, the external c-loop will be
      * deleted. In this case these external c-loops
      * are needed for geometric testing.
      *
      * As a result of the above explaination, the following 
      * processing is done along with invoking loopset 
      * splityourself method.
      *
      * 1. collect all of the open loops among the loops to
      *    be imposed. 
      * 2. split the loopset with the open loops.
      * 3. nest the closed loops in the split loopset.
      * 4. Toggle the loops.
      */

      OM_stat = EMmake_chanselect (EMSloopset_to_loops, &ls_lp_chan);
      EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

      OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &lp_ed_chan);
      EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

      OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &com_ed_chan);
      EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

      open_lps = (GRobjid *) om$malloc (size = num_imp_lps *
                                               sizeof(GRobjid));
      EMerr_hndlr(!open_lps,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

      closed_lps = (GRobjid *) om$malloc (size = num_imp_lps *
                                                 sizeof(GRobjid));
      EMerr_hndlr(!closed_lps,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
 
      num_open_lps = 0;
      num_closed_lps = 0;

      for (i = 0; i < num_imp_lps; i++)
      {
        OM_stat = om$send(msg = message EMSloop.EMget_props(
                           &mthd_stat, &lp_props),
                          senderid = NULL_OBJID, targetid =imp_lp_ids[i]);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

        if(lp_props &EMLP_OPEN)open_lps[num_open_lps++]=imp_lp_ids[i];
        else closed_lps[num_closed_lps++] = imp_lp_ids[i];
      }

      if(num_open_lps)
      {
         split_options = EMImpBnd_CloseRegular | EMImpBnd_CloseReverse |
                         EMImpBnd_NoDummyEdges;

         OM_stat = om$send(msg = message EMSloopset.EMsplityourself(
                             &mthd_stat, open_lps, num_open_lps, NULL,
                              NULL, NULL, NULL, NULL, split_options, 
                              NULL, NULL, partolbasis, env),
                            senderid = NULL_OBJID, targetid = nat_ls);
         /*
          * If the return code is EMS_E_IntersectTrim, the loop
          * under consideration is not intersecting the loopset
          * and thus needs some more information to resolve its
          * ambiguity.
          */

         if (mthd_stat == EMS_E_IntersectTrim)
         {
            OM_S_CHANSELECT to_outter;

            OM_stat = EMmake_chanselect (EMSloop_to_outter, &to_outter);
            EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

           /*
            * collect the ambiguous loops
            */

           *num_amb_lps = num_in_lps;
           *amb_lps = (GRobjid *) om$malloc (size = num_in_lps * 
                       sizeof(GRobjid));
           EMerr_hndlr (!(*amb_lps), *EMmsg,EMS_E_NoDynamicMemory,wrapup);
          
           for (cur_entry = 0; cur_entry < num_in_lps; cur_entry++)
           {
              (*amb_lps)[cur_entry] = adj_table[cur_entry * num_in_lps];

              OM_stat = om$send (msg = message Root.wild_disconnect (
                                  to_outter),
                                 senderid = NULL_OBJID,
                                 targetid = (*amb_lps)[cur_entry]);
              EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

           } /*for (cur_entry = 0; cur_entry < num_in_lps; cur_entry++)*/

           mthd_stat = EMS_S_Success;
           goto wrapup;
         }

         EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);
      }

      for(i = 0;i < num_closed_lps; i++)
      {
        OM_stat = om$send(msg = message EMSloop.EMgivenestinfo(
                           &mthd_stat, &nesting),
                          senderid = NULL_OBJID, targetid=closed_lps[i]);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_NestError,wrapup);

        OM_stat = om$send(msg=message EMSloopset.EMnesting (&mthd_stat, 
                           &nesting, partolbasis),
                          senderid = NULL_OBJID, targetid = nat_ls);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_NestError,wrapup);

        if(IF_EQ_OBJID(nat_ls,nesting.parent))

          OM_stat = om$send(msg = message EMSloopset.EMtreemod(&mthd_stat,
                             &nesting, ADD_CHILD, partolbasis),
                            senderid = NULL_OBJID, targetid = nat_ls);
        else
          OM_stat = om$send(msg = message EMSloop.EMtreemod (&mthd_stat, 
                             &nesting, ADD_CHILD, partolbasis),
                            senderid = NULL_OBJID, 
                            targetid = nesting.parent);

        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_TreeModError,wrapup);
     
      } /* for(i = 0;i < num_closed_lps; i++) */

      OM_stat = om$get_objid_at_index (osnum = OM_Gw_current_OS,
                   objid = nat_ls, p_chanselect = &ls_lp_chan,
                   index = 0, objidaddr = &nat_ls_lp, osnumaddr =&dum_os);
      EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror,wrapup);

      togtype_options = EMTogType_SendInner | EMTogType_SendOuter
			| EMTogType_SendAdjacent;
			
      OM_stat = om$send (msg = message EMSloop.EMtoggle_type(
                          &mthd_stat, TRUE, FALSE, nat_ls_lp, togtype_options, 
			  NULL, NULL, NULL, NULL, NULL, NULL),
                         senderid = nat_ls_lp, targetid = nat_ls_lp);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

      /*
       * name out_gr1_lps and out_gr2_lps as solid/hole regions
       * appropriately.
       */

      if (*num_out_gr1_lps || *num_out_gr2_lps)
      {
        gr_type_decided= FALSE;
        cur_gr = 0;

        do
        {
          num_gr_lps = cur_gr ? (*num_out_gr2_lps) : (*num_out_gr1_lps);
          gr_lps = cur_gr ? (*out_gr2_lps) : (*out_gr1_lps);

          if (num_gr_lps)
          {
            i = 0;

            do
            {
              status =  loop_in_area_or_hole(EMmsg, adj_table, 
                          num_in_lps, gr_lps[i], nat_ls, partolbasis, 
                          lp_ed_chan,  com_ed_chan, &lp_loc_decided, 
                         &lp_location);
              EMerr_hndlr((!status || !(1&OM_stat)),*EMmsg,EMS_E_Fail,wrapup);

              if (lp_loc_decided)
              {
                 if (lp_location == EMS_L_INAREA)
                 {
                   GROUP1_LOC = cur_gr ? EMS_L_INHOLE : EMS_L_INAREA;
                   GROUP2_LOC = cur_gr ? EMS_L_INAREA : EMS_L_INHOLE;
                   gr_type_decided = TRUE;
                 }
                 else
                 if (lp_location == EMS_L_INHOLE)
                 {
                    GROUP1_LOC = cur_gr ? EMS_L_INAREA : EMS_L_INHOLE;
                    GROUP2_LOC = cur_gr ? EMS_L_INHOLE : EMS_L_INAREA;
                    gr_type_decided = TRUE;
                 }

              } /* if (lp_loc_decided) */

              i++;

            } while ( i < num_gr_lps && !gr_type_decided);

          } /* if (num_gr_lps) */

          cur_gr++;

        } while (cur_gr < 2 && !gr_type_decided);

/* If the group type cannot be decided, consider it as ambiguous case */
        if (!gr_type_decided)
        {
          OM_S_CHANSELECT to_outter;

           OM_stat = EMmake_chanselect (EMSloop_to_outter, &to_outter);
           EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

           *num_amb_lps = num_in_lps;
           *amb_lps = (GRobjid *) om$malloc (size = num_in_lps *
                       sizeof(GRobjid));
           EMerr_hndlr (!(*amb_lps), *EMmsg,EMS_E_NoDynamicMemory,wrapup);

           for (cur_entry = 0; cur_entry < num_in_lps; cur_entry++)
           {
              (*amb_lps)[cur_entry] = adj_table[cur_entry * num_in_lps];

              OM_stat = om$send (msg = message Root.wild_disconnect (
                                  to_outter),
                                 senderid = NULL_OBJID,
                                 targetid = (*amb_lps)[cur_entry]);
              EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

           } /*for (cur_entry = 0; cur_entry < num_in_lps; cur_entry++)*/
 /* Commented    -Inasu               
  *         *EMmsg = EMS_E_Fail;
  *         fprintf (stderr,"Unable to decide group types(hole/area)\n");
  */
           goto wrapup;
        }

      } /* if (*num_out_gr1_lps || *num_out_gr2_lps) */
      else
      {
          GROUP1_LOC = EMS_L_INAREA;
          GROUP2_LOC = EMS_L_INHOLE;
      }

        cur_entry = 0;
        do
        {
          amb_lp_found = FALSE;
          amb_lp_id = NULL_OBJID;
          do
          {
            if (!entry_used[cur_entry]) 
            {
              amb_lp_id = adj_table[cur_entry * num_in_lps];
              amb_lp_found = TRUE;
            }
            else cur_entry++;

          } while (cur_entry < num_in_lps && !amb_lp_found);

          if (IF_NULL_OBJID(amb_lp_id))
          {
            *EMmsg = EMS_E_Fail;
            fprintf (stderr,"ambiguous loop not found, EMlsspintwls\n");
            goto wrapup;
          }

          status =  loop_in_area_or_hole(EMmsg, adj_table, num_in_lps, 
                      amb_lp_id, nat_ls, partolbasis, lp_ed_chan, 
                      com_ed_chan, &lp_loc_decided,  &lp_location);
          EMerr_hndlr((!status || !(1&OM_stat)),*EMmsg,EMS_E_Fail,wrapup);

          if (lp_loc_decided)
          {
            if (lp_location == EMS_L_INHOLE)
            {
               if (GROUP1_LOC == EMS_L_INHOLE)
                   amb_lp_gr = EMS_MKFACE_GROUP1;
               else
                   amb_lp_gr = EMS_MKFACE_GROUP2;
            }
            else   /* lp_location == EMS_L_INAREA */
            {
               if (GROUP1_LOC == EMS_L_INAREA)
                   amb_lp_gr = EMS_MKFACE_GROUP1;
               else
                   amb_lp_gr = EMS_MKFACE_GROUP2;
            }

          } /* if (lp_loc_decided) */

          temp_gr1_entries = temp_gr2_entries = 0;

          if (amb_lp_gr == EMS_MKFACE_GROUP1)
          {
             (*out_gr1_lps)[(*num_out_gr1_lps)++] = amb_lp_id;

             if (adj_lps_per_lp[cur_entry])
             {
                adj_table_ptr = cur_entry * num_in_lps + 1;
                for (j = 0; j < adj_lps_per_lp[cur_entry]; j++)
                {
                   temp_gr2[j] = adj_table[adj_table_ptr];
                   (*out_gr2_lps)[(*num_out_gr2_lps)++] = 
                                  adj_table[adj_table_ptr++];
                }

                temp_gr2_entries = adj_lps_per_lp[cur_entry];
             }
          }
          else
          {
             (*out_gr2_lps)[(*num_out_gr2_lps)++] = amb_lp_id;

             if (adj_lps_per_lp[cur_entry])
             {
                adj_table_ptr = cur_entry * num_in_lps + 1;
                for (j = 0; j < adj_lps_per_lp[cur_entry]; j++)
                {
                  temp_gr1[j] = adj_table[adj_table_ptr];
                  (*out_gr1_lps)[(*num_out_gr1_lps)++] = 
                             adj_table[adj_table_ptr++];
                }

                temp_gr1_entries = adj_lps_per_lp[cur_entry];
             }
          }
 
          entry_used[cur_entry] = TRUE;
          num_entries_used++;

          if (temp_gr1_entries || temp_gr2_entries)
          {
            status =  sort_loops (EMmsg, adj_table, adj_lps_per_lp, 
                         num_in_lps, entry_used, &num_entries_used, 
                         temp_gr1, temp_gr1_entries, temp_gr2, 
                         temp_gr2_entries, *out_gr1_lps, num_out_gr1_lps,
                         *out_gr2_lps, num_out_gr2_lps);
            EMerr_hndlr(!status || !(1&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);
          }

          cur_entry++;

    } while (num_entries_used < num_in_lps && cur_entry < num_in_lps);

    if (num_entries_used < num_in_lps)
    {
        *EMmsg = EMS_E_Fail;
        fprintf (stderr, "could not sort ambiguous loops \n");
        goto wrapup;
    }

} /* if (num_entries_used < num_in_lps) */

wrapup:

/*
 * delete the working loopset, if there is one.
 */

if (!IF_NULL_OBJID(nat_ls))
{
  OM_stat = om$send (msg = message Root.delete(1),
                       senderid = NULL_OBJID, targetid = nat_ls);
  if (!(1&OM_stat)) *EMmsg = EMS_E_LoopsetError;

} /* if (!IF_NULL_OBJID(nat_ls)) */

if (open_lps) om$dealloc (ptr = open_lps);
if (closed_lps) om$dealloc (ptr = closed_lps);

if (temp_gr1) om$dealloc (ptr = temp_gr1);
if (temp_gr2) om$dealloc (ptr = temp_gr2);
if (entry_used) om$dealloc (ptr = entry_used);

return (1);

}  
/* end group_loops function */

method EMsplit_into_two_ls (
        IGRlong                 *EMmsg;
        IGRint                  num_imp_lps;
        GRobjid                 *imp_lp_ids;
        struct GRmd_env         *env;
        struct EMSpartolbasis   *partolbasis;
        GRobjid                 *gr1_ls_id;
        GRobjid                 *gr2_ls_id;
        GRobjid                 **amb_lps;
        IGRint                  *num_amb_lps)

/*

 Notes
        This method is currently used by MAKE FACE
        operation. It is not clear if this functionality
        can be used any where else.

History

            RC  05/10/87   Creation Date
            RC  11/03/87   Modified for version 1.1.0
            RC  11/10/87   Modified arguments to EMmake_natural_loopset.
            SM  13-Dec-88  Argument change for EMSloop.EMtoggle_type.
09 Sep 1988 jBk Changed name of message EMget_adjacent_loops to
                EMgetAdjacentLoops.  Added appropriate values for
                new mustHaveProps and mustNotHaveProps arguments
                of message EMgetAdjacentLoops.
             RC 02/22/90   Added code to handle graphic loops
          Inasu 07/27/90   Fixed TR 90n2034.
                           Consider this case as ambiguous and set the return
                           code for more information from the user.
*/

{
  IGRlong               mthd_stat, OM_stat, sender_lp_type, sender_lp_gr;

  IGRint                *adj_lps_per_lp, adj_table_ptr,i,
                        num_gr1_lps, num_gr2_lps;
  OMuint                num_lps, chan_count;

  GRobjid               *adj_table, gr1_lp_to_connect, *gr1_lps,
                        gr2_lp_to_connect, *gr2_lps, *lp_ids, 
                        *lps_of_group1, *lps_of_group2;
 
  OM_S_CHANSELECT       ls_lp_chan, to_inner, to_outter;

  OM_S_OBJECT_LINKAGE   lp_id;

  IGRboolean            group_loops(), status;

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;
  mthd_stat = EMS_S_Success;

  *gr1_ls_id = my_id;

  adj_lps_per_lp = NULL;
  adj_table = NULL;
  gr1_lps = NULL;
  gr2_lps = NULL;  
  lp_ids = NULL;
  lps_of_group1 = NULL;
  lps_of_group2 = NULL;
  
  OM_stat = EMmake_chanselect (EMSloopset_to_loops, &ls_lp_chan);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  /*
   * find out how many loops, does the loopset has ?
   */

  OM_stat = om$get_channel_count (object = me,
                                  p_chanselect = &ls_lp_chan,
                                  count = &num_lps);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  /*
   * if I have only one child loop, then ther is no 
   * adjancency needed.
   */

  if (num_lps == 1)
  {
     /*
      * get the child loop
      */

     OM_stat = om$get_channel_objects (object = me,
                                       p_chanselect = &ls_lp_chan,
                                       list = &lp_id,
                                       size = 1,
                                       count = &chan_count);
     EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
     EMerr_hndlr ((chan_count != 1),*EMmsg,EMS_E_ChanCountNot1,wrapup);

     gr1_lps = &lp_id.S_objid;
     num_gr1_lps = 1;
     num_gr2_lps = 0;
  }
  else
  {
    IGRint   num_reg_lps;
    OMuword  lp_classid;

     /*
      * I have more than one loop as my childern. 
      * Therefore, it is needed to divide them
      * into two groups.
      * 
      * It may be possible that I own only one regular loop and the
      * rest of them are graphic loops. In such a case, no grouping
      * is needed.
      */

     lp_ids = (GRobjid *) om$malloc (size = num_lps *
                                            sizeof(GRobjid));
     EMerr_hndlr(!lp_ids,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

     num_reg_lps = 0;

     for (i = 0; i < num_lps; i++)
     {
       OM_stat = om$send (msg=message EMSboundary.EMget_objid(
                           &mthd_stat, &lp_ids[num_reg_lps]),
                          p_chanselect = &ls_lp_chan, from = i, to = i);
       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

       OM_stat = om$get_classid (osnum = OM_Gw_current_OS,
                    objid = lp_ids[num_reg_lps],
                    p_classid = &lp_classid);
       EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

       OM_stat = om$is_ancestry_valid (subclassid = lp_classid,
                    superclassid = OPP_EMSgraloop_class_id);
       EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

       if (OM_stat != OM_S_SUCCESS)
        num_reg_lps++;
     }
    
     if (num_reg_lps > 1)
     {
      adj_table = (GRobjid *) om$malloc (size = (num_reg_lps * 
                     num_reg_lps * sizeof(GRobjid)));
      EMerr_hndlr (!adj_table,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

      adj_lps_per_lp = (IGRint *) om$malloc (size = (num_reg_lps * 
                                             sizeof(IGRint)));
      EMerr_hndlr (!adj_lps_per_lp,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

      for ( i = 0; i < num_reg_lps; i++)
      {
       adj_table_ptr = (i * num_reg_lps);
       adj_table[adj_table_ptr++] = lp_ids[i];
       adj_lps_per_lp[i] = 0;

       OM_stat = om$send (msg = message EMSloop.EMgetAdjacentLoops(
                           &mthd_stat, lp_ids, &num_reg_lps, 
                           &adj_table[adj_table_ptr], &adj_lps_per_lp[i],
                           EMLP_PLOOP, NULL),
                          targetid = lp_ids[i]);
       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
 
      } /* for ( i = 0; i < num_reg_lps; i++) */
              
      /*
       * adjacent table is ready now. Divide these loops
       * into two groups
       */
    
      status =  group_loops (&mthd_stat, num_imp_lps, imp_lp_ids, 
                             adj_table, num_reg_lps, adj_lps_per_lp,
                             partolbasis, env, &lps_of_group1,
                            &num_gr1_lps, &lps_of_group2, &num_gr2_lps,
                             amb_lps, num_amb_lps);
      EMerr_hndlr((!status || !(1&mthd_stat)),*EMmsg,EMS_E_Fail,wrapup);

      gr1_lps = lps_of_group1;
      gr2_lps = lps_of_group2;

     } /* if (num_reg_lps > 1) */
     else
     {
      gr1_lps = lp_ids;
      num_gr1_lps = 1;
      num_gr2_lps = 0;
    
     } /* else for if (num_reg_lps > 1) */

  } /* if (num_lps == 1) */
      
  /*
   * construct a loopset object. This loopset object
   * will have the second group of loops.
   */

  OM_stat = om$construct (classid = OPP_EMSloopset_class_id,
                          osnum = OM_Gw_current_OS,
                          p_objid = gr2_ls_id);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  /*
   * If there are any ambiguous loops, stop here and return
   */

  if (*num_amb_lps)
  {
      *EMmsg = EMS_I_NeedGrpInfo;
  }
  else
  {
     OM_stat = EMmake_chanselect (EMSloop_to_inner, &to_inner);
     EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

     /*
      * time to group the loops in two groups.
      */

     for (i = 0; i < num_gr1_lps; i++)
     {
        gr1_lp_to_connect = gr1_lps[i];
        gr2_lp_to_connect = *gr2_ls_id;
        sender_lp_type = EMLP_PLOOP;
        sender_lp_gr = EMS_MKFACE_GROUP1;

        OM_stat = om$send (msg = message EMSloop.EMgroup_loops ( 
                        &mthd_stat,
                        gr1_lp_to_connect, gr2_lp_to_connect,
                        sender_lp_type, sender_lp_gr),
                       senderid = gr1_lps[i], p_chanselect = &to_inner);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

      } /* for (i = 0; i < num_gr1_lps; i++) */

      OM_stat = EMmake_chanselect (EMSloop_to_outter, &to_outter);
      EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

      for (i = 0; i < num_gr2_lps; i++)
      {
        /*
         * disconnect gr2_lps[i] and
         * connect gr2_lps[i] to gr2_ls_id
         */

        OM_stat = om$send (msg = message Root.wild_disconnect( to_outter),
                       targetid = gr2_lps[i]);
        EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

        OM_stat = om$send (msg = message Root.connect ( ls_lp_chan,
                        i, gr2_lps[i], OM_Gw_current_OS, to_outter,
                        NULL),
                      targetid = *gr2_ls_id, targetos = OM_Gw_current_OS);
        EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

        gr1_lp_to_connect = *gr1_ls_id;
        gr2_lp_to_connect = gr2_lps[i];
        sender_lp_type = EMLP_PLOOP;
        sender_lp_gr = EMS_MKFACE_GROUP2;

        OM_stat = om$send (msg = message EMSloop.EMgroup_loops ( 
                        &mthd_stat,
                        gr1_lp_to_connect, gr2_lp_to_connect,
                        sender_lp_type, sender_lp_gr),
                       senderid = gr2_lps[i], p_chanselect = &to_inner);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

      } /* for (i = 0; i < num_gr2_lps; i++) */

  } /* else for if (*num_amb_lps) */

wrapup:
  EMWRAPUP (*EMmsg,OM_stat,"In EMSloopset.EMsplit_into_two_ls");

  if (adj_lps_per_lp)   om$dealloc (ptr = adj_lps_per_lp);
  if (adj_table)        om$dealloc (ptr = adj_table);
  if (lp_ids)           om$dealloc (ptr = lp_ids);
  if (lps_of_group1)    om$dealloc (ptr = lps_of_group1);
  if (lps_of_group2)    om$dealloc (ptr = lps_of_group2);

  return (OM_stat);

}   /* end EMsplit_int_two_ls method */


end implementation EMSloopset;
