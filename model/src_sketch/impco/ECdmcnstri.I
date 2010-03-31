class implementation ECdmcnstr;

#include "OMmacros.h"
#include "emsdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dimplcmacros.h"
#include "emserr.h"
#include "EMSmsgnumdef.h"
#include "EMSmsgdef.h"
#include "EMSasnucdef.h"
#include "SKdef.h"
#include "SKmacros.h"
#include "EMSdatumdef.h"
#include "EMdtmacros.h"
#include "ECmsg.h"
#include "ECcmd.h"

#include "madef.h"
#include "maidmx.h"

from SKconstraint import SKgetmgr;
from GRgraphics   import GRdelete, GRchgprops;

method init (int type; char *string)
{
  ME.ECdmcnstr->constraint_GRid.objid = NULL_OBJID;
  ME.ECdmcnstr->props = NULL;
  EFneedthelockon();

  return (om$send (mode = OM_e_wrt_parent, 
      msg = message ECdmcnstr.init (type, string), targetid = my_id));
}

method wakeup (int pos)
{
  int bytes_in, bytes_out, aflag;
  long msg_loc;

  aflag = pwIsActivationOn();
  if(aflag)
  {
    pwGetActiveModuleEnv( &ME.ECdmcnstr->display_env);
  }
  else
  {
    bytes_in = sizeof (struct GRmd_env);
    gr$get_module_env(msg = &msg_loc, sizbuf = &bytes_in,
        buffer = &ME.ECdmcnstr->display_env, nret = &bytes_out);
  }

  EFrefplane_lock_mgr(&msg_loc, NULL, TRUE, &me->ref_plane_lock);

  return (om$send (mode = OM_e_wrt_parent, 
      msg = message ECdmcnstr.wakeup (pos), targetid = my_id));
}

method super_cmd.sleep(int pos)
{
 IGRlong sts,msg;

 sts = OM_S_SUCCESS;
 msg = 1;


  if (!(me->ref_plane_lock))
    EFrefplane_lock_mgr(&msg, NULL, FALSE,NULL);

  return (om$send (mode = OM_e_wrt_parent, 
      msg = message ECdmcnstr.sleep (pos), targetid = my_id));
}

