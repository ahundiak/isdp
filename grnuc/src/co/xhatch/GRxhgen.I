/* #######################    APOGEE COMPILED   ######################## */
/*
  Name
  GRxh_generate_crosshatch
 
             Algorithm for Generating Cross Hatching in I/Draft


   (This function now just gets the object to crosshatched and its
    boundary objects off of the notify channel and calls another function
    to do the actual crosshatch generation)
   Make channel selector for the notify channel.

   Find out how many objects are on the notify channel.
  
   Get element to be cross hatched from notify channel.
     (the element to be cross hatched will always be the first
        element on the channel).

   Get the boundary elements.

/*  */
class implementation GRcoxhatch;

#include <alloca.h>
#include "coimport.h"
#include "codebug.h"
#include "OMminimum.h"
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
#include "madef.h"
#include "dp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "dpmacros.h"
#include "dpdef.h"
#include "msdef.h"
#include "maerr.h"
#include "exdef.h"
#include "bstypes.h"
#include "bsmalloc.h"
#include "grownmacros.h"

%safe
#include <math.h>
%endsafe

extern IGRint   GRgenerate_crosshatch();


IGRint     GRxh_generate_crosshatch(msg,
				    window_grid,
				    xh_gg,
				    xhatch_id,
                                    xhatch_color,
                                    xhatch_spacing,
                                    xhatch_angle,
		                    xhatch_pattern,
                                    act_origin,
				    module_info,
                                    associative_flag)
     
     IGRlong                     *msg;
     struct GRid                 *window_grid;
     struct GRid                 *xh_gg; /* graphic group to be
					    filled with lines     */
     struct GRid                  xhatch_id;      /* xhatch object's id     */
     IGRshort                     xhatch_color;
     IGRdouble                    xhatch_spacing;
     IGRdouble                    xhatch_angle;
     struct GRxhatchpat          *xhatch_pattern; /* pattern to xhatch with */
     IGRdouble                   *act_origin;
     struct GRmd_env             *module_info;
     IGRboolean                   associative_flag;
     
{
  IGRlong                      status;
  OMuint                       notify_count;
  IGRint                       index,
                               sts;
  struct GRid                  elem_to_xhatch;
  struct GRid                 *boundary_grids;
  OM_S_CHANSELECT              notify_chanselect;

  status = sts = OM_S_SUCCESS;
  *msg = MSSUCC;

  /* make a selector to the to_notify channel */
  status = om$make_chanselect(channame = "GRcoxhatch.to_notify",
			      p_chanselect = &notify_chanselect);
  _m_checkq(status);
  
  /* find out how many objects are on the notify channel */
  status = om$get_channel_count(objid = xhatch_id.objid,
				osnum = xhatch_id.osnum,
				p_chanselect = &notify_chanselect,
				count = &notify_count);
  _m_checkq(status);
  
  /* allocate space for the list of objects coming off the channel */

  boundary_grids = NULL;
  boundary_grids = (struct GRid *) alloca(notify_count * sizeof(struct GRid));

  if (boundary_grids == NULL)
    return(OM_E_NODYNMEM);
  
  /* get element to be crosshatched off the channel (always the first one) */

  status = om$get_objid_at_index(osnum = xhatch_id.osnum,
                                 objid = xhatch_id.objid,
			         p_chanselect = &notify_chanselect,
                                 index = 0,
                                 objidaddr = &elem_to_xhatch.objid,
                                 osnumaddr = &elem_to_xhatch.osnum);
  _m_checkq(status);

  for (index = 1; index < notify_count; index++)
  {
    status = om$get_objid_at_index(osnum = xhatch_id.osnum,
                                   objid = xhatch_id.objid,
  			           p_chanselect = &notify_chanselect,
                                   index = index,
                                   objidaddr = &boundary_grids[index - 1].objid,
                                   osnumaddr = &boundary_grids[index - 1].osnum);
    _m_checkq(status);
  }

  /* call the function to generate the crosshatch elements */

  sts = GRgenerate_crosshatch(msg, &elem_to_xhatch, ((IGRint)notify_count) - 1,
                              boundary_grids, window_grid, xh_gg,
			      xhatch_id, xhatch_color, xhatch_spacing,
                              xhatch_angle, xhatch_pattern, act_origin,
		              module_info, associative_flag);
quit:

  if (! status)
    sts = status;

  return (sts);
}

end implementation GRcoxhatch;

