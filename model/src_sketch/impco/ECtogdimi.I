/*

Name
  ECtogdim

Abstract
  Execute method to change a driving dimension to driven and vice versa.
  
Synopsis

Description

Return Value

Notes

Index

Keywords
  dimension,profile

History
  03/04/93 : Rajiv Agrawal : Changed the symbology of the dimension when it was
             changed to driving to be the same as what it was before.  Somehow 
             EMcreate_dimension_constraint changes the layer to the profile layer.
  09/11/93 : Rajiv Agrawal : Added a call to SKsplit_profile after the constraint
             is deleted.
  12/27/93 : Rajiv Agrawal : Added support for 3D explicit constraints.
  01/10/94 : Rajiv Agrawal : Implemented CIRCULAR_DIAMETER & LINEAR_DIAMETER cases.  

 */
class implementation ECtogdim;

#include <values.h>
#include "nddef.h"
#include "ndmacros.h"
#include "dimdload.h"
#include "dimdef.h"
#include "dim.h"
#include "dimmacros.h"
#include "dimplcmacros.h"
#include "DIglob.h" 
#include "DIprims.h"
#include "SKdef.h"
#include "SKmacros.h"
#include "EMSasmacros.h"
#include "ECmsg.h"
#include "ECcmd.h"

#define GET_DIM		0
#define PROCESS		1

extern GRclassid OPP_DMdim_class_id, OPP_GRvg_class_id;
extern GRclassid OPP_SKexplicit_class_id, OPP_EMSlndmcnstr_class_id, 
                 OPP_EMSangcnstr_class_id;

from GRgraphics   import GRdisplay, GRdelete;
from DMroot       import get_info;
from GRowner      import GRget_components;
from expression   import modify;
from SKconstraint import SKgetprops, SKgetmgr;
from GRvg         import GRchgprops, GRgetsymb, GRchglevel;


