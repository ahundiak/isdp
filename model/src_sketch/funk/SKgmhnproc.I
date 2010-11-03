class implementation SKconstraint;

#include "dimdef.h"
#include "dimdload.h"
#include "dim.h"
#include "dimmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include <alloca.h>

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

void SKdisp_geomhandle ( msg, os, grobj, disp_attr, disp_level, disp_len )
long              *msg;
GRspacenum        os;
GRobjid           grobj;
struct IGRdisplay *disp_attr;
short             *disp_level;
IGRdouble         *disp_len;
{
  long                  msg_loc, stat_OM;
  struct GRsymbology    symb;
  struct DMglobal_param dm_glb_param;
  struct DMenv_param    dm_env_param;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (disp_attr || disp_len)
  {
    stat_OM = dm$get_dim_param ( type = DM_ENV_PARAM, p_data = &dm_env_param );
    EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_Fail, ret_end );
  }

  /*
   * Obtain the color and the weight that the handle must have. 
   */
  if (disp_attr || disp_level)
  {
    if (disp_attr)
    {
      stat_OM = dm$get_dim_param ( type = DM_GLOB_PARAM, p_data = &dm_glb_param );
      EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_Fail, ret_end );
      disp_attr->weight = dm_env_param.dim_weig;
      disp_attr->color =  dm_glb_param.driving_color;
      disp_attr->style = 0;
    }

    if (disp_level)
    {
      if (grobj == NULL_OBJID)
        {
        *disp_level = NULL;
        gr$get_active_level (buffer = disp_level);
        }
      else
        {
        stat_OM = om$send (msg = message GRvg.GRgetsymb ( &msg_loc, &symb ),
          targetid = grobj, targetos = os, senderid = NULL_OBJID );
        *disp_level = symb.level;
        
        if (!(stat_OM & msg_loc & 1))
        {
            IGRint sizbuf = sizeof(IGRshort), nret = 0;

            stat_OM = gr$get_active_level ( msg = &msg_loc, 
                                            sizbuf = &sizbuf,
                                            buffer = disp_level,
                                            nret = &nret );

            if (!(stat_OM & msg_loc & 1))
            {
                EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail,
                 ret_end );
            }
          }
        }
     }
  }

  /*
   * Obtain the standard length that must be used in all the computes
   * for geometric handles
   */
  if (disp_len)
    *disp_len = 1.1 * dm_env_param.txt_heig;

ret_end:
  EMWRAPUP ( *msg, stat_OM, "SKdisp_gmhndl" );
  return;
}


void SKexist_geomhandle ( msg, os, cnstrobj, num_buff, num_gmhndls, gmhndls )
long       *msg;
GRspacenum os;
GRobjid    cnstrobj;
int        num_buff, *num_gmhndls;
GRobjid    **gmhndls;
{
  int                 i;
  OMuint              count;
  long                stat_OM;
  OM_S_CHANSELECT     chan_to_comps;
  OM_p_OBJECT_LINKAGE objlist;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain the geometric handles that are already connected to
   * the constraint
   */
  EMmake_chanselect ( GRcmpowner_to_components, &chan_to_comps );
  count = 0;
  om$get_channel_count ( objid = cnstrobj, osnum = os,
      p_chanselect = &chan_to_comps, count = &count );

  if (count)
  {
    objlist = (OM_p_OBJECT_LINKAGE) alloca ( count * 
        sizeof ( OM_S_OBJECT_LINKAGE ) );
    EMerr_hndlr ( !objlist, *msg, EMS_E_NoStackMemory, ret_end );

    stat_OM = om$get_channel_objects ( objid = cnstrobj, osnum = os, 
        p_chanselect = &chan_to_comps, size = count, count = &count,
        list = objlist );
    EMomerr_exit ( stat_OM, ret_end );

    if (num_buff < count)
    {
      *gmhndls = (GRobjid *) om$malloc ( size = count * sizeof ( GRobjid ) );
      EMerr_hndlr ( !*gmhndls, *msg, EMS_E_NoDynamicMemory, ret_end );
    }

    for (i = 0; i < count; i++)
      (*gmhndls) [i] = objlist [i].S_objid;
    *num_gmhndls = count;
  }
  else
    *num_gmhndls = 0;

ret_end:
  EMWRAPUP ( *msg, stat_OM, "SKexist_gmhndl" );
  return;
}

end implementation SKconstraint;
