/*

Name
  EC1elecnstr.execute

Abstract
  Command object to place constraints on one element.

Synopsis

Description
 This routine implements the command interface for some of the 
 profile commands.  All the commands require only one input.
 The commands implemented are:
 
 Horizontal/Vertical
 Tangency
 Ground constraint
 Delete component 

Return Value

Notes

Index

Keywords
  method,profile

History
 Rajiv  	10/14/92	Added a routine to prevent profile component deletion
 				in case it will mess-up the solid.
 Allen Clark	Jan 12, 93	Initialized num_vgpts, cnstrclass,
				cnstrprops, and listners.
 Rajiv Agrawal	1/19/93		Fixed a memory overwrite problem in ECfeature_exists.
 				Also corrected delete component for a composite.
 Rajiv Agrawal   5/20/93	Removed checking for features when a component is being
 				deleted.
 Rajiv Agrawal   6/01/93	Removed the call to SKsplit_profile since it is now done
 				in the SKmgr.GRremove_components.
 Rajiv Agrawal   6/10/93	Massive cleanup and creation of a new state for DELETE
 				COMPONENT command.
 GMK             10/15/93       accept_prompt as instance data    -- TR # 119306839
 				clearing the locate_stack, if it contains the SKptvars
 GMK             10/21/93	Check for Cycle and Bad plane after SKprocess_sketch_graphics.

 */

class implementation EC1elecnstr;

%safe
#include <math.h>
%endsafe
#include <alloca.h>
#include "grgsmacros.h"
#include "SKdef.h"
#include "SKinc.h"
#include "EMSasopts.h"
#include "EMSdatumdef.h"
#include "EMdtmacros.h"
#include "msmacros.h"
#include "nddef.h"
#include "ECmsg.h"
#include "ECcmd.h"

#include "madef.h"
#include "maidmx.h"

#define HORIZVERT_CMD		0
#define TANGENCY_CMD		1
#define GROUND_CMD		2
#define DELETE_COMPONENT_CMD	3

#define LOCATE_PARMELE          0
#define LOCATE_HORVER_POINT     1
#define PROCESS_VGCNSTR         2
#define PROCESS_PARAMGM         3
#define DELETE_COMPONENT_STATE  4

#define FIRST  0
#define SECOND 1
#define THIRD  2

#define X 0
#define Y 1
#define Z 2

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

/*
 * _grids_equal(a,b) compares two GRids strucutures (a and b) for equality
 */
#define _grids_equal(a,b)  (( a.osnum == b.osnum ) && ( a.objid == b.objid ))

extern GRclassid OPP_GRbspline_class_id, OPP_GRpoint_class_id, OPP_SKmgr_class_id;
extern GRclassid OPP_SKline_class_id, OPP_SKptvar_class_id, OPP_SKarc_class_id;
extern GRclassid OPP_SKhorizvert_class_id, OPP_SKtangency_class_id, OPP_EMShvcnstr_class_id;
extern GRclassid OPP_SKasptgrnd_class_id, OPP_GR3dcirarc_class_id, OPP_GR3dlineseg_class_id;
extern GRclassid OPP_SKbspline_class_id;

extern GRclassid OPP_EMSparamvc_class_id, OPP_EMSparampt_class_id;
extern GRclassid OPP_EMSparamgm_class_id, OPP_SKgeometry_class_id;
extern GRclassid OPP_EMSsurface_class_id;

from GRgraphics   import GRdisplay, GRdelete;
from SKconstraint import SKinit, SKvalidate, SKgetmgr;
from EMScnstr     import EMinit, EMvalidate;
from SKvariable   import SKgetvar;
from SKgeometry   import SKgetmgr;
from SKmgr        import SKconstr_update, SKsavestate;
from GRowner      import GRremove_components;
from GRcurve      import GRsplit, GRendpts;
from NDnode       import NDget_objects;
from SKdumpt      import SKget_origin_id;


/*** Static globals for RFA ***/
%safe
static struct GRmd_env display_env;
%endsafe

/*
 * This structure is used as an argument to the action-handler
 * called within the locate for horizontal/vertical method.
 */

struct hv_acthndlr_args
{
  char *acc_prompt;
};

method init ( int type; char *string )
{
  ME.super_cmd->state = 0;
  ME.super_cmd->mytype = type;
  ME.EC1elecnstr->locate_stack.num_entries = 0;
  ME.EC1elecnstr->two_elements = FALSE;
  
  return OM_S_SUCCESS;
}

method wakeup ( int pos )
{
  int  bytes_in, bytes_out;
  long msg_loc, stat_OM;
  IGRboolean aflag;

  stat_OM = OM_S_SUCCESS;
  msg_loc = EMS_S_Success;

  UI_prompt ( "" );

  aflag = pwIsActivationOn();
  if (aflag)
  {
    pwGetActiveModuleEnv(&ME.EC1elecnstr->active_md_env);

    /*
     * set the display enviroment to the master module env.
     */
    bytes_in = sizeof (struct GRmd_env);
    gr$get_module_env (msg = &msg_loc, sizbuf = &bytes_in, 
    buffer = &display_env, nret = &bytes_out);
    EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
  }
  else
  {
    bytes_in = sizeof (struct GRmd_env);
    gr$get_module_env (msg = &msg_loc, sizbuf = &bytes_in, 
    buffer = &ME.EC1elecnstr->active_md_env, nret = &bytes_out);
    EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
  }
  
  if (me->mytype == HORIZVERT_CMD)
  {
    ex$message ( msgnumb = EM_M_PlaceHzVtConstraint );
  }
  else 
    if (me->mytype == TANGENCY_CMD)
    {
      ex$message ( msgnumb = EM_M_PlaceTangencyConstraint );
    }
    else
      if (me->mytype == DELETE_COMPONENT_CMD)
      {
        ex$message ( msgnumb = EM_M_DeleteProfileComponent );
      }
      else
        if (me->mytype == GROUND_CMD)
        {
          ex$message ( msgnumb = EM_M_PlaceGroundConstraint );
        }

  dp$erase_hilite ( msg = &msg_loc );

ret_end:
  return OM_S_SUCCESS;
}


