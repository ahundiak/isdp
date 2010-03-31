class implementation ECskmgr;
/*

Name
  ECskmgr methods

Abstract
  Command object to implement commands that work on a profile.
  
Synopsis

Description
  The following commands are implemented here:
  
  Calculate Profile
  Undo Profile
  Show Underconstrained Profile
  Convert to Profile
  Close Profile
  Toggle Geometric Constraint Display
  
Return Value

Notes

Index

Keywords

History
  07/26/93 : Rajiv Agrawal : created documentation header and started using 
                             EFconvert_to_profile function.
  09/08/93 : Rajiv Agrawal : Added an options form to the Convert to Profile command.
  09/15/93 : Rajiv Agrawal : Added a call to SKcalculate_profile to compute and removed lot
                             of duplicate code.
  12/21/93 : Rajiv Agrawal : Added code to toggle the display of SKpoints belonging to other
                             geometric elements.
  08/15/94 : scw           : clarified sleep method
  
  08/16/95 : Ramana	   : Added emsdef.h as bsvalues.h is changed and
			     removed values.h.
 */

#include <math.h>
#include <alloca.h>
#include "bsvalues.h"
#include "emsdef.h"
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSdatumdef.h"
#include "EMdtmacros.h"
#include "EMSopt.h"
#include "SKdef.h"
#include "SKinc.h"
#include "SKmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DImacros.h"
#include "DIprims.h"
#include "FI.h"
#include "expression.h"
#include "expmacros.h"
#include "comisc.h"
#include "ECmsg.h"
#include "ECcmd.h"

#define FIRST  		0

#define COMPUTE_CMD	 0
#define UNDO_CMD	 1
#define UNCNSTR_CMD	 2
#define CONVERTPROF_CMD	 3
#define CLOSEPROF_CMD    4
#define TOGGEOMCNSTR_CMD 5

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMSparamgm_class_id;
extern GRclassid OPP_GRcurve_class_id, OPP_GRbspline_class_id, OPP_GAbspline_class_id;
extern GRclassid OPP_SKmgr_class_id, OPP_SKgeometry_class_id,
                 OPP_GR3dpoint_class_id, OPP_GR3dlineseg_class_id,
                 OPP_GR3dcircle_class_id, OPP_GR3dcirarc_class_id,
                 OPP_GA3dpoint_class_id, OPP_GA3dlineseg_class_id,
                 OPP_GA3dcircle_class_id, OPP_GA3dcirarc_class_id,
                 OPP_GRcompcurve_class_id;

from NDnode 	import NDget_objects;
from GRgraphics import GRdisplay, GRgetprops, GRchgprops;
from GRvg	import GRgeomprops;
from SKmgr 	import SKundo, SKdisplay_underconstrained, SKgetvarconstrs;
from SKmgr 	import SKmgrprops, SKundo_dimval;
from SKmgr 	import SKgeom_update, SKconstr_update;
from SKcompcurve import SKclose;
from SKgeometry import SKgetmgr;
from EMSdatpln 	import EMget_pln_info;
from EMSparamgm import EMdisplay_underconstrained;
from expression import NDgive_value;
from GRowner    import GRget_number_components, GRget_components;

