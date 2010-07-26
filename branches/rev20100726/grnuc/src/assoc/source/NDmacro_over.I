/*
   ASsource implementation file for NDmacro override 

HISTORY :
   jla October 90 : design date
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

/* ========================================================================= */

method   ACreturn_foot(IGRlong *msg;char *footname;
                struct GRid *foot_GRid;IGRshort *mat_type;IGRdouble *matrix)
{
struct GRid go;
int status;
  /*"ACreturn_foot %s, \n",footname */
  *msg=0;

  status = om$send( msg = message NDnode.ASreturn_go(&go,mat_type,matrix),
              targetid = my_id);
   as$status(action = RET_STATUS);
  if('.'== footname[0]|| 0 == footname[0] )
  {
   *foot_GRid = go;
   *msg = 1;
  }
  else
  {
   status = om$send(msg = message NDmacro.ACreturn_foot(msg,footname,foot_GRid,
					mat_type,matrix),
                    targetid = go.objid,
                    targetos = go.osnum);
  }

  return( status );
}
end implementation ASsource;
