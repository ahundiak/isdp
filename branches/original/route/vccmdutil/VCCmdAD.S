
/* $Id: VCCmdAD.S,v 1.1.1.1 2001/01/04 21:12:30 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccmdutil/VCCmdAD.S
 *
 * Description:
 *      Command object for attach/detach cable
 *
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCmdAD.S,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:30  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:17:36  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.6  1997/10/06  16:46:18  pinnacle
# Replaced: vccmdutil/VCCmdAD.S for:  by apazhani for cabling
#
# Revision 1.5  1997/03/19  18:33:00  pinnacle
# Replaced: vccmdutil/VCCmdAD.S for:  by hverstee for cabling
#
# Revision 1.4  1997/03/12  22:18:02  pinnacle
# Replaced: vccmdutil/VCCmdAD.S for:  by hverstee for cabling
#
# Revision 1.3  1997/01/16  14:53:24  pinnacle
# Replaced: vccmdutil/VCCmdAD.S for:  by hverstee for cabling
#
# Revision 1.2  1996/11/21  21:33:16  pinnacle
# Replaced: vccmdutil/VCCmdAD.S for:  by hverstee for cabling
#
# Revision 1.1  1996/10/15  19:33:02  pinnacle
# Created: vccmdutil/VCCmdAD.S by hverstee for cabling
#
 *
 * History:
 *        07/10/96        hv        Initial
 *        09/25/97        Alwin     Added the message VCADMoAttVertex
 *
 *************************************************************************/

class specification VCCmdAD (1:0) of VDS_LOCATE;

#include <stdio.h>
#include <string.h>
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "FI.h"
#include "FEI.h"

#include "ex.h"
#include "exmacros.h"
#include "msdef.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "coimport.h"
#include "COBmacros.h"

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "AS_status.h"

#include "VRtracer.h"

#include "VCdefine.h"
#include "VCstructs.h"
#include "VCCmdDef.h"
#include "VCCmdStr.h"
#include "VCparameters.h"

instance VCCmdAD
{
  IGRint                MyType;       /* Type   (attach/detach)     */
  IGRint                MyRet;        /* Private return code        */
  IGRint                LocType;      /* Picked element type        */
  IGRboolean            bSecGiven;    /* Second vertex input        */
  IGRboolean            bReverse;     /* vertices reversed          */

  IGRint                Vtx1;         /* first vertex to be replaced   */
  IGRint                Vtx2;         /* second vertex to be replaced  */
  IGRint                SectNo;       /* section number                */

  IGRshort              iCFrom;       /* connectpoint indicators for   */
  IGRshort              iCTo;         /*   guides/raceway sections     */

                                      /* Accept points, indicating Vertices */

  IGRdouble             dCVtx1[3];    /* Insertion vertex 1   */
  IGRdouble             dCVtx2[3];    /* Insertion vertex 2   */

  struct GRid           RefId;        /* Item picked (point or conduit) */
  struct GRid           AssId;        /* Item picked (point or conduit) */
                                      /* (same as RefId -or- pretend)   */
  struct GRid           CabId;        /* Item picked (cable)            */
  struct IGRpolyline    LineIn;       /* Section linestring             */

  /*   for items in ref files save modenv  */

  struct GRmd_env       AltEnv;

  /*  Two step raceway specification     */

  struct GRid                     RacewayId;     /*  startpoint   */
  IGRshort                        ICbeg;
  IGRshort                        ICend;

  IGRshort                        nRWtr;
  struct VR_tracerec             *RWTrac;
};


override init;

message VCADReset ( long * sts );

message VCADDel ( long * sts );

message VCADGetFather ( long * sts );

message VCADGetCable ( long * sts );

message VCADGetVtx2 ( long * sts );

message VCADProcess ( long * sts );

message VCADGetARW (long * sts);

message VCADRWfill (long * sts);

/* This message (VCADMoAttVertex) provides the facility to move the vertex 
 without inserting any vertex. Currently while attaching vertex to a point, 
 it inserts a vertex at that point. Alwin */

message VCADMoAttVertex (long * sts); 

end specification VCCmdAD;
