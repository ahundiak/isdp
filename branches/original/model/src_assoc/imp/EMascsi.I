class implementation EMSassoc;

#include "asbox.h" /* For NULL_GRID */
#include "nddef.h" /* For ND_NC_NEW */
#include "parametric.h"
extern OMuword OPP_EMSdpr_class_id;

method NDattach_to_cs(IGRlong *EMmsg; struct GRid cs_grid,contents_grid;
		       struct GRid *as_grid; struct GRmd_env *md_env)
/*
 * This method attaches a non-associative solid to a coordinate system.
 * 
 * History
 *   Creation : PP : 01/11/91
 */
{
 IGRlong status ;
 struct ret_struct refdef;
 
 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 if (ME.GRgraphics->properties & GRIS_ASSOCIATIVE)
  return (OM_S_SUCCESS);

 if (EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS, 
                       OPP_EMSdpr_class_id, FALSE))
  return (OM_S_SUCCESS);

 ME.GRgraphics->properties |= GRIS_ASSOCIATIVE;

 status = om$send(msg = message NDnode.NDconnect (1,&cs_grid,
                         NULL_GRID, ND_FULL), 
                   targetid = my_id);
 EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);

 status = om$send (msg = message NDnode.NDgive_structure(EMmsg,
                         &refdef, md_env),
                   targetid = cs_grid.objid,
                   targetos = cs_grid.osnum);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

 status = om$send(msg = message EMSassoc.EMput_info(EMmsg, NULL, 254, 
                        sizeof (IGRmatrix), 
                        (IGRchar *)refdef.var.ref_st.t),
                    targetid = my_id);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 as_grid->objid = my_id;
 as_grid->osnum = OM_Gw_current_OS;
 ME.GRgraphics->properties |= GRIS_ASSOCIATIVE;

wrapup:
 EMWRAPUP (*EMmsg, status, "In EMSassoc:NDattach_to_cs error");
 return (status);
}

method NDdetach_from_cs(IGRlong *EMmsg; struct GRid cs_grid,contents_grid;
		       struct GRid *as_grid; struct GRmd_env *md_env)
/*
 * This method detaches an element from a coordinate system.
 *
 * History
 * Creation : PP : 01/11/91
 */
{
 IGRlong status;
 IGRuint type;
 
 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 status = om$send (msg = message EMSassoc.EMget_info(EMmsg,NULL,&type,
                         NULL,NULL),
                   targetid = my_id);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 if (type == 254)
 {
  status = om$send (msg = message NDnode.NDdisconnect(0,NULL),
          targetid = my_id);
  EMerr_hndlr(!(1&status), *EMmsg, MSFAIL, wrapup);

  status = om$send (msg = message EMSassoc.EMput_info(EMmsg,NULL,
                         EMS_ASno_type,0,NULL),
                   targetid = my_id);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, MSFAIL, wrapup);

  if (ME.GRgraphics->properties & GRIS_ASSOCIATIVE)
   ME.GRgraphics->properties &= ~GRIS_ASSOCIATIVE;
 }

wrapup:
 return (status);
}

end implementation EMSassoc;

