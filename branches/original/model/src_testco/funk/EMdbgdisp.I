class implementation GRvg;

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWapi/featquery.h"

void EMdbgdisp (grobj, osnum, num_flashes)
GRobjid grobj;
GRspacenum osnum;
IGRint num_flashes;
{
  IGRint i, j, num_disp_objs;
  IGRlong msg_loc;
  struct GRsymbology symb;
  struct GRmd_env md_env;
  enum GRdpmode dpmode;
  PWobjid *disp_objs;

  gr$get_module_env (buffer = &md_env);
  if (pwFeatureType (grobj, osnum) != PWfeat_unknown)
    pwGetFeatureSfs (grobj, osnum, &num_disp_objs, &disp_objs);
  else
  {
    num_disp_objs = 1;
    disp_objs = &grobj;
  }

  for (i=0; i<num_disp_objs; i++)
  {
    om$send (msg = message GRvg.GRgetsymb (&msg_loc, &symb),
     targetid = disp_objs[i], targetos = osnum, senderid = NULL_OBJID);
    symb.display_attr.weight++;
    om$send (msg = message GRvg.GRputsymb (&msg_loc, &symb),
     targetid = disp_objs[i], targetos = osnum, senderid = NULL_OBJID);
    
    for (j=0; j<(num_flashes*2)+1; j++)
    {
      dpmode = i % 2 ? GRhe : GRhd;
      om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
       &md_env.md_env.matrix_type, md_env.md_env.matrix,
       &dpmode, &md_env.md_id), 
       targetid = disp_objs[i], targetos = osnum, senderid = NULL_OBJID);
    }

    symb.display_attr.weight--;
    om$send (msg = message GRvg.GRputsymb (&msg_loc, &symb),
     targetid = disp_objs[i], targetos = osnum, senderid = NULL_OBJID);
  }
    
  return;
}

end implementation GRvg;