method execute ( int *response; char *response_data; int pos )
{
  IGRboolean             stat_func;
  IGRushort		 options, geom_type;
  char                   elename [DI_PATH_MAX], *p_acceptmsg, acceptmsg[MAX_CHAR];
  short                  grprops, turnon;
  OMuint 		 num_geoms;
  int                    i, stat_OM, cmdtype, batch_mode, num_children, num_comps;
  int                    num_cnstrs, num_conflict_cnstr, ref_lock_state;
  int                    plane_lock_was_off = 0;
  long                   msg_loc;
  long			 accept_mask, eventsize;
  GRobjid                obj;
  GRspacenum             dumos;
  GRclassid              eleclass;
  GRobjid 		 *conflict_cnstr_objs = NULL;
  struct GRid            *children, ptobj, *comp_list;
  struct GRmd_env        *env;
  struct SKconstrinfo    *cnstrs;
  struct GRevent	 accept_event;
  enum EMSuser_responses useract;
  enum GRdpmode          dpmode;
  struct GRid            eleid;
  OM_S_CHANSELECT        chan_to_comps, to_geometries, to_defpts;
  GRspacenum osn;
  IGRboolean aflag = 0;
  IGRboolean RFlocate_ref_profile_handler();
  extern void 		 SKgetgeomtype();

  aflag = pwIsActivationOn();
  cnstrs = NULL;

  cmdtype = ME.super_cmd->mytype;
  if (cmdtype == COMPUTE_CMD)
  {
    ex$message ( msgnumb = EM_M_CalculateProfile);
  }
  else if (cmdtype == UNDO_CMD)
  {
    ex$message ( msgnumb = EM_M_UndoProfile);
  }
  else if (cmdtype == UNCNSTR_CMD)
  {
    ex$message ( msgnumb = EM_M_ShowUnderConstrainedProfile);
  }
  else if (cmdtype == CONVERTPROF_CMD)
  {
    ex$message ( msgnumb = EM_M_ConvertToProfile);
    ex$message ( msgnumb = EMS_I_InvkStatusFrm);
  }
  else if (cmdtype == CLOSEPROF_CMD)
  {
    ex$message ( msgnumb = EM_M_CloseProfile);
  }
  else if (cmdtype == TOGGEOMCNSTR_CMD)
  {
    ex$message ( msgnumb = EM_M_ToggleGeometricConstraintDisplay);
  }
  
  env = &ME.ECelements->elems[0].module_info;
  do
  {
    ME.ECelements->num_elems = 0;

    if (cmdtype == CONVERTPROF_CMD)
    {
      ems$ref_plane_lock ( msg = &msg_loc, 
          options = EMS_REF_PLANE_LOCK_INQ, mode = &ref_lock_state );
      if (!(ref_lock_state & EMS_REF_PLANE_LOCK_ON))
        plane_lock_was_off = 1;
      ems$ref_plane_lock(msg = &msg_loc, 
          options = EMS_REF_PLANE_LOCK_ON | EMS_REF_PLANE_LOCK_SET,
          mode = &ref_lock_state );

      ex$message (buff = elename, msgnumb = EMS_P_Curve);
      ex$message (buff = acceptmsg, msgnumb = EMS_P_InOrientedWindow);
      p_acceptmsg = NULL;
    }
    else if (cmdtype == CLOSEPROF_CMD)
    {
      ex$message (msgnumb = EMS_P_CompositeProfile, buff = elename);
      p_acceptmsg = NULL;
    }
    else
    {
      ex$message (msgnumb = EMS_P_Profile, buff = elename);
      p_acceptmsg = NULL;
    }
 
    if (aflag)
    {
      /* Add action handler */
      osn = pwGetActiveOs();
      
      me->acthndlr_args = (char *)&osn;
      me->acthndlr = RFlocate_ref_profile_handler;
    }

    me->display_flag = ALL_WINDOWS | ELEM_HILIGHT;
    stat_OM = om$send (msg = message ECelements.do_locate (&msg_loc,
        &useract, response, response_data, elename, NULL,
        NULL, p_acceptmsg, NULL, NULL), targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

    if (!ME.ECelements->num_elems)
      goto ret_end;

    eleid = ME.ECelements->elems[0].located_obj;
    om$get_classid (objid = eleid.objid, osnum = eleid.osnum,
                    p_classid = &eleclass);
    if (om$is_ancestry_valid (subclassid = eleclass,
         superclassid = OPP_SKmgr_class_id) == OM_S_SUCCESS)
      ME.ECskmgr->is_vg = TRUE;
    else
      ME.ECskmgr->is_vg = FALSE;

    if (cmdtype == UNDO_CMD)
    {
      stat_OM = om$send (msg = message SKmgr.SKundo (&msg_loc, NULL, env),
          targetid = eleid.objid, targetos = eleid.osnum);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

      if (msg_loc == EMS_I_NoResponse)
      {
        ex$message ( msgnumb = EMS_S_PrevStateNotKnown);
      }
    }
    else if (cmdtype == COMPUTE_CMD)
    {
      stat_OM = om$send (msg = message SKmgr.SKmgrprops (&msg_loc, 
          SK_CHGPROPS_ON, SK_MGR_OUTOFDATE, NULL),
          targetid = eleid.objid, targetos = eleid.osnum);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

      options = SK_UPDATE_IMPCONSTRS | SK_UPDATE_EXPCONSTRS | 
                SK_UPDATE_DRAW | SK_UPDATE_ERASE;

      stat_OM = SKcalculate_profile (&msg_loc, options, env, &eleid);

      num_children = 0;
      stat_OM = om$send (msg = message NDnode.NDget_objects 
          (ND_CHILDREN | ND_IN_BUF, NULL, 0, &children, 0, MAXINT,
          &num_children), 
          targetid = eleid.objid, targetos = eleid.osnum);
      EMomerr_exit (stat_OM, ret_end);

      nd$wait_batch (type = GR_GEOM_POSTED, 
          l_object = children, nb_obj = num_children);
      nd$mod_batch (request = ND_INQ, p_ret_mode = &batch_mode);
      if (batch_mode == ND_IMMEDIATE)
        nd$exec_batch();
    }
    else if (cmdtype == UNCNSTR_CMD)
    {
      dp$erase_hilite ( msg = &msg_loc );
      ME.ECelements->elems_hilit = FALSE;
      if (ME.ECskmgr->is_vg)
      {
        int dof;
        stat_OM = SKget_degrees_of_freedom (&msg_loc, eleid, &dof);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
        if (!dof)
        {
          ex$message ( msgnumb = EMS_S_FullyConstrained );
        }
        else
        {
          ex$message ( msgnumb = EMS_S_NoOfDegreesOfFreedom, type = "%d", var = `dof` );
          ex$message ( msgnumb = EMS_P_IdentifyProfMoveOnforGhost );
          accept_mask = GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP;
          stat_func = co$getevent (msg = &msg_loc, event_mask = accept_mask,
                                   response = response, response_data = response_data,
                                   event = &accept_event);
          EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
    
          switch (accept_event.response)
          {
            case EX_RJT_MOVEON:
              stat_OM = om$send (msg = message SKmgr.SKdisplay_underconstrained 
                                       (&msg_loc, NULL, env), 
                                 targetid = eleid.objid, 
                                 targetos = eleid.osnum);
              EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
              if (msg_loc == EMS_I_Redundant)
              {
                ex$message ( msgnumb = EMS_S_ConflictingConstraints );
              }
              break;
            
            case EX_BACK_UP:
              break;
            
            case EX_DATA:
              eventsize = sizeof(struct GRevent);
              ex$putque (msg = &msg_loc, response = &accept_event.response,
                         byte = &eventsize, 
                         buffer = (char *) &accept_event.event);
              break;

            default:
              eventsize = sizeof(struct GRevent);
              ex$putque (msg = &msg_loc, response = &accept_event.response,
                         byte = &eventsize, 
                         buffer = (char *) &accept_event.event);
              goto ret_end;
          }
        }
      }
      else 
      {
        stat_OM = om$send (msg = message EMSparamgm.EMdisplay_underconstrained 
                                 (&msg_loc, NULL, env), 
                           targetid = eleid.objid, 
                           targetos = eleid.osnum);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
        if (msg_loc == EMS_I_FullyConstrained)
        {
          ex$message ( msgnumb = EMS_S_FullyConstrained);
        }
      }
    }
    else if (cmdtype == CONVERTPROF_CMD)
    {
      GRclassid classid;
      
      /*
       * Check the class of the selected element.  If its already a profile,
       * add constraints to it ... else call convert it to profile.
       */
      classid = OM_K_NOTUSING_CLASSID;
      om$get_classid ( osnum = eleid.osnum,
                       objid = eleid.objid,
                       p_classid = &classid );
      
      if (om$is_ancestry_valid (subclassid = classid,
                                superclassid = OPP_SKmgr_class_id) == OM_S_SUCCESS)
      {
        stat_OM = SKauto_constrain (&msg_loc, NULL, env, eleid, NULL);
        EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
      }
      else
      {
        sk$convert_to_profile ( msg = &msg_loc, 
                                options = SK_CONVERT_VERBOSE,
                                module = env, 
                                geometry = eleid);
      }
    }
    else if (cmdtype == CLOSEPROF_CMD)
    {
      stat_OM = om$send (msg = message SKcompcurve.SKclose (&msg_loc, NULL, 
                               env, &num_conflict_cnstr, &conflict_cnstr_objs),
                         targetid = eleid.objid, targetos = eleid.osnum);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

      if (msg_loc == EMS_I_Redundant)
      {
        dpmode = GRhd;
        ex$message ( msgnumb = EMS_S_ConflictingConstraints);
        for (i=0; i<num_conflict_cnstr; i++)
          om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
              &env->md_env.matrix_type, env->md_env.matrix, &dpmode,
              &env->md_id), targetid = conflict_cnstr_objs[i], 
              targetos = eleid.osnum);

        if (conflict_cnstr_objs)
        {
          om$dealloc (ptr = conflict_cnstr_objs);
          conflict_cnstr_objs = NULL;
        }
      }
      else
      {
        num_children = 0;
        stat_OM = om$send (msg = message NDnode.NDget_objects 
            (ND_CHILDREN | ND_IN_BUF, NULL, 0, &children, 0, MAXINT,
            &num_children), 
            targetid = eleid.objid, targetos = eleid.osnum);
        EMomerr_exit (stat_OM, ret_end);
  
        nd$wait_batch (type = GR_GEOM_POSTED, 
            l_object = children, nb_obj = num_children);
        nd$mod_batch (request = ND_INQ, p_ret_mode = &batch_mode);
        if (batch_mode == ND_IMMEDIATE)
          nd$exec_batch();
      }
    }
    else if (cmdtype == TOGGEOMCNSTR_CMD)
    {
      num_cnstrs = 0;
      cnstrs = NULL;
      stat_OM = om$send (msg = message SKmgr.SKgetvarconstrs (&msg_loc,
                               SK_GETCN_HNDL | SK_GETCN_IMPLICIT, NULL,
                               &num_cnstrs, &cnstrs),
                         targetid = eleid.objid, 
                         targetos = eleid.osnum);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
      if (!num_cnstrs)
        continue;

      /*
       * Determine the current state of constraints - whether ON or OFF.
       */
      EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);


      for (i = 0; i < num_cnstrs; i++)
      {
        obj = NULL_OBJID;
        om$get_objid_at_index ( objid = cnstrs [i].constrid,
            osnum = eleid.osnum, p_chanselect = &chan_to_comps, index = FIRST, 
            objidaddr = &obj, osnumaddr = &dumos );
        if (obj != NULL_OBJID)
          break;
      }

      if (IF_NULL_OBJID (obj))
      {
        ex$message ( msgnumb = EMS_S_InvalidProfile);
        continue;
      }
      om$send (msg = message GRgraphics.GRgetprops (&msg_loc, &grprops),
               targetid = obj, targetos = eleid.osnum);
      if (grprops & GRIS_DISPLAYABLE)
        turnon = FALSE;
      else
        turnon = TRUE;

      grprops = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
      for (i=0; i<num_cnstrs; i++)
      {
        if (turnon)
        {
          om$send (msg = message GRgraphics.GRchgprops 
                         (&msg_loc, &turnon, &grprops), 
                   targetid = cnstrs[i].constrid, 
                   targetos = eleid.osnum);

          dpmode = GRbd;
          om$send (msg = message GRgraphics.GRdisplay 
                         (&msg_loc, &env->md_env.matrix_type, 
                         env->md_env.matrix, &dpmode, &env->md_id), 
                   targetid = cnstrs[i].constrid, 
                   targetos = eleid.osnum);
        }
        else
        {
          dpmode = GRbe;
          om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                         &env->md_env.matrix_type, env->md_env.matrix, &dpmode,
                         &env->md_id), 
                   targetid = cnstrs[i].constrid, 
                   targetos = eleid.osnum);

          om$send (msg = message GRgraphics.GRchgprops 
                         (&msg_loc, &turnon, &grprops), 
                   targetid = cnstrs[i].constrid, 
                   targetos = eleid.osnum);
        }
      }

      om$dealloc (ptr = cnstrs);
      cnstrs = NULL;
      /*
       * Toggle the display of SKpoints that are attached to other geometries
       * i.e. arcs, circles and bsplines.
       */
      stat_OM = om$send  ( msg =  message GRowner.GRget_number_components 
                                  (&msg_loc, &num_comps),
                           targetid = eleid.objid, targetos = eleid.osnum);
      EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
        
      comp_list = (struct GRid *) alloca (num_comps * sizeof (struct GRid));
      stat_OM = om$send (msg = message GRowner.GRget_components (&msg_loc, NULL, 
                               comp_list, num_comps, &num_comps, 0, MAXINT),
                         targetid = eleid.objid, targetos = eleid.osnum);
      EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
  
      EMmake_chanselect ( SKvariable_to_geometries, &to_geometries );
      EMmake_chanselect ( SKgeometry_to_defpts, &to_defpts );
      for (i = 0; i < num_comps; i++) 
      {
        SKgetgeomtype(comp_list[i].objid, comp_list[i].osnum, &geom_type);
        if (!(geom_type & SK_POINT)) 
          continue;
        stat_OM = om$get_objid_at_index ( objid = comp_list[i].objid,
                                          osnum = comp_list[i].osnum,
                                          p_chanselect = &to_defpts,
                                          index = 0,
                                          objidaddr = &ptobj.objid, 
                                          osnumaddr = &ptobj.osnum );
        if (!(stat_OM & 1)) goto ret_end;
        stat_OM = om$get_channel_count ( osnum = ptobj.osnum, 
                                         objid = ptobj.objid, 
                                         p_chanselect = &to_geometries,
            				 count = &num_geoms );
        if (num_geoms > 1)
        {
          if (turnon) 
          {
            om$send (msg = message GRgraphics.GRchgprops 
                           (&msg_loc, &turnon, &grprops), 
                     targetid = comp_list[i].objid, 
                     targetos = comp_list[i].osnum);
  
            dpmode = GRbd;
            om$send (msg = message GRgraphics.GRdisplay 
                           (&msg_loc, &env->md_env.matrix_type, 
                           env->md_env.matrix, &dpmode, &env->md_id), 
                     targetid = comp_list[i].objid, 
                     targetos = comp_list[i].osnum);
          }
          else 
          {
             om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                             &env->md_env.matrix_type, env->md_env.matrix, &dpmode,
                             &env->md_id), 
                      targetid = comp_list[i].objid, 
                      targetos = comp_list[i].osnum);
    
             om$send (msg = message GRgraphics.GRchgprops 
                             (&msg_loc, &turnon, &grprops), 
                      targetid = comp_list[i].objid, 
                      targetos = comp_list[i].osnum);
          }
        }
      }        
    }
    else
    {
      ex$message ( msgnumb = EMS_S_NoSuchCommand );
    }
  }  while (TRUE);

