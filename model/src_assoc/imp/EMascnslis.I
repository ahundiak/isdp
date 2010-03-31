/* ###################   APOGEE COMPILED   ################## */
class implementation EMSassoc;

# include "go.h" /* For GRvg_construct */
# include "grdpbdef.h"
# include "grdpbmacros.h"

method EMget_construction_info (IGRlong *EMmsg;
                                struct GRvg_construct *construct_list)

/* ************************************************************************

 Description
   This method generates the construct list based on the construction 
   information that is stored in itself. It fills the entire
   structure barring the environment information. It expects the memory for
   the display field in the construct_list structure to be allocated.
   If construct_list->class_attr is not NULL then this method assumes
   that enough memory has been allocated to get the element specific
   attributes and it will try to obtain the same from itself.
   
 Notes
   Upon exit the completion code will be one of the following:
   EMS_S_Success : If all is well.
   EMS_E_Fail : If there was some form of an error.

 History
   Creation date : PP : July 12, 1988
   ************************************************************************* */
{
 IGRlong status, EFget_construction_info_from_id();
 

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 status = EFget_construction_info_from_id(EMmsg,
                                          construct_list,
                                          my_id,
                                          OM_Gw_current_OS);
 EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);

wrapup:
 EMWRAPUP (*EMmsg, status, "EMSassoc:EMget_construction_info error");
 if (1 & *EMmsg & status) return(OM_I_STOP_SENDING);
 else return (status);
}


IGRlong EFget_construction_info_from_id(EMmsg,
                                        construct_list,
                                        objid,
                                        osnum)
IGRlong               *EMmsg;
struct GRvg_construct *construct_list;
GRobjid               objid;
OMuword               osnum;

/* ************************************************************************

 Description
   This method generates the construct list based on the construction 
   information that is stored in itself. It fills the entire
   structure barring the environment information. It expects the memory for
   the display field in the construct_list structure to be allocated.
   If construct_list->class_attr is not NULL then this method assumes
   that enough memory has been allocated to get the element specific
   attributes and it will try to obtain the same from itself.
   
 Notes
   Upon exit the completion code will be one of the following:
   EMS_S_Success : If all is well.
   EMS_E_Fail : If there was some form of an error.

 History
   DLB 3/14/91 Made it a function.
   Creation date : PP : July 12, 1988
   ************************************************************************* */
{
 IGRlong status;
 struct GRsymbology symb;
 
 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 construct_list->properties = 0;
 status = om$send(msg = message GRgraphics.GRgetprops(EMmsg,
                        (IGRshort *)&construct_list->properties),
                  senderid = NULL_OBJID,
                  targetid = objid,
                  targetos = osnum);
 construct_list->properties |= GRIS_LOCATABLE | GRIS_DISPLAYABLE | GRIS_NEW;
 construct_list->properties &= ~(GR_RIGID_RELATIONSHIP | GRIS_ASSOCIATIVE |
                                 GRHAS_EXTERNAL_CONSTRAINT);
 EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);

 status = om$send(msg = message GRvg.GRgetsymb (EMmsg, &symb),
                  senderid = NULL_OBJID,
                  targetid = objid,
                  targetos = osnum);
 EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);

 *construct_list->display = symb.display_attr;
 construct_list->level = symb.level;
 construct_list->newflag = TRUE;
 construct_list->geometry = NULL;
 if (construct_list->class_attr)
 {
  IGRint msg_loc,loc_sts;
  loc_sts = om$send(msg = message GRvg.GRgetattr((IGRlong *)&msg_loc, 
                           construct_list->class_attr),
                    senderid = NULL_OBJID,
                    targetid = objid,
                    targetos = osnum);
  if (!(1&loc_sts&msg_loc)) construct_list->class_attr = NULL;
 }
 construct_list->name = NULL;

wrapup:
/*
 * If for some reason there is an error in recomputing the
 * construction information get the same from the active
 * master file.
 */
 if (!(1&status&*EMmsg))
 {
  int bytes_in,bytes_out;
  int loc_msg;

  status = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  bytes_in = sizeof(construct_list->level);
  gr$get_active_level(
    msg = &loc_msg,
    sizbuf = &bytes_in,
    buffer = &construct_list->level,
    nret = &bytes_out);
  if (!(1&loc_msg)) return (OM_E_ABORT);

 bytes_in = sizeof(struct IGRdisplay);
 gr$get_active_display(
   msg = &loc_msg, 
   sizbuf = &bytes_in,
   buffer = construct_list->display,
   nret = &bytes_out);
 if (!(1&loc_msg)) return (OM_E_ABORT);

  construct_list->newflag = TRUE;
  construct_list->geometry = NULL;
  construct_list->class_attr = NULL;
  construct_list->name = NULL;
 }

 EMWRAPUP(*EMmsg, status, "EFget_construction_info_from_id")
 return (status);
}
end implementation EMSassoc;

