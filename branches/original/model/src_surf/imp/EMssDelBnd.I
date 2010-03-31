/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

/* HISTORY:
   Creation		Long ago....
   08/25/92  NP		Modified for ANSI compliance.

*/
#include "EMS.h"
#include "godef.h"
#include "gocmacros.h"
#include "EMSdpb.h"			/* DPB include file */

from EMSboundary import EMpostdelete;

method EMdelete_boundary(IGRlong *EMmsg; struct GRmd_env *env;
			 struct GRid *md_id;
			 struct GRid *surfid)
{
  IGRboolean		notify;
  IGRlong               sts, msg_loc;
  extern IGRboolean     GRabsg_del_by_objid();
  IGRboolean		loc_sts;
  OM_S_CHANSELECT       to_loopset;
  enum			GRdpmode DisplayMode;
  IGRuint		count = 0;

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  notify = EMcheck_inhibit_postproc();

  loc_sts = GRabsg_del_by_objid(&my_id, &OM_Gw_current_OS);

  if(surfid)
   {
    surfid->objid = my_id;
    surfid->osnum = OM_Gw_current_OS;
   }

  to_loopset.type = OM_e_addr;
  to_loopset.u_sel.addr = &ME.EMSsubbs->to_loopset;

  sts = om$get_channel_count(object = me, p_chanselect = &to_loopset, 
			     count = &count);
  if(!(1&sts)) goto wrapup;
  if(!count) goto wrapup;

 /* Erase the surface
 */
 if(md_id && env)
  {
   DisplayMode = GRbehe; /* GRbe */
   sts = om$send(msg = message GRgraphics.GRdisplay(
    				EMmsg, &env->md_env.matrix_type,
    				env->md_env.matrix, &DisplayMode, 
				md_id), targetid = my_id);
   if(!(1&sts)) goto wrapup;
  }

 /* Delete the loopset
 */
  sts = om$send(msg=message Root.delete(1),p_chanselect=&to_loopset);
  if(!(1&sts)) goto wrapup;

  loc_sts = GRabsg_del_by_objid(&my_id, &OM_Gw_current_OS);


 /* Redraw the surface
 */
 if(md_id && env)
  {
   DisplayMode = GRbd;
   sts = om$send(msg = message GRgraphics.GRdisplay(
    				EMmsg, &env->md_env.matrix_type,
    				env->md_env.matrix, &DisplayMode, 
				md_id), targetid = my_id);
   if(!(1&sts)) goto wrapup;
  }

wrapup:

  if (notify)
    {
    if (!EMSerror (*EMmsg))
      sts = om$send (msg = message EMSsubbs.EMpassloop (&msg_loc,
             message EMSboundary.EMpostdelete (EMmsg, NULL, env)),
             targetid = my_id);
    EMrestore_postproc();
    }

  return(sts);
}

end implementation EMSsubbs;
