/* $Id: VCCmdGdVX.S,v 1.1.1.1 2001/01/04 21:12:30 cvs Exp $  */
/*************************************************************************
 * I/CABLE
 *
 * File:        vccmdutil/VCCmdGdVX.S
 *
 * Description:
 *      Command object for insert/move/delete Guide vertex
 *
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCmdGdVX.S,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:30  cvs
 *        Initial import to CVS
 *
# Revision 1.1  2000/03/24  14:16:18  pinnacle
# Created for Guide Vertex Move/Delete/Insert command.
#
 *
 * History:
 *        03/24/2000		Alwin		Creation
 *
 *************************************************************************/

class specification VCCmdGdVX (1:0) of VDS_LOCATE;

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

#include "VCdefine.h"
#include "VCstructs.h"
#include "VCCmdDef.h"
#include "VCCmdStr.h"
#include "VCparameters.h"

instance VCCmdGdVX
{
  struct GRid     RefId;       	/*C Guide being modified   */
  IGRint		  SendType;		/*C Type for VCGdModify */
  IGRint          VtxNo;       	/*C Vertex number being modified  */
  IGRint		  SegmentNo;	/*C Find the segment selected */
IGRint          IX;          	/*C Preserved coordinate index  */

  IGRdouble       dDyn[12];    	/*C Dynamics buffer    */

  struct GRid	  LineId;		/*C to store the line string Id */

  /*    automatic detent      */
  struct VCVX_detent	Detent;
  struct GRmd_env      MdEnv;
};


override init;
override dynamics;

/* Get the located object */
message VCGetItem ( long * sts );

/* Find the segment closest to the user selection */
message VCGdLocateSegment ( long * sts ); 

/* Find the vertex closest to the user selection */
message VCGdLocateVertex ( long * sts ); 
									
/* Modify the Guide based on selection */
message VCGdModify ( long * sts ); 

message VCGdVXcorners( IGRdouble *pT1; IGRdouble *pT2 );

end specification VCCmdGdVX;