method execute ( int *response; char *response_data; int pos )
{
  IGRboolean              putq=0, vg, val_cnstr, stat_func, use_event, chkcycle;
  IGRboolean              aflag=0;
  char                    locate_prompt[GR_MAX_CHAR], *accept_prompt;
  char                    relocate_prompt [GR_MAX_CHAR];
  char                    *p_actargs;
  unsigned short          gmtype [2], cnstrprops = NULL;
  int                     i, j, num_vgpts = 0, eventsize, num_conflict_cnstr, cmdtype;
  OMuint		  count;
  int                     batch_mode, comp_type, ref_lock_state;
  long                    val_msg_loc, send_rc, msg_loc, stat_OM;
  long                    display_flag, locate_mask, accept_mask;
  long                    object_was_located;
  IGRpoint                endpts [2];
  GRclassid               rclass [3], eliclass [6], cnstrclass = OM_K_NOTUSING_CLASSID, 
                          classid;
  GRobjid                 vgpts [4], *conflict_cnstr;
  struct GRmd_env         *env;
  struct GRid             cnstr_grid, aspt_grid, planid, mgrid, *parmele;
  struct GRid             parent_grids [2], *conflict_cnstrid;
  struct GRlc_locate      attributes;
  struct GRevent          accept_event, *locev, *obev;
  struct hv_acthndlr_args actargs;
  OM_S_CLASSLIST          rtree_classes, elig_classes;
  OM_S_CHANSELECT         chan_to_defpts, chan_to_geoms;
  OM_S_OBJECT_LINKAGE     vgptlist [4], gmlist [3];
  enum GRdpmode           dpmode;
  int                     plane_lock_was_off = 0; 
  long                    (*p_acthndlr) (), hv_acthndlr ();
  IGRboolean		  first_time;
  struct SKlocate_action_args   action_args;         /*arguments for action handler --GMK*/
  extern int 		  ECaction_handler();

  stat_OM = OM_S_SUCCESS;

  conflict_cnstr = NULL;
  conflict_cnstrid = (struct GRid *)alloca ( 3 * sizeof ( struct GRid ) );
  cmdtype = ME.super_cmd->mytype;
  eventsize = sizeof (struct GRevent);
  env = &ME.EC1elecnstr->active_md_env;

  /*
   *  TR # 119306839     for storing the accept_prompt
   */
  accept_prompt = ME.EC1elecnstr->accept_prompt;
  
  /*
   * if locate stack contains SKptvars, make stack entries to ZERO.
   * it starts the locate process again, this is because of locate doesn't know
   * how to display and locate SKptvars -- GMK 10/15/93
   */
  if ( ME.EC1elecnstr->locate_stack.num_entries )
  {
    parmele = &ME.EC1elecnstr->locate_stack.entry[0].located_obj;
    om$get_classid (objid = parmele->objid, osnum = parmele->osnum,
                          p_classid = &classid);
    if ( classid == OPP_SKptvar_class_id )
      ME.EC1elecnstr->locate_stack.num_entries = 0;
    parmele = NULL;
  }

  if (cmdtype == HORIZVERT_CMD)
  {
    ems$ref_plane_lock ( msg = &msg_loc, 
        options = EMS_REF_PLANE_LOCK_INQ, mode = &ref_lock_state );
    if (!(ref_lock_state & EMS_REF_PLANE_LOCK_ON))
      plane_lock_was_off = 1;
    ems$ref_plane_lock(msg = &msg_loc, 
        options = EMS_REF_PLANE_LOCK_ON | EMS_REF_PLANE_LOCK_SET,
        mode = &ref_lock_state );
  }

  first_time = TRUE;
  do
  {
    switch (ME.super_cmd->state)
    {
      case LOCATE_PARMELE:
        locate_mask = GRm_DATA | GRm_BACK_UP;
        accept_mask = GRm_DATA;
        if (first_time)
        {
          display_flag = ALL_WINDOWS | ELEM_HILIGHT;
          first_time = FALSE;
        }
        else
        {
          display_flag = ALL_WINDOWS | ELEM_HILIGHT | LC_IGNORE_FIRST_MISS;
        }
  
        p_acthndlr = NULL;
        p_actargs = NULL;
        if (cmdtype == HORIZVERT_CMD)
        {
          ex$message ( buff = locate_prompt, msgnumb = EMS_P_IdentifyAssocLinePoint );
          actargs.acc_prompt = accept_prompt;
          ex$message ( buff = relocate_prompt, msgnumb = EMS_P_LinePointNotFound );
          elig_classes.w_count = 4;
          eliclass[0] = OPP_SKline_class_id;
          eliclass[1] = OPP_SKptvar_class_id;
          eliclass[2] = OPP_EMSparampt_class_id;
          eliclass[3] = OPP_EMSparamvc_class_id;
          elig_classes.p_classes = eliclass;
          elig_classes.w_flags = OM_CLST_subclass;
  
          p_actargs = (char *) &actargs;
          p_acthndlr = hv_acthndlr;
        }
        else if (cmdtype == TANGENCY_CMD)
        {
          ex$message ( buff = locate_prompt, msgnumb = EMS_P_IdentifyProfileVertex );
          ex$message ( buff = accept_prompt, msgnumb = EMS_P_AcceptWithVertex );
          ex$message ( buff = relocate_prompt, msgnumb = EMS_P_VertexNotFound );
          elig_classes.w_count = 1;
          eliclass [0] = OPP_SKptvar_class_id;
          elig_classes.w_flags = OM_CLST_subclass;
          elig_classes.p_classes = eliclass;
        }
        else if (cmdtype == GROUND_CMD)
        {
          ex$message (buff = locate_prompt, msgnumb = EMS_P_IdentifyAssociativePoint );
          ex$message (buff = accept_prompt, msgnumb = EMS_P_AcceptWithNextPoint );
          ex$message (buff = relocate_prompt, msgnumb = EMS_P_PointNotFound );
          elig_classes.w_count = 2;
          eliclass [0] = OPP_SKptvar_class_id;
          eliclass [1] = OPP_EMSparampt_class_id;
          elig_classes.w_flags = OM_CLST_subclass;
          elig_classes.p_classes = eliclass;
        }
        else if (cmdtype == DELETE_COMPONENT_CMD)
        {
          ex$message ( buff = locate_prompt, msgnumb = EMS_P_IdentifyComponentToDelete );
          ex$message ( buff = accept_prompt, msgnumb = EMS_P_AcceptWithNextComponent );
          ex$message ( buff = relocate_prompt, msgnumb = EMS_S_ComponentNotFound );
          elig_classes.w_count = 2;
          eliclass [0] = OPP_GRbspline_class_id;
          eliclass [1] = OPP_SKbspline_class_id;
          elig_classes.w_flags = OM_CLST_subclass;
          elig_classes.p_classes = eliclass;
        }
  
        rtree_classes.w_count = 1;
        rclass[0] = OPP_GRbspline_class_id;
        rtree_classes.w_flags = OM_CLST_subclass;
        rtree_classes.p_classes = rclass;
  
        attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
        attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS;
 
    if((aflag = pwIsActivationOn()) && (p_acthndlr == NULL))
      { 
        extern long RFlocate_cons_acthndlr();
        GRspacenum  osn;

        osn = pwGetActiveOs();
        lc$locate ( rc = &object_was_located,
                    event1 = &ME.EC1elecnstr->locate_event, 
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
                    stack = &ME.EC1elecnstr->locate_stack, 
                    act_handler = RFlocate_cons_acthndlr,
                    act_args = &osn,
                    rtree_classes = &rtree_classes, 
                    eligible_classes = &elig_classes);
      }
    else
      {
        lc$locate ( rc = &object_was_located,
                    event1 = &ME.EC1elecnstr->locate_event, 
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
                    stack = &ME.EC1elecnstr->locate_stack, 
                    act_handler = p_acthndlr,
                    act_args = p_actargs,
                    rtree_classes = &rtree_classes, 
                    eligible_classes = &elig_classes);
       } 
        if (!object_was_located)
          goto ret_end;
        else
        {
          ME.EC1elecnstr->parmele = accept_event.located_object[0];
  
          parmele = &accept_event.located_object[0].located_obj;
          om$get_classid (objid = parmele->objid, osnum = parmele->osnum,
                          p_classid = &classid);
          if (om$is_ancestry_valid (subclassid = classid,
              superclassid = OPP_EMSparamgm_class_id) == OM_S_SUCCESS)
            ME.super_cmd->state = PROCESS_PARAMGM;
          else
            ME.super_cmd->state = PROCESS_VGCNSTR;
  
          if (om$is_ancestry_valid (subclassid = classid,
              superclassid = OPP_SKptvar_class_id) == OM_S_SUCCESS ||
              om$is_ancestry_valid (subclassid = classid,
              superclassid = OPP_EMSparampt_class_id) == OM_S_SUCCESS)
          {
            if (cmdtype == HORIZVERT_CMD)
            {
              putq = FALSE;
              ME.super_cmd->state = LOCATE_HORVER_POINT;
            }
            else
            {
              putq = TRUE;
              accept_event.subtype = EX_DATA;
            }
          }
          else 
            if (cmdtype == GROUND_CMD)
            {
              locev = &ME.EC1elecnstr->locate_event;
              if (locev->response == EX_OBJID ||
                  (locev->subtype != GRst_REGULAR &&
                  accept_event.num_id &&
                  locev->located_object[0].located_obj.objid ==
                  accept_event.located_object[0].located_obj.objid))
                putq = FALSE;
              else
                putq = TRUE;
            }
            else
              if (cmdtype == DELETE_COMPONENT_CMD)
              {
                ME.super_cmd->state = DELETE_COMPONENT_STATE;
                putq = TRUE;
              }
  
          if (putq)
            ex$putque ( msg = &msg_loc, response = response,
                        byte = (long *) &eventsize, 
                        buffer = (char *) &accept_event.event );
        }
        break;
  
      case LOCATE_HORVER_POINT:
        ex$message (msgnumb = EMS_P_IdentifyOtherPoint);
        accept_mask = GRm_DATA | GRm_BACK_UP;
        stat_func = co$getevent (msg = &msg_loc, event_mask = accept_mask,
            response = response, response_data = response_data,
            event = &accept_event);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
        UI_prompt ("");
  
        switch (accept_event.response)
        {
        case EX_BACK_UP:
          first_time = TRUE;
          ME.super_cmd->state = LOCATE_PARMELE;
          break;
  
        case EX_DATA:
          parmele = &ME.EC1elecnstr->parmele.located_obj;
          om$get_classid (objid = parmele->objid, osnum = parmele->osnum,
              p_classid = &classid);
          if (om$is_ancestry_valid (subclassid = classid,
              superclassid = OPP_EMSparamgm_class_id) == OM_S_SUCCESS)
            vg = FALSE;
          else
            vg = TRUE;
  
          if (!EMptsubtype_supported (&accept_event))
          {
            ex$putque (msg = &msg_loc, response = response,
                       byte = (long *) &eventsize, 
                       buffer = (char *) &accept_event.event);
  
            display_flag = ALL_WINDOWS | ELEM_HILIGHT | DO_NOT_RELOCATE;
            locate_mask = GRm_DATA | GRm_BACK_UP;
            accept_mask = GRm_DATA;
  
            ex$message ( buff = locate_prompt, msgnumb = EMS_P_IdentifyPoint );
            ex$message ( buff = accept_prompt, msgnumb = EMS_P_AcceptReject );
            ex$message ( buff = relocate_prompt, msgnumb = EMS_P_PointNotFound );
  
            elig_classes.w_count = 2;
            eliclass[0] = OPP_SKptvar_class_id;
            eliclass[1] = OPP_GRpoint_class_id;
            elig_classes.w_flags = OM_CLST_subclass;
            elig_classes.p_classes = eliclass;
  
            rtree_classes.w_count = 1;
            rclass[0] = OPP_GRbspline_class_id;
            rtree_classes.w_flags = OM_CLST_subclass;
            rtree_classes.p_classes = rclass;
  
            attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
            attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_REF_HEADER | LC_REF_OBJECTS;

            /* 
             * argument for action hander  --GMK 
             */
	    action_args.selected_object =  &me->parmele.located_obj;
  
            lc$locate ( rc = &object_was_located,
                        event1 = &ME.EC1elecnstr->locate_event, 
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
                        stack = &ME.EC1elecnstr->locate_stack, 
                        rtree_classes = &rtree_classes, 
                        eligible_classes = &elig_classes);
  
            if (object_was_located)
            {
              if (_grids_equal (ME.EC1elecnstr->parmele.located_obj,
                  accept_event.located_object[0].located_obj))
              {
                ex$message (msgnumb = EMS_S_ConstraintPointsCoincident);
              }
              else 
              {
                ME.EC1elecnstr->two_elements = TRUE;
                ME.EC1elecnstr->use_event = FALSE;
                ME.EC1elecnstr->otherele_event = accept_event;
                ME.super_cmd->state = vg ? PROCESS_VGCNSTR : PROCESS_PARAMGM;
              }
            }
            else
            {
              ex$message (msgnumb = EMS_P_PointNotFound);
            }
          }
          else
          {
            if (_grids_equal( ME.EC1elecnstr->parmele.located_obj,
                accept_event.located_object[0].located_obj))
            {
              ex$message (msgnumb = EMS_S_ConstraintPointsCoincident);
            }
            else 
            {
              ME.EC1elecnstr->two_elements = TRUE;
              ME.EC1elecnstr->use_event = TRUE;
              ME.EC1elecnstr->otherele_event = accept_event;
              ME.super_cmd->state = vg ? PROCESS_VGCNSTR : PROCESS_PARAMGM;
            }
          }
          break;
  
        default:
          goto ret_end;
        }
        break;
  
      case PROCESS_VGCNSTR:
        dp$erase_hilite (msg = &msg_loc);
  
        chkcycle = FALSE;
        parmele = &ME.EC1elecnstr->parmele.located_obj;
        if (cmdtype == HORIZVERT_CMD)
        {
          if (!ME.EC1elecnstr->two_elements)
          {
            EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
            stat_OM = om$get_channel_objects (objid = parmele->objid,
                osnum = parmele->osnum, p_chanselect = &chan_to_defpts,
                count = &count, size = 3, list = vgptlist);
            EMomerr_exit (stat_OM, ret_end);
            EMerr_hndlr (count != 2, stat_OM, OM_E_ABORT, ret_end);
  
            for (i=FIRST; i<=SECOND; i++)
              vgpts[i] = vgptlist[i].S_objid;
          }
          else
          {
            vgpts[FIRST] = parmele->objid;
  
            use_event = ME.EC1elecnstr->use_event;
            obev = &ME.EC1elecnstr->otherele_event;
            stat_OM = SKprocess_sketch_graphics (&msg_loc, SK_PROCSKGR_MERGESK,
                env, parmele, NULL,
                use_event ? obev : NULL,
                use_event ? 0 : 1, 
                use_event ? NULL : &obev->located_object[0].located_obj,
                &count, &vgpts[SECOND]);
            EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
                ret_end);

            if (msg_loc == EMS_I_BadPlane)
            {
              ex$message (msgnumb = EMS_S_IncompatiblePlane);
              me->state = LOCATE_PARMELE;
              break;
            }
            else if (msg_loc == EMS_I_Cycle)
            {
              ex$message (msgnumb = EMS_S_CyclicDependency);
              ME.super_cmd->state = LOCATE_PARMELE;
              break;
            }

            if (msg_loc == EMS_I_Assoc)
              chkcycle = TRUE;
          }
          num_vgpts = 2;
  
          cnstrclass = OPP_SKhorizvert_class_id;
          for (i=FIRST; i<=SECOND; i++)
          {
            stat_OM = om$send (msg = message SKvariable.SKgetvar (&msg_loc,
                NULL, NULL, NULL, endpts[i]), targetid = vgpts[i],
                targetos = parmele->osnum);
            EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
                ret_end);
          }
  
          if (fabs (endpts[FIRST][X] - endpts[SECOND][X]) >
              fabs (endpts[FIRST][Y] - endpts[SECOND][Y]))
            cnstrprops = SK_HORIZONTAL;
          else
            cnstrprops = NULL;
  
          ME.EC1elecnstr->two_elements = FALSE;
        }
        else if (cmdtype == TANGENCY_CMD)
        {
          EMmake_chanselect (SKvariable_to_geometries, &chan_to_geoms);
          stat_OM = om$get_channel_objects (objid = parmele->objid,
              osnum = parmele->osnum, p_chanselect = &chan_to_geoms,
              count = &count, size = 3, list = gmlist);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (count != 2, stat_OM, OM_E_ABORT, ret_end);
  
          for (i=FIRST; i<=SECOND; i++)
            SKgetgeomtype (gmlist[i].S_objid, parmele->osnum, &gmtype[i]);
          if ((gmtype[FIRST] & SK_LINE && gmtype[SECOND] & SK_LINE) ||
              (gmtype[FIRST] & SK_POINT || gmtype[SECOND] & SK_POINT))
          {
            ex$message (msgnumb = EMS_S_InvalidConstraint);
  
            ME.super_cmd->state = LOCATE_PARMELE;
            break;
          }
  
          EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
          vgpts [FIRST] = parmele->objid;
          for (i = FIRST, j = SECOND; i <= SECOND; i++, j++)
          {
            stat_OM = om$get_channel_objects (objid = gmlist[i].S_objid,
                                              osnum = parmele->osnum, 
                                              p_chanselect = &chan_to_defpts,
                                              count = &count, size = 4, list = vgptlist);
            EMomerr_exit (stat_OM, ret_end);
  
            if (gmtype[i] & SK_LINE)
              vgpts [j] = vgptlist [vgptlist [0].S_objid == vgpts [0] ? 1 : 0].S_objid;
            else if (gmtype[i] & SK_ARC)
              vgpts [j] = vgptlist [1].S_objid;    /* center pt-id */
            else if (gmtype[i] & SK_BSPLINE)
              vgpts [j] = vgptlist [vgptlist [0].S_objid == vgpts [0] ? 1 : 2].S_objid;
          }
          num_vgpts = 3;
  
          cnstrclass = OPP_SKtangency_class_id;
          cnstrprops = NULL;
        }
        else
          if (cmdtype == GROUND_CMD)
          {
            vgpts[FIRST] = parmele->objid;
            num_vgpts = 1;
  
            cnstrclass = OPP_SKasptgrnd_class_id;
            cnstrprops = NULL;
          }
  
        stat_OM = om$construct (classid = cnstrclass,
                                osnum = env->md_id.osnum,
                                msg = message SKconstraint.SKinit (&msg_loc,
                                      SK_OPT_CREATE_GEOMETRY | SK_OPT_MARK_AS_NEWADD |
                                      SK_OPT_MARK_AS_USERADD | SK_OPT_DISPLAY_GEOMETRY,
                                      env, num_vgpts, vgpts, cnstrprops, NULL, NULL),
                                p_objid = &cnstr_grid.objid);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
        cnstr_grid.osnum = env->md_id.osnum;
  
        stat_OM = om$send (msg = message SKconstraint.SKvalidate (&val_msg_loc,
            chkcycle ? SK_UPDATE_CHKCYCLE : NULL, env, &val_cnstr,
            &num_conflict_cnstr, &conflict_cnstr),
            targetid = cnstr_grid.objid, targetos = cnstr_grid.osnum);
        if (!(stat_OM & val_msg_loc & 1))
          val_cnstr = 0;
  
        if (val_cnstr)
        {
          if (val_msg_loc == EMS_I_FullyConstrained)
          {
            ex$message (msgnumb = EMS_S_FullyConstrained);
          }
  
          stat_OM = om$send (msg = message SKconstraint.SKgetmgr
                                   (&msg_loc, &mgrid.objid), 
                             targetid = cnstr_grid.objid,
                             targetos = cnstr_grid.osnum);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
          mgrid.osnum = cnstr_grid.osnum;

          if (cmdtype != GROUND_CMD)
          {
            comp_type = ND_COMP;
            nd$wait_batch (type = GR_GEOM_POSTED,
                l_object = &mgrid, l_obj_info = &comp_type, nb_obj = 1);
  
            nd$mod_batch (request = ND_INQ, p_ret_mode = &batch_mode);
            if (batch_mode == ND_IMMEDIATE)
              nd$exec_batch();
          }
          else
          {
            stat_OM = om$send (msg = message SKmgr.SKsavestate (&msg_loc, NULL, NULL),
                               targetid = mgrid.objid,
                               targetos = mgrid.osnum);
            EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

            dpmode = GRbd;
            aflag = pwIsActivationOn();
            if(aflag)
            {
              om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                                    &display_env.md_env.matrix_type,
                                    display_env.md_env.matrix, &dpmode,
                                    &display_env.md_id), 
                     targetid = cnstr_grid.objid, 
                     targetos = cnstr_grid.osnum);
            }
            else
            {
              om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                           &env->md_env.matrix_type, env->md_env.matrix, &dpmode,
                           &env->md_id), 
                     targetid = cnstr_grid.objid, 
                     targetos = cnstr_grid.osnum);
            }
          }
        }
        else
        {
          ECvg_report_conflict(&msg_loc, val_msg_loc, env, cnstr_grid, 
                               num_conflict_cnstr, conflict_cnstr);
          conflict_cnstr = NULL;
        }
  
        ME.super_cmd->state = LOCATE_PARMELE;
        break;
  
      case PROCESS_PARAMGM:
        dp$erase_hilite ( msg = &msg_loc );
  
        parmele = &ME.EC1elecnstr->parmele.located_obj;
        if (cmdtype == HORIZVERT_CMD)
        {
          ems$ref_plane_lock (msg = &msg_loc, options = EMS_REF_PLANE_LOCK_INQ,
              mode = &ref_lock_state);
          if (! (ref_lock_state & EMS_REF_PLANE_LOCK_ON))
          {
            ex$message(msgnumb = EMS_S_RefPlaneLockShdbeOn);
            ME.super_cmd->state = LOCATE_PARMELE;
            break;
          }
  
          planid.objid = NULL_OBJID;
          ems$get_active_datum_plane (msg = &msg_loc, datpln = &planid);
          EMerr_hndlr (IF_NULL_OBJID (planid.objid), stat_OM, OM_E_ABORT,
              ret_end);
  
          if (ME.EC1elecnstr->two_elements)
          {
            use_event = ME.EC1elecnstr->use_event;
            obev = &ME.EC1elecnstr->otherele_event;
            if (use_event)
            {
              EMasptcnstr (&msg_loc, EMScnstr_check_cycle, env, obev,
                           0, NULL, &aspt_grid.objid);
              EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
              if (msg_loc == EMS_I_NotSupported || msg_loc == EMS_I_Cycle)
              {
                if (msg_loc == EMS_I_NotSupported)
                {
                  ex$message (msgnumb = EMS_S_NotYetSupported);
                }
                else
                {
                  ex$message (msgnumb = EMS_S_CyclicDependency);
                }
  
                ME.super_cmd->state = LOCATE_PARMELE;
                break;
              }
              aspt_grid.osnum = parmele->osnum;
            }
            else
              aspt_grid = obev->located_object[0].located_obj;
  
            parent_grids[FIRST] = aspt_grid;
            parent_grids[SECOND] = planid;
          }
          else
            parent_grids[FIRST] = planid;
          stat_OM = om$construct (classid =  OPP_EMShvcnstr_class_id,
                                  msg = message EMScnstr.EMinit ( &send_rc,
                                        EMScnstr_connect_geomhandle | EMScnstr_minimum_delta | 
                                        EMScnstr_display, env,
                                        ME.EC1elecnstr->two_elements ? 2 : 1, parent_grids,
                                        NULL, NULL, 1, parmele ),
                                  osnum = env->md_id.osnum, 
                                  p_objid = &cnstr_grid.objid );
          EMomerr_exit ( stat_OM, ret_end );
        }
        else
        {
          ex$message (msgnumb = EMS_S_NotYetSupported);
  
          ME.super_cmd->state = LOCATE_PARMELE;
          break;
        }
  
        if (EMSerror (send_rc))
        {
          ex$message (msgnumb = EMS_S_InvalidConstraint);
  
          ME.super_cmd->state = LOCATE_PARMELE;
          break;
        }
  
        cnstr_grid.osnum = env->md_id.osnum;
        stat_OM = om$send (msg = message EMScnstr.EMvalidate ( &val_msg_loc, 
                                 EMSsolve_checkcycle,
                                 env, &val_cnstr, &num_conflict_cnstr, conflict_cnstrid ),
                           targetid = cnstr_grid.objid, 
                           targetos = cnstr_grid.osnum);
        EMerr_hndlr (EMSerror (stat_OM & val_msg_loc), stat_OM, OM_E_ABORT,
            ret_end);
  
        if (val_cnstr)
        {
          comp_type = ND_COMP;
          nd$wait_batch (type = GR_GEOM_POSTED,
              l_object = parmele, l_obj_info = &comp_type, nb_obj = 1);
  
          nd$mod_batch (request = ND_INQ, p_ret_mode = &batch_mode);
          if (batch_mode == ND_IMMEDIATE)
            nd$exec_batch();
        }
        else
        {
          ECparam_report_conflict(&msg_loc, val_msg_loc, env, cnstr_grid, 
                                  num_conflict_cnstr, conflict_cnstrid);
        }
    
        ME.super_cmd->state = LOCATE_PARMELE;
        break;
  
      case DELETE_COMPONENT_STATE:
        dp$erase_hilite (msg = &msg_loc);

        /*
         * Are we dealing with a Profile element or with a Composite curve
         * element?
         */
        if (om$is_ancestry_valid ( subclassid = classid,
                                   superclassid = OPP_SKgeometry_class_id ) == OM_S_SUCCESS)
        {
          GRobjid  	   mgr_id;
          struct GRobj_env objects [1];
          int              count = 1;

          dpmode = GRbehe;

          aflag = pwIsActivationOn();
          if(aflag)
          {
            stat_OM = om$send ( msg = message GRgraphics.GRdisplay ( &msg_loc, 
                                    &display_env.md_env.matrix_type, 
                                    display_env.md_env.matrix, &dpmode,
                                    &display_env.md_id ), 
                              targetid = parmele->objid, 
                              targetos = parmele->osnum );
          }
          else
          {
          stat_OM = om$send ( msg = message GRgraphics.GRdisplay ( &msg_loc, 
                                    &accept_event.located_object [0].module_info.md_env.matrix_type, 
                                    accept_event.located_object [0].module_info.md_env.matrix, &dpmode,
                                    &accept_event.located_object [0].module_info.md_id ), 
                              targetid = parmele->objid, 
                              targetos = parmele->osnum );
          }

          /*
           * Get the SKmgr of the element being deleted.  Remove it from its
           * components and redisplay the manager.
           */
          stat_OM = om$send ( msg = message SKgeometry.SKgetmgr ( &msg_loc, &mgr_id ),
                              targetid = parmele->objid, 
                              targetos = parmele->osnum );
          EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
          objects [0].obj_id = *parmele;
          objects [0].mod_env = accept_event.located_object [0].module_info;
  
          stat_OM = om$send (msg = message SKmgr.GRremove_components ( &msg_loc, 
                                   &accept_event.located_object [0].module_info, 
                                   &count, objects ),
                             targetid = mgr_id, 
                             targetos = parmele->osnum );
          EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
          

          stat_OM = om$send ( msg = message SKmgr.SKconstr_update ( &msg_loc,
                                    SK_UPDATE_IMPCONSTRS | 
                                    SK_UPDATE_ERASE | SK_UPDATE_DRAW, NULL, 
                                    &accept_event.located_object [0].module_info ), 
                              targetid = mgr_id, 
                              targetos = parmele->osnum );
  
          dpmode = GRbd;
          aflag = pwIsActivationOn();
          if(aflag)
          {
            stat_OM = om$send ( msg = message GRgraphics.GRdisplay ( &msg_loc,
                                    &display_env.md_env.matrix_type, 
                                    display_env.md_env.matrix, &dpmode,
                                    &display_env.md_id ), 
                              targetid = mgr_id, 
                              targetos = parmele->osnum );
          }
          else
          {
          stat_OM = om$send ( msg = message GRgraphics.GRdisplay ( &msg_loc,
                                    &accept_event.located_object [0].module_info.md_env.matrix_type, 
                                    accept_event.located_object [0].module_info.md_env.matrix, &dpmode,
                                    &accept_event.located_object [0].module_info.md_id ), 
                              targetid = mgr_id, 
                              targetos = parmele->osnum );
          }
        }
        else
        {
          OM_S_CHANSELECT     to_owners, to_members;
          OM_S_OBJECT_LINKAGE owners [1], members [1];
          OMuint              count;
          IGRpoint            startpnt, endpnt;
          GRobjid             c1, c2;
          short               num_obj;
          struct GRparms      parms;
  
          /*
           * We split the composite at the end points of the element we are
           * deleting.
           */
          EMmake_chanselect ( GRconnector_to_owners, &to_owners );
          stat_OM = om$get_channel_objects ( osnum = parmele->osnum, 
              objid = parmele->objid, list = owners, size = 1, 
              p_chanselect = &to_owners, count = &count );
          if (count == 1)
          {
            /*
             * If there is one or two components then there is no need to split
             * the composite curve.
             */
            EMmake_chanselect ( GRcmpowner_to_components, &to_members );
            stat_OM = om$get_channel_count ( osnum = owners [0].osnum,
                objid = owners [0].S_objid, p_chanselect = &to_members, count = &count );
            if (count > 2)
            {
              struct GRid first, last;
              
              stat_OM = om$get_objid_at_index ( osnum = owners [0].osnum,
                objid = owners [0].S_objid, p_chanselect = &to_members,
                index = 0, objidaddr= &first.objid, osnumaddr = &first.osnum );
              EMerr_hndlr ( EMSerror ( stat_OM ), stat_OM, OM_E_ABORT, ret_end );
              
              stat_OM = om$get_objid_at_index ( osnum = owners [0].osnum,
                objid = owners [0].S_objid, p_chanselect = &to_members,
                index = count-1, objidaddr= &last.objid, osnumaddr = &last.osnum );
              EMerr_hndlr ( EMSerror ( stat_OM ), stat_OM, OM_E_ABORT, ret_end );
              
              if (parmele->objid != first.objid && parmele->objid != last.objid)
              {
                stat_OM = om$send ( msg = message GRcurve.GRendpts ( &msg_loc,
                      &accept_event.located_object [0].module_info.md_env.matrix_type, 
                      accept_event.located_object [0].module_info.md_env.matrix,
                      startpnt, endpnt ), 
                    targetid = parmele->objid, 
                    targetos = parmele->osnum );
                EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
                
                parms.leaf_id = *parmele;
                stat_OM = om$send ( msg = message GRcurve.GRsplit ( &msg_loc,
                         &accept_event.located_object [0].module_info,
                         startpnt, &parms, &c1, &c2, &num_obj ), 
                  targetid = owners [0].S_objid, 
                  targetos = parmele->osnum );
                EMerr_hndlr ( EMSerror ( msg_loc & stat_OM ), stat_OM, OM_E_ABORT, ret_end );
                
                /*
                 * The member has changed objid -> get the new one.
                 */
                stat_OM = om$get_channel_objects ( osnum = parmele->osnum, 
                    objid = c2, list = members, size = 1, 
                    p_chanselect = &to_members, count = &count );
              }
              else
              {
                members [0].S_objid = parmele->objid;
                members [0].osnum = parmele->osnum;
              }
            }
            else
            {
              if (count == 1)
              {
                /*
                 * We delete the owner
                 */
                members [0] = owners [0];
              }
              else  /* count = 2 ... only two components */
              {
                /*
                 * We delete the member
                 */
                members [0].S_objid = parmele->objid;
                members [0].osnum = parmele->osnum;
              }
            }
          }
          else
          {
            /*
             * This is a regular delete...
             */
            members [0].S_objid = parmele->objid;
            members [0].osnum = parmele->osnum;
          }
  
          /*
           * We erase and then delete the element.
           */
          dpmode = GRbehe;
          aflag = pwIsActivationOn();
          if(aflag)
          {
            om$send ( msg = message GRgraphics.GRdisplay ( &msg_loc,
              &display_env.md_env.matrix_type, 
              display_env.md_env.matrix, &dpmode,
              &display_env.md_id ), 
              targetid =  members [0].S_objid, targetos = members [0].osnum );
          }
          else
          {
            om$send ( msg = message GRgraphics.GRdisplay ( &msg_loc,
              &accept_event.located_object [0].module_info.md_env.matrix_type, 
              accept_event.located_object [0].module_info.md_env.matrix, &dpmode,
              &accept_event.located_object [0].module_info.md_id ), 
              targetid =  members [0].S_objid, targetos = members [0].osnum );
          }
  
          stat_OM = om$send (msg = message GRgraphics.GRdelete ( &msg_loc, 
              &accept_event.located_object [0].module_info ),
              targetid =  members [0].S_objid, targetos = members [0].osnum );
          EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
        }
        
        ME.super_cmd->state = LOCATE_PARMELE;
        break;
  
      default:
         stat_OM = OM_E_ABORT;
         goto ret_end;
    }
  }  while (TRUE);

