/*

Name
  EC2elecnstr.execute

Abstract

Synopsis

Description
  This command object is written to place constraints between 2 objects.
  The constraints placed are parallel, perpendicular, coincident and pt-on-element.
  Both VG and 3D constraints are supported.
  
Return Value

Notes
  KNOWN BUG:
    The 3D perpendicular constraint allows the locate of LC_HANDLES to locate
    reference planes.  This has a side-effect of allowing the locate of 
    dimensioning lines and other constraint handles.
    
Index

Keywords
  profile, constraints
  
History
  ???????? : ?????          : created
  05/12/93 : Rajiv Agrawal  : Added handling of a regular point in case of a 3D coincident
                              constraint. (TR#11925037)
  08/04/93 : GMK            : Disallow same point selection in Coincident constraint (TR119301583).
                              Add backup option while selecting second element. (TR119301586).
  10/15/93 : GMK            : clearing the locate_stack, if it contains the SKptvars
  11/03/93 : HGB            : don't locate B-splines for parallel constraints.
  11/29/93 : Rajiv Agrawal  : changed SKline to GRlineseg to fix a regression caused by
                              Henry's fix. (TR#119313317)
  12/29/93 : Rajiv Agrawal  : Prevent selection of the same point thru a tentative snap for 
                              Coincident constraint.
  01/10/94 : Rajiv Agrawal  : Changed the eligible classes for a 3D pt-on-element 
                              constraint (TR#119415547). 
 */
class implementation EC2elecnstr;

#include "SKdef.h"
#include "SKinc.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSasdef.h"
#include "EMSas.h"
#include "EMSasopts.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "ECcmd.h"
#include "grimport.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMindex.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "dp.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "dpstruct.h"
#include "lcpriv.h"
#include "emsdef.h"

#include "madef.h"
#include "maidmx.h"

#define PARALLEL_CMD      0
#define PERPENDICULAR_CMD 1
#define COINCIDENT_CMD    2
#define PTELEMENT_CMD     3

#define LOCATE_PARMELE    0
#define LOCATE_ELE        1
#define LOCATE_COINC_PT  15
#define PROCESS_PARAMGM   2
#define PROCESS_VGCNSTR   3

#define X 0
#define Y 1
#define Z 2

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;
/*
 * _grids_equal(a,b) compares two GRids strucutures (a and b) for equality
 */
#define _grids_equal(a,b)  (( a.osnum == b.osnum ) && ( a.objid == b.objid ))

extern GRclassid OPP_GRvg_class_id, OPP_GRcurve_class_id;
extern GRclassid OPP_GRbspline_class_id, OPP_GRpoint_class_id;
extern GRclassid OPP_GRlineseg_class_id, OPP_GRcirarc_class_id;
extern GRclassid OPP_GRcircle_class_id;
extern GRclassid OPP_SKline_class_id, OPP_SKptvar_class_id;
extern GRclassid OPP_EMSparamgm_class_id, OPP_SKdumpt_class_id;
extern GRclassid OPP_EMSparamvc_class_id, OPP_EMSparampt_class_id;
extern GRclassid OPP_SKparallel_class_id, OPP_SKnormal_class_id;
extern GRclassid OPP_SKcoincident_class_id, OPP_SKhorizvert_class_id;
extern GRclassid OPP_SKptonelmt_class_id;
extern GRclassid OPP_EMSparvcnstr_class_id, OPP_EMSpervcnstr_class_id;
extern GRclassid OPP_EMSasptcnstr_class_id, OPP_EMSptelcnstr_class_id;
extern GRclassid OPP_EMSdatpln_class_id;
extern GRclassid OPP_EMSsubbs_class_id;

from GRgraphics   import GRdisplay, GRdelete;
from EMScnstr 	  import EMinit, EMvalidate;
from SKconstraint import SKinit, SKvalidate, SKgetmgr;
from SKdumpt      import SKget_origin_id;

static IGRboolean aflag;

method init (int type; char *string)
{
  me->state = 0;
  me->mytype = type;
  me->locate_stack.num_entries = 0;

  return (OM_S_SUCCESS);
}

method wakeup (int pos)
{
  int bytes_in, bytes_out;
  long msg_loc, stat_OM;

  stat_OM = OM_S_SUCCESS;
  msg_loc = EMS_S_Success;

  UI_prompt ("");

  aflag = pwIsActivationOn();
  if (aflag)
  {
    pwGetActiveModuleEnv(&me->active_md_env);
  }
  else
  {
  bytes_in = sizeof (struct GRmd_env);
  gr$get_module_env (msg = &msg_loc, sizbuf = &bytes_in, 
      buffer = &me->active_md_env, nret = &bytes_out);
  EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
  }

  dp$erase_hilite (msg = &msg_loc);

ret_end:
  return (OM_S_SUCCESS);
}

