/* $Id: VDunwSrf.I,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	VDunwSrf.I
 *
 * Description: Main public interface to new routines
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDunwSrf.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:31  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  2000/03/24  17:36:34  pinnacle
# ah
#
# Revision 1.1  1999/10/26  19:31:06  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/20/99  ah      Creation
 *
 ***************************************************************************/

class implementation VDSroot;

#ifndef DEBUG
#define DEBUG 1
#endif

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDsa.h"
#include "VDgeom.h"

#include "VDunwrap.h"
#include "VDefp.h"

static int traceFlag;

/* ------------------------------------
 * Starting point for unwrapping plate
 * in VDS
 */
IGRstat VDunwUnwrapPlate(TGRobj_env *plateOE)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDunwDevSrfInfo devInfo;
  IGRint tessOption;

  // Arg check
  if ((plateOE == NULL) || (plateOE->obj_id.objid == NULL_OBJID)) goto wrapup;

  // Say hi
  traceFlag = 1;
  if (traceFlag) {
    printf("---------------------------------------\n");
    printf(">>> VDunwUnwrapPlate\n");
    vdobj$Print(objOE = plateOE);
  }

  // Setup developable stuff
  VDunwInitDevSrfInfo(&devInfo);
  
  // Get the surface to work on
  vdobj$GetFoot(objOE    =  plateOE, 
		footName =  VDEFP_PLATE_BASE_SURF_NAME, 
		footOE   = &devInfo.surf_id);
  if (devInfo.surf_id.obj_id.objid == NULL_OBJID) goto wrapup;

  // Note: Loft code makes a copy here???, Becauses of edges???

  // Really should filter out planar surfaces here

  // Get the surface geomotry with edges
  vdgeom$GetSurface(objOE = &devInfo.surf_id, 
                    getEdges = 1, 
                    srf = &devInfo.surface);
  if (devInfo.surface == NULL) goto wrapup;

  // Setup some options
  devInfo.tesselation_option  = 1;  // Want this for shell plates???
  tessOption                  = 1;  // Check if it changes

  devInfo.type         = 4;  // Not sure
  devInfo.developpable = 0;
  devInfo.fib_ratio    = .5;

  // Might need to mess with orientation to change direction???
  vdsa$GetStruct(objOE = plateOE, 
                 name  = "thickness", 
                 dbl   = &devInfo.epaisseur);

  // Ready to rock
  sts = VDunwGetPtsNorms(&devInfo,tessOption,0.0);
  VDunwPrintDevSrfInfo(&devInfo,1);
  if (!(sts & 1)) goto wrapup;
  
  // Done
  retFlag = 1;

wrapup:
  VDunwFreeDevSrfInfo(&devInfo);
  if (traceFlag) printf("<<< VDunwUnwrapPlate %d\n",retFlag);
  return retFlag;
}

end implementation VDSroot;





