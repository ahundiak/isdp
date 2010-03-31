class implementation NMdebug;

#define	VtxDisp			0
#define EdVtxuseAssoc 		1
#define	VtxLocate 		2
#define VerboseWarning		3
#define CreateNMtp              4
#define DeleteNMtp              5
#define NMtpPersistent          6

#include "EMS.h"
#if DEBUG
#include <stdio.h>
#endif
# include "griodef.h"
# include "igrtypedef.h"
# include "igrdp.h"
# include "dpstruct.h"
#include "igrdef.h"                     /* Has IGRPY */
#include "ECcmd.h"
#include "ECmsg.h"
#include "NMcmd.h"
#include "NMmsg.h"
#include "exmacros.h"   /* Has ex$putque */
#include "dpmacros.h"   /* Has dp$erase_hilite */
#include "msmacros.h"   /* Has message subsystem macros */
#include "maerr.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSopt.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "OMmacros.h"
#include "emsmapdef.h"
#include "emsimpdef.h"
#include "lcmacros.h"
#include "EMSmsgdef.h"
#include "griomacros.h"    /* co$getevent */
#include "EMSdpb.h"
#include "EMSasopts.h"
#include "emsdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "nmdef.h"
#include "EMSaction.h"
#include "EMSlmdef.h"
#include "go.h"
#include "igr.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "griodef.h"
#include "exdef.h"
#include "nm.h"
#include "nmdef.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "griodef.h"
#include "nddef.h"
#include "ndmacros.h"

extern IGRboolean NMvertex_display_and_Rtree, NMedgevtxuse_assoc, 
		  NMvertex_locatable, NMtp_persistent;
extern OMuint OM_Gf_verbose_warning;


from GRgraphics import GRdelete;
from EMSsurface import EMgetedges, EMputLsIfNotThere;
extern OMuword OPP_EMSsurface_class_id, OPP_EMSsubbs_class_id;


method super_cmd.sleep(int pos)
{
    IGRlong        msg, sts;

    UI_status(" ");
    UI_message(" ");
    UI_prompt(" ");
    sts = dp$erase_hilite(msg = &msg);
    return(OM_S_SUCCESS);
}


method delete(int defer_flag)
{
 IGRlong sts, msg;

 sts = OM_S_SUCCESS;
 sts = dp$erase_hilite(msg = &msg);
 UI_status(" ");
 UI_message(" ");
 UI_prompt(" ");
 sts = om$send(mode = OM_e_wrt_ancestor,
               msg = message Root.delete(1),
               targetid = my_id);
 if (!(1&sts)) return (OM_E_ABORT);

 return (sts);
}