method execute (int *response; char *response_data; int pos)
{
  IGRboolean 		putq, val_cnstr, stat_func, is_vg, chkcycle;
  char 			locate_prompt[GR_MAX_CHAR], accept_prompt[GR_MAX_CHAR];
  char 			relocate_prompt[GR_MAX_CHAR];
  char 			*cnstrinfo;
  unsigned short 	cnstrprops;
  int 			i, num_vgpts, eventsize, num_conflict_cnstr, count, 
                        cmdtype, subtype, 
			batch_mode, comp_type, num_aspt_parents;
  long 			val_msg_loc, send_rc, msg_loc, stat_OM;
  long 			display_flag, locate_mask, accept_mask;
  long 			object_was_located;
  GRclassid 		rclass[3], eliclass[3], classid, cnstrclass;
  GRobjid 		vgpts[4], *conflict_cnstr_objs;
  struct GRmd_env 	*env;
  struct GRid 		cnstr_grid, mgrid, conflict_cnstr_ids[3], *parmele, *ele;
  struct GRid 		aspt_parents[2];
  struct GRlc_locate 	attributes;
  struct GRevent 	accept_event, *ev, *locev;
  struct EMSasptinfo 	asptinfo;
  struct EMSnrminfo 	nrminfo;
  struct SKptonelmt_info ptonelmt_info;
  OM_S_CLASSLIST 	rtree_classes, elig_classes;
  OM_S_CHANSELECT 	chan_to_defpts;

  OM_S_OBJECT_LINKAGE 	objlist[2];
  struct SKlocate_action_args action_args;      /* arguments for the action handler --GMK*/
  extern IGRint         ECaction_handler ();


  stat_OM = OM_S_SUCCESS;

  conflict_cnstr_objs = NULL;

  cmdtype = me->mytype;

  if (cmdtype == PARALLEL_CMD)
  {
    ex$message (msgnumb = EM_M_PlaceParallelConstraint);
  }
  else if (cmdtype == PERPENDICULAR_CMD)
  {
    ex$message (msgnumb = EM_M_PlacePerpendicularConstraint);
  }
  else if (cmdtype == COINCIDENT_CMD)
  {
    ex$message (msgnumb = EM_M_PlaceCoincidentConstraint);
  }
  else if (cmdtype == PTELEMENT_CMD)
  {
    ex$message (msgnumb = EM_M_PlacePointOnElementConstraint);
  }

  /*
   * if locate stack contains the SKptvars, make stack entries to ZERO.
   * it starts the locate process again, this is because of locate does't know
   * display and locate of SKptvars -- GMK 10/15/93
   */
  if ( ME.EC2elecnstr->locate_stack.num_entries )
  {
    parmele = &ME.EC2elecnstr->locate_stack.entry[0].located_obj;
    om$get_classid (objid = parmele->objid, osnum = parmele->osnum,
                          p_classid = &classid);
    if ( classid == OPP_SKptvar_class_id )
      ME.EC2elecnstr->locate_stack.num_entries = 0;
    parmele = NULL;
  }

  eventsize = sizeof (struct GRevent);
  env = &me->active_md_env;

  do
  {
    switch (me->state)
    {
    case LOCATE_PARMELE:
      display_flag = ALL_WINDOWS | ELEM_HILIGHT;
      locate_mask = GRm_DATA | GRm_BACK_UP;
      accept_mask = GRm_DATA;

      if (cmdtype == PARALLEL_CMD)
      {
        ex$message (buff = locate_prompt,
            msgnumb = EMS_P_IdentifyAssociativeLine);
        ex$message (buff = accept_prompt,
            msgnumb = EMS_P_AcceptWithParallel);
        ex$message (buff = relocate_prompt,
            msgnumb = EMS_P_LineNotFound);

        elig_classes.w_count = 2;
        eliclass[0] = OPP_SKline_class_id;
        eliclass[1] = OPP_EMSparamvc_class_id;
        elig_classes.w_flags = OM_CLST_subclass;
        elig_classes.p_classes = eliclass;
      }
      else if (cmdtype == PERPENDICULAR_CMD)
      {
        ex$message (buff = locate_prompt,
            msgnumb = EMS_P_IdentifyAssociativeLine );
        ex$message (buff = accept_prompt,
            msgnumb = EMS_P_AcceptWithPerpendicular);
        ex$message (buff = relocate_prompt,
            msgnumb = EMS_P_LineNotFound)

        elig_classes.w_count = 2;
        eliclass[0] = OPP_SKline_class_id;
        eliclass[1] = OPP_EMSparamvc_class_id;
        elig_classes.w_flags = OM_CLST_subclass;
        elig_classes.p_classes = eliclass;
      }
      else if (cmdtype == COINCIDENT_CMD)
      {
        ex$message (buff = locate_prompt,
            msgnumb = EMS_P_IdentifyAssociativePoint);
        ex$message (buff = accept_prompt,
            msgnumb = EMS_P_AcceptReject);
        ex$message (buff = relocate_prompt,
            msgnumb = EMS_P_PointNotFound);

        elig_classes.w_count = 2;
        eliclass[0] = OPP_SKptvar_class_id;
        eliclass[1] = OPP_EMSparampt_class_id;
        elig_classes.w_flags = OM_CLST_subclass;
        elig_classes.p_classes = eliclass;
      }
      else if (cmdtype == PTELEMENT_CMD)
      {
        ex$message (buff = locate_prompt,
            msgnumb = EMS_P_IdentifyAssociativePoint);
        ex$message (buff = accept_prompt,
            msgnumb = EMS_P_AcceptWithElement);
        ex$message (buff = relocate_prompt,
            msgnumb = EMS_P_PointNotFound);

        elig_classes.w_count = 2;
        eliclass[0] = OPP_SKptvar_class_id;
        eliclass[1] = OPP_EMSparampt_class_id;
        elig_classes.w_flags = OM_CLST_subclass;
        elig_classes.p_classes = eliclass;
      }

      rtree_classes.w_count = 1;
      rclass[0] = OPP_GRvg_class_id;
      rtree_classes.w_flags = OM_CLST_subclass;
      rtree_classes.p_classes = rclass;

      aflag = pwIsActivationOn();
      if (aflag)
      {
      attributes.properties = LC_LC_ONLY | LC_DP_ONLY;
                              /* | LC_WRITE_ONLY; - removed for RFA */

      attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP |
          LC_NO_REF_HEADER | LC_REF_OBJECTS; /*added REF_OBJ for RFA */
      }
      else
      {
      attributes.properties = LC_LC_ONLY | LC_DP_ONLY |
                              LC_WRITE_ONLY; 

      attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP |
          LC_NO_REF_HEADER;
      }
      
  if(aflag = pwIsActivationOn())
     {
      extern long RFlocate_cons_acthndlr();
      GRspacenum  osn;

      osn = pwGetActiveOs();
      lc$locate ( rc = &object_was_located,
                  event1 = &me->locate_event,
                  event2 = &accept_event,
                  mask1 = locate_mask,
                  mask2 = accept_mask,
                  eventsize= &eventsize,
                  display_flag = display_flag,
                  response = response,
                  response_data = response_data,
                  locate_prompt = locate_prompt,
                  acc_prompt = accept_prompt,
                  relocate_prompt = relocate_prompt,
                  attributes = &attributes,
                  stack = &me->locate_stack,
                  act_handler = RFlocate_cons_acthndlr,
                  act_args    = &osn,
                  rtree_classes = &rtree_classes,   
                  eligible_classes = &elig_classes);
     }
    else
     {

      lc$locate ( rc = &object_was_located,
                  event1 = &me->locate_event, 
                  event2 = &accept_event,
                  mask1 = locate_mask, 
                  mask2 = accept_mask,
                  eventsize= &eventsize, 
                  display_flag = display_flag,
                  response = response, 
                  response_data = response_data, 
                  locate_prompt = locate_prompt, 
                  acc_prompt = accept_prompt,
                  relocate_prompt = relocate_prompt, 
                  attributes = &attributes, 
                  stack = &me->locate_stack, 
                  rtree_classes = &rtree_classes, 
                  eligible_classes = &elig_classes);
      }

      if (!object_was_located)
        goto ret_end;
      else
      {
        me->parmele = accept_event.located_object[0];

        parmele = &accept_event.located_object[0].located_obj;
        om$get_classid (objid = parmele->objid, osnum = parmele->osnum,
            p_classid = &classid);
        if (cmdtype == COINCIDENT_CMD)
          putq = FALSE;
        else 
          if (om$is_ancestry_valid (subclassid = classid,
              superclassid = OPP_SKptvar_class_id) == OM_S_SUCCESS)
            putq = TRUE;
          else
          {
            locev = &me->locate_event;
            if (locev->response == EX_OBJID ||
                (locev->subtype != GRst_REGULAR &&
                accept_event.num_id &&
                locev->located_object[0].located_obj.objid ==
                accept_event.located_object[0].located_obj.objid))
              putq = FALSE;
            else
              putq = TRUE;
          }

        if (putq)
          ex$putque (msg = &msg_loc, response = response,
                     byte = (long *) &eventsize, 
                     buffer = (char *) &accept_event.event);

        if (cmdtype == COINCIDENT_CMD)
          me->state = LOCATE_COINC_PT;
        else 
          me->state = LOCATE_ELE;
      }
      break;

    case LOCATE_COINC_PT:
      ex$message ( msgnumb = EMS_P_IdentifyCoincidentPoint );
      accept_mask = GRm_DATA | GRm_BACK_UP;
      stat_func = co$getevent (msg = &msg_loc, event_mask = accept_mask,
          response = response, response_data = response_data,
          event = &accept_event);
      EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
      UI_prompt ("");

      switch (accept_event.response)
      {
      case EX_BACK_UP:
        dp$erase_hilite (msg = &msg_loc);
        me->state = LOCATE_PARMELE;
        break;

      case EX_DATA:
        parmele = &me->parmele.located_obj;
        om$get_classid (objid = parmele->objid, osnum = parmele->osnum,
            p_classid = &classid);
        if (om$is_ancestry_valid (subclassid = classid,
            superclassid = OPP_EMSparamgm_class_id) == OM_S_SUCCESS)
          is_vg = FALSE;
        else 
          is_vg = TRUE;

        if (!EMptsubtype_supported (&accept_event))
        {
          ex$putque (msg = &msg_loc, response = response,
                     byte = (long *) &eventsize, 
                     buffer = (char *) &accept_event.event);

          display_flag = ALL_WINDOWS | ELEM_HILIGHT | DO_NOT_RELOCATE;
          locate_mask = GRm_DATA;
          accept_mask = GRm_DATA;

          ex$message (buff = locate_prompt,
              msgnumb = EMS_P_IdentifyCoincidentPoint);
          ex$message (buff = accept_prompt,
              msgnumb = EMS_P_AcceptReject);
          ex$message (buff = relocate_prompt,
              msgnumb = EMS_P_PointNotFound);

          if (is_vg)
          {
            elig_classes.w_count = 2;
            eliclass[0] = OPP_SKptvar_class_id;
            eliclass[1] = OPP_GRpoint_class_id;
          }
          else
          {
            elig_classes.w_count = 1;
            eliclass[0] = OPP_GRpoint_class_id;
          }
          elig_classes.w_flags = OM_CLST_subclass;
          elig_classes.p_classes = eliclass;

          rtree_classes.w_count = 1;
          rclass[0] = OPP_GRbspline_class_id;
          rtree_classes.w_flags = OM_CLST_subclass;
          rtree_classes.p_classes = rclass;

          attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;

          aflag = pwIsActivationOn();
          if (aflag)
          {
          attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP | 
                 LC_NO_REF_HEADER | LC_REF_OBJECTS; /*added REF_OBJ for RFA*/
          }
          else
          {
          attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP | 
                                    LC_NO_REF_HEADER;
          }

          /* argument for action handler  --GMK */
          action_args.selected_object =  &me->parmele.located_obj;


          lc$locate ( rc = &object_was_located,
                      event1 = &me->locate_event,
                      event2 = &accept_event, 
                      mask1 = locate_mask, 
                      mask2 = accept_mask,
                      eventsize= &eventsize, 
                      display_flag = display_flag,
                      response = response, 
                      response_data = response_data, 
                      locate_prompt = locate_prompt, 
                      act_handler = ECaction_handler,
                      act_args = (char *)(&action_args),
                      acc_prompt = accept_prompt,
                      relocate_prompt = relocate_prompt, 
                      attributes = &attributes, 
                      stack = &me->locate_stack, 
                      rtree_classes = &rtree_classes, 
                      eligible_classes = &elig_classes);

          if (object_was_located)
          {
            me->ele = accept_event.located_object[0];
            if (is_vg)
              me->state = PROCESS_VGCNSTR;
            else
            {
              me->ele_event = accept_event;
              me->state = PROCESS_PARAMGM;
            }
          }
          else
          {
            ex$message (msgnumb = EMS_S_PointNotFound);
          }
        }
        else
        {
          me->ele.located_obj.objid = NULL_OBJID;
          me->ele_event = accept_event;
          if (is_vg)
            me->state = PROCESS_VGCNSTR;
          else
            me->state = PROCESS_PARAMGM;
        }
        break;

      default:
        goto ret_end;
      }
      break;

    case LOCATE_ELE:
      display_flag = ALL_WINDOWS | ELEM_HILIGHT;
      locate_mask = GRm_DATA | GRm_BACK_UP;
      accept_mask = GRm_DATA;
      rtree_classes.w_count = 1;
      rclass[0] = OPP_GRbspline_class_id;
      rtree_classes.w_flags = OM_CLST_subclass;
      rtree_classes.p_classes = rclass;

      attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
      aflag = pwIsActivationOn();
      if (aflag)
      {
      attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP | 
                                LC_NO_REF_HEADER | LC_REF_OBJECTS; 
                                                 /* added REF_OBJ for RFA */
      }
      else
      {
      attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP | 
                                LC_NO_REF_HEADER; 
      }

      if (cmdtype == PARALLEL_CMD)
      {
        ex$message (buff = locate_prompt,
            msgnumb = EMS_P_IdentifyLineParallelTo);
        ex$message (buff = accept_prompt,
            msgnumb = EMS_P_AcceptReject);
        ex$message (buff = relocate_prompt,
            msgnumb = EMS_P_LineNotFound);

        elig_classes.w_count = 2;
        eliclass[0] = OPP_GRlineseg_class_id;
        eliclass[1] = OPP_EMSparamvc_class_id;
        elig_classes.w_flags = OM_CLST_subclass;
        elig_classes.p_classes = eliclass;
      }
      else if (cmdtype == PERPENDICULAR_CMD)
      {
        ex$message (buff = locate_prompt,
            msgnumb = EMS_P_IdentifyPerpendicularTo);
        ex$message (buff = accept_prompt,
            msgnumb = EMS_P_AcceptReject);
        ex$message (buff = relocate_prompt,
            msgnumb = EMS_P_ElementNotFound);

        parmele = &accept_event.located_object[0].located_obj;
        om$get_classid (objid = parmele->objid, osnum = parmele->osnum,
            p_classid = &classid);
        if (om$is_ancestry_valid (subclassid = classid,
            superclassid = OPP_EMSparamvc_class_id) == OM_S_SUCCESS)
        {
          elig_classes.w_count = 2;
          eliclass[0] = OPP_GRvg_class_id;
          eliclass[1] = OPP_EMSdatpln_class_id;
          /*
           * Allow locate of a reference plane for the perpendicular constraint (TR119300893).
           * Adding LC_HANDLES has a side-effect that allows the command to locate
           * constraint handles also.  HAS TO BE FIXED SOMEDAY s.t. only reference
           * planes get selected. - Rajiv 12/04/93
           */
          attributes.owner_action |= LC_HANDLES;
        }
        else
        {
          elig_classes.w_count = 1;
          eliclass[0] = OPP_GRbspline_class_id;
        }
        elig_classes.w_flags = OM_CLST_subclass;
        elig_classes.p_classes = eliclass;
      }
      else if (cmdtype == PTELEMENT_CMD)
      {
        ex$message (buff = locate_prompt,
            msgnumb = EMS_P_IdentifyConstrainingElement);
        ex$message (buff = accept_prompt,
            msgnumb = EMS_P_AcceptReject);
        ex$message (buff = relocate_prompt,
            msgnumb = EMS_P_ElementNotFound);

        parmele = &accept_event.located_object[0].located_obj;
        om$get_classid (objid = parmele->objid, osnum = parmele->osnum,
            p_classid = &classid);
        if (om$is_ancestry_valid (subclassid = classid,
            superclassid = OPP_EMSparamgm_class_id) != OM_S_SUCCESS)
        {
          elig_classes.w_count = 3;
          eliclass[0] = OPP_GRlineseg_class_id;
          eliclass[1] = OPP_GRcirarc_class_id;
          eliclass[2] = OPP_GRcircle_class_id;
        }
        else
        {
          elig_classes.w_count = 2;
          eliclass[0] = OPP_GRcurve_class_id;
          eliclass[1] = OPP_EMSsubbs_class_id;
        }
        elig_classes.w_flags = OM_CLST_subclass;
        elig_classes.p_classes = eliclass;
      }

      
      /*
       * arguments for action handler  --GMK
       */
      action_args.selected_object =  &me->parmele.located_obj;

      lc$locate ( rc = &object_was_located,
                  event1 = &me->locate_event, 
                  event2 = &accept_event, 
                  mask1 = locate_mask, 
                  mask2 = accept_mask,
                  eventsize= &eventsize, 
                  display_flag = display_flag,
                  response = response, 
                  response_data = response_data, 
                  locate_prompt = locate_prompt, 
                  acc_prompt = accept_prompt,
                  relocate_prompt = relocate_prompt, 
                  act_handler = ECaction_handler,
                  act_args = (char *)(&action_args),
                  attributes = &attributes, 
                  stack = &me->locate_stack, 
                  rtree_classes = &rtree_classes, 
                  eligible_classes = &elig_classes);

      /*
       * Back up response    --GMK
       */
      if ( *response == EX_BACK_UP ) 
      {
        me->state = LOCATE_PARMELE;
      }
      else if (!object_was_located)
        goto ret_end;
      else
      {
        me->ele = accept_event.located_object[0];
        me->ele_event = accept_event;

        parmele = &me->parmele.located_obj;
        om$get_classid ( objid = parmele->objid, 
                         osnum = parmele->osnum,
                         p_classid = &classid);
        if (om$is_ancestry_valid ( subclassid = classid,
                                   superclassid = OPP_EMSparamgm_class_id) == OM_S_SUCCESS)
          me->state = PROCESS_PARAMGM;
        else
          me->state = PROCESS_VGCNSTR;
      }
      break;

    case PROCESS_PARAMGM:
      dp$erase_hilite (msg = &msg_loc);

      if (cmdtype == PARALLEL_CMD)
      {
        stat_OM = om$construct (classid =  OPP_EMSparvcnstr_class_id,
            msg = message EMScnstr.EMinit (&send_rc,
            EMScnstr_connect_geomhandle, env,
            1, &me->ele.located_obj, NULL, NULL,
            1, &me->parmele.located_obj),
            osnum = env->md_id.osnum, p_objid = &cnstr_grid.objid);
        EMomerr_exit (stat_OM, ret_end);
      }
      else if (cmdtype == PERPENDICULAR_CMD)
      {
        ev = &me->ele_event;
        nrminfo.win_pln.objid = ev->event.button.objid;
        nrminfo.win_pln.osnum = ev->event.button.osnum;
        stat_OM = om$construct (classid =  OPP_EMSpervcnstr_class_id,
            msg = message EMScnstr.EMinit (&send_rc,
            EMScnstr_connect_geomhandle, env,
            1, &me->ele.located_obj, NULL,
            (char *) &nrminfo,
            1, &me->parmele.located_obj),
            osnum = env->md_id.osnum, p_objid = &cnstr_grid.objid);
        EMomerr_exit (stat_OM, ret_end);
      }
      else if (cmdtype == COINCIDENT_CMD)
      {
        subtype = me->ele_event.subtype;
        if (subtype == GRst_CENTER || subtype == GRst_MIDPOINT ||
            subtype == GRst_KEYPOINT || 
            subtype == GRst_REGULAR || subtype == GRst_INTER)
        {
          ev = &me->ele_event;
          num_aspt_parents = ev->num_id;
          for (i=0; i<num_aspt_parents; i++)
            aspt_parents[i] = ev->located_object[i].located_obj;

          asptinfo.type = subtype;
          OM_BLOCK_MOVE (&ev->event.button.x, asptinfo.pts[0], sizeof (IGRpoint));
          asptinfo.win_pln.objid = ev->event.button.objid;
          asptinfo.win_pln.osnum = ev->event.button.osnum;

          stat_OM = om$construct (classid =  OPP_EMSasptcnstr_class_id,
                                  msg = message EMScnstr.EMinit (&send_rc,
                                        EMScnstr_connect_geomhandle, env,
                                        num_aspt_parents, aspt_parents, NULL,
                                        (char *) &asptinfo,
                                        1, &me->parmele.located_obj),
                                  osnum = env->md_id.osnum, p_objid = &cnstr_grid.objid);
          EMomerr_exit (stat_OM, ret_end);
        }
        else
          send_rc = EMS_E_Fail;
      }
      else
      {
        stat_OM = om$construct (classid =  OPP_EMSptelcnstr_class_id,
            msg = message EMScnstr.EMinit (&send_rc,
            EMScnstr_connect_geomhandle, env,
            1, &me->ele.located_obj, NULL, NULL,
            1, &me->parmele.located_obj),
            osnum = env->md_id.osnum, p_objid = &cnstr_grid.objid);
        EMomerr_exit (stat_OM, ret_end);
      }

      if (EMSerror (send_rc))
      {
        ex$message (msgnumb = EMS_S_InvalidConstraint);
        me->state = LOCATE_PARMELE;
        break;
      }

      cnstr_grid.osnum = env->md_id.osnum;
      stat_OM = om$send (msg = message EMScnstr.EMvalidate ( &val_msg_loc, 
          EMSsolve_checkcycle, env, &val_cnstr, &num_conflict_cnstr, 
          conflict_cnstr_ids ),
          targetid = cnstr_grid.objid, targetos = cnstr_grid.osnum );
      EMerr_hndlr ( EMSerror ( stat_OM & val_msg_loc ), stat_OM, OM_E_ABORT, ret_end );

      if (val_cnstr)
      {
        if (val_msg_loc == EMS_I_FullyConstrained)
        {
          ex$message (msgnumb = EMS_S_FullyConstrained);
        }

        comp_type = ND_COMP;
        nd$wait_batch (type = GR_GEOM_POSTED,
            l_object = &cnstr_grid, l_obj_info = &comp_type, nb_obj = 1);

        nd$mod_batch (request = ND_INQ, p_ret_mode = &batch_mode);
        if (batch_mode == ND_IMMEDIATE)
          nd$exec_batch();
      }
      else
      {
        ECparam_report_conflict(&msg_loc, val_msg_loc, env, cnstr_grid, 
                                num_conflict_cnstr, conflict_cnstr_ids);
      }

      me->state = LOCATE_PARMELE;
      break;

    case PROCESS_VGCNSTR:
      dp$erase_hilite (msg = &msg_loc);
      chkcycle = FALSE;
      parmele = &me->parmele.located_obj;
      if (cmdtype == PARALLEL_CMD || cmdtype == PERPENDICULAR_CMD)
      {
        EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
        stat_OM = om$get_channel_objects (objid = parmele->objid,
            osnum = parmele->osnum, p_chanselect = &chan_to_defpts,
            count = (OMuint *)&count, size = 2, list = objlist);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (count != 2, stat_OM, OM_E_ABORT, ret_end);
        for (i=0; i<2; i++)
          vgpts[i] = objlist[i].S_objid;
        num_vgpts = 2;
      }
      else
      {
        vgpts[0] = parmele->objid;
        num_vgpts = 1;
      }

      ele = &me->ele.located_obj;
      if (cmdtype == COINCIDENT_CMD && IF_NULL_OBJID (ele->objid))
        ev = &me->ele_event;
      else
        ev = NULL;
      stat_OM = SKprocess_sketch_graphics (&msg_loc, SK_PROCSKGR_MERGESK,
          env, parmele, NULL, ev, ev ? 0 : 1, ev ? NULL : ele,
          &count, &vgpts[num_vgpts]);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
      if (msg_loc == EMS_I_BadPlane)
      {
        ex$message (msgnumb = EMS_S_IncompatiblePlane);
        me->state = LOCATE_PARMELE;
        break;
      }
      else if (msg_loc == EMS_I_Cycle)
      {
        ex$message (msgnumb = EMS_S_CyclicDependency);
        me->state = LOCATE_PARMELE;
        break;
      }

      if (cmdtype == COINCIDENT_CMD && vgpts[0] == vgpts[1]) 
      {
        ex$message (msgnumb = EMS_S_ConstraintNoCoincident);
        me->state = LOCATE_PARMELE;
        break;
      }
      
      if (msg_loc == EMS_I_Assoc)
        chkcycle = TRUE;
      num_vgpts += count;

      cnstrprops = NULL;
      cnstrinfo = NULL;
      if (cmdtype == PARALLEL_CMD)
        cnstrclass = OPP_SKparallel_class_id;
      else if (cmdtype == PERPENDICULAR_CMD)
        cnstrclass = OPP_SKnormal_class_id;
      else if (cmdtype == COINCIDENT_CMD)
        cnstrclass = OPP_SKcoincident_class_id;
      else
      {
        cnstrclass = OPP_SKptonelmt_class_id;
        ptonelmt_info.elemobj = ele->objid;
        cnstrinfo = (char *) &ptonelmt_info;
      }

      stat_OM = om$construct (classid = cnstrclass,
                              osnum = env->md_id.osnum,
                              msg = message SKconstraint.SKinit (&msg_loc,
                                    SK_OPT_CREATE_GEOMETRY | SK_OPT_DISPLAY_GEOMETRY |
                                    SK_OPT_MARK_AS_NEWADD | SK_OPT_MARK_AS_USERADD,
                                    env, num_vgpts, vgpts, cnstrprops, NULL, cnstrinfo),
                              p_objid = &cnstr_grid.objid);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
      cnstr_grid.osnum = env->md_id.osnum;

      stat_OM = om$send (msg = message SKconstraint.SKvalidate (&val_msg_loc,
          chkcycle ? SK_UPDATE_CHKCYCLE : NULL, env, &val_cnstr,
          &num_conflict_cnstr, &conflict_cnstr_objs),
          targetid = cnstr_grid.objid, targetos = cnstr_grid.osnum);
      EMerr_hndlr (EMSerror (stat_OM & val_msg_loc), stat_OM, OM_E_ABORT,
          ret_end);

      if (val_cnstr)
      {
        if (val_msg_loc == EMS_I_FullyConstrained)
        {
          ex$message (msgnumb = EMS_S_FullyConstrained);
        }

        stat_OM = om$send (msg = message SKconstraint.SKgetmgr(&msg_loc, &mgrid.objid), 
                           targetid = cnstr_grid.objid,
                           targetos = cnstr_grid.osnum);
        EMerr_hndlr ( EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end );
        mgrid.osnum = cnstr_grid.osnum;

        comp_type = ND_COMP;
        nd$wait_batch (type = GR_GEOM_POSTED,
            l_object = &mgrid, l_obj_info = &comp_type, nb_obj = 1);

        nd$mod_batch (request = ND_INQ, p_ret_mode = &batch_mode);
        if (batch_mode == ND_IMMEDIATE)
          nd$exec_batch();
      }
      else
      {
        ECvg_report_conflict(&msg_loc, val_msg_loc, env, cnstr_grid, 
                             num_conflict_cnstr, conflict_cnstr_objs);
        conflict_cnstr_objs = NULL;
      }

      me->state = LOCATE_PARMELE;
      break;

    default:
      stat_OM = OM_E_ABORT;
      goto ret_end;
    }
  }  while (TRUE);

ret_end:
  if (conflict_cnstr_objs)
    free ( conflict_cnstr_objs );

  if (EMSerror ( stat_OM ))
    *response = TERMINATE;

  return stat_OM;
}


