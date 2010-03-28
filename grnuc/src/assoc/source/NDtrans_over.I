/*
   ASsource implementation file for NDtrans override 

HISTORY :
   jla August 88  : design date
*/

class implementation ASsource;

#include "OMmacros.h"
#include "godef.h"
#include "grerr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "ASmatrix.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "madef.h"

#define AS_DEBUG

from GRconnector import  GRdisconn;

method  NDattach_to_cs(IGRlong *msg; struct GRid cs_grid,contents;
                       struct GRid *as_grid; struct GRmd_env *md_env)
{
IGRlong status;
struct GRid my_grid;


/*| Look for a possible cycle in the graph   */

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  if(nd$dep_exist( l_root = &my_grid,  nb_root = 1,
                   l_tip  = &contents,  nb_tip = 1 )) return (OM_S_SUCCESS);

 
/* do a connect is enough (will ND_FULL to disconnect from previous cs if any */

 status = om$send(msg = message NDnode.NDconnect(1,&contents,NULL_GRID,ND_FULL),
		  targetid = my_id);
 as$status();

 as_grid->objid = my_id;
 as_grid->osnum = OM_Gw_current_OS;
 *msg = MSSUCC;
 return(OM_S_SUCCESS);
  
}


method  NDdetach_from_cs(IGRlong *msg; struct GRid cs_grid,contents;
                       struct GRid *as_grid; struct GRmd_env *md_env)
{
IGRlong status;
IGRint count;
struct GRid my_root;

  /* I don't change objid */
   as_grid->objid = my_id;
   as_grid->osnum = OM_Gw_current_OS;

  /* get my roots */

   status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,&my_root,1,NULL,
					       0,1,&count),
		    targetid = my_id);
   as$status(action = RET_STATUS);
   if( count == 0 ) return(OM_S_SUCCESS);
   if(!IF_NULL_OBJID(contents.objid)  &&
      !IF_EQ_OBJID(contents.objid,my_root.objid)) return(OM_S_SUCCESS);
      
       
  /* disconnect the source object from the AScontents */

     status = om$send( msg = message NDnode.NDdisconnect( 0, NULL ),
                       targetid = my_id);
     as$status();

  /* disconnect the graphic object from contents */

     status = om$send( msg = message GRconnector.GRdisconn( msg, &my_root ),
		       p_chanselect = &AS_listeners);
     as$status();

     *msg = MSSUCC;
     return(OM_S_SUCCESS);
}
end implementation ASsource;
