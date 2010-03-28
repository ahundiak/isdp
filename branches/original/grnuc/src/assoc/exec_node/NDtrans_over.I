class implementation ASnode;
/*
   Ch    dec 87 :  update for the 1.1 release

   This is the implementation file of the class ASnode and gather only the
   overrided method of GRgraphics and GRvg.

   LLC	dec 91 : add implementation of NDattach_to_track_pt and NDdetach_to_track_pt 
		 method.
*/

#include "AS_status.h"
#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMmacros.h"
#include "asdef.h"
#include "nddef.h"
#include "asmacros.h"
#include "asbox.h"

#define AS_DEBUG 1


method NDattach_to_cs(IGRlong *msg; struct GRid cs_grid,contents_grid;
                       struct GRid *as_grid; struct GRmd_env *md_env)
{
 IGRlong status;
 status = om$send(msg = message ASnode.ASadd_opt(cs_grid,0,md_env),
		  targetid = my_id);
 as_grid->objid = my_id;
 as_grid->osnum = OM_Gw_current_OS;
 return(OM_S_SUCCESS);   /* return success even if not attached */
}

method NDdetach_from_cs(IGRlong *msg; struct GRid cs_grid,contents_grid;
                       struct GRid *as_grid; struct GRmd_env *md_env)
{
 IGRlong status;
 cs_grid.objid = NULL_OBJID;
 status = om$send(msg = message ASnode.ASadd_opt(cs_grid,0,md_env),
		  targetid = my_id);
 as_grid->objid = my_id;
 as_grid->osnum = OM_Gw_current_OS;
 return(OM_S_SUCCESS);   /* return success even if not attached */
}

method NDattach_to_track_pt(IGRlong *msg; struct GRid pt_grid;
                       struct GRid *as_grid; struct GRmd_env *md_env)
{
 IGRlong status;
 status = om$send(msg = message ASnode.ASadd_opt(pt_grid,1,md_env),
		  targetid = my_id);
 as_grid->objid = my_id;
 as_grid->osnum = OM_Gw_current_OS;
 return(OM_S_SUCCESS);   /* return success even if not attached */
}

method NDdetach_from_track_pt(IGRlong *msg; struct GRid pt_grid;
                       struct GRid *as_grid; struct GRmd_env *md_env)
{
 IGRlong status;
 pt_grid.objid = NULL_OBJID;
 status = om$send(msg = message ASnode.ASadd_opt(pt_grid,1,md_env),
		  targetid = my_id);
 as_grid->objid = my_id;
 as_grid->osnum = OM_Gw_current_OS;
 return(OM_S_SUCCESS);   /* return success even if not attached */
}

end implementation ASnode;

