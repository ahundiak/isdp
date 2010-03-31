/* ###################   APOGEE COMPILED   ################## */
class implementation ECselundo;
/*
Description

Return values

History
        scw     08/14/94    clarified sleep method
    Vadiraj     06/10/92    Modified for message subsystem compliance.   
        DLB     02/21/92    Made EFassoc_in_tree_path function non-static.
        DLB     10/31/89    Removed display of specific window.
        DLB     09/29/89    Added error checks for replacing node.  Ask for 
                            orientation if replacing node is a surface.
        DLB     06/23/89    Added replace node code.
        DLB     02/23/89    Added event generator code.
        DLB     01/05/89    Added remove node code.
        DLB     04/28/88    Added sel redo code.
        DLB     03/24/88    Creation date.
*/

#include "EMS.h"

#define UNDO    0    /*Free tree node.*/
#define REPLACE 1    /*Replace the located tree node with an external node.*/
#define EG      2    /*Event generator to locate intermediate state.*/


#define DEBUG 0 /*Set to 1 if wanting error strings.*/

#include "stdio.h"
#include "ECdlb.h"
#include "EMSopt.h"
#include "EMSmsgdef.h"
#include "OMmacros.h"
#include "dpmacros.h"
#include "lcmacros.h"
#include "exmacros.h"
#include "EMSdpr.h"
#include "EC_I.h"
#include "EC_S.h"
#include "EC_P.h"
#include "EC_E.h"
#include "EC_M.h"

%safe 
OM_S_OBJID edittree_id=0xffffffff;
%endsafe

from GRgraphics import GRdisplay;
from EMSsurface import EMmake_active_state, EMgetactiveid,
                       EMgettreepath, EMgetstatedesc, EMtree_display,
                       EMreplace, EMshow_normals, EMrevorient;
from EMSdpr     import EMredo, EMtreecleanup, EMcleanSSI;
from EMSsubbs   import EMupdateGradata;
from EMSedittree import EMinit;

extern OMuword OPP_EMSsubbs_class_id, 
               OPP_EMSdpr_class_id,
               OPP_EMSsurface_class_id,
               OPP_EMSsolid_class_id;

from GRgraphics import GRgetprops;

IGRboolean EFassoc_in_tree_path(msg,
                                pathlist,
                                pathlist_size,
                                osnum)
IGRlong     *msg;
GRobjid     *pathlist;
IGRint      pathlist_size;
OMuword     osnum;
{
  IGRlong OM_stat, ii;
  IGRshort props;

  for(ii=0; ii<pathlist_size; ii++)
  {
    OM_stat = om$send(msg = message GRgraphics.GRgetprops(msg, &props),
                      senderid = NULL_OBJID,            
                      targetid = pathlist[ii],
                      targetos = osnum);
    if (! (1 & OM_stat & *msg)) return(FALSE);

    if (props & GRIS_ASSOCIATIVE) return(TRUE);
  }
  return(FALSE);
}

method wakeup(int pos)
{
  IGRlong OM_stat = OM_S_SUCCESS;

  if (me->got_path)
  {
    IGRlong         msg = EMS_S_Success;
    enum GRdpmode   display_mode = GRhhd;
    struct GRid     md_GRid;

    md_GRid = me->module_env.md_id;
    md_GRid.objid = me->window_id;
    OM_stat = om$send(msg = message GRgraphics.GRdisplay(&msg,
                            &me->module_env.md_env.matrix_type,
                            me->module_env.md_env.matrix,
                            &display_mode, &md_GRid),
                      targetid = me->path[me->path_pos],
                      targetos = me->node_os);
    ERROR(OM_stat, msg, "wakeup erase ", wrapup);

    ex$message(field = ERROR_FIELD, in_buff = me->desc);  
  }
  
  wrapup:
   return(OM_stat);
}


method super_cmd.sleep(int pos)
{
  IGRlong msg;
  dp$erase_hilite(msg = &msg);

  ex$message(msgnumb = EM_M_ClearMessageField);
  ex$message(msgnumb = EMS_S_ClearStatusField); 
  ex$message(msgnumb = EMS_P_ClearPromptField);
  return(OM_S_SUCCESS);
}