/*
Name
  ECaction_handler

Description
  This is the action handler for lc$locate. It calls the 
  default action handler internally.

  This action handler doesn't call the default action handler
  if the input (already selected) object is matched with the new entry. 

Return Values
  IGRint ()  return status of default action handler
        
History
  GMK     08/17/93    Created.
*/

IGRint  ECaction_handler( do_not_locate, new_entry, locate_args, action )
struct	SKlocate_action_args *do_not_locate;
struct	GRlc_info *new_entry;
struct	LC_action_args *locate_args;
enum	GRlocate_action *action;
{
  IGRboolean	call_action_handler;
  IGRlong	sts,msg_loc;
  struct GRid   *search_id, origin_id;
  GRclassid     classid,sel_classid;
  IGRint	j;
  GRspacenum    osn;
  IGRboolean    aflag = 0;
  long          stat_OM;
  /*
   * Initialize
   */
  call_action_handler = TRUE;

  if(aflag = pwIsActivationOn())
   {
      osn = pwGetActiveOs();
      search_id = &new_entry->located_obj;
      om$get_classid( objid = search_id->objid,
                      osnum = search_id->osnum,
                      p_classid = &classid );

 if(om$is_ancestry_valid(subclassid = classid, 
          superclassid = OPP_SKdumpt_class_id) == OM_S_SUCCESS)
     {
  stat_OM = om$send (msg = message SKdumpt.SKget_origin_id(&msg_loc,&origin_id),
       senderid = NULL_OBJID, targetid = search_id->objid, targetos = search_id->osnum);
      EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

      if(origin_id.osnum != osn)
        return(OM_S_SUCCESS);
     }
     else
     {
      if(new_entry->located_obj.osnum != osn)
        return(OM_S_SUCCESS); 
     }
   }