method execute ( int *response; char *response_data; int pos )
{
  IGRboolean         make_driving = FALSE, is_vg = FALSE;
  unsigned short     cnstr_type;
  int                eventsize, object_was_located, display_flag;
  long               locate_mask, accept_mask, msg_loc, stat_OM;
  GRclassid          eliclass[4], eleclass;
  struct GRevent     accept_event;
  struct GRlc_locate attributes;
  struct GRid        eleid, cnstrid, mgr;
  struct GRmd_env    *env = NULL;
  struct diminfo     diminfo;
  struct GRsymbology symb;
  OM_S_CLASSLIST     elig_classes, rtree_classes;
  OM_S_CHANSELECT    chan_to_comps;

  stat_OM = OM_S_SUCCESS;
  ex$message ( msgnumb = EM_M_ToggleDimensionDrivenDriving);
  eventsize = sizeof (struct GRevent);

  do
  {
    switch (ME.super_cmd->state)
    {
    case GET_DIM:
      display_flag = ALL_WINDOWS | ELEM_HILIGHT;
      locate_mask = GRm_DATA | GRm_BACK_UP;
      accept_mask = GRm_DATA;
      attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_WRITE_ONLY;
      attributes.owner_action = LC_RIGID_OWNER | LC_HANDLES |
                                LC_NO_REF_HEADER | LC_REF_OBJECTS;

      elig_classes.w_count = 4;
      elig_classes.w_flags = OM_CLST_subclass;
      elig_classes.p_classes = eliclass;
      eliclass[0] = OPP_SKexplicit_class_id;
      eliclass[1] = OPP_EMSlndmcnstr_class_id;
      eliclass[2] = OPP_EMSangcnstr_class_id;
      eliclass[3] = OPP_DMdim_class_id;

      rtree_classes.w_count = 1;
      rtree_classes.w_flags = OM_CLST_subclass;
      rtree_classes.p_classes = &OPP_GRvg_class_id;

      lc$locate(rc = &object_was_located,
                event1 = &me->locate_event,
                event2 = &accept_event,
                mask1 = locate_mask, 
                mask2 = accept_mask,
                eventsize= &eventsize, 
                display_flag = display_flag,
                response = response, 
                response_data = response_data, 
                locate_key = EMS_P_IdentifyDimension, 
                acc_key = EMS_P_AcceptReject,
                relocate_key = EMS_S_DimensionNotFound,
                attributes = &attributes, 
                stack = &me->locate_stack, 
                eligible_classes = &elig_classes,
                rtree_classes = &rtree_classes);

      if (!object_was_located)
        goto ret_end;
      else
      {
        me->ele_info = accept_event.located_object[0];
        eleid = me->ele_info.located_obj;
        env = &me->ele_info.module_info;
        om$get_classid (objid = eleid.objid, osnum = eleid.osnum,
                        p_classid = &eleclass);
        make_driving = FALSE;
        if (om$is_ancestry_valid (superclassid = OPP_DMdim_class_id,
                                  subclassid = eleclass) == OM_S_SUCCESS )
        {
          short action = 0, mask = GR_RIGID_RELATIONSHIP;
          
          make_driving = TRUE;
          
          /* That guy is NOT a rigid owner */
          stat_OM = om$send ( msg = message GRvg.GRchgprops ( &msg_loc, &action, &mask ),
              targetid = eleid.objid,
              targetos = eleid.osnum );
          EMerr_hndlr ( EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end );
        }

        ME.super_cmd->state = PROCESS;
      }
      break;

    case PROCESS:
      dp$erase_hilite (msg = &msg_loc);

      if (make_driving)
      {
        stat_OM = om$send (msg = message DMroot.get_info ((int *) &msg_loc, 
                                 env, &diminfo), 
                           targetid = eleid.objid,
                           targetos = eleid.osnum);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
        
        stat_OM = om$send  ( msg = message GRvg.GRgetsymb (&msg_loc, &symb),
                             targetid = eleid.objid,
                             targetos = eleid.osnum);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
           

        switch (diminfo.dim_type)
        {
        case STACKED_LINEAR:
        case STRINGED_LINEAR:
        case SYMMETRICAL_DIAMETER:
        case SINGLE_PARALLEL:
        case STACKED_ANGULAR:
        case STRINGED_ANGULAR:
        case RADIAL:
        case RADIAL_DIAMETER:
        case CIRCULAR_DIAMETER:
        case LINEAR_DIAMETER:
          sk$create_dimension_constraint( msg = &msg_loc,
                                          module = env, 
                                          dim_grid = &eleid,
                                          cnstr_grid = &cnstrid,
                                          cnstr_type = &cnstr_type);
          EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

          if (msg_loc == EMS_I_Redundant)
          {
            ex$message ( msgnumb = EMS_S_ConflictingConstraints);
          }
          else if (msg_loc == EMS_I_BadElement)
          {
            ex$message ( msgnumb = EMS_S_MeasureElementNotParametric);
          }
          else if (msg_loc == EMS_I_BadPlane)
          {
            ex$message ( msgnumb = EMS_S_IncompatDimPlane);
          }
          else if (msg_loc == EMS_I_NotSupported)
          {
            ex$message ( msgnumb = EMS_S_DimConstraintNotSupported);
          }
          else if (msg_loc != EMS_S_Success &&
                   msg_loc != EMS_I_FullyConstrained)
          {
            ex$message ( msgnumb = EMS_S_ConstraintCouldNotBePlaced);
          }
          else
          {
            if (msg_loc == EMS_I_FullyConstrained)
            {
              ex$message ( msgnumb = EMS_S_FullyConstrained);
            }

            dm$set_type (type = DIM_DRIVING |
                (cnstr_type & SK_DIMCNSTR_UNIDIR ? DIM_DIRECTED : NULL),
                update = TRUE, md_env = env, dim_grid = &eleid);

            stat_OM = om$send (msg = message GRvg.GRchglevel (&msg_loc, &symb.level),
                               targetid = eleid.objid,
                               targetos = eleid.osnum);
            EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, EMS_E_Fail, ret_end);
          }
          break;

        default:
          ex$message ( msgnumb = EMS_S_DimConstraintNotSupported);
          break;
        }
      }
      else
      {
        is_vg = om$is_ancestry_valid (superclassid = OPP_SKexplicit_class_id,
                                      subclassid = eleclass) == OM_S_SUCCESS;
        if (is_vg) 
        {
          om$send (msg = message SKconstraint.SKgetmgr ( &msg_loc, &mgr.objid ), 
                   targetid = eleid.objid, 
                   targetos = eleid.osnum);
          mgr.osnum = eleid.osnum;
        }

        dm$set_type (type = DIM_DRIVING, update = TRUE, op_code = BIT_CLEAR,
                     md_env = env, dim_grid = &eleid);

        EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
        om$send (msg = message Root.wild_disconnect (chan_to_comps),
                 targetid = eleid.objid, targetos = eleid.osnum);

        om$send (msg = message GRgraphics.GRdelete (&msg_loc, env),
                 targetid = eleid.objid, targetos = eleid.osnum);

        /*
         * Check if the profile split due to the above constraint deletion.
         */
        if (is_vg)
          SKsplit_profile ( &msg_loc, &mgr );
      }

      ME.super_cmd->state = GET_DIM;
      break;

    default:
      stat_OM = OM_E_ABORT;
      goto ret_end;
    }
  } while (TRUE);

ret_end:
  if (EMSerror ( stat_OM ))
    *response = TERMINATE;

  return stat_OM;
}

end implementation ECtogdim;
