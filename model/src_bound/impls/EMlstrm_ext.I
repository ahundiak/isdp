class implementation EMSloopset;

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsdef.h"
#include "emsimpdef.h"
#include "emsmacros.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emsinter.h" 
#include "EMSprop.h"
#include "EMSopt.h"
#include "EMSlm.h"
#include "emssfint.h"
#include "OMmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

#define SplitLocation(loc) \
	( ( (loc) == EMScvint_middle) ? MIDDLE : \
	  ( (loc) == EMScvint_rtend)  ? END : \
	  ( (loc) == EMScvint_lfend)  ? BEGIN : UNKNOWN )

from EMSloop import EMget_props;
from EMSloop import EMtrimyourself;
from EMSloop import EMextractyourself;

static IGRlong EMfix_pair_info(EMmsg, num_def_info, def_info,
                               num_pair_info, pair_info,
                               edge_count, edge_list, new_loop)

IGRlong                *EMmsg;
IGRint                 *num_def_info;
struct EMdef_con_info  *def_info;
IGRint                 *num_pair_info;
struct EMedge_con_info *pair_info;
IGRint                 edge_count;
OM_S_OBJECT_LINKAGE    *edge_list;
GRobjid                new_loop;

{
 IGRlong               stat_OM;
 IGRint                i, j;
 struct GRid           edge_id;
 OM_S_CHANSELECT       to_edges;

 *EMmsg = EMS_S_Success;

 stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
 if (! (1 & stat_OM)) goto wrapup;

 for (j=0; j<edge_count; j++)
  {
   stat_OM = om$get_objid_at_index(objid = new_loop,
                                   p_chanselect = &to_edges,
                                   index = j,
                                   objidaddr = &edge_id.objid,
                                   osnumaddr = &edge_id.osnum);
   if (! (1 & stat_OM)) goto wrapup;

   for (i=0; i<(*num_pair_info); i++)
    {
     if (IF_EQ_OBJID(edge_list[j].S_objid, pair_info[i].edge))
      {
       pair_info[i].edge = edge_id.objid;
       break;
      }
     if (IF_EQ_OBJID(edge_list[j].S_objid, pair_info[i].comm_edge))
      {
       pair_info[i].comm_edge = edge_id.objid;
       break;
      }
    }

   for (i=0; i<(*num_def_info); i++)
    {
     if (IF_EQ_OBJID(edge_list[j].S_objid, def_info[i].com_edge1))
      {
       def_info[i].com_edge1 = edge_id.objid;
       break;
      }
     if (IF_EQ_OBJID(edge_list[j].S_objid, def_info[i].com_edge2))
      {
       def_info[i].com_edge2 = edge_id.objid;
       break;
      }
    }
   }

 wrapup:
  return;
}         

method EMtrim_extract(IGRlong                         *EMmsg;
                      struct GRmd_env                 *my_env;
                      struct EMedge_round_info        *my_info;
                      struct GRid                     srf_GRid;
                      IGRint                          num_edges;
                      struct  EMSpartolbasis          *partolbasis;
                      IGRint                          num_imp_loops;
                      GRobjid                         *imp_loop_ids;
                      IGRint                          *num_entries;
                      GRobjid                         **out_loops;
                      IGRboolean                      *in_area_trim;
                      IGRboolean                      info_to_save;
                      IGRint                          *num_saves;
                      GRobjid                         *edge_ids;
                      IGRboolean                      *to_disconnect;
                      IGRint                          num_conn_edge;
                      GRobjid                         *conn_edges;
                      IGRint                          *num_pair_info;
                      struct EMedge_con_info          *pair_info;
                      IGRint                          *num_def_info;
                      struct EMdef_con_info           *def_info;
                      IGRboolean                      blend_surface;
                      struct  EMSsfintedpar           ***trim_info)

/*
 Notes

History  gupta     03/14/88        Creation Date
TAPADIA	11th Jan. 91 	Fix for TR 90n3345. Reallocted memory for 
			extracting loops. Changed from sizeof(struct GRid) to 
			GRobjid for trim_loops during realloc.
*/