method dimension_driving ()
{
  unsigned short cnstr_type;
  long msg_loc, stat_OM;
  struct GRid constraint_GRid;

  stat_OM = OM_S_SUCCESS;

  ME.ECdmcnstr->constraint_GRid.objid = NULL_OBJID;
  switch (me->mytype)
  {
  case STACKED_LINEAR:
  case STRINGED_LINEAR:
  case SYMMETRICAL_DIAMETER:
  case SINGLE_PARALLEL:
  case STACKED_ANGULAR:
  case STRINGED_ANGULAR:
  case RADIAL:
  case RADIAL_DIAMETER:
    sk$create_dimension_constraint( msg = &msg_loc,
                                    module = &ME.ECdmcnstr->display_env,
                                    dim_grid = &ME.COdmplace->dim_grid,
                                    cnstr_grid = &constraint_GRid,
                                    cnstr_type = &cnstr_type);
    EMerr_hndlr (EMSerror (msg_loc), stat_OM, EMS_E_Fail, ret_end);

    if (msg_loc == EMS_I_Redundant || 
        msg_loc == EMS_I_Cycle ||
        msg_loc == EMS_I_NoSolution ||
        msg_loc == EMS_I_NoStackMemory)
    {
      if (msg_loc == EMS_I_Redundant)
      {
        ex$message (msgnumb = EMS_S_ConflictingConstraints);
      }
      else if (msg_loc == EMS_I_Cycle)
      {
        ex$message (msgnumb = EMS_S_CyclicDependency);
      }
      else if (msg_loc == EMS_I_NoSolution)
      {
        ex$message (msgnumb = EMS_S_SolutionNotFound);
      }
      else 
      {
        ex$message (msgnumb = EMS_S_InsufficientMemory);
      }

      ME.ECdmcnstr->props = DIM_REFERENCE;
      dm$set_type (type = DIM_REFERENCE, md_env = &ME.ECdmcnstr->display_env,
                   dim_grid = &ME.COdmplace->dim_grid, update = TRUE);
    }
    else if (msg_loc == EMS_I_BadElement)
    {
      ex$message (msgnumb = EMS_S_MeasureElementNotParametric);
      ME.ECdmcnstr->props = NULL;
    }
    else if (msg_loc == EMS_I_BadPlane)
    {
      ex$message (msgnumb = EMS_S_IncompatDimPlane);
      ME.ECdmcnstr->props = NULL;
    }
    else if (msg_loc == EMS_I_NotSupported)
    {
      ex$message (msgnumb = EMS_S_DimConstraintNotSupported);
      ME.ECdmcnstr->props = NULL;
    }
    else if (msg_loc != EMS_S_Success && msg_loc != EMS_I_FullyConstrained)
    {
      ex$message (msgnumb = EMS_I_ErrorInConstruction);
      ME.ECdmcnstr->props = NULL;
    }
    else
    {
      if (msg_loc == EMS_I_FullyConstrained)
      {
        ex$message (msgnumb = EMS_S_FullyConstrained);
      }

      ME.ECdmcnstr->constraint_GRid = constraint_GRid;
      ME.ECdmcnstr->props = DIM_DRIVING |
          (cnstr_type & SK_DIMCNSTR_UNIDIR ? 
          DIM_DIRECTED : NULL);
      dm$set_type (type = ME.ECdmcnstr->props,
          md_env = &ME.ECdmcnstr->display_env,
          dim_grid = &ME.COdmplace->dim_grid, update = TRUE);
    }
    break;

  default:
    ex$message (msgnumb = EMS_S_DimConstraintNotSupported );
    ME.ECdmcnstr->props = NULL;
    break;
  }

ret_end:
  return (stat_OM);
}

method delete_dimension()
{
  short               action, grprops;
  long                msg_loc;
  OMuint              count;
  struct GRid         *cnstrid;
  OM_S_CHANSELECT     chan_to_comps;
  OM_S_OBJECT_LINKAGE list [1];

  cnstrid = &ME.ECdmcnstr->constraint_GRid;
  if (!IF_NULL_OBJID (cnstrid->objid))
  {
    EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);

    /* make sure the dimension is connected to the constraint */
    om$get_channel_objects ( osnum = cnstrid->osnum, objid = cnstrid->objid,
        p_chanselect = &chan_to_comps, list = list, size = 1, count = &count );
    if (count == 1)
    {
      if (list [0].S_objid == me->dim_grid.objid)
      {
        action = 0;
        grprops = GR_RIGID_RELATIONSHIP;
        om$send (msg = message GRgraphics.GRchgprops (&msg_loc, &action, &grprops),
            p_chanselect = &chan_to_comps, senderid = cnstrid->objid,
            targetos = cnstrid->osnum);

        om$send (msg = message Root.wild_disconnect (chan_to_comps),
            targetid = cnstrid->objid, targetos = cnstrid->osnum);

        om$send (msg = message GRgraphics.GRdelete (&msg_loc,
            &ME.ECdmcnstr->display_env), 
            targetid = cnstrid->objid, targetos = cnstrid->osnum);
      }
    }
  }

  return om$send (msg = message ECdmcnstr.delete_dimension (),
      mode = OM_e_wrt_parent, targetid = my_id);
}

method get_dim_plane()
{
  int status;

  status = OM_S_SUCCESS;

  status =
  om$send (msg = message COdmplace.get_dim_plane(),
        mode = OM_e_wrt_message,
        targetid = my_id);
  if (!(1&status)) return (OM_E_ABORT);

  return(OM_S_SUCCESS);
}

end implementation ECdmcnstr;