  /*
   * If the action is to add then first check to see
   * if the object already selected.  If so then we don't
   * want to go through the accept/reject handler.
   */
  switch (*action)
  {
    case add_all:
    case add_inside:
    case add_outside:
    case add_overlap:
    case add_nopost:
	{
          search_id = &new_entry->located_obj;
          /*
           * get the class id's for selected object and new entry object
           */
	  om$get_classid( objid = search_id->objid,
	  		  osnum = search_id->osnum,
	  		  p_classid = &classid );
	  om$get_classid( objid = do_not_locate->selected_object->objid,
	  		  osnum = do_not_locate->selected_object->osnum,
	  		  p_classid = &sel_classid );

          if ( classid != OPP_SKdumpt_class_id )
          {
            if ( ( do_not_locate->selected_object->objid == search_id->objid ) &&
                 ( do_not_locate->selected_object->osnum == search_id->osnum ) ) 
              call_action_handler = FALSE;    
            else if ( sel_classid == OPP_SKptvar_class_id )
            {
              OM_S_CHANSELECT chan_to_geoms;
              OMuint num_geoms=0;
              struct GRid geom_id;
              
              /*
               * Here we are checking for connection between the already selected
               * object and new entry object. If the selected object is
               * connected to new entry object with to_geometries channel,
               * match that object with new entry object and reject that object.
               * example: point_on_element constraint 
               */
              EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);
            
              om$get_channel_count (   objid = do_not_locate->selected_object->objid, 
          	 		p_chanselect = &chan_to_geoms, 
          	 		       count = &num_geoms );
      
              for (j = 0; j < num_geoms; j++)
      	      {
        	om$get_objid_at_index ( objid = do_not_locate->selected_object->objid, 
            			 p_chanselect = &chan_to_geoms, 
            			        index = j, 
            			    objidaddr = &geom_id.objid, 
            			    osnumaddr = &geom_id.osnum );
	        if ( ( search_id->objid == geom_id.objid ) &&
                     ( search_id->osnum == geom_id.osnum ) ) 
		{
                  call_action_handler = FALSE;
                  break; 
                }    	    
	      } /* for loop j<num_geoms */
            }  

          }
          else
          {
            /*
             * get the originated object id
             */
            om$send( msg = message SKdumpt.SKget_origin_id( &msg_loc, &origin_id),
	 	     senderid = NULL_OBJID,
		     targetid = search_id->objid,
		     targetos = search_id->osnum );
 	    if ( ( do_not_locate->selected_object->objid == origin_id.objid ) &&
                 ( do_not_locate->selected_object->osnum == origin_id.osnum ) ) 
              call_action_handler = FALSE;    
          } /* class is SKdumpt class */     
        }
    /*
     * If the action is not to add then let the
     * regular action handler take care of the 
     * situation.
     */
    case start_transition:
    case end_transition:
    case post_object:
    case check_object:
    	break;
  } /* switch (*action) */
  /*
   * Call the action handler
   */
  if (call_action_handler)
  {
    extern IGRlong LCptlocact();

    sts = LCptlocact(NULL, new_entry, locate_args, action);
  }
  else
    sts = OM_S_SUCCESS;
  /*
   * Eof
   */
  return(sts);

  ret_end:
   return(stat_OM); 
 
}

end implementation EC2elecnstr;