method execute(int *response; char *response_data; int pos)
{
 IGRint             OM_stat=OM_S_SUCCESS;
 IGRlong            msg=EMS_S_Success;
 IGRint             eventmsg, size=sizeof(struct GRevent),
                    display_flag, locate_mask, accept_mask, token = 0,
                    i, j;
 IGRlong            qsize = sizeof(me->locate_event.event) + sizeof (IGRint);
 struct GRmd_env    *md_env;
 GRobjid            display_id = 0, stop_id;
 enum   GRdpmode    display_mode;
 struct GRid        md_GRid;
 struct GRlc_locate attr;
 OM_S_CLASSLIST     rtree_classes, elig_classes;
 IGRshort           mytype;
 IGRboolean         gothru = FALSE;
 IGRchar            loc_prompt[54], acc_prompt[54], reloc_prompt[54];


 #define NUM_TOKENS 5
 static IGRint Tokens[NUM_TOKENS] =
 {
   EX_BACK_UP, DATA, STRING, EX_RJT_MOVEON, GR_UNKNOWN_TYPE
 };

 enum actions
 {
   NIL, ERR, init, get_path, mod_path, do_display, verify, process, remrepl,
   redo, tree_cln
 };

 #define NUM_STATES 5
 enum states
 { 
   start, dummy, gotnode, gotrepl, shown
 };

 static enum states NextState[NUM_STATES][NUM_TOKENS] =
 {
   /*  token:      BACKUP   DATA     STRING   MOVEON   UNK
    old state: */                                   
   /* start    */ {dummy,   dummy,   dummy,   gotnode, start  },
   /* dummy    */ {dummy,   start,   dummy,   dummy,   dummy  },
   /* gotnode  */ {start,   gotrepl, gotnode, shown,   gotnode},
   /* gotrepl  */ {gotnode, gotrepl, shown,   gotrepl, gotrepl},
   /* shown    */ {dummy,   start,   start,   start,   start  }
 };
 
 static enum actions NextAction[NUM_STATES][NUM_TOKENS] =
 {
   /*  token:      BACKUP    DATA        STRING    MOVEON    UNK
    old state: */                                           
   /* start    */ {mod_path, get_path,   mod_path, NIL,      NIL      }, 
   /* dummy    */ {NIL,      do_display, NIL,      NIL,      NIL      },
   /* gotnode  */ {NIL,      verify,     NIL,      process,  NIL      },
   /* gotrepl  */ {remrepl,  NIL,        process,  NIL,      NIL      },
   /* shown    */ {redo,     tree_cln,   tree_cln, tree_cln, tree_cln }
 };

 #if DEBUG
  fprintf(stderr,"In debug\n");
 #endif

 switch(ME.super_cmd->mytype)
 {
   case UNDO:
     ex$message(msgnumb = EM_M_FrTrNd);
     break;
   case EG:
     ex$message(msgnumb = EM_M_LctIntmdNd);     
     break;
   case REPLACE:
     ex$message(msgnumb = EM_M_ReplcTrNd);  
     break;
   default:
     ERROR(OM_E_ABORT, EMS_E_Fail, "Invalid mytype", wrapup);        
 }

 mytype = ME.super_cmd->mytype;
 md_env = &me->module_env;
 md_GRid = md_env->md_id;

 do
 {
  switch (ME.COconst->action)
  {
   case NIL:
   case ERR:
   {
    break;
   }
 

   case init:
   {
     me->got_path = FALSE;
     break;
   }


   case get_path:
   {
     IGRint  pathlist_size=0, ipathlist_size=0;
     GRobjid *pathlist=NULL, *ipathlist=NULL, top_id = 0, path_pos_id = 0, temp_id;

     temp_id = me->locate_event.located_object[0].located_obj.objid;

     if (!me->got_path) 
     {
       /**me->window_id = me->locate_event.event.button.objid;**/
       /*Display in all windows. DLB 10/31/89.*/
       me->window_id =
                   me->locate_event.located_object[0].module_info.md_id.objid; 
       me->node_os = me->locate_event.located_object[0].located_obj.osnum;
       me->module_env = me->locate_event.located_object[0].module_info;
       md_env = &me->module_env;
       md_GRid = md_env->md_id;
     }
     else
     {
       if (me->locate_event.located_object[0].located_obj.osnum != me->node_os)
       {
         ex$message(msgnumb = EMS_S_InvldSrfSlctd);
         ME.super_cmd->state = start;
         break;
       }

       /*Temporarily store the top index id.  This is used to get the top
        * index of the intersected path (see below).
        * Also store the path_pos id.  This is used to get the path_pos
        * index of the intersection path (see below).
        */
       top_id = me->path[me->top];
       path_pos_id = me->path[me->path_pos];
     }

     OM_stat = om$send(msg = message EMSsurface.EMgettreepath(&msg,
                             &pathlist, &pathlist_size, FALSE),
                       targetid = temp_id,
                       targetos = me->node_os);
     ERROR(OM_stat, msg, "EMgettreepath", wrapup);        

     if (me->mytype != UNDO && 
         EFassoc_in_tree_path(&msg, pathlist, pathlist_size, me->node_os))
     {
       ex$message(msgnumb = EMS_E_AsscEleNtCurntSupptd);
       ME.super_cmd->state = start;
       break;
     }
     
     if (pathlist_size == 1)
     {
       ex$message(msgnumb = EMS_E_SlctdNdIsAlrdyFr); 
       ME.super_cmd->state = start;
       break;
     }

     if (me->got_path)
     {
       /*This is the next path gotten, so intersect the two paths.*/

       IGRint  small_size, large_size, vla_size, temp_list_size;
       GRobjid *temp_list, *small_list, *large_list;

       vla_size = om$dimension_of(varray = me->path);
 
       if (pathlist_size < vla_size)
       {
         small_size = pathlist_size;
         small_list = pathlist;         
         large_size = vla_size;
         large_list = me->path;
       }
       else
       {
         small_size = vla_size;
         small_list = me->path;
         large_size = pathlist_size;
         large_list = pathlist;         
       }           

       temp_list_size = 0;

       temp_list = (GRobjid *) om$malloc(
                    size = small_size * sizeof(GRobjid));
       if (!temp_list) 
        ERROR(OM_S_SUCCESS, EMS_E_NoDynamicMemory,"alloc templist", wrapup);

       for (i=0; i<small_size; i++)
       {
         for (j=0; j<large_size; j++)
         {
           if (small_list[i] == large_list[j])
             temp_list[temp_list_size++] = small_list[i];
         }
       }

       ipathlist = temp_list;
       ipathlist_size = temp_list_size;

       om$dealloc(ptr = pathlist);
       pathlist = NULL;

       for (i=0; i<ipathlist_size; i++) if (top_id == ipathlist[i]) break;

       if (i == ipathlist_size)
       {
         /*ERROR CHECK: if the top_id is not in the intersection path then
          * the only intersection was the active state.  This is not valid
          * so notify user and return to previous path.
          */

         ex$message(msgnumb = EMS_E_SlctdNdIsAlrdyFr);

         if (ipathlist)
         { 
           om$dealloc(ptr = ipathlist);
           ipathlist = NULL;
         }

         ME.super_cmd->state = start;
         break;
       }

       /*Save the path for backup purposes.*/
       if (om$dimension_of(varray = me->old_path) < vla_size)
       {
         OM_stat = om$vla_set_dimension(varray = me->old_path,  
                                        size = vla_size);    
         ERROR(OM_stat, EMS_S_Success, "om$vla_set_dim", wrapup);
       }

       OM_BLOCK_MOVE(me->path, me->old_path, vla_size * sizeof(GRobjid));
       me->old_path_pos = me->path_pos;
       me->old_top = me->top;
     }
     else 
     {
       ipathlist = pathlist;
       ipathlist_size = pathlist_size;
     }

   
     if (om$dimension_of(varray = me->path) < ipathlist_size)
     {
       OM_stat = om$vla_set_dimension(varray = me->path,  
                                      size = ipathlist_size);    
       ERROR(OM_stat, EMS_S_Success, "om$vla_set_dim", wrapup);
     }

     OM_BLOCK_MOVE(ipathlist, me->path, ipathlist_size * sizeof(GRobjid));

     if (ipathlist)
     { 
       om$dealloc(ptr = ipathlist);
       ipathlist = NULL;
     }

     if (!me->got_path)
     {
       me->top = ipathlist_size - 2;  
       me->path_pos = 0; 
       display_id = me->path[me->path_pos];
       display_mode = GRhhd;
       stop_id = NULL_OBJID;
       me->got_path = TRUE;
     }
     else
     {
       /*Use previous info to get top index and path_pos (see above).*/
       for (i=0; i<ipathlist_size; i++)
         if (top_id == me->path[i]) break;
       me->top = i; 

       for (i=0; i<ipathlist_size; i++)
         if (path_pos_id == me->path[i]) break;
 
       if (i == ipathlist_size)
       {
         /*Path_pos_id wasn't in the intersection path.*/
         me->path_pos = 0;
         display_id = me->path[me->path_pos];
         stop_id = path_pos_id;
         display_mode = GRhhd;
       }
       else
       {
         /*It was in path.*/
         me->path_pos = i;
         display_id = me->path[me->path_pos];
         stop_id = display_id;
       }
     }     

     break;
   }   


   case mod_path:
   {
     if (!me->got_path) 
     {
       ex$message(msgnumb = EMS_S_InvInp);
       ME.super_cmd->state = start;
       break;
     }

     if (Tokens[token] == STRING)  
     {
       IGRboolean bottom_node = FALSE, top_node = FALSE; /*DECL*/

       switch(toupper(me->locate_event.event.keyin[0]))
       {
         case 'U':
         {
           stop_id = me->path[me->path_pos];
           if (me->path_pos == me->top) top_node = TRUE;
           else me->path_pos++;
           display_id = me->path[me->path_pos];
           display_mode = GRhhd;
           break;
         }
         case 'D':
         {
           display_id = me->path[me->path_pos];
           if (me->path_pos == 0) bottom_node = TRUE;
           else me->path_pos--;
           stop_id = me->path[me->path_pos];
           display_mode = GRhe;
           break;
         }
         case 'T':
         {
           stop_id = me->path[me->path_pos];
           if (me->path_pos == me->top) top_node = TRUE;
           else me->path_pos = me->top;
           display_id = me->path[me->path_pos];
           display_mode = GRhhd;           
           break;
         }
         case 'B':
         {
           display_id = me->path[me->path_pos];
           if (me->path_pos == 0) bottom_node = TRUE;
           else me->path_pos = 0;
           stop_id = me->path[me->path_pos];
           display_mode = GRhe;
           break;
         }
         case 'R':
         {
           dp$erase_hilite(msg = &msg);
           OM_stat = om$vla_set_dimension(varray = me->old_path, size = 0);
           ERROR(OM_stat, EMS_S_Success, "vla_set_dim", wrapup);
           me->got_path = FALSE;
           ME.super_cmd->state = start;
           break;
         }
         default:
         {
           ME.COconst->action = NIL;
           ME.super_cmd->state = start;
           return (OM_S_SUCCESS);
         }
       }

       if (bottom_node || top_node)
       {
         if (bottom_node) 
         ex$message(msgnumb = EMS_S_BtmNdInPth)
         else 
         ex$message(msgnumb = EMS_S_TopNdInPth);
         ems_sleep(2);
         ex$message(field = ERROR_FIELD, in_buff = me->desc);
         ME.super_cmd->state = start;
         break;
       }
     }
     else if (Tokens[token] == EX_BACK_UP)
     {
       IGRint vla_size;         /*DECL*/

       vla_size = om$dimension_of(varray = me->old_path);

       if (!vla_size)
       {
         ex$message(msgnumb = EMS_S_NoPrvsPthDefnd);
         ems_sleep(2);
         ME.super_cmd->state = start;
         break;
       }

       ex$message(msgnumb = EMS_S_RetrngToPrvsPth);
       ems_sleep(2);

       if (om$dimension_of(varray = me->path) < vla_size)
       {
         OM_stat = om$vla_set_dimension(varray = me->path,  
                                        size = vla_size);    
         ERROR(OM_stat, EMS_S_Success, "vla_set_dim", wrapup);
       }

       display_id = me->path[me->path_pos]; 
       display_mode = GRhe;
       stop_id = me->old_path[me->old_path_pos];
       
       OM_BLOCK_MOVE(me->old_path, me->path, vla_size * sizeof(GRobjid));
       me->path_pos = me->old_path_pos;
       me->top = me->old_top;
     }       

     break;
   }

  
   case do_display:
   {
     OM_stat = om$send(msg = message EMSsurface.EMgetstatedesc(&msg, 
                             me->desc),
                       targetid = me->path[me->path_pos],
                       targetos = me->node_os);
     ERROR(OM_stat, msg, "EMgetstatedesc", wrapup);

     ex$message(field = ERROR_FIELD, in_buff = me->desc);

     if (display_id != stop_id)
     {
       md_GRid.objid = me->window_id;
       OM_stat = om$send(msg = message EMSsurface.EMtree_display(&msg,
                               &md_env->md_env.matrix_type,
                               md_env->md_env.matrix, &display_mode, 
                               &md_GRid, &stop_id, 1),
                         targetid = display_id,
                         targetos = me->node_os);
       ERROR(OM_stat, msg, "ECundo erase ", wrapup);
     }
     break;
   }


   case verify:
   {
     struct GRid active_GRid;  /*DECL*/

     if (mytype != REPLACE) break;

     me->replacing_id =me->locate_event.located_object[0].located_obj.objid;

     /*Make sure a different tree was indeed located.*/
     OM_stat = om$send(msg = message EMSsurface.EMgetactiveid(&msg,
                             &active_GRid, NULL),
                       targetos = me->node_os,
                       targetid = me->replacing_id);
     ERROR(OM_stat, msg, "getacid", wrapup);

     /*Save the replace id if valid.*/    
     if (me->locate_event.located_object[0].located_obj.osnum != 
         me->node_os ||
         me->path[me->top+1] == active_GRid.objid)
     {
       ex$message(msgnumb = EMS_S_InvldNdSlctd);
       ems_sleep(2);        
       ME.super_cmd->state = gotnode;
       /*DONT BREAK, FALL THRU TO remrepl ACTION*/
     }
     else
     {
       /*See if need to orient replacing id*/
       if (!EFisAncestryValid(&msg, me->replacing_id, me->node_os,
                              OPP_EMSsolid_class_id, FALSE))
         me->got_surface = TRUE;
       break;
     }
     /*NO BREAK!*/
   }


   case remrepl:
   {
     display_mode = GRhe;
     OM_stat = om$send(msg = message GRgraphics.GRdisplay(&msg,
                             &md_env->md_env.matrix_type,
                             md_env->md_env.matrix,
                             &display_mode, &md_env->md_id),
                       targetid = me->replacing_id,
                       targetos = me->node_os);
     ERROR(OM_stat, msg, "remrepl erase ", wrapup);
     me->replacing_id = NULL_OBJID;
     break;
   }


   case process:
   {
     IGRint            display_count=0, invoke_count=0;  /*DECL*/
     GRobjid           *display_ids=NULL, node_id, active_id;
     IGRushort options;

     dp$erase_hilite(msg = &msg);
     node_id = me->path[me->path_pos];
     ex$message(msgnumb = EMS_I_00003); 
     ex$message(msgnumb = EMS_P_ClearPromptField);
     if (mytype == UNDO)
     {
       options = EMS_DO_DISPLAY | /*Perform the display internally.*/
                 EMS_TEMP_UNDO;   /*Ability to return to original.*/

       OM_stat = om$send(msg = message EMSsurface.EMmake_active_state(&msg,
                               &options, md_env, NULL, NULL,
                               NULL, &display_ids, &display_count,
                               &invoke_count), 
                         targetid = node_id,
                         targetos = me->node_os);
       display_count = 0;
       display_ids = NULL;
       ex$message(msgnumb = EMS_S_ClearStatusField);

       if (COERROR(OM_stat) || COERROR(msg))
       {
         ex$message(msgnumb = EMS_S_IntErrOcc);
         break;    /*BREAKKKKKKKKKKKKKKKKKKKKKKKKKK!!!!!!!!!!!!!*/
       }
       display_mode = GRhhd;
       md_GRid.objid = me->window_id;
       OM_stat = om$send(msg = message GRgraphics.GRdisplay(&msg,
                               &md_env->md_env.matrix_type,
                               md_env->md_env.matrix,
                               &display_mode, &md_GRid),
                         targetid = node_id,
                         targetos = me->node_os);
       ERROR(OM_stat, msg, "hhd freed state", wrapup);
     }
     else if (mytype == EG)
     {
       IGRlong event_size;

       event_size = sizeof(struct GRevent); /* - (sizeof(IGRint) * 2) ;*/
       
       if (edittree_id == NULL_OBJID)
       {
         OM_stat = om$construct(classid=OPP_EMSedittree_class_id,
                                osnum = OM_Gw_current_OS,  /*TRANSIENT OS*/
                                p_objid = &edittree_id);
         ERROR(OM_stat, EMS_S_Success, "construct EMSedittree", wrapup); 
       }

       OM_stat = om$send(msg = message EMSedittree.EMinit(&msg, node_id,
                               me->node_os), 
                         targetid = edittree_id);
       ERROR(OM_stat, msg, "init EMSedittree", wrapup); 

       *response = SPECIFIED_OBJ;
       me->locate_event.subtype = GRst_LOCATE; /*Pick anything but regular*/
       me->locate_event.num_id = 1;
       me->locate_event.located_object[0].located_obj.objid = edittree_id;
       me->locate_event.located_object[0].located_obj.osnum =OM_Gw_current_OS;
                                                              
       OM_stat = ex$putque(msg = &msg, 
                           response = response,
                           byte = &event_size,
                           buffer = (char *)&me->locate_event.event);
       ERROR(OM_stat, msg, "ex$putque", wrapup);
       *response = TERMINATE;
       return(OM_S_SUCCESS);
     }
     else if (mytype == REPLACE)
     {
       if (me->replacing_id == NULL_OBJID)
         ex$message(msgnumb = EMS_S_RemngNd)
       else
         ex$message(msgnumb = EMS_S_ReplcngNd);

       options = EMreplace_DO_DISPLAY; /*Perform efficient display. */
       OM_stat = om$send(msg = message EMSsurface.EMreplace(&msg,
                               me->replacing_id, md_env, 
                               options, &display_ids, &display_count, 
                               &active_id),
                         targetid = node_id,
                         targetos = me->node_os);
       if (COERROR(OM_stat) || COERROR(msg))
       {
          ex$message(msgnumb = EMS_S_IntErrOcc);
         break;
       }
       else if (msg == EMS_I_CantRecompute)
       {
          ex$message(msgnumb = EMS_S_ClearStatusField);
       }

       /*Note:  The following message is necessary to update the gradata
        *       information that got blown away due to possible undo/redo ops.
        *       The update gradata message will be unknown by the composites
        *       and will subsequently be passed on down the to_comps channel
        *       to all surfaces. 
        */
       ex$message(msgnumb = EMS_S_UpdtngGrphcsDtInfo);
       OM_stat = om$send(msg = message EMSsubbs.EMupdateGradata(&msg,
                               &md_env->md_env.matrix_type,
                               md_env->md_env.matrix),
                         targetid = active_id,
                         targetos = me->node_os); 
       ERROR(OM_stat, msg, "gradata update", wrapup);
       ex$message(msgnumb = EMS_I_ProcessingComplete);
     }
     break;
   }
 
 
   case tree_cln:
   {
     if (mytype == UNDO)
     {
       /*Clean up the tree ids that own the path pos id.*/
       ex$message(msgnumb = EMS_P_ClearPromptField);
       ex$message(msgnumb = EMS_S_Processing);

       OM_stat = om$send(msg = message EMSdpr.EMtreecleanup(&msg, md_env),
                         targetid = me->path[me->path_pos+1],
                         targetos = me->node_os);
       ERROR(OM_stat, msg, "EMtreecleanup", wrapup);
       ex$message(msgnumb = EMS_S_ClearStatusField); 
     }

/***FOR NORMAL UNEVALUATION THE USER SHOULD ACCEPT OR REJECT THE UNEVAL.***
     else 
     {
       OM_stat = om$send(msg = message EMSdpr.EMcleanSSI(&msg, md_env, NULL),
                         targetid = me->path[me->path_pos+1],
                         targetos = me->node_os);
       ERROR(OM_stat, msg, "EMcleanSSI", wrapup);
     }
***************************************************************************/

     me->got_path = FALSE;

     if (!gothru)
     {
       if (mytype == UNDO)
       /*Place accept event on the software queue.*/
       OM_stat = ex$putque(msg = &msg, 
                           response = response, 
                           byte = &qsize,
                           buffer = (char *)&me->locate_event.event);
       ERROR(OM_stat, msg, "put que", wrapup);
     }
     else
     {
       gothru = FALSE;
       ME.COconst->action = NIL;
       return (OM_S_SUCCESS);
     }
     break;
   }


   case redo:
   {
     IGRint            display_count=0, invoke_count=0;  /*DECL*/
     GRobjid           *display_ids=NULL;   
     IGRushort options=EMS_DO_DISPLAY;
     
     ex$message(msgnumb = EMS_P_ClearPromptField);
     ex$message(msgnumb = EMS_I_00003);  
   
     OM_stat = om$send(msg = message EMSdpr.EMredo(&msg, &options, md_env,
                             &display_ids, &display_count, &invoke_count),
                       targetid = me->path[me->top+1],
                       targetos = me->node_os);
     ERROR(OM_stat, msg, "EMredo", wrapup);

     ex$message(msgnumb = EMS_S_ClearStatusField);

     display_id = me->path[me->path_pos];
     display_mode = GRhhd;
     stop_id = NULL_OBJID;

     break;
   }


   default:
   {
     ERROR(OM_E_ABORT, EMS_E_Fail, "ECundo action table garbage", wrapup);
   }
  } /*end switch */


  switch(ME.super_cmd->state)
  {
   case start:
   {
     me->got_surface = FALSE;
     me->replacing_id = NULL_OBJID;

     strcpy(attr.classes, "EMSsurface");
     attr.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;

     attr.owner_action = LC_RIGID_COMP | LC_OBJ_W_OWNER; 

     elig_classes.w_count = 1;
     elig_classes.p_classes = &OPP_EMSsubbs_class_id;

     ex$message(msgnumb = EMS_P_AccSfReject, buff = acc_prompt); 
     ex$message(msgnumb = EMS_I_00011, buff = reloc_prompt);

     rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
     rtree_classes.w_count = 1;
     rtree_classes.p_classes = &OPP_EMSsubbs_class_id;

     if (!me->got_path)
     {
       if (mytype == UNDO)
         ex$message(msgnumb = EMS_P_IdntSrfOfTrNdToFr, buff = loc_prompt)
       else if (mytype == REPLACE)
         ex$message(msgnumb = EMS_P_IdntSrfOfTrNdToRplc, buff = loc_prompt)
       else if (mytype == EG)
         ex$message(msgnumb = EMS_P_IdntSrfOfTrNdToLct, buff = loc_prompt);

       locate_mask = GRm_DATA | GRm_BACK_UP;
       display_flag = NO_PROJ_ACCEPT_POINT | ELEM_HILIGHT;
     }
     else
     {
       display_flag = LC_ERASE_LOC_ELEMENT | NO_PROJ_ACCEPT_POINT |  
                      ELEM_HILIGHT | DO_NOT_RELOCATE;
     }

     /*if (mytype == EG) display_flag |= LC_Retrieve_Criteria;*/

     accept_mask = GRm_DATA;   

     /*The following do..while loop has been added to overcome the
      * stupidity of the locate filter.  I do this because it is 
      * currently impossible to get a string event back from locate.
      * It seems that any string event gotten is assumed to be a named
      * locate and if the name is not in the NOD it is assumed to be a 
        command string!!!!!! 
      */ 
     do
     {
       if (me->got_path)  /*For locates AFTER first time.*/
       {
         locate_mask = GRm_DATA | GRm_BACK_UP | GRm_STRING | GRm_RJT_MOVEON;
         ex$message(msgnumb = EMS_P_UDTBRIdntNxtMvOn); 

         token = GRget_token(&msg, Tokens, &locate_mask, &me->locate_event, 
                             &size, response, response_data);
         if (Tokens[token] != DATA)  break;

         /*Place accept event on the software queue.*/
         OM_stat = ex$putque(msg = &msg, 
                             response = response, 
                             byte = &qsize,
                             buffer = (char *)&me->locate_event.event);
         ERROR(OM_stat, msg, "put que", wrapup);

         locate_mask = GRm_DATA;  /*Set up mask for locate.*/
       }

       lc$locate(rc = &eventmsg, 
                 event1 = &me->locate_event, 
                 event2 = &me->locate_event,
                 mask1 = locate_mask, 
                 mask2 = accept_mask, 
                 eventsize= &size, 
                 display_flag = display_flag,
                 unhilight_mode = GRhe,
                 response = response, 
                 response_data = response_data, 
                 locate_prompt = loc_prompt, 
                 acc_prompt = acc_prompt,
                 relocate_prompt = reloc_prompt, 
                 attributes = &attr, 
                 stack = &me->locate_stack, 
                 rtree_classes = &rtree_classes, 
                 eligible_classes = &elig_classes);

       token = GRloc_token(&eventmsg, Tokens, &me->locate_event);

       if (!me->got_path) break;  /*For first time locate.*/
     }
     while(eventmsg == LC_NO_OBJ_LOCATED);

     break;
   }


   case gotnode:
   {
     if (mytype != REPLACE)
     {
       token = 1;  /*Simulate DATA event.*/
       break;
     }

     strcpy(attr.classes, "EMSsurface");
     attr.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
     attr.owner_action = LC_RIGID_OWNER | 
                         LC_ASSOCIATIVE |
                         LC_EXTERN_CONSTRAINED;

     rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
     rtree_classes.w_count = 1;
     rtree_classes.p_classes = &OPP_EMSsubbs_class_id;

     if (EFisAncestryValid(&msg, me->path[me->path_pos], me->node_os,
                           OPP_EMSsolid_class_id, FALSE))
     {
       ex$message(msgnumb = EMS_S_ThReplcngNdMstBeASld);
       elig_classes.p_classes = &OPP_EMSsolid_class_id;
     ex$message(msgnumb = EMS_S_NdNtFndThRplcngNdMstBeSld, buff = reloc_prompt);
     }
     else
     {
       elig_classes.p_classes = &OPP_EMSsurface_class_id;
       ex$message(msgnumb = EMS_S_NdNtFnd, buff = reloc_prompt);
     }
     elig_classes.w_count = 1;

     display_flag = LC_ERASE_LOC_ELEMENT | 
                    NO_PROJ_ACCEPT_POINT |  
                    ELEM_HILIGHT;

     ex$message(msgnumb = EMS_P_IdntRplcngNdMvOnToRm, buff = loc_prompt);
     ex$message(msgnumb = EMS_P_AccptNdOrRjct, buff = acc_prompt);

     locate_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
     accept_mask = GRm_DATA;   

     me->locate_event.located_object[0].located_obj.objid = NULL_OBJID;

     lc$locate(rc = &msg, 
               event1 = &me->locate_event, 
               event2 = &me->locate_event,
               mask1 = locate_mask, 
               mask2 = accept_mask, 
               eventsize= &size, 
               display_flag = display_flag,
               unhilight_mode = GRhe,
               response = response, 
               response_data = response_data, 
               locate_prompt = loc_prompt, 
               acc_prompt = acc_prompt,
               relocate_prompt = reloc_prompt, 
               attributes = &attr, 
               stack = &me->locate_stack, 
               rtree_classes = &rtree_classes, 
               eligible_classes = &elig_classes);
     token = GRloc_token(&msg, Tokens, &me->locate_event);
     break;
   }


   case gotrepl:
   {
     if (mytype != REPLACE || !me->got_surface)
     {
       token = 2; /*Simulate STRING event*/
       break;
     }

     OM_stat = om$send(msg = message EMSsurface.EMshow_normals(&msg, md_env,
                             &me->ActiveDisplay, GRhd),  
                       targetid = me->replacing_id,
                       targetos = me->node_os);
     ERROR(OM_stat, msg, "show norm", wrapup);

     ex$message(msgnumb = EMS_P_CorrectSurfOrnt);

     locate_mask = GRm_STRING | GRm_RJT_MOVEON | GRm_BACK_UP;
     token = GRget_token(&msg, Tokens, &locate_mask, &me->locate_event,
                         &size, response, response_data);
     ex$message(msgnumb = EMS_P_ClearPromptField); 
   
     if (me->locate_event.response == EX_RJT_MOVEON || msg == GRw_no_value)
     {
       /*<CR> or MOVE_ON was given (meaning take default) so pretend user
        * said 'y'.
        */
       me->locate_event.response = STRING;
       *response = STRING;
       strcpy(me->locate_event.event.keyin, "Y");
       strcpy(response_data, "Y");                    
       token = GRloc_token(&msg, Tokens, &me->locate_event);
       msg = EMS_S_Success;
     }
    
     OM_stat = om$send(msg = message EMSsurface.EMshow_normals(&msg, md_env,
                             &me->ActiveDisplay, GRhe),  
                       targetid = me->replacing_id,
                       targetos = me->node_os);
     ERROR(OM_stat, msg, "erase norm", wrapup);

     if (Tokens[token] == STRING)
     {
       if (toupper (me->locate_event.event.keyin[0]) == 'N') 
       {
         OM_stat = om$send(msg = message EMSsurface.EMrevorient(&msg),
                           targetid = me->replacing_id,
                           targetos = me->node_os);
         ERROR(OM_stat, msg, "revornt", wrapup);
       }
     }
     break;
   }


   case shown:
   {
     if (mytype == UNDO)
     {
       ex$message(msgnumb = EMS_S_FrNdIsHlitd);

       ex$message(msgnumb = EMS_P_AccptWthNxtEvntBckToRd);

       locate_mask = GRm_DATA | GRm_BACK_UP;   
       token = GRget_token(&msg, Tokens, &locate_mask, &me->locate_event, 
                           &size, response, response_data);
       ERROR(OM_S_SUCCESS, msg, "get_token", wrapup);

       if (Tokens[token] == GR_UNKNOWN_TYPE)
         gothru = TRUE; 
       else gothru = FALSE;

       dp$erase_hilite(msg = &msg);
       ex$message(msgnumb = EMS_S_ClearStatusField);
     }
     else
     {
       /*Simulate DATA event.*/
       token = 1; 
       gothru = FALSE;
     }     
     break;
   }


   case dummy:
   {
     token = 1; /*Simulate DATA event*/
     break;
   }


   default:
   {
     ERROR(OM_E_ABORT, EMS_E_Fail, "bad state", wrapup);
   }

  }

  ME.COconst->action = NextAction[ME.super_cmd->state][token];
  ME.super_cmd->state = NextState[ME.super_cmd->state][token];

 }
 while ( (Tokens[token] != GR_UNKNOWN_TYPE) || (gothru) );

 return(OM_stat);

 wrapup:
  *response = TERMINATE;
  return (OM_E_ABORT);

}
end implementation ECselundo;
