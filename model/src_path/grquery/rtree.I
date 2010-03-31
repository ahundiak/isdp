class implementation GRrtree;

#include <stdio.h>
#include <memory.h>

#include "PWminimum.h"
#include "PWerror.h"

#include "PWapi/rtree.h"

PWresult pwAddObjToRtree
(
  PWobjid objid,
  PWosnum os,
  PWrange range
)
{

    int status=OM_S_SUCCESS,ret=0, how_big=0;  
    OM_S_KEY_DESC  rtree_key;
    DB_3D_DBL_BOX  rtrange;
    PWobjid  grtree;

    how_big =  sizeof (DB_3D_DBL_BOX);
    rtree_key.type = KEY_3D_DBL;

    grtree = omObjOfClass (omClassidFromName ("GRrtree", os), os);
 
    rtree_key.key.p_3ddbl = &rtrange;
    memcpy((char *)rtree_key.key.p_3ddbl, (char *)range, how_big);

    status = om$send ( mode = OM_e_wrt_object, 
                       msg = message GRrtree.add ( &rtree_key, &objid, 
                                     NULL, &ret),
		senderid = NULL_OBJID,
		targetid = grtree,
		targetos = os);
    om$report_error(sts =status);

    return(status);  		
}

end implementation GRrtree;
