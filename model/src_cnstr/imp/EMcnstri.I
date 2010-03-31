class implementation EMScnstr;

#include "EMSopt.h"
#include "lcdef.h"
#include "lcmsg.h"
#include "msdef.h"
#include "grerr.h"

extern GRclassid OPP_EMSexpcnstr_class_id;

from expression import NDgive_value;

method EMgetprops (IGRlong *EMmsg; IGRushort *props)
{
 *EMmsg = EMS_S_Success;
 *props = ME.EMScnstr->cnstr_props;
 return (OM_S_SUCCESS);
}

method EMchgprops(IGRlong *EMmsg; IGRshort action; IGRushort props)
{
  long OM_stat;
  
  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  switch (action)
   {
    case EMS_O_OFF:
     ME.EMScnstr->cnstr_props &= ~props;
     break;

    case EMS_O_ON:
     ME.EMScnstr->cnstr_props |= props;
     break;
    
    case EMS_O_SET:
     ME.EMScnstr->cnstr_props = props;
     break;

    default:
     *EMmsg = EMS_E_InvalidArg;

   }
 
   EMWRAPUP (*EMmsg, OM_stat, "EMScnstr.EMchgprops");
   return (OM_stat);
}


method NDmove_to_root (IGRlong *EMmsg; struct GRid *src_GRid;
                       struct GRmd_env *md_env)
{
 IGRlong msg_loc;
 enum GRdpmode mode = GRbehe;

 *EMmsg=EMS_S_Success;

 om$send ( msg = message GRgraphics.GRdisplay 
                                          ( &msg_loc,
                                            &md_env->md_env.matrix_type,
                                            md_env->md_env.matrix,
                                            &mode,
                                            &md_env->md_id ),
            targetid = my_id);

 om$send (msg = message GRgraphics.GRdelete(&msg_loc, md_env),
                  targetid = my_id);

 return (OM_S_SUCCESS);

}

method GRlocate_owner ( IGRlong *msg; 
                        struct GRlc_cvl *cvl;
                        struct GRlc_path *path; 
                        IGRint *path_position)
{
 *msg = EMS_S_Success;

 if (cvl->attributes.obj_attr.owner_action & LC_HANDLES)
  return (om$send (mode = OM_e_wrt_parent,
                   msg = message EMScnstr.GRlocate_owner(msg,
                         cvl,path, path_position),
                   targetid = my_id));
 else
 {

  GRLocInfo(GRObjectIneligible, LC_E_ExternConstrain,
            OM_Gw_current_OS, my_id);

  *msg = GRNO_PROCESSING_NEEDED;
  return (OM_S_SUCCESS);
 }
}

method debug()
{
  long stat_OM;
  GRclassid myclass;
  
  stat_OM = om$send ( mode = OM_e_wrt_parent, msg = message EMScnstr.debug(),
                      targetid = my_id );

  fprintf (stderr, "\nConstraint-props : 0x%x", me->cnstr_props);
  if (me->cnstr_props & EMScnstr_horizontal)
    fprintf (stderr, " EMScnstr_horizontal");
  if (me->cnstr_props & EMScnstr_clockwise_angle)
    fprintf (stderr, " EMScnstr_clockwise_angle");
  if (me->cnstr_props & EMScnstr_self_constraint)
    fprintf (stderr, " EMScnstr_self_constraint");
  if (me->cnstr_props & EMScnstr_negative_axis)
    fprintf (stderr, " EMScnstr_negative_axis");
  if (me->cnstr_props & EMScnstr_convert_units)
    fprintf (stderr, " EMScnstr_convert_units");
  if (me->cnstr_props & EMScnstr_direction_validated)
    fprintf (stderr, " EMScnstr_direction_validate");
  
  fprintf (stderr, "\n");
  
  om$get_classid ( objid = my_id, p_classid = &myclass );
  if (om$is_ancestry_valid ( subclassid = myclass,
                             superclassid = OPP_EMSexpcnstr_class_id) == OM_S_SUCCESS)
  {
    double db_value;
    stat_OM = om$send  ( mode = OM_e_wrt_message,
                         msg = message expression.NDgive_value (&db_value),
                         targetid = my_id);
    fprintf (stderr, "Dim value : [%lf]\n", db_value);
  }
  
  return stat_OM;
}

end implementation EMScnstr;
