class implementation NMshowglue;

#include <stdio.h>
#include "codef.h"
#include "ECdlb.h"
#include "igr.h"
#include "igrtypedef.h"
#include "griodef.h"
#include "exdef.h"
#include "EMSmsgdef.h"
#include "emsbool.h"
#include "emssfintdef.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "OMmacros.h"
#include "griomacros.h"
#include "grdpbmacros.h"
#include "lcmacros.h"
#include "EMSopt.h"
#include "EMSlogic.h"
#include "EMScmacros.h"
#include "EMSaction.h"                  /* Locate action handler */
#include "msmacros.h"   /* ex$message */
#include "emsdef.h"
#include "OMmacros.h"
#include "ECprepsf.h"
#include "nmdef.h"
#include "ECcmd.h"
#include "ECmsg.h"

#include "NMcmd.h"
#include "NMmsg.h"

#define StaticBuf 10

#include "EMStypedef.h"

from GRgraphics   import GRdisplay, GRdelete;

extern OMuword OPP_EMSsubbs_class_id,
               OPP_EMSsurface_class_id,
	       OPP_EMSedge_class_id;
	

/* States.
*/
#define LOCATE_EDGE	0
#define SHOW_SURFS	1


/* Mytypes.
*/
#define SHOW_GLUE_SURFS	0
#define SHOW_GLUE_SURFS_DBG  1

extern IGRboolean EFedge_curves_locatable();
static void localMsg ();

method init (IGRint type; IGRchar *string)
{
 IGRint sts=OM_S_SUCCESS;
 IGRlong msg=EMS_S_Success;

 sts = om$send(mode = OM_e_wrt_message, 
	       msg = message ECelement.init(type, string), 
	       targetid = my_id);
 ERROR(sts, msg, "ECelement.init", wrapup);

 /* Save current dpb flag in my instance data.
 */
 me->dpb_edge_locate_flag = EFedge_curves_locatable();

 /* Set edge locate ON
 */
 if(!me->dpb_edge_locate_flag)
  EFset_locate_eligibility(&msg, 1, "EMSedge");

wrapup:
 return(sts);
}

method wakeup(int pos)
{
 IGRint sts=OM_S_SUCCESS;
 IGRlong msg=EMS_S_Success;
 
 sts = om$send(mode = OM_e_wrt_message, 
	       msg = message ECelement.wakeup(pos), 
	       targetid = my_id);
 ERROR(sts, msg, "ECelement.wakeup", wrapup);

 /* Save current dpb flag in my instance data.
 */
 me->dpb_edge_locate_flag = EFedge_curves_locatable();

 /* Set edge locate ON.
 */
 if(!me->dpb_edge_locate_flag)
  EFset_locate_eligibility(&msg, 1, "EMSedge");

 wrapup:
  return(sts);
}


method super_cmd.sleep(int pos)
{
 IGRint sts=OM_S_SUCCESS;
 IGRlong msg=EMS_S_Success;


 sts = om$send(mode = OM_e_wrt_message, 
	       msg = message ECelement.sleep(pos), 
	       targetid = my_id);
 ERROR(sts, msg, "ECelement.sleep", wrapup);

 dp$erase_hilite(msg = &msg);

 localMsg (EM_M_ClearMessageField);

 localMsg (EMS_P_ClearPromptField);

 if(me->dpb_edge_locate_flag)
  EFset_locate_eligibility(&msg, 1, "EMSedge");
 else
  EFset_locate_eligibility(&msg, 0, "EMSedge");

 wrapup:
  return(sts);
}


method delete(int f_defer_flag)
{
  IGRint sts;
  IGRlong msg;

  if(me->dpb_edge_locate_flag)
   EFset_locate_eligibility(&msg, 1, "EMSedge");
  else
   EFset_locate_eligibility(&msg, 0, "EMSedge");

  dp$erase_hilite(msg = &msg);

  sts = om$send(mode = OM_e_wrt_message,
                msg = message ECelement.delete(NULL),
                targetid = my_id);
  ERROR(sts, EMS_S_Success, "ECelement delete", wrapup);

 wrapup:
  return(sts);
}