ret_end:
  if (plane_lock_was_off)
    ems$ref_plane_lock ( msg = &msg_loc, 
        options = EMS_REF_PLANE_LOCK_OFF | EMS_REF_PLANE_LOCK_SET );

  if (cnstrs)
    om$dealloc (ptr = cnstrs);

  if (EMSerror (stat_OM))
  {
    ex$message ( msgnumb = EMS_S_ErrorInCommand);
    *response = TERMINATE;
  }

  return stat_OM;
}


method get_locate_criteria (long *msg; int maxnum_classes;
                            OM_S_CLASSLIST *rtree_classes, *elig_classes,
                            *nelig_classes; unsigned short *geomprops;
                            short *operation; unsigned short *options;
                            int *minnum_to_locate, *maxnum_to_locate)
{
  int cmdtype;
  long stat_OM;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  cmdtype = ME.super_cmd->mytype;

  rtree_classes->w_count = 1;
  rtree_classes->w_flags = OM_CLST_subclass;
  if (cmdtype == CONVERTPROF_CMD || cmdtype == UNCNSTR_CMD)
    rtree_classes->p_classes[0] = OPP_GRbspline_class_id;
  else
    rtree_classes->p_classes[0] = OPP_SKgeometry_class_id;

  elig_classes->w_count = 1;
  elig_classes->w_flags = OM_CLST_subclass;
  if (cmdtype == CONVERTPROF_CMD)
  {
    elig_classes->p_classes[0] = OPP_GRcompcurve_class_id;
    elig_classes->p_classes[1] = OPP_GRbspline_class_id;
    elig_classes->p_classes[2] = OPP_SKmgr_class_id;
    elig_classes->w_count = 3;
  }
  else if (cmdtype == UNCNSTR_CMD)
  {
    elig_classes->p_classes[0] = OPP_SKmgr_class_id;
    elig_classes->p_classes[1] = OPP_EMSparamgm_class_id;
    elig_classes->w_count = 2;
  }
  else if (cmdtype == CLOSEPROF_CMD)
    elig_classes->p_classes[0] = OPP_SKcompcurve_class_id;
  else 
    elig_classes->p_classes[0] = OPP_SKmgr_class_id;

  nelig_classes->w_count = 0;

  *geomprops = NULL;
  *operation = EC_GEOM_CHGSHAPE;
  *options = EC_LOC_NOFLEXGROUPS | EC_LOC_NOHALFHILITE;
  if ( ME.super_cmd->mytype == CLOSEPROF_CMD)
    *options = *options | EC_LOC_RIGIDCOMPOK | EC_LOC_READONLYOK;
  else
    *options = *options | EC_LOC_ASSOCOK | EC_LOC_EXTCONSTOK;   

  *minnum_to_locate = 1;
  *maxnum_to_locate = 1;

  return stat_OM;
}

