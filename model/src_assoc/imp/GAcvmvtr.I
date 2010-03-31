/* ###################   APOGEE COMPILED   ################## */
class implementation GAcurve;

#include "EMSasdef.h"
#include "exmacros.h"
#include "maidmx.h"

method NDmove_to_root(IGRlong *msg; struct GRid *src_grid;
                      struct GRmd_env *md_env)
/* *******************************************************************
Description
 This method will send the NDmove_to_root message to its children
and delete itself.

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If all goes well.
 MSFAIL : If there is some form of failure

History:
 WBC : 06/13/91 : Creation.
 Sudha   06/01/93    modified to handle BSprototype headers

*********************************************************************** */
{
 IGRlong status;
 int is_msc;
 OM_S_CHANSELECT children_chansel;
 struct GRmd_env  my_md_env;

 status = OM_S_SUCCESS;
 *msg = MSSUCC;

 om$send (msg = message GAcurve.GAis_msc(msg, &is_msc),
          targetid = my_id);

 if (is_msc) {
	status = om$make_chanselect(channame = "NDchildren.children",
                             p_chanselect = &children_chansel);
	EMerr_hndlr(!(1&status), *msg, MSFAIL, wrapup);

	status = om$send (msg = OPPmargs,
                   p_chanselect = &children_chansel);
	EMerr_hndlr(!(1&status), *msg, MSFAIL, wrapup);

	my_md_env.md_id.osnum = OM_Gw_current_OS;
	ex$get_modid(mod_osnum = OM_Gw_current_OS,
              mod_id = &my_md_env.md_id.objid);
	my_md_env.md_env.matrix_type = MAIDMX;
	MAidmx(msg, my_md_env.md_env.matrix);

	status = om$send (msg = message GRgraphics.GRdelete(msg, &my_md_env),
                   targetid = my_id);
	EMerr_hndlr(!(1&status&*msg), *msg, MSFAIL, wrapup);
 }
 else {
	status = om$send (msg = message EMSassoc.NDmove_to_root (msg,
                          src_grid, md_env),
                    mode = OM_e_wrt_message,
                    targetid = my_id);
	EMerr_hndlr(!(1&status&*msg), *msg, MSFAIL, wrapup);
 }

wrapup:
 EMWRAPUP (status, *msg, "In GAcurve:NDmove_to_root error");
 return (status);
}

method GAis_msc(IGRlong *EMmsg; int *flag)

/* ***************************************************************
Description
 This message when sent to an associative curve will indicate whether
 the same is a model space counterpart or not.

Arguments

 EMmsg : O : Completion code
 flag  : O : TRUE: If the entity is a model space counterpart
             FALSE : If the entity is not a model space counterpart

Notes
 Upon exit the completion code will be:
  EMS_S_Success: If all goes well
  EMS_E_Fail : If things do not go well

History:
 Creation : PP : 06/25/92

********************************************************************* */
{
 *EMmsg = EMS_S_Success;

 if ((me->type == EMSmsc_id) || (me->type == EMSmsc_key) ||
    (me->type == EMSmsc_id_key) || (me->type == EMSmsc_match_failed) ||
    (me->type == EMSmsc_noncount_key) || (me->type == EMSmsc_long_key))
 {
  *flag = 1;
 }
 else
  *flag = 0;
 
 return (OM_S_SUCCESS);

}
void EFis_msc(EMmsg, type, flag)
IGRint *EMmsg;
IGRint type;
IGRint *flag;
{
 *EMmsg = EMS_S_Success;

 if ((type == EMSmsc_id) || (type == EMSmsc_key) ||
    (type == EMSmsc_id_key) || (type == EMSmsc_match_failed)||
    (type == EMSmsc_noncount_key) || (type == EMSmsc_long_key))
 {
  *flag = 1;
 }
 else
  *flag = 0;
 
 return;

}
end implementation GAcurve;