ret_end:
  if (plane_lock_was_off)
    ems$ref_plane_lock ( msg = &msg_loc, 
        options = EMS_REF_PLANE_LOCK_OFF | EMS_REF_PLANE_LOCK_SET );

  if (conflict_cnstr)
    free ( conflict_cnstr );

  if (EMSerror ( stat_OM )) *response = TERMINATE;

  return stat_OM;
}


/*
 * This is the action-handler used in order to dynamically change the
 * accept prompt while in the horizontal/vertical constraint placement command.
 */

long hv_acthndlr (curr_info, new_locinfo, priv_args, action)
struct hv_acthndlr_args *curr_info;
struct GRlc_info *new_locinfo;
struct LC_action_args *priv_args;
enum GRlocate_action *action;
{
  GRclassid classid;
  struct GRid *locid;
  extern long LCptlocact();
  struct GRid origin_id;
  long loc_msg,stat_OM;
  long sts = OM_S_SUCCESS;
  IGRboolean aflag = 0;
  GRspacenum osn;
  osn = pwGetActiveOs();
  locid = &new_locinfo->located_obj;

  om$get_classid (objid = locid->objid, osnum = locid->osnum,
      p_classid = &classid);
  if (om$is_ancestry_valid (subclassid = classid,
      superclassid = OPP_EMSparampt_class_id) == OM_S_SUCCESS ||
      om$is_ancestry_valid (subclassid = classid,
      superclassid = OPP_SKptvar_class_id) == OM_S_SUCCESS ||
      om$is_ancestry_valid (subclassid = classid,
      superclassid = OPP_GRpoint_class_id) == OM_S_SUCCESS)
  {
    ex$message (buff = curr_info->acc_prompt, msgnumb = EMS_P_AcceptReject);
  }
  else
  {
    ex$message (buff = curr_info->acc_prompt, msgnumb = EMS_P_AcceptWithNextParametric );
  }
 
if(aflag = pwIsActivationOn())
 {
 if(om$is_ancestry_valid(subclassid = classid, superclassid = OPP_SKdumpt_class_id) == OM_S_SUCCESS)
 {
  stat_OM = om$send (msg = message SKdumpt.SKget_origin_id(&loc_msg,&origin_id),
       senderid = NULL_OBJID, targetid = locid->objid, targetos = locid->osnum);
  EMerr_hndlr (EMSerror (loc_msg), stat_OM, OM_E_ABORT, ret_end); 
  if(origin_id.osnum != osn)
     return (sts);
 }
 else
 {
   if(new_locinfo->located_obj.osnum != osn)
     return (sts);
 }
 }