method init (IGRint type; IGRchar *string)
{
  IGRlong 	  stat_OM; 

  stat_OM = OM_S_SUCCESS;

  stat_OM = om$send (mode = OM_e_wrt_message, 
                     msg = message ECelements.init(type, string), 
                     targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);

  me->form_ptr = NULL;


ret_end:
  return stat_OM;
}

static void AutoUpdateForm();

method status_disp()
{
  extern int  ConvertProcessForm(), SKget_auto_mask();

  if (ME.super_cmd->mytype == CONVERTPROF_CMD)
  {
    if (!me->form_ptr)
    {
      FIf_new ( 0, "GRAutoCnstr", ConvertProcessForm, &me->form_ptr);
      FIf_set_cmd_oid_os (me->form_ptr, my_id, OM_Gw_current_OS);

      /* gadget 5 is the save-restore gadget - suppress it */
      FIg_erase   ( me->form_ptr, 5 );
      FIg_disable ( me->form_ptr, 5 );
    }
    
    me->auto_mask = SKgetautomask();
    AutoUpdateForm (me->form_ptr, me->auto_mask);
    FIf_display (me->form_ptr);
  }

  return OM_S_SUCCESS;
}

method wakeup (IGRint pos)
{
  IGRboolean  assoc_flag;

  om$send (mode = OM_e_wrt_message, 
           msg = message ECelements.wakeup (pos), 
           targetid = my_id);  

  if (me->mytype == CONVERTPROF_CMD)
  {
    gr$get_associative_flag( buffer = &assoc_flag );
 
    if (assoc_flag)
      GRdisplay_associative_button(TRUE);
    GRstatus_display_button (TRUE);
  }
  
  return OM_S_SUCCESS;
}

