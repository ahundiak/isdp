/* #######################    APOGEE COMPILED   ######################## */

class implementation  GRxhgg;

#include "coimport.h"
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
#include "exmacros.h"

method GRdelete(IGRlong *msg; struct GRmd_env *md_env)
{
  
  IGRlong                      status;   
  OM_S_CHANSELECT              chanselect, chanselect1;
  OM_S_OBJID		       undo_object;

  status = OM_S_SUCCESS;
  *msg = MSSUCC;

  /* delete graphic group */
  status = om$send (msg = message GRgrgrp.GRdelete(msg,
						   md_env),
		    mode = OM_e_wrt_message,
   	            targetid = my_id);

  /* delete cross hatching object */
  status = om$make_chanselect(chanaddr = &me->to_owners,
			      p_chanselect = &chanselect);

  status = om$make_chanselect(channame = "GRcmpowner.to_components",
			      p_chanselect = &chanselect1);

    status = ex$get_super (mod_id = md_env->md_id.objid,
                        mod_osnum = md_env->md_id.osnum,
                        super_name = "UNDO_OBJECT",
                        create = FALSE,
                        super_class = "GRundo",
                        super_id = &undo_object);

    if(undo_object != NULL)
	    status = om$send(msg = message Root.disconnect(chanselect, 
			undo_object, 
			md_env->md_id.osnum, chanselect1),
			targetid=my_id);
	
    status = om$send(msg = message Root.delete(FALSE),
			   p_chanselect = &chanselect);

  return(status);
}

end implementation GRxhgg;