   return LCptlocact (curr_info, new_locinfo, priv_args, action );
 ret_end:
   return (stat_OM);
}
long RFlocate_cons_acthndlr (osn, new_locinfo, priv_args, action)
GRspacenum *osn;
struct GRlc_info *new_locinfo;
struct LC_action_args *priv_args;
enum GRlocate_action *action;
{
  GRclassid classid;
  struct GRid *locid;
  extern long LCptlocact();
  struct GRid origin_id;
  long loc_msg,stat_OM;
  long sts = OM_S_SUCCESS;

  locid = &new_locinfo->located_obj;

  om$get_classid (objid = locid->objid, osnum = locid->osnum,
      p_classid = &classid);
 
 if(om$is_ancestry_valid(subclassid = classid, superclassid = OPP_SKdumpt_class_id) == OM_S_SUCCESS)
 {
  stat_OM = om$send (msg = message SKdumpt.SKget_origin_id(&loc_msg,&origin_id),
       senderid = NULL_OBJID, targetid = locid->objid, targetos = locid->osnum);
  EMerr_hndlr (EMSerror (loc_msg), stat_OM, OM_E_ABORT, ret_end); 
   if(origin_id.osnum != *osn)
     return (sts);
   else
     return LCptlocact (NULL, new_locinfo, priv_args, action ); 
 }
 else
 {
   if(new_locinfo->located_obj.osnum != *osn)
     return (sts);
   else
     return LCptlocact (NULL, new_locinfo, priv_args, action );
 }
 ret_end:
   return (stat_OM);
}


