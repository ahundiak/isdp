/* $Id: VDefpNatEd.I,v 1.2 2001/01/11 19:04:49 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdefp/VDefpNatEd.I
 *
 * Description: Natural Edge Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDefpNatEd.I,v $
 *      Revision 1.2  2001/01/11 19:04:49  art
 *      sp merge
 *
# Revision 1.2  2000/10/16  17:21:46  pinnacle
# ah
#
# Revision 1.1  2000/04/11  17:16:00  pinnacle
# ah
#
# Revision 1.1  2000/03/27  21:27:58  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/24/00  ah      Creation
 * 04/11/00  ah      TR179901283 Warning
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDmem.h"
#include "VDgeom.h"
#include "VDefp.h"

#include "VDdbgProto.h"

#include "EMSopt.h"
#include "EMSlcdef.h"

static int traceFlag;

/* -----------------------------------------------
 * Try again
 */
IGRstat VDefpComputeNatEdges(TGRobj_env *macOE,
			     IGRint      opFlag,
			     IGRint     *edgeCnt,
			     TGRid      *edgeIDs)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRobj_env plateOE;
  TGRobj_env srfOE;
  
  IGRpoint centerPT;
  TGRid    centerID;
  
  struct {
    IGRint max;
    IGRint cnt;
    IGRint i;
    TGRbsp_curve *bsps[VDEFP_NEAT_EDGES_MAX];
  } edge;
  
  // Init
  memset(&edge,0,sizeof(edge));
  edge.max = VDEFP_NEAT_EDGES_MAX;
  
  // Arg check
  if (edgeCnt) *edgeCnt = 0;
  
  // Get 1st parent, either the surface or a plate
  vdobj$GetTemplate(objOE      = macOE,
                    nth        = 0,
                    templateOE = &plateOE);
  if (plateOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  // Get the surface
  vdobj$GetFoot(objOE    = &plateOE, 
		footName =  VDEFP_PLATE_BASE_SURF_NAME, 
		footOE   = &srfOE);

  if (srfOE.obj_id.objid == NULL_OBJID) goto wrapup;

  //printf("=========================\n");
  //vdobj$Print(objOE = &plateOE);
  //vdobj$Print(objOE = &srfOE);
  
  // Get the geomotryies
  sts = VDgeomGetSurfaceNaturalOuterContourGeometry(&srfOE,
						    edge.max,
						    &edge.cnt,
						    edge.bsps);

  // printf("Edge count %d\n",edge.cnt);

  // TR179901283 Warning
  if (sts == 3) {
    printf("*** The following plate may have invalid internal cutout geometry\n");
    vdobj$Print(objOE = &plateOE);
  }
  
  // Center point is useful
  VDefpGetSurfaceCenter(&srfOE,centerPT);
  VDdrawLinear(1,centerPT,&macOE->mod_env,&centerID);

  if (centerID.objid == NULL_OBJID) {
    printf("Problem making center point\n");
    goto wrapup;
  }
  edgeIDs[0] = centerID;
  *edgeCnt = 1;

  // Make the edge objects
  for(edge.i = 0; edge.i < edge.cnt; edge.i++) {
    
    /* 15 Oct 2000 - Added env */
    VDdrawCurve(edge.bsps[edge.i],
		&macOE->mod_env,
		&edgeIDs[*edgeCnt]);

    if (edgeIDs[*edgeCnt].objid == NULL_OBJID) {
      printf("Problem creating edge object\n");
    }
    else *edgeCnt = *edgeCnt + 1;
    _FREE(edge.bsps[edge.i]);
  }
  
  // Done
  retFlag = 1;
  
 wrapup:

  return retFlag;
  
}


end implementation Root;