method execute(int *response; char *response_data; int pos)
{

 if(ME.super_cmd->mytype == VtxDisp)
  {
   UI_message("Toggle NM vertex display and R tree");

   NMvertex_display_and_Rtree = !NMvertex_display_and_Rtree;
   if(NMvertex_display_and_Rtree)
     UI_status("NM vertex display enabled for creations hereafter");
   else UI_status("NMvertex display disabled");
   sleep(2);
   UI_status("");
  }
 else if(ME.super_cmd->mytype == EdVtxuseAssoc)
  {
   UI_message("Toggle NM edge/vertexuse associativity");

   NMedgevtxuse_assoc = !NMedgevtxuse_assoc;
   if(NMedgevtxuse_assoc)
     UI_status("NM edge/vertexuse assoc enabled for creations hereafter");
   else UI_status("NM edge/vertexuse assoc disabled");
   sleep(2);
   UI_status("");
  }
 else if(ME.super_cmd->mytype == VtxLocate)
  {
   UI_message("Toggle NM vertex locate");

   NMvertex_locatable = !NMvertex_locatable;
   if(NMvertex_locatable)
     UI_status("NM vertices in R-tree now locatable");
   else UI_status("NMvertex locate disabled");
   sleep(2);
   UI_status("");
  }
 else if(ME.super_cmd->mytype == VerboseWarning)
  {
   UI_message("Toggle Verbose warning flag");

   OM_Gf_verbose_warning = !OM_Gf_verbose_warning;
   if(OM_Gf_verbose_warning)
     UI_status("Verbose warning is now ON");
   else UI_status("Verbose warning is now OFF");
   sleep(2);
   UI_status("");
  }
 else if(ME.super_cmd->mytype == NMtpPersistent)
  {
   UI_message("Toggle NMtp persistent flag");

   NMtp_persistent = !NMtp_persistent;
   if(NMtp_persistent)
     UI_status("NMtp object will remain even if no children");
   else UI_status("NMtp object without children will be deleted");
   sleep(2);
   UI_status("");
  }
 else if( (ME.super_cmd->mytype == CreateNMtp) ||
          (ME.super_cmd->mytype == DeleteNMtp))
  {
   IGRint         size, object_was_located, display_flag, sts;
   IGRint         locate_mask, accept_mask;
   struct GRevent accept_event;
   OMuword                     rclass, eliclass;
   OM_S_CLASSLIST              rtree_classes, elig_classes;
   struct GRlc_locate attributes;
   struct GRid modelid, nmtpid;
   struct GRmd_env *modelenv;
   IGRchar outstr[254];
   struct GRvg_construct construct;
   IGRlong msg;

   size = sizeof(struct GRevent);

   if(ME.super_cmd->mytype == CreateNMtp)
    UI_message("Create NM topology");
   else
    UI_message("Delete NM topology");
   do
    {
     sts = dp$erase_hilite(msg = &msg);

     locate_mask = GRm_DATA;
     accept_mask = GRm_DATA;
     attributes.properties   = LC_LC_ONLY | LC_DP_ONLY | LC_RW |
                               IGN_MOD_BIT | IGN_PLANAR_BIT;
    attributes.owner_action = 
     LC_ASSOCIATIVE     |       /* Associative elements */
     LC_EXTERN_CONSTRAINED |    /* Externally constrained assoc elements */
     LC_RIGID_OWNER     |       /* Composites */
     LC_RIGID_COMP      |       /* Components of composites */
     LC_FLEX_OWNER      |       /* Graphic groups, etc. */
     LC_FLEX_COMP       |       /* Members of graphic groups, etc. */
     LC_REF_OBJECTS     |       /* Objects in ref. files are allowed */
     LC_NO_REF_HEADER;          /* No reference file headers */

     strcpy(attributes.classes, "EMSsurface");
     display_flag = ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                      LC_ERASE_LOC_ELEMENT;

     rtree_classes.w_count = elig_classes.w_count = 1;
     rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
     rclass = OPP_EMSsubbs_class_id;
     eliclass = OPP_EMSsurface_class_id;
     rtree_classes.p_classes = &rclass;
     elig_classes.p_classes = &eliclass;

      sts = lc$locate(rc = &object_was_located, 
            event1 = &me->locate_event,
            event2 = &accept_event,
            mask1 = locate_mask, 
            mask2 = accept_mask, 
            eventsize= &size, 
            display_flag = display_flag,
            response = response, 
            response_data = response_data, 
            locate_key = EMS_P_IdSfSl, 
            acc_key = EMS_P_00038, 	/* Accept/reject */
            relocate_key = EMS_P_ElementNotFound, 
            attributes = &attributes,
            stack = &me->locate_stack, 
            rtree_classes = &rtree_classes, 
            eligible_classes = &elig_classes);
       
     if(!object_was_located)
      return(OM_S_SUCCESS);
     else
      {
       IGRlong junk;

       modelid = accept_event.located_object[0].located_obj;
       modelenv = &accept_event.located_object[0].module_info;

       sts = om$send(msg = message EMSsurface.EMputLsIfNotThere(&msg, 
             &modelenv->md_env, NULL, NULL, NULL, NULL), 
             targetid = modelid.objid, targetos = modelid.osnum);
       if(!(1&msg&sts)) return(OM_E_ABORT);

       construct.msg = &junk;
       construct.env_info = modelenv;
       construct.newflag = FALSE;
       construct.geometry = NULL;
       construct.class_attr = NULL;
       construct.level = ME.CObuild->ActiveLevel;
       construct.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
       construct.display = &ME.CObuild->ActiveDisplay;
       construct.name = NULL;

       if(ME.super_cmd->mytype == CreateNMtp)
        {
         sts = NMcreate_mesh_topology(&msg, &accept_event.located_object[0]);
         if(!(1&msg&sts)) return(OM_E_ABORT);

	 nmtpid.objid = NULL_OBJID;
	 sts = NMcreate_nmtp(&msg, &modelid, modelenv, &nmtpid, NULL, 
	       NMcrtnmtp_QueryOnly, &construct);
         if(!(1&msg&sts)) return(OM_E_ABORT);
         if(IF_NULL_OBJID(nmtpid.objid))
          UI_status("NM topology object not found");
         else
          {
           sprintf(outstr, "NM topology created, NMtpid = %d.%d", 
                   nmtpid.osnum, nmtpid.objid);
           UI_status(outstr);
          }
        }
       else
        {
	 nmtpid.objid = NULL_OBJID;
	 sts = NMcreate_nmtp(&msg, &modelid, modelenv, &nmtpid, NULL, 
	       NMcrtnmtp_QueryOnly, &construct);
         if(!(1&msg&sts)) return(OM_E_ABORT);
         if(IF_NULL_OBJID(nmtpid.objid))
          UI_status("NM topology object not found");
         else
          {
           sprintf(outstr, "NM topology object found, NMtpid = %d.%d", 
                   nmtpid.osnum, nmtpid.objid);
           UI_status(outstr);
           locate_mask = GRm_STRING;
           accept_mask = GRm_STRING;
           sts = co$getevent(msg = &object_was_located, 
                 event_mask = locate_mask, 
                 prompt = "Delete? (y/n) [n]", response = response, 
                 response_data = response_data, event = &accept_event);
           UI_status(" ");
           if(!(1&sts)) return(OM_E_ABORT);
           if( (accept_event.response == STRING) &&
               (toupper (accept_event.event.keyin[0]) == 'Y'))
            {
	     sts = om$send(msg = message GRgraphics.GRdelete(&msg, modelenv), 
	           targetid = nmtpid.objid, targetos = nmtpid.osnum);
             if(!(1&sts)) return(OM_E_ABORT);
             nd$exec_batch();
             UI_status("Its gone, its outta here!");
            }
          }
        }

      } /* if(object_was_located) */

    } while(TRUE);

  }
 else 
  {
   UI_status("Invalid option - check command table");
   sleep(2);
  }

 *response = TERMINATE;
 return(OM_S_SUCCESS);
}

end implementation NMdebug;
