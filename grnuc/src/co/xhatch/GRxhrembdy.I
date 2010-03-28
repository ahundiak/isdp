/* #######################    APOGEE COMPILED   ######################## */
class implementation  GRcoxhatch;

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
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"

#define   _xh_check_win()\
{\
  status = \
  om$is_objid_valid(osnum=me->window_grid.osnum, objid=me->window_grid.objid);\
  if(status == OM_E_NOSUCHOBJ ||  status == OM_E_NO_OBJECT_SPACE)\
    {\
      me->associative_flag = FALSE;\
      return(OM_S_SUCCESS);\
    }\
}\
#define   _xh_check_mem(ptr,msg) if(ptr==NULL) {msg=MSFAIL;return(OM_E_ABORT);}

from GRnotify import GRntfydisconn;

method GRxhremove_bdry(IGRlong         *msg; 
                       struct GRid     *cob_id;
                       OM_S_CHANSELECT *p_co_chanselect)
{
  IGRlong                      status;   
  struct GRid                  my_grid;
  OM_S_CHANSELECT              chansel;
  IGRlong                      i;
  OM_S_OBJECT_LINKAGE         *channel_linkage;
  IGRlong                      num_objects;

  status = OM_S_SUCCESS;
  *msg = MSSUCC;

  _xh_check_win();
  chansel.type = OM_e_name;
  chansel.u_sel.name = "GRcoxhatch.to_notify";

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  status = lc$get_channel_count(objid = cob_id->objid,
                                osnum = cob_id->osnum,
                                p_chanselect = p_co_chanselect,
                                count = &num_objects);

  channel_linkage = (OM_S_OBJECT_LINKAGE *)om$malloc
                   (size = sizeof(OM_S_OBJECT_LINKAGE) * num_objects);

  status = lc$get_channel_objects(objid = cob_id->objid,
                                  osnum = cob_id->osnum,
				  p_chanselect = p_co_chanselect,
				  list = channel_linkage,
				  size = num_objects,
				  count = &num_objects );
  for(i=0; i<num_objects; i++)
   {
     status = om$send (msg = message GRnotify.GRntfydisconn(msg,
							 &my_grid, 
							 &chansel),
		       targetid = channel_linkage[i].S_objid,
		       targetos = channel_linkage[i].osnum);   
     
   }
  if(channel_linkage) om$dealloc(ptr = channel_linkage);
  return(status);
}


end implementation GRcoxhatch;














