class implementation DMroot;

#define AS_DEBUG 1

%safe
#include "math.h"
%endsafe

#include "OMDB.h"
#include "dimdef.h"
#include "dimlinear.h"
#include "dimgraph.h"
#include "griodef.h"
#include "griomacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "msmacros.h"
#include "DMmsg.h"
#include "dimweld.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"

from OMrtree import find_key,find_and_remove,remove;

DMcleanup_non_rtree_dimensions(msg,dim_grid,info)
IGRlong *msg;
struct GRid *dim_grid;
char *info;
{
  IGRint status,ret,f_flag,i;
  IGRlong long_rc;
  struct GRmd_env mod_env;
  char name[80];
  OM_S_KEY_DESC select_key_rtree_range,rtree_key_test;
  GRrange search_range, rtree_range;
  DB_3D_DBL_BOX     rtrange_test;
  OM_S_CHANSELECT chan;
  int dim_object_is_nan = 0;

  strcpy(name, "primary");
  chan.type = OM_e_name;
  chan.u_sel.name = name;

  *msg =MSSUCC;

  DMget_module_info( &mod_env);
  select_key_rtree_range.type = KEY_3D_DBL;
  select_key_rtree_range.key.p_3ddbl = (DB_3D_DBL_BOX *)rtree_range;
  rtree_key_test.type = KEY_3D_DBL;
  rtree_key_test.key.p_3ddbl = &rtrange_test;


  status = om$send(msg = message OMrtree.find_key(
                      NULL,
                      &dim_grid->objid,
                      &select_key_rtree_range,
                      0, &ret),
           senderid = mod_env.md_id.objid,
           p_chanselect = &chan);


  if(ret != DB_SUCCESS)
  {
      /* Remove this object as it is not present in the rtree */
      om$send(msg = message Root.delete(f_flag),
          senderid = dim_grid->objid,
          targetid = dim_grid->objid,
          targetos = dim_grid->osnum);
      printf( " %d : Root.delete successful.\n", dim_grid->objid );
      return(OM_S_SUCCESS);
    
  }
  else
  {
    if(( status = GRvalidate_rtree_range((double *)rtree_range)) 
             != OM_S_SUCCESS )
    {
      rtrange_test.xmin = rtree_range[0];
      rtrange_test.ymin = rtree_range[1];
      rtrange_test.zmin = rtree_range[2];

      rtrange_test.xmax = rtree_range[3];
      rtrange_test.ymax = rtree_range[4];
      rtrange_test.zmax = rtree_range[5];

      status = om$send(msg = message OMrtree.find_and_remove(
                      &rtree_key_test, &dim_grid->objid,
                      0 ,&ret),
               senderid = mod_env.md_id.objid,
               p_chanselect = &chan);

      printf( "Key for object = %d has been found and removed\n", 
                dim_grid->objid );

          om$send(msg = message Root.delete(f_flag),
                  senderid = dim_grid->objid,
                  targetid = dim_grid->objid,
                  targetos = dim_grid->osnum);
      printf( " Root.delete successful.\n" );
    }
    
   }
  
  return(OM_S_SUCCESS);
}
end implementation DMroot;