end implementation EC1elecnstr;

#if WE_NEED_TO_LOOK_AT_SOME_OLD_USELESS_CODE
/*
 * This function checks if a profile/composite component is attached to a feature.
 * NO LONGER BEING USED - Rajiv 5/20/93
 */
int ECfeature_exists (msg, geomid, geomos)
long 		*msg;
GRobjid 	geomid;
GRspacenum 	geomos;
{
  int           i, j;
  int		feature_found = FALSE;
  long          stat_OM;
  int 		num_children = 0, num_grand_children = 0;
  OMuint	num_listners = 0;
  struct GRid   compid, *children, *grand_children;
  GRclassid	geom_class, child_class, grand_child_class;
  OM_S_CHANSELECT to_owners, to_listner;
  OM_S_OBJECT_LINKAGE *listners = NULL;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  EMmake_chanselect ( GRconnector_to_owners, &to_owners );
  stat_OM = om$get_objid_at_index ( objid = geomid, osnum = geomos,
     p_chanselect = &to_owners, index = 0, 
     objidaddr = &compid.objid, osnumaddr = &compid.osnum );
  EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_Fail, ret_end );
  
  /*
   * If the component being deleted is not part of a profile, then find the listener
   * object.
   */
  om$get_classid (objid = geomid, osnum = geomos, p_classid = &geom_class);
  if (om$is_ancestry_valid(subclassid = geom_class, 
           superclassid = OPP_SKgeometry_class_id) != OM_S_SUCCESS)
  {
    EMmake_chanselect ( GRnotify_notification, &to_listner);
    stat_OM = om$get_channel_count ( objid = compid.objid, osnum = compid.osnum,
    		p_chanselect = &to_listner, count = &num_listners );
    
    if (num_listners)
    {
      listners = (OM_S_OBJECT_LINKAGE *)alloca ( num_listners * sizeof ( OM_S_OBJECT_LINKAGE ) );
      stat_OM = om$get_channel_objects ( objid = compid.objid, osnum = compid.osnum,
         p_chanselect = &to_listner, list = listners, size = num_listners,
         count = &num_listners);
      EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_Fail, ret_end );
      compid.objid = listners[0].S_objid;
      compid.osnum = listners[0].osnum;
    }
    else
      goto ret_end;
  }
  
  /*
   * Get the children.
   */
    
  stat_OM = om$send (msg = message NDnode.NDget_objects (ND_CHILDREN,
        NULL, 0, NULL, 0, MAXINT, &num_children), 
        senderid = NULL_OBJID, targetid = compid.objid, targetos = compid.osnum);
  EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);
  if (num_children)
  {
    children = (struct GRid *) alloca (num_children*sizeof(struct GRid));
    stat_OM = om$send (msg = message NDnode.NDget_objects (ND_CHILDREN,
        children, num_children, NULL, 0, MAXINT, &num_children), 
        senderid = NULL_OBJID, targetid = compid.objid, targetos = compid.osnum);
    EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);
    /*
     * for each EMSsurface child, determine its children and check if any 
     * are EMSsurface class.
     */
    for (i=0; i<num_children && !feature_found; i++)
    {
      om$get_classid (objid = children[i].objid, osnum = children[i].osnum,
                      p_classid = &child_class);
      if (om$is_ancestry_valid(subclassid = child_class, 
                               superclassid = OPP_EMSsurface_class_id) == OM_S_SUCCESS)
      {
        stat_OM = om$send (msg = message NDnode.NDget_objects (ND_CHILDREN,
            NULL, 0, NULL, 0, MAXINT, &num_grand_children), 
            senderid = NULL_OBJID, targetid = children[i].objid, targetos = children[i].osnum);
        EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);
        if (num_grand_children)
        {
          grand_children = (struct GRid *) alloca (num_grand_children*sizeof(struct GRid));
          stat_OM = om$send (msg = message NDnode.NDget_objects (ND_CHILDREN,
              grand_children, num_grand_children, NULL, 0, MAXINT,
              &num_grand_children), 
              senderid = NULL_OBJID, targetid = children[i].objid, targetos = children[i].osnum);
          EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);
          
          for (j=0; j < num_grand_children && !feature_found; j++)
          {
            om$get_classid(objid = grand_children[j].objid, osnum = grand_children[j].osnum, 
                           p_classid = &grand_child_class);
            if (om$is_ancestry_valid (subclassid = grand_child_class, 
                  superclassid = OPP_EMSsurface_class_id) == OM_S_SUCCESS)
            {
              feature_found = TRUE;
            }
          }
        }
      }
    }
  }
  
ret_end:
  EMWRAPUP (*msg, stat_OM, "ECfeature_exists");
  return feature_found;
}
#endif