method super_cmd.sleep (IGRint pos)
{
  long msg_loc;
  
  om$send (mode = OM_e_wrt_message, 
           msg = message ECelements.sleep (pos), 
           targetid = my_id);  

  if (me->mytype == CONVERTPROF_CMD)
  {
    GRdisplay_associative_button (FALSE);
    GRstatus_display_button (FALSE);
  }

  dp$erase_hilite ( msg = &msg_loc );

  return OM_S_SUCCESS;
}

method delete (int flag)
{
  long stat_OM;

  stat_OM = OM_S_SUCCESS;

  if (ME.super_cmd->mytype == CONVERTPROF_CMD)
  {
    if (me->form_ptr)
    {
      FIf_erase (me->form_ptr);
      FIf_delete (me->form_ptr);
      me->form_ptr = NULL;
    }
  }

  stat_OM = om$send (mode = OM_e_wrt_message, 
                     msg = message ECelements.delete (flag), 
                     targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);

ret_end:
  return stat_OM;
}

#argsused
int ConvertProcessForm ( FormLabel, GadgetLabel, Value, form_ptr )
int    FormLabel;
int    GadgetLabel;
double Value;
Form   form_ptr;
{
  IGRlong msg_loc;
  GRobjid cmdobj;
  GRspacenum cmdos;

  FIf_get_cmd_oid_os (form_ptr, &cmdobj, &cmdos);

  om$send (msg = message ECskmgr.do_form (&msg_loc, GadgetLabel),
           senderid = NULL_OBJID, 
           targetid = cmdobj, 
           targetos = cmdos);
  return OM_S_SUCCESS;
}

