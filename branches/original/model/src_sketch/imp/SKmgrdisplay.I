/* ###################   APOGEE COMPILED   ################## */
class implementation SKmgr;

/*
  ABSTRACT

    This implementation provides the GRdisplay override at SKmgr class
    object.

  HISTORY

     RC  :  05/26/90  :  Creation Date
*/


method GRdisplay(IGRlong *msg;  IGRshort *type; IGRmatrix matrix;
	             enum GRdpmode *mode; struct GRid *display_info)
{

 OM_S_CHANSELECT   mgr_cnstrs_chan;

 IGRlong  OM_stat;

 /* ***************************************************************** */

 OM_stat = OM_S_SUCCESS;
 *msg = EMS_S_Success;

 /*
  * o Pass the message to my constraints.
  * o Pass the message to my geomtery.
  */


OM_stat = om$make_chanselect (channame = "SKmgr.to_constrs",
                              p_chanselect = &mgr_cnstrs_chan);
EMerr_hndlr (!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);


OM_stat = om$send (msg = message GRgraphics.GRdisplay (msg, type,
                    matrix, mode, display_info),
                   p_chanselect = &mgr_cnstrs_chan);
/*
 * Ignore this message because if an owner does not have any components
 * the display fails when a drawing view is attached.
 */
if (!(1&*msg&OM_stat))
{
 OM_stat = OM_S_SUCCESS;
 *msg = EMS_S_Success;
}

OM_stat = om$send (mode = OM_e_wrt_message,
                   msg = message GRowner.GRdisplay (msg, type,
                    matrix, mode, display_info),
                   targetid = my_id);
EMerr_hndlr (!(1&OM_stat&*msg), *msg, EMS_E_Fail, wrapup);

wrapup:
  EMWRAPUP (*msg, OM_stat, "SKmgr.GRdisplay");
  return (OM_stat);
}

method GRdisyourself(IGRlong *msg; IGRshort *mx_type; IGRmatrix
                        matrix;  enum GRdpmode *mode;
			struct IGRaltdisplay *alt_symb;
			struct DP_information *sp_info;
                        OM_p_KEY_DESC range_key)
{
 OM_S_CHANSELECT   mgr_cnstrs_chan;

 IGRlong  OM_stat;

 /* ***************************************************************** */

 OM_stat = OM_S_SUCCESS;
 *msg = EMS_S_Success;

 /*
  * o Pass the message to my constraints.
  * o Pass the message to my geomtery.
  */


OM_stat = om$make_chanselect (channame = "SKmgr.to_constrs",
                              p_chanselect = &mgr_cnstrs_chan);
EMerr_hndlr (!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);


OM_stat = om$send (msg = OPPmargs,
                   p_chanselect = &mgr_cnstrs_chan);
EMerr_hndlr (!(1&OM_stat&*msg), *msg, EMS_E_Fail, wrapup);

OM_stat = om$send (mode = OM_e_wrt_message,
                   msg = message GRowner.GRdisyourself(msg, mx_type,
                         matrix,mode,alt_symb,sp_info,range_key),
                   targetid = my_id);
EMerr_hndlr (!(1&OM_stat&*msg), *msg, EMS_E_Fail, wrapup);

wrapup:
  EMWRAPUP (*msg, OM_stat, "SKmgr.GRdisplay");
  return (OM_stat);
}
end implementation SKmgr;