{

IGRlong                 stat_OM, msg;
IGRboolean              trim_loop, edge_extended;
IGRboolean              is_in_list;
GRobjid                 *loop_ids,
                        trimmed_loop_id,
                        com_edge, dangling_edge,
                        *trim_loops, *trim_loops_ptr;
IGRint                  *num_bdrys, extend_end;
OMuint                  count, ed_count, lp_count, comm_edge_cnt;
IGRint                  BUF_INC,
                        BUF_SIZE,
                        extract_buffer,
                        i, j, k, m,
                        num_loops = 0,
                        split_buffer,
                        trim_buffer;
IGRushort       lp_props;
IGRushort       ext_options;
IGRdouble               end_point[2];
IGRdouble               bastol, max_ext_dist;
struct  EMSsfintedpar   **against_bdrys,
                        *EMsfintedpar_malloc(),
                        **loop_bdrys,
                        **trim_info_ptr,
                        **out_bdrys;
void                    EMsfintedpar_free();
OM_S_CHANSELECT         to_assoc,
                        to_edges,
                        to_loops,
                        to_common_edge;
OM_S_OBJECT_LINKAGE     *edge_list;

/*----------------------------------------------------------------------*/

stat_OM = OM_S_SUCCESS;
*EMmsg = EMS_S_Success;

against_bdrys = NULL;
loop_ids = NULL;
loop_bdrys = NULL;
out_bdrys = NULL;
trim_loops = NULL;
num_bdrys = NULL;
*num_entries = 0;

to_loops.type = OM_e_addr;
to_loops.u_sel.addr = &ME.EMSloopset->to_loops;

stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
stat_OM = EMmake_chanselect (GRnotify_notification, &to_assoc);
stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
if (! (1 & stat_OM)) goto wrapup;
/*
 * Assuming that loops returned by EMget_mapped_data
 * are not self intersecting (which is true), if the loopset
 * under consideration is a natural loopset and the 
 * loop under consideration is a closed loop, there is no need to
 * send it for trimming as it will not be trimmed any way.
 */

/* allocate memory for trimming process */

BUF_SIZE = 3 * num_imp_loops;
BUF_INC = num_imp_loops;

trim_buffer = BUF_SIZE;
   
against_bdrys = (struct EMSsfintedpar **) om$malloc(size = 
                (trim_buffer * sizeof(struct EMSsfintedpar *)));

loop_bdrys = (struct EMSsfintedpar **) om$malloc(size = 
             (trim_buffer * sizeof(struct EMSsfintedpar *)));

loop_ids = (GRobjid *) om$malloc (size = (trim_buffer * 
                                     sizeof(GRobjid)));

num_bdrys = (IGRint *) om$malloc (size = (trim_buffer *
                                      sizeof(IGRint)));
EMerr_hndlr(!against_bdrys || !loop_bdrys || !loop_ids || !num_bdrys,
	*EMmsg, EMS_E_NoDynamicMemory, wrapup);

/* allocate memory for extract */

extract_buffer = BUF_SIZE;

out_bdrys = (struct EMSsfintedpar **) om$malloc(size = 
                (extract_buffer * sizeof(struct EMSsfintedpar *)));
EMerr_hndlr(!out_bdrys,*EMmsg, EMS_E_NoDynamicMemory, wrapup);

/* allocate memory to be used by extractyourself and splityourself */

split_buffer = BUF_SIZE;

*trim_info = (struct EMSsfintedpar **) om$malloc (size = 
                (split_buffer * sizeof(struct EMSsfintedpar *)));
EMerr_hndlr(!(*trim_info),*EMmsg, EMS_E_NoDynamicMemory, wrapup);

trim_loops = (GRobjid *) om$malloc (size = (split_buffer * sizeof(GRobjid)));
EMerr_hndlr(!trim_loops,*EMmsg, EMS_E_NoDynamicMemory,wrapup);

for (i=0; i<num_imp_loops; i++)
 {
  trim_loop = TRUE;
  edge_list = NULL;

  /* check if the loop is a closed loop or not */
      
  stat_OM = om$send (msg = message EMSloop.EMget_props(
                           &msg, &lp_props),
                     targetid = imp_loop_ids[i]);
  EMerr_hndlr (!(1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);

  if (! (lp_props & EMLP_OPEN))
   {
    stat_OM = om$get_channel_count(object = me,
                                   p_chanselect = &to_loops,
                                   count = &lp_count);
    EMerr_hndlr(! (1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

    if ((ME.EMSloopset->ls_props & EMLS_NATURAL) ||
        (lp_count <= 1) || (! (lp_props & EMLP_PLOOP)))
     {
      trim_loop = FALSE;

      if (!(*num_entries < split_buffer))
       {
        split_buffer += BUF_INC;
/*
        trim_loops = (GRobjid *) om$realloc(ptr = (char *)trim_loops,
                      size = split_buffer * sizeof(struct GRid));
*/
        trim_loops = (GRobjid *) om$realloc(ptr = (char *)trim_loops,
                      size = split_buffer * sizeof(GRobjid));
        EMerr_hndlr(!trim_loops, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

        *trim_info = (struct EMSsfintedpar **) om$realloc(
                      ptr = (char *)*trim_info,size = split_buffer * 
                      sizeof(struct EMSsfintedpar *));
        EMerr_hndlr(!(*trim_info), *EMmsg, EMS_E_NoDynamicMemory, wrapup);
       } /* if (!(*num_entries < split_buffer)) */

      trim_loops[*num_entries] = imp_loop_ids[i];
  
      (*trim_info)[*num_entries]  = (struct EMSsfintedpar *) 
                   om$malloc (size = sizeof(struct EMSsfintedpar));
      EMerr_hndlr (!(*trim_info)[*num_entries], *EMmsg,
                   EMS_E_NoDynamicMemory, wrapup);

      (*trim_info)[*num_entries]->edgeid = NULL_OBJID;
      (*trim_info)[*num_entries]->next = NULL;
      (*num_entries)++;
      num_bdrys[i] = 1;
     }
   } /* if (!(lp_props & EMLP_OPEN)) */
        
  if (trim_loop)
   {
    num_loops = 0;

    ex$message ( msgnumb = EMS_S_TrimmingLps);
    stat_OM = om$send (msg = message EMSloop.EMtrimyourself(&msg,
                             &my_id,
                             NULL,
                             &against_bdrys,
                             &loop_bdrys,
                             &loop_ids,
                             &num_loops,
                             &num_bdrys,
                             &trim_buffer,
                             partolbasis),
                       targetid = imp_loop_ids[i]);
    EMerr_hndlr (!(1&stat_OM&msg), *EMmsg, EMS_E_LoopError, wrapup);
    EMerr_hndlr(msg == EMS_I_InHoleTrim, *EMmsg, EMS_E_InHoleTrim, wrapup);

    ex$message ( msgnumb = EMS_I_ClearStatusField);

    /* Sometimes during surface/surface intersection, the intersection
       data does not terminate at the loop. An attempt is being made
       here to extend the edge polynomially by ~100*bastol and retry
       trimming */

    if ((num_loops == 1) && (lp_props & EMLP_OPEN))
     {
      if ((against_bdrys[0]->edgeid == NULL_OBJID) ||
          (against_bdrys[0]->next->edgeid == NULL_OBJID))
       {
        ex$message ( msgnumb = EMS_S_TrimmingUnsuccessfulRetrying);
     
        if (against_bdrys[0]->edgeid != NULL_OBJID)
         {
          stat_OM = EMsend_loops(&msg,
                        message EMSboundary.EMget_objid (&msg,
                        &trimmed_loop_id), against_bdrys[0]->edgeid, 0,
                        MAXINT, EMLP_ACTIVE, NULL, NULL);
          EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
         }
        else
        if (against_bdrys[0]->next->edgeid != NULL_OBJID)
         {
          stat_OM = EMsend_loops(&msg,
                        message EMSboundary.EMget_objid (&msg,
                        &trimmed_loop_id), against_bdrys[0]->next->edgeid,
                        0, MAXINT, EMLP_ACTIVE, NULL, NULL);
          EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
         }
        else
          goto some_label;

        dangling_edge = (against_bdrys[0]->edgeid == NULL_OBJID) ?
                    loop_bdrys[0]->edgeid : loop_bdrys[0]->next->edgeid;

        extend_end = (against_bdrys[0]->edgeid == NULL_OBJID) ?
                             SplitLocation(loop_bdrys[0]->intloc) :
                             SplitLocation(loop_bdrys[0]->next->intloc);

        if (against_bdrys[0]->edgeid == NULL_OBJID)
         {
          end_point[0] = loop_bdrys[0]->point[0];
          end_point[1] = loop_bdrys[0]->point[1];
         }
        else
         {
          end_point[0] = loop_bdrys[0]->next->point[0];
          end_point[1] = loop_bdrys[0]->next->point[1];
         }

        edge_extended = FALSE;

        BSEXTRACTPAR(&msg, BSTOLLENVEC, bastol);
        max_ext_dist = 100 * bastol;

        edge_extended = EMextend_edge_upto_loop(&msg,
                                                my_env,
                                                dangling_edge,
                                                extend_end,
                                                end_point,
                                                trimmed_loop_id,
                                                max_ext_dist,
                                                partolbasis);
        EMerr_hndlr (! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);

        if (edge_extended)
         {
          num_loops = 0;

          stat_OM = om$send (msg = message EMSloop.EMtrimyourself(&msg,
                                   &my_id,
                                   NULL,
                                   &against_bdrys,
                                   &loop_bdrys,
                                   &loop_ids,
                                   &num_loops,
                                   &num_bdrys,
                                   &trim_buffer,
                                   partolbasis),
                             targetid = imp_loop_ids[i]);
          EMerr_hndlr (!(1&stat_OM&msg), *EMmsg, EMS_E_LoopError, wrapup);
    
          ex$message ( msgnumb = EMS_I_ClearStatusField);
         }
       }
     }

some_label:

    *in_area_trim = (msg == EMS_I_InAreaTrim) ? TRUE : FALSE;
    
    for (j=0; j<num_loops; j++)
     {
      trim_info_ptr = &((*trim_info)[*num_entries]);
      trim_loops_ptr = &trim_loops[*num_entries];

      if (*in_area_trim)
       {
        trim_loops[*num_entries] = imp_loop_ids[i];
        OM_BLOCK_MOVE(&against_bdrys[j], &trim_info_ptr[j], sizeof (struct
                      EMSsfintedpar *));
       }
      else
       {
        /* check if memory will be avaialable for extracting */

        if ( (*num_entries + num_bdrys[j]) > split_buffer)
         {
          split_buffer = *num_entries + num_bdrys[j];
/* 
          trim_loops = (GRobjid *) om$realloc (ptr = (char *)trim_loops,
                           size = split_buffer * sizeof(struct GRid));
*/
          trim_loops = (GRobjid *) om$realloc (ptr = (char *)trim_loops,
                           size = split_buffer * sizeof(GRobjid));
          EMerr_hndlr(!trim_loops,*EMmsg,EMS_E_NoDynamicMemory, wrapup);
 
          *trim_info = (struct EMSsfintedpar **) om$realloc (
                        ptr = (char *)*trim_info, size = split_buffer * 
                        sizeof(struct EMSsfintedpar *));
          EMerr_hndlr(! (*trim_info), *EMmsg, EMS_E_NoDynamicMemory,
                      wrapup);

	/* TAPADIA - Fix for TR 90n3345 */

          trim_info_ptr = &((*trim_info)[*num_entries]);
          trim_loops_ptr = &trim_loops[*num_entries];

	  out_bdrys = (struct EMSsfintedpar **) om$realloc(ptr = 
	      (char *)out_bdrys,size = (split_buffer * sizeof(struct EMSsfintedpar *)));
	  EMerr_hndlr(!out_bdrys,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
         } 
                
        stat_OM = om$get_channel_count(objid = imp_loop_ids[i],
                                       p_chanselect = &to_edges,
                                       count = &ed_count);
        EMerr_hndlr(! (1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

        edge_list = (OM_S_OBJECT_LINKAGE *) om$malloc(size =
                     ed_count * (sizeof (OM_S_OBJECT_LINKAGE)));

        stat_OM = om$get_channel_objects (objid = imp_loop_ids[i],
                                          p_chanselect = &to_edges,
                                          list = edge_list,
                                          size = ed_count,
                                          count = &count);
        EMerr_hndlr(! (1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

        for (k=0; k<num_conn_edge; k++)
         {
          stat_OM = om$send (msg = message Root.connect (to_assoc,
                                   NULL, conn_edges[k], OM_Gw_current_OS,
                                  to_assoc, NULL),
                             senderid = conn_edges[k],
                             p_chanselect = &to_common_edge);
          if (! (1 & stat_OM)) goto wrapup;
         }

        ex$message ( msgnumb = EMS_S_ExtractingLoops);

        ext_options = EMImpBnd_NoInputDelete | EMImpBnd_MaintainAssoc; 
        stat_OM = om$send (msg = message EMSloop.EMextractyourself(&msg,
                                 loop_bdrys[j],
                                 against_bdrys[j],
                                 num_bdrys[j],
                                 &trim_loops_ptr,
                                 &out_bdrys,
                                 &trim_info_ptr,
                                 TRUE,
                                 ext_options,
                                 partolbasis),
                           targetid = loop_ids[j]);
        EMerr_hndlr (!(1&stat_OM&msg), *EMmsg, EMS_E_LoopError, wrapup);

        if ((num_pair_info[0]) && (ed_count == count))
         {
          IGRlong   EMfix_pair_info();

          EMfix_pair_info(&msg, num_def_info, def_info, num_pair_info,
                          pair_info, ed_count, edge_list,
                          trim_loops_ptr[0]);
          if (! (1 & msg)) goto wrapup;
         }
       }
     
      if ((! blend_surface) && (info_to_save))
       {
        for (k=0; k<num_bdrys[j]; k++)
         {
          if ((SplitLocation(trim_info_ptr[k]->intloc) == UNKNOWN) ||
              (SplitLocation(trim_info_ptr[k]->intloc) == MIDDLE))
           {
            if (trim_info_ptr[k]->edgeid != NULL_OBJID)
             {
              is_in_list = FALSE;

              stat_OM = om$get_channel_count (
                                      osnum = OM_Gw_current_OS,
                                      objid = trim_info_ptr[k]->edgeid,
                                      p_chanselect = &to_common_edge,
                                      count = &comm_edge_cnt);

              if (comm_edge_cnt)
               {
                stat_OM = om$send(msg = message EMSboundary.EMget_objid(
                                        &msg, &com_edge),
                                  senderid = trim_info_ptr[k]->edgeid,
                                  p_chanselect = &to_common_edge);
                EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg,
                            EMS_E_EdgeError,wrapup);

                for (m=0; m<(*num_saves); m++)
                 {
                  if (IF_EQ_OBJID(com_edge, edge_ids[m]))
                   {
                    is_in_list = TRUE;
                    break;
                   }
                 }
                if (! is_in_list)
                 {
                  edge_ids[(*num_saves)] = trim_info_ptr[k]->edgeid;
                  to_disconnect[(*num_saves)] = FALSE;
                  (*num_saves)++;
                 }
               }
             }
           }

          if((SplitLocation(trim_info_ptr[k]->next->intloc) == UNKNOWN) ||
             (SplitLocation(trim_info_ptr[k]->next->intloc) == MIDDLE))
           {
            if ((trim_info_ptr[k]->next->edgeid != NULL_OBJID) &&
                (trim_info_ptr[k]->edgeid !=
                               trim_info_ptr[k]->next->edgeid))
             {
              is_in_list = FALSE;
    
              stat_OM = om$get_channel_count (
                                  osnum = OM_Gw_current_OS,
                                  objid = trim_info_ptr[k]->next->edgeid,
                                  p_chanselect = &to_common_edge,
                                  count = &comm_edge_cnt);

              if (comm_edge_cnt)
               {
                stat_OM = om$send(msg = message EMSboundary.EMget_objid(
                                        &msg, &com_edge),
                                senderid = trim_info_ptr[k]->next->edgeid,
                                p_chanselect = &to_common_edge);
                EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg,
                            EMS_E_EdgeError,wrapup);

                for (m=0; m<(*num_saves); m++)
                 {
                  if (IF_EQ_OBJID(com_edge, edge_ids[m]))
                   {
                    is_in_list = TRUE;
                    break;
                   }
                 }
                if (! is_in_list)
                 {
                  edge_ids[(*num_saves)] = trim_info_ptr[k]->next->edgeid;
                  to_disconnect[(*num_saves)] = FALSE;
                  (*num_saves)++;
                 }
               }
             }              
           }
         }
       }

      *num_entries += num_bdrys[j];
                
      /* deallocate the space for out_bdrys link list. */
 
      if (! (*in_area_trim))
       {
        for (k=0; k<num_bdrys[j]; k++)
         {
          EMsfintedpar_free(out_bdrys[k],2);
          out_bdrys[k] = NULL;
         }
       }
     } /* for (j=0; j<num_loops; j++) */
   } /* if (trim_loop) */

  trim_buffer += num_loops;
  if (edge_list) om$dealloc(ptr = edge_list);
 } /* for (i=0; i<num_imp_loops; i++) */

*out_loops = trim_loops;

wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "In EMSloopset.EMtrim_extract");

 if (loop_bdrys) om$dealloc (ptr = loop_bdrys);
 if (loop_ids) om$dealloc (ptr = loop_ids);
 if (out_bdrys) om$dealloc (ptr = out_bdrys);
 if (num_bdrys) om$dealloc (ptr = num_bdrys);

 return (stat_OM);

}


end implementation EMSloopset;