#define ACCEPTFORM_STATE    1
#define KILLFORM_STATE	    4
#define CLEAR_ALL	   12
#define SET_ALL            13

method do_form (long *msg; int GadgetLabel)
{
  GRspacenum Osnum;
  char       Syntax [DI_PATH_MAX];
  GRobjid    Objid;
  int        stat_OM, sMask;
  
  switch (GadgetLabel)
  {
    case ACCEPTFORM_STATE:
      /*
       * Save the settings in IGENOD:AutoConstrain
       */
      ex$get_cur_mod ( osnum = &Osnum );
      di$cd ( osnum = Osnum, dirname = "IGENOD" );
      sprintf ( Syntax, "%d", me->auto_mask );
      stat_OM = di$translate ( osnum = Osnum, path = "IGENOD",
                               objname = "AutoConstrain", p_objid = &Objid );
      if (stat_OM & 1)
      {
        exp$modify ( exp_name = "AutoConstrain", osnum = Osnum, exp_syntax = Syntax );
      }
      else
      {
        exp$create ( exp_name = "AutoConstrain", osnum = Osnum, exp_syntax = Syntax,
                     p_exp_id= &Objid );
      }
      di$cd ( dirname = "-" );
      di$cd ( dirname = "." );

    case KILLFORM_STATE:
      FIf_erase ( me->form_ptr );
      break;

    case CLEAR_ALL:
      me->auto_mask = 0x00;
      for (sMask = SK_AUTO_HORIZONTAL; sMask != SK_AUTO_LASTONE; sMask <<= 1)
        FIg_set_state_off ( me->form_ptr, sMask + 20 );
      break;

    case SET_ALL:
      me->auto_mask = 0xff;
      for (sMask = SK_AUTO_HORIZONTAL; sMask != SK_AUTO_LASTONE; sMask <<= 1)
        FIg_set_state_on ( me->form_ptr, sMask + 20 );
      break;
    
    default:
      /*
       * We check all the possible constrains against GadgetLabel + 20
       */
      for (sMask = SK_AUTO_HORIZONTAL; sMask != SK_AUTO_LASTONE; sMask <<= 1)
        if (GadgetLabel == sMask + 20)
        {
          if (me->auto_mask & sMask)
            me->auto_mask &= ~sMask;
          else    
            me->auto_mask |= sMask;
          break;
        }
      AutoUpdateForm (me->form_ptr, me->auto_mask);
  }
  
  return OM_S_SUCCESS;
}

