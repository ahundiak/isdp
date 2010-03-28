/* #######################    APOGEE COMPILED   ######################## */

class implementation  GRcoxhatch;

#include "coimport.h"
#include "codebug.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "igrmacros.h"
#include "comiscmac.h"
#include "msdef.h"
#include "dp.h"
#include "maerr.h"
#include "exdef.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grsymmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grxhdef.h"

from GRnotify    import GRntfyconn;

method GRxhinit( IGRlong                    *msg;     
		 struct GRid                *wireframe_go;
		 struct GRid                *window_grid;
                 IGRboolean                  xhatch_assoc_flag;
                 IGRshort                    xhatch_color;
                 IGRdouble                   xhatch_spacing;
                 IGRdouble                   xhatch_angle;
                 IGRdouble                  *origin;
                 struct GRxhatchpat         *pattern_def)
{
  
  IGRlong                      status;   
  struct GRid                  my_grid;
  OM_S_CHANSELECT              chansel;
  IGRint                       index = 0;
  IGRboolean                   tag_flag;

  _m_debug(EX_start_timing();)
  status = OM_S_SUCCESS;
  *msg = MSSUCC;
/*  */
  my_grid.osnum = OM_Gw_current_OS;
  my_grid.objid = my_id;

  chansel.type = OM_e_name;
  chansel.u_sel.name = "GRcoxhatch.to_notify";

  me->window_grid = *window_grid;
  me->pattern_def = *pattern_def;
  me->associative_flag = xhatch_assoc_flag;
  me->xhatch_spacing = xhatch_spacing;
  me->xhatch_angle = xhatch_angle;
  me->origin[0] = origin[0];
  me->origin[1] = origin[1];
  me->origin[2] = origin[2];
  me->xhatch_color = xhatch_color;

  status = om$send (msg = message GRnotify.GRntfyconn(msg,
					              &my_grid, 
						      &chansel,
                                                      &index,
                                                      &tag_flag,
                                                      &wireframe_go->osnum),
  		    targetid = wireframe_go->objid,
		    targetos = wireframe_go->osnum);   

  _m_debug(EX_end_timing("GRcoxhatch:GRxhinit");)
  return(status);
}

end implementation GRcoxhatch;