method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
 enum           GRdpmode DisplayMode;
 IGRint         size, object_was_located, display_flag, sts;
 IGRint         locate_mask, accept_mask, i;
 struct GRevent accept_event;
  OMuword                     rclass, eliclass;
  OM_S_CLASSLIST              rtree_classes, elig_classes;
 struct GRlc_locate attributes;
 extern      IGRlong EFlocate_action_handler();
 struct      EMSaction_handler was_located;
 IGRlong     msg;

 size = sizeof(struct GRevent);
 if(me->mytype == SHOW_GLUE_SURFS)
  {
   ex$message(msgnumb = NMC_M_ShowSurfsGluedAlongEdge);
  }
 else 
  UI_message("Show surfaces glued along an edge - debug");

 do
  {
   switch(me->state)
    {
     case LOCATE_EDGE:
      locate_mask = GRm_DATA;
      accept_mask = GRm_DATA;
      attributes.properties   = LC_LC_ONLY | LC_DP_ONLY | LC_RW |
                                LC_PLANAR_NON_PLANAR;
      attributes.owner_action = LC_RIGID_COMP  |
                                LC_OBJ_W_OWNER | 
                                LC_REF_OBJECTS |
                                LC_NO_REF_HEADER;
      strcpy(attributes.classes, "EMSsurface");
      display_flag = ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                      LC_ERASE_LOC_ELEMENT;

      /* The option field has been set to 6 for locating edges. This
         has been done to pass the information to edge level and do 
         the filtration of located edges there itself.
      */ 

      was_located.next = NULL;
      was_located.option = LOCATE_EDGE;
      was_located.type = 2;
      was_located.num_objects = 0;

      rtree_classes.w_count = elig_classes.w_count = 1;
      rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
      rclass = OPP_EMSsurface_class_id;
      eliclass = OPP_EMSedge_class_id;
      rtree_classes.p_classes = &rclass;
      elig_classes.p_classes = &eliclass;

      sts = lc$locate(rc = &object_was_located, 
            event1 = &me->locev,
            event2 = &accept_event,
            mask1 = locate_mask, 
            mask2 = accept_mask, 
            eventsize= &size, 
            display_flag = display_flag,
            response = response, 
            response_data = response_data, 
            locate_key = NM_P_IdentifyEdge, 
            acc_key = EMS_P_00038, 	/* Accept/reject */
            relocate_key = NM_I_EdgeNotFound, 
            attributes = &attributes,
            act_handler = EFlocate_action_handler,
            act_args = &was_located,
            stack = &me->locate_stack, 
            rtree_classes = &rtree_classes, 
            eligible_classes = &elig_classes);
       
      if(!object_was_located)
       return(OM_S_SUCCESS);
      else
       {
	me->elem = accept_event.located_object[0];
	me->state = SHOW_SURFS;
       }

     break;

     case SHOW_SURFS:
      {
       struct GRid *mates = NULL, *edgeid, nmedge, *sfids = NULL;
       struct GRmd_env *edgeenv;
       IGRint nummates = 0;
       unsigned int nmquery_opt = NMquery_ConsiderExternalToModel;

       edgeid = &me->elem.located_obj;
       edgeenv = &me->elem.module_info;
       nmedge.objid = NULL_OBJID;
       sts = NMget_edge_mates(&msg, edgeid, &nummates, &mates, NULL, NULL, 
	     NULL, &nmedge, nmquery_opt, NULL, NULL);
       ERROR(sts, msg, "NMshowglue - NMget_edge_mates", wrapup);

       if(!nummates)
        {
	 ex$message(msgnumb = NM_I_NoSurfsGluedAlongEdge);
	 me->state = LOCATE_EDGE;
	 break;
        }

       /* Collect all the surfaces to be hilighted.
       */
       sfids = (struct GRid *) om$malloc(size = nummates * 
		sizeof(struct GRid));
       if(!sfids)
        {
         ERROR(sts, EMS_E_NoDynamicMemory, "NMshowglue malloc for sf", wrapup);
        }
       for(i=0; i<nummates; i++)
        {
	 sts = NMfind_sf_no_matter_what(&msg, &mates[i], &sfids[i], NULL, 
	       NULL);
	 ERROR(sts, msg, "NMshowglue find sf", wrapup);
        }

       /* Hilight all the surfaces.
       */
       DisplayMode = GRhd;
       for(i=0; i<nummates; i++)
        {
	 sts = om$send(msg = message GRgraphics.GRdisplay(&msg, 
	       &edgeenv->md_env.matrix_type, edgeenv->md_env.matrix, 
	       &DisplayMode, &edgeenv->md_id), targetid = sfids[i].objid, 
	       targetos = sfids[i].osnum);
	 ERROR(sts, msg, "NMshowglue hilite sf", wrapup);	
        }
       if( (me->mytype == SHOW_GLUE_SURFS_DBG) && 
	   (!IF_NULL_OBJID(nmedge.objid)))
	{
         ex$message(msgnumb = NM_I_GluedSurfsHilitedDbg, 
		    var = nmedge.objid, type = "%d");
	}
       else
        {
         ex$message(msgnumb = NM_I_GluedSurfsHilited);
        }

       locate_mask = GRm_DATA | GRm_RJT_MOVEON;
       sts = co$getevent (msg = &msg, event_mask = locate_mask,
             msgnum = NM_P_DataMvOnForNextEdge, 
             response = response,
             response_data = response_data,
             event = &accept_event);
       localMsg (EMS_P_ClearPromptField);
       localMsg (EMS_I_ClearStatusField);

       dp$erase_hilite(msg = &msg);

       me->state = LOCATE_EDGE;
       if(mates) om$dealloc(ptr = mates);
       if(sfids) om$dealloc(ptr = sfids);
      }
     break;

     default:
      {
       ERROR(OM_E_ABORT, EMS_E_Fail, "NMshowglue_exec state garbage", wrapup);
       break;
      }
    }

  }while(TRUE);

 return(sts);

 wrapup:
  *response = TERMINATE;
  return(OM_E_ABORT);

}



static void localMsg (msgnumb)
IGRlong msgnumb;
{
    ex$message (msgnumb = msgnumb);

    return;
}

end implementation NMshowglue;