static void AutoUpdateForm (Form AutoForm, int AutoMask)
/*
 * This procedure updates the auto-constrain form according to the current mask setting.
 */
{
  int sMask;
  
  for (sMask = SK_AUTO_HORIZONTAL; sMask != SK_AUTO_LASTONE; sMask <<= 1)
    if (AutoMask & sMask)
      FIg_set_state_on ( AutoForm, sMask + 20 );
    else
      FIg_set_state_off ( AutoForm, sMask + 20 );
  
}

int SKgetautomask()
{
  int 		stat_OM;
  GRspacenum 	Osnum;
  GRobjid 	Objid;
  
  ex$get_cur_mod ( osnum = &Osnum );
  stat_OM = di$translate ( osnum = Osnum, path = "IGENOD",
                           objname = "AutoConstrain", p_objid = &Objid );
  if (stat_OM & 1)
  {
    double DoubleMask = 0;

    om$send ( msg = message expression.NDgive_value ( &DoubleMask ),
              targetos = Osnum, targetid = Objid, senderid = NULL_OBJID );
    return ((int) DoubleMask);
  }
  else
    return (0xff);
}

IGRboolean RFlocate_ref_profile_handler(osn, new_entry, locate_args, action)
GRspacenum *osn;
struct  GRlc_info *new_entry;
struct  LC_action_args *locate_args;
enum    GRlocate_action *action;
{
  IGRboolean  call_action_handler = FALSE;
  IGRlong sts = OM_S_SUCCESS;

  switch(*action)
  {
      case add_all:
      case add_inside:
      case add_outside:
      case add_overlap:
      case add_nopost:
      {
         if (new_entry->located_obj.osnum != *osn)
         {
            call_action_handler = FALSE;
         }
         else
         {
            call_action_handler = TRUE;
         }
      }
      break;

      default:
      break;
  }

  /* Call the default action handler */

  if(call_action_handler)
      sts = LCptlocact(NULL, new_entry, locate_args, action);
  else
      sts = OM_S_SUCCESS;

  return(sts);
}

end implementation ECskmgr;

