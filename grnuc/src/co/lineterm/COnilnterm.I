/* #######################    APOGEE COMPILED   ######################## */
/* 
  Name
  
  IGRlong CO_ni_place_line_terminator(msg,
                                Events,
                                ModuleInfo,
                                DisplayMode,
                                DisplayGrid,
                                my_id,
                                MyChannelStruct,
                                ObjectsGrid )
  
  IGRlong              *msg;
  struct GRevent       *Events[];
  struct GRmd_env      *ModuleInfo;
  enum GRdpmode         DisplayMode;
  struct GRid          *DisplayGrid;
  GRobjid               my_id;
  OM_S_CHANSELECT      *MyChannelStruct;
  struct GRid          *ObjectsGrid;
  
  
  Abstract
  This function extends an element by a distance or to a point
  
  Arguments
  
  msg
  return codes
  
  events
  an array of events.  these are usually collected by
  a command object.  
  
  event[0] is the from point
  event[1] is the to point
  
  module
  context of located object
  
  cob_id
  object id of calling object, or at least some object
  
  display_obj
  id of object to display located object
  
  p_chanselect
  pointer to a chaselect structure for located object on channel
  
  ObjectsGrid
  object to extend
  
  Status returns
  
  OM_S_SUCCESS            
  OM_E_INVARG             
  OM_E_NODYNMEM
  OM_E_NOSUCHOS
  
  History
  */
class implementation Root;

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
#include "lcmacros.h"

from GRlnterm   import GRlnterminit;
from GRgraphics import GRdisplay; 
/*----------------------------------------
 *  CO_ni_place_line_terminator
 *----------------------------------------
 */
IGRlong CO_ni_place_line_terminator(msg,
			      Events,
			      ModuleInfo,
			      DisplayMode,
			      DisplayGrid,
			      my_id,
			      MyChannelStruct,
			      ObjectsGrid )
     
     IGRlong              *msg;
     struct GRevent       *Events[];
     struct GRmd_env      *ModuleInfo;
     enum GRdpmode         DisplayMode;
     struct GRid          *DisplayGrid;
     GRobjid               my_id;
     OM_S_CHANSELECT      *MyChannelStruct;
     struct GRid          *ObjectsGrid;
     
{
  
  IGRlong                      status;   
  struct GRevent               accept_event;
  IGRlong                      NumberObjectsFound;
  OM_S_OBJECT_LINKAGE          ChannelLinkage[1];
  struct GRid                  element;
  struct GRid                  line_term;
  struct GRid                  cell_id;
  enum GRdpmode                display_mode;

  display_mode = GRbd;

  if ( MyChannelStruct != NULL )  /* extract object from channel */
    {
      /*
       *  find out who is on my channel
       */
      status = lc$get_channel_objects(objid = my_id,
				      p_chanselect = MyChannelStruct,
				      list = ChannelLinkage,
				      size = 1,
				      count = &NumberObjectsFound );
      element.objid = ChannelLinkage[0].S_objid;
      element.osnum = ChannelLinkage[0].osnum;
      _m_check2q( status, *msg );
    }
  else                            /* grid passed */
    {
      element = *ObjectsGrid;
    }
  
  /*
   *  pull the events out of the array
   */

  accept_event   = *Events[1];
  
  line_term.osnum =  element.osnum;

  status = om$construct( osnum = element.osnum,
			classname = "GRlnterm",
			p_objid = &line_term.objid);

  status = om$send( msg = message GRlnterm.GRlnterminit(msg,
						        &element,
                                                        &accept_event,
                                                         ModuleInfo,
                                                        &cell_id),
		   targetid = line_term.objid,
		   targetos = line_term.osnum );

  status = om$send(msg = message GRgraphics.GRdisplay(msg,
					      &ModuleInfo->md_env.matrix_type,
	 				      ModuleInfo->md_env.matrix,
						      &display_mode,
						      &ModuleInfo->md_id),
		   targetid = cell_id.objid,
		   targetos = cell_id.osnum);
  
  
 quit:
  return(OM_S_SUCCESS);
}

end implementation Root;


