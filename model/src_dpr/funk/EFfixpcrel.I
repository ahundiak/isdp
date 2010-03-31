class implementation EMSassoc;

#include "EMSmsgdef.h"
#include "EMSopt.h"
#include "emsdef.h"
#include "asbox.h" /* For NULL_GRID */
#include "nddef.h"

#argsused
IGRint EFfix_parent_child_relationship(EMmsg, surf_id, comp_id, osnum,
                                       taking_out, options)
IGRlong         *EMmsg;
GRobjid         surf_id;
GRobjid         comp_id;
OMuword         osnum;
IGRboolean      taking_out;
OMuword         options;
/*
Description
     This function will fix up the parent-child relation of a component surface
     which has been removed due to a dpr operation.  If an associative surface
     is removed from a composite, then a parent-child relationship must be
     established (taking_out == TRUE).  Likewise, when an associative surface
     is put back, the parent-child relationship must be broken.

Notes 
     About parameters:
         surf_id - surface being taken out or put back.
         comp_id - composite surface is being removed from or put back to.
         osnum - obvious.
         taking_out - if TRUE surface is in the process of being taken out.
         options - none so far.

History
     DLB  03/03/92  Creation.
*/
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  struct GRid       root_grid;
  IGRshort          grprops;
  extern IGRboolean EFisAncestryValid();
  extern OMuword    OPP_EMAsubbs_class_id;  


  *EMmsg = EMS_S_Success;

  /*Screen the surface for valid case - EFisancval just a paranoia check.
   * Do this whether taking_out or not since I want to be real careful.
   */
  OM_stat = om$send(msg = message GRgraphics.GRgetprops(EMmsg, &grprops),
                    senderid = NULL_OBJID,
                    targetid = surf_id,
                    targetos = osnum);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  if (!(grprops & GRIS_ASSOCIATIVE) || 
      !EFisAncestryValid(EMmsg, surf_id, osnum, OPP_EMAsubbs_class_id,
                         FALSE)) goto wrapup;

  root_grid.objid = surf_id;
  root_grid.osnum = osnum;

  if (taking_out)
  {
    OM_stat =om$send(msg = message NDnode.NDconnect(1, &root_grid, 
                           NULL_GRID, ND_ADD),
                     senderid = NULL_OBJID,
                     targetid = comp_id,
                     targetos = osnum);
    if (!(1 & OM_stat)) goto wrapup;                       
  }    
  else
  {
    /*Is possible that I am working on an old design file that did not have the
     * parent-child channel connected up.  I will just check this case and
     * do nothing.
     */
    OM_S_CHANSELECT to_children;

    EMmake_chanselect(NDchildren_children, &to_children);

    OM_stat = om$is_objid_on_channel(objid_c = surf_id,
                                     osnum_c = osnum,
                                     p_chanselect = &to_children,
                                     objid = comp_id);
    if (OM_stat == OM_W_NOTONCHAN)
    {
      OM_stat = OM_S_SUCCESS;
      goto wrapup;
    }
    else if (!(1 & OM_stat)) goto wrapup;
                                             
    OM_stat = om$send(msg = message NDnode.NDdisconnect(1, &root_grid),
                      senderid = NULL_OBJID,
                      targetid = comp_id,
                      targetos = osnum);
    if (!(1 & OM_stat)) goto wrapup;
  }

wrapup:
   EMWRAPUP(*EMmsg, OM_stat, "EFfixpcrel")
   /*NO MATTER WHAT HAPPENS JUST RETURN SUCCESS!!!!*/
   *EMmsg = EMS_S_Success;
   return(OM_S_SUCCESS);
}
end implementation EMSassoc;
